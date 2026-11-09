import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/currency_code.dart';
import '../../../../core/providers/active_budget_provider.dart';
import '../../../../core/providers/selected_month_provider.dart';
import '../../../../shared/presentation/modals/app_sheet.dart';
import '../../../settings/providers/settings_provider.dart';
import '../dashboard_copy.dart';
import 'month_currency_choices.dart';

/// The display-currency picker reached from the Dashboard overflow menu.
class MonthToolsSheet extends ConsumerWidget {
  const MonthToolsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAppSheet<void>(
      context,
      builder: (_) => const MonthToolsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(activeBudgetProvider).value;
    final mainCurrency = ref.watch(mainCurrencyProvider);
    final yearMonth = budget == null
        ? ref.watch(selectedYearMonthProvider)
        : budget.yearMonth;
    final selected = CurrencyCode.tryParse(budget?.currency);
    final choices = monthCurrencyChoices(mainCurrency);

    return AppSheet(
      key: const Key('monthToolsSheet'),
      title: DashboardCopy.convertMonth,
      subtitle: monthLabel(yearMonth),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < choices.length; index++) ...[
            if (index == 1) const Divider(height: 1),
            ListTile(
              key: Key(
                choices[index].value == null
                    ? 'convertToDefault'
                    : 'convertTo-${choices[index].value!.code}',
              ),
              title: Text(choices[index].label),
              trailing: selected == choices[index].value
                  ? const Icon(Icons.check)
                  : null,
              onTap: budget == null
                  ? null
                  : () async {
                      await saveMonthCurrency(
                        ref,
                        budget,
                        choices[index].value,
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
            ),
          ],
        ],
      ),
    );
  }
}
