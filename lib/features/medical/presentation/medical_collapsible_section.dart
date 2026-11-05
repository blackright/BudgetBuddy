import 'package:flutter/material.dart';

import 'medical_theme.dart';

/// A styled collapsible form section. Field state is kept while collapsed.
class MedicalCollapsibleSection extends StatelessWidget {
  const MedicalCollapsibleSection({
    super.key,
    required this.title,
    required this.storageKey,
    required this.children,
    this.initiallyExpanded = false,
    this.icon,
    this.accent,
  });

  final String title;
  final String storageKey;
  final List<Widget> children;
  final bool initiallyExpanded;
  final IconData? icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: MedicalTheme.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MedicalTheme.cardRadius),
        side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.55)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey(storageKey),
        initiallyExpanded: initiallyExpanded,
        maintainState: true,
        tilePadding: const EdgeInsets.symmetric(
            horizontal: MedicalTheme.cardPadding, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(MedicalTheme.cardPadding, 0,
            MedicalTheme.cardPadding, MedicalTheme.cardPadding),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        title: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (accent ?? Theme.of(context).colorScheme.primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: accent ?? Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ],
        ),
        children: children,
      ),
    );
  }
}
