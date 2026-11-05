import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/expenses/domain/expense_date_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 1, 15, 30);

  test('a paid expense stops at today', () {
    expect(expenseDateCeiling(ExpenseStatus.paid, now), DateTime(2026, 11, 1));
    expect(isFuturePaidExpense(ExpenseStatus.paid, DateTime(2026, 11, 1), now),
        isFalse);
    expect(isFuturePaidExpense(ExpenseStatus.paid, DateTime(2026, 10, 31), now),
        isFalse);
    expect(isFuturePaidExpense(ExpenseStatus.paid, DateTime(2026, 11, 2), now),
        isTrue);
  });

  test('a planned expense may look a year ahead', () {
    expect(
        expenseDateCeiling(ExpenseStatus.planned, now), DateTime(2027, 11, 1));
    expect(
        isFuturePaidExpense(ExpenseStatus.planned, DateTime(2027, 6, 1), now),
        isFalse);
  });

  test('past dates start in 2000', () {
    expect(expenseDateFloor(), DateTime(2000));
  });
}
