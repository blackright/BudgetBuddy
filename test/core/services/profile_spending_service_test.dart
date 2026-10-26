import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/network/rate_types.dart';
import 'package:budget_buddy/core/services/profile_spending_service.dart';
import 'package:budget_buddy/features/engine/currency_resolution.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';

RateTable _table() => RateTable(
      usdRates: {
        CurrencyCode.usd: 1.0,
        CurrencyCode.eur: 0.86,
        CurrencyCode.huf: 345.0,
        CurrencyCode.cad: 1.36,
      },
      asOf: DateTime(2026, 1, 31),
      fetchedAt: DateTime(2026, 2, 1),
      source: RateSource.historical,
    );

Expense _expense({
  required int amount,
  required String currency,
  ExpenseStatus status = ExpenseStatus.paid,
  int profileId = 1,
  int? budgetProfileId,
  String yearMonth = '2026-01',
}) =>
    Expense(
      profileId: profileId,
      budgetProfileId: budgetProfileId ?? profileId,
      yearMonth: yearMonth,
      title: 'Row',
      amount: amount,
      currency: currency,
      categoryId: 'general',
      status: status,
      date: DateTime(2026, 1, 10),
      budgetId: 1,
    );

void main() {
  const service = ProfileSpendingService();

  test('partial refunds preserve the unrecovered expense spending', () {
    final expense = _expense(
        amount: 10000,
        currency: 'usd',
        status: ExpenseStatus.partiallyReimbursed)
      ..id = 10;
    final returned = Reimbursement(
        profileId: 1,
        expenseId: 10,
        originYearMonth: '2026-01',
        amount: 2500,
        currency: 'usd',
        date: DateTime(2026));
    expect(
        service.spentInYearMonth(
            profileId: 1,
            yearMonth: '2026-01',
            expenses: [expense],
            reimbursements: [returned]),
        7500);
  });

  test('without a converter the raw minor units are summed (legacy callers)',
      () {
    final total = service.spentInYearMonth(
      profileId: 1,
      yearMonth: '2026-01',
      expenses: [
        _expense(amount: 3450, currency: 'huf'),
        _expense(amount: 500, currency: 'usd'),
      ],
    );

    expect(total, 3950);
  });

  test('a converter brings every row into one currency before summing (D5)',
      () {
    final table = _table();
    final total = service.spentInYearMonth(
      profileId: 1,
      yearMonth: '2026-01',
      expenses: [
        _expense(amount: 3450, currency: 'huf'),
        _expense(amount: 500, currency: 'usd'), // $5.00 = 1,725 Ft
      ],
      convert: (expense) =>
          expenseToDisplay(expense, CurrencyCode.huf, table).minorUnits,
    );

    expect(total, 5175);
  });

  test('only paid-like rows in the requested month and profile count', () {
    final table = _table();
    final total = service.spentInYearMonth(
      profileId: 1,
      yearMonth: '2026-01',
      expenses: [
        _expense(amount: 1000, currency: 'huf'),
        _expense(
          amount: 2000,
          currency: 'huf',
          status: ExpenseStatus.cancelled,
        ),
        _expense(amount: 3000, currency: 'huf', yearMonth: '2026-02'),
        _expense(amount: 4000, currency: 'huf', profileId: 2),
      ],
      convert: (expense) =>
          expenseToDisplay(expense, CurrencyCode.huf, table).minorUnits,
    );

    expect(total, 1000);
  });
}
