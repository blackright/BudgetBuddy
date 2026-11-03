import 'package:flutter/material.dart';

import 'medical_theme.dart';

/// A label and money value that stays paired at narrow widths and large text.
class MedicalMoneyRow extends StatelessWidget {
  const MedicalMoneyRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
    this.compact = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: compact ? 12 : null,
      color: MedicalTheme.subtleText(context),
    );
    final valueStyle = TextStyle(
      fontSize: compact ? 13 : null,
      fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
      color: valueColor,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 320) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: labelStyle),
              const SizedBox(height: 2),
              Text(value, style: valueStyle),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(label, style: labelStyle)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: valueStyle,
              ),
            ),
          ],
        );
      },
    );
  }
}
