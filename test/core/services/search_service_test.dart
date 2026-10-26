import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/services/search_service.dart';
import 'package:budget_buddy/core/services/filter_service.dart';
import 'package:flutter_test/flutter_test.dart';

Expense row(int id, String title,
        {String month = '2026-10',
        String currency = 'eur',
        int amount = 1000}) =>
    Expense(
        id: id,
        profileId: 1,
        yearMonth: month,
        title: title,
        amount: amount,
        currency: currency,
        categoryId: 'food',
        date: DateTime(2026, 10, id),
        budgetId: 1);

void main() {
  const service = SearchService();
  test(
      'all literal partial words match across fields/aliases, not regex or alternatives',
      () {
    final coffee = row(1, 'Coffee')
      ..notes = 'Office meeting'
      ..merchantSyncGuid = 'shop'
      ..tags = ['Work'];
    final tea = row(2, 'Tea');
    final rows = [coffee, tea];
    expect(
        service.searchExpenses(
            rows, 'OFF cof work shop', const ExpenseFilters(), '2026-10',
            merchantAliases: {
              'shop': ['Shop central']
            }),
        [coffee]);
    expect(
        service.searchExpenses(
            rows, 'coffee tea', const ExpenseFilters(), '2026-10'),
        isEmpty);
    expect(
        service.searchExpenses(rows, '.*', const ExpenseFilters(), '2026-10'),
        isEmpty);
    expect(
        service.searchExpenses(rows, '  ', const ExpenseFilters(), '2026-10'),
        [tea, coffee]);
    expect(rows, [coffee, tea]);
  });
  test('date ranges include the last day, currencies and bounds are exact', () {
    final first = row(1, 'first')..date = DateTime(2026, 10, 1, 0);
    final last = row(2, 'last')..date = DateTime(2026, 10, 2, 23, 59, 59);
    final next = row(3, 'next')..date = DateTime(2026, 10, 3);
    final usd = row(4, 'USD', currency: 'usd');
    final filters = ExpenseFilters(
        scope: ExpenseDateScope.range,
        start: DateTime(2026, 10, 1),
        end: DateTime(2026, 10, 2),
        currency: 'EUR',
        minimum: 1000,
        maximum: 1000);
    expect(
        service
            .searchExpenses([first, last, next, usd], '', filters, '2026-09'),
        [last, first]);
    expect(const ExpenseFilters(minimum: 1).error, isNotNull);
    expect(parseSearchAmount('1,000.01', CurrencyCode.eur), 100001);
    expect(parseSearchAmount('0', CurrencyCode.huf), 0);
    expect(() => parseSearchAmount('1.001', CurrencyCode.eur),
        throwsFormatException);
    expect(() => parseSearchAmount('1,00', CurrencyCode.huf),
        throwsFormatException);
  });
  test('all filters combine and ambiguous profiles never become Main', () {
    final item = row(1, 'item')
      ..merchantSyncGuid = 'merchant'
      ..paymentMethod = 'cash'
      ..budgetProfileId = 1
      ..financialProfileType = 'direct'
      ..financialProfileSyncGuid = 'direct-guid';
    final unknown = row(2, 'unknown')..budgetProfileId = 1;
    final filters = ExpenseFilters(
        merchant: 'merchant',
        financialProfile: expenseFinancialKey(item),
        category: 'food',
        currency: 'eur',
        paymentMethod: 'cash',
        status: ExpenseStatus.paid);
    expect(service.searchExpenses([item, unknown], '', filters, '2026-10'),
        [item]);
    expect(expenseFinancialKey(unknown), 'unresolved');
    final pending = row(4, 'Pending target')
      ..financialProfileType = FinancialProfileType.budget
      ..financialProfileSyncGuid = 'not-yet-received';
    expect(expenseFinancialKey(pending), 'unresolved');
    expect(
        service.searchExpenses([unknown], '',
            const ExpenseFilters(financialProfile: 'main'), '2026-10'),
        isEmpty);
    expect(
        service.searchExpenses([row(3, 'other month', month: '2025-01')], '',
            const ExpenseFilters(scope: ExpenseDateScope.all), '2026-10'),
        hasLength(1));
  });
}
