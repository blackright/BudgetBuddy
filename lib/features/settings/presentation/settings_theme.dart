import 'package:flutter/material.dart';

/// Applies the Settings card style to a subtree.
///
/// Reused Settings widgets already render [Card]s. This local theme keeps those
/// cards consistent with the hub — 20 dp radius, no elevation and a visible
/// outline in both light and dark mode — without changing the global app theme.
class SettingsCardTheme extends StatelessWidget {
  const SettingsCardTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Theme(
      data: theme.copyWith(
        cardTheme: CardThemeData(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: scheme.outlineVariant),
          ),
        ),
      ),
      child: child,
    );
  }
}
