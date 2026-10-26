import '../../../shared/presentation/financial_feedback.dart';
import 'widgets/expense_evidence_view.dart';
import 'purchase_screen.dart';
import '../../../core/services/merchant_service.dart';
import '../../../core/services/fx_booking_service.dart';
import '../../../shared/presentation/money_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/category.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../shared/presentation/money_conversion.dart';
import '../../../shared/presentation/widgets/conversion_footnote.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../engine/providers/safe_to_spend_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../spaces/providers/spaces_providers.dart';
import '../providers/category_provider.dart';
import '../providers/expenses_provider.dart';
import 'widgets/reimbursement_entry_sheet.dart' as entry;
import 'widgets/reimbursement_history_list.dart' as history;
import 'widgets/refund_summary_card.dart';
import 'refund_dialog.dart';
import 'profile_picker_sheet.dart';
import '../providers/refund_provider.dart';
import '../../engine/providers/true_available_provider.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final Expense expense;

  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expense =
        (ref.watch(monthlyExpensesProvider).value ?? const <Expense>[])
                .where((e) => e.id == this.expense.id)
                .firstOrNull ??
            this.expense;
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
            if (expense.purchaseSyncGuid != null)
              Card.outlined(
                  child: ListTile(
                      leading: const Icon(Icons.receipt_long),
                      title: const Text('Part of a purchase'),
                      subtitle:
                          const Text('View all items and their shared receipt'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                              builder: (_) => PurchaseScreen(
                                  guid: expense.purchaseSyncGuid!))))),
            if ((expense.budgetProfileId != null &&
                    expense.financialProfileType == null) ||
                (expense.budgetProfileId == null &&
                    expense.financialProfileSyncGuid != null))
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                              'This expense needs a profile assignment. Choose its Budget or Direct profile before recording a refund.'),
                          if (ref.watch(activeContextCanEditProvider))
                            TextButton(
                                onPressed: () async {
                                  final choice =
                                      await ProfilePickerSheet.show(context);
                                  if (choice == null) return;
                                  try {
                                    await ref
                                        .read(refundServiceProvider)
                                        .assignProfile(
                                            expenseId: expense.id,
                                            profileId: choice.profileId,
                                            profileType: choice.profileType,
                                            syncGuid: choice.syncGuid);
                                    if (context.mounted) {
                                      showFinancialFeedback(
                                          context, 'Expense profile assigned');
                                    }
                                  } catch (error) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  'Could not assign profile: $error')));
                                    }
                                  }
                                },
                                child:
                                    const Text('Confirm profile assignment')),
                        ],
                      ))),
            _HeroSection(expense: expense),
            _AccountingValueCard(expense: expense),
            const SizedBox(height: 12),
            Text('Merchant: ${expense.merchantName ?? 'Not recorded'}'),
            if (expense.type == ExpenseType.standard)
              ExpenseEvidenceView(expense: expense),
            Text(
                'Payment method: ${expensePaymentMethods[expense.paymentMethod] ?? (expense.paymentMethod == null ? 'Not recorded' : 'Other recorded method')}'),
            if (expense.tags.isNotEmpty)
              Text('Tags: ${expense.tags.join(', ')}'),
            if (expense.notes?.isNotEmpty ?? false)
              Text('Notes: ${expense.notes}'),
            const SizedBox(height: 24),
            _ImpactCard(expense: expense),
            const SizedBox(height: 24),
            _VisualTimeline(expense: expense),
            const SizedBox(height: 24),
            if (expense.status == ExpenseStatus.reimbursed ||
                expense.status == ExpenseStatus.partiallyReimbursed ||
                expense.status == ExpenseStatus.paid)
              expense.type == ExpenseType.standard
                  ? RefundSummaryCard(expense: expense)
                  : history.ReimbursementHistoryList(expenseId: expense.id),
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
    if (expense.type == ExpenseType.standard) {
      showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => RefundDialog(expenseId: expense.id));
      return;
    }
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
    final canEdit = ref.watch(activeContextCanEditProvider);

    if (!canEdit) return const SizedBox.shrink();

    return Column(
      children: [
        if (isPaid && expense.type == ExpenseType.standard) ...[
          FilledButton.icon(
              key: const Key('recordRefund'),
              onPressed: () => showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => RefundDialog(expenseId: expense.id)),
              icon: const Icon(Icons.undo),
              label: const Text('Record refund')),
          const SizedBox(height: 12),
        ],
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
            if (expense.status == ExpenseStatus.planned ||
                expense.status == ExpenseStatus.paid)
              FilledButton.icon(
                onPressed: () async {
                  if (expense.status == ExpenseStatus.planned &&
                      expense.type == ExpenseType.standard) {
                    showFinancialFeedback(context,
                        'Choose Paid and complete the payment evidence before saving.');
                    context.push('/edit_expense', extra: expense);
                    return;
                  }
                  final saved = await runFinancialAction(context,
                      action: () async {
                    await ref
                        .read(expensesProvider.notifier)
                        .toggleStatus(expense);
                  },
                      success: expense.status == ExpenseStatus.paid
                          ? 'Expense marked as Planned'
                          : 'Expense marked as Paid',
                      failure:
                          'Expense status could not be updated. Please retry.');
                  if (saved && context.mounted) context.pop();
                },
                icon: Icon(expense.status == ExpenseStatus.paid
                    ? Icons.schedule
                    : Icons.check_circle),
                label: Text(expense.status == ExpenseStatus.paid
                    ? 'Mark Planned'
                    : 'Mark Paid'),
                style: FilledButton.styleFrom(
                  backgroundColor: expense.status == ExpenseStatus.paid
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
            OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Expense?'),
                    content: const Text(
                        'Are you sure you want to delete this expense?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel')),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style:
                            FilledButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  final removed = await runFinancialAction(context,
                      action: () async {
                    await ref
                        .read(expensesProvider.notifier)
                        .deleteExpense(expense.id);
                  },
                      success: 'Expense deleted',
                      failure: 'Expense could not be deleted. Please retry.');
                  if (removed && context.mounted) context.pop();
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
        _HeroAmount(expense: expense),
      ],
    );
  }
}

/// The hero amount: converted into the month's display currency, with the
/// amount exactly as recorded revealed on long-press (T163, FR-020).
class _HeroAmount extends ConsumerWidget {
  const _HeroAmount({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = Theme.of(context)
        .textTheme
        .headlineSmall
        ?.copyWith(fontWeight: FontWeight.bold);
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final budget = ref.watch(activeBudgetProvider).value;
    final main = ref.watch(mainCurrencyProvider);
    final display = resolveContextDisplayCurrency(budget, main);
    final table = ref.watch(rateRegistryProvider).tableFor(yearMonth);

    final from = expense.currencyCode;
    if (from == null) {
      // Unsupported legacy code: never invent a currency or a rate.
      return Text(
        '${expense.amount} ${expense.currency} · Rate unavailable',
        style: style,
        textAlign: TextAlign.center,
      );
    }

    final converted = expenseToDisplay(expense, display, table);
    return ConvertedAmountText(
      text: formatMinorUnits(converted.minorUnits, display),
      originalText: formatMinorUnits(expense.amount, from),
      style: style,
    );
  }
}

class _AccountingValueCard extends StatelessWidget {
  const _AccountingValueCard({required this.expense});
  final Expense expense;

  @override
  Widget build(BuildContext context) {
    String title, description;
    try {
      final booked = expenseFx(expense)?.current;
      if (!fxPaid(expense.status)) {
        title = 'Estimated value';
        description =
            'The accounting value is fixed when this expense becomes Paid.';
      } else if (booked == null) {
        title = 'Legacy FX · original rate not recorded';
        description =
            'This expense still uses monthly rates. Its original payment rate has not been guessed.';
      } else {
        title =
            'Booked ${formatMinorUnits(booked.baseMinor, booked.money.currency)}';
        final captured = DateTime.parse(booked.capturedAt).toLocal();
        description =
            'Fixed accounting value · ${DateFormat('d MMM y, HH:mm').format(captured)}\n${booked.originalCurrency} → ${booked.baseCurrency}: ${booked.numerator}/${booked.denominator}\n${booked.source}';
      }
    } on FormatException {
      title = 'Accounting evidence needs review';
      description =
          'The recorded conversion does not reconcile. Do not rely on its converted total.';
    }
    return Card.filled(
      child: ListTile(
        leading: const Icon(Icons.currency_exchange),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}

class _ImpactCard extends ConsumerWidget {
  final Expense expense;
  const _ImpactCard({required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeToSpend = ref.watch(safeToSpendProvider);
    final budget = ref.watch(activeBudgetProvider).value;
    final profile = ref.watch(activeProfileProvider).value;
    final yearMonth = ref.watch(selectedYearMonthProvider);
    final table = ref.watch(rateRegistryProvider).tableFor(yearMonth);
    final display = resolveDisplayCurrency(month: budget, profile: profile);
    final main = ref.watch(mainCurrencyProvider);

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
                  expenseToDisplay(expense, display, table).majorValue;
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
            ConversionFootnote(main: main, display: display, table: table),
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
              title: 'Expense date',
              date: expense.date,
              isCompleted: true,
            ),
            _TimelineStep(
              title: 'Paid at',
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
                DateFormat('MMM dd, yyyy - hh:mm a').format(date!.toLocal()),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
          ],
        ),
      ],
    );
  }
}
