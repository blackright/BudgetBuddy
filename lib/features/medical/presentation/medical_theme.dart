import 'package:flutter/material.dart';

import '../../../core/models/medical_bill.dart';

/// Shared visual tokens for the medical screens.
///
/// Centralises the UX-001 / UX-002 rules that were previously duplicated as
/// literals across the medical screens:
/// - **UX-001**: every surface derives from the active [ThemeData], so the
///   screens render correctly in dark mode.
/// - **UX-002**: light mode uses a soft, muted background instead of harsh
///   pure white to reduce glare.
class MedicalTheme {
  const MedicalTheme._();

  /// Soft light-mode background (not pure white) and a near-black dark surface.
  static const Color softLightBackground = Color(0xFFF4F5F7);
  static const Color darkBackground = Color(0xFF121212);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Page background honouring UX-001 / UX-002.
  static Color background(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (isDark(context)) return darkBackground;
    // Muted grey-blue rather than pure white, so cards still stand out.
    return Color.alphaBlend(
      scheme.primary.withValues(alpha: 0.04),
      softLightBackground,
    );
  }

  /// Card surface, one step above [background].
  static Color surface(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (isDark(context)) return scheme.surfaceContainerHigh;
    return Colors.white;
  }

  /// Muted, low-contrast text used for supporting labels.
  static Color subtleText(BuildContext context) =>
      isDark(context) ? Colors.white70 : Colors.black54;

  /// Accent colour for a claim status chip / icon.
  static Color claimStatusColor(BuildContext context, ClaimStatus status) {
    switch (status) {
      case ClaimStatus.unclaimed:
        return Colors.orange;
      case ClaimStatus.processing:
        return Colors.blue;
      case ClaimStatus.reimbursed:
        return Colors.green;
      case ClaimStatus.denied:
        return Colors.red;
    }
  }

  static IconData claimStatusIcon(ClaimStatus status) {
    switch (status) {
      case ClaimStatus.unclaimed:
        return Icons.help_outline;
      case ClaimStatus.processing:
        return Icons.autorenew;
      case ClaimStatus.reimbursed:
        return Icons.verified_outlined;
      case ClaimStatus.denied:
        return Icons.cancel_outlined;
    }
  }

  /// Money rendered the way the rest of the app does it. [currencySymbol]
  /// comes from the active budget so amounts follow the primary currency.
  static String money(String currencySymbol, double amount) =>
      '$currencySymbol${amount.toStringAsFixed(2)}';
}
