import 'package:flutter/material.dart';

/// Stable identity colours for profiles.
///
/// Red is reserved for the unbudgeted (Main / free-to-use) destination and for
/// warnings, so this palette deliberately avoids red hues. Budget-health colours
/// (on track / close / over) are a separate signal and are never used here.
const List<Color> _profileIdentityPalette = [
  Color(0xFF3949AB), // indigo
  Color(0xFF1E88E5), // blue
  Color(0xFF00897B), // teal
  Color(0xFF6A1B9A), // purple
  Color(0xFF00838F), // cyan
  Color(0xFF6D4C41), // brown
];

/// Deterministic colour for a profile identity.
///
/// Pass the portable `syncGuid` when available; the name is the fallback for a
/// legacy row without one. The same profile keeps the same colour across app
/// launches and devices, and dark mode lifts the tone for contrast.
Color profileIdentityColor(String key, {required Brightness brightness}) {
  final normalized = key.trim().toLowerCase();
  var hash = 0x811c9dc5;
  for (final unit in normalized.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  final base = _profileIdentityPalette[hash % _profileIdentityPalette.length];
  if (brightness == Brightness.light) return base;
  final hsl = HSLColor.fromColor(base);
  return hsl.withLightness((hsl.lightness + 0.18).clamp(0.0, 1.0)).toColor();
}

/// The red identity reserved for "no budget — free-to-use".
Color mainProfileColor(ColorScheme scheme) => scheme.error;

/// Convenience for widgets: prefer the stable guid, fall back to the name.
Color profileIdentity(BuildContext context,
    {String? syncGuid, required String name}) {
  final key = (syncGuid == null || syncGuid.trim().isEmpty) ? name : syncGuid;
  return profileIdentityColor(key, brightness: Theme.of(context).brightness);
}
