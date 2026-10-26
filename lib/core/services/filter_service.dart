import '../models/expense.dart';
import '../models/currency_code.dart';

enum ExpenseDateScope { month, range, all }

class ExpenseFilters {
  const ExpenseFilters(
      {this.scope = ExpenseDateScope.month,
      this.start,
      this.end,
      this.merchant,
      this.financialProfile,
      this.category,
      this.currency,
      this.paymentMethod,
      this.status,
      this.minimum,
      this.maximum});
  final ExpenseDateScope scope;
  final DateTime? start, end;
  final String? merchant, financialProfile, category, currency, paymentMethod;
  final ExpenseStatus? status;
  final int? minimum, maximum;

  String? get error {
    if (scope == ExpenseDateScope.range &&
        (start == null || end == null || start!.isAfter(end!))) {
      return 'Choose a valid start and end date.';
    }
    if ((minimum != null || maximum != null) &&
        CurrencyCode.tryParse(currency) == null) {
      return 'Choose a currency for the amount range.';
    }
    if ((minimum ?? 0) < 0 ||
        (maximum ?? 0) < 0 ||
        (minimum != null && maximum != null && minimum! > maximum!)) {
      return 'Enter a valid minimum and maximum amount.';
    }
    return null;
  }

  Map<String, String> get labels => {
        if (scope != ExpenseDateScope.month)
          'date': scope == ExpenseDateScope.all
              ? 'All months'
              : '${_day(start)} to ${_day(end)}',
        if (merchant != null)
          'merchant': merchant == 'unknown'
              ? 'Merchant: Not recorded'
              : 'Merchant selected',
        if (financialProfile != null) 'profile': 'Financial profile selected',
        if (category != null) 'category': 'Category selected',
        if (currency != null) 'currency': currency!.toUpperCase(),
        if (paymentMethod != null) 'payment': 'Payment: $paymentMethod',
        if (status != null) 'status': 'Status: ${status!.name}',
        if (minimum != null || maximum != null) 'amount': 'Amount range',
      };
  static String _day(DateTime? date) => date == null
      ? '?'
      : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  ExpenseFilters without(String field) => ExpenseFilters(
      scope: field == 'date' ? ExpenseDateScope.month : scope,
      start: field == 'date' ? null : start,
      end: field == 'date' ? null : end,
      merchant: field == 'merchant' ? null : merchant,
      financialProfile: field == 'profile' ? null : financialProfile,
      category: field == 'category' ? null : category,
      currency: field == 'currency' ? null : currency,
      paymentMethod: field == 'payment' ? null : paymentMethod,
      status: field == 'status' ? null : status,
      minimum: field == 'amount' || field == 'currency' ? null : minimum,
      maximum: field == 'amount' || field == 'currency' ? null : maximum);
}

/// An exact identity, never a name or a bare ID shared by two collections.
String expenseFinancialKey(Expense e) {
  if (e.budgetProfileId == null && e.financialProfileSyncGuid == null) {
    return 'main';
  }
  if (e.budgetProfileId == null ||
      (e.financialProfileType != FinancialProfileType.budget &&
          e.financialProfileType != FinancialProfileType.direct)) {
    return 'unresolved';
  }
  final identity = e.financialProfileSyncGuid ?? 'local:${e.budgetProfileId}';
  return '${e.financialProfileType}:$identity:${e.yearMonth}';
}

class FilterService {
  const FilterService();
  bool matches(Expense e, ExpenseFilters f, String selectedMonth) {
    if (f.error != null) return false;
    if (f.scope == ExpenseDateScope.month && e.yearMonth != selectedMonth) {
      return false;
    }
    if (f.scope == ExpenseDateScope.range) {
      final date = e.date.toLocal();
      final start = DateTime(f.start!.year, f.start!.month, f.start!.day);
      final exclusiveEnd = DateTime(f.end!.year, f.end!.month, f.end!.day + 1);
      if (date.isBefore(start) || !date.isBefore(exclusiveEnd)) return false;
    }
    if (f.merchant != null &&
        (f.merchant == 'unknown'
            ? e.merchantSyncGuid != null ||
                (e.merchantName?.trim().isNotEmpty ?? false)
            : e.merchantSyncGuid != f.merchant)) {
      return false;
    }
    if (f.financialProfile != null &&
        expenseFinancialKey(e) != f.financialProfile) {
      return false;
    }
    if (f.category != null && e.categoryId != f.category) return false;
    if (f.currency != null &&
        e.currency.toLowerCase() != f.currency!.toLowerCase()) {
      return false;
    }
    if (f.paymentMethod != null &&
        (e.paymentMethod ?? 'unknown') != f.paymentMethod) {
      return false;
    }
    if (f.status != null && e.status != f.status) return false;
    return (f.minimum == null || e.amount >= f.minimum!) &&
        (f.maximum == null || e.amount <= f.maximum!);
  }
}

/// Exact grouped decimal input, including zero bounds, without binary floats.
int? parseSearchAmount(String raw, CurrencyCode? currency) {
  final text = raw.trim();
  if (text.isEmpty) return null;
  if (currency == null ||
      !RegExp(r'^(?:\d+|\d{1,3}(?:,\d{3})+)(?:\.\d+)?$').hasMatch(text)) {
    throw const FormatException('Choose a currency and enter a valid amount.');
  }
  final parts = text.replaceAll(',', '').split('.');
  final fraction = parts.length == 2 ? parts[1] : '';
  if (fraction.length > currency.exponent) {
    throw const FormatException('Use the currency’s exact precision.');
  }
  final minor =
      BigInt.parse(parts[0]) * BigInt.from(currency.minorUnitsPerMajor) +
          BigInt.parse(fraction.padRight(currency.exponent, '0').isEmpty
              ? '0'
              : fraction.padRight(currency.exponent, '0'));
  if (minor > BigInt.from(9007199254740991)) {
    throw const FormatException('Amount is too large.');
  }
  return minor.toInt();
}
