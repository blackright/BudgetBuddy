import '../models/income_source.dart';

/// Pure period rules for income activation.
///
/// A period key is always `YYYY-MM`. Monthly, weekly and one-time sources use a
/// calendar month; quarterly sources use the first month of the quarter; yearly
/// sources use January. The key is an identity, not a cash date.
String periodKeyFor(IncomeSource source, DateTime date) {
  final month = _month(date);
  return switch (source.frequency) {
    IncomeFrequency.monthly || IncomeFrequency.weekly => month,
    IncomeFrequency.quarterly => _quarterStart(month),
    IncomeFrequency.yearly => '${date.year.toString().padLeft(4, '0')}-01',
    IncomeFrequency.oneTime => _month(source.startDate ?? date),
  };
}

/// The next period key, or null when a one-time source has no next period.
String? nextPeriodKey(IncomeSource source, String periodKey) {
  final start = _parseMonth(periodKey);
  final step = switch (source.frequency) {
    IncomeFrequency.monthly || IncomeFrequency.weekly => 1,
    IncomeFrequency.quarterly => 3,
    IncomeFrequency.yearly => 12,
    IncomeFrequency.oneTime => 0,
  };
  if (step == 0) return null;
  return _shiftMonth(start, step);
}

/// The inclusive last month of [periodKey] for [frequency].
String periodEndKey(String periodKey, IncomeFrequency frequency) {
  final start = _parseMonth(periodKey);
  final span = switch (frequency) {
    IncomeFrequency.monthly || IncomeFrequency.weekly => 0,
    IncomeFrequency.quarterly => 2,
    IncomeFrequency.yearly => 11,
    IncomeFrequency.oneTime => 0,
  };
  return _shiftMonth(start, span);
}

/// Whether [periodKey] is an applicable period for [source].
///
/// A source that starts inside a quarter or year is active for that first
/// period. A source with an end date is inactive after that month.
bool isPeriodActive(IncomeSource source, String periodKey) {
  final start = _parseMonth(periodKey);
  final end = _parseMonth(periodEndKey(periodKey, source.frequency));
  final startMonth = _parseMonth(_month(source.startDate ?? source.createdAt));
  final endMonth =
      source.endDate == null ? null : _parseMonth(_month(source.endDate!));
  if (source.frequency == IncomeFrequency.oneTime &&
      _compare(start, startMonth) != 0) {
    return false;
  }
  if (_compare(start, end) > 0) {
    throw FormatException('Period start is after its end: $periodKey');
  }
  if (_compare(end, startMonth) < 0) return false;
  if (endMonth != null && _compare(start, endMonth) > 0) return false;
  return true;
}

String _quarterStart(String month) {
  final parsed = _parseMonth(month);
  final startMonth = ((parsed.month - 1) ~/ 3) * 3 + 1;
  return '${parsed.year.toString().padLeft(4, '0')}-'
      '${startMonth.toString().padLeft(2, '0')}';
}

String _month(DateTime value) => '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}';

({int year, int month}) _parseMonth(String value) {
  if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(value)) {
    throw FormatException('Invalid income period: $value');
  }
  final parts = value.split('-').map(int.parse).toList();
  return (year: parts[0], month: parts[1]);
}

String _shiftMonth(({int year, int month}) value, int offset) {
  final date = DateTime.utc(value.year, value.month + offset);
  return _month(date);
}

int _compare(({int year, int month}) a, ({int year, int month}) b) {
  final byYear = a.year.compareTo(b.year);
  return byYear != 0 ? byYear : a.month.compareTo(b.month);
}
