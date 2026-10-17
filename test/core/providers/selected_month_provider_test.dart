import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// The month arithmetic the reimbursement attribution leans on: a payout for a
/// December bill must land in the following January, not in December again.
void main() {
  group('shiftMonth', () {
    test('moves forward within a year', () {
      expect(shiftMonth('2026-01', 1), '2026-02');
      expect(shiftMonth('2026-06', 3), '2026-09');
    });

    test('rolls over the year boundary', () {
      expect(shiftMonth('2026-12', 1), '2027-01');
      expect(shiftMonth('2026-01', -1), '2025-12');
    });

    test('rejects a malformed month', () {
      expect(() => shiftMonth('2026-13', 1), throwsArgumentError);
      expect(() => shiftMonth('2026', 1), throwsArgumentError);
    });
  });

  group('nextMonth / previousMonth', () {
    test('nextMonth rolls December into January', () {
      expect(nextMonth('2026-12'), '2027-01');
    });

    test('previousMonth rolls January into December', () {
      expect(previousMonth('2026-01'), '2025-12');
    });
  });

  group('monthLabel', () {
    test('names the month and year', () {
      expect(monthLabel('2026-02'), 'February 2026');
      expect(monthLabel('2027-01'), 'January 2027');
    });
  });

  group('snapToCurrentMonthIfBehind (US8)', () {
    test('snaps a stale selection forward to the current month', () {
      // Left the app on October, opened it on 1 November.
      expect(
        snapToCurrentMonthIfBehind('2026-10', DateTime(2026, 11, 1)),
        '2026-11',
      );
      // Even across a year boundary.
      expect(
        snapToCurrentMonthIfBehind('2025-12', DateTime(2026, 1, 2)),
        '2026-01',
      );
    });

    test('keeps the current month untouched', () {
      expect(
        snapToCurrentMonthIfBehind('2026-11', DateTime(2026, 11, 15)),
        '2026-11',
      );
    });

    test('keeps a deliberately chosen future month', () {
      expect(
        snapToCurrentMonthIfBehind('2027-03', DateTime(2026, 11, 15)),
        '2027-03',
      );
    });
  });
}
