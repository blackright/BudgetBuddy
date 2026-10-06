import 'package:flutter/material.dart';

/// The Material time picker's keyboard-entry layout cannot be built at a small
/// text scale, so this is the floor we let it see.
///
/// Flutter sizes the input-mode dialog as `_kTimePickerInputSize.height *
/// textScale` (`time_picker.dart`, `_dialogSize`), where the base height is
/// 252. It then clamps that against `_kTimePickerMinInputSize.height` (196) and
/// finally asks the `AnimatedContainer` for `minHeight:
/// _kTimePickerInputMinimumHeight` (216) with that value as `maxHeight`. Those
/// two constants are inconsistent - 196 is smaller than 216 - so any text scale
/// in `[196 / 252, 216 / 252)` = `[0.778, 0.857)` inverts the constraints and
/// Flutter throws `BoxConstraints has non-normalized height constraints`
/// (thrown from the `AnimatedContainer` constructor, reported against
/// `_TimePickerDialogState.build`). Android's *Smallest* font setting is 0.85,
/// which is inside that window, so this is reachable for real users rather
/// than only under an exotic scale.
///
/// 0.9 rather than the exact 216 / 252 boundary, because landing on the
/// boundary is within float rounding of 216 and would be flaky. 0.9 gives a
/// dialog height of 226.8, a 5% margin over the floor.
const double _kMinSafeTimePickerTextScale = 0.9;

/// Presents [TimePickerDialog] with the text scale clamped to a value its
/// input-entry layout can actually be built at.
///
/// Only the picker is clamped. The rest of the app keeps whatever platform font
/// scale the user chose, and large scales are left alone - Flutter already caps
/// its own dialog size growth at 1.1 (`clamp(maxScaleFactor: 1.1)`), so a floor
/// here cannot fight it.
///
/// The clamp does not touch [MediaQueryData.viewInsets]: `Dialog` and
/// `DialogRoute` lay out from `MediaQuery.removePadding`, never from the
/// keyboard inset, so zeroing it does not affect this crash and would only hide
/// the real inset from the picker's own text fields.
Future<TimeOfDay?> showSafeTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (BuildContext context, Widget? child) {
      final MediaQueryData data = MediaQuery.of(context);
      return MediaQuery(
        data: data.copyWith(
          textScaler:
              data.textScaler.clamp(minScaleFactor: _kMinSafeTimePickerTextScale),
        ),
        child: child!,
      );
    },
  );
}