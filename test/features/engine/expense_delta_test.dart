import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/features/engine/expense_delta.dart';
import 'package:flutter_test/flutter_test.dart';

ExpenseSnapshot snap(double amount, ExpenseStatus status) => ExpenseSnapshot(
      amount: Money.fromMajor(amount, CurrencyCode.usd).minorUnits,
      currency: CurrencyCode.usd,
      status: status,
    );

/// Identity conversion for USD amounts entered as majors in the tests.
double identity(ExpenseSnapshot s) => s.amount / 100.0;

void main() {
  group('ExpenseDelta', () {
    test('paid amount 50 → 60 lowers both metrics by exactly 10', () {
      final d = ExpenseDelta.between(
        before: snap(50, ExpenseStatus.paid),
        after: snap(60, ExpenseStatus.paid),
        toPrimary: identity,
      );
      expect(d.trueAvailableDelta, -10);
      expect(d.safeToSpendDelta, -10);
    });

    test('planned → paid lowers trueAvailable only', () {
      final d = ExpenseDelta.between(
        before: snap(100, ExpenseStatus.planned),
        after: snap(100, ExpenseStatus.paid),
        toPrimary: identity,
      );
      expect(d.trueAvailableDelta, -100);
      expect(d.safeToSpendDelta, 0);
    });

    test('paid → planned restores trueAvailable only', () {
      final d = ExpenseDelta.between(
        before: snap(100, ExpenseStatus.paid),
        after: snap(100, ExpenseStatus.planned),
        toPrimary: identity,
      );
      expect(d.trueAvailableDelta, 100);
      expect(d.safeToSpendDelta, 0);
    });

    test('currency rate is applied', () {
      double r400(ExpenseSnapshot s) => s.amount / 100.0 * 400;
      final d = ExpenseDelta.between(
        before: snap(10, ExpenseStatus.paid),
        after: snap(12, ExpenseStatus.paid),
        toPrimary: r400,
      );
      expect(d.trueAvailableDelta, -800);
    });

    test('duplicate (no before) costs the full amount', () {
      final d = ExpenseDelta.between(
        after: snap(5, ExpenseStatus.paid),
        toPrimary: identity,
      );
      expect(d.trueAvailableDelta, -5);
      expect(d.safeToSpendDelta, -5);
    });

    test('delete (no after) frees the full amount', () {
      final d = ExpenseDelta.between(
        before: snap(5, ExpenseStatus.planned),
        toPrimary: identity,
      );
      expect(d.trueAvailableDelta, 0);
      expect(d.safeToSpendDelta, 5);
    });

    test('smart warning: planned 100 → 500 with safeToSpend 300', () {
      final d = ExpenseDelta.between(
        before: snap(100, ExpenseStatus.planned),
        after: snap(500, ExpenseStatus.planned),
        toPrimary: identity,
      );
      expect(d.wouldOverspend(300), isTrue);
      expect(d.wouldOverspend(400), isFalse);
    });

    test('no warning when edit reduces spending even if already over', () {
      final d = ExpenseDelta.between(
        before: snap(500, ExpenseStatus.planned),
        after: snap(400, ExpenseStatus.planned),
        toPrimary: identity,
      );
      expect(d.wouldOverspend(-50), isFalse);
    });
  });
}