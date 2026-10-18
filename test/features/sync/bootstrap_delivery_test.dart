import 'dart:convert';

import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/insurance_profile.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_service_type.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/spaces/domain/shared_member_key.dart';
import 'package:budget_buddy/features/sync/domain/change_signing.dart';
import 'package:budget_buddy/features/sync/domain/hlc.dart';
import 'package:budget_buddy/features/sync/domain/sync_guid.dart';
import 'package:budget_buddy/features/sync/repositories/change_signer.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'package:budget_buddy/features/sync/repositories/sync_recorder.dart';
import 'package:budget_buddy/features/sync/transport/transport.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'support/change_factory.dart';
import 'support/fake_transport.dart';
import 'support/sync_harness.dart';

/// T046 (US2, SC-002/SC-003): a context the receiver has **never seen**
/// materializes **whole** after one exchange — the real name, currency and
/// income, both memberships with their roles, the month, the money **and the
/// shared medical directory** (family members, providers, service types, the
/// insurance plan), with every cross-reference resolving to the receiver's
/// **own** local row id.
///
/// A truncated delivery is completed by the next round **in the same row**
/// (nothing is half-applied and nothing is duplicated), and the materialized
/// space survives an engine restart.
void main() {
  late SyncTestHarness harnessA;
  late SyncTestHarness harnessB;
  late DeviceKeys keysA;
  late DeviceKeys keysB;
  late Map<String, SimplePublicKey> trusted;
  late FakeTransportHub hub;
  late Transport endpointA;
  late SyncEngine engineA;
  late SyncEngine engineB;
  late SyncRecorder recorderA;

  const int spaceA = 1;
  const int peerAOnB = 7;
  const int peerBOnA = 8;
  const String month = '2026-03';

  /// Everything the Owner shares, by device-independent identity.
  late _History history;

  setUp(() async {
    harnessA = await SyncTestHarness.create();
    harnessB = await SyncTestHarness.create();
    keysA = await DeviceKeys.generate('idA');
    keysB = await DeviceKeys.generate('idB');

    // B already holds its own local rows, so the delivered space cannot reuse
    // A's local id — the 012 gap the per-entity guid closes (research R5).
    await harnessB.createSpace(name: 'B personal one');
    await harnessB.createSpace(name: 'B personal two');

    hub = harnessA.transport;
    endpointA = hub.endpoint('idA', username: 'A');
    hub.endpoint('idB', username: 'B');

    trusted = {
      keysA.identityId: keysA.publicKey,
      keysB.identityId: keysB.publicKey,
    };
    engineA = SyncEngine(harnessA.isar,
        trustedKeys: trusted, selfIdentityId: keysA.identityId);
    engineB = SyncEngine(harnessB.isar,
        trustedKeys: trusted, selfIdentityId: keysB.identityId);

    recorderA = SyncRecorder(
      harnessA.isar,
      signer: Ed25519ChangeSigner(
        authorIdentityId: keysA.identityId,
        keyPair: keysA.keyPair,
      ),
      clock: HlcClock(deviceId: 'devA'),
    );

    // A knows B as a contact; B knows A, so B can mirror the context (T067).
    await harnessA.isar
        .writeTxn(() => harnessA.isar.pairedPeers.put(PairedPeer()
          ..id = peerBOnA
          ..peerIdentityId = keysB.identityId
          ..pairedAt = DateTime(2026)));
    await harnessB.isar
        .writeTxn(() => harnessB.isar.pairedPeers.put(PairedPeer()
          ..id = peerAOnB
          ..peerIdentityId = keysA.identityId
          ..pairedAt = DateTime(2026)));
  });

  tearDown(() async {
    await harnessA.close();
    await harnessB.close();
  });

  /// One full snapshot round: A initiates, B responds.
  Future<({int appliedOnA, int appliedOnB})> converge({
    SyncEngine? responderOverride,
  }) async {
    final advertisementB =
        hub.advertisements().firstWhere((a) => a.identityId == 'idB');
    final incomingB = hub.nextIncoming('idB');
    final connectionA = await endpointA.connect(advertisementB);
    final connectionB = await incomingB;
    final bFuture = (responderOverride ?? engineB)
        .exchange(connectionB, contextLocalId: 0, peerId: peerAOnB);
    final aFuture = engineA.exchange(connectionA,
        contextLocalId: spaceA, initiator: true, peerId: peerBOnA);
    final results = await Future.wait([aFuture, bFuture]);
    await connectionA.close();
    await connectionB.close();
    return (appliedOnA: results[0], appliedOnB: results[1]);
  }

  /// The Owner authors a whole space — membership, money **and** the medical
  /// directory a bill points at — before the member exists (T066 journals it).
  Future<_History> seedOwnerHistory() async {
    final spaceGuid = newSyncGuid();
    final budgetGuid = newSyncGuid();
    final expenseGuid = newSyncGuid();
    final familyGuid = newSyncGuid();
    final providerGuid = newSyncGuid();
    final serviceTypeGuid = newSyncGuid();
    final insuranceGuid = newSyncGuid();
    final billGuid = newSyncGuid();

    final space = SharedSpace()
      ..id = spaceA
      ..name = 'Family'
      ..avatar = '🏠'
      ..currency = PrimaryCurrency.usd
      ..defaultIncome = 555000
      ..createdByProfileId = 1
      ..createdAt = DateTime(2026)
      ..syncGuid = spaceGuid;
    final budget = MonthlyBudget()
      ..id = 1
      ..sharedSpaceId = spaceA
      ..yearMonth = month
      ..baseAvailableAmount = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026)
      ..syncGuid = budgetGuid;
    final family = FamilyMember()
      ..id = 1
      ..sharedSpaceId = spaceA
      ..name = 'Sam'
      ..relation = 'Self'
      ..syncGuid = familyGuid;
    final provider = MedicalProvider()
      ..id = 1
      ..sharedSpaceId = spaceA
      ..name = 'City Hospital'
      ..specialty = 'Radiology'
      ..syncGuid = providerGuid;
    final serviceType = MedicalServiceType()
      ..id = 1
      ..sharedSpaceId = spaceA
      ..name = 'X-ray'
      ..syncGuid = serviceTypeGuid;
    final insurance = InsuranceProfile()
      ..id = 1
      ..sharedSpaceId = spaceA
      ..insurerName = 'Blue Cross'
      ..planName = 'PPO 500'
      ..syncGuid = insuranceGuid;
    final expense = Expense(
      id: 1,
      profileId: sharedMemberKey(keysA.identityId),
      sharedSpaceId: spaceA,
      yearMonth: month,
      title: 'Groceries',
      amount: 4200,
      currency: 'usd',
      categoryId: 'general',
      date: DateTime.utc(2026, 3, 5),
      budgetId: 1,
    )..syncGuid = expenseGuid;
    final bill = MedicalBill()
      ..id = 1
      ..sharedSpaceId = spaceA
      ..linkedExpenseId = 1
      ..familyMemberId = 1
      ..providerId = 1
      ..serviceTypeId = 1
      ..yearMonth = month
      ..serviceDate = DateTime.utc(2026, 3, 5)
      ..billedAmount = 30000
      ..currency = 'usd'
      ..state = MedicalBillState.waiting
      ..paymentMethod = MedicalPaymentMethod.selfPaid
      ..syncGuid = billGuid;

    final ownerMember = SharedMember()
      ..sharedSpaceId = spaceA
      ..profileId = sharedMemberKey(keysA.identityId)
      ..role = SharedMemberRole.owner
      ..joinedAt = DateTime(2026)
      ..version = 1
      ..updatedAt = DateTime(2026)
      ..authorIdentityId = keysA.identityId;
    final bMember = SharedMember()
      ..sharedSpaceId = spaceA
      ..profileId = sharedMemberKey(keysB.identityId)
      ..role = SharedMemberRole.editor
      ..joinedAt = DateTime(2026)
      ..version = 1
      ..updatedAt = DateTime(2026)
      ..authorIdentityId = keysA.identityId;
    for (final member in [ownerMember, bMember]) {
      final signature = await Ed25519()
          .sign(membershipCanonicalBytes(member), keyPair: keysA.keyPair);
      member.signature = base64Encode(signature.bytes);
    }

    await harnessA.isar.writeTxn(() async {
      await harnessA.isar.sharedSpaces.put(space);
      await harnessA.isar.monthlyBudgets.put(budget);
      await harnessA.isar.familyMembers.put(family);
      await harnessA.isar.medicalProviders.put(provider);
      await harnessA.isar.medicalServiceTypes.put(serviceType);
      await harnessA.isar.insuranceProfiles.put(insurance);
      await harnessA.isar.expenses.put(expense);
      await harnessA.isar.medicalBills.put(bill);
      ownerMember.id = await harnessA.isar.sharedMembers.put(ownerMember);
      bMember.id = await harnessA.isar.sharedMembers.put(bMember);
      await recorderA.recordSpace(space);
      await recorderA.recordMember(ownerMember);
      await recorderA.recordMember(bMember);
      await recorderA.recordBudget(budget);
      await recorderA.recordExpense(expense);
      await recorderA.recordFamilyMember(family);
      await recorderA.recordMedicalProvider(provider);
      await recorderA.recordMedicalServiceType(serviceType);
      await recorderA.recordInsuranceProfile(insurance);
      await recorderA.recordMedicalBill(bill);
    });

    return _History(
      spaceGuid: spaceGuid,
      budgetGuid: budgetGuid,
      expenseGuid: expenseGuid,
      familyGuid: familyGuid,
      providerGuid: providerGuid,
      serviceTypeGuid: serviceTypeGuid,
      insuranceGuid: insuranceGuid,
      billGuid: billGuid,
    );
  }

  Future<SharedSpace> spaceOnB(String guid) async =>
      (await harnessB.isar.sharedSpaces
          .filter()
          .syncGuidEqualTo(guid)
          .findFirst())!;

  Future<int> monthTotal(SyncTestHarness harness, int spaceId) async {
    final rows = await harness.isar.expenses
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .yearMonthEqualTo(month)
        .findAll();
    return rows.fold<int>(0, (sum, expense) => sum + expense.amount);
  }

  /// The whole space as the member's phone must hold it: nothing missing and no
  /// reference left dangling.
  Future<void> expectWholeOnB() async {
    final space = await spaceOnB(history.spaceGuid);
    expect(space.name, 'Family', reason: 'the real name, not the anchor');
    expect(space.defaultIncome, 555000);
    expect(space.isPendingSync, isFalse);
    expect(space.id, isNot(spaceA),
        reason: 'the wire carries no local id; B keeps its own');

    expect(
        (await harnessB.memberFor(space.id, sharedMemberKey(keysA.identityId)))!
            .role,
        SharedMemberRole.owner);
    expect(
        (await harnessB.memberFor(space.id, sharedMemberKey(keysB.identityId)))!
            .role,
        SharedMemberRole.editor);

    final expense = (await harnessB.expenseByGuid(history.expenseGuid))!;
    expect(expense.sharedSpaceId, space.id);
    expect(expense.budgetId, isNot(0),
        reason: 'budgetId resolves to B\'s own month row');
    expect(await monthTotal(harnessA, spaceA),
        await monthTotal(harnessB, space.id),
        reason: 'the money reads identically on both phones');

    final family = (await harnessB.isar.familyMembers
        .filter()
        .syncGuidEqualTo(history.familyGuid)
        .findFirst())!;
    final provider = (await harnessB.isar.medicalProviders
        .filter()
        .syncGuidEqualTo(history.providerGuid)
        .findFirst())!;
    final serviceType = (await harnessB.isar.medicalServiceTypes
        .filter()
        .syncGuidEqualTo(history.serviceTypeGuid)
        .findFirst())!;
    final insurance = (await harnessB.isar.insuranceProfiles
        .filter()
        .syncGuidEqualTo(history.insuranceGuid)
        .findFirst())!;
    expect(family.name, 'Sam');
    expect(provider.name, 'City Hospital');
    expect(serviceType.name, 'X-ray');
    expect(insurance.insurerName, 'Blue Cross');
    expect(family.sharedSpaceId, space.id);
    expect(provider.sharedSpaceId, space.id);
    expect(serviceType.sharedSpaceId, space.id);
    expect(insurance.sharedSpaceId, space.id);

    final bill = (await harnessB.isar.medicalBills
        .filter()
        .syncGuidEqualTo(history.billGuid)
        .findFirst())!;
    expect(bill.sharedSpaceId, space.id);
    expect(bill.linkedExpenseId, expense.id,
        reason: 'the bill finds its own expense');
    expect(bill.familyMemberId, family.id,
        reason: 'the bill finds the family member');
    expect(bill.providerId, provider.id, reason: 'the bill finds the provider');
    expect(bill.serviceTypeId, serviceType.id,
        reason: 'the bill finds the service type');
  }

  test('a never-seen context materializes whole in one round', () async {
    history = await seedOwnerHistory();
    expect(await harnessB.isar.sharedSpaces.count(), 2,
        reason: 'B knows nothing of A\'s space yet');

    final result = await converge();

    expect(result.appliedOnB, greaterThan(0));
    await expectWholeOnB();
  });

  test(
      'a repeated exchange delivers exactly once, and a restart finds it whole',
      () async {
    history = await seedOwnerHistory();
    await converge();
    await expectWholeOnB();

    // The retry after an interrupted round re-sends the whole log: nothing is
    // applied twice and no row is duplicated (SC-003).
    final repeated = await converge();
    expect(repeated.appliedOnB, 0, reason: 'everything is already known');
    final space = await spaceOnB(history.spaceGuid);
    expect(
        await harnessB.isar.sharedMembers
            .filter()
            .sharedSpaceIdEqualTo(space.id)
            .count(),
        2);
    expect(
        await harnessB.isar.medicalBills
            .filter()
            .syncGuidEqualTo(history.billGuid)
            .count(),
        1);
    expect(
        await harnessB.isar.medicalProviders
            .filter()
            .syncGuidEqualTo(history.providerGuid)
            .count(),
        1);
    await expectWholeOnB();

    // A fresh engine over the same database is what a relaunched app builds:
    // the space is durable, complete and already up to date.
    final restarted = SyncEngine(harnessB.isar,
        trustedKeys: trusted, selfIdentityId: keysB.identityId);
    final afterRestart = await converge(responderOverride: restarted);
    expect(afterRestart.appliedOnB, 0,
        reason: 'nothing new arrives after a restart');
    await expectWholeOnB();
  });

  test('a truncated delivery is completed by the next round, exactly once',
      () async {
    history = await seedOwnerHistory();

    // The link died after only the space + memberships crossed (each incoming
    // record is applied in its own transaction, so a partial batch is real).
    final records = await harnessA.changeRecords();
    final partial = records
        .where((record) =>
            record.entityType == 'SharedSpace' ||
            record.entityType == 'SharedMember')
        .toList();
    for (final record in partial) {
      await engineB.applyIncoming(record, peerId: peerAOnB);
    }
    final partialSpace = await spaceOnB(history.spaceGuid);
    expect(partialSpace.name, 'Family');
    expect(await harnessB.isar.expenses.count(), 0,
        reason: 'the money has not arrived yet');

    // The next round re-sends the whole log: B completes in the same row.
    await converge();

    final space = await spaceOnB(history.spaceGuid);
    expect(space.id, partialSpace.id,
        reason: 'completed in place, not re-created under a new id');
    expect(
        await harnessB.isar.sharedSpaces
            .filter()
            .syncGuidEqualTo(history.spaceGuid)
            .count(),
        1);
    await expectWholeOnB();
  });
}

/// The device-independent identities of everything the Owner shared.
class _History {
  const _History({
    required this.spaceGuid,
    required this.budgetGuid,
    required this.expenseGuid,
    required this.familyGuid,
    required this.providerGuid,
    required this.serviceTypeGuid,
    required this.insuranceGuid,
    required this.billGuid,
  });

  final String spaceGuid;
  final String budgetGuid;
  final String expenseGuid;
  final String familyGuid;
  final String providerGuid;
  final String serviceTypeGuid;
  final String insuranceGuid;
  final String billGuid;
}
