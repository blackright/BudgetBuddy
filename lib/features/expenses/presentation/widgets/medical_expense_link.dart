import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/budget_context_provider.dart';
import '../../../medical/providers/medical_providers.dart';

/// Expenses is a spending view of the same bill, never another Medical editor.
class MedicalExpenseLink extends ConsumerWidget {
  const MedicalExpenseLink({super.key, required this.expenseId});
  final int expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final link = ref.watch(medicalBillForExpenseProvider(expenseId));
    final colors = Theme.of(context).colorScheme;
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Icon(Icons.medical_services_outlined, color: colors.primary),
            const SizedBox(width: 12),
            Expanded(
                child: Text('Medical expense',
                    style: Theme.of(context).textTheme.titleMedium)),
          ]),
          const SizedBox(height: 8),
          const Text('This is the spending record of your Medical bill. '
              'It is counted once. Manage payment and insurance in Medical.'),
          const SizedBox(height: 12),
          link.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text(
                'The bill link could not be verified. Open Medical to review it.'),
            data: (bill) => bill == null
                ? const Text(
                    'No linked bill is available in this budget month. '
                    'Open Medical to review it.')
                : FilledButton.tonalIcon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('View Medical claim'),
                    onPressed: () {
                      final current =
                          ref.read(medicalBillForExpenseProvider(expenseId));
                      final scope = ref.read(budgetContextProvider);
                      final sameOwner = scope.isShared
                          ? bill.sharedSpaceId == scope.spaceId
                          : bill.sharedSpaceId == null &&
                              bill.profileId == scope.profileId;
                      if (!current.isLoading &&
                          !current.hasError &&
                          current.valueOrNull?.id == bill.id &&
                          sameOwner &&
                          bill.yearMonth == scope.yearMonth) {
                        context.push('/medical_detail', extra: bill.id);
                      }
                    }),
          ),
        ]),
      ),
    );
  }
}
