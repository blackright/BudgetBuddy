import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/budget_profile.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/direct_expense_profile.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared/presentation/money_conversion.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../finance/providers/profile_providers.dart';

/// The expenses filed under one budget profile.
///
/// Opened by tapping a budget profile card on the dashboard (T130) or a
/// profile in Settings (T132). Only the expenses of that profile in the
/// active month are listed.
class ProfileExpensesScreen extends ConsumerWidget {
  const ProfileExpensesScreen(
      {super.key,
      required this.profileId,
      this.profileType = FinancialProfileType.budget});

  final int profileId;
  final String profileType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currency = ref.watch(dashboardCurrencyProvider);
    final table = ref
        .watch(rateRegistryProvider)
        .tableFor(ref.watch(selectedYearMonthProvider));

    final profiles = ref.watch(budgetProfilesProvider).value ?? const [];
    final directProfiles =
        ref.watch(directExpenseProfilesProvider).value ?? const [];

    BudgetProfile? budgetProfile;
    for (final p in profiles) {
      if (profileType == FinancialProfileType.budget && p.id == profileId) {
        budgetProfile = p;
      }
    }
    DirectExpenseProfile? directProfile;
    for (final p in directProfiles) {
      if (profileType == FinancialProfileType.direct && p.id == profileId) {
        directProfile = p;
      }
    }

    final expenses = (ref.watch(contextExpensesProvider))
        .where((e) =>
            e.budgetProfileId == profileId &&
            e.financialProfileType == profileType)
        .toList();

    final name =
        budgetProfile?.name ?? directProfile?.name ?? 'Profile $profileId';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: expenses.isEmpty
          ? Center(
              child: Text(
                'No expenses in this profile yet.',
                style: theme.textTheme.bodyMedium,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                // D12: read-only rows convert; long-press shows the original.
                final from = expense.currencyCode;
                final formatted = from == null
                    ? null
                    : formatExpenseConversion(expense, currency, table);
                return ListTile(
                  title: Text(expense.title),
                  subtitle: Text(
                    '${_dateLabel(expense.date)}  •  '
                    '${expense.status.name}',
                  ),
                  trailing: formatted == null
                      ? Text(
                          '${expense.amount} ${expense.currency}',
                          style: theme.textTheme.titleSmall,
                        )
                      : ConvertedAmountText(
                          text: formatted.text,
                          originalText: formatted.originalText,
                          style: theme.textTheme.titleSmall,
                        ),
                  onTap: () => context.push(
                    '/expense_detail',
                    extra: expense,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAddExpenseForProfile(context, profileId,
            isDirect: profileType == FinancialProfileType.direct),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _dateLabel(DateTime date) => date.toIso8601String().split('T').first;
}
