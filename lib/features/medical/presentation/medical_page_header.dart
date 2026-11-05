import 'package:flutter/material.dart';

import 'medical_theme.dart';

/// One page-level title and optional trailing action.
class MedicalPageHeader extends StatelessWidget {
  const MedicalPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final subtle =
        TextStyle(fontSize: 12, color: MedicalTheme.subtleText(context));
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          MedicalTheme.screenGutter, 8, MedicalTheme.screenGutter, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                    const SizedBox(height: 2),
                    Text(subtitle!, style: subtle),
                  ],
                ],
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
