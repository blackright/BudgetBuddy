import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/expense.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../core/models/user_profile.dart';
import '../../medical/providers/medical_providers.dart';
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
    final activeBudget = ref.watch(activeBudgetProvider).value;
    final categoriesAsync = ref.watch(categoriesProvider);

    String currencySymbol = '\$';
    if (activeBudget != null) {
      switch (activeBudget.currency) {
        case PrimaryCurrency.huf:
          currencySymbol = 'Ft';
          break;
        case PrimaryCurrency.usd:
          currencySymbol = '\$';
          break;
        case PrimaryCurrency.cad:
          currencySymbol = 'C\$';
          break;
        case PrimaryCurrency.eur:
          currencySymbol = '€';
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        // FR-035: money really did come back, so the return is kept. The user
        // decides whether to move it to another expense or drop it, rather than
        // having the app silently discard it with the target.
        actions: const [_OrphanBannerButton()],
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
              ref.read(selectedYearMonthProvider.notifier).update((state) => nextMonth(state));
            } else if (details.primaryVelocity! > 300) {
              ref.read(selectedYearMonthProvider.notifier).update((state) => previousMonth(state));
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
                  ? ListView(children: const [Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No expenses found.')))])
                  : SlidableAutoCloseBehavior(
                      child: ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return _ExpenseTile(
                            key: ValueKey(expense.id),
                            expense: expense,
                            currencySymbol: currencySymbol,
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
    final currencySymbol = ref.read(medicalCurrencySymbolProvider);
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
                          '$currencySymbol${orphan.amount.toStringAsFixed(2)}'
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
                '${expense.title} - ${expense.amount.toStringAsFixed(2)}',
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
  final String currencySymbol;

  const _ExpenseTile({
    super.key,
    required this.expense,
    required this.currencySymbol,
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
    final isPartiallyReimbursed = expense.status == ExpenseStatus.partiallyReimbursed;

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
              if (!isReimbursed && !isPartiallyReimbursed) _toggle(context, ref);
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
        trailing: Text(
          '$currencySymbol ${NumberFormat('#,##0.00').format(expense.amount)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
