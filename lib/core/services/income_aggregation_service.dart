import '../models/currency_code.dart';
import '../models/income_source.dart';

/// Aggregates income sources into a monthly total (minor units).
///
/// Frequency handling:
/// - oneTime: contributes only in its start month.
/// - weekly: contributes 4 occurrences per month.
/// - monthly: contributes once.
/// - quarterly: contributes in the start month and every 3rd month after.
/// - yearly: contributes in the start month each year.
///
/// **Multi-currency (T109, FR-020).** A source carries its own currency, and
/// minor units only mean something next to that currency: 1 000 minor units
/// are 1 000 forints but 10 dollars. Totals are therefore grouped by currency
/// and never summed across currencies — mixing HUF minor units with USD minor
/// units would be a meaningless number. [monthlyTotalsByCurrency] returns one
/// total per currency, and [monthlyTotal] returns the total for a single
/// requested currency.
class IncomeAggregationService {
  const IncomeAggregationService();

  /// The total for [yearMonth] in [currency], in that currency's minor units.
  ///
  /// Sources in another currency are skipped: they are not converted here
  /// (conversion is the engine's job, and it needs a rate table), so adding
  /// them would mix scales.
  int monthlyTotal(
    List<IncomeSource> sources,
    String yearMonth, {
    CurrencyCode? currency,
  }) {
    final totals = monthlyTotalsByCurrency(sources, yearMonth);
    if (currency == null) {
      // No currency asked for: only meaningful when every source agrees.
      if (totals.length != 1) return 0;
      return totals.values.first;
    }
    return totals[currency] ?? 0;
  }

  /// The monthly totals in [yearMonth], keyed by currency.
  ///
  /// One entry per currency, so a user who earns in both forints and dollars
  /// sees two honest numbers instead of one broken one.
  Map<CurrencyCode, int> monthlyTotalsByCurrency(
    List<IncomeSource> sources,
    String yearMonth,
  ) {
    final parts = yearMonth.split('-');
    if (parts.length != 2) return const {};
    final year = int.tryParse(parts[0]) ?? 0;
    final month = int.tryParse(parts[1]) ?? 0;
    if (year == 0 || month == 0) return const {};

    final totals = <CurrencyCode, int>{};
    for (final source in sources) {
      if (!_isActiveInMonth(source, year, month)) continue;
      final contribution = _contribution(source, year, month);
      if (contribution == 0) continue;
      final currency = currencyOf(source);
      if (currency == null) continue;
      totals[currency] = (totals[currency] ?? 0) + contribution;
    }
    return totals;
  }

  /// The currency of [source], or `null` when the stored code is not one the
  /// app supports.
  ///
  /// An unsupported code is skipped rather than re-coded: the raw record stays
  /// untouched and simply does not contribute to a total (FR-021).
  CurrencyCode? currencyOf(IncomeSource source) =>
      CurrencyCode.tryParse(source.currency);

  /// Whether [source] carries a usable amount and a supported currency.
  bool isValid(IncomeSource source) {
    if (source.amount < 0) return false;
    if (currencyOf(source) == null) return false;
    if (source.name.trim().isEmpty) return false;
    return true;
  }

  bool _isActiveInMonth(IncomeSource source, int year, int month) {
    if (source.startDate != null) {
      final start = source.startDate!;
      if (year < start.year || (year == start.year && month < start.month)) {
        return false;
      }
    }
    if (source.endDate != null) {
      final end = source.endDate!;
      if (year > end.year || (year == end.year && month > end.month)) {
        return false;
      }
    }
    return true;
  }

  int _contribution(IncomeSource source, int year, int month) {
    switch (source.frequency) {
      case IncomeFrequency.oneTime:
        final start = source.startDate;
        if (start == null || start.year != year || start.month != month) {
          return 0;
        }
        return source.amount;
      case IncomeFrequency.weekly:
        return source.amount * 4;
      case IncomeFrequency.monthly:
        return source.amount;
      case IncomeFrequency.quarterly:
        final startMonth = source.startDate?.month ?? 1;
        if ((month - startMonth) % 3 != 0) return 0;
        return source.amount;
      case IncomeFrequency.yearly:
        final startMonth = source.startDate?.month ?? 1;
        if (month != startMonth) return 0;
        return source.amount;
    }
  }
}
