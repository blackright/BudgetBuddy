import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/engine/providers/month_summary_provider.dart';

/// Warns that the selected month cannot yet be judged (FR-025).
///
/// A month needs both an opening balance and a recorded income before "kept"
/// means anything. Rather than showing a confident zero, the app says what is
/// missing. Planned expenses never satisfy this: they are commitments, not
/// settled money.
class MonthIncompleteBanner extends ConsumerWidget {
  const MonthIncompleteBanner({super.key, required this.currencySymbol});

  final String currencySymbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthSummaryProvider);
    if (summary.isComplete) return const SizedBox.shrink();

    final missing = <String>[
      if (summary.income <= 0) 'Net salary',
    ];

    return Container(
      key: const Key('monthIncompleteBanner'),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Add your ${missing.join(' and ')} to see what you kept this month.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
