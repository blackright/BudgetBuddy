import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/sync_cursor.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:budget_buddy/features/sync/domain/sync_guid.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'support/change_factory.dart';
import 'support/sync_harness.dart';

Expense _expense({
  required int id,
  required String title,
  required int amount,
  int profileId = 1,
  String? syncGuid,
}) =>
    Expense(
      id: id,
      profileId: profileId,
      sharedSpaceId: 1,
      yearMonth: '2026-03',
      title: title,
      amount: amount,
      currency: 'usd',
      categoryId: 'general',
      date: DateTime.utc(2026, 3, 5),
      budgetId: 1,
    )..syncGuid = syncGuid ?? newSyncGuid();

void main() {
  late SyncTestHarness harness;
  late DeviceKeys keys;

  setUp(() async {
    harness = await SyncTestHarness.create();
    keys = await DeviceKeys.generate('idA');
  });

  tearDown(() async => harness.close());

  SyncEngine engineOn(SyncTestHarness target) => SyncEngine(
        target.isar,
        trustedKeys: {keys.identityId: keys.publicKey},
      );

  test('arrival order does not change the winning row (FR-007, SC-002)',
      () async {
    // Same logical entity (one syncGuid), two versions: old then new.
    final guid = newSyncGuid();
    final oldRecord = await signedChange(
      keys: keys,
      deviceId: 'A',
      hlcMillis: 1000,
      payload: const ExpenseCodec().toPayload(
          _expense(id: 31, title: 'Old', amount: 100, syncGuid: guid)),
    );
    final newRecord = await signedChange(
      keys: keys,
      deviceId: 'A',
      hlcMillis: 2000,
      payload: const ExpenseCodec().toPayload(
          _expense(id: 31, title: 'New', amount: 200, syncGuid: guid)),
    );

    // Order 1 on the primary device: newest first, then the stale one.
    final engine = engineOn(harness);
    await engine.applyIncoming(newRecord);
    await engine.applyIncoming(oldRecord);
    final winnerForward = (await harness.expenseByGuid(guid))!;

    // Order 2 on a fresh device: the stale one first, then the newer one.
    final otherHarness = await SyncTestHarness.create();
    addTearDown(otherHarness.close);
    final otherEngine = engineOn(otherHarness);
    await otherEngine.applyIncoming(oldRecord);
    await otherEngine.applyIncoming(newRecord);
    final winnerReverse = (await otherHarness.expenseByGuid(guid))!;

    expect(winnerForward.title, 'New');
    expect(winnerReverse.title, 'New');
    expect(winnerForward.amount, winnerReverse.amount);
  });

  test('an equal-time change tie-breaks by deviceId, deterministically',
      () async {
    final guid = newSyncGuid();
    final recordA = await signedChange(
      keys: keys,
      deviceId: 'A',
      hlcMillis: 1000,
      payload: const ExpenseCodec().toPayload(
          _expense(id: 31, title: 'from A', amount: 100, syncGuid: guid)),
    );
    final recordB = await signedChange(
      keys: keys,
      deviceId: 'B',
      hlcMillis: 1000,
      payload: const ExpenseCodec().toPayload(
          _expense(id: 31, title: 'from B', amount: 100, syncGuid: guid)),
    );

    final engine = engineOn(harness);
    await engine.applyIncoming(recordA);
    await engine.applyIncoming(recordB);
    expect((await harness.expenseByGuid(guid))!.title, 'from B');

    final otherHarness = await SyncTestHarness.create();
    addTearDown(otherHarness.close);
    final otherEngine = engineOn(otherHarness);
    await otherEngine.applyIncoming(recordB);
    await otherEngine.applyIncoming(recordA);
    expect((await otherHarness.expenseByGuid(guid))!.title, 'from B');
  });

  test('a losing change is retained and counted, never silently dropped',
      () async {
    final guid = newSyncGuid();
    final oldRecord = await signedChange(
      keys: keys,
      deviceId: 'A',
      hlcMillis: 1000,
      payload: const ExpenseCodec().toPayload(
          _expense(id: 31, title: 'Old', amount: 100, syncGuid: guid)),
    );
    final newRecord = await signedChange(
      keys: keys,
      deviceId: 'A',
      hlcMillis: 2000,
      payload: const ExpenseCodec().toPayload(
          _expense(id: 31, title: 'New', amount: 200, syncGuid: guid)),
    );

    final engine = engineOn(harness);
    await engine.applyIncoming(newRecord, peerId: 1);
    final outcome = await engine.applyIncoming(oldRecord, peerId: 1);

    expect(outcome, ApplyOutcome.losing);
    expect((await harness.expenseByGuid(guid))!.title, 'New',
        reason: 'the loser must not overwrite the winning row');
    // Both records are retained in the log (nothing is thrown away).
    expect(await harness.isar.changeRecords.count(), 2);

    final cursor = await harness.isar.syncCursors
        .filter()
        .peerIdEqualTo(1)
        .contextLocalIdEqualTo(1)
        .findFirst();
    expect(cursor, isNotNull);
    expect(cursor!.conflictCount, 1,
        reason: 'the losing change is surfaced as a conflict');

    // Re-offering the very same loser on a later round must NOT double-count it:
    // a distinct kept-aside edit is counted exactly once, no matter how many
    // exchange rounds re-deliver it (the badge must not climb per round).
    expect(await engine.applyIncoming(oldRecord, peerId: 1),
        ApplyOutcome.duplicate);
    final afterReoffer = await harness.isar.syncCursors
        .filter()
        .peerIdEqualTo(1)
        .contextLocalIdEqualTo(1)
        .findFirst();
    expect(afterReoffer!.conflictCount, 1,
        reason: 'a kept-aside conflict is counted once, not once per round');
  });

  test('re-applying the same change is an idempotent no-op (sync-protocol §3)',
      () async {
    final record = await signedChange(
      keys: keys,
      deviceId: 'A',
      hlcMillis: 1000,
      payload: const ExpenseCodec()
          .toPayload(_expense(id: 31, title: 'Once', amount: 100)),
    );

    final engine = engineOn(harness);
    expect(await engine.applyIncoming(record), ApplyOutcome.applied);
    expect(await engine.applyIncoming(record), ApplyOutcome.duplicate);
    expect(await harness.isar.changeRecords.count(), 1);
  });

  test('identity is the syncGuid, not the local row id (T032)', () async {
    // Two versions of the *same* entity authored on two devices where each
    // stored it under a different local row id (31 vs 7). Identity must follow
    // the shared syncGuid, so they resolve to exactly one row — the case 012's
    // same-id tests never exercised (research R5).
    final guid = newSyncGuid();
    final versionA = await signedChange(
      keys: keys,
      deviceId: 'A',
      hlcMillis: 1000,
      entityLocalId: 31,
      payload: const ExpenseCodec().toPayload(_expense(
          id: 31, title: 'A local id 31', amount: 100, syncGuid: guid)),
    );
    final versionB = await signedChange(
      keys: keys,
      deviceId: 'B',
      hlcMillis: 2000,
      entityLocalId: 7,
      payload: const ExpenseCodec().toPayload(
          _expense(id: 7, title: 'B local id 7', amount: 200, syncGuid: guid)),
    );

    final engine = engineOn(harness);
    await engine.applyIncoming(versionA);
    await engine.applyIncoming(versionB);

    final rows =
        await harness.isar.expenses.filter().syncGuidEqualTo(guid).findAll();
    expect(rows, hasLength(1),
        reason: 'the same syncGuid is one entity regardless of local id');
    expect(rows.single.title, 'B local id 7', reason: 'the newer version wins');
  });

  test('a tampered payload fails verification and is dropped', () async {
    final record = await signedChange(
      keys: keys,
      deviceId: 'A',
      hlcMillis: 1000,
      payload: const ExpenseCodec()
          .toPayload(_expense(id: 31, title: 'Signed', amount: 100)),
    );
    record.payload = const ExpenseCodec()
        .toPayload(_expense(id: 31, title: 'Tampered', amount: 999999));

    final engine = engineOn(harness);
    expect(
        await engine.applyIncoming(record), ApplyOutcome.droppedBadSignature);
    expect(await harness.isar.expenses.count(), 0);
  });
}
