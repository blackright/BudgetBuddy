import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/models/money.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../../engine/providers/rate_registry_provider.dart';
import '../../providers/reimbursement_provider.dart';
import 'reimbursement_history_list.dart';

/// One combined return total prevents reimbursements and refunds from claiming
/// the same remaining amount. Original amounts are always labelled explicitly.
class RefundSummaryCard extends ConsumerWidget {
  const RefundSummaryCard({super.key, required this.expense});
  final Expense expense;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final returns = ref.watch(reimbursementsByExpenseProvider(expense.id));
    final rates = ref.watch(rateRegistryProvider);
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: returns.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Text('Return history could not be loaded.'),
              data: (rows) {
                final currency = expense.currencyCode;
                if (currency == null) {
                  return const Text(
                      'Return summary unavailable: unsupported expense currency.');
                }
                var total = 0;
                var linkedCount = 0;
                for (final row in rows) {
                  if (row.expenseId != expense.id ||
                      row.originYearMonth != expense.yearMonth ||
                      row.sharedSpaceId != expense.sharedSpaceId ||
                      (expense.sharedSpaceId == null &&
                          row.profileId != expense.profileId)) {
                    continue;
                  }
                  final from = row.currencyCode;
                  if (from == null || row.amount < 0) {
                    return const Text(
                        'Return summary unavailable: unsupported return currency.');
                  }
                  final result = rates.convert(
                      amount: Money(row.amount, from),
                      to: currency,
                      yearMonth: expense.yearMonth);
                  if (result.isDegraded) {
                    return const Text(
                        'Return summary unavailable: exchange rate missing.');
                  }
                  total += result.amount.minorUnits;
                  linkedCount++;
                }
                final legacyReturned = linkedCount == 0 &&
                    expense.status == ExpenseStatus.reimbursed;
                if (legacyReturned) total = expense.amount;
                final remaining = expense.amount - total;
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Refunds and returns',
                          style: Theme.of(context).textTheme.titleMedium),
                      if (legacyReturned)
                        const Text(
                            'Legacy expense marked fully returned; no detailed return entry is available.'),
                      Text(
                          'Originally paid: ${formatMinorUnits(expense.amount, currency)}'),
                      Text(
                          'Returned so far: ${formatMinorUnits(total, currency)}'),
                      Text(
                          'Still refundable: ${formatMinorUnits(remaining > 0 ? remaining : 0, currency)}'),
                      if (remaining < 0)
                        const Text(
                            'Recorded returns exceed the original payment. Review the return history.'),
                      ReimbursementHistoryList(
                          expenseId: expense.id, title: 'Return history'),
                    ]);
              },
            )));
  }
}
