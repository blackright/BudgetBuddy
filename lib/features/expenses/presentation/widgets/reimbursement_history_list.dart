import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/active_budget_provider.dart';
import '../../../../core/providers/selected_month_provider.dart';
import '../../../../shared/presentation/money_conversion.dart';
import '../../../engine/currency_resolution.dart';
import '../../../engine/providers/rate_registry_provider.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/reimbursement_provider.dart';

class ReimbursementHistoryList extends ConsumerWidget {
  final int expenseId;

  const ReimbursementHistoryList({
    super.key,
    required this.expenseId,
    this.title = 'Reimbursement History',
  });
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reimbursementsAsync =
        ref.watch(reimbursementsByExpenseProvider(expenseId));
    final main = ref.watch(mainCurrencyProvider);
    final budget = ref.watch(activeBudgetProvider).value;
    final display = resolveContextDisplayCurrency(budget, main);
    final table = ref
        .watch(rateRegistryProvider)
        .tableFor(ref.watch(selectedYearMonthProvider));

    return reimbursementsAsync.when(
      data: (reimbursements) {
        if (reimbursements.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reimbursements.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final reimb = reimbursements[index];
                // T159: the history is read-only, so it reads in the display
                // currency; long-press reveals the amount as recorded. The
                // entry sheet keeps saving in the expense currency.
                final from = reimb.currencyCode;
                final formatted = from == null
                    ? null
                    : formatRefundConversion(reimb, display, table);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    child:
                        const Icon(Icons.currency_exchange, color: Colors.blue),
                  ),
                  title: formatted == null
                      ? Text(
                          '${reimb.amount} ${reimb.currency} · Rate unavailable',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : ConvertedAmountText(
                          text: formatted.text,
                          originalText: formatted.originalText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat.yMMMd().format(reimb.date)),
                      if (reimb.note != null && reimb.note!.isNotEmpty)
                        Text(
                          reimb.note!,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading reimbursements: $e')),
    );
  }
}
