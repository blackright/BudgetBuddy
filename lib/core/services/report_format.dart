import 'package:intl/intl.dart';
import '../models/financial_report.dart';
import '../models/currency_code.dart';
import '../../shared/presentation/money_format.dart';
import 'free_funds.dart';

String reportMoney(int? amount, CurrencyCode currency) => amount == null
    ? 'Unavailable'
    : BigInt.from(amount).abs() > BigInt.from(9007199254740991)
        ? 'Needs review'
        : '${currency.code.toUpperCase()} ${formatMinorUnits(amount, currency)}';
String reportTime(DateTime? time) => time == null
    ? 'Not recorded'
    : '${DateFormat('d MMM yyyy, HH:mm', 'en_US').format(time.toUtc())} UTC';
String reportDate(DateTime date) =>
    DateFormat('d MMM yyyy', 'en_US').format(date.toLocal());
String reportPayment(String value) =>
    const {
      'cash': 'Cash',
      'card': 'Card',
      'bankTransfer': 'Bank transfer',
      'other': 'Other'
    }[value] ??
    value;
String reportStatus(String value) =>
    const {
      'paid': 'Paid',
      'planned': 'Planned',
      'cancelled': 'Cancelled',
      'reimbursed': 'Fully refunded',
      'partiallyReimbursed': 'Partially refunded'
    }[value] ??
    value;
String exactReportDecimal(int value, CurrencyCode code) {
  final sign = value < 0 ? '-' : '';
  final n = BigInt.from(value).abs(),
      factor = BigInt.from(code.minorUnitsPerMajor);
  return '$sign${n ~/ factor}${code.exponent == 0 ? '' : '.${(n % factor).toString().padLeft(code.exponent, '0')}'}';
}

Map<String, int?> originalReportTotals(FinancialReport report) {
  final result = <String, int?>{};
  for (final row in report.transactions) {
    final group = row.effect == 1
        ? 'Paid'
        : row.effect == -1
            ? 'Refunds'
            : row.status == 'planned'
                ? 'Planned'
                : row.kind;
    final key = '${row.currency} · $group';
    if (result.containsKey(key) && result[key] == null) continue;
    try {
      result[key] = sumFinancialMinor([result[key] ?? 0, row.amount]);
    } on FormatException {
      result[key] = null;
    }
  }
  return Map.unmodifiable(result);
}

const String reportReconciliation =
    'Net paid = paid spending − recorded refunds. Free to spend = income − paid spending + refunds − unused allocations − carry protection + carry received + Month-End released + vault credit. Currency rounding, when shown, reconciles converted display values only. Opening bank funds are not income. Vault movements and allocation transfers are not expenses. Profile borrowing figures use a shared reserve and must not be added together. Period cards sum activity; monthly and vault balances are shown at their own dates.';

class ReportExportOptions {
  const ReportExportOptions({this.notes = false, this.appendix = false});
  final bool notes, appendix;
}
