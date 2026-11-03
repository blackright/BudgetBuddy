import 'package:flutter/material.dart';

import 'medical_theme.dart';

/// Shared sheet header: one title, optional explanation and a close action.
class MedicalSheetHeader extends StatelessWidget {
  const MedicalSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onClose,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                        fontSize: 13,
                        color: MedicalTheme.subtleText(context)),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (onClose != null)
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
                minimumSize: const Size(48, 48)),
          ),
      ],
    );
  }
}
