import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/currency_code.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/network/rate_types.dart';
import '../../../../core/providers/selected_month_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/presentation/money_conversion.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../../../shared/presentation/modals/app_sheet.dart';
import '../../../engine/providers/rate_registry_provider.dart';
import '../../../medical/presentation/medical_theme.dart';
import '../../../spaces/providers/spaces_providers.dart';
import '../budget_status.dart';
import '../dashboard_copy.dart';
import '../dashboard_view_state.dart';

/// The detail panel behind one Budgets row.
class BudgetDetailSheet extends ConsumerWidget {
  const BudgetDetailSheet({
    super.key,
    required this.row,
    required this.currency,
  });

  final DashboardBudgetRow row;
  final CurrencyCode currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEdit = ref.watch(activeContextCanEditProvider);
    final table = ref
        .watch(rateRegistryProvider)
        .tableFor(ref.watch(selectedYearMonthProvider));
    final scheme = Theme.of(context).colorScheme;

    return AppSheet(
      key: const Key('budgetDetailSheet'),
      showCloseButton: false,
      title: row.name,
      titleStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
      subtitle: row.isDirect
          ? 'Direct profile · no budget'
          : 'Budget profile · ${row.statusLabel}',
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          row.isDirect
              ? Icons.bolt_outlined
              : Icons.account_balance_wallet_outlined,
          size: 20,
          color: scheme.onPrimaryContainer,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BudgetSummary(row: row, currency: currency),
          if (row.borrowedMinor > 0) ...[
            const SizedBox(height: 8),
            _DetailLine(
              label: DashboardCopy.borrowed,
              value: formatMinorUnits(row.borrowedMinor, currency),
              color: MedicalTheme.semantic(context, MedicalTheme.moneyOut),
            ),
          ],
          if (row.deficitMinor > 0) ...[
            const SizedBox(height: 4),
            _DetailLine(
              label: DashboardCopy.deficit,
              value: formatMinorUnits(row.deficitMinor, currency),
              color: MedicalTheme.semantic(context, MedicalTheme.moneyOut),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 18,
                color: scheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                DashboardCopy.recent,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (row.recentExpenses.isEmpty)
            Text(
              'No expenses yet.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            )
          else
            for (final expense in row.recentExpenses)
              _ExpenseRow(
                key: Key('budgetDetailExpense-${expense.id}'),
                expense: expense,
                currency: currency,
                table: table,
              ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.end,
            children: [
              TextButton(
                key: const Key('budgetDetailSeeAll'),
                onPressed: () => openProfileExpenses(
                  context,
                  row.profileId,
                  isDirect: row.isDirect,
                ),
                child: const Text(DashboardCopy.seeAll),
              ),
              if (canEdit)
                FilledButton.icon(
                  key: const Key('budgetDetailAddExpense'),
                  onPressed: () => openAddExpenseForProfile(
                    context,
                    row.profileId,
                    isDirect: row.isDirect,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(DashboardCopy.addExpense),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetSummary extends StatelessWidget {
  const _BudgetSummary({required this.row, required this.currency});

  final DashboardBudgetRow row;
  final CurrencyCode currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isOver = row.isOverBudget;
    final statusColor = row.isDirect
        ? scheme.primary
        : MedicalTheme.semantic(context, row.status.color);
    final amount = row.isDirect
        ? formatMinorUnits(row.spentMinor, currency)
        : isOver
            ? formatMinorUnits(row.overspendMinor, currency)
            : formatMinorUnits(row.remainingMinor, currency);
    final label = row.isDirect
        ? '${DashboardCopy.spent} · ${DashboardCopy.noBudget}'
        : isOver
            ? DashboardCopy.overBy
            : DashboardCopy.left;
    final amountColor = row.isDirect
        ? scheme.onPrimaryContainer
        : isOver
            ? MedicalTheme.semantic(context, MedicalTheme.moneyOut)
            : scheme.onSurface;
    final labelColor = row.isDirect
        ? scheme.onPrimaryContainer.withValues(alpha: 0.85)
        : scheme.onSurfaceVariant;

    return Container(
      key: const Key('budgetDetailSummary'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: row.isDirect
            ? scheme.primaryContainer
            : statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              key: const Key('budgetDetailSummaryAmount'),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
        ),
      ],
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    super.key,
    required this.expense,
    required this.currency,
    required this.table,
  });

  final Expense expense;
  final CurrencyCode currency;
  final RateTable? table;

  @override
  Widget build(BuildContext context) {
    final formatted = formatExpenseConversion(expense, currency, table);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 18,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('d MMM yyyy').format(expense.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: ConvertedAmountText(
                    text: formatted.text,
                    originalText: formatted.originalText,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: MedicalTheme.semantic(
                            context,
                            MedicalTheme.moneyOut,
                          ),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
