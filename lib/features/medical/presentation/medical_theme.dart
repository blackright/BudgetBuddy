import 'package:flutter/material.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/medical_bill.dart';
import '../../../shared/presentation/money_format.dart';

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

  // ---------------------------------------------------------------------------
  // Semantic money tokens (FR-019, FR-020)
  //
  // Colour carries meaning here, so these are the only sanctioned literals for
  // the four money roles. Screens must reference these rather than picking a
  // green/red/orange of their own, which is what stops two screens from
  // disagreeing about what a figure means.
  // ---------------------------------------------------------------------------

  /// Money coming in: income, and money returned to the user.
  static const Color moneyIn = Color(0xFF2E7D32);

  /// Money going out: amounts that have actually left the account.
  static const Color moneyOut = Color(0xFFC62828);

  /// Money committed to but not yet spent.
  static const Color planned = Color(0xFFEF6C00);

  /// Money in the bank — deliberately neutral. It is a position, not a
  /// movement, so it must not read as a gain or a loss.
  static const Color bank = Color(0xFF546E7A);

  /// Money-role colour resolved against the active theme.
  ///
  /// Dark mode lifts the tones so they keep contrast against dark surfaces.
  static Color semantic(BuildContext context, Color token) {
    if (!isDark(context)) return token;
    final hsl = HSLColor.fromColor(token);
    return hsl.withLightness((hsl.lightness + 0.18).clamp(0.0, 1.0)).toColor();
  }

  /// Accent colour for a bill-state chip / icon (SC-007).
  ///
  /// `planned` is neutral because it is a commitment rather than an event, and
  /// `finished` shares the positive tone with a settled payer.
  static Color billStateColor(BuildContext context, MedicalBillState state) {
    switch (state) {
      case MedicalBillState.planned:
        return Colors.blueGrey;
      case MedicalBillState.waiting:
        return Colors.orange;
      case MedicalBillState.paid:
        return Colors.blue;
      case MedicalBillState.finished:
        return Colors.green;
      case MedicalBillState.rejected:
        return Colors.red;
    }
  }

  static IconData billStateIcon(MedicalBillState state) {
    switch (state) {
      case MedicalBillState.planned:
        return Icons.event_note_outlined;
      case MedicalBillState.waiting:
        return Icons.help_outline;
      case MedicalBillState.paid:
        return Icons.autorenew;
      case MedicalBillState.finished:
        return Icons.verified_outlined;
      case MedicalBillState.rejected:
        return Icons.cancel_outlined;
    }
  }

  /// Money rendered through the app's single formatter (FR-018), so medical
  /// figures obey the same exponent rules — HUF has no decimals, the rest two —
  /// and never hardcode a symbol (defect D10).
  static String money(CurrencyCode currency, num amount) =>
      formatMajorUnits(amount, currency);

  /// Renders money stored in minor units.
  static String moneyMinor(CurrencyCode currency, int minorUnits) =>
      formatMinorUnits(minorUnits, currency);
}
