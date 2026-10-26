import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/features/vault/vault_goal_schedule.dart';
import 'package:budget_buddy/features/vault/presentation/vault_time.dart';
import 'package:budget_buddy/core/services/free_funds.dart';

void main() {
  VaultGoalSchedule schedule(
          {String? month = '2027-06',
          int target = 1000000,
          int saved = 100000}) =>
      VaultGoalSchedule(
          target: target,
          saved: saved,
          targetMonth: month,
          now: DateTime(2026, 10, 23));
  test('inclusive nine-month goal suggests 100,000; withdrawals recalculate',
      () {
    expect(schedule().months, 9);
    expect(schedule().suggested, 100000);
    expect(schedule(saved: 0).suggested, 111112);
  });
  test('undated, reached, overdue and invalid goals do not divide by zero', () {
    expect(schedule(month: null).suggested, isNull);
    expect(schedule(saved: 1000001).remaining, 0);
    expect(schedule(saved: 1000001).suggested, 0);
    expect(schedule(month: '2026-09').overdue, isTrue);
    expect(schedule(month: '2026-09').suggested, isNull);
    expect(schedule(month: '2026-13').invalid, isTrue);
    expect(schedule(month: '2026-10').suggested, 900000);
  });
  test('year rollover and minor-unit ceiling are exact', () {
    final result = VaultGoalSchedule(
        target: 100, saved: 0, targetMonth: '2027-02', now: DateTime(2026, 12));
    expect(result.months, 3);
    expect(result.suggested, 34);
  });
  test(
      'shared financial rule protects unused allocations without duplicate borrowing',
      () {
    expect(freeToSpend(income: 200000, paid: 50000, returned: 0, unused: 80000),
        70000);
    expect(
        freeToSpend(
            income: 200000,
            paid: 50000,
            returned: 0,
            unused: 80000,
            transfers: -20000),
        50000);
    expect(
        freeToSpend(income: 100000, paid: 120000, returned: 10000, unused: 0),
        -10000);
    expect(
        () => freeToSpend(
            income: 9007199254740991, paid: 0, returned: 1, unused: 0),
        throwsFormatException);
  });
  test('local timestamp has date and HH:mm but no fractional seconds', () {
    expect(formatVaultTime(DateTime(2026, 10, 23, 21, 58, 34, 154, 542)),
        '23 Oct 2026, 21:58');
  });
}
