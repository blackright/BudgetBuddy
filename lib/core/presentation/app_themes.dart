import 'package:flutter/material.dart';

import '../../shared/presentation/modals/app_modal_tokens.dart';

/// Phase 9-E (T060): the app's two Material 3 themes, built from one seed so a
/// mode switch only changes tone, never structure.
///
/// Both derive from a `Colors.deepPurple` seed via the current
/// `ColorScheme.fromSeed(...)` API and hand-rolled surface/on-surface/outline
/// tones that honour the app's existing UX rules:
/// - UX-001 every surface derives from the active theme; nothing hardcodes a
///   single-mode colour that breaks in the other mode.
/// - UX-002 the light "surface" is a soft warm off-white, not harsh pure
///   white, and its text is a warm near-black, not pure black — low glare for
///   long sessions. The dark theme uses a warm near-black surface with soft
///   off-white text and never a pure black/white pair.
///
/// [fontFamily] is applied to both modes so the Settings font choice survives
/// a mode switch (T062).
ThemeData buildAppTheme({
  required Brightness brightness,
  String? fontFamily,
}) {
  final seed = ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: brightness,
  );
  final scheme = switch (brightness) {
    Brightness.light => seed.copyWith(
        surface: const Color(0xFFFBF8F4),
        onSurface: const Color(0xFF2E2A26),
        onSurfaceVariant: const Color(0xFF5F5A53),
        outline: const Color(0xFF8A8074),
        outlineVariant: const Color(0xFFD6CCC0),
        surfaceContainerLowest: const Color(0xFFFDFBF8),
        surfaceContainerLow: const Color(0xFFF4F0EA),
        surfaceContainer: const Color(0xFFEFEAE3),
        surfaceContainerHigh: const Color(0xFFE9E3DB),
        surfaceContainerHighest: const Color(0xFFE3DCD4),
      ),
    Brightness.dark => seed.copyWith(
        surface: const Color(0xFF181512),
        onSurface: const Color(0xFFEDE8E3),
        onSurfaceVariant: const Color(0xFFCFC8C0),
        outline: const Color(0xFF9C9385),
        outlineVariant: const Color(0xFF4F4B45),
        surfaceContainerLowest: const Color(0xFF12100D),
        surfaceContainerLow: const Color(0xFF201C19),
        surfaceContainer: const Color(0xFF25211D),
        surfaceContainerHigh: const Color(0xFF302B27),
        surfaceContainerHighest: const Color(0xFF3B3631),
      ),
  };

  final dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppModalTokens.dialogRadius),
  );
  final textTheme = ThemeData(
    colorScheme: scheme,
    fontFamily: fontFamily,
    useMaterial3: true,
  ).textTheme;

  return ThemeData(
    colorScheme: scheme,
    fontFamily: fontFamily,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surface,
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      elevation: 3,
      surfaceTintColor: Colors.transparent,
      shape: dialogShape,
      insetPadding: AppModalTokens.dialogInsetPadding,
      iconColor: scheme.primary,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
        height: 1.4,
      ),
      actionsPadding: AppModalTokens.dialogActionsPadding,
      barrierColor: scheme.scrim.withValues(alpha: 0.52),
      clipBehavior: Clip.antiAlias,
      constraints:
          const BoxConstraints(maxWidth: AppModalTokens.dialogMaxWidth),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      modalBackgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      modalElevation: 6,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppModalTokens.sheetRadius)),
      ),
      showDragHandle: true,
      dragHandleColor: scheme.onSurfaceVariant.withValues(alpha: 0.4),
      dragHandleSize: AppModalTokens.dragHandleSize,
      clipBehavior: Clip.antiAlias,
      constraints: AppModalTokens.sheetConstraints,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      elevation: 3,
      surfaceTintColor: Colors.transparent,
      shape: dialogShape,
      headerBackgroundColor: scheme.primaryContainer,
      headerForegroundColor: scheme.onPrimaryContainer,
      todayForegroundColor: WidgetStatePropertyAll<Color?>(scheme.primary),
      todayBorder: BorderSide(color: scheme.primary),
      dayShape: const WidgetStatePropertyAll<OutlinedBorder>(CircleBorder()),
      yearShape: const WidgetStatePropertyAll<OutlinedBorder>(CircleBorder()),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: 0.38);
        }
        if (states.contains(WidgetState.selected)) {
          return scheme.onPrimary;
        }
        return scheme.onSurface;
      }),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: scheme.primary,
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      elevation: 3,
      shape: dialogShape,
      dialBackgroundColor: scheme.surfaceContainerHighest,
      dialHandColor: scheme.primary,
      dialTextColor: scheme.onSurface,
      hourMinuteColor: scheme.primaryContainer,
      hourMinuteTextColor: scheme.onPrimaryContainer,
      dayPeriodColor: scheme.primaryContainer,
      dayPeriodTextColor: scheme.onPrimaryContainer,
      helpTextStyle: textTheme.labelLarge?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      cancelButtonStyle: TextButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
      ),
      confirmButtonStyle: TextButton.styleFrom(
        foregroundColor: scheme.primary,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surfaceContainerHigh,
      elevation: 3,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppModalTokens.menuRadius),
      ),
      textStyle: textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
    ),
  );
}
