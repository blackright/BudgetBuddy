import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/currency_code.dart';
import '../../../../core/models/monthly_budget.dart';
import '../../../finance/repositories/month_finance_repository.dart';

/// One choice in a month display-currency picker.
typedef MonthCurrencyChoice = ({String label, CurrencyCode? value});

/// The single currency list used by the Dashboard sheet and the shared
/// Medical/Expenses menu.
List<MonthCurrencyChoice> monthCurrencyChoices(CurrencyCode main) => [
      (
        label: 'Show in ${main.displayName} (default)',
        value: null,
      ),
      for (final currency in CurrencyCode.values)
        (
          label: '${currency.name.toUpperCase()} (${currency.symbol})',
          value: currency,
        ),
    ];

/// Writes the display-only convert-to choice for [budget]'s month.
Future<void> saveMonthCurrency(
  WidgetRef ref,
  MonthlyBudget budget,
  CurrencyCode? currency,
) {
  return ref
      .read(monthFinanceRepositoryProvider)
      .saveConvertTo(budget.yearMonth, currency);
}
