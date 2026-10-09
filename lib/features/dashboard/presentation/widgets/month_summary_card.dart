import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/currency_code.dart';
import '../../../../core/providers/selected_month_provider.dart';
import '../../../engine/providers/month_summary_provider.dart';
import '../../../engine/providers/rate_registry_provider.dart';
import '../../../medical/presentation/medical_theme.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../../../shared/presentation/widgets/conversion_footnote.dart';

/// The month's headline figures (FR-018).
///
/// The verdict the user came for — what they kept — is the largest element on
/// the screen (SC-001, SC-002) and needs no interaction to read. Everything
/// else is subordinate: one supporting line, then four labelled amounts whose
/// colour carries meaning (FR-019).
///
/// Deliberately absent: Safe to Spend and True Available. Their providers stay
/// alive for the expense screens, but the dashboard default view does not show
/// them (FR-023).
class MonthSummaryCard extends ConsumerWidget {
  const MonthSummaryCard({super.key, required this.currency});

  final CurrencyCode currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(monthSummaryProvider);

    return Card(
      key: const Key('monthSummaryCard'),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kept this month',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Center(
              child: Container(
                key: const Key('keptHero'),
                child: Text(
                  _money(summary.kept),
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: MedicalTheme.semantic(
                      context,
                      summary.kept < 0
                          ? MedicalTheme.moneyOut
                          : MedicalTheme.moneyIn,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'after ${_money(summary.paymentsMade)} paid out'
                '${summary.moneyReturned > 0 ? ', ${_money(summary.moneyReturned)} returned' : ''}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Divider(height: 28),
            _SummaryLine(
              label: 'Income',
              value: _money(summary.income),
              valueKey: const Key('incomeLine'),
              color: MedicalTheme.semantic(context, MedicalTheme.moneyIn),
            ),
            _SummaryLine(
              label: 'Paid out',
              value: _money(summary.paymentsMade),
              valueKey: const Key('paymentsLine'),
              color: MedicalTheme.semantic(context, MedicalTheme.moneyOut),
            ),
            _SummaryLine(
              label: 'Planned',
              value: _money(summary.planned),
              valueKey: const Key('plannedLine'),
              color: MedicalTheme.semantic(context, MedicalTheme.planned),
            ),
            _SummaryLine(
              label: 'Returned',
              value: _money(summary.moneyReturned),
              valueKey: const Key('returnedLine'),
              color: MedicalTheme.semantic(context, MedicalTheme.moneyIn),
            ),
            ConversionFootnote(
              main: ref.watch(mainCurrencyProvider),
              display: currency,
              table: ref.watch(rateRegistryProvider).tableFor(
                    ref.watch(selectedYearMonthProvider),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _money(double amount) => MedicalTheme.moneyMajor(currency, amount);
}

/// One labelled amount. The key sits on the value alone so a test can read its
/// colour without also matching the label.
class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    required this.valueKey,
    required this.color,
  });

  final String label;
  final String value;
  final Key valueKey;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Container(
            key: valueKey,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
