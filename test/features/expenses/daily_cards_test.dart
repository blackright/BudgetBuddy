import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/expenses/providers/daily_cards_provider.dart';
import 'package:flutter_test/flutter_test.dart';

Expense row(int id, int day, ExpenseStatus status, int amount,
        {String currency = 'HUF'}) =>
    Expense(
        id: id,
        profileId: 1,
        yearMonth: '2026-10',
        title: 'Purchase $id',
        amount: amount,
        currency: currency,
        categoryId: 'food',
        status: status,
        date: DateTime(2026, 10, day),
        budgetId: 1);
Reimbursement refund(int id, int amount,
        {String currency = 'HUF', int owner = 1}) =>
    Reimbursement(
        profileId: owner,
        expenseId: id,
        originYearMonth: '2026-10',
        amount: amount,
        currency: currency,
        date: DateTime(2026, 10, 25));

void main() {
  test(
      'invalid legacy money and overflowing daily totals are flagged without wrapped amounts',
      () {
    final invalid = groupDailyExpenses(
        [row(1, 24, ExpenseStatus.paid, -9223372036854775808)], []).single;
    expect(invalid.incompleteCurrencies, {'HUF'});
    final large = groupDailyExpenses([
      row(1, 24, ExpenseStatus.planned, 9007199254740991),
      row(2, 24, ExpenseStatus.planned, 1)
    ], []).single;
    expect(large.incompleteCurrencies, {'HUF'});
  });
  test('groups by purchase day newest first, keeping all expenses of a day',
      () {
    final result = groupDailyExpenses([
      row(1, 23, ExpenseStatus.paid, 1000),
      row(2, 24, ExpenseStatus.paid, 2000),
      row(3, 24, ExpenseStatus.paid, 3000)
    ], []);
    expect(result.map((d) => d.date.day), [24, 23]);
    expect(result.first.expenses.map((e) => e.id), [3, 2]);
  });
  test('paid refunds, Planned and original currencies are separate', () {
    final result = groupDailyExpenses([
      row(1, 24, ExpenseStatus.partiallyReimbursed, 10000),
      row(2, 24, ExpenseStatus.planned, 3000),
      row(3, 24, ExpenseStatus.paid, 500, currency: 'EUR'),
      row(4, 24, ExpenseStatus.cancelled, 9000)
    ], [
      refund(1, 2000)
    ]).single;
    expect(result.paid, {'HUF': 8000, 'EUR': 500});
    expect(result.planned, {'HUF': 3000});
    expect(result.expenses.length, 4);
  });
  test('foreign, orphaned and wrong-month returns cannot alter totals', () {
    final result = groupDailyExpenses([
      row(1, 24, ExpenseStatus.paid, 10000)
    ], [
      refund(1, 3000, owner: 2),
      refund(1, 2000)..orphaned = true,
      refund(1, 1000)..originYearMonth = '2026-09'
    ]).single;
    expect(result.paid['HUF'], 10000);
  });
  test('unconvertible refund makes affected total explicitly incomplete', () {
    final rows = [row(1, 24, ExpenseStatus.partiallyReimbursed, 10000)];
    final returns = [refund(1, 100, currency: 'EUR')];
    expect(
        groupDailyExpenses(rows, returns).single.incompleteCurrencies, {'HUF'});
    final converted =
        groupDailyExpenses(rows, returns, convertReturn: (_, __) => 4000)
            .single;
    expect(converted.incompleteCurrencies, isEmpty);
    expect(converted.paid['HUF'], 6000);
  });
  test('legacy fully returned status matches the spending engine', () {
    expect(
        groupDailyExpenses([row(1, 24, ExpenseStatus.reimbursed, 10000)], [])
            .single
            .paid['HUF'],
        0);
  });
}
