import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/category.dart';
import '../../engine/providers/safe_to_spend_provider.dart';
import '../providers/category_provider.dart';
import '../providers/expenses_provider.dart';
import 'widgets/reimbursement_entry_sheet.dart' as entry;
import 'widgets/reimbursement_history_list.dart' as history;

class ExpenseDetailScreen extends ConsumerWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/edit_expense', extra: expense),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroSection(expense: expense),
            const SizedBox(height: 24),
            _ImpactCard(expense: expense),
            const SizedBox(height: 24),
            _VisualTimeline(expense: expense),
            const SizedBox(height: 24),
            if (expense.status == ExpenseStatus.reimbursed || 
                expense.status == ExpenseStatus.partiallyReimbursed ||
                expense.status == ExpenseStatus.paid)
              history.ReimbursementHistoryList(
                expenseId: expense.id,
              ),
            const SizedBox(height: 32),
            _ActionBar(expense: expense),
          ],
        ),
      ),
    );
  }
}

class _ActionBar extends ConsumerWidget {
  final Expense expense;
  const _ActionBar({required this.expense});

  void _showReimbursementSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => entry.ReimbursementEntrySheet(expense: expense),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPaid = expense.status == ExpenseStatus.paid ||
        expense.status == ExpenseStatus.partiallyReimbursed ||
        expense.status == ExpenseStatus.reimbursed;

    return Column(
      children: [
        if (isPaid && expense.status != ExpenseStatus.reimbursed) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showReimbursementSheet(context),
              icon: const Icon(Icons.currency_exchange),
              label: const Text('Add Reimbursement'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (expense.status == ExpenseStatus.planned || expense.status == ExpenseStatus.paid)
              FilledButton.icon(
                onPressed: () async {
                  await ref.read(expensesProvider.notifier).toggleStatus(expense);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(expense.status == ExpenseStatus.paid ? 'Marked as Planned' : 'Marked as Paid')),
                    );
                    context.pop();
                  }
                },
                icon: Icon(expense.status == ExpenseStatus.paid ? Icons.schedule : Icons.check_circle),
                label: Text(expense.status == ExpenseStatus.paid ? 'Mark Planned' : 'Mark Paid'),
                style: FilledButton.styleFrom(
                  backgroundColor: expense.status == ExpenseStatus.paid ? Colors.orange : Colors.green,
                ),
              ),
            OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Expense?'),
                    content: const Text('Are you sure you want to delete this expense?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await ref.read(expensesProvider.notifier).deleteExpense(expense.id);
                  if (context.mounted) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense deleted')));
                  }
                }
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroSection extends ConsumerWidget {
  final Expense expense;
  const _HeroSection({required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final category = categoriesAsync.value?.firstWhere(
        (c) => c.categoryId == expense.categoryId,
        orElse: () => Category(
            categoryId: 'default',
            name: 'Unknown',
            emoji: '❓',
            colorValue: 0xFF9E9E9E));

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: category != null
              ? Color(category.colorValue).withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          child: Text(
            category?.emoji ?? '❓',
            style: const TextStyle(fontSize: 40),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          expense.title,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '${expense.currency.toUpperCase()} ${NumberFormat('#,##0.00').format(expense.amount)}',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ImpactCard extends ConsumerWidget {
  final Expense expense;
  const _ImpactCard({required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeToSpend = ref.watch(safeToSpendProvider);

    // Impact is approximate based on current safe to spend + expense amount (if we were to revert it)
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Budget Impact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Builder(builder: (context) {
              // Approximate total before this expense
              final amountInPrimary =
                  expense.amount * expense.exchangeRateToPrimary;
              final totalBefore = safeToSpend + amountInPrimary;
              final percent = totalBefore > 0
                  ? (amountInPrimary / totalBefore * 100).clamp(0, 100)
                  : 0;

              return Column(
                children: [
                  LinearProgressIndicator(
                    value: percent / 100,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.redAccent,
                    minHeight: 12,
                  ),
                  const SizedBox(height: 8),
                  Text(
                      '${percent.toStringAsFixed(1)}% of your available funds used'),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _VisualTimeline extends StatelessWidget {
  final Expense expense;
  const _VisualTimeline({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Timeline',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _TimelineStep(
              title: 'Created',
              date: expense.date,
              isCompleted: true,
            ),
            _TimelineStep(
              title: 'Paid',
              date: expense.paidAt,
              isCompleted: expense.status == ExpenseStatus.paid,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final DateTime? date;
  final bool isCompleted;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.date,
    required this.isCompleted,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? Colors.green : Colors.grey,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? Colors.green : Colors.grey,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight:
                        isCompleted ? FontWeight.bold : FontWeight.normal)),
            if (date != null)
              Text(
                DateFormat('MMM dd, yyyy - hh:mm a').format(date!),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
      ],
    );
  }
}
