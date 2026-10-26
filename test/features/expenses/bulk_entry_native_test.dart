import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/expense_evidence_chunk.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/merchant.dart';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/direct_expense_profile.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/month_end_run.dart';
import 'package:budget_buddy/features/sync/repositories/sync_recorder.dart';
import 'package:budget_buddy/features/sync/repositories/change_signer.dart';
import 'package:cryptography/cryptography.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/services/bulk_entry_service.dart';
import 'package:budget_buddy/features/expenses/providers/expenses_provider.dart';
import 'package:budget_buddy/features/expenses/providers/bulk_entry_providers.dart';
import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_search_repository.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import '../medical/repositories/medical_test_harness.dart';
import 'bulk_entry_service_test.dart' show readyBulkRow;

class FailingBulkRecorder extends SyncRecorder {
  FailingBulkRecorder(super.isar);
  @override
  Future<ChangeRecord?> recordExpense(Expense expense, {DateTime? now}) async =>
      throw StateError('Injected sync-journal failure');
}

/// Models a screen whose subscription has not delivered the post-save event.
/// Re-subscribing still reads the actual database, never a fabricated result.
class OneShotExpenseSearchRepository extends ExpenseSearchRepository {
  OneShotExpenseSearchRepository(super.db);
  @override
  Stream<List<Expense>> watch(ContextRef scope, int? actor) async* {
    yield await super.watch(scope, actor).first;
  }
}

void main() {
  late MedicalTestHarness h;
  late ExpensesNotifier writer;
  late ContextRef owner;
  setUp(() async {
    h = await MedicalTestHarness.create();
    IsarHelper.instance = h.isar;
    await h.seedBudget(yearMonth: '2026-10');
    await h.isar.writeTxn(() async {
      final month = (await h.isar.monthlyBudgets.get(h.budgetId))!
        ..profileId = h.profileId;
      await h.isar.monthlyBudgets.put(month);
      await h.isar.categorys.put(Category(
          categoryId: 'food', name: 'Food', emoji: 'F', colorValue: 0));
    });
    owner = ContextRef.personal(profileId: h.profileId, yearMonth: '2026-10');
    writer = ExpensesNotifier(h.budgetId, (_) => 0,
        actingProfileId: h.profileId,
        initialState: const AsyncValue.data([]),
        rateRegistry: RateTableRegistry());
  });
  tearDown(() async {
    writer.dispose();
    await h.close();
  });
  Expense expense(BulkExpenseDraft row) => const BulkEntryService().expense(row,
      owner: h.profileId,
      space: null,
      month: owner.yearMonth,
      budget: h.budgetId);
  for (final missedEvent in [false, true]) {
    test(
        missedEvent
            ? 'bulk submission refreshes Expenses when its watcher has not delivered'
            : 'bulk submission reaches the subscribed real Expenses search list',
        () async {
      final month = (await h.isar.monthlyBudgets.get(h.budgetId))!;
      final container = ProviderContainer(overrides: [
        budgetContextProvider.overrideWithValue(owner),
        actingProfileIdProvider.overrideWithValue(h.profileId),
        activeContextCanEditProvider.overrideWithValue(true),
        activeBudgetProvider.overrideWith((ref) => Stream.value(month)),
        if (missedEvent)
          expenseSearchRepositoryProvider
              .overrideWithValue(OneShotExpenseSearchRepository(h.isar)),
        expensesProvider.overrideWith((ref) => ExpensesNotifier(
            h.budgetId, (_) => 0,
            actingProfileId: h.profileId,
            initialState: const AsyncValue.data([]),
            rateRegistry: RateTableRegistry())),
      ]);
      addTearDown(container.dispose);
      final changes = <List<int>>[];
      container.listen(expenseSearchResultsProvider, (_, next) {
        if (next.asData != null) {
          changes.add(next.requireValue.map((e) => e.id).toList());
        }
      }, fireImmediately: true);
      Future<void> until(bool Function() predicate) async {
        for (var i = 0; i < 100; i++) {
          if (predicate()) {
            return;
          }
          await Future<void>.delayed(const Duration(milliseconds: 15));
        }
        fail('The real Expenses list did not receive the bulk save.');
      }

      await container.read(activeBudgetProvider.future);
      await until(() =>
          container.read(expenseSearchResultsProvider).asData?.value.isEmpty ==
          true);
      final rice = readyBulkRow()..title = 'Rice';
      final flour = readyBulkRow()..title = 'Farine';
      expect(
          await container.read(bulkSubmitProvider)(
              [rice, flour], owner, h.profileId),
          isEmpty);
      await until(() =>
          container.read(expenseSearchResultsProvider).asData?.value.length ==
          2);
      expect(
          container
              .read(expenseSearchResultsProvider)
              .requireValue
              .map((e) => e.syncGuid)
              .toSet(),
          {rice.guid, flour.guid});
      expect(changes.last.length, 2);
      expect(await h.isar.expenses.count(), 2);
    });
  }
  test(
      'mixed validation saves only ready rows and retry never duplicates audit or money',
      () async {
    final good = readyBulkRow();
    final bad = readyBulkRow()..amount = '';
    final valid = [good, bad]
        .where((r) =>
            const BulkEntryService().validate(r, owner.yearMonth).isEmpty)
        .toList();
    await writer.addBulkExpenses(valid.map(expense).toList(), owner,
        assertContext: () {});
    expect(await h.isar.expenses.count(), 1);
    final auditCount = await h.isar.auditEvents.count();
    expect(auditCount, greaterThan(0));
    await writer.addBulkExpenses(valid.map(expense).toList(), owner,
        assertContext: () {});
    expect(await h.isar.expenses.count(), 1);
    expect(await h.isar.auditEvents.count(), auditCount);
    good.amount = '2';
    await expectLater(
        writer.addBulkExpenses([expense(good)], owner, assertContext: () {}),
        throwsStateError);
    expect((await h.isar.expenses.where().findFirst())!.amount, 123456);
  });
  test('late failure rolls back every expense, merchant, audit and spent cache',
      () async {
    final profile = BudgetProfile()
      ..profileId = h.profileId
      ..yearMonth = '2026-10'
      ..name = 'Food'
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    await h.isar.writeTxn(() => h.isar.budgetProfiles.put(profile));
    final row = readyBulkRow()
      ..profileId = profile.id
      ..profileType = FinancialProfileType.budget
      ..profileGuid = profile.syncGuid;
    var checks = 0;
    await expectLater(
        writer.addBulkExpenses([expense(row), expense(readyBulkRow())], owner,
            assertContext: () {
          if (++checks == 2) throw StateError('Context changed');
        }),
        throwsStateError);
    expect(await h.isar.expenses.count(), 0);
    expect(await h.isar.merchants.count(), 0);
    expect(await h.isar.auditEvents.count(), 0);
    expect((await h.isar.budgetProfiles.get(profile.id))!.spent, 0);
    await writer.addBulkExpenses([expense(row)], owner, assertContext: () {});
    expect((await h.isar.budgetProfiles.get(profile.id))!.spent, 123456);
  });
  test(
      'Main Budget and Direct identities are distinct; invalid profile retains per-row error',
      () async {
    final profile = BudgetProfile()
      ..profileId = h.profileId
      ..yearMonth = '2026-10'
      ..name = 'Budget'
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    final direct = DirectExpenseProfile()
      ..profileId = h.profileId
      ..yearMonth = '2026-10'
      ..name = 'Direct'
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    await h.isar.writeTxn(() async {
      await h.isar.budgetProfiles.put(profile);
      await h.isar.directExpenseProfiles.put(direct);
    });
    final row = readyBulkRow()
      ..profileId = direct.id
      ..profileType = FinancialProfileType.direct
      ..profileGuid = direct.syncGuid;
    await writer.addBulkExpenses([expense(row)], owner, assertContext: () {});
    expect((await h.isar.directExpenseProfiles.get(direct.id))!.spent, 123456);
    expect((await h.isar.budgetProfiles.get(profile.id))!.spent, 0);
    row
      ..profileGuid = 'foreign'
      ..saved = false;
    final errors = await writer.addBulkExpenses(
        [expense(readyBulkRow()), expense(row)], owner,
        assertContext: () {});
    expect(errors.keys, [row.guid]);
    expect(await h.isar.expenses.count(), 2);
  });
  test('sync-journal failure rolls back expense and required audit together',
      () async {
    final failing = ExpensesNotifier(h.budgetId, (_) => 0,
        actingProfileId: h.profileId,
        initialState: const AsyncValue.data([]),
        rateRegistry: RateTableRegistry(),
        recorder: FailingBulkRecorder(h.isar));
    addTearDown(failing.dispose);
    await expectLater(
        failing.addBulkExpenses([expense(readyBulkRow())], owner,
            assertContext: () {}),
        throwsStateError);
    expect(await h.isar.expenses.count(), 0);
    expect(await h.isar.expenseEvidenceChunks.count(), 0);
    expect(await h.isar.auditEvents.count(), 0);
    expect(await h.isar.merchants.count(), 0);
  });
  test(
      'batch limit, duplicate row identity and converted overflow are rejected without writes',
      () async {
    await expectLater(
        writer.addBulkExpenses(
            List.generate(51, (_) => expense(readyBulkRow())), owner,
            assertContext: () {}),
        throwsStateError);
    final repeated = expense(readyBulkRow());
    await expectLater(
        writer
            .addBulkExpenses([repeated, repeated], owner, assertContext: () {}),
        throwsStateError);
    final huge = expense(readyBulkRow()..amount = '90,071,992,547,409.91');
    await h.isar.writeTxn(() async {
      final month = (await h.isar.monthlyBudgets.get(h.budgetId))!
        ..currency = 'HUF';
      await h.isar.monthlyBudgets.put(month);
    });
    expect(await writer.addBulkExpenses([huge], owner, assertContext: () {}),
        contains(huge.syncGuid));
    expect(await h.isar.expenses.count(), 0);
    expect(await h.isar.auditEvents.count(), 0);
  });
  test(
      'fifty rows save together and Planned rows do not increase paid spending',
      () async {
    final profile = BudgetProfile()
      ..profileId = h.profileId
      ..yearMonth = '2026-10'
      ..name = 'Food'
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    await h.isar.writeTxn(() => h.isar.budgetProfiles.put(profile));
    final rows = List.generate(
        50,
        (i) => expense(readyBulkRow()
          ..amount = '1.00'
          ..profileId = profile.id
          ..profileType = FinancialProfileType.budget
          ..profileGuid = profile.syncGuid
          ..status = i.isEven ? ExpenseStatus.paid : ExpenseStatus.planned));
    await writer.addBulkExpenses(rows, owner, assertContext: () {});
    expect(await h.isar.expenses.count(), 50);
    expect((await h.isar.budgetProfiles.get(profile.id))!.spent, 2500);
  });
  test('completed Month-End blocks new rows in the settled month', () async {
    await h.isar.writeTxn(() => h.isar.monthEndRuns.put(MonthEndRun()
      ..syncGuid = 'closed'
      ..profileId = h.profileId
      ..yearMonth = '2026-10'
      ..destinationMonth = '2026-11'
      ..contextGuid = 'personal'
      ..currency = 'USD'
      ..reportJson = '{}'
      ..fingerprint = 'f'
      ..actor = 'a'
      ..createdAt = DateTime(2026, 11)));
    await expectLater(
        writer.addBulkExpenses([expense(readyBulkRow())], owner,
            assertContext: () {}),
        throwsStateError);
    expect(await h.isar.expenses.count(), 0);
  });
  test(
      'shared viewer cannot write; owner needs audit signing and signed rows preserve retries',
      () async {
    await h.isar.writeTxn(() async {
      await h.isar.sharedSpaces.put(SharedSpace()
        ..id = 1
        ..name = 'Shared'
        ..currency = PrimaryCurrency.usd
        ..createdByProfileId = h.profileId
        ..createdAt = DateTime(2026));
      await h.isar.sharedMembers.put(SharedMember()
        ..sharedSpaceId = 1
        ..profileId = h.profileId
        ..role = SharedMemberRole.viewer
        ..joinedAt = DateTime(2026));
      final month = (await h.isar.monthlyBudgets.get(h.budgetId))!
        ..profileId = null
        ..sharedSpaceId = 1;
      await h.isar.monthlyBudgets.put(month);
    });
    final shared = ContextRef.shared(spaceId: 1, yearMonth: '2026-10');
    Expense request() => const BulkEntryService().expense(readyBulkRow(),
        owner: 0,
        space: 1,
        month: shared.yearMonth,
        budget: h.budgetId,
        actor: h.profileId);
    await expectLater(
        writer.addBulkExpenses([request()], shared, assertContext: () {}),
        throwsA(anything));
    expect(await h.isar.expenses.count(), 0);
    await h.isar.writeTxn(() async {
      final member = (await h.isar.sharedMembers.where().findFirst())!
        ..role = SharedMemberRole.owner;
      await h.isar.sharedMembers.put(member);
    });
    await expectLater(
        writer.addBulkExpenses([request()], shared, assertContext: () {}),
        throwsStateError);
    expect(await h.isar.merchants.count(), 0);
    expect(await h.isar.auditEvents.count(), 0);
    final key = await Ed25519().newKeyPair();
    final signed = ExpensesNotifier(h.budgetId, (_) => 0,
        actingProfileId: h.profileId,
        initialState: const AsyncValue.data([]),
        rateRegistry: RateTableRegistry(),
        recorder: SyncRecorder(h.isar,
            signer:
                Ed25519ChangeSigner(authorIdentityId: 'owner', keyPair: key)));
    addTearDown(signed.dispose);
    final row = request();
    await signed.addBulkExpenses([row], shared, assertContext: () {});
    expect(await h.isar.expenses.count(), 1);
    expect(
        (await h.isar.changeRecords.where().findAll())
            .any((r) => r.entityType == 'Expense'),
        isTrue);
    expect(
        (await h.isar.auditEvents.where().findAll())
            .every((e) => e.signature != null),
        isTrue);
    final count = await h.isar.auditEvents.count();
    await signed.addBulkExpenses([row], shared, assertContext: () {});
    expect(await h.isar.expenses.count(), 1);
    expect(await h.isar.auditEvents.count(), count);
  });
}
