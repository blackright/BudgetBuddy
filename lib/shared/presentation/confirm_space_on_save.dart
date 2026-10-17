import 'package:flutter/material.dart';

/// What the user chose in the shared-save confirmation dialog (US6, T054).
enum SpaceSaveDecision {
  /// Go ahead and save into the shared space.
  confirm,

  /// Do not save; the caller should let the user switch context first.
  changeContext,
}

/// US6 (T054): asks the user to confirm saving into a **shared** space.
///
/// Only call this when a shared space is active — personal saves never prompt.
/// The dialog names the space so the active context is unmistakable, which is
/// the whole point of US6 ("I cannot post to the wrong one").
///
/// Returns [SpaceSaveDecision.confirm] when the user confirms,
/// [SpaceSaveDecision.changeContext] when they choose to switch first, or
/// `null` when the dialog is dismissed (treated as "do not save").
Future<SpaceSaveDecision?> confirmSpaceOnSave(
  BuildContext context, {
  required String title,
  required String amountText,
  required String spaceName,
}) {
  return showDialog<SpaceSaveDecision>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Save to a shared space?'),
      content: Text(
        'Add "$title" ($amountText) to "$spaceName"?',
        key: const Key('confirmSpaceOnSaveMessage'),
      ),
      actions: [
        TextButton(
          key: const Key('changeContextButton'),
          onPressed: () =>
              Navigator.of(dialogContext).pop(SpaceSaveDecision.changeContext),
          child: const Text('Change context'),
        ),
        FilledButton(
          key: const Key('confirmSaveButton'),
          onPressed: () =>
              Navigator.of(dialogContext).pop(SpaceSaveDecision.confirm),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}
