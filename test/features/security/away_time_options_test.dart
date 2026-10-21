import 'package:budget_buddy/features/security/domain/away_time.dart';
import 'package:flutter_test/flutter_test.dart';

/// T064 (FR-033, SC-013): the away-time offers exactly five bounded choices and
/// never a "never".
///
/// SC-013 is a *count* requirement — "the user is offered at most five choices"
/// — so the assertion is deliberately about the set, not about a hand-picked
/// pair. A sixth value added later (or a "never" smuggled in as a zero-window)
/// must break this test rather than quietly widen the surface.
///
/// FR-033 is the other half: the app must always re-arm itself. There is no
/// "never", and the shortest window is a real re-lock, not an opt-out.
void main() {
  group('T064: the five bounded away-time choices', () {
    test('exactly five choices are offered (SC-013)', () {
      expect(AwayTime.values.length, 5);
    });

    test('the choices are the five bounded windows, in order (FR-033)', () {
      expect(AwayTime.values, const [
        AwayTime.immediate,
        AwayTime.thirtySeconds,
        AwayTime.oneMinute,
        AwayTime.twoMinutes,
        AwayTime.fiveMinutes,
      ]);
    });

    test('there is no "never": every choice re-arms the lock (FR-033)', () {
      for (final choice in AwayTime.values) {
        // A "never" would be a window that never elapses. The longest is five
        // minutes, so nothing here can be mistaken for an opt-out.
        expect(choice.window, lessThanOrEqualTo(const Duration(minutes: 5)),
            reason: '${choice.name} must be a bounded window');
      }
    });

    test('every choice has a plain label and no raw enum name leaks out', () {
      for (final choice in AwayTime.values) {
        expect(choice.label, isNotEmpty);
        expect(choice.label.toLowerCase(), isNot(contains('awaytime')),
            reason: 'the label speaks the user\'s words, not the enum name');
      }
    });

    test('the windows increase strictly, so "stricter" is well-defined', () {
      final windows = AwayTime.values.map((c) => c.window).toList();
      for (var i = 1; i < windows.length; i++) {
        expect(windows[i], greaterThan(windows[i - 1]),
            reason:
                'a later choice must not be a shorter wait than an earlier');
      }
    });

    test('stricter picks the shorter window, either way round (FR-028)', () {
      expect(AwayTime.stricter(AwayTime.fiveMinutes, AwayTime.thirtySeconds),
          AwayTime.thirtySeconds);
      expect(AwayTime.stricter(AwayTime.thirtySeconds, AwayTime.fiveMinutes),
          AwayTime.thirtySeconds);
      expect(AwayTime.stricter(AwayTime.immediate, AwayTime.immediate),
          AwayTime.immediate);
    });
  });
}
