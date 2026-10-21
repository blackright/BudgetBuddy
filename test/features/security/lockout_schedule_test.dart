import 'package:budget_buddy/features/security/domain/lockout_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

/// T020: FR-013 — the wait after a failed PIN follows the fixed, visible
/// schedule, with the boundaries the requirement makes hard.
void main() {
  group('T020: the schedule', () {
    test('the first four failures cost no wait', () {
      for (var failures = 0; failures <= 4; failures++) {
        expect(LockoutSchedule.waitFor(failures), Duration.zero,
            reason: 'failure $failures must not wait');
      }
    });

    test('the fifth failure is exactly 30 seconds', () {
      expect(LockoutSchedule.waitFor(5), const Duration(seconds: 30));
    });

    test('failures six to nine still wait 30 seconds', () {
      for (final failures in [6, 7, 8, 9]) {
        expect(LockoutSchedule.waitFor(failures), const Duration(seconds: 30),
            reason: 'failure $failures must wait 30s');
      }
    });

    test('the tenth failure is exactly 5 minutes', () {
      expect(LockoutSchedule.waitFor(10), const Duration(minutes: 5));
    });

    test('failures beyond ten double, capped at 60 minutes', () {
      expect(LockoutSchedule.waitFor(11), const Duration(minutes: 10));
      expect(LockoutSchedule.waitFor(12), const Duration(minutes: 20));
      expect(LockoutSchedule.waitFor(13), const Duration(minutes: 40));
      expect(LockoutSchedule.waitFor(14), const Duration(minutes: 60));
      expect(LockoutSchedule.waitFor(15), const Duration(minutes: 60));
      expect(LockoutSchedule.waitFor(100), const Duration(minutes: 60),
          reason: 'the cap holds no matter how many failures pile up');
    });
  });

  group('T020: the boundaries the boundaries test cares about', () {
    test('4 -> none, 5 -> 30s', () {
      expect(LockoutSchedule.waitFor(4), Duration.zero);
      expect(LockoutSchedule.waitFor(5), const Duration(seconds: 30));
    });

    test('9 -> 30s, 10 -> 5 min', () {
      expect(LockoutSchedule.waitFor(9), const Duration(seconds: 30));
      expect(LockoutSchedule.waitFor(10), const Duration(minutes: 5));
    });

    test('13 -> 40 min, 14 -> the 60 min cap', () {
      expect(LockoutSchedule.waitFor(13), const Duration(minutes: 40));
      expect(LockoutSchedule.waitFor(14), const Duration(minutes: 60));
    });
  });

  group('T020: the schedule only ever grows', () {
    test('no failure count produces a shorter wait than the one below it', () {
      var previous = Duration.zero;
      for (var failures = 0; failures <= 40; failures++) {
        final wait = LockoutSchedule.waitFor(failures);
        expect(wait >= previous, isTrue,
            reason: 'failure $failures must not wait less than $previous');
        previous = wait;
      }
    });
  });
}
