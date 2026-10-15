import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/currency_code.dart';
import '../../../../core/models/money.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../providers/reimbursement_provider.dart';

class ReimbursementHistoryList extends ConsumerWidget {
  final int expenseId;

  const ReimbursementHistoryList({
    super.key,
    required this.expenseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reimbursementsAsync =
        ref.watch(reimbursementsByExpenseProvider(expenseId));

    return reimbursementsAsync.when(
      data: (reimbursements) {
        if (reimbursements.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Reimbursement History',
                style: TextStyle(
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
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    child:
                        const Icon(Icons.currency_exchange, color: Colors.blue),
                  ),
                  title: Text(
                    formatMoney(
                      Money(
                        reimb.amount,
                        reimb.currencyCode ?? CurrencyCode.huf,
                      ),
                    ),
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
