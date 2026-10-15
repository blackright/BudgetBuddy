import '../models/currency_code.dart';
import '../models/money.dart';

/// Where a rate table came from — carried on every conversion result so the
/// UI can label it (contract currency-conversion §1).
///
/// The live table's provider fetch is recorded as [live] (the contract's name
/// for it); everything else matches the seal's stored source values in
/// data-model §2.1.
enum RateSource {
  /// Fetched live from the rate provider for the current month.
  live,

  /// Fetched for a specific past month's close date.
  historical,

  /// A previous fetch reused because history could not be retrieved.
  lastKnown,

  /// Bundled first-launch table shipped in the binary (research R11).
  bundled,
}

/// One immutable four-currency rate table referenced to USD:
/// `usdRates[currency]` = units of `currency` per 1 USD (data-model §2.1).
///
/// Never persisted directly here — [MonthRateSeal] and [LiveRateSet] store the
/// four columns and hand out tables through this value object.
class RateTable {
  RateTable({
    required this.usdRates,
    required this.asOf,
    required this.fetchedAt,
    required this.source,
    this.isStale = false,
  });

  /// Builds a table, validating the invariants every seal row must satisfy:
  /// all four codes present, every rate > 0 and finite. Returns `null` when
  /// the input cannot satisfy them — a bad table is refused, never repaired
  /// into something plausible (FR-014).
  static RateTable? tryCreate({
    required Map<CurrencyCode, double> usdRates,
    required DateTime asOf,
    required DateTime fetchedAt,
    required RateSource source,
    bool isStale = false,
  }) {
    if (usdRates.length != CurrencyCode.values.length) return null;
    for (final code in CurrencyCode.values) {
      final rate = usdRates[code];
      if (rate == null || !rate.isFinite || rate <= 0) return null;
    }
    return RateTable(
      usdRates: Map.unmodifiable(usdRates),
      asOf: asOf,
      fetchedAt: fetchedAt,
      source: source,
      isStale: isStale,
    );
  }

  /// Units per 1 USD for each supported currency (`usd` ≡ 1).
  final Map<CurrencyCode, double> usdRates;

  /// The date the rates represent (seal close date / provider date).
  final DateTime asOf;

  /// When this table was obtained.
  final DateTime fetchedAt;

  /// Provenance, for labelling.
  final RateSource source;

  /// Live table older than 24h or last refresh failed (contract §1).
  final bool isStale;

  /// USD ≡ 1 by construction; the stored column exists so seals round-trip.
  double usdRate(CurrencyCode code) => usdRates[code] ?? 1.0;

  /// Major-to-major cross-rate `from → to`: `usdRate[to] / usdRate[from]`.
  ///
  /// `null` when either side is missing — callers must surface a degraded
  /// result rather than invent a 1.0 (FR-014).
  double? crossRate(CurrencyCode from, CurrencyCode to) {
    if (from == to) return 1.0;
    final sourceRate = usdRates[from];
    final targetRate = usdRates[to];
    if (sourceRate == null ||
        targetRate == null ||
        !sourceRate.isFinite ||
        !targetRate.isFinite ||
        sourceRate <= 0 ||
        targetRate <= 0) {
      return null;
    }
    return targetRate / sourceRate;
  }
}

/// The outcome of converting [Money] into another currency against a
/// [RateTable] (contract `currency-conversion.md` §2).
///
/// A degraded result never carries a substituted `1.0`: [rate] is `null`,
/// [amount] is returned untouched in its original currency, and the caller is
/// obliged to render an unreliable label (FR-014).
class ConversionResult {
  const ConversionResult({
    required this.amount,
    required this.rate,
    required this.source,
    required this.asOf,
    required this.isStale,
    required this.isDegraded,
  });

  /// The converted amount, or the original money when [isDegraded].
  final Money amount;

  /// `usdRate[to] / usdRate[from]`, or `null` when degraded.
  final double? rate;

  /// Provenance of the table used, or `null` when there was none.
  final RateSource? source;

  /// The date the rates represent, or `null` when there was no table.
  final DateTime? asOf;

  /// Live table older than the 24h window (contract §1).
  final bool isStale;

  /// True when no valid table backed the conversion — surface, never hide.
  final bool isDegraded;

  @override
  String toString() =>
      'ConversionResult(${amount.minorUnits} ${amount.currency.code}, '
      'rate: $rate, source: ${source?.name}, degraded: $isDegraded)';
}
