import 'package:flutter/material.dart';

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

  return ThemeData(
    colorScheme: scheme,
    fontFamily: fontFamily,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surface,
  );
}
