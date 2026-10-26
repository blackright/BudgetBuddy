import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:flutter_test/flutter_test.dart';

MonthSummary summary(
        {required double setAside,
        double carriedIn = 0,
        double released = 0}) =>
    MonthSummary(
        yearMonth: '2026-10',
        income: 100,
        usesOverriddenIncome: false,
        paymentsMade: 80,
        moneyReturned: 0,
        planned: 0,
        cancelled: 0,
        medicalPaid: 0,
        excessReturned: 0,
        openingBalance: 50,
        setAside: setAside,
        carriedIn: carriedIn,
        releasedAtMonthEnd: released);
void main() {
  test(
      'incoming carry offsets its allocation once without changing income/bank balance',
      () {
    final s = summary(setAside: 40, carriedIn: 20);
    expect(s.kept, 0);
    expect(s.income, 100);
    expect(s.moneyInBank, 70);
  });
  test('Reset releases unused reservation without becoming new income', () {
    final s = summary(setAside: 20, released: 20);
    expect(s.kept, 20);
    expect(s.income, 100);
    expect(s.moneyInBank, 70);
  });
}
