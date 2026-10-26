/// The fixed, visible wait after a failed PIN (FR-013).
///
/// | Failure | Wait |
/// |---|---|
/// | 1-4 | none |
/// | 5-9 | 30 seconds |
/// | 10 | 5 minutes |
/// | 11+ | double, capped at 60 minutes |
///
/// Pure Dart and total: every `int` answers with a [Duration], including
/// negatives and absurdly large counts, so a corrupt record can never make the
/// lock throw or wait forever.
class LockoutSchedule {
  const LockoutSchedule._();

  /// The wait once the schedule starts biting (failures 5-9).
  static const Duration shortWait = Duration(seconds: 30);

  /// The wait at the tenth failure.
  static const Duration longWait = Duration(minutes: 5);

  /// The ceiling the doubling never passes.
  static const Duration cap = Duration(minutes: 60);

  /// The wait owed after [failCount] consecutive failures.
  static Duration waitFor(int failCount) {
    if (failCount <= 4) return Duration.zero;
    if (failCount <= 9) return shortWait;
    // 10 -> 5 min, then 10, 20, 40, and 60 from the fourteenth failure on.
    final doublings = failCount - 10;
    if (doublings >= 4) return cap;
    return Duration(minutes: 5 << doublings);
  }
}
