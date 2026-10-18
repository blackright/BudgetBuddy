import 'dart:convert';

import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/paired_context.dart';
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

/// T068: an added person's phone receives the space **whole** — the real name,
/// currency and income, the Owner's membership and the money already in it —
/// even though the Owner authored all of it before the person existed; and the
/// joining phone's own edits flow back (two-way, T067). The join completes after
/// one snapshot round (T066 journals the pre-existing history).
void main() {
  late SyncTestHarness harnessA;
  late SyncTestHarness harnessB;
  late DeviceKeys keysA;
  late DeviceKeys keysB;
  late FakeTransportHub hub;
  late Transport endpointA;
  late SyncEngine engineA;
  late SyncEngine engineB;
  late SyncRecorder recorderA;
  late SyncRecorder recorderB;

  const int spaceA = 1;
  const int peerAOnB = 7;
  const int peerBOnA = 8;

  Future<SharedMember> addMember({
    required SyncTestHarness harness,
    required int spaceId,
    required DeviceKeys subject,
    required DeviceKeys author,
    required SharedMemberRole role,
  }) async {
    final member = SharedMember()
      ..sharedSpaceId = spaceId
      ..profileId = sharedMemberKey(subject.identityId)
      ..role = role
      ..joinedAt = DateTime(2026)
      ..version = 1
      ..updatedAt = DateTime(2026)
      ..authorIdentityId = author.identityId;
    final signature = await Ed25519()
        .sign(membershipCanonicalBytes(member), keyPair: author.keyPair);
    member.signature = base64Encode(signature.bytes);
    member.id = await harness.isar
        .writeTxn(() => harness.isar.sharedMembers.put(member));
    return member;
  }

  setUp(() async {
    harnessA = await SyncTestHarness.create();
    harnessB = await SyncTestHarness.create();
    keysA = await DeviceKeys.generate('idA');
    keysB = await DeviceKeys.generate('idB');

    hub = harnessA.transport;
    endpointA = hub.endpoint('idA', username: 'A');
    hub.endpoint('idB', username: 'B');

    final trusted = {
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
    recorderB = SyncRecorder(
      harnessB.isar,
      signer: Ed25519ChangeSigner(
        authorIdentityId: keysB.identityId,
        keyPair: keysB.keyPair,
      ),
      clock: HlcClock(deviceId: 'devB'),
    );

    // A knows B as a contact and vice versa; the joining phone needs the peer
    // row so it can mirror the context (T067).
    await harnessA.isar
        .writeTxn(() => harnessA.isar.pairedPeers.put(PairedPeer()
          ..peerIdentityId = keysB.identityId
          ..pairedAt = DateTime(2026)));
    await harnessB.isar
        .writeTxn(() => harnessB.isar.pairedPeers.put(PairedPeer()
          ..id = peerAOnB
          ..peerIdentityId = keysA.identityId
          ..pairedAt = DateTime(2026)));
    await harnessA.isar
        .writeTxn(() => harnessA.isar.pairedPeers.put(PairedPeer()
          ..id = peerBOnA
          ..peerIdentityId = keysB.identityId
          ..pairedAt = DateTime(2026)));
  });

  tearDown(() async {
    await harnessA.close();
    await harnessB.close();
  });

  Future<void> converge() async {
    final advertisementB =
        hub.advertisements().firstWhere((a) => a.identityId == 'idB');
    final incomingB = hub.nextIncoming('idB');
    final connectionA = await endpointA.connect(advertisementB);
    final connectionB = await incomingB;
    final bFuture =
        engineB.exchange(connectionB, contextLocalId: 0, peerId: peerAOnB);
    final aFuture = engineA.exchange(connectionA,
        contextLocalId: spaceA, initiator: true, peerId: peerBOnA);
    await Future.wait([aFuture, bFuture]);
    await connectionA.close();
    await connectionB.close();
  }

  test('A\'s full history reaches B whole, and B\'s edit flows back', () async {
    final spaceGuid = newSyncGuid();

    // --- Owner authors everything BEFORE anyone is added ----------------------
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
      ..yearMonth = '2026-03'
      ..baseAvailableAmount = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026)
      ..syncGuid = newSyncGuid();
    final expense = Expense(
      id: 1,
      profileId: sharedMemberKey(keysA.identityId),
      sharedSpaceId: spaceA,
      yearMonth: '2026-03',
      title: 'Groceries',
      amount: 4200,
      currency: 'usd',
      categoryId: 'general',
      date: DateTime.utc(2026, 3, 5),
      budgetId: 1,
    )..syncGuid = newSyncGuid();

    expect(await harnessA.isar.pairedContexts.count(), 0,
        reason: 'nothing is paired yet; T066 must still journal the history');

    final ownerMember = await addMember(
        harness: harnessA,
        spaceId: spaceA,
        subject: keysA,
        author: keysA,
        role: SharedMemberRole.owner);
    final bMember = await addMember(
        harness: harnessA,
        spaceId: spaceA,
        subject: keysB,
        author: keysA,
        role: SharedMemberRole.editor);

    ChangeRecord? spaceRec;
    ChangeRecord? memberRec;
    ChangeRecord? expenseRec;
    await harnessA.isar.writeTxn(() async {
      await harnessA.isar.sharedSpaces.put(space);
      await harnessA.isar.monthlyBudgets.put(budget);
      await harnessA.isar.expenses.put(expense);
      spaceRec = await recorderA.recordSpace(space);
      await recorderA.recordMember(ownerMember);
      memberRec = await recorderA.recordMember(bMember);
      await recorderA.recordBudget(budget);
      expenseRec = await recorderA.recordExpense(expense);
    });
    expect(spaceRec, isNotNull,
        reason: 'the space is journaled unpaired (T066)');
    expect(memberRec, isNotNull,
        reason: 'the membership is journaled unpaired (T066)');
    expect(expenseRec, isNotNull,
        reason: 'the money is journaled unpaired (T066)');

    // --- One round: the space arrives whole on B ------------------------------
    await converge();

    final bSpace = (await harnessB.isar.sharedSpaces
        .filter()
        .syncGuidEqualTo(spaceGuid)
        .findFirst())!;
    expect(bSpace.name, 'Family', reason: 'the real name, not the anchor');
    expect(bSpace.defaultIncome, 555000);
    expect(bSpace.isPendingSync, isFalse);
    expect(
        (await harnessB.memberFor(
                bSpace.id, sharedMemberKey(keysA.identityId)))!
            .role,
        SharedMemberRole.owner);
    expect(await harnessB.expenseByGuid(expense.syncGuid), isNotNull);

    // The joining phone mirrors the context so it can send its own edits (T067).
    final mirrored = await harnessB.isar.pairedContexts
        .filter()
        .contextLocalIdEqualTo(bSpace.id)
        .findFirst();
    expect(mirrored, isNotNull, reason: 'B gains a context for the space');
    expect(mirrored!.peerId, peerAOnB);

    // --- B edits offline, then the second round carries it back to A ----------
    final bExpense = Expense(
      id: 9,
      profileId: sharedMemberKey(keysB.identityId),
      sharedSpaceId: bSpace.id,
      yearMonth: '2026-03',
      title: 'B top-up',
      amount: 1500,
      currency: 'usd',
      categoryId: 'general',
      date: DateTime.utc(2026, 3, 6),
      budgetId: 1,
    )..syncGuid = newSyncGuid();
    await harnessB.isar.writeTxn(() async {
      await harnessB.isar.expenses.put(bExpense);
      await recorderB.recordExpense(bExpense);
    });

    await converge();

    expect(await harnessA.expenseByGuid(bExpense.syncGuid), isNotNull,
        reason: 'B\'s own edit flows back to the Owner (two-way)');
  });
}
