import 'package:flutter/material.dart';

/// Shared geometry and timing for the app's dialog, sheet, picker and menu
/// surfaces.
///
/// Keeping these values in one place is what makes the overlays feel like one
/// system instead of a collection of one-off layouts. Colours are deliberately
/// absent: every surface derives its colour from the active [ColorScheme].
abstract final class AppModalTokens {
  static const double dialogRadius = 28;
  static const double sheetRadius = 28;
  static const double menuRadius = 16;
  static const double dialogMaxWidth = 560;
  static const double sheetMaxWidth = 640;

  static const EdgeInsets dialogInsetPadding =
      EdgeInsets.symmetric(horizontal: 24, vertical: 24);
  static const EdgeInsets dialogActionsPadding =
      EdgeInsets.fromLTRB(24, 0, 24, 20);
  static const EdgeInsets sheetHeaderPadding =
      EdgeInsets.fromLTRB(20, 4, 12, 12);
  static const EdgeInsets sheetBodyPadding = EdgeInsets.fromLTRB(20, 0, 20, 16);
  static const EdgeInsets sheetFooterPadding =
      EdgeInsets.fromLTRB(20, 12, 20, 16);

  static const Size dragHandleSize = Size(36, 4);
  static const Duration keyboardInsetDuration = Duration(milliseconds: 180);

  static const BoxConstraints sheetConstraints =
      BoxConstraints(maxWidth: sheetMaxWidth);
}
