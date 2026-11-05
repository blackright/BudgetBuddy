import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/services/expense_evidence.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/providers/expenses_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../medical/repositories/medical_test_harness.dart';

void main() {
  test('a past expense is filed into its own month, not the selected one',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    IsarHelper.instance = h.isar;
    await h.seedBudget(yearMonth: '2026-10');
    late MonthlyBudget past;
    await h.isar.writeTxn(() async {
      await h.isar.categorys.put(Category(
          categoryId: 'food', name: 'Food', emoji: 'F', colorValue: 0));
      past = MonthlyBudget()
        ..profileId = h.profileId
        ..yearMonth = '2026-06'
        ..baseAvailableAmount = 0
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);
      past.id = await h.isar.monthlyBudgets.put(past);
    });

    final notifier = ExpensesNotifier(h.budgetId, (_) => 0,
        actingProfileId: h.profileId,
        initialState: const AsyncValue.data([]),
        rateRegistry: RateTableRegistry());
    addTearDown(notifier.dispose);

    final date = DateTime(2026, 6, 12);
    await notifier.addExpense(
        Expense(
          profileId: h.profileId,
          yearMonth: '2026-06',
          title: 'Past lunch',
          amount: 1500,
          currency: 'HUF',
          categoryId: 'food',
          status: ExpenseStatus.planned,
          merchantName: 'Cafe',
          paymentMethod: 'cash',
          paymentEvidenceJson:
              const ExpenseEvidence(profileChosen: true).encode(),
          date: date,
          budgetId: past.id,
        ),
        targetBudgetId: past.id);

    final saved = (await h.isar.expenses.where().findAll()).single;
    expect(saved.yearMonth, '2026-06');
    expect(saved.budgetId, past.id);
    expect(saved.date, date);
    final selectedMonth = (await h.isar.monthlyBudgets.get(h.budgetId))!;
    expect(selectedMonth.yearMonth, '2026-10');
    expect(
        await h.isar.expenses
            .filter()
            .budgetIdEqualTo(selectedMonth.id)
            .count(),
        0);
  });
}
