import 'package:flutter/material.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/services/quantity_math.dart';
import '../money_format.dart';

/// A compact `quantity × unit price = line total` summary.
///
/// The parent supplies [totalMinor] when it already has a checked total (for
/// example a saved purchase total that needs correction); otherwise the total
/// is derived from [unitMinor] and [quantity].
class LineTotalPreview extends StatelessWidget {
  const LineTotalPreview({
    super.key,
    required this.unitMinor,
    required this.quantity,
    required this.currency,
    this.totalMinor,
    this.note,
    this.errorText,
  });

  final int? unitMinor;
  final int quantity;
  final CurrencyCode? currency;
  final int? totalMinor;
  final String? note;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context), scheme = theme.colorScheme;
    final code = currency;
    final derived =
        quantityLineTotalMinor(unitMinor: unitMinor ?? 0, quantity: quantity);
    final total = totalMinor ?? derived;
    final unitText = unitMinor == null || code == null
        ? null
        : formatMinorUnits(unitMinor!, code);
    final totalText =
        total == null || code == null ? null : formatMinorUnits(total, code);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Line total',
            style: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          totalText ?? 'Enter a valid unit price',
          style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: errorText == null ? scheme.onSurface : scheme.error),
        ),
        if (quantity > 1 && unitText != null)
          Text(
            '$quantity × $unitText',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ),
        if (note != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              note!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}
