import 'package:flutter/material.dart';

enum FinancialFeedbackKind { success, warning, error }

/// One short result per explicit action. Durable errors stay in their forms.
void showFinancialFeedback(BuildContext context, String message,
    {FinancialFeedbackKind kind = FinancialFeedbackKind.success}) {
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.removeCurrentSnackBar();
  messenger.showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(seconds: kind == FinancialFeedbackKind.success ? 3 : 6),
    backgroundColor: kind == FinancialFeedbackKind.error
        ? Theme.of(context).colorScheme.error
        : null,
  ));
}

/// Reports success only after the operation commits; preserves failed forms.
Future<bool> runFinancialAction(BuildContext context,
    {required Future<void> Function() action,
    required String success,
    required String failure}) async {
  try {
    await action();
    if (context.mounted) showFinancialFeedback(context, success);
    return true;
  } catch (_) {
    if (context.mounted) {
      showFinancialFeedback(context, failure,
          kind: FinancialFeedbackKind.error);
    }
    return false;
  }
}
