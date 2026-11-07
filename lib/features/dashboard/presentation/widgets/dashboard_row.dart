import 'package:flutter/material.dart';

/// One flat, full-width row on the Dashboard.
///
/// The row deliberately has no card, elevation or subtitle. It keeps the
/// anatomy fixed by `contracts/dashboard-rows.md` §1: an optional leading
/// icon, a label, and a trailing value or chevron, with a full-row tap target
/// of at least 48 logical pixels.
class DashboardRow extends StatelessWidget {
  const DashboardRow({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.showDivider = false,
    this.minHeight = 56,
  });

  final String label;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// The complete announcement for the row, including its value and action.
  ///
  /// When supplied, child semantics are replaced so a screen reader hears one
  /// concise statement instead of the label and value twice.
  final String? semanticLabel;

  final bool showDivider;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            if (leading != null) ...[
              ExcludeSemantics(child: leading!),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              Flexible(child: trailing!),
            ],
          ],
        ),
      ),
    );

    final interactive =
        onTap == null ? content : InkWell(onTap: onTap, child: content);

    final row = Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      onTap: onTap,
      excludeSemantics: semanticLabel != null,
      child: interactive,
    );

    if (!showDivider) return row;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: row,
    );
  }
}
