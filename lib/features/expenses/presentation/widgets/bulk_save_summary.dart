import 'package:flutter/material.dart';
import '../../../../core/models/currency_code.dart';
import '../../../../core/models/expense.dart';
import '../../../../core/services/bulk_entry_service.dart';
import '../../../../core/services/filter_service.dart';
import '../../../../shared/presentation/money_format.dart';

/// A durable handoff from recording a batch to finding its saved expenses.
class BulkSaveSummary extends StatelessWidget {
  const BulkSaveSummary(
      {super.key,
      required this.saved,
      required this.remaining,
      required this.destination,
      required this.onView});
  final List<BulkExpenseDraft> saved;
  final int remaining;
  final String destination;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), colors = Theme.of(context).colorScheme;
    final paid = saved.where((r) => r.status == ExpenseStatus.paid).length;
    final totals = <CurrencyCode, int>{};
    for (final row in saved) {
      final code = CurrencyCode.tryParse(row.currency)!;
      totals[code] = (totals[code] ?? 0) + parseSearchAmount(row.amount, code)!;
    }
    return Container(
      key: const ValueKey('bulk-save-summary'),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primaryContainer, colors.surfaceContainerLow]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.all(10),
              decoration:
                  BoxDecoration(color: colors.surface, shape: BoxShape.circle),
              child: Icon(Icons.task_alt_rounded,
                  color: colors.primary, size: 28)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Batch saved',
                    style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700, color: colors.onSurface)),
                const SizedBox(height: 4),
                Text(destination,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colors.onSurface)),
              ])),
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _Stat(
              label: '${saved.length} saved', icon: Icons.check_circle_outline),
          _Stat(
              label: '$remaining remaining',
              icon: remaining == 0 ? Icons.done_all : Icons.edit_outlined),
        ]),
        const SizedBox(height: 12),
        Text('$paid paid / ${saved.length - paid} planned',
            style:
                theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface)),
        const SizedBox(height: 4),
        for (final entry in totals.entries)
          Text(
              '${entry.key.code.toUpperCase()} ${formatMinorUnits(entry.value, entry.key)} recorded',
              style:
                  theme.textTheme.bodySmall?.copyWith(color: colors.onSurface)),
        const SizedBox(height: 12),
        Text(
            remaining == 0
                ? 'Your expenses are ready to view in the list.'
                : 'Saved rows are safe. Finish the remaining rows, or view what you saved.',
            style:
                theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface)),
        const SizedBox(height: 16),
        SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
                onPressed: onView,
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('View saved expenses'))),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
        ]),
      );
}
