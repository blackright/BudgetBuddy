import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'banking_calendar_coverage.g.dart';

/// Verified (or unverified) banking calendar coverage for a country/region.
///
/// Missing coverage is an explicit degraded state, never a false weekday.
@collection
class BankingCalendarCoverage {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String guid = newSyncGuid();

  /// Country code (e.g. 'HU', 'UG', 'CA', 'US', 'CD').
  @Index()
  late String countryCode;

  /// Optional region/state.
  String? regionCode;

  /// Covered date range start (inclusive).
  late DateTime coverageStart;

  /// Covered date range end (inclusive).
  late DateTime coverageEnd;

  /// Whether the data is verified against an official source.
  bool verified = false;

  /// Source name (e.g. 'magyar-nemzeti-bank', 'bank-of-uganda').
  String sourceName = '';

  /// Source URL or reference.
  String sourceRef = '';

  /// Verification/update status: 'verified', 'partial', 'unverified'.
  String status = 'unverified';

  /// Notes about coverage gaps.
  String notes = '';

  late DateTime createdAt;
  late DateTime updatedAt;
}
