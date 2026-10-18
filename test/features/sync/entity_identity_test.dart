import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:budget_buddy/features/sync/domain/entity_applier.dart';
import 'package:budget_buddy/features/sync/domain/sync_codec.dart';
import 'package:budget_buddy/features/sync/domain/sync_guid.dart';
import 'package:budget_buddy/features/sync/domain/sync_id_translator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'support/sync_harness.dart';

/// T029: device-independent identity (`contracts/entity-identity.md`).
///
/// The wire never carries a local integer id; identity is the row's `syncGuid`
/// and references are GUID references the applier resolves to this device's local
/// rows. These tests pin the two behaviours the engine depends on: a reference
/// resolves to `null` (never an invented row) when the target is unknown, and a
/// context GUID bootstraps exactly one local space.
Expense _expense({
  required int id,
  required String title,
  required int amount,
  required String syncGuid,
  int budgetId = 0,
}) =>
    Expense(
      id: id,
      profileId: 3,
      sharedSpaceId: 1,
      yearMonth: '2026-03',
      title: title,
      amount: amount,
      currency: 'usd',
      categoryId: 'general',
      date: DateTime.utc(2026, 3, 5),
      budgetId: budgetId,
    )..syncGuid = syncGuid;

Future<MonthlyBudget> _putBudget(SyncTestHarness h, String syncGuid) async {
  final budget = MonthlyBudget()
    ..syncGuid = syncGuid
    ..yearMonth = '2026-03'
    ..baseAvailableAmount = 0
    ..currency = 'usd'
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);
  final id = await h.isar.writeTxn(() => h.isar.monthlyBudgets.put(budget));
  return (await h.isar.monthlyBudgets.get(id))!;
}

void main() {
  late SyncTestHarness harness;

  setUp(() async {
    harness = await SyncTestHarness.create();
  });

  tearDown(() async => harness.close());

  test('resolveLocalEntity finds a row by GUID, never invents one (R2)',
      () async {
    final guid = newSyncGuid();
    final budget = await _putBudget(harness, guid);
    final translator = SyncIdTranslator(harness.isar);

    expect(
        await translator.resolveLocalEntity('MonthlyBudget', guid), budget.id);
    expect(await translator.resolveLocalEntity('MonthlyBudget', newSyncGuid()),
        isNull);
    expect(await translator.resolveLocalEntity('MonthlyBudget', null), isNull);
    expect(await translator.resolveLocalEntity('MonthlyBudget', ''), isNull);
    expect(await translator.resolveLocalEntity('NotAThing', guid), isNull);
  });

  test(
      'resolveLocalContext finds the existing space, creating only when unseen',
      () async {
    final guid = newSyncGuid();
    await harness.createSpaceAt(localId: 1, syncGuid: guid);
    final translator = SyncIdTranslator(harness.isar);

    expect(await translator.resolveLocalContext(guid), 1);
    expect(await harness.isar.sharedSpaces.count(), 1,
        reason: 'a known context GUID must not bootstrap a second space');

    final created = await harness.isar
        .writeTxn(() => translator.resolveLocalContext(newSyncGuid()));
    expect(await harness.isar.sharedSpaces.count(), 2);
    expect(created, isNot(1));
  });

  test('the Expense applier resolves GUID references to local rows', () async {
    final spaceGuid = newSyncGuid();
    final budgetGuid = newSyncGuid();
    await harness.createSpaceAt(localId: 1, syncGuid: spaceGuid);
    final budget = await _putBudget(harness, budgetGuid);

    final expense = _expense(
      id: 99,
      title: 'Coffee',
      amount: 100,
      syncGuid: newSyncGuid(),
    );
    final json = const ExpenseCodec().toJson(expense)
      ..['sharedSpaceSyncGuid'] = spaceGuid
      ..['budgetSyncGuid'] = budgetGuid;

    await harness.isar.writeTxn(() => applierForEntityType('Expense')!
        .upsert(harness.isar, canonicalJsonEncode(json)));

    final applied = await harness.expenseByGuid(expense.syncGuid);
    expect(applied, isNotNull);
    expect(applied!.sharedSpaceId, 1,
        reason: 'the space reference resolves to the local space id');
    expect(applied.budgetId, budget.id,
        reason: 'the budget reference resolves to the local budget id');
  });

  test('an unresolvable reference is left unset, not invented (R2)', () async {
    final expense = _expense(
      id: 99,
      title: 'Orphan',
      amount: 100,
      syncGuid: newSyncGuid(),
    );
    // No sharedSpaceSyncGuid / budgetSyncGuid on the wire: the targets have not
    // arrived yet, so the applier must not fabricate local rows.
    final payload = const ExpenseCodec().toPayload(expense);
    await harness.isar.writeTxn(
        () => applierForEntityType('Expense')!.upsert(harness.isar, payload));

    final applied = await harness.expenseByGuid(expense.syncGuid);
    expect(applied, isNotNull);
    expect(applied!.sharedSpaceId, isNull);
    expect(applied.budgetId, 0, reason: 'budgetId is non-null; 0 is unknown');
    expect(await harness.isar.sharedSpaces.count(), 0);
  });

  test('the same syncGuid under two local ids is one row', () async {
    final guid = newSyncGuid();
    final applier = applierForEntityType('Expense')!;
    await harness.isar.writeTxn(() async {
      await applier.upsert(
          harness.isar,
          const ExpenseCodec().toPayload(
              _expense(id: 10, title: 'local A', amount: 100, syncGuid: guid)));
      await applier.upsert(
          harness.isar,
          const ExpenseCodec().toPayload(
              _expense(id: 20, title: 'local B', amount: 200, syncGuid: guid)));
    });

    final rows =
        await harness.isar.expenses.filter().syncGuidEqualTo(guid).findAll();
    expect(rows, hasLength(1),
        reason: 'identity is the syncGuid, not the local row id');
    expect(rows.single.title, 'local B');
  });
}
