import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/services/month_end_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('late spending cannot reuse released funds or erase committed carry',
      () {
    const reset =
        MonthEndReservation(unused: 10000, carried: 0, released: 20000);
    const carry =
        MonthEndReservation(unused: 10000, carried: 20000, released: 0);
    expect(reset.releasedCredit, 10000);
    expect(carry.carryShortfall, 10000);
  });
  test('Reset releases unused and Carry Forward adds it to the base once', () {
    final reset = MonthEndAmounts(
        allocation: 100000,
        spent: 80000,
        defaultAllocation: 100000,
        rule: MonthEndRule.reset);
    final carry = MonthEndAmounts(
        allocation: 100000,
        spent: 80000,
        defaultAllocation: 100000,
        rule: MonthEndRule.carryForward);
    expect(reset.released, 20000);
    expect(reset.carried, 0);
    expect(reset.nextAllocation, 100000);
    expect(carry.released, 0);
    expect(carry.carried, 20000);
    expect(carry.nextAllocation, 120000);
  });
  test('existing destination preserves its base; debt never carries', () {
    final value = MonthEndAmounts(
        allocation: 100,
        spent: 120,
        defaultAllocation: 100,
        destinationAllocation: 75,
        rule: MonthEndRule.carryForward);
    expect(value.unused, 0);
    expect(value.overspent, 20);
    expect(value.nextAllocation, 75);
  });
  test('month navigation handles year boundaries and invalid inputs', () {
    expect(nextFinancialMonth('2026-12'), '2027-01');
    expect(() => nextFinancialMonth('2026-13'), throwsArgumentError);
  });
}
