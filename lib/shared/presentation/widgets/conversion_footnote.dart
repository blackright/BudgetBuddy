import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/network/rate_types.dart';

/// `1 $ = 345 Ft` — the cross-rate caption the footnote and the expense-form
/// hint both render (T054, T056): main units per one display unit.
String crossRateCaption(CurrencyCode display, CurrencyCode main, double rate) =>
    '1 ${display.symbol} = ${_formatRate(rate)} ${main.symbol}';

String _formatRate(double rate) =>
    rate.toStringAsFixed(2).replaceFirst(RegExp(r'\.00$'), '');

/// The one-line caption that names the conversion every figure above went
/// through (T054): `1 $ = 345 Ft · live rate · 2026-02-01`.
///
/// Rendered only when [display] differs from the main currency — a screen that
/// only ever shows one currency has no conversion to explain — and honours
/// FR-014 by never inventing a rate: when the governing [table] has no usable
/// cross-rate the row shows an explicit unavailable marker rather than a
/// fabricated `1.0`. There is no separate rate screen; the provenance lives on
/// the caption itself.
class ConversionFootnote extends StatelessWidget {
  const ConversionFootnote({
    super.key,
    required this.main,
    required this.display,
    required this.table,
  });

  final CurrencyCode main;
  final CurrencyCode display;
  final RateTable? table;

  @override
  Widget build(BuildContext context) {
    if (main == display) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    final rate = table?.crossRate(display, main);
    if (rate == null) {
      final error = theme.colorScheme.error;
      return Padding(
        key: const Key('conversionFootnote'),
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 14, color: error),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Rate unavailable — the figures above are shown as recorded.',
                style: style?.copyWith(color: error),
              ),
            ),
          ],
        ),
      );
    }

    final parts = <String>[
      crossRateCaption(display, main, rate),
      _sourceLabel(table!.source),
      DateFormat('yyyy-MM-dd').format(table!.asOf),
      if (table!.isStale && table!.source != RateSource.bundled) 'stale',
    ];

    return Padding(
      key: const Key('conversionFootnote'),
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.currency_exchange, size: 14, color: style?.color),
          const SizedBox(width: 6),
          Expanded(child: Text(parts.join(' · '), style: style)),
        ],
      ),
    );
  }

  static String _sourceLabel(RateSource source) => switch (source) {
        RateSource.live => 'live rate',
        RateSource.historical => 'sealed at month close',
        RateSource.lastKnown => 'last known rate',
        RateSource.bundled => 'offline estimate',
      };
}
