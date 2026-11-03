import 'package:flutter/material.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/services/medical_management_reducer.dart';
import '../../../shared/presentation/money_format.dart';
import 'medical_bill_view_state.dart';

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

  /// Inbox group colour. Always paired with the group icon and text.
  static Color inboxGroupColor(BuildContext context, MedicalInboxGroup group) {
    final base = switch (group) {
      MedicalInboxGroup.needsYou => moneyOut,
      MedicalInboxGroup.waiting => planned,
      MedicalInboxGroup.closed => bank,
    };
    return semantic(context, base);
  }

  static IconData inboxGroupIcon(MedicalInboxGroup group) => switch (group) {
        MedicalInboxGroup.needsYou => Icons.notifications_active_outlined,
        MedicalInboxGroup.waiting => Icons.hourglass_top_outlined,
        MedicalInboxGroup.closed => Icons.inventory_2_outlined,
      };

  /// Status accent for the new management stages. Text and an icon always
  /// accompany the colour, so colour is never the only signal.
  static Color managementStageColor(
      BuildContext context, MedicalManagementStage stage) {
    final base = switch (stage) {
      MedicalManagementStage.needsReview => planned,
      MedicalManagementStage.planned => Colors.blueGrey,
      MedicalManagementStage.receiptPending => Colors.blue,
      MedicalManagementStage.inProgress => Colors.indigo,
      MedicalManagementStage.approved => moneyIn,
      MedicalManagementStage.waitingForPayslip => planned,
      MedicalManagementStage.rejected => moneyOut,
      MedicalManagementStage.appeal => Colors.purple,
      MedicalManagementStage.requestCancelled => bank,
      MedicalManagementStage.completed => Colors.teal,
      MedicalManagementStage.closed => moneyIn,
      MedicalManagementStage.cancelled => bank,
    };
    return semantic(context, base);
  }

  static IconData managementStageIcon(MedicalManagementStage stage) =>
      switch (stage) {
        MedicalManagementStage.needsReview => Icons.rate_review_outlined,
        MedicalManagementStage.planned => Icons.event_note_outlined,
        MedicalManagementStage.receiptPending => Icons.mark_email_read_outlined,
        MedicalManagementStage.inProgress => Icons.hourglass_top_outlined,
        MedicalManagementStage.approved => Icons.verified_outlined,
        MedicalManagementStage.waitingForPayslip =>
          Icons.account_balance_wallet_outlined,
        MedicalManagementStage.rejected => Icons.cancel_outlined,
        MedicalManagementStage.appeal => Icons.gavel_outlined,
        MedicalManagementStage.requestCancelled => Icons.block_outlined,
        MedicalManagementStage.completed => Icons.task_alt_outlined,
        MedicalManagementStage.closed => Icons.inventory_2_outlined,
        MedicalManagementStage.cancelled => Icons.block_outlined,
      };

  /// Minimum logical touch target used by inbox cards and filters.
  static const double minTouchTarget = 48;

  /// v2 spacing and shape tokens. Screens should use these instead of ad-hoc
  /// literals so the Medical surfaces stay consistent at 320px and 200% text.
  static const double screenGutter = 16;
  static const double sectionGap = 16;
  static const double cardPadding = 16;
  static const double tightGap = 8;
  static const double cardRadius = 16;
  static const double inputRadius = 12;

  /// Money rendered from a **major-unit** value (e.g. an engine aggregate still
  /// expressed as a double), through the app's single formatter (FR-018). Most
  /// stored money is already in minor units and must use [moneyMinor] instead —
  /// passing a minor-unit int here inflates it by the currency's minor factor.
  static String moneyMajor(CurrencyCode currency, num amount) =>
      formatMajorUnits(amount, currency);

  /// Renders money stored in **minor units** (the persisted form of every
  /// amount field) through the app's single formatter (FR-018).
  static String moneyMinor(CurrencyCode currency, int minorUnits) =>
      formatMinorUnits(minorUnits, currency);
}
