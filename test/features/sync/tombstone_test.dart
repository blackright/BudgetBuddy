import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/context_kind.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/change_factory.dart';
import 'support/sync_harness.dart';

Expense _expense({required String title}) => Expense(
      id: 31,
      profileId: 1,
      sharedSpaceId: 1,
      yearMonth: '2026-03',
      title: title,
      amount: 100,
      currency: 'usd',
      categoryId: 'general',
      date: DateTime.utc(2026, 3, 5),
      budgetId: 1,
    );

void main() {
  late SyncTestHarness harness;
  late DeviceKeys keys;
  late SyncEngine engine;

  setUp(() async {
    harness = await SyncTestHarness.create();
    keys = await DeviceKeys.generate('idA');
    engine = SyncEngine(
      harness.isar,
      trustedKeys: {keys.identityId: keys.publicKey},
    );
  });

  tearDown(() async => harness.close());

  Future<dynamic> upsert({required int millis, String deviceId = 'A'}) =>
      signedChange(
        keys: keys,
        deviceId: deviceId,
        hlcMillis: millis,
        op: 'upsert',
        entityLocalId: 31,
        payload: const ExpenseCodec().toPayload(_expense(title: 'Expense')),
      );

  Future<dynamic> tombstone({required int millis, String deviceId = 'B'}) =>
      signedChange(
        keys: keys,
        deviceId: deviceId,
        hlcMillis: millis,
        op: 'delete',
        entityLocalId: 31,
        payload: '',
      );

  test('delete beats a concurrent upsert (FR-006/007)', () async {
    final created = await upsert(millis: 1000);
    await engine.applyIncoming(created);
    expect(await harness.isar.expenses.get(31), isNotNull);

    // Same HLC time, a tombstone wins the tie.
    final deleted = await tombstone(millis: 1000);
    expect(await engine.applyIncoming(deleted), ApplyOutcome.applied);
    expect(await harness.isar.expenses.get(31), isNull);
  });

  test('a strictly later upsert recreates the entity', () async {
    await engine.applyIncoming(await tombstone(millis: 1000));
    expect(await harness.isar.expenses.get(31), isNull);

    final recreated = await upsert(millis: 2000);
    expect(await engine.applyIncoming(recreated), ApplyOutcome.applied);
    expect(await harness.isar.expenses.get(31), isNotNull);
  });

  test('the tombstone is retained as the head — nothing resurrects the row',
      () async {
    await engine.applyIncoming(await tombstone(millis: 3000));
    // An older upsert arrives late (e.g. a peer replaying its log).
    final staleUpsert = await upsert(millis: 2000);
    expect(await engine.applyIncoming(staleUpsert), ApplyOutcome.losing);
    expect(await harness.isar.expenses.get(31), isNull,
        reason: 'a deleted row must not be resurrected by a stale change');

    final head = await engine.headFor(
      contextKind: ContextKind.shared,
      contextLocalId: 1,
      entityType: 'Expense',
      entityLocalId: 31,
    );
    expect(head, isNotNull);
    expect(head!.op, 'delete', reason: 'the tombstone stays the winning head');
  });

  test('a re-delivered tombstone is an idempotent no-op', () async {
    final deleted = await tombstone(millis: 1000);
    expect(await engine.applyIncoming(deleted), ApplyOutcome.applied);
    expect(await engine.applyIncoming(deleted), ApplyOutcome.duplicate);
    expect(await harness.isar.changeRecords.count(), 1);
  });
}
