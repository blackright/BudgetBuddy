import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/currency_code.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../../../shared/presentation/modals/app_sheet.dart';
import '../../providers/dashboard_providers.dart';
import '../budget_status.dart';
import '../dashboard_copy.dart';
import '../dashboard_view_state.dart';
import 'budget_detail_sheet.dart';

/// The dashboard's compact budget ledger.
///
/// The provider already converts every amount into the display currency and
/// orders profiles worst-first. This widget only caps the list at four and
/// gives each profile a flat, tappable row.
class BudgetsLedger extends ConsumerWidget {
  const BudgetsLedger({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(dashboardProfilesProvider);
    final currency = ref.watch(dashboardCurrencyProvider);
    final rows = profiles
        .take(4)
        .map((profile) => DashboardBudgetRow.fromProfile(profile, currency))
        .toList();
    final budgetProfiles = profiles.where((profile) => !profile.isDirect);
    final totalBudgetMinor = budgetProfiles.fold<int>(
        0, (total, profile) => total + profile.allocation);
    final totalLeftMinor = budgetProfiles.fold<int>(
        0, (total, profile) => total + profile.remaining);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      key: const Key('budgetsSection'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DashboardCopy.budgets,
                  key: const Key('budgetsHeader'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              TextButton(
                key: const Key('budgetsSeeAll'),
                onPressed: () => context.push('/profiles'),
                child: const Text(DashboardCopy.seeAll),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (budgetProfiles.isNotEmpty) ...[
            _BudgetTotals(
              totalBudgetMinor: totalBudgetMinor,
              totalLeftMinor: totalLeftMinor,
              currency: currency,
            ),
            const SizedBox(height: 8),
          ],
          if (rows.isEmpty)
            const _EmptyBudgetRow()
          else
            for (final row in rows)
              _BudgetProfileRow(
                row: row,
                currency: currency,
                onTap: () => _openDetail(context, row, currency),
              ),
        ],
      ),
    );
  }

  void _openDetail(
    BuildContext context,
    DashboardBudgetRow row,
    CurrencyCode currency,
  ) {
    showAppSheet<void>(
      context,
      builder: (_) => BudgetDetailSheet(row: row, currency: currency),
    );
  }
}

class _BudgetTotals extends StatelessWidget {
  const _BudgetTotals({
    required this.totalBudgetMinor,
    required this.totalLeftMinor,
    required this.currency,
  });

  final int totalBudgetMinor;
  final int totalLeftMinor;
  final CurrencyCode currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final over = totalLeftMinor < 0;
    return Container(
      key: const Key('budgetsSummary'),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _BudgetMetric(
                key: const Key('budgetsTotal'),
                label: 'Total budget',
                value: formatMinorUnits(totalBudgetMinor, currency),
                color: scheme.onSurface,
              ),
            ),
            Container(
              width: 1,
              color: scheme.outlineVariant,
            ),
            Expanded(
              child: _BudgetMetric(
                key: const Key('budgetsLeft'),
                label: over ? 'Over by' : 'Left',
                value: formatMinorUnits(totalLeftMinor.abs(), currency),
                color: over ? scheme.error : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetMetric extends StatelessWidget {
  const _BudgetMetric({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetProfileRow extends StatelessWidget {
  const _BudgetProfileRow({
    required this.row,
    required this.currency,
    required this.onTap,
  });

  final DashboardBudgetRow row;
  final CurrencyCode currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final statusColor =
        row.isDirect ? scheme.onSurfaceVariant : row.status.color;
    final isOver = row.isOverBudget;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        key: Key('budgetRow-${row.identity}'),
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              row.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: _RowAmount(
                              row: row,
                              currency: currency,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      if (!row.isDirect && !isOver) ...[
                        const SizedBox(height: 2),
                        Text(
                          row.statusLabel,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                      if (row.isDirect) ...[
                        const SizedBox(height: 2),
                        Text(
                          DashboardCopy.noBudget,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                      if (row.showsProgress) ...[
                        const SizedBox(height: 7),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: (row.usagePercent / 100).clamp(0.0, 1.0),
                            minHeight: 4,
                            color: statusColor,
                            backgroundColor: scheme.surfaceContainerHighest,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RowAmount extends StatelessWidget {
  const _RowAmount({
    required this.row,
    required this.currency,
    required this.color,
  });

  final DashboardBudgetRow row;
  final CurrencyCode currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (row.isDirect) {
      return _AmountLabel(
        amount: formatMinorUnits(row.spentMinor, currency),
        label: DashboardCopy.spent,
        color: color,
      );
    }
    if (row.isOverBudget) {
      return Text(
        row.statusLabel,
        maxLines: 2,
        textAlign: TextAlign.right,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      );
    }
    return _AmountLabel(
      amount: formatMinorUnits(row.remainingMinor, currency),
      label: DashboardCopy.left,
      color: color,
    );
  }
}

class _AmountLabel extends StatelessWidget {
  const _AmountLabel({
    required this.amount,
    required this.label,
    required this.color,
  });

  final String amount;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            amount,
            maxLines: 1,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _EmptyBudgetRow extends StatelessWidget {
  const _EmptyBudgetRow();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      key: const Key('budgetsEmpty'),
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/allocations'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(
            children: [
              Icon(Icons.add_circle_outline, color: scheme.primary),
              const SizedBox(width: 12),
              const Expanded(child: Text('Create your first budget')),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
