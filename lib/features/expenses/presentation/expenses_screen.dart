import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../engine/providers/true_available_provider.dart';
import '../../../core/models/expense.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/models/user_profile.dart';
import '../providers/expenses_provider.dart';
import '../providers/expense_filter_provider.dart';
import '../providers/category_provider.dart';

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
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(child: Text('No expenses found.'));
          }
          return SlidableAutoCloseBehavior(
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add_expense'),
        child: const Icon(Icons.add),
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
            await _toggle(context, ref);
            return false; // keep the row; it just changes status
          },
          onDismissed: () {},
        ),
        children: [
          SlidableAction(
            onPressed: (_) => _toggle(context, ref),
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
            backgroundColor: isPaid
                ? Colors.green.withOpacity(0.2)
                : Colors.orange.withOpacity(0.2),
            child: Icon(
              isPaid ? Icons.check : Icons.schedule,
              color: isPaid ? Colors.green : Colors.orange,
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
