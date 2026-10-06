import 'package:isar/isar.dart';

import '../network/rate_types.dart';
import 'currency_code.dart';

part 'live_rate_set.g.dart';

/// The current month's rate table: a device-global singleton (one row, id 1)
/// refreshed at most once per 24h (data-model §2.2).
///
/// Currency data is not user-private, so this row is shared by every profile
/// (Constitution A2). Once a month seals, it never reads this row again.
@collection
class LiveRateSet {
  /// Fixed id — every put overwrites the same row, keeping the singleton.
  Id id = 1;

  /// Rates vs USD: units of the currency per 1 USD (`ratesUsd ≡ 1`).
  double ratesUsd = 1.0;
  double ratesHuf = 0.0;
  double ratesEur = 0.0;
  double ratesCad = 0.0;

  /// When the table was obtained; `null` before the first-ever fetch.
  DateTime? fetchedAt;

  @enumerated
  RateSource source = RateSource.bundled;

  /// True when `fetchedAt` is older than 24h or the last refresh failed
  /// (data-model §2.2) — surfaced as the "rates last updated" label.
  bool stale = false;

  /// The stored table, or `null` when it violates the invariants (e.g. a row
  /// that has never been seeded) — readers then degrade instead of fabricating.
  RateTable? toRateTable() {
    final at = fetchedAt;
    if (at == null) return null;
    return RateTable.tryCreate(
      usdRates: usdRatesMap(),
      asOf: at,
      fetchedAt: at,
      source: source,
      isStale: stale,
    );
  }

  /// Seeds this row from a validated table.
  void apply(RateTable table) {
    applyUsdRates(table.usdRates);
    fetchedAt = table.fetchedAt;
    source = table.source;
    stale = table.isStale;
  }

  /// The four USD-based rates as a map (derived view — not a stored column).
  Map<CurrencyCode, double> usdRatesMap() => {
        CurrencyCode.usd: ratesUsd,
        CurrencyCode.huf: ratesHuf,
        CurrencyCode.eur: ratesEur,
        CurrencyCode.cad: ratesCad,
      };

  /// Writes a four-rate map back onto the stored columns.
  void applyUsdRates(Map<CurrencyCode, double> rates) {
    ratesUsd = rates[CurrencyCode.usd] ?? 1.0;
    ratesHuf = rates[CurrencyCode.huf] ?? 0.0;
    ratesEur = rates[CurrencyCode.eur] ?? 0.0;
    ratesCad = rates[CurrencyCode.cad] ?? 0.0;
  }
}
