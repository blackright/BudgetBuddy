/// The five bounded away-time choices (FR-033, data-model §2).
///
/// There is deliberately **no** "never": the app must always re-arm itself.
/// The order of the values is part of the stored schema — `Isar` writes an
/// `@enumerated` field as this index — so members are appended, never reordered
/// and never removed.
enum AwayTime {
  immediate(Duration.zero),
  thirtySeconds(Duration(seconds: 30)),
  oneMinute(Duration(minutes: 1)),
  twoMinutes(Duration(minutes: 2)),
  fiveMinutes(Duration(minutes: 5));

  const AwayTime(this.window);

  /// How long the app may stay away before it locks again.
  final Duration window;

  /// The wording the Settings control shows (contracts/security-settings-ui §2).
  String get label => switch (this) {
        AwayTime.immediate => 'Immediately',
        AwayTime.thirtySeconds => 'After 30 seconds',
        AwayTime.oneMinute => 'After 1 minute',
        AwayTime.twoMinutes => 'After 2 minutes',
        AwayTime.fiveMinutes => 'After 5 minutes',
      };

  /// The stricter of two choices — the shorter window wins.
  ///
  /// A space Owner's requirement composes with the member's own choice by this
  /// rule, so a member can lock sooner but never later (FR-028, data-model §4).
  static AwayTime stricter(AwayTime a, AwayTime b) =>
      a.window <= b.window ? a : b;
}
