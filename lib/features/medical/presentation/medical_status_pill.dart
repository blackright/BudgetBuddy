import 'package:flutter/material.dart';

import 'medical_bill_view_state.dart';
import 'medical_theme.dart';

/// Status is always text plus icon, never colour alone.
class MedicalStatusPill extends StatelessWidget {
  const MedicalStatusPill({
    super.key,
    required this.label,
    required this.group,
    this.icon,
    this.color,
  });

  final String label;
  final MedicalInboxGroup group;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? MedicalTheme.inboxGroupColor(context, group);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: resolved.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: resolved.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? MedicalTheme.inboxGroupIcon(group),
                size: 15, color: resolved),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: resolved),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
