import 'package:isar/isar.dart';

import '../network/rate_types.dart';
import 'currency_code.dart';

part 'month_rate_seal.g.dart';

/// Lifecycle of a month's frozen rate table (data-model §3).
///
/// One-way transitions except `provisional → sealed`; sealed and approximate
/// rows are immutable once written (FR-006, contract month-seal-lifecycle §3).
enum SealStatus {
  /// Implicit pre-close state; rows are never stored as `open`.
  open,

  /// Closed while offline: last-known rates, retried for a 7-day grace window.
  provisional,

  /// Final; rates fetched for the month's own close date. Never touched again.
  sealed,

  /// Final with fallback rates (history impossible). Permanent badge; manual
  /// retry from settings only.
  approximate,
}

/// The month seal: one row per calendar month holding that month's frozen
/// four-currency rate table, referenced to USD (data-model §2.1).
///
/// Written by the seal coordinator and never modified by an automatic pass
/// once `sealed`/`approximate` (invariant I2).
@collection
class MonthRateSeal {
  Id id = Isar.autoIncrement;

  /// `YYYY-MM`, unique — exactly one seal per month.
  @Index(unique: true, replace: true)
  late String yearMonth;

  @enumerated
  SealStatus status = SealStatus.open;

  /// Rates vs USD: units of the currency per 1 USD (`ratesUsd ≡ 1`).
  double ratesUsd = 1.0;
  double ratesHuf = 0.0;
  double ratesEur = 0.0;
  double ratesCad = 0.0;

  /// The date the rates represent (close date / business day served).
  late DateTime asOf;

  /// When we obtained them.
  late DateTime fetchedAt;

  @enumerated
  RateSource source = RateSource.historical;

  /// When the month was sealed; `null` while provisional.
  DateTime? closedAt;

  /// Seal/retry attempts — drives retry pacing and settings display (I6).
  int attemptCount = 0;

  /// Last write.
  late DateTime updatedAt;

  /// The frozen table for this month, or `null` if the stored rates somehow
  /// violate the invariants (then readers degrade — never fabricate).
  RateTable? toRateTable() => RateTable.tryCreate(
        usdRates: usdRatesMap(),
        asOf: asOf,
        fetchedAt: fetchedAt,
        source: source,
      );

  /// The four USD-based rates as a map (derived view — not a stored column).
  Map<CurrencyCode, double> usdRatesMap() => {
        CurrencyCode.usd: ratesUsd,
        CurrencyCode.huf: ratesHuf,
        CurrencyCode.eur: ratesEur,
        CurrencyCode.cad: ratesCad,
      };

  /// Writes a validated four-rate map back onto the stored columns.
  void applyUsdRates(Map<CurrencyCode, double> rates) {
    ratesUsd = rates[CurrencyCode.usd] ?? 1.0;
    ratesHuf = rates[CurrencyCode.huf] ?? 0.0;
    ratesEur = rates[CurrencyCode.eur] ?? 0.0;
    ratesCad = rates[CurrencyCode.cad] ?? 0.0;
  }
}
