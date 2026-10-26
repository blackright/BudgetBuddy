import '../../../shared/presentation/financial_feedback.dart';
import '../../../core/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/budget_profile.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/direct_expense_profile.dart';
import '../../../core/models/money.dart';
import '../../../core/network/rate_types.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../core/services/borrowing_service.dart';
import '../../../core/services/profile_spending_service.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../engine/providers/true_available_provider.dart';
import '../../../shared/presentation/input_formatters/thousands_separator_input_formatter.dart';
import '../../../shared/presentation/money_format.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../dashboard/presentation/budget_status.dart';
import '../providers/profile_providers.dart';
import '../providers/month_end_providers.dart';
import '../providers/reserve_providers.dart';

/// The Allocations screen for the active month.
///
/// Every budget profile is shown with its allocated, spent and left amounts,
/// its status colour, and the actions to edit the allocation or transfer
/// money between profiles. Direct expense profiles are listed separately as
/// "spent from reserve" (T147, FR-002, FR-011, T155, T168-T170).
class AllocationsScreen extends ConsumerStatefulWidget {
  const AllocationsScreen({super.key});

  @override
  ConsumerState<AllocationsScreen> createState() => _AllocationsScreenState();
}

class _AllocationsScreenState extends ConsumerState<AllocationsScreen> {
  /// Whether the budget profiles section is expanded.
  bool _budgetExpanded = true;

  /// Whether the direct expense profiles section is expanded.
  bool _directExpanded = true;

  /// Scroll controller for the floating "Jump to Direct" button.
  final ScrollController _scrollController = ScrollController();

  /// Anchor for the Direct profiles section, so the jump button lands exactly
  /// on it instead of guessing a scroll offset.
  final GlobalKey _directSectionKey = GlobalKey();

  /// Whether the direct section is visible on screen.
  bool _directVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkDirectVisibility);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkDirectVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkDirectVisibility() {
    // Show the jump action while the user is still inside the (long) budget
    // list. The action itself uses the section's GlobalKey, so this heuristic
    // only decides *whether* to offer it, never where to scroll.
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final showButton = currentScroll < maxScroll * 0.7 && maxScroll > 300;
    if (showButton != !_directVisible) {
      setState(() => _directVisible = !showButton);
    }
  }

  Future<void> _jumpToDirect() async {
    final target = _directSectionKey.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayCurrency = ref.watch(dashboardCurrencyProvider);
    final contextCurrency = ref.watch(budgetContextProvider).isShared
        ? (ref.watch(activeSpaceProvider).value?.currency.code ??
            CurrencyCode.huf)
        : (ref.watch(activeProfileProvider).value?.primaryCurrency.code ??
            CurrencyCode.huf);
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final table = ref.watch(rateRegistryProvider).tableFor(yearMonth);
    final budgetProfiles = ref.watch(budgetProfilesProvider).value ?? const [];
    final directProfiles =
        ref.watch(directExpenseProfilesProvider).value ?? const [];
    final availableReserve = ref.watch(availableReserveProvider);
    final contextExpenses = ref.watch(contextExpensesProvider);
    final returns = ref.watch(monthlyReimbursementsProvider).value ?? const [];

    // D5: stored `spent` is a cache; the live figure converts each expense into
    // the context currency, so a profile holding a foreign-currency row no
    // longer sums unlike units. Everything is displayed in [displayCurrency].
    const spending = ProfileSpendingService();
    int liveSpent(int profileId, String type) => spending.spentInYearMonth(
          profileId: profileId,
          profileType: type,
          yearMonth: yearMonth,
          expenses: contextExpenses,
          reimbursements: returns,
          convertReimbursement: (r) =>
              reimbursementToDisplay(r, contextCurrency, table).minorUnits,
          convert: (expense) =>
              expenseToDisplay(expense, contextCurrency, table).minorUnits,
        );

    final spentByBudget = {
      for (final profile in budgetProfiles)
        profile.id: liveSpent(profile.id, FinancialProfileType.budget),
    };
    final spentByDirect = {
      for (final profile in directProfiles)
        profile.id: liveSpent(profile.id, FinancialProfileType.direct),
    };

    // Summary totals.
    final totalAllocated =
        budgetProfiles.fold<int>(0, (s, p) => s + p.allocation);
    final totalSpent =
        spentByBudget.values.fold<int>(0, (s, spent) => s + spent);

    return Scaffold(
      appBar: AppBar(title: const Text('Allocations'), actions: [
        IconButton(
            onPressed: () => context.push('/month_end'),
            icon: const Icon(Icons.event_available),
            tooltip: 'Month-End')
      ]),
      // T169: the summary bar stays pinned above the list, so the totals remain
      // visible while the long list scrolls underneath.
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _StickySummaryBar(
              allocated: totalAllocated,
              spent: totalSpent,
              free: availableReserve,
              displayCurrency: displayCurrency,
              contextCurrency: contextCurrency,
              table: table,
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Collapsible budget profiles section (T168).
                _CollapsibleSection(
                  title: 'Budget Profiles',
                  count: budgetProfiles.length,
                  expanded: _budgetExpanded,
                  onToggle: () =>
                      setState(() => _budgetExpanded = !_budgetExpanded),
                  children: budgetProfiles.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('No budget profiles yet.'),
                          )
                        ]
                      : [
                          for (final profile in budgetProfiles)
                            _BudgetProfileRow(
                              profile: profile,
                              spent: spentByBudget[profile.id] ?? 0,
                              displayCurrency: displayCurrency,
                              contextCurrency: contextCurrency,
                              table: table,
                              availableReserve: availableReserve,
                            ),
                        ],
                ),
                const SizedBox(height: 12),
                // Collapsible direct expense profiles section (T168). The key
                // is the jump target for T170.
                Container(
                  key: _directSectionKey,
                  child: _CollapsibleSection(
                    title: 'Direct Expense Profiles',
                    count: directProfiles.length,
                    expanded: _directExpanded,
                    onToggle: () =>
                        setState(() => _directExpanded = !_directExpanded),
                    children: directProfiles.isEmpty
                        ? [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('No direct expense profiles yet.'),
                            )
                          ]
                        : [
                            for (final profile in directProfiles)
                              _DirectProfileRow(
                                profile: profile,
                                spent: spentByDirect[profile.id] ?? 0,
                                displayCurrency: displayCurrency,
                                contextCurrency: contextCurrency,
                                table: table,
                              ),
                          ],
                  ),
                ),
                const SizedBox(height: 80), // Space for floating button.
              ],
            ),
          ),
        ],
      ),
      // T170: only offered when the budget list is long enough to hide the
      // direct section below the fold.
      floatingActionButton: !_directVisible && budgetProfiles.length > 5
          ? FloatingActionButton.extended(
              onPressed: _jumpToDirect,
              icon: const Icon(Icons.arrow_downward),
              label: const Text('Jump to Direct'),
            )
          : null,
    );
  }
}

/// A collapsible section with a header showing title and count.
class _CollapsibleSection extends StatelessWidget {
  const _CollapsibleSection({
    required this.title,
    required this.count,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  final String title;
  final int count;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$title ($count)',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }
}

/// Sticky summary bar showing allocated, spent, and free.
class _StickySummaryBar extends StatelessWidget {
  const _StickySummaryBar({
    required this.allocated,
    required this.spent,
    required this.free,
    required this.displayCurrency,
    required this.contextCurrency,
    required this.table,
  });

  final int allocated;
  final int spent;
  final int free;
  final CurrencyCode displayCurrency;
  final CurrencyCode contextCurrency;
  final RateTable? table;

  int _convert(int minorUnits) => toDisplay(
        Money(minorUnits, contextCurrency),
        displayCurrency,
        table,
      ).minorUnits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: _SummaryItem(
                label: 'Allocated',
                value: formatMinorUnits(_convert(allocated), displayCurrency),
              ),
            ),
            Expanded(
              child: _SummaryItem(
                label: 'Spent',
                value: formatMinorUnits(_convert(spent), displayCurrency),
              ),
            ),
            Expanded(
              child: _SummaryItem(
                label: 'Free',
                value: formatMinorUnits(_convert(free), displayCurrency),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One item in the sticky summary bar.
class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(value,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

/// One budget profile on the Allocations screen.
class _BudgetProfileRow extends ConsumerWidget {
  const _BudgetProfileRow({
    required this.profile,
    required this.spent,
    required this.displayCurrency,
    required this.contextCurrency,
    required this.table,
    required this.availableReserve,
  });

  final BudgetProfile profile;
  final int spent;
  final CurrencyCode displayCurrency;
  final CurrencyCode contextCurrency;
  final RateTable? table;
  final int availableReserve;

  /// Converts a context-currency minor-unit amount to the display currency.
  int _convert(int minorUnits) => toDisplay(
        Money(minorUnits, contextCurrency),
        displayCurrency,
        table,
      ).minorUnits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ProfileBorrowingState(
      allocation: profile.allocation,
      spent: spent,
      availableReserve: availableReserve,
    );
    final status = state.status;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    profile.name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  status.label,
                  style:
                      theme.textTheme.labelSmall?.copyWith(color: status.color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _AllocationLine(
              label: 'Allocated',
              value: formatMinorUnits(
                  _convert(profile.allocation), displayCurrency),
            ),
            _AllocationLine(
              label: 'Spent',
              value: formatMinorUnits(_convert(spent), displayCurrency),
            ),
            _AllocationLine(
              label: 'Left',
              value:
                  formatMinorUnits(_convert(state.remaining), displayCurrency),
              bold: true,
            ),
            if (state.borrowed > 0)
              _AllocationLine(
                label: 'Borrowed',
                value:
                    formatMinorUnits(_convert(state.borrowed), displayCurrency),
                color: status.color,
              ),
            if (state.deficit > 0)
              _AllocationLine(
                label: 'Deficit',
                value:
                    formatMinorUnits(_convert(state.deficit), displayCurrency),
                color: BudgetStatus.red.color,
                bold: true,
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _editAllocation(context, ref, profile,
                      displayCurrency, contextCurrency, table),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/transfers'),
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Transfer'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${ref.watch(monthEndPolicyHistoryProvider).containsKey(profile.syncGuid) ? 'Applied month-end' : 'Month-end'}: ${(ref.watch(monthEndPolicyHistoryProvider)[profile.syncGuid] ?? profile.monthEndRule.name) == 'reset' ? 'Reset (unused returns to reserve)' : 'Carry Forward (unused adds to next month)'}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editAllocation(
    BuildContext context,
    WidgetRef ref,
    BudgetProfile profile,
    CurrencyCode displayCurrency,
    CurrencyCode contextCurrency,
    RateTable? table,
  ) async {
    final controller = TextEditingController(
      text: formatMinorUnitsInput(profile.allocation, contextCurrency),
    );
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit allocation: ${profile.name}'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Allocation (${contextCurrency.code.toUpperCase()})',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: const [ThousandsSeparatorInputFormatter()],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final value = parseMoneyInput(controller.text) ?? 0;
                final newAllocation =
                    (value * contextCurrency.minorUnitsPerMajor).round();
                profile.allocation = newAllocation;
                profile.updatedAt = DateTime.now();
                final saved = await runFinancialAction(context,
                    action: () =>
                        ref.read(profileActionsProvider).saveBudget(profile),
                    success: 'Allocation updated',
                    failure: 'Allocation could not be saved. Please retry.');
                if (saved && context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

/// One direct expense profile on the Allocations screen.
class _DirectProfileRow extends StatelessWidget {
  const _DirectProfileRow({
    required this.profile,
    required this.spent,
    required this.displayCurrency,
    required this.contextCurrency,
    required this.table,
  });

  final DirectExpenseProfile profile;
  final int spent;
  final CurrencyCode displayCurrency;
  final CurrencyCode contextCurrency;
  final RateTable? table;

  /// Converts a context-currency minor-unit amount to the display currency.
  int _convert(int minorUnits) => toDisplay(
        Money(minorUnits, contextCurrency),
        displayCurrency,
        table,
      ).minorUnits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    profile.name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _AllocationLine(
              label: 'Spent from reserve',
              value: formatMinorUnits(_convert(spent), displayCurrency),
            ),
            _AllocationLine(
              label: 'Expenses',
              value: profile.expenseCount.toString(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'No allocation: spends directly from reserve (FR-002)',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One labelled amount in the Allocation card or screen.
class _AllocationLine extends StatelessWidget {
  const _AllocationLine({
    required this.label,
    required this.value,
    this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
