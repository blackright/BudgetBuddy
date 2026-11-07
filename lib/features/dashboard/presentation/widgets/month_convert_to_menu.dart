import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/currency_code.dart';
import '../../../../core/providers/active_budget_provider.dart';
import '../../../settings/providers/settings_provider.dart';
import 'month_currency_choices.dart';

/// The month-global "convert this month to" control (FR-011, US4, SC-006).
///
/// Shared by the dashboard, Medical dashboard and Expenses screens, so the same
/// convert-to choice pins *this* month everywhere: selecting a currency is
/// display-only for the viewed month, while "Show in {main} (default)" clears
/// the choice so the month follows the profile again (data-model §4.2).
///
/// Hides itself until the month's budget row exists — no month, no choice.
class MonthConvertToMenu extends ConsumerWidget {
  const MonthConvertToMenu({super.key});

  // Flutter only calls `onSelected` for non-null popup values; a null-valued
  // "clear" item is treated as a dismiss. So "clear back to default" carries
  // this sentinel instead of null (PopupMenuButton._showMenu).
  static const Object _defaultChoice = Object();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(activeBudgetProvider).value;
    final mainCurrency = ref.watch(mainCurrencyProvider);
    if (budget == null) return const SizedBox.shrink();
    final choices = monthCurrencyChoices(mainCurrency);

    return PopupMenuButton<Object>(
      key: const Key('monthConvertToMenu'),
      initialValue: CurrencyCode.tryParse(budget.currency),
      icon: const Icon(Icons.currency_exchange),
      tooltip: 'Convert this month to',
      // Read lazily so the menu can render before Isar is needed (the write
      // only happens on selection).
      onSelected: (value) => saveMonthCurrency(
        ref,
        budget,
        value is CurrencyCode ? value : null,
      ),
      itemBuilder: (context) => [
        PopupMenuItem<Object>(
          value: _defaultChoice,
          child: Text(choices.first.label),
        ),
        const PopupMenuDivider(),
        for (final choice in choices.skip(1))
          PopupMenuItem<Object>(
            value: choice.value,
            child: Text(choice.label),
          ),
      ],
    );
  }
}
