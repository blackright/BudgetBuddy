import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';

/// The active chart filters — transient UI state, never persisted
/// (data-model §4.2).
///
/// Composition rule (FR-012): a `null` field means *no restriction*. Fields
/// combine with AND; the members of a set combine with OR. So
/// `categoryIds: {food, transport}` + `statuses: {paid}` means "food or
/// transport, and paid".
///
/// A value object: two [ChartFilters] with equal fields are equal, so it can be
/// used as a provider key and asserted in tests.
class ChartFilters {
  const ChartFilters({
    this.dateStart,
    this.dateEnd,
    this.categoryIds,
    this.currency,
    this.statuses,
  });

  /// The unrestricted filter — every field `null`, so nothing is excluded.
  static const ChartFilters none = ChartFilters();

  /// Earliest date to include (inclusive), or `null` for no lower bound.
  final DateTime? dateStart;

  /// Latest date to include (inclusive), or `null` for no upper bound.
  final DateTime? dateEnd;

  /// Restrict to these category ids (`null` = all categories).
  final Set<String>? categoryIds;

  /// Override the display currency (`null` = the context's display currency).
  final CurrencyCode? currency;

  /// Restrict to these statuses (`null` = all statuses).
  final Set<ExpenseStatus>? statuses;

  /// Whether every field is unrestricted.
  bool get isEmpty =>
      dateStart == null &&
      dateEnd == null &&
      categoryIds == null &&
      currency == null &&
      statuses == null;

  /// Whether [categoryId] passes the category restriction.
  bool permitsCategory(String categoryId) =>
      categoryIds == null || categoryIds!.contains(categoryId);

  /// Whether [status] passes the status restriction.
  bool permitsStatus(ExpenseStatus status) =>
      statuses == null || statuses!.contains(status);

  /// Whether [date] falls inside the configured range (both bounds inclusive).
  bool permitsDate(DateTime date) {
    if (dateStart != null && date.isBefore(dateStart!)) return false;
    if (dateEnd != null && date.isAfter(dateEnd!)) return false;
    return true;
  }

  /// A copy with the given fields replaced.
  ///
  /// A `null` argument leaves that field unchanged, so a restriction is clear
  /// only by constructing a fresh [ChartFilters] (or via [none]) — which keeps
  /// "clear this filter" an explicit act rather than a typo.
  ChartFilters copyWith({
    DateTime? dateStart,
    DateTime? dateEnd,
    Set<String>? categoryIds,
    CurrencyCode? currency,
    Set<ExpenseStatus>? statuses,
  }) =>
      ChartFilters(
        dateStart: dateStart ?? this.dateStart,
        dateEnd: dateEnd ?? this.dateEnd,
        categoryIds: categoryIds ?? this.categoryIds,
        currency: currency ?? this.currency,
        statuses: statuses ?? this.statuses,
      );

  @override
  bool operator ==(Object other) =>
      other is ChartFilters &&
      other.dateStart == dateStart &&
      other.dateEnd == dateEnd &&
      other.currency == currency &&
      _setEquals(other.categoryIds, categoryIds) &&
      _setEquals(other.statuses, statuses);

  @override
  int get hashCode => Object.hash(
        dateStart,
        dateEnd,
        currency,
        categoryIds == null ? null : Object.hashAllUnordered(categoryIds!),
        statuses == null ? null : Object.hashAllUnordered(statuses!),
      );

  static bool _setEquals<T>(Set<T>? a, Set<T>? b) {
    if (a == null) return b == null;
    if (b == null) return false;
    return a.length == b.length && a.containsAll(b);
  }
}
