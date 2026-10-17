import '../../../core/models/expense.dart';
import '../../../core/models/shared_member.dart';
import '../repositories/analytics_repository.dart';
import 'chart_series.dart';

/// The pure aggregation layer — the "One Chart Brain"
/// (contracts/chart-data.md §4).
///
/// Every function here takes a ready-made [AnalyticsSnapshot] and returns one
/// [ChartSeries]. They are DB-free, clock-free and currency-free: no chart
/// queries Isar or calls `convert` itself (FR-001), which is exactly why every
/// chart that could show a figure does show the same one (SC-001).
///
/// Normalization already happened in `AnalyticsRepository`, so all that
/// happens here is filtering, grouping and summing whole minor units.

/// Expenses that count toward spending: every status except cancelled.
///
/// Cancelled money was never spent, so it reaches no spending figure — and
/// because both [spendingSeries] and [categorySeries] apply this same rule,
/// their totals agree by construction (Constitution IV, SC-001).
bool _spends(Expense expense) => expense.status != ExpenseStatus.cancelled;

/// The rows a chart considers: the "not cancelled" rule plus the user's
/// [ChartFilters], which compose as AND across fields (FR-012).
List<NormalizedExpense> _rows(AnalyticsSnapshot snapshot) => [
      for (final row in snapshot.expenses)
        if (_spends(row.expense) &&
            snapshot.filters.permitsCategory(row.expense.categoryId) &&
            snapshot.filters.permitsStatus(row.expense.status) &&
            snapshot.filters.permitsDate(row.expense.date))
          row,
    ];

/// Sum of the rows' normalized values, in the snapshot's display currency.
///
/// Excluded rows carry `0`, so they drop out of the total here rather than
/// being counted as a real zero (FR-005).
int _sum(List<NormalizedExpense> rows) =>
    rows.fold<int>(0, (total, row) => total + row.amount.minorUnits);

int _excludedCount(List<NormalizedExpense> rows) =>
    rows.where((row) => row.amount.excluded).length;

/// Non-null when the total cannot honestly be shown as complete: some rows
/// were dropped for want of a rate, or the governing table is stale.
ChartDegradedState? _degraded(AnalyticsSnapshot snapshot, int excluded) {
  if (excluded == 0 && !snapshot.isStale) return null;
  return ChartDegradedState(
    isStale: snapshot.isStale,
    hasMissingRates: excluded > 0,
  );
}

/// How one expense should be classified by [plannedPaidSeries]: money that has
/// actually left versus money still only committed. Cancelled rows never reach
/// this helper (see [_spends]).
// _paidStatus intentionally unused; plannedPaidSeries reads status directly.

/// Neutral slice colour for a category the seed set has not defined yet.
const int _fallbackColor = 0xFF9E9E9E;

/// Fixed colours for the two medical payers — the split is a stable pair, so a
/// constant colour keeps the legend readable across months.
const int _insurerColor = 0xFF42A5F5;
const int _patientColor = 0xFFFFA726;

/// Fixed colours for the personal/shared comparison.
const int _personalColor = 0xFF7E57C2;
const int _sharedColor = 0xFF26A69A;

/// A small, ordered palette for member slices, cycled when a space has more
/// members than colours (contracts/chart-data.md §4.2).
const List<int> _memberPalette = [
  0xFF42A5F5,
  0xFFEF5350,
  0xFF66BB6A,
  0xFFFFA726,
  0xFFAB47BC,
  0xFF26C6DA,
  0xFF8D6E63,
  0xFFEC407A,
];

/// Months of the year, short form, used as axis labels.
const List<String> _shortMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// The bucket granularity a date range is drawn at (research R7).
enum _BucketMode { day, week, month }

/// Spending over time, one point per bucket (FR-015).
///
/// Range length decides the bucket size so the point count stays bounded no
/// matter how far back the user looks: a month or less → per day, up to six
/// months → per week, beyond that → per month.
ChartSeries spendingSeries(AnalyticsSnapshot snapshot) {
  final rows = _rows(snapshot);
  if (rows.isEmpty) {
    return ChartSeries.empty(ChartKind.spending, snapshot.displayCurrency);
  }
  final excluded = _excludedCount(rows);
  return ChartSeries(
    kind: ChartKind.spending,
    currency: snapshot.displayCurrency,
    total: _sum(rows),
    isEmpty: false,
    buckets: _bucket(rows),
    degraded: _degraded(snapshot, excluded),
    excludedCount: excluded,
  );
}

/// Spending grouped by category, one slice per category.
///
/// The total is taken from the same row set [spendingSeries] uses, so the two
/// charts cannot disagree (SC-001). Slices are sorted largest-first for a
/// sensible legend, and categories holding only cancelled money get no slice.
ChartSeries categorySeries(AnalyticsSnapshot snapshot) {
  final rows = _rows(snapshot);
  if (rows.isEmpty) {
    return ChartSeries.empty(ChartKind.category, snapshot.displayCurrency);
  }

  final totals = <String, int>{};
  for (final row in rows) {
    final id = row.expense.categoryId;
    totals[id] = (totals[id] ?? 0) + row.amount.minorUnits;
  }

  final total = _sum(rows);
  final slices = [
    for (final entry in totals.entries)
      CategorySlice(
        categoryId: entry.key,
        label: snapshot.categories[entry.key]?.name ?? entry.key,
        emoji: snapshot.categories[entry.key]?.emoji ?? '',
        colorValue:
            snapshot.categories[entry.key]?.colorValue ?? _fallbackColor,
        minorUnits: entry.value,
        fraction: total == 0 ? 0 : entry.value / total,
      ),
  ]..sort((a, b) => b.minorUnits.compareTo(a.minorUnits));

  final excluded = _excludedCount(rows);
  return ChartSeries(
    kind: ChartKind.category,
    currency: snapshot.displayCurrency,
    total: total,
    isEmpty: false,
    slices: slices,
    degraded: _degraded(snapshot, excluded),
    excludedCount: excluded,
  );
}

/// Planned versus paid, one bar per category (Constitution IV).
///
/// The two figures are summed from disjoint status sets — planned never
/// reaches the paid figure and cancelled reaches neither — so "what we still
/// owe" and "what we already spent" can never blur together. The series
/// headline [ChartSeries.total] is the **paid** sum.
ChartSeries plannedPaidSeries(AnalyticsSnapshot snapshot) {
  final rows = _rows(snapshot);
  if (rows.isEmpty) {
    return ChartSeries.empty(ChartKind.plannedPaid, snapshot.displayCurrency);
  }

  final planned = <String, int>{};
  final paid = <String, int>{};
  for (final row in rows) {
    final id = row.expense.categoryId;
    if (row.expense.status == ExpenseStatus.planned) {
      planned[id] = (planned[id] ?? 0) + row.amount.minorUnits;
    } else {
      paid[id] = (paid[id] ?? 0) + row.amount.minorUnits;
    }
  }

  final ids = <String>{...planned.keys, ...paid.keys};
  final bars = [
    for (final id in ids)
      BarPair(
        label: snapshot.categories[id]?.name ?? id,
        plannedMinorUnits: planned[id] ?? 0,
        paidMinorUnits: paid[id] ?? 0,
      ),
  ]..sort((a, b) => (b.plannedMinorUnits + b.paidMinorUnits)
      .compareTo(a.plannedMinorUnits + a.paidMinorUnits));

  final excluded = _excludedCount(rows);
  return ChartSeries(
    kind: ChartKind.plannedPaid,
    currency: snapshot.displayCurrency,
    total: paid.values.fold<int>(0, (total, value) => total + value),
    isEmpty: false,
    bars: bars,
    degraded: _degraded(snapshot, excluded),
    excludedCount: excluded,
  );
}

/// The medical insurer/user split, one slice per payer (US4, data-model §2.2).
///
/// It reuses the split the bill already computes — `patientShareAmount` and
/// `insurerPaidAmount` (Constitution IV) rather than recomputing it — and counts
/// only bills whose money has actually been incurred (`state != planned`, see
/// `MedicalBill.countsAsPaid`). Both slices are always emitted so the total
/// always equals their sum (SC-001); a payer owed nothing simply shows zero.
/// A bill whose currency could not be converted is excluded and disclosed, never
/// zeroed (FR-005).
ChartSeries insuranceSeries(AnalyticsSnapshot snapshot) {
  final bills = [
    for (final bill in snapshot.medicalBills)
      if (bill.bill.countsAsPaid) bill,
  ];
  if (bills.isEmpty) {
    return ChartSeries.empty(ChartKind.insurance, snapshot.displayCurrency);
  }

  var insurer = 0;
  var patient = 0;
  var excluded = 0;
  for (final bill in bills) {
    if (bill.insurerPaid.excluded || bill.patientShare.excluded) {
      excluded++;
      continue;
    }
    insurer += bill.insurerPaid.minorUnits;
    patient += bill.patientShare.minorUnits;
  }

  final total = insurer + patient;
  if (total == 0) {
    return ChartSeries.empty(ChartKind.insurance, snapshot.displayCurrency);
  }

  return ChartSeries(
    kind: ChartKind.insurance,
    currency: snapshot.displayCurrency,
    total: total,
    isEmpty: false,
    slices: [
      CategorySlice(
        categoryId: 'insurer',
        label: 'Insurer paid',
        emoji: '',
        colorValue: _insurerColor,
        minorUnits: insurer,
        fraction: insurer / total,
      ),
      CategorySlice(
        categoryId: 'patient',
        label: 'You pay',
        emoji: '',
        colorValue: _patientColor,
        minorUnits: patient,
        fraction: patient / total,
      ),
    ],
    degraded: _degraded(snapshot, excluded),
    excludedCount: excluded,
  );
}

/// Each shared member's net contribution, one slice per member (US4, FR-011).
///
/// It groups the shared rows by their owning `profileId`, joins the membership's
/// role, and lists **every** member of the space — including those who
/// contributed nothing — ordered by net contribution descending
/// (contracts/chart-data.md §4.2). A synced member whose profile is absent
/// locally still contributed money, so it is kept and given a fallback label;
/// only the label falls back, never a total.
///
/// Slices carry a **net** figure (`expenses − reimbursements`), which may be
/// negative; the contribution chart therefore renders them as bars, where a
/// negative is meaningful, rather than as a pie.
///
/// [profileNames] maps a member's profile id to a display name; it is injected
/// by the data layer so this pure function never reaches for names itself. A
/// member missing from the map keeps a stable fallback label.
ChartSeries contributionSeries(
  AnalyticsSnapshot snapshot, {
  Map<int, String> profileNames = const {},
}) {
  final expenseByMember = <int, int>{};
  final reimbursementByMember = <int, int>{};
  var excluded = 0;

  for (final row in _rows(snapshot)) {
    final profileId = row.expense.profileId;
    expenseByMember[profileId] =
        (expenseByMember[profileId] ?? 0) + row.amount.minorUnits;
    if (row.amount.excluded) excluded++;
  }
  for (final row in snapshot.reimbursements) {
    if (!snapshot.filters.permitsDate(row.reimbursement.date)) continue;
    final profileId = row.reimbursement.profileId;
    reimbursementByMember[profileId] =
        (reimbursementByMember[profileId] ?? 0) + row.amount.minorUnits;
    if (row.amount.excluded) excluded++;
  }

  final ids = <int>{
    for (final member in snapshot.members)
      if (member.revokedAt == null) member.profileId,
    ...expenseByMember.keys,
    ...reimbursementByMember.keys,
  };
  if (ids.isEmpty) {
    return ChartSeries.empty(ChartKind.contribution, snapshot.displayCurrency);
  }

  final contributions = [
    for (final id in ids)
      () {
        final spent = expenseByMember[id] ?? 0;
        final returned = reimbursementByMember[id] ?? 0;
        return MemberContribution(
          profileId: id,
          displayName: profileNames[id] ?? 'Member $id',
          role: _roleFor(snapshot.members, id),
          sharedExpenseMinorUnits: spent,
          sharedReimbursementMinorUnits: returned,
          netContributionMinorUnits: spent - returned,
          fraction: 0,
        );
      }(),
  ]..sort(
      (a, b) =>
          b.netContributionMinorUnits.compareTo(a.netContributionMinorUnits),
    );

  final total = contributions.fold<int>(
    0,
    (sum, contribution) => sum + contribution.netContributionMinorUnits,
  );
  final positiveTotal = contributions.fold<int>(
    0,
    (sum, contribution) =>
        sum +
        (contribution.netContributionMinorUnits > 0
            ? contribution.netContributionMinorUnits
            : 0),
  );

  final slices = [
    for (var i = 0; i < contributions.length; i++)
      CategorySlice(
        categoryId: 'member:${contributions[i].profileId}',
        label: contributions[i].displayName,
        emoji: '',
        colorValue: _memberPalette[i % _memberPalette.length],
        minorUnits: contributions[i].netContributionMinorUnits,
        // The bar length reads against the largest positive contribution, so a
        // zero contributor stays visible and a negative one points the other way.
        fraction: positiveTotal == 0
            ? 0
            : contributions[i].netContributionMinorUnits / positiveTotal,
      ),
  ];

  return ChartSeries(
    kind: ChartKind.contribution,
    currency: snapshot.displayCurrency,
    total: total,
    isEmpty: false,
    slices: slices,
    degraded: _degraded(snapshot, excluded),
    excludedCount: excluded,
  );
}

/// Shared spending versus the active profile's personal spending (US4).
///
/// It compares two already context-scoped snapshots that were normalized into
/// the **same** display currency (the space's), so the two parts can be added
/// honestly (FR-004). [ChartSeries.total] is their combined figure and the two
/// slices are its parts, so the total always equals the sum of its slices
/// (SC-001); a side with no spending shows a zero slice rather than vanishing.
ChartSeries sharedVsPersonalSeries(
  AnalyticsSnapshot shared,
  AnalyticsSnapshot personal,
) {
  final sharedRows = _rows(shared);
  final personalRows = _rows(personal);
  final sharedTotal = _sum(sharedRows);
  final personalTotal = _sum(personalRows);
  final combined = sharedTotal + personalTotal;

  if (combined == 0) {
    return ChartSeries.empty(
      ChartKind.sharedVsPersonal,
      shared.displayCurrency,
    );
  }

  final excluded = _excludedCount(sharedRows) + _excludedCount(personalRows);
  return ChartSeries(
    kind: ChartKind.sharedVsPersonal,
    currency: shared.displayCurrency,
    total: combined,
    isEmpty: false,
    slices: [
      CategorySlice(
        categoryId: 'personal',
        label: 'Personal',
        emoji: '',
        colorValue: _personalColor,
        minorUnits: personalTotal,
        fraction: personalTotal / combined,
      ),
      CategorySlice(
        categoryId: 'shared',
        label: 'Shared',
        emoji: '',
        colorValue: _sharedColor,
        minorUnits: sharedTotal,
        fraction: sharedTotal / combined,
      ),
    ],
    degraded: _degraded(shared, excluded),
    excludedCount: excluded,
  );
}

/// The role a member holds in [members], or a viewer fallback when their
/// membership row is absent locally (a synced member). Label-only.
SharedMemberRole _roleFor(List<SharedMember> members, int profileId) {
  for (final member in members) {
    if (member.profileId == profileId) return member.role;
  }
  return SharedMemberRole.viewer;
}

/// Available amount over the month, one point per active day (US2, FR-016).
///
/// It counts down from the month's opening available amount
/// ([AnalyticsSnapshot.openingAvailableMinorUnits]): every expense whose money
/// has actually left (paid / reimbursed / partially reimbursed) lowers it, and
/// every reimbursement lifts it back — the same rule `trueAvailableProvider`
/// uses, so the trend and the Dashboard agree on what "available" means.
///
/// It is cumulative: each bucket holds the running balance up to and including
/// that day, so the line reads as "what is left over time".
ChartSeries availableTrendSeries(AnalyticsSnapshot snapshot) {
  final paidRows = [
    for (final row in snapshot.expenses)
      if (_paid(row.expense) &&
          snapshot.filters.permitsCategory(row.expense.categoryId) &&
          snapshot.filters.permitsStatus(row.expense.status) &&
          snapshot.filters.permitsDate(row.expense.date))
        row,
  ];
  final reimbursementRows = [
    for (final row in snapshot.reimbursements)
      if (snapshot.filters.permitsDate(row.reimbursement.date)) row,
  ];

  if (paidRows.isEmpty && reimbursementRows.isEmpty) {
    return ChartSeries.empty(
      ChartKind.availableTrend,
      snapshot.displayCurrency,
    );
  }

  final deltas = <DateTime, int>{};
  final counts = <DateTime, int>{};
  for (final row in paidRows) {
    final day = _day(row.expense.date);
    deltas[day] = (deltas[day] ?? 0) - row.amount.minorUnits;
    counts[day] = (counts[day] ?? 0) + 1;
  }
  for (final row in reimbursementRows) {
    final day = _day(row.reimbursement.date);
    deltas[day] = (deltas[day] ?? 0) + row.amount.minorUnits;
    counts[day] = (counts[day] ?? 0) + 1;
  }

  final days = deltas.keys.toList()..sort();
  var running = snapshot.openingAvailableMinorUnits;
  final buckets = [
    for (final day in days)
      () {
        running += deltas[day]!;
        return DayBucket(
          label: '${day.day}',
          minorUnits: running,
          date: day,
          pointCount: counts[day]!,
        );
      }(),
  ];

  final excluded = _excludedCount(paidRows) +
      reimbursementRows.where((row) => row.amount.excluded).length;
  return ChartSeries(
    kind: ChartKind.availableTrend,
    currency: snapshot.displayCurrency,
    total: running,
    isEmpty: false,
    buckets: buckets,
    degraded: _degraded(snapshot, excluded),
    excludedCount: excluded,
  );
}

/// Whether an expense has actually moved money out of the wallet — the rule
/// [availableTrendSeries] shares with `trueAvailableProvider` (FR-011).
bool _paid(Expense expense) =>
    expense.status == ExpenseStatus.paid ||
    expense.status == ExpenseStatus.reimbursed ||
    expense.status == ExpenseStatus.partiallyReimbursed;

/// Midnight of [date]'s day — the stable key for one trend bucket.
DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);

/// Groups [rows] into time buckets at the granularity [_bucket] selected.
List<DayBucket> _bucket(List<NormalizedExpense> rows) {
  var earliest = rows.first.expense.date;
  var latest = earliest;
  for (final row in rows) {
    final date = row.expense.date;
    if (date.isBefore(earliest)) earliest = date;
    if (date.isAfter(latest)) latest = date;
  }

  // Month span of the range, inclusive — a single month is already the
  // finest granularity anyone wants to read.
  final months = (latest.year * 12 + latest.month) -
      (earliest.year * 12 + earliest.month) +
      1;
  final mode = months <= 1
      ? _BucketMode.day
      : months <= 6
          ? _BucketMode.week
          : _BucketMode.month;

  final groups = <DateTime, List<NormalizedExpense>>{};
  for (final row in rows) {
    final key = switch (mode) {
      _BucketMode.day => DateTime(
          row.expense.date.year,
          row.expense.date.month,
          row.expense.date.day,
        ),
      _BucketMode.week => _weekStart(row.expense.date),
      _BucketMode.month => DateTime(
          row.expense.date.year,
          row.expense.date.month,
        ),
    };
    groups.putIfAbsent(key, () => <NormalizedExpense>[]).add(row);
  }

  final keys = groups.keys.toList()..sort();
  return [
    for (final key in keys)
      DayBucket(
        label: _labelFor(mode, key),
        minorUnits: _sum(groups[key]!),
        date: key,
        pointCount: groups[key]!.length,
      ),
  ];
}

/// Monday of [date]'s week — the stable key that keeps a week spanning a month
/// boundary in one bucket.
DateTime _weekStart(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

/// The axis label for one bucket.
String _labelFor(_BucketMode mode, DateTime key) => switch (mode) {
      _BucketMode.day => '${key.day}',
      _BucketMode.week => '${key.day} ${_shortMonths[key.month - 1]}',
      _BucketMode.month => _shortMonths[key.month - 1],
    };
