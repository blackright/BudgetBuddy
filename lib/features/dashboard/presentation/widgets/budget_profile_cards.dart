import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/currency_code.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/providers/selected_month_provider.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/borrowing_service.dart';
import '../../../../shared/presentation/money_conversion.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../../engine/providers/rate_registry_provider.dart';
import '../../providers/dashboard_providers.dart';
import '../budget_status.dart';

/// "Profiles at a glance" — the compact profiles section of the dashboard.
///
/// The section is built so the dashboard stays clean no matter how many
/// profiles there are (T136):
///
/// - a **one-line summary** of the whole picture,
/// - a **one-line rail of pills**, scrolled sideways, ordered so a profile in
///   trouble comes first,
/// - **one expandable card** at a time, showing that profile's three newest
///   expenses.
///
/// The rail is one line high and the card is the only thing that grows, so
/// twenty profiles still take no more room than two.
class BudgetProfileCards extends ConsumerStatefulWidget {
  const BudgetProfileCards({super.key});

  @override
  ConsumerState<BudgetProfileCards> createState() => _BudgetProfileCardsState();
}

class _BudgetProfileCardsState extends ConsumerState<BudgetProfileCards> {
  /// The profile whose card is open, or `null` when none is open.
  String? _expandedId;

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(dashboardProfilesProvider);
    final currency = ref.watch(dashboardCurrencyProvider);
    final summary = ref.watch(dashboardProfilesSummaryProvider);

    // T138: with no profiles at all, invite the user to make the first one.
    if (profiles.isEmpty) {
      return const _EmptyProfilesCard();
    }

    final expanded = _expandedId == null
        ? null
        : profiles.where((p) => p.identity == _expandedId).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Budget Profiles',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // T139: See all reuses the full Profiles screen.
            TextButton(
              onPressed: () => context.push('/profiles'),
              child: const Text('See all ›'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        _SummaryLine(
          summary: summary,
          currency: currency,
        ),
        const SizedBox(height: 12),
        _PillRail(
          profiles: profiles,
          currency: currency,
          expandedId: _expandedId,
          onTap: (id) => setState(() {
            _expandedId = _expandedId == id ? null : id;
          }),
        ),
        if (expanded != null) ...[
          const SizedBox(height: 12),
          _ProfileCard(
            entry: expanded,
            currency: currency,
            onClose: () => setState(() => _expandedId = null),
          ),
        ],
      ],
    );
  }
}

/// The one-line summary of every profile.
class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.summary, required this.currency});

  final ({
    int count,
    int allocated,
    int spent,
    int borrowed,
    int deficit
  }) summary;
  final CurrencyCode currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = <String>[
      '${summary.count} profiles',
      '${formatMinorUnits(summary.allocated, currency)} allocated',
      '${formatMinorUnits(summary.spent, currency)} spent',
    ];
    if (summary.borrowed > 0) {
      parts.add('${formatMinorUnits(summary.borrowed, currency)} borrowed');
    }
    if (summary.deficit > 0) {
      parts.add('${formatMinorUnits(summary.deficit, currency)} deficit');
    }
    return Text(
      parts.join(' · '),
      style: theme.textTheme.bodySmall,
    );
  }
}

/// The scrolling row of profile pills — always one line high.
class _PillRail extends StatelessWidget {
  const _PillRail({
    required this.profiles,
    required this.currency,
    required this.expandedId,
    required this.onTap,
  });

  final List<DashboardProfileState> profiles;
  final CurrencyCode currency;
  final String? expandedId;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: profiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = profiles[index];
          final isOpen = entry.identity == expandedId;
          final needsAttention = entry.isDirect
              ? entry.deficit > 0
              : entry.status == BudgetStatus.red || entry.deficit > 0;
          final color = entry.isDirect
              ? Theme.of(context).colorScheme.primary
              : entry.status.color;

          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => onTap(entry.identity),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isOpen ? color.withValues(alpha: 0.16) : null,
                border: Border.all(
                  color: isOpen ? color : Theme.of(context).dividerColor,
                  width: isOpen ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The colour dot: green, yellow, orange or red.
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(entry.name),
                  const SizedBox(width: 8),
                  Text(
                    entry.isDirect
                        ? formatMinorUnits(entry.spent, currency)
                        : formatMinorUnits(entry.remaining, currency),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  // A badge so trouble is visible without opening anything.
                  if (needsAttention) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.warning_amber_rounded,
                        size: 16, color: BudgetStatus.red.color),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The one open profile card.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.entry,
    required this.currency,
    required this.onClose,
  });

  final DashboardProfileState entry;
  final CurrencyCode currency;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = entry.status;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: entry.isDirect ? theme.colorScheme.primary : status.color,
              width: 5,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                // T137: a direct profile has no allocation, so it shows the
                // money it took from the reserve instead of a usage bar.
                if (entry.isDirect)
                  Text(
                    '${formatMinorUnits(entry.spent, currency)} spent · '
                    '${entry.expenseCount} expenses',
                    style: theme.textTheme.bodySmall,
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status.softColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.label,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: status.onSoftColor),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClose,
                  tooltip: 'Close',
                ),
              ],
            ),
            if (!entry.isDirect) ...[
              const SizedBox(height: 8),
              Text(
                'Left: ${formatMinorUnits(entry.remaining, currency)}  •  '
                'of ${formatMinorUnits(entry.allocation, currency)}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (entry.state.usagePercent / 100).clamp(0.0, 1.0),
                  color: status.color,
                  backgroundColor: status.softColor,
                  minHeight: 6,
                ),
              ),
            ],
            if (entry.borrowed > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Borrowed from reserve: '
                '${formatMinorUnits(entry.borrowed, currency)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (entry.deficit > 0) ...[
              const SizedBox(height: 2),
              Text(
                'Deficit: ${formatMinorUnits(entry.deficit, currency)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: BudgetStatus.red.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 8),
            if (entry.recentExpenses.isEmpty)
              Text('No expenses yet.', style: theme.textTheme.bodySmall)
            else
              for (final expense in entry.recentExpenses)
                _ExpenseRow(expense: expense, currency: currency),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // T139: Show all opens the full list for this profile.
                TextButton(
                  onPressed: () => openProfileExpenses(context, entry.id,
                      isDirect: entry.isDirect),
                  child: const Text('Show all'),
                ),
                // T129: add an expense straight into this profile.
                TextButton.icon(
                  onPressed: () => openAddExpenseForProfile(context, entry.id,
                      isDirect: entry.isDirect),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add expense'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One expense line inside the card.
///
/// T167/D5: each expense is converted from its own currency into the display
/// currency; the amount exactly as recorded is revealed on long-press.
class _ExpenseRow extends ConsumerWidget {
  const _ExpenseRow({required this.expense, required this.currency});

  final Expense expense;
  final CurrencyCode currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final table = ref
        .watch(rateRegistryProvider)
        .tableFor(ref.watch(selectedYearMonthProvider));
    final from = expense.currencyCode;
    final formatted =
        from == null ? null : formatExpenseConversion(expense, currency, table);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              expense.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            expense.date.toIso8601String().split('T').first,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(width: 12),
          if (formatted == null)
            Text(
              '${expense.amount} ${expense.currency}',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            )
          else
            ConvertedAmountText(
              text: formatted.text,
              originalText: formatted.originalText,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}

/// Shown when the user has no profiles yet (T138).
class _EmptyProfilesCard extends StatelessWidget {
  const _EmptyProfilesCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget Profiles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Give your money a home: a budget profile for things like food or '
              'transport, and a direct profile for medical or insurance costs.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => context.push('/profiles'),
              icon: const Icon(Icons.add),
              label: const Text('Create your first profile'),
            ),
          ],
        ),
      ),
    );
  }
}
