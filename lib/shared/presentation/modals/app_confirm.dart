import 'package:flutter/material.dart';

import 'app_dialog.dart';

/// Shows the shared confirmation dialog and returns `true` for the primary
/// action, `false` for cancel, and `null` when the route is dismissed.
///
/// A [busy] confirmation cannot be dismissed by the barrier, the system back
/// gesture or its own actions until the caller closes it.
Future<bool?> showAppConfirm(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
  bool busy = false,
  IconData? icon,
}) {
  return showAppDialog<bool>(
    context: context,
    barrierDismissible: !busy,
    builder: (_) => AppConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
      busy: busy,
      icon: icon,
    ),
  );
}

/// The shared short-confirmation content.
///
/// Destructive actions use the theme error colour and actions are disabled
/// while the caller reports a busy save.
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.destructive = false,
    this.busy = false,
    this.icon,
  });

  final String title;
  final String? message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;
  final bool busy;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = destructive ? scheme.error : scheme.primary;
    return PopScope(
      canPop: !busy,
      child: AppDialog(
        icon: icon == null && !destructive
            ? null
            : Icon(icon ?? Icons.warning_amber_rounded),
        iconColor: accent,
        title: Text(title, key: const Key('appConfirmTitle')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message != null)
              Text(message!, key: const Key('appConfirmMessage')),
            if (busy)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: LinearProgressIndicator(key: Key('appConfirmBusy')),
              ),
          ],
        ),
        actions: [
          TextButton(
            key: const Key('appConfirmCancel'),
            onPressed: busy ? null : () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            key: const Key('appConfirmConfirm'),
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: busy ? null : () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
