import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/engine/expense_delta.dart';
import 'package:flutter_test/flutter_test.dart';

ExpenseSnapshot snap(double amount, ExpenseStatus status, {double rate = 1}) =>
    ExpenseSnapshot(
        amount: amount, exchangeRateToPrimary: rate, status: status);

void main() {
  group('ExpenseDelta', () {
    test('paid amount 50 → 60 lowers both metrics by exactly 10', () {
      final d = ExpenseDelta.between(
        before: snap(50, ExpenseStatus.paid),
        after: snap(60, ExpenseStatus.paid),
      );
      expect(d.trueAvailableDelta, -10);
      expect(d.safeToSpendDelta, -10);
    });

    test('planned → paid lowers trueAvailable only', () {
      final d = ExpenseDelta.between(
        before: snap(100, ExpenseStatus.planned),
        after: snap(100, ExpenseStatus.paid),
      );
      expect(d.trueAvailableDelta, -100);
      expect(d.safeToSpendDelta, 0);
    });

    test('paid → planned restores trueAvailable only', () {
      final d = ExpenseDelta.between(
        before: snap(100, ExpenseStatus.paid),
        after: snap(100, ExpenseStatus.planned),
      );
      expect(d.trueAvailableDelta, 100);
      expect(d.safeToSpendDelta, 0);
    });

    test('currency rate is applied', () {
      final d = ExpenseDelta.between(
        before: snap(10, ExpenseStatus.paid, rate: 400),
        after: snap(12, ExpenseStatus.paid, rate: 400),
      );
      expect(d.trueAvailableDelta, -800);
    });

    test('duplicate (no before) costs the full amount', () {
      final d = ExpenseDelta.between(after: snap(5, ExpenseStatus.paid));
      expect(d.trueAvailableDelta, -5);
      expect(d.safeToSpendDelta, -5);
    });

    test('delete (no after) frees the full amount', () {
      final d = ExpenseDelta.between(before: snap(5, ExpenseStatus.planned));
      expect(d.trueAvailableDelta, 0);
      expect(d.safeToSpendDelta, 5);
    });

    test('smart warning: planned 100 → 500 with safeToSpend 300', () {
      final d = ExpenseDelta.between(
        before: snap(100, ExpenseStatus.planned),
        after: snap(500, ExpenseStatus.planned),
      );
      expect(d.wouldOverspend(300), isTrue);
      expect(d.wouldOverspend(400), isFalse);
    });

    test('no warning when edit reduces spending even if already over', () {
      final d = ExpenseDelta.between(
        before: snap(500, ExpenseStatus.planned),
        after: snap(400, ExpenseStatus.planned),
      );
      expect(d.wouldOverspend(-50), isFalse);
    });
  });
}
