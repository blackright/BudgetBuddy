import 'package:flutter/material.dart';

import '../../../core/models/money.dart';
import '../../../core/network/rate_types.dart';
import '../money_format.dart';

/// Renders a converted amount beside its original, and falls back to an
/// explicit **unavailable** marker when the conversion is degraded (FR-014).
///
/// This is the one place a [`ConversionResult`] is turned into visible UI, so
/// the "never fabricate a rate" rule holds by construction: a `null` or degraded
/// result never shows a converted figure, and the original amount is displayed
/// exactly as it was recorded, with a text label (never colour alone) explaining
/// that no rate is available.
///
/// Contract: `currency-conversion.md` §2/§4.
class DegradedAmountLabel extends StatelessWidget {
  const DegradedAmountLabel({
    super.key,
    required this.original,
    this.result,
    this.style,
    this.degradedLabel = 'Rate unavailable',
  });

  /// The amount exactly as recorded — always shown.
  final Money original;

  /// The conversion outcome. `null` is treated as degraded, so a caller that
  /// never attempted a conversion cannot accidentally show an invented value.
  final ConversionResult? result;

  /// Style for the amount text. Defaults to the ambient body text style.
  final TextStyle? style;

  /// Text shown next to the original when no usable rate exists.
  final String degradedLabel;

  bool get _isDegraded => result == null || result!.isDegraded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.bodyMedium ?? const TextStyle();

    if (_isDegraded) {
      final errorColor = theme.colorScheme.error;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(formatMoney(original), style: base),
          const SizedBox(width: 6),
          Tooltip(
            message: '$degradedLabel — no exchange rate is available, so the '
                'original amount is shown as recorded.',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 14, color: errorColor),
                const SizedBox(width: 2),
                Text(
                  degradedLabel,
                  style: base.copyWith(fontSize: 11, color: errorColor),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Text(
      formatMoneyWithOriginal(converted: result!.amount, original: original),
      style: base,
    );
  }
}
