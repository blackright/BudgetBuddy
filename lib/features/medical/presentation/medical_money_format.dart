import '../../../core/models/currency_code.dart';
import '../../../core/models/money.dart';
import '../../../core/network/rate_types.dart';
import '../../../shared/presentation/money_format.dart';
import '../../engine/currency_resolution.dart';

/// History values retain their own recorded currency, even after a bill edit.
String formatMedicalRecordedMoney(int amount, String code) {
  final currency = CurrencyCode.tryParse(code);
  return currency == null
      ? 'Recorded currency needs review'
      : formatMedicalViewMoney(Money(amount, currency));
}

/// Reuses conversion/rounding and formatting without the aggregate zero fallback.
/// A missing display rate never changes the original recorded currency/value.
String formatMedicalViewMoney(Money? money,
    {CurrencyCode? displayCurrency, RateTable? rateTable}) {
  if (money == null) return 'Not confirmed';
  String recorded(Money value) =>
      '${value.currency.code.toUpperCase()} ${formatMinorUnitsInput(value.minorUnits, value.currency)}';
  if (displayCurrency == null || displayCurrency == money.currency) {
    return recorded(money);
  }
  final display = tryToDisplay(money, displayCurrency, rateTable);
  return display == null
      ? '${recorded(money)} · ${displayCurrency.code.toUpperCase()} conversion unavailable'
      : '${recorded(display)} (${recorded(money)})';
}
