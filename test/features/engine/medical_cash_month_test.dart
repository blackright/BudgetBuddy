import 'package:flutter_test/flutter_test.dart';

import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/expenses/repositories/expense_repository.dart';
import 'package:budget_buddy/features/expenses/repositories/reimbursement_repository.dart';
import '../medical/repositories/medical_test_harness.dart';

void main() {
  test('cash merge keeps each medical expense in exactly one month', () {
    final serviceMedical = Expense(
      id: 1,
      profileId: 1,
      yearMonth: '2026-03',
      title: 'medical',
      amount: 1000,
      currency: 'usd',
      categoryId: 'health',
      date: DateTime.utc(2026, 3, 1),
      budgetId: 1,
      type: ExpenseType.medical,
    );
    final movedMedical = Expense(
      id: 2,
      profileId: 1,
      yearMonth: '2026-03',
      cashYearMonth: '2026-04',
      title: 'medical moved',
      amount: 2000,
      currency: 'usd',
      categoryId: 'health',
      date: DateTime.utc(2026, 3, 1),
      budgetId: 1,
      type: ExpenseType.medical,
    );
    final standard = Expense(
      id: 3,
      profileId: 1,
      yearMonth: '2026-03',
      title: 'food',
      amount: 500,
      currency: 'usd',
      categoryId: 'food',
      date: DateTime.utc(2026, 3, 1),
      budgetId: 1,
    );

    final merged = mergeCashExpenses(
      [serviceMedical, movedMedical, standard],
      [movedMedical],
    );

    expect(merged.map((e) => e.id), [1, 3, 2]);
  });

  test('credit merge keeps each reimbursement in exactly one month', () {
    final origin = Reimbursement(
      id: 1,
      profileId: 1,
      originYearMonth: '2026-03',
      amount: 100,
      currency: 'usd',
      date: DateTime.utc(2026, 3, 2),
    );
    final moved = Reimbursement(
      id: 2,
      profileId: 1,
      originYearMonth: '2026-03',
      creditYearMonth: '2026-05',
      amount: 200,
      currency: 'usd',
      date: DateTime.utc(2026, 5, 2),
    );

    final merged = mergeCreditedReimbursements([origin, moved], [moved]);

    expect(merged.map((e) => e.id), [1, 2]);
  });

  test('repositories separate service/origin month from cash/credit month',
      () async {
    final harness = await MedicalTestHarness.create();
    addTearDown(harness.close);
    final context = await harness.seedBudget(yearMonth: '2026-04');
    final demo = ContextRef.personal(profileId: 1, yearMonth: '2026-04');

    await harness.isar.writeTxn(() async {
      await harness.isar.expenses.put(Expense(
        profileId: context.profileId,
        yearMonth: '2026-03',
        cashYearMonth: '2026-04',
        title: 'moved medical',
        amount: 1000,
        currency: 'usd',
        categoryId: 'health',
        date: DateTime.utc(2026, 3, 1),
        budgetId: context.budgetId,
        type: ExpenseType.medical,
      ));
      await harness.isar.expenses.put(Expense(
        profileId: context.profileId,
        yearMonth: '2026-04',
        title: 'service medical',
        amount: 2000,
        currency: 'usd',
        categoryId: 'health',
        date: DateTime.utc(2026, 4, 1),
        budgetId: context.budgetId,
        type: ExpenseType.medical,
      ));
      await harness.isar.reimbursements.put(Reimbursement(
        profileId: context.profileId,
        originYearMonth: '2026-03',
        creditYearMonth: '2026-04',
        amount: 500,
        currency: 'usd',
        date: DateTime.utc(2026, 4, 2),
      ));
    });

    final expenses = ExpenseRepository(harness.isar);
    final reimbursements = ReimbursementRepository(harness.isar);

    expect(
        (await expenses.watchExpensesForContext(demo).first)
            .map((e) => e.title),
        ['service medical']);
    expect(
        (await expenses.watchExpensesByCashMonth(demo).first)
            .map((e) => e.title),
        ['moved medical']);
    expect(await reimbursements.watchReimbursementsForContext(demo).first,
        isEmpty);
    expect(
        (await reimbursements.watchReimbursementsByCreditMonth(demo).first)
            .single
            .amount,
        500);
  });

  test('month summary keeps reporting while money-in-bank uses cash months',
      () {
    final serviceExpense = Expense(
      profileId: 1,
      yearMonth: '2026-03',
      cashYearMonth: '2026-04',
      title: 'medical',
      amount: 1000,
      currency: 'usd',
      categoryId: 'health',
      date: DateTime.utc(2026, 3, 1),
      budgetId: 1,
      type: ExpenseType.medical,
      status: ExpenseStatus.paid,
    );

    final summary = MonthSummary.from(
      yearMonth: '2026-04',
      income: 1000,
      usesOverriddenIncome: false,
      expenses: [serviceExpense],
      reimbursements: const [],
      convertExpense: (e) =>
          Money(e.amount, CurrencyCode.tryParse(e.currency)!),
      convertReimbursement: (r) => Money(r.amount, CurrencyCode.usd),
      cashPaymentsMade: 500,
      cashMoneyReturned: 100,
    );

    expect(summary.paymentsMade, 10);
    expect(summary.kept, 600);
    expect(summary.keptBeforeAllocations, 600);
  });
}
