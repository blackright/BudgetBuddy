import 'package:intl/intl.dart';

import '../../core/models/currency_code.dart';
import '../../core/models/money.dart';

/// The single money formatter in the app (FR-018, contract
/// currency-conversion §4).
///
/// Rules this file owns and every screen inherits:
/// - **Rounding point**: none — [Money] already holds whole minor units, so
///   rendering is exact string assembly and never touches a double.
/// - **Exponent**: HUF renders with no decimals, USD/EUR/CAD with two (fixes
///   the HUF phantom-cents defect D10).
/// - **Symbol**: from [CurrencyCode.symbol] only; no screen hardcodes one.
/// - **Grouping**: `,` thousands separators (the app's existing visual style).
String formatMoney(Money money) =>
    formatMinorUnits(money.minorUnits, money.currency);

/// Renders whole minor units of [currency] — the primitive [formatMoney] is
/// built on, exported so call sites that already hold minor units (engine
/// aggregates) do not have to allocate a [Money] first.
String formatMinorUnits(int minorUnits, CurrencyCode currency) {
  final factor = currency.minorUnitsPerMajor;
  final isNegative = minorUnits < 0;
  final absolute = minorUnits.abs();
  final major = absolute ~/ factor;
  final fraction = absolute % factor;

  final grouped = NumberFormat('#,##0', 'en_US').format(major);
  final numeric = currency.exponent == 0
      ? grouped
      : '$grouped.${fraction.toString().padLeft(currency.exponent, '0')}';

  return '${isNegative ? '-' : ''}${currency.symbol} $numeric';
}

/// Renders a major-unit [amount] (e.g. `12.34`) in [currency].
///
/// A thin bridge for engine aggregates that are still expressed in major units:
/// it rounds once to whole minor units and hands off to [formatMinorUnits], so
/// there is still exactly one formatting/rounding path (FR-018).
String formatMajorUnits(num amount, CurrencyCode currency) => formatMinorUnits(
      Money.fromMajor(amount.toDouble(), currency).minorUnits,
      currency,
    );

/// Renders the converted amount with the original beside it, e.g.
/// `Ft 3,850 · $10.00` (FR-002: the original amount is always visible).
///
/// When both sides are the same currency the original is redundant, so only
/// the converted amount is returned.
String formatMoneyWithOriginal({
  required Money converted,
  required Money original,
}) {
  if (converted.currency == original.currency) {
    return formatMoney(converted);
  }
  return '${formatMoney(converted)} · ${formatMoney(original)}';
}

/// Parses a free-text amount field into a major-unit `double`, ignoring
/// thousands separators and whitespace (`1,234.56` and `1 234.56` → `1234.56`).
///
/// This is the one input parser every amount field shares (FR-007): the grouping
/// formatter may insert `,`, so a screen must never feed the raw text straight to
/// `double.tryParse`. Returns `null` for empty or non-numeric text — callers
/// decide whether a `null`/blank means "clear" or "zero"; negative values are
/// passed through so the screen's own validator can reject them.
double? parseMoneyInput(String raw) {
  final cleaned = raw.trim().replaceAll(RegExp(r'[,\s]'), '');
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null || value.isNaN || !value.isFinite) return null;
  return value;
}

/// Parses user input ("1 234,50", "12.34", "1,234.56") into a [Money] in
/// [currency].
///
/// Returns `null` when the text is not a number or resolves to a non-positive
/// amount — amounts ≤ 0 are rejected at input (data-model §1.2). Rounding to
/// the currency's exponent happens here, at the input boundary. Delegates the
/// separator handling to [parseMoneyInput] so there is one stripping rule.
Money? tryParseMoneyInput(String raw, CurrencyCode currency) {
  final withoutSymbol = raw.replaceAll(currency.symbol.trim(), '');
  final value = parseMoneyInput(withoutSymbol);
  if (value == null || value <= 0) return null;
  return Money.fromMajor(value, currency);
}
