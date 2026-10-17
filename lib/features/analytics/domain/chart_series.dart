export 'chart_drill_down.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/shared_member.dart';

/// The kinds of chart this feature draws.
///
/// Every chart is described by exactly one [ChartSeries] whose [ChartSeries.kind]
/// names which of these it is, so a renderer can branch without guessing from
/// the payload shape (data-model §3.1).
enum ChartKind {
  /// Monthly spending over time (time-series buckets).
  spending,

  /// Spending grouped by category (proportional slices).
  category,

  /// Planned versus paid amounts (paired bars).
  plannedPaid,

  /// How the available amount moved over the month (time-series buckets).
  availableTrend,

  /// A medical bill split into insurer-paid and user-payable (slices).
  insurance,

  /// Each shared member's net contribution (slices).
  contribution,

  /// Shared versus personal versus combined spending (slices).
  sharedVsPersonal,
}

/// Density and interaction mode for a chart widget.
///
/// A single chart widget renders both modes so the Dashboard and the Analytics
/// tab can never drift apart (contracts/chart-ui.md §1, SC-002): `mini` is the
/// compact, non-interactive Dashboard form, `full` is the labelled, tappable
/// Analytics form.
enum ChartSize {
  /// Compact, label-light, no drill-down (Dashboard).
  mini,

  /// Labelled, legend-bearing, drill-down enabled (Analytics).
  full,
}

/// Why a series could not represent every record, so the UI can disclose it
/// rather than silently show a smaller number (FR-005).
///
/// A non-null [ChartSeries.degraded] means at least one record was converted
/// with a degraded rate. The count of exactly how many is
/// [ChartSeries.excludedCount]; the flags here explain *why*.
class ChartDegradedState {
  const ChartDegradedState({
    this.isStale = false,
    this.hasMissingRates = false,
  });

  /// The rate table used was stale (an old snapshot rather than a fresh fetch).
  final bool isStale;

  /// At least one record's currency had no rate in the table at all.
  final bool hasMissingRates;

  @override
  bool operator ==(Object other) =>
      other is ChartDegradedState &&
      other.isStale == isStale &&
      other.hasMissingRates == hasMissingRates;

  @override
  int get hashCode => Object.hash(isStale, hasMissingRates);
}

/// One proportional segment of a pie/ring chart (category, insurance split,
/// contribution, shared-vs-personal).
class CategorySlice {
  const CategorySlice({
    required this.categoryId,
    required this.label,
    required this.emoji,
    required this.colorValue,
    required this.minorUnits,
    required this.fraction,
    this.statusFilter,
  });

  /// The category key this slice aggregates (or a synthetic key such as
  /// `'insurer'` / `'member:3'`).
  final String categoryId;

  /// Human-readable label.
  final String label;

  /// Emoji shown beside the label (may be empty for synthetic slices).
  final String emoji;

  /// ARGB colour for the slice, taken from `Category.colorValue` or the theme.
  final int colorValue;

  /// This slice's value, in whole minor units of the series currency.
  final int minorUnits;

  /// This slice's share of the series total, in the range 0–1.
  final double fraction;

  /// When set, tapping the slice drills into this expense status.
  final ExpenseStatus? statusFilter;
}

/// One point of a time-series chart, already bucketed (data-model §3.3).
class DayBucket {
  const DayBucket({
    required this.label,
    required this.minorUnits,
    required this.date,
    required this.pointCount,
  });

  /// Axis label for the bucket (e.g. `'10'`, `'W2'`, `'Mar'`).
  final String label;

  /// The bucket's value, in whole minor units of the series currency.
  final int minorUnits;

  /// The bucket's start instant — its sort key.
  final DateTime date;

  /// How many source records fell into this bucket.
  final int pointCount;
}

/// A planned-versus-paid pair for one label (data-model §3.4).
class BarPair {
  const BarPair({
    required this.label,
    required this.plannedMinorUnits,
    required this.paidMinorUnits,
  });

  /// Axis label (e.g. a category name or a month).
  final String label;

  /// What was planned, in whole minor units of the series currency.
  final int plannedMinorUnits;

  /// What was actually paid, in whole minor units of the series currency.
  final int paidMinorUnits;
}

/// One shared member's contribution (data-model §3.5, FR-011).
///
/// Every member of the active space gets a row, including members who
/// contributed nothing ([netContributionMinorUnits] of zero).
class MemberContribution {
  const MemberContribution({
    required this.profileId,
    required this.displayName,
    required this.role,
    required this.sharedExpenseMinorUnits,
    required this.sharedReimbursementMinorUnits,
    required this.netContributionMinorUnits,
    required this.fraction,
  });

  /// The contributing profile's id (`0`/negative reserved for a member whose
  /// profile is not present locally).
  final int profileId;

  /// Display label: the profile name when known, otherwise the membership's
  /// identity label.
  final String displayName;

  /// The member's role in the space.
  final SharedMemberRole role;

  /// What this member's shared expenses add up to, in whole minor units.
  final int sharedExpenseMinorUnits;

  /// What this member's reimbursements add up to, in whole minor units.
  final int sharedReimbursementMinorUnits;

  /// `sharedExpense - sharedReimbursement` — the net figure the chart sorts by.
  final int netContributionMinorUnits;

  /// This member's share of the positive net total, in the range 0–1.
  final double fraction;
}

/// The single data object every chart consumes (data-model §3.1).
///
/// All monetary values are already normalized into [currency], so no chart ever
/// converts or re-aggregates (contracts/chart-data.md §3). A record whose
/// currency could not be converted is excluded from [total] and counted in
/// [excludedCount] — never treated as zero (FR-005).
class ChartSeries {
  const ChartSeries({
    required this.kind,
    required this.currency,
    required this.total,
    required this.isEmpty,
    this.buckets = const [],
    this.slices = const [],
    this.bars = const [],
    this.degraded,
    this.excludedCount = 0,
  });

  /// A series with nothing to draw — the honest empty state (FR-013).
  factory ChartSeries.empty(ChartKind kind, CurrencyCode currency) =>
      ChartSeries(
        kind: kind,
        currency: currency,
        total: 0,
        isEmpty: true,
      );

  /// Which chart this series describes.
  final ChartKind kind;

  /// The display currency every value in this series is denominated in.
  final CurrencyCode currency;

  /// Headline total in whole minor units of [currency].
  final int total;

  /// True when there is nothing to draw; drives the empty state (FR-013).
  final bool isEmpty;

  /// Time-series points (spending, availableTrend).
  final List<DayBucket> buckets;

  /// Proportional segments (category, insurance, contribution,
  /// sharedVsPersonal).
  final List<CategorySlice> slices;

  /// Planned-versus-paid pairs (plannedPaid).
  final List<BarPair> bars;

  /// Non-null when at least one record was converted with a degraded rate.
  final ChartDegradedState? degraded;

  /// How many records were dropped from [total] because their currency could
  /// not be converted.
  final int excludedCount;
}
