import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/budget_profile.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/direct_expense_profile.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared/presentation/money_conversion.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../finance/providers/profile_providers.dart';
import '../../medical/presentation/medical_theme.dart';

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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 40,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No expenses in this profile yet.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                // D12: read-only rows convert; long-press shows the original.
                final from = expense.currencyCode;
                final formatted = from == null
                    ? null
                    : formatExpenseConversion(expense, currency, table);
                return _ExpenseCard(
                  key: Key('profileExpense-${expense.id}'),
                  expense: expense,
                  formatted: formatted,
                  onTap: () => context.push(
                    '/expense_detail',
                    extra: expense,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openAddExpenseForProfile(context, profileId,
            isDirect: profileType == FinancialProfileType.direct),
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    super.key,
    required this.expense,
    required this.formatted,
    required this.onTap,
  });

  final Expense expense;
  final ConvertedMoney? formatted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusColor = _statusColor(context, expense.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 20,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            DateFormat('d MMM yyyy').format(expense.date),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _statusLabel(expense.status),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: formatted == null
                        ? Text(
                            '${expense.amount} ${expense.currency}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _moneyOut(context),
                            ),
                          )
                        : ConvertedAmountText(
                            text: formatted!.text,
                            originalText: formatted!.originalText,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _moneyOut(context),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, ExpenseStatus status) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case ExpenseStatus.planned:
        return _planned(context);
      case ExpenseStatus.paid:
        return _moneyOut(context);
      case ExpenseStatus.cancelled:
        return scheme.onSurfaceVariant;
      case ExpenseStatus.reimbursed:
      case ExpenseStatus.partiallyReimbursed:
        return _moneyIn(context);
    }
  }

  Color _moneyOut(BuildContext context) =>
      MedicalTheme.semantic(context, MedicalTheme.moneyOut);

  Color _moneyIn(BuildContext context) =>
      MedicalTheme.semantic(context, MedicalTheme.moneyIn);

  Color _planned(BuildContext context) =>
      MedicalTheme.semantic(context, MedicalTheme.planned);

  String _statusLabel(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.planned:
        return 'Planned';
      case ExpenseStatus.paid:
        return 'Paid';
      case ExpenseStatus.cancelled:
        return 'Cancelled';
      case ExpenseStatus.reimbursed:
        return 'Reimbursed';
      case ExpenseStatus.partiallyReimbursed:
        return 'Partly reimbursed';
    }
  }
}
