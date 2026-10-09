import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../core/database/isar_helper.dart';
import '../../core/models/live_rate_set.dart';
import '../../core/models/month_rate_seal.dart';
import '../../core/models/monthly_budget.dart';
import '../../core/network/baseline_rates.dart';
import '../../core/network/exchange_rate_client.dart';
import '../../core/network/rate_types.dart';
import '../../core/providers/selected_month_provider.dart';

/// The device-global singleton that turns closed calendar months into immutable
/// rate "seals" (contract `month-seal-lifecycle.md`).
///
/// One idempotent [runSealPass] runs on cold start and on `resumed`: it freezes
/// every completed month it can, upgrades `provisional` seals inside their
/// 7-day grace, and keeps the current live table fresh (≤ 1 fetch/24h). It never
/// awaits network before the first frame (invariant I3) and is safe to call any
/// number of times (invariants I1/I2).
class SealCoordinator {
  SealCoordinator({
    required this.isar,
    required this.client,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// How long a `provisional` seal may still be corrected by a successful
  /// historical fetch before it is frozen as `approximate`.
  static const Duration graceWindow = Duration(days: 7);

  /// The live table is refreshed at most once per this window (FR-005).
  static const Duration liveRefreshWindow = Duration(hours: 24);

  final Isar isar;
  final ExchangeRateClient client;
  final DateTime Function() _clock;

  /// One idempotent pass. [now] defaults to the wall clock but is injectable
  /// so tests can drive the state machine deterministically.
  Future<SealPassResult> runSealPass([DateTime? now]) async {
    final instant = now ?? _clock();
    final liveRefreshed = await _refreshLive(instant);

    final current = currentYearMonth(instant);
    final months = await _eligibleMonths(current);

    final sealed = <String>[];
    final provisional = <String>[];
    final approximate = <String>[];

    for (final yearMonth in months) {
      final status = await _sealMonth(yearMonth, instant);
      switch (status) {
        case SealStatus.sealed:
          sealed.add(yearMonth);
        case SealStatus.provisional:
          provisional.add(yearMonth);
        case SealStatus.approximate:
          approximate.add(yearMonth);
        case SealStatus.open:
        case null:
          break;
      }
    }

    return SealPassResult(
      sealedMonths: sealed,
      provisionalMonths: provisional,
      approximateMonths: approximate,
      liveRefreshed: liveRefreshed,
    );
  }

  /// Seals the month that just ended. Present in the contract for the calendar
  /// roll-over path; [runSealPass] already covers it, so this is a thin wrapper.
  Future<SealStatus?> closeCurrentMonth([DateTime? now]) {
    final instant = now ?? _clock();
    return _sealMonth(shiftMonth(currentYearMonth(instant), -1), instant);
  }

  /// Seals/upgrades [yearMonth]. Returns the resulting status, or `null` when
  /// the row was already final and therefore left untouched (invariant I2).
  Future<SealStatus?> _sealMonth(String yearMonth, DateTime now) async {
    final existing = await _find(yearMonth);
    if (existing != null &&
        (existing.status == SealStatus.sealed ||
            existing.status == SealStatus.approximate)) {
      return null; // immutable — a seal is written once (FR-006, I2)
    }

    final snapshot = await client.fetchHistorical(_closeDate(yearMonth));
    if (snapshot != null) {
      final row = existing ?? (MonthRateSeal()..yearMonth = yearMonth);
      row
        ..status = SealStatus.sealed
        ..source = RateSource.historical
        ..applyUsdRates(snapshot.usdRates)
        ..asOf = snapshot.asOf
        ..fetchedAt = snapshot.fetchedAt
        ..closedAt = existing?.closedAt ?? now
        ..updatedAt = now;
      await _writeSeal(row);
      return SealStatus.sealed;
    }

    // Fetch failed: fall back to last-known rates, never fabricated (I4).
    final reference = existing?.closedAt ?? _closeDate(yearMonth);
    final withinGrace = now.difference(reference).inDays <= graceWindow.inDays;

    if (existing != null) {
      // A provisional row: retry until the grace window closes, then freeze.
      if (withinGrace) {
        existing
          ..attemptCount += 1
          ..updatedAt = now;
        await _writeSeal(existing);
        return SealStatus.provisional;
      }
      existing
        ..status = SealStatus.approximate
        ..attemptCount += 1
        ..updatedAt = now;
      await _writeSeal(existing);
      return SealStatus.approximate;
    }

    // No row yet: create the first seal from the best available offline rates.
    final fallback = await _lastKnownTable();
    final row = MonthRateSeal()
      ..yearMonth = yearMonth
      ..status = withinGrace ? SealStatus.provisional : SealStatus.approximate
      ..applyUsdRates(fallback.usdRates)
      ..asOf = fallback.asOf
      ..fetchedAt = fallback.fetchedAt
      ..source = fallback.source
      ..closedAt = withinGrace ? now : null
      ..attemptCount = 1
      ..updatedAt = now;
    await _writeSeal(row);
    return row.status;
  }

  /// Refresh the live singleton when absent or older than [liveRefreshWindow].
  /// Returns `true` when a new table was fetched.
  Future<bool> _refreshLive(DateTime now) async {
    final existing = await isar.liveRateSets.where().findFirst();
    final fetchedAt = existing?.fetchedAt;
    if (fetchedAt != null && now.difference(fetchedAt) < liveRefreshWindow) {
      return false;
    }

    final snapshot = await client.fetchLatest();
    if (snapshot == null) {
      // Downgrade the label, never the data (I4).
      if (existing != null && !existing.stale) {
        existing.stale = true;
        await _writeLive(existing);
      }
      return false;
    }

    final row = existing ?? LiveRateSet();
    row
      ..applyUsdRates(snapshot.usdRates)
      ..fetchedAt = snapshot.fetchedAt
      ..source = RateSource.live
      ..stale = false;
    await _writeLive(row);
    return true;
  }

  /// Every calendar month before [current] that needs a seal (no row, or a
  /// `provisional` row still eligible for upgrade), from the earliest month with
  /// recorded data. Bounded so a long-lived database cannot loop forever.
  Future<List<String>> _eligibleMonths(String current) async {
    final budgets = await isar.monthlyBudgets.where().findAll();
    String? earliest;
    for (final budget in budgets) {
      final ym = budget.yearMonth;
      if (ym.isEmpty) continue;
      if (earliest == null || ym.compareTo(earliest) < 0) earliest = ym;
    }
    if (earliest == null) return const [];

    final months = <String>[];
    var yearMonth = earliest;
    var guard = 0;
    while (yearMonth.compareTo(current) < 0 && guard < 1200) {
      final existing = await _find(yearMonth);
      if (existing == null || existing.status == SealStatus.provisional) {
        months.add(yearMonth);
      }
      yearMonth = shiftMonth(yearMonth, 1);
      guard++;
    }
    return months;
  }

  /// Best offline table: the live singleton's rates re-labelled `lastKnown`, or
  /// the bundled baseline when nothing is persisted.
  Future<RateTable> _lastKnownTable() async {
    final live = await isar.liveRateSets.where().findFirst();
    final table = live?.toRateTable();
    if (table != null) {
      return RateTable(
        usdRates: table.usdRates,
        asOf: table.asOf,
        fetchedAt: table.fetchedAt,
        source: RateSource.lastKnown,
      );
    }
    return RateTable(
      usdRates: Map.unmodifiable(kBundledUsdRates),
      asOf: DateTime.utc(2000),
      fetchedAt: DateTime.utc(2000),
      source: RateSource.bundled,
    );
  }

  Future<MonthRateSeal?> _find(String yearMonth) =>
      isar.monthRateSeals.filter().yearMonthEqualTo(yearMonth).findFirst();

  Future<void> _writeSeal(MonthRateSeal row) =>
      isar.writeTxn(() => isar.monthRateSeals.put(row));

  Future<void> _writeLive(LiveRateSet row) =>
      isar.writeTxn(() => isar.liveRateSets.put(row));

  /// The last calendar day of [yearMonth], used as the historical close date.
  DateTime _closeDate(String yearMonth) {
    final parts = yearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    return DateTime(year, month + 1, 0);
  }
}

/// The outcome of one coordinator pass — drives the banner/badge projection.
class SealPassResult {
  const SealPassResult({
    this.sealedMonths = const [],
    this.provisionalMonths = const [],
    this.approximateMonths = const [],
    this.liveRefreshed = false,
  });

  final List<String> sealedMonths;
  final List<String> provisionalMonths;
  final List<String> approximateMonths;
  final bool liveRefreshed;

  bool get changed =>
      sealedMonths.isNotEmpty ||
      provisionalMonths.isNotEmpty ||
      approximateMonths.isNotEmpty ||
      liveRefreshed;
}

/// Device-global coordinator: Isar + the Frankfurter client.
final sealCoordinatorProvider = Provider<SealCoordinator>((ref) {
  return SealCoordinator(
    isar: IsarHelper.instance,
    client: ref.watch(exchangeRateClientProvider),
  );
});
