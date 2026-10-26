import 'package:flutter/material.dart';

import '../../core/models/currency_code.dart';
import '../../core/models/money.dart';
import '../../core/models/expense.dart';
import '../../features/expenses/models/reimbursement.dart';
import '../../core/network/rate_types.dart';
import '../../features/engine/currency_resolution.dart';
import 'money_format.dart';

/// The result of converting and formatting a money amount.
///
/// [text] is the formatted display-currency string (e.g. "$ 250.00").
/// [originalText] is the formatted source-currency string when the source
/// and display currencies differ, or `null` when they are the same.
class ConvertedMoney {
  const ConvertedMoney({
    required this.text,
    this.originalText,
  });

  /// The amount formatted in the display currency.
  final String text;

  /// The amount formatted in its original currency, when it differs from the
  /// display currency. `null` when no conversion happened.
  final String? originalText;

  /// Whether the amount was converted from a different currency.
  bool get wasConverted => originalText != null;
}

/// Converts [amountMinor] from [sourceCurrency] to [displayCurrency] using
/// [table], then formats the result with the display currency's symbol and
/// decimal places (T156, FR-020).
///
/// When the two currencies differ, [originalText] holds the amount as it
/// was stored, so the caller can show it in a tooltip (FR-020).
ConvertedMoney convertAndFormat(
  int amountMinor,
  CurrencyCode sourceCurrency,
  CurrencyCode displayCurrency,
  RateTable? table,
) {
  final converted = toDisplay(
    Money(amountMinor, sourceCurrency),
    displayCurrency,
    table,
  );
  final text = formatMinorUnits(converted.minorUnits, displayCurrency);
  if (sourceCurrency == displayCurrency) {
    return ConvertedMoney(text: text);
  }
  final original = formatMinorUnits(amountMinor, sourceCurrency);
  return ConvertedMoney(text: text, originalText: original);
}

/// Uses the fixed accounting value for Paid records while retaining the actual
/// original amount in the tooltip. Planned/legacy records keep monthly rates.
ConvertedMoney formatExpenseConversion(
    Expense expense, CurrencyCode display, RateTable? table) {
  final converted = expenseToDisplay(expense, display, table);
  return ConvertedMoney(
      text: formatMinorUnits(converted.minorUnits, display),
      originalText: expense.currencyCode == null
          ? null
          : formatMinorUnits(expense.amount, expense.currencyCode!));
}

ConvertedMoney formatRefundConversion(
    Reimbursement refund, CurrencyCode display, RateTable? table) {
  final converted = reimbursementToDisplay(refund, display, table);
  return ConvertedMoney(
      text: formatMinorUnits(converted.minorUnits, display),
      originalText: refund.currencyCode == null
          ? null
          : formatMinorUnits(refund.amount, refund.currencyCode!));
}

/// A widget that shows a converted amount with an optional tooltip revealing
/// the original currency (T156, FR-020).
///
/// On mobile the tooltip appears on long-press; on desktop it appears on
/// hover. The caller passes the already-converted [text] and, when the
/// amount was converted, the [originalText].
class ConvertedAmountText extends StatelessWidget {
  const ConvertedAmountText({
    super.key,
    required this.text,
    this.originalText,
    this.style,
  });

  final String text;
  final String? originalText;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (originalText == null) {
      return Text(text, style: style);
    }
    return Tooltip(
      message: 'Original: $originalText',
      child: Text(text, style: style),
    );
  }
}
