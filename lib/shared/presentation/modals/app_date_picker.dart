import 'package:flutter/material.dart';

/// Presents the themed application date picker.
///
/// The native Material picker is retained; the shared [ThemeData.datePickerTheme]
/// supplies its surface, shape and accent colours.
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  String? helpText,
  String? cancelText,
  String? confirmText,
  String? fieldLabelText,
  String? fieldHintText,
  String? errorFormatText,
  String? errorInvalidText,
  RouteSettings? routeSettings,
  TransitionBuilder? builder,
  bool useRootNavigator = true,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    initialEntryMode: initialEntryMode,
    initialDatePickerMode: initialDatePickerMode,
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
    fieldLabelText: fieldLabelText,
    fieldHintText: fieldHintText,
    errorFormatText: errorFormatText,
    errorInvalidText: errorInvalidText,
    routeSettings: routeSettings,
    builder: builder,
    useRootNavigator: useRootNavigator,
  );
}

/// The Material time picker's keyboard-entry layout cannot be built at a small
/// text scale, so this is the floor we let it see.
///
/// Flutter sizes the input-mode dialog as `_kTimePickerInputSize.height *
/// textScale`, then clamps it against two inconsistent constants. Any scale in
/// `[196 / 252, 216 / 252)` inverts the constraints and throws
/// `BoxConstraints has non-normalized height constraints`.
const double _kMinSafeTimePickerTextScale = 0.9;

/// Presents the themed application time picker with the existing safety clamps:
/// a minimum text scale and a bounded keyboard inset keep the input layout
/// buildable on small screens.
Future<TimeOfDay?> showAppTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  bool useRootNavigator = true,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context, Widget? child) {
      final data = MediaQuery.of(context);

      // TimePickerDialog requires at least ~216px of height, but calculates
      // availableHeight = size.height - viewInsets.bottom. If the keyboard is
      // very tall this becomes smaller than the minHeight and crashes with
      // non-normalized BoxConstraints.
      final maxSafeInset =
          (data.size.height - 250.0).clamp(0.0, double.infinity);
      final safeBottomInset = data.viewInsets.bottom > maxSafeInset
          ? maxSafeInset
          : data.viewInsets.bottom;

      return MediaQuery(
        data: data.copyWith(
          textScaler: data.textScaler
              .clamp(minScaleFactor: _kMinSafeTimePickerTextScale),
          viewInsets: data.viewInsets.copyWith(bottom: safeBottomInset),
        ),
        child: child!,
      );
    },
  );
}
