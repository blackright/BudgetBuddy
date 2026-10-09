import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/money.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../shared/presentation/widgets/conversion_footnote.dart';
import '../../dashboard/presentation/widgets/month_convert_to_menu.dart';
import '../../engine/currency_conversion.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/reimbursement.dart';
import '../providers/expenses_provider.dart';
import '../providers/expense_filter_provider.dart';
import '../providers/category_provider.dart';
import '../repositories/expense_repository.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(filteredExpensesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        // FR-035: money really did come back, so the return is kept. The user
        // decides whether to move it to another expense or drop it, rather than
        // having the app silently discard it with the target.
        actions: const [
          MonthConvertToMenu(),
          _OrphanBannerButton(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search expenses...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) =>
                      ref.read(searchQueryProvider.notifier).state = value,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    // Status Filter
                    DropdownButton<ExpenseStatus?>(
                      value: ref.watch(activeStatusFilterProvider),
                      hint: const Text('Status'),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('All Statuses')),
                        ...ExpenseStatus.values.map((s) =>
                            DropdownMenuItem(value: s, child: Text(s.name))),
                      ],
                      onChanged: (val) => ref
                          .read(activeStatusFilterProvider.notifier)
                          .state = val,
                    ),
                    const SizedBox(width: 16),
                    // Category Filter
                    categoriesAsync.when(
                      data: (cats) => DropdownButton<String?>(
                        value:
                            ref.watch(activeCategoryFilterProvider)?.categoryId,
                        hint: const Text('Category'),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text('All Categories')),
                          ...cats.map((c) => DropdownMenuItem(
                              value: c.categoryId,
                              child: Text('${c.emoji} ${c.name}'))),
                        ],
                        onChanged: (val) {
                          if (val == null) {
                            ref
                                .read(activeCategoryFilterProvider.notifier)
                                .state = null;
                          } else {
                            ref
                                    .read(activeCategoryFilterProvider.notifier)
                                    .state =
                                cats.firstWhere((c) => c.categoryId == val);
                          }
                        },
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < -300) {
              ref
                  .read(selectedYearMonthProvider.notifier)
                  .update((state) => nextMonth(state));
            } else if (details.primaryVelocity! > 300) {
              ref
                  .read(selectedYearMonthProvider.notifier)
                  .update((state) => previousMonth(state));
            }
          }
        },
        child: expensesAsync.when(
          data: (expenses) {
            return RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: expenses.isEmpty
                  ? ListView(children: const [
                      _MonthRateFootnote(),
                      Center(
                          child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('No expenses found.')))
                    ])
                  : SlidableAutoCloseBehavior(
                      child: ListView.builder(
                        itemCount: expenses.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return const _MonthRateFootnote();
                          }
                          final expense = expenses[index - 1];
                          return _ExpenseTile(
                            key: ValueKey(expense.id),
                            expense: expense,
                          );
                        },
                      ),
                    ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add_expense'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// The month's conversion caption at the top of the list (T054).
///
/// Names the rate the month's figures convert at when the display currency
/// differs from the profile main, and the Expenses app bar gains the same
/// convert-to control as the dashboard (T055); a single-currency month renders
/// nothing.
class _MonthRateFootnote extends ConsumerWidget {
  const _MonthRateFootnote();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = resolveDisplayCurrency(
      month: ref.watch(activeBudgetProvider).value,
      profile: ref.watch(activeProfileProvider).value,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: ConversionFootnote(
        main: ref.watch(mainCurrencyProvider),
        display: display,
        table: ref.watch(rateRegistryProvider).tableFor(
              ref.watch(selectedYearMonthProvider),
            ),
      ),
    );
  }
}

/// App-bar entry that appears only when reimbursements need resolving (FR-035).
class _OrphanBannerButton extends ConsumerWidget {
  const _OrphanBannerButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(expenseRepositoryProvider);
    return StreamBuilder<List<Reimbursement>>(
      stream: repository.watchOrphanedReimbursements(),
      builder: (context, snapshot) {
        final orphans = snapshot.data ?? const <Reimbursement>[];
        if (orphans.isEmpty) return const SizedBox.shrink();
        return IconButton(
          key: const ValueKey('orphan-reimbursements'),
          tooltip: '${orphans.length} reimbursement'
              '${orphans.length == 1 ? '' : 's'} need attention',
          icon: Badge(
            label: Text('${orphans.length}'),
            child: const Icon(Icons.warning_amber_rounded),
          ),
          onPressed: () => _resolveOrphans(context, ref, orphans),
        );
      },
    );
  }

  Future<void> _resolveOrphans(
    BuildContext context,
    WidgetRef ref,
    List<Reimbursement> orphans,
  ) async {
    final repository = ref.read(expenseRepositoryProvider);
    final profileId = ref.read(activeProfileProvider).value?.id;
    final yearMonth = ref.read(selectedYearMonthProvider);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reimbursement without an expense'),
        // `double.maxFinite` width inside a dialog asked for more room than the
        // dialog would grant, and `Flexible` + `shrinkWrap` inside a
        // `MainAxisSize.min` column overflowed as soon as the list outgrew the
        // space left by the keyboard. A bounded box plus one real scroll view
        // keeps the list reachable at any height (FR-035).
        content: SizedBox(
          width: 360,
          // Always a bounded height: `Expanded` inside a `MainAxisSize.min`
          // column is an error when the height is unbounded, and the count-based
          // cap keeps a short list from reserving a tall empty box.
          height: 96 + orphans.length.clamp(1, 4) * 56.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'These returns were kept, but the expense they paid for is gone. '
                'Move each one to an expense, or remove it.',
                style: Theme.of(dialogContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    for (final orphan in orphans)
                      ListTile(
                        key: ValueKey('orphan-${orphan.id}'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${formatMoney(Money(orphan.amount, orphan.currencyCode ?? CurrencyCode.huf))}'
                          ' received ${DateFormat.yMMMd().format(orphan.date)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              key: ValueKey('orphan-restore-${orphan.id}'),
                              onPressed: profileId == null
                                  ? null
                                  : () async {
                                      final target = await _pickTarget(
                                        dialogContext,
                                        profileId,
                                        yearMonth,
                                        repository,
                                      );
                                      if (target == null) return;
                                      await repository
                                          .restoreOrphanReimbursement(
                                        orphan.id,
                                        target,
                                      );
                                      if (dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                      }
                                    },
                              child: const Text('Move'),
                            ),
                            TextButton(
                              key: ValueKey('orphan-discard-${orphan.id}'),
                              onPressed: () async {
                                await repository
                                    .discardOrphanReimbursement(orphan.id);
                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }
                              },
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  /// Lets the user pick which expense the return should now pay for.
  ///
  /// Scoped to the month being viewed, so the choice matches what the user can
  /// see on screen rather than reaching across the whole ledger.
  Future<int?> _pickTarget(
    BuildContext context,
    int profileId,
    String yearMonth,
    ExpenseRepository repository,
  ) async {
    final expenses = await repository.getExpenses(profileId, yearMonth);
    if (expenses.isEmpty) {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No expenses in $yearMonth to move this reimbursement to. '
            'Remove it, or switch to the month the expense belongs to.',
          ),
        ),
      );
      return null;
    }

    if (!context.mounted) return null;
    return showDialog<int>(
      context: context,
      builder: (pickerContext) => SimpleDialog(
        title: Text('Move to which $yearMonth expense?'),
        children: [
          for (final expense in expenses)
            SimpleDialogOption(
              key: ValueKey('restore-target-${expense.id}'),
              onPressed: () => Navigator.pop(pickerContext, expense.id),
              child: Text(
                '${expense.title} - ${formatMoney(Money(expense.amount, expense.currencyCode ?? CurrencyCode.huf))}',
              ),
            ),
        ],
      ),
    );
  }
}

/// An expense row with swipe actions:
/// - Swipe right (start → end): toggle Paid ↔ Planned.
/// - Swipe left (end → start): reveal Edit and Delete.
/// - Tap: open the full edit screen.
class _ExpenseTile extends ConsumerWidget {
  final Expense expense;

  const _ExpenseTile({
    super.key,
    required this.expense,
  });

  void _openEdit(BuildContext context) =>
      context.push('/edit_expense', extra: expense);

  void _openDetail(BuildContext context) =>
      context.push('/expense_detail', extra: expense);

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final wasPaid = expense.status == ExpenseStatus.paid;
    await ref.read(expensesProvider.notifier).toggleStatus(expense);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(wasPaid
            ? '"${expense.title}" moved back to Planned 🗓️'
            : '"${expense.title}" marked as Paid ✅'),
        duration: const Duration(seconds: 2),
      ));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('"${expense.title}" will be removed for good.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep it')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(expensesProvider.notifier).deleteExpense(expense.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Deleted "${expense.title}" 🗑️')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPaid = expense.status == ExpenseStatus.paid;
    final isReimbursed = expense.status == ExpenseStatus.reimbursed;
    final isPartiallyReimbursed =
        expense.status == ExpenseStatus.partiallyReimbursed;

    // T055: each row converts to the month's display currency so the list
    // reads in one currency. Hides when the expense already is the display
    // currency or the pair is degraded (never invents a figure, FR-014).
    final from = expense.currencyCode;
    final budget = ref.watch(activeBudgetProvider).value;
    final profile = ref.watch(activeProfileProvider).value;
    final display = resolveDisplayCurrency(month: budget, profile: profile);
    String? convertedCaption;
    if (from != null && from != display && expense.amount > 0) {
      final result = convert(
        Money(expense.amount, from),
        display,
        ref
            .watch(rateRegistryProvider)
            .tableFor(ref.watch(selectedYearMonthProvider)),
      );
      if (!result.isDegraded) {
        convertedCaption = '≈ ${formatMoney(result.amount)}';
      }
    }

    IconData statusIcon;
    Color statusColor;
    if (isReimbursed) {
      statusIcon = Icons.currency_exchange;
      statusColor = Colors.blue;
    } else if (isPartiallyReimbursed) {
      statusIcon = Icons.change_circle;
      statusColor = Colors.lightBlue;
    } else if (isPaid) {
      statusIcon = Icons.check;
      statusColor = Colors.green;
    } else {
      statusIcon = Icons.schedule;
      statusColor = Colors.orange;
    }

    return Slidable(
      key: ValueKey('slidable-${expense.id}'),
      groupTag: 'expenses',
      // T009: left-to-right → toggle status (full swipe triggers it).
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.3,
        dismissible: DismissiblePane(
          closeOnCancel: true,
          confirmDismiss: () async {
            if (!isReimbursed && !isPartiallyReimbursed) {
              await _toggle(context, ref);
            }
            return false; // keep the row; it just changes status
          },
          onDismissed: () {},
        ),
        children: [
          SlidableAction(
            onPressed: (_) {
              if (!isReimbursed && !isPartiallyReimbursed) {
                _toggle(context, ref);
              }
            },
            backgroundColor: isPaid ? Colors.orange : Colors.green,
            foregroundColor: Colors.white,
            icon: isPaid ? Icons.schedule : Icons.check_circle,
            label: isPaid ? 'Planned' : 'Paid',
          ),
        ],
      ),
      // T010: right-to-left → Edit / Delete.
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (_) => _openEdit(context),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => _delete(context, ref),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _openDetail(context), // T017
        leading: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: CircleAvatar(
            key: ValueKey(expense.status),
            backgroundColor: statusColor.withValues(alpha: 0.2),
            child: Icon(
              statusIcon,
              color: statusColor,
            ),
          ),
        ),
        title: Text(expense.title),
        subtitle: Text(
          '${expense.status.name.toUpperCase()} • ${expense.guiltLevel.name}',
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatMoney(
                Money(expense.amount, expense.currencyCode ?? CurrencyCode.huf),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (convertedCaption != null)
              Text(
                convertedCaption,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
