import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The month the whole app is currently scoped to, as `YYYY-MM`.
///
/// Promoted from a hardcoded "whatever month it is today" read so the selection
/// can be moved backwards and forwards (FR-026). Every downstream consumer
/// scopes its queries through this value, which is what makes the selection
/// persist across screens without per-screen plumbing (FR-027).
final selectedYearMonthProvider =
    StateProvider<String>((ref) => currentYearMonth());

/// The month the wall clock is in. Used as the initial selection only.
String currentYearMonth([DateTime? now]) {
  final instant = now ?? DateTime.now();
  final month = instant.month.toString().padLeft(2, '0');
  return '${instant.year}-$month';
}

/// Moves [yearMonth] by [delta] months, rolling the year over in both
/// directions.
///
/// Throws [ArgumentError] if [yearMonth] is not `YYYY-MM`.
String shiftMonth(String yearMonth, int delta) {
  final parts = _parseYearMonth(yearMonth);
  final year = parts.$1;
  final month = parts.$2;

  final zeroBased = year * 12 + (month - 1) + delta;
  final shiftedYear = zeroBased ~/ 12;
  final shiftedMonth = zeroBased % 12 + 1;

  return '$shiftedYear-${shiftedMonth.toString().padLeft(2, '0')}';
}

/// The month before [yearMonth].
String previousMonth([String? yearMonth]) =>
    shiftMonth(yearMonth ?? currentYearMonth(), -1);

/// The month after [yearMonth].
String nextMonth([String? yearMonth]) =>
    shiftMonth(yearMonth ?? currentYearMonth(), 1);

/// The current wall-clock month, for the "Today" control (FR-026).
String goToToday() => currentYearMonth();

(int, int) _parseYearMonth(String yearMonth) {
  final match = RegExp(r'^(\d{4})-(\d{2})$').firstMatch(yearMonth);
  if (match == null) {
    throw ArgumentError.value(yearMonth, 'yearMonth', 'Expected YYYY-MM');
  }
  final month = int.parse(match.group(2)!);
  if (month < 1 || month > 12) {
    throw ArgumentError.value(yearMonth, 'yearMonth', 'Month must be 01-12');
  }
  return (int.parse(match.group(1)!), month);
}

/// Human-readable label for a `YYYY-MM` value, e.g. `October 2026`.
String monthLabel(String yearMonth) {
  final (year, month) = _parseYearMonth(yearMonth);
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${names[month - 1]} $year';
}
