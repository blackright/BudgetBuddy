import 'package:isar/isar.dart';
part 'previous_goal_vault.g.dart';

/// Actual version-25 shape, with a goal but no target-month property.
@collection
@Name('SavingsVault')
class PreviousGoalVault {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late int profileId;
  int totalMinor = 0;
  String? goalName;
  int? goalTargetMinor;
  String currency = '';
  late String lastSweepYearMonth;
  bool sweepPaused = false;
  String? pauseReason;
  late DateTime updatedAt;
  double totalAmount = 0;
}
