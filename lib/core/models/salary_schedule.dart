import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'salary_schedule.g.dart';

/// Configuration for a recurring Salary source's payday and banking calendar.
///
/// One schedule per Salary [IncomeSource]. Later expected-source edits must not
/// rewrite prior cycles; the schedule is versioned by [policyRevision] and
/// cycles snapshot the values they need at creation time.
@collection
class SalarySchedule {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String guid = newSyncGuid();

  /// Owning personal profile (salary schedules are personal only).
  @Index()
  int? profileId;

  /// The Salary [IncomeSource.syncGuid] this schedule governs.
  @Index()
  late String sourceGuid;

  /// Nominal payday day-of-month: 25 normally, 15 in December.
  int nominalDay = 25;

  /// Banking country code (e.g. 'HU', 'UG', 'CA', 'US', 'CD').
  late String countryCode;

  /// Optional region/state for country-specific rules.
  String? regionCode;

  /// User-confirmed IANA timezone for reminder scheduling.
  late String timezone;

  /// Whether calendar coverage for [countryCode] has been verified.
  bool calendarVerified = false;

  /// Covered date range start (inclusive) for verified calendar data.
  DateTime? coverageStart;

  /// Covered date range end (inclusive) for verified calendar data.
  DateTime? coverageEnd;

  int policyRevision = 1;

  late DateTime createdAt;
  late DateTime updatedAt;
}
