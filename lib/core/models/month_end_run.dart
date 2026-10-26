import 'package:isar/isar.dart';

part 'month_end_run.g.dart';

/// Immutable settlement; source allocations/expenses are never rewritten.
/// One context/month key covers all policies, so a policy change cannot bypass
/// idempotency. The complete destination plan travels in one signed sync unit.
@collection
class MonthEndRun {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String syncGuid;
  int? profileId;
  int? sharedSpaceId;
  late String contextGuid;
  @Index()
  late String yearMonth;
  late String destinationMonth;
  late String currency;
  late String reportJson;
  late String fingerprint;
  late String actor;
  late DateTime createdAt;
  int carriedMinor = 0;
  int releasedMinor = 0;

  /// A differing offline confirmation is surfaced and blocks further closes;
  /// it never adds a second carry or silently replaces the accepted run.
  bool hasConflict = false;
  bool applied = true;
}
