import '../../core/models/currency_code.dart';
import '../../core/models/expense.dart';
import '../../core/models/money.dart';
import '../../core/models/monthly_budget.dart';
import '../../core/models/user_profile.dart';
import '../../core/network/rate_types.dart';
import '../expenses/models/reimbursement.dart';
import 'currency_conversion.dart';

/// The currency a month's figures are expressed in: the month's own convert-to
/// choice when set, otherwise the profile's main currency (FR-011).
CurrencyCode resolveDisplayCurrency({
  MonthlyBudget? month,
  UserProfile? profile,
}) {
  final convertTo = CurrencyCode.tryParse(month?.currency);
  if (convertTo != null) return convertTo;
  final profileCode = profile?.primaryCurrency.code;
  return profileCode ?? CurrencyCode.huf;
}

/// The currency a profile's stored income and opening balance are in.
///
/// Unlike expenses — which each carry their own stored currency — net salary
/// (FR-001) and the confirmed opening balance (FR-006) are recorded once, in
/// the profile main currency. When a month displays in a different currency,
/// these two figures are converted *from* the main currency through the month's
/// table, never relabelled into the display currency.
CurrencyCode mainSourceCurrency(UserProfile? profile) =>
    profile?.primaryCurrency.code ?? CurrencyCode.huf;

/// Converts [amount] into the display currency using the month's [table].
///
/// The registry's table is never `null` (bundled fallback), so this only
/// degrades when the stored currency is unsupported — in which case the amount
/// is excluded from converted totals (data-model §4.4) rather than invented.
Money toDisplay(Money amount, CurrencyCode display, RateTable? table) {
  final result = convert(amount, display, table);
  return result.isDegraded ? Money.zero(display) : result.amount;
}

/// Converts an expense into the display currency. Rows carrying an unsupported
/// legacy currency contribute zero and are surfaced separately (FR-021, §4.4).
Money expenseToDisplay(
    Expense expense, CurrencyCode display, RateTable? table) {
  final code = expense.currencyCode;
  if (code == null) return Money.zero(display);
  return toDisplay(Money(expense.amount, code), display, table);
}

/// Converts a reimbursement into the display currency.
Money reimbursementToDisplay(
  Reimbursement reimbursement,
  CurrencyCode display,
  RateTable? table,
) {
  final code = reimbursement.currencyCode;
  if (code == null) return Money.zero(display);
  return toDisplay(Money(reimbursement.amount, code), display, table);
}
