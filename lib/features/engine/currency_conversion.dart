import '../../core/models/currency_code.dart';
import '../../core/models/money.dart';
import '../../core/network/rate_types.dart';

/// The one pure conversion function (contract `currency-conversion.md` §2).
///
/// Given an [amount] and the [table] that governs its month, returns the
/// amount expressed in [to]. No I/O, no clock, no globals — every caller in
/// the engine goes through this, so the same `(amount, from, to, month)` always
/// maps to the same result.
///
/// Behaviour:
/// - Same currency → `rate = 1.0`, amount unchanged (legitimate, not degraded).
/// - Any other pair → `amount.scaledBy(usdRate[to] / usdRate[from], to)`, the
///   single rounding being half-away-from-zero inside [Money.scaledBy].
/// - A `null` or incomplete table → `isDegraded = true`, amount returned in its
///   original currency, `rate` `null`. A missing rate is **never** reported as
///   `1.0` (FR-014).
ConversionResult convert(
  Money amount,
  CurrencyCode to,
  RateTable? table,
) {
  final from = amount.currency;

  if (from == to) {
    return ConversionResult(
      amount: amount,
      rate: 1.0,
      source: table?.source,
      asOf: table?.asOf,
      isStale: table?.isStale ?? false,
      isDegraded: false,
    );
  }

  if (table == null) {
    return ConversionResult(
      amount: amount,
      rate: null,
      source: null,
      asOf: null,
      isStale: false,
      isDegraded: true,
    );
  }

  final rate = table.crossRate(from, to);
  if (rate == null) {
    return ConversionResult(
      amount: amount,
      rate: null,
      source: table.source,
      asOf: table.asOf,
      isStale: table.isStale,
      isDegraded: true,
    );
  }

  return ConversionResult(
    amount: amount.scaledBy(rate, to),
    rate: rate,
    source: table.source,
    asOf: table.asOf,
    isStale: table.isStale,
    isDegraded: false,
  );
}
