import 'package:flutter/material.dart';

import 'medical_theme.dart';

/// Shared empty/error state with one clear next step.
class MedicalEmptyState extends StatelessWidget {
  const MedicalEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actions = const [],
    this.isError = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final List<Widget> actions;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? MedicalTheme.semantic(context, MedicalTheme.moneyOut)
        : MedicalTheme.subtleText(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: MedicalTheme.subtleText(context)),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: actions,
            ),
          ],
        ],
      ),
    );
  }
}
