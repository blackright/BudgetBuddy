import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/features/engine/currency_conversion.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:budget_buddy/features/sync/domain/hlc.dart';
import 'package:budget_buddy/features/sync/domain/sync_codec.dart';
import 'package:budget_buddy/features/sync/domain/sync_guid.dart';
import 'package:budget_buddy/features/sync/repositories/change_signer.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'package:budget_buddy/features/sync/repositories/sync_recorder.dart';
import 'package:budget_buddy/features/sync/transport/transport.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'support/change_factory.dart';
import 'support/fake_transport.dart';
import 'support/sync_harness.dart';

/// T042a: a sealed month delivered across two peers with **different** local ids
/// (FR-005/SC-006).
///
/// A sealed month's records are exchanged while unsealed, then frozen: once both
/// phones hold the seal, a later edit arriving from a peer is refused by
/// `SyncEngine._authorize` (`monthKeyOf` → sealed) and never changes the sealed
/// content. Each device re-renders identical totals from its *own* seal.
void main() {
  late SyncTestHarness harnessA;
  late SyncTestHarness harnessB;
  late DeviceKeys owner; // device A
  late DeviceKeys editor; // device B
  late FakeTransportHub hub;
  late Transport endpointA;
  late SyncEngine engineA;
  late SyncEngine engineB;
  late SyncRecorder recorderA;
  late String spaceGuid;

  const int spaceA = 1;
  const int spaceB = 2;
  const String month = '2026-03';

  setUp(() async {
    harnessA = await SyncTestHarness.create();
    harnessB = await SyncTestHarness.create();
    owner = await DeviceKeys.generate('owner');
    editor = await DeviceKeys.generate('editor');

    spaceGuid = newSyncGuid();
    await harnessA.createSpaceAt(localId: spaceA, syncGuid: spaceGuid);
    await harnessB.createSpaceAt(localId: spaceB, syncGuid: spaceGuid);

    for (final h in [harnessA, harnessB]) {
      final localId = identical(h, harnessA) ? spaceA : spaceB;
      await h.addSignedMember(
          spaceId: localId, keys: owner, role: SharedMemberRole.owner);
      await h.addSignedMember(
          spaceId: localId, keys: editor, role: SharedMemberRole.editor);
    }

    await harnessA.pairContext(peerId: 2, spaceId: spaceA);
    await harnessB.pairContext(peerId: 1, spaceId: spaceB);

    final trusted = {
      owner.identityId: owner.publicKey,
      editor.identityId: editor.publicKey,
    };
    engineA = SyncEngine(harnessA.isar,
        trustedKeys: trusted, selfIdentityId: owner.identityId);
    engineB = SyncEngine(harnessB.isar,
        trustedKeys: trusted, selfIdentityId: editor.identityId);

    recorderA = SyncRecorder(
      harnessA.isar,
      signer: Ed25519ChangeSigner(
        authorIdentityId: owner.identityId,
        keyPair: owner.keyPair,
      ),
      clock: HlcClock(deviceId: 'devA'),
    );

    hub = harnessA.transport;
    endpointA = hub.endpoint('idA', username: 'A');
    hub.endpoint('idB', username: 'B');
  });

  tearDown(() async {
    await harnessA.close();
    await harnessB.close();
  });

  Expense expenseAt(int id, int spaceId, String guid, {int amount = 100}) =>
      (Expense(
        id: id,
        profileId: 1,
        sharedSpaceId: spaceId,
        yearMonth: month,
        title: 'Coffee',
        amount: amount,
        currency: 'usd',
        categoryId: 'general',
        date: DateTime.utc(2026, 3, 5),
        budgetId: 1,
      ))
        ..syncGuid = guid;

  Future<void> writeExpense(
    SyncTestHarness harness,
    SyncRecorder recorder,
    int id,
    int spaceId,
    String guid, {
    int amount = 100,
    DateTime? now,
  }) async {
    final expense = expenseAt(id, spaceId, guid, amount: amount);
    await harness.isar.writeTxn(() async {
      await harness.isar.expenses.put(expense);
      await recorder.recordExpense(expense, now: now);
    });
  }

  Future<void> sealWithRates(SyncTestHarness h) => h.isar.writeTxn(() async {
        await h.isar.monthRateSeals.put(
          MonthRateSeal()
            ..yearMonth = month
            ..status = SealStatus.sealed
            ..ratesUsd = 1.0
            ..ratesHuf = 350.0
            ..ratesEur = 0.92
            ..ratesCad = 1.35
            ..asOf = DateTime.utc(2026, 3, 31)
            ..fetchedAt = DateTime.utc(2026, 3, 31)
            ..updatedAt = DateTime.utc(2026, 3, 31),
        );
      });

  /// One exchange; returns how many records A and B each applied.
  Future<(int, int)> converge() async {
    final advertisementB =
        hub.advertisements().firstWhere((a) => a.identityId == 'idB');
    final incomingB = hub.nextIncoming('idB');
    final connectionA = await endpointA.connect(advertisementB);
    final connectionB = await incomingB;

    final bFuture =
        engineB.exchange(connectionB, contextLocalId: spaceB, peerId: 1);
    final aFuture = engineA.exchange(connectionA,
        contextLocalId: spaceA, initiator: true, peerId: 2);
    final results = await Future.wait([aFuture, bFuture]);

    await connectionA.close();
    await connectionB.close();
    return (results[0], results[1]);
  }

  Future<int> monthTotalMinorOn(SyncTestHarness h) async {
    final localId = identical(h, harnessA) ? spaceA : spaceB;
    final all =
        await h.isar.expenses.filter().yearMonthEqualTo(month).findAll();
    final minor = all
        .where((e) => e.sharedSpaceId == localId)
        .fold<int>(0, (sum, e) => sum + e.amount);
    final seal = await h.isar.monthRateSeals
        .filter()
        .yearMonthEqualTo(month)
        .findFirst();
    return convert(
      Money(minor, CurrencyCode.usd),
      CurrencyCode.eur,
      seal!.toRateTable(),
    ).amount.minorUnits;
  }

  test('a month is delivered intact across distinct local ids, then frozen',
      () async {
    final guid = newSyncGuid();

    // 1. Unsealed: the Owner's expense is delivered to B (distinct local id).
    await writeExpense(harnessA, recorderA, 1, spaceA, guid);
    await converge();
    expect(await harnessB.expenseByGuid(guid), isNotNull);

    // 2. Byte-identical on both: the delivered payload and the rendered row
    //    match, keyed by GUID (no local id leaks onto the wire).
    final recordA = (await harnessA.isar.changeRecords.where().findAll())
        .singleWhere((r) => r.entitySyncGuid == guid);
    final recordB = (await harnessB.isar.changeRecords.where().findAll())
        .singleWhere((r) => r.entitySyncGuid == guid);
    expect(recordB.payload, recordA.payload,
        reason: 'the delivered payload is byte-identical');
    expect(recordB.authorIdentityId, recordA.authorIdentityId);
    expect(recordB.entitySyncGuid, recordA.entitySyncGuid);

    expect(
      canonicalJsonEncode(
          const ExpenseCodec().toJson((await harnessA.expenseByGuid(guid))!)),
      canonicalJsonEncode(
          const ExpenseCodec().toJson((await harnessB.expenseByGuid(guid))!)),
      reason: 'the delivered row renders byte-identically on both devices',
    );

    // 3. Both peers seal the month.
    await sealWithRates(harnessA);
    await sealWithRates(harnessB);

    // 4. Each device re-renders the frozen month's total from its *own* seal.
    expect(
        await monthTotalMinorOn(harnessA), await monthTotalMinorOn(harnessB));

    // 5. Re-delivering the sealed month changes nothing (idempotent).
    await converge();
    expect((await harnessB.expenseByGuid(guid))!.amount, 100);
  });

  test(
      'a post-seal edit arriving from a peer is refused by _authorize '
      '(FR-005/SC-006)', () async {
    final guid = newSyncGuid();

    // An expense is delivered, then both peers seal the month.
    await writeExpense(harnessA, recorderA, 1, spaceA, guid,
        now: DateTime.utc(2026, 3, 5));
    await converge();
    await sealWithRates(harnessA);
    await sealWithRates(harnessB);

    // A later edit authored on the peer (a fresh, higher-HLC signed change; the
    // recorder itself never checks the seal — the *apply* path must).
    final edited = expenseAt(1, spaceA, guid, amount: 999);
    final record = (await harnessA.isar.writeTxn(
        () => recorderA.recordExpense(edited, now: DateTime.utc(2026, 4, 1))))!;

    // Delivered over the wire: the sealed receiver applies nothing.
    final (_, bApplied) = await converge();
    expect(bApplied, 0, reason: 'a sealed month applies no incoming change');
    expect((await harnessB.expenseByGuid(guid))!.amount, 100,
        reason: 'the sealed content never changes');

    // The exact refusal, at the engine seam the delivery uses.
    expect(
      await engineB.applyIncoming(record),
      ApplyOutcome.droppedUnauthorized,
    );
    expect((await harnessB.expenseByGuid(guid))!.amount, 100);
  });
}
