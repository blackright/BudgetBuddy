import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/expenses/providers/expense_filter_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Expense expense(int id, int day, String title,
        {ExpenseStatus status = ExpenseStatus.paid}) =>
    Expense(
        id: id,
        profileId: 1,
        yearMonth: '2026-10',
        title: title,
        amount: 100,
        currency: 'huf',
        categoryId: 'general',
        date: DateTime(2026, 10, day),
        budgetId: 1,
        status: status);

void main() {
  test(
      'Expenses uses newest dates then newest local additions without mutating source',
      () async {
    final rows = [
      expense(9, 1, 'Old'),
      expense(2, 20, 'Same date first'),
      expense(3, 20, 'Same date latest'),
      expense(1, 24, 'Newest date')
    ];
    final container = ProviderContainer(overrides: [
      monthlyExpensesProvider.overrideWith((ref) => Stream.value(rows)),
    ]);
    addTearDown(container.dispose);
    await container.read(monthlyExpensesProvider.future);
    expect(
        container.read(filteredExpensesProvider).requireValue.map((e) => e.id),
        [1, 3, 2, 9]);
    expect(rows.map((e) => e.id), [9, 2, 3, 1]);
    container.read(searchQueryProvider.notifier).state = 'same date';
    expect(
        container.read(filteredExpensesProvider).requireValue.map((e) => e.id),
        [3, 2]);
  });

  test('status filtering retains newest-first order and supports empty matches',
      () async {
    final container = ProviderContainer(overrides: [
      monthlyExpensesProvider.overrideWith((ref) => Stream.value([
            expense(1, 1, 'Paid'),
            expense(2, 24, 'Planned', status: ExpenseStatus.planned),
            expense(3, 20, 'Paid later'),
          ])),
    ]);
    addTearDown(container.dispose);
    await container.read(monthlyExpensesProvider.future);
    container.read(activeStatusFilterProvider.notifier).state =
        ExpenseStatus.paid;
    expect(
        container.read(filteredExpensesProvider).requireValue.map((e) => e.id),
        [3, 1]);
    container.read(searchQueryProvider.notifier).state = 'missing';
    expect(container.read(filteredExpensesProvider).requireValue, isEmpty);
  });
}
