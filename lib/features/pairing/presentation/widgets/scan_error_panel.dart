import 'package:flutter/material.dart';

/// The latched error shown after a **bad scan** (US7).
///
/// `MobileScanner` fires once per camera frame while a code is in view, so a
/// refusal must not be surfaced as a repeatable toast: this panel stops the
/// camera, shows the reason exactly once, and only resumes when the person
/// deliberately taps **Scan again**.
class ScanErrorPanel extends StatelessWidget {
  const ScanErrorPanel({
    super.key,
    required this.message,
    required this.onRetry,
  });

  /// The refusal reason, shown verbatim.
  final String message;

  /// Restarts the camera.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(
            message,
            key: const Key('scanErrorMessage'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const Key('scanAgainButton'),
            onPressed: onRetry,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan again'),
          ),
        ],
      ),
    );
  }
}
