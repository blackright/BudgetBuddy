import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/budget_context_provider.dart';
import '../../finance/providers/income_source_providers.dart';
import '../../finance/providers/profile_providers.dart';
import '../../spaces/providers/spaces_providers.dart';
import 'settings_copy.dart';
import 'widgets/settings_row.dart';

/// The focused surface for income, profiles, month end, transfers, savings,
/// reports and bulk entry.
class SettingsBudgetingScreen extends ConsumerWidget {
  const SettingsBudgetingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeCount =
        ref.watch(incomeSourcesProvider).valueOrNull?.length ?? 0;
    final budgetCount =
        ref.watch(budgetProfilesProvider).valueOrNull?.length ?? 0;
    final directCount =
        ref.watch(directExpenseProfilesProvider).valueOrNull?.length ?? 0;
    final isShared = ref.watch(budgetContextProvider).isShared;
    final canEdit = ref.watch(activeContextCanEditProvider);
    final scheme = Theme.of(context).colorScheme;

    final rows = <Widget>[
      SettingsRow(
        key: const Key('settingsIncomeRow'),
        title: SettingsCopy.income,
        summary: SettingsCopy.incomeSummary(incomeCount),
        icon: Icons.payments_outlined,
        onTap: () => context.push('/income_sources'),
      ),
      SettingsRow(
        key: const Key('settingsProfilesRow'),
        title: SettingsCopy.profiles,
        summary: SettingsCopy.profilesSummary(
          budgets: budgetCount,
          direct: directCount,
        ),
        icon: Icons.account_balance_wallet_outlined,
        onTap: () => context.push('/profiles'),
      ),
      SettingsRow(
        key: const Key('settingsMonthEndRow'),
        title: SettingsCopy.monthEnd,
        summary: SettingsCopy.monthEndSummary,
        icon: Icons.event_available_outlined,
        onTap: () => context.push('/month_end'),
      ),
      SettingsRow(
        key: const Key('settingsTransfersRow'),
        title: SettingsCopy.transfers,
        summary: SettingsCopy.transfersSummary,
        icon: Icons.swap_horiz,
        onTap: () => context.push('/transfers'),
      ),
      if (!isShared)
        SettingsRow(
          key: const Key('settingsSavingsRow'),
          title: SettingsCopy.savings,
          summary: SettingsCopy.savingsSummary,
          icon: Icons.savings_outlined,
          onTap: () => context.push('/vault'),
        ),
      SettingsRow(
        key: const Key('settingsReportsRow'),
        title: SettingsCopy.reports,
        summary: SettingsCopy.reportsSummary,
        icon: Icons.summarize_outlined,
        onTap: () => context.push('/reports'),
      ),
      if (canEdit)
        SettingsRow(
          key: const Key('settingsBulkAddExpensesRow'),
          title: SettingsCopy.bulkAddExpenses,
          summary: SettingsCopy.bulkAddExpensesSummary,
          icon: Icons.playlist_add,
          onTap: () => context.push('/bulk_entry'),
        ),
    ];

    return Scaffold(
      key: const Key('settingsBudgetingScreen'),
      appBar: AppBar(title: const Text(SettingsCopy.budgeting)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Material(
          key: const Key('settingsBudgetingCard'),
          color: scheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < rows.length; index++) ...[
                if (index > 0)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 68,
                    endIndent: 16,
                    color: scheme.outlineVariant,
                  ),
                rows[index],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
