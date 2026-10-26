import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/expense_purchase.dart';
import 'package:budget_buddy/core/models/expense_evidence_chunk.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/services/purchase_draft.dart';
import 'package:budget_buddy/features/expenses/providers/purchase_provider.dart';
import 'package:budget_buddy/features/expenses/providers/expenses_provider.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_evidence_repository.dart';
import 'package:budget_buddy/core/services/expense_evidence.dart';
import 'package:budget_buddy/core/services/refund_service.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/settings/presentation/profile_switcher_section.dart';
import 'package:budget_buddy/features/spaces/repositories/month_move_operations.dart';
import '../../support/audit_test_support.dart';
import 'package:budget_buddy/features/expenses/presentation/purchase_screen.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import '../medical/repositories/medical_test_harness.dart';
import 'bulk_entry_service_test.dart' show readyBulkRow;

void main() {
  late MedicalTestHarness h;
  late ProviderContainer c;
  late ContextRef owner;
  setUp(() async {
    h = await MedicalTestHarness.create();
    IsarHelper.instance = h.isar;
    await h.seedBudget(yearMonth: '2026-10');
    late MonthlyBudget month;
    await h.isar.writeTxn(() async {
      month = (await h.isar.monthlyBudgets.get(h.budgetId))!
        ..profileId = h.profileId;
      await h.isar.monthlyBudgets.put(month);
      await h.isar.categorys.put(Category(
          categoryId: 'food', name: 'Food', emoji: 'F', colorValue: 0));
    });
    owner = ContextRef.personal(profileId: h.profileId, yearMonth: '2026-10');
    c = ProviderContainer(overrides: [
      budgetContextProvider.overrideWithValue(owner),
      actingProfileIdProvider.overrideWithValue(h.profileId),
      activeContextCanEditProvider.overrideWithValue(true),
      activeBudgetProvider.overrideWith((ref) => Stream.value(month)),
      expensesProvider.overrideWith((ref) => ExpensesNotifier(
          h.budgetId, (_) => 0,
          actingProfileId: h.profileId,
          initialState: const AsyncValue.data([]),
          rateRegistry: RateTableRegistry()))
    ]);
    await c.read(activeBudgetProvider.future);
  });
  tearDown(() async {
    c.dispose();
    await h.close();
  });
  PurchaseDraft purchase() {
    final p = PurchaseDraft();
    final ready = readyBulkRow();
    p.header
      ..merchant = ready.merchant
      ..currency = ready.currency
      ..date = ready.date
      ..payment = ready.payment
      ..status = ready.status;
    p.receiptTotal = '3,000';
    for (final amount in ['1,000', '2,000']) {
      p.addItem()
        ..title = 'Item $amount'
        ..amount = amount
        ..category = 'food'
        ..profileChosen = true;
    }
    p.evidence.documents.addAll(ready.evidence.documents);
    p.evidence.prepared.addAll(ready.evidence.prepared);
    return p;
  }

  test('one receipt is stored once; items and audit commit once across retry',
      () async {
    final p = purchase();
    await c.read(purchaseSubmitProvider)(p, owner, h.profileId);
    expect(await h.isar.expenses.count(), 2);
    expect(await h.isar.expensePurchases.count(), 1);
    final chunks = await h.isar.expenseEvidenceChunks.where().findAll();
    expect(chunks.length, p.evidence.documents.length);
    expect(chunks.map((e) => e.expenseSyncGuid).toSet(), {p.items.first.guid});
    final items = await h.isar.expenses.where().findAll();
    expect(items.fold<int>(0, (n, e) => n + e.amount), 300000);
    final doc =
        ExpenseEvidence.decode(items.last.paymentEvidenceJson)!.documents.first;
    expect(
        await ExpenseEvidenceRepository(h.isar).readDocument(items.last, doc),
        isNotNull);
    final audits = await h.isar.auditEvents.count();
    p.revision = 0;
    await c.read(purchaseSubmitProvider)(p, owner, h.profileId);
    expect(await h.isar.expenses.count(), 2);
    expect(await h.isar.auditEvents.count(), audits);
  });
  test('invalid item rolls back the purchase, files, audit and other items',
      () async {
    final p = purchase();
    p.items.last.category = 'missing';
    await expectLater(c.read(purchaseSubmitProvider)(p, owner, h.profileId),
        throwsStateError);
    expect(await h.isar.expensePurchases.count(), 0);
    expect(await h.isar.expenses.count(), 0);
    expect(await h.isar.expenseEvidenceChunks.count(), 0);
    expect(await h.isar.auditEvents.count(), 0);
  });
  test(
      'individual deletion is refused; whole deletion retains evidence history',
      () async {
    final p = purchase();
    await c.read(purchaseSubmitProvider)(p, owner, h.profileId);
    final row = (await h.isar.expenses.where().findFirst())!;
    await expectLater(c.read(expensesProvider.notifier).deleteExpense(row.id),
        throwsStateError);
    expect(await h.isar.expenses.count(), 2);
    await c
        .read(expensesProvider.notifier)
        .deletePurchase(p.guid, p.revision, p.expectedToken!);
    expect(await h.isar.expenses.count(), 0);
    expect(await h.isar.expensePurchases.count(), 0);
    expect(await h.isar.expenseEvidenceChunks.count(), greaterThan(0));
  });
  test(
      'balanced edits update all items and stale revisions cannot overwrite them',
      () async {
    final p = purchase();
    await c.read(purchaseSubmitProvider)(p, owner, h.profileId);
    final stored = (await h.isar.expensePurchases.where().findFirst())!;
    final rows = await h.isar.expenses.where().findAll();
    final edit = purchaseDraftFromSaved(stored, rows);
    final stale = purchaseDraftFromSaved(stored, rows);
    edit.items.first.amount = '1,500';
    edit.items.last.amount = '1,500';
    await c.read(purchaseSubmitProvider)(edit, owner, h.profileId);
    final updated = await h.isar.expenses.where().findAll();
    expect(updated.map((r) => r.amount).toList(), [150000, 150000]);
    stale.items.first.notes = 'Old editor';
    await expectLater(c.read(purchaseSubmitProvider)(stale, owner, h.profileId),
        throwsStateError);
    expect((await h.isar.expenses.where().findFirst())!.notes, isNull);
  });
  test(
      'an item refund preserves the original receipt total and protects removal',
      () async {
    final p = purchase();
    await c.read(purchaseSubmitProvider)(p, owner, h.profileId);
    final row = (await h.isar.expenses.where().findFirst())!;
    final refunds = RefundService(h.isar,
        context: owner,
        actingProfileId: h.profileId,
        rates: RateTableRegistry());
    await refunds.record(
        expenseId: row.id, amount: 50000, operationId: 'purchase-refund-once');
    final stored = (await h.isar.expensePurchases.where().findFirst())!;
    expect(stored.receiptTotalMinor, 300000);
    expect((await h.isar.expenses.get(row.id))!.amount, 100000);
    expect((await h.isar.expenses.get(row.id))!.status,
        ExpenseStatus.partiallyReimbursed);
    await expectLater(
        c
            .read(expensesProvider.notifier)
            .deletePurchase(p.guid, stored.revision, stored.versionToken),
        throwsStateError);
    expect(await h.isar.expenses.count(), 2);
  });
  test(
      'corrected cash amounts require fresh confirmation for the whole purchase',
      () async {
    final p = purchase();
    p.header.payment = 'cash';
    p.evidence.cashConfirmed = true;
    await c.read(purchaseSubmitProvider)(p, owner, h.profileId);
    final saved = (await h.isar.expensePurchases.where().findFirst())!;
    final edit =
        purchaseDraftFromSaved(saved, await h.isar.expenses.where().findAll());
    edit.items.first.amount = '1,500';
    edit.items.last.amount = '1,500';
    await expectLater(c.read(purchaseSubmitProvider)(edit, owner, h.profileId),
        throwsStateError);
    expect((await h.isar.expenses.where().findFirst())!.amount, 100000);
    edit.evidence.cashConfirmed = true;
    await c.read(purchaseSubmitProvider)(edit, owner, h.profileId);
    expect((await h.isar.expenses.where().findFirst())!.amount, 150000);
  });
  test(
      'Planned month moves preserve group membership and copy only one document set',
      () async {
    final p = purchase();
    p.header.status = ExpenseStatus.planned;
    await c.read(purchaseSubmitProvider)(p, owner, h.profileId);
    final before = await h.isar.expenseEvidenceChunks.count();
    final space = SharedSpace()
      ..name = 'Home'
      ..currency = PrimaryCurrency.usd
      ..defaultIncome = 0
      ..createdByProfileId = h.profileId
      ..createdAt = DateTime(2026);
    await h.isar.writeTxn(() async {
      space.id = await h.isar.sharedSpaces.put(space);
      await h.isar.sharedMembers.put(SharedMember()
        ..sharedSpaceId = space.id
        ..profileId = h.profileId
        ..role = SharedMemberRole.owner
        ..joinedAt = DateTime(2026));
    });
    final ops = MonthMoveOperations(h.isar,
        recorder: await auditTestRecorder(h.isar),
        rateRegistry: RateTableRegistry());
    await ops.moveMonth(owner,
        ContextRef.shared(spaceId: space.id, yearMonth: '2026-10'), '2026-10',
        actingProfileId: h.profileId);
    final moved = (await h.isar.expensePurchases.where().findFirst())!;
    expect(moved.sharedSpaceId, space.id);
    expect(moved.itemGuids, p.items.map((e) => e.guid).toList());
    expect(await h.isar.expenseEvidenceChunks.count(), before * 2);
    final rows = await h.isar.expenses.where().findAll();
    final document =
        ExpenseEvidence.decode(rows.last.paymentEvidenceJson)!.documents.first;
    expect(
        await ExpenseEvidenceRepository(h.isar)
            .readDocument(rows.last, document),
        isNotNull);
  });
  test(
      'existing merchant spelling is normalized before header and cash evidence',
      () async {
    final first = purchase();
    await c.read(purchaseSubmitProvider)(first, owner, h.profileId);
    final next = purchase();
    next.header
      ..merchant = first.header.merchant.toUpperCase()
      ..payment = 'cash';
    next.evidence.cashConfirmed = true;
    await c.read(purchaseSubmitProvider)(next, owner, h.profileId);
    final stored = (await h.isar.expensePurchases
        .filter()
        .syncGuidEqualTo(next.guid)
        .findFirst())!;
    expect(stored.merchantName, first.header.merchant.trim());
    final rows = await h.isar.expenses
        .filter()
        .purchaseSyncGuidEqualTo(next.guid)
        .findAll();
    expect(rows.every((r) => expenseEvidenceProblems(r).isEmpty), isTrue);
    expect(rows.every((r) => r.merchantName == stored.merchantName), isTrue);
  });
  test('explicit profile deletion removes purchase headers and shared content',
      () async {
    final p = purchase();
    await c.read(purchaseSubmitProvider)(p, owner, h.profileId);
    await h.isar.writeTxn(() async {
      await h.isar.userProfiles.put(UserProfile()
        ..name = 'Kept'
        ..primaryCurrency = PrimaryCurrency.usd
        ..monthlyAvailableAmount = 0
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
    });
    await ProfileSwitcherController(h.isar)
        .deleteProfile(h.profileId, activeProfileId: null);
    expect(await h.isar.expensePurchases.count(), 0);
    expect(await h.isar.expenseEvidenceChunks.count(), 0);
    expect(await h.isar.userProfiles.count(), 1);
  });
}
