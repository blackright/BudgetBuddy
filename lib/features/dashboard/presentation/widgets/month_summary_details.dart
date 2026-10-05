import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../engine/providers/month_summary_provider.dart';
import '../../../medical/presentation/medical_theme.dart';

/// The supporting detail behind the month's headline figures, collapsed by
/// default (FR-021).
///
/// The headline card answers "what did I keep". This answers "why", for the
/// handful of figures that are worth checking rather than reading at a glance:
/// the bank position, the medical portion of the month's spending, what was
/// cancelled, whether the salary is an override, and any over-reimbursement.
///
/// The handful of figures that are worth checking rather than reading at a glance:
/// the medical portion of the month's spending, what was
/// cancelled, whether the salary is an override, and any over-reimbursement.
class MonthSummaryDetails extends ConsumerWidget {
  const MonthSummaryDetails({
    super.key,
    required this.currencySymbol,
    this.onMedicalTap,
  });

  final String currencySymbol;

  final VoidCallback? onMedicalTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthSummaryProvider);

    return Card(
      elevation: 1,
      child: ExpansionTile(
        key: const Key('summaryDetails'),
        title: const Text('Details'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          _DetailLine(
            label: 'Medical',
            value: _money(summary.medicalPaid),
            valueKey: const Key('medicalLine'),
            color: MedicalTheme.semantic(context, MedicalTheme.moneyOut),
            onTap: onMedicalTap,
          ),
          _DetailLine(
            label: 'Cancelled',
            value: _money(summary.cancelled),
            valueKey: const Key('cancelledLine'),
            color: MedicalTheme.semantic(context, MedicalTheme.bank),
          ),
          if (summary.excessReturned > 0)
            _DetailLine(
              label: 'Excess returned',
              value: _money(summary.excessReturned),
              valueKey: const Key('excessLine'),
              color: MedicalTheme.semantic(context, MedicalTheme.moneyIn),
            ),
          if (summary.usesOverriddenIncome)
            Padding(
              key: const Key('overrideMarker'),
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Salary set for this month only',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _money(double amount) => MedicalTheme.money(currencySymbol, amount);
}

/// One labelled detail amount, optionally tappable.
class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.value,
    required this.valueKey,
    required this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final Key valueKey;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Container(
      key: valueKey,
      child: Text(
        value,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          if (onTap == null)
            text
          else
            InkWell(
              onTap: onTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  text,
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
