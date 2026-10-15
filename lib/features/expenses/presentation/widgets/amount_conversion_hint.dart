import 'package:flutter/material.dart';

import '../../../../core/models/currency_code.dart';
import '../../../../core/models/money.dart';
import '../../../../core/network/rate_types.dart';
import '../../../../shared/presentation/money_format.dart';
import '../../../../shared/presentation/widgets/conversion_footnote.dart';
import '../../../engine/currency_conversion.dart';

/// Live preview of what a typed expense amount means in the month's display
/// currency (T056): `≈ $0.29 · at 1 $ = 345 Ft`.
///
/// Sits under the Amount field on the Add/Edit expense forms. Renders nothing
/// when the amount is empty/invalid, when the expense currency equals the
/// display currency, or when the month's table cannot convert the pair — the
/// hint never invents a figure (FR-014).
class AmountConversionHint extends StatelessWidget {
  const AmountConversionHint({
    super.key,
    required this.amount,
    required this.currency,
    required this.display,
    required this.main,
    required this.table,
  });

  /// The parsed major-unit input; `null` means the field is empty/invalid.
  final double? amount;

  /// The expense's currency (may be `null` for a legacy unsupported string).
  final CurrencyCode? currency;

  final CurrencyCode display;
  final CurrencyCode main;
  final RateTable? table;

  @override
  Widget build(BuildContext context) {
    final value = amount;
    final from = currency;
    if (value == null || value <= 0 || from == null || from == display) {
      return const SizedBox.shrink();
    }

    final result = convert(Money.fromMajor(value, from), display, table);
    if (result.isDegraded) return const SizedBox.shrink();

    final cross = table?.crossRate(display, main);
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final caption = cross == null
        ? '≈ ${formatMoney(result.amount)}'
        : '≈ ${formatMoney(result.amount)}'
            ' · at ${crossRateCaption(display, main, cross)}';

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.currency_exchange, size: 14, color: style?.color),
          const SizedBox(width: 6),
          Expanded(child: Text(caption, style: style)),
        ],
      ),
    );
  }
}
