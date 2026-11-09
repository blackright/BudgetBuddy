import 'package:flutter/material.dart';

/// One full-width row in the Settings hub.
///
/// The anatomy follows the approved Settings contract: a 40 dp icon tile, a
/// title, a muted summary, an optional trailing control and a disclosure
/// chevron. The row needs a Material ancestor (the hub card provides one) so
/// the [InkWell] can paint its splash.
///
/// When [trailing] is interactive, pass `excludeSemantics: false` so the
/// control keeps its own semantics node. Rows without a trailing control
/// announce the supplied [semanticLabel] as one concise action.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    required this.summary,
    required this.icon,
    this.onTap,
    this.trailing,
    this.showChevron = true,
    this.showDivider = false,
    this.semanticLabel,
    this.excludeSemantics = true,
    this.minHeight = 56,
  });

  final String title;
  final String summary;
  final IconData icon;
  final VoidCallback? onTap;

  /// An optional control shown before the chevron, such as the Security
  /// row's app-lock switch.
  final Widget? trailing;

  final bool showChevron;
  final bool showDivider;

  /// The complete announcement for the row, including its value and action.
  final String? semanticLabel;

  /// Whether [semanticLabel] replaces the child semantics. Set this to `false`
  /// when [trailing] is an interactive control that must keep its own node.
  final bool excludeSemantics;

  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
            if (showChevron) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
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
      excludeSemantics: semanticLabel != null && excludeSemantics,
      child: interactive,
    );

    if (!showDivider) return row;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row,
        Divider(
          height: 1,
          thickness: 1,
          indent: 68,
          endIndent: 16,
          color: scheme.outlineVariant,
        ),
      ],
    );
  }
}
