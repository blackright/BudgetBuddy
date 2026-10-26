import 'package:budget_buddy/features/security/domain/monotonic_clock.dart';

/// A clock the test moves by hand (research R3, FR-014, FR-015).
///
/// The lockout's whole argument is that it measures **real elapsed time** and
/// not the wall clock, so the tests must be able to make time pass without
/// touching [DateTime]. Every value is milliseconds from an arbitrary origin, as
/// the real seam is; only differences matter.
class FakeMonotonicClock implements MonotonicClock {
  FakeMonotonicClock([this._nowMs = 1000000]);

  int _nowMs;

  @override
  int nowMs() => _nowMs;

  /// Makes [by] of real time pass. Never backwards.
  void advance(Duration by) => _nowMs += by.inMilliseconds;

  /// Jumps to an absolute reading, for a test that wants to simulate the app
  /// being closed for a long time. A smaller value is refused: the whole point
  /// of the seam is that it cannot run backwards (FR-015).
  void set(int value) {
    if (value < _nowMs) {
      throw ArgumentError.value(
          value, 'value', 'a monotonic clock cannot go back');
    }
    _nowMs = value;
  }
}
