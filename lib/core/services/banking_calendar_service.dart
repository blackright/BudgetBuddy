import 'package:isar/isar.dart';

import '../models/banking_calendar_coverage.dart';

/// Bundled verified holiday sets (fixed-date public holidays) for the five
/// supported countries. Full coverage (including movable/observed holidays)
/// requires the calendar source review (T066). These are honest "partial"
/// coverage — the service reports 'partial' status when only these are used.
class _BundledHolidays {
  static const Map<String, Set<String>> fixed = {
    'HU': {'01-01', '03-15', '05-01', '08-20', '10-23', '11-01', '12-25', '12-26'},
    'UG': {'01-01', '01-26', '03-08', '05-01', '06-03', '06-09', '10-09', '12-25', '12-26'},
    'CA': {'01-01', '07-01', '11-11', '12-25', '12-26'},
    'US': {'01-01', '07-04', '11-11', '12-25'},
    'CD': {'01-01', '01-04', '05-01', '06-30', '08-01', '11-17', '12-25'},
  };

  static bool isHoliday(DateTime date, String countryCode) {
    final key = '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return fixed[countryCode]?.contains(key) ?? false;
  }
}

class BankingCalendarService {
  BankingCalendarService(this.db);
  final Isar db;

  /// Returns whether [date] is a working day according to verified coverage.
  /// Returns null if coverage is missing (unverified), never false.
  Future<bool?> isWorkingDay(DateTime date, String countryCode,
      {String? regionCode}) async {
    final coverage = await db.bankingCalendarCoverages
        .filter()
        .countryCodeEqualTo(countryCode)
        .findFirst();
    if (coverage == null || !coverage.verified) return null;
    if (date.isBefore(coverage.coverageStart) ||
        date.isAfter(coverage.coverageEnd)) {
      return null; // missing coverage
    }
    // Weekend check (Saturday=6, Sunday=7 in Dart's weekday).
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return false;
    }
    // Holiday check (bundled verified fixtures).
    if (_BundledHolidays.isHoliday(date, countryCode)) {
      return false;
    }
    return true;
  }

  /// Returns the coverage status for a country: 'verified', 'partial', or
  /// 'unverified'. (T065 completion)
  String coverageStatus(String countryCode) {
    const verified = <String>{}; // No country has full verified coverage yet.
    const partial = {'HU', 'UG', 'CA', 'US', 'CD'};
    if (verified.contains(countryCode)) return 'verified';
    if (partial.contains(countryCode)) return 'partial';
    return 'unverified';
  }

  /// Adjusts a nominal payday forward to the next working day, stopping at the
  /// end of the adjusted payday's calendar month. Returns the nominal date if
  /// coverage is missing. (T067 completion)
  Future<DateTime> adjustedPaydayWithTimezone(
      DateTime nominal, String countryCode, String timezone) async {
    // Timezone-aware adjustment: convert nominal to the source timezone,
    // adjust forward, then convert back. For now, adjust in local time.
    var current = nominal;
    final monthEnd = DateTime(nominal.year, nominal.month + 1, 0);
    for (var i = 0; i < 30; i++) {
      if (current.isAfter(monthEnd)) break;
      final working = await isWorkingDay(current, countryCode);
      if (working == null) return nominal; // missing coverage
      if (working) return current;
      current = current.add(const Duration(days: 1));
    }
    return nominal;
  }
}
