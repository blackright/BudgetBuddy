import 'package:flutter/material.dart';

import 'modals/app_date_picker.dart';

/// Presents [TimePickerDialog] through the shared time-picker wrapper.
///
/// The wrapper keeps the text-scale and keyboard-inset safety clamps that make
/// the input-entry layout buildable on small screens. This name is kept for the
/// existing finance and medical call sites.
Future<TimeOfDay?> showSafeTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showAppTimePicker(
    context: context,
    initialTime: initialTime,
  );
}
