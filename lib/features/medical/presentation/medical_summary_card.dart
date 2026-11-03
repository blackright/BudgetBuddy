import 'package:flutter/material.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/network/rate_types.dart';
import '../../../shared/presentation/widgets/conversion_footnote.dart';
import 'medical_theme.dart';

/// Compact Medical inbox summary. Counts are owner-wide; the amount is the
/// approved refund still expected, converted through the existing policy.
class MedicalSummaryCard extends StatelessWidget {
  const MedicalSummaryCard({
    super.key,
    required this.needsYouCount,
    required this.waitingCount,
    required this.approvedStillToReceiveMinor,
    required this.currency,
    required this.mainCurrency,
    required this.rateTable,
    this.amountsNeedReview = false,
    this.hasError = false,
  });

  final int needsYouCount;
  final int waitingCount;
  final int approvedStillToReceiveMinor;
  final CurrencyCode currency;
  final CurrencyCode mainCurrency;
  final RateTable? rateTable;
  final bool amountsNeedReview;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final subtle =
        TextStyle(fontSize: 12, color: MedicalTheme.subtleText(context));
    final attention = MedicalTheme.semantic(context, MedicalTheme.moneyOut);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          MedicalTheme.screenGutter, 8, MedicalTheme.screenGutter, 4),
      child: Card(
        key: const Key('medicalInboxSummary'),
        elevation: 0,
        color: MedicalTheme.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MedicalTheme.cardRadius),
          side: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.55)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(MedicalTheme.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Needs you', style: subtle),
                        Text(
                          '$needsYouCount',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: needsYouCount > 0 ? attention : null),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Waiting', style: subtle),
                      Text(
                        '$waitingCount',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text('Approved refunds still to receive',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      MedicalTheme.moneyMinor(
                          currency, approvedStillToReceiveMinor),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'All open bills across all months · shown in '
                '${currency.code.toUpperCase()}',
                style: subtle,
              ),
              if (amountsNeedReview)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Some amounts need review and are excluded.',
                    style: TextStyle(
                        fontSize: 12,
                        color: MedicalTheme.semantic(
                            context, MedicalTheme.planned)),
                  ),
                ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('The inbox could not be refreshed.',
                      style: TextStyle(fontSize: 12, color: attention)),
                ),
              ConversionFootnote(
                  main: mainCurrency, display: currency, table: rateTable),
            ],
          ),
        ),
      ),
    );
  }
}
