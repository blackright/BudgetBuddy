import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../domain/pairing_protocol.dart';
import '../providers/pairing_providers.dart';
import 'widgets/qr_panel.dart';
import 'widgets/scan_error_panel.dart';

/// US7 (T062): the **scanner** side of an identity pairing.
///
/// Scans the other person's identity code, confirms their fingerprint, then
/// shows this device's reply code for them to scan. Fully offline.
///
/// A refused scan **latches**: the camera stops and the reason is shown once by
/// [ScanErrorPanel], so a wrong or expired code cannot repeat its message every
/// frame.
class ScanIdentityCodeScreen extends ConsumerStatefulWidget {
  const ScanIdentityCodeScreen({super.key});

  @override
  ConsumerState<ScanIdentityCodeScreen> createState() =>
      ScanIdentityCodeScreenState();
}

class ScanIdentityCodeScreenState
    extends ConsumerState<ScanIdentityCodeScreen> {
  PairingClaim? _reply;
  String? _addedName;
  String? _error;
  bool _busy = false;

  /// Clears a latched refusal and resumes the camera.
  void retry() {
    setState(() => _error = null);
  }

  /// Stops the camera and shows [message] exactly once.
  void _fail(String message) {
    if (!mounted) return;
    setState(() => _error = message);
  }

  /// Handles one scanned string. Exposed so a test can drive the flow without a
  /// camera; the live path calls it from `MobileScanner.onDetect`.
  Future<void> handleScanned(String raw) async {
    if (_busy) return;
    final service = ref.read(pairingServiceProvider);
    if (service == null) {
      _fail('Create your identity first.');
      return;
    }
    // Friendly nudge for the most common mistake: scanning a reply code where
    // an identity code was expected.
    if (pairingCodeKindOf(raw) != PairingCodeKind.identity) {
      _fail(
        "That's not someone's identity code. Ask them to show their code "
        'first, then scan it here.',
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final payload = await service.parseIdentityPayload(raw);
      if (!mounted) return;
      final confirmed = await _confirmScanned(payload);
      if (confirmed != true || !mounted) return;
      final peer = await service.acceptIdentityPayload(payload);
      if (!mounted) return;
      setState(() {
        _addedName = peer.peerUsername;
        _reply = service.identityClaimFrom(payload);
        _error = null;
      });
    } on PairingException catch (error) {
      _fail(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) {
    final raw =
        capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
    if (raw == null) return Future<void>.value();
    return handleScanned(raw);
  }

  Future<bool?> _confirmScanned(PairingIdentityPayload payload) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add this person?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${payload.username} (${payload.fingerprint})',
                key: const Key('scannedIdentity')),
            const SizedBox(height: 8),
            const Text(
              'Only continue if the fingerprint above matches what the other '
              'person sees on their screen.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirmScannedIdentityButton'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan a code')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final reply = _reply;
    if (reply != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline,
                size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text('You added $_addedName.',
                key: const Key('identityScanSuccess'),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Text('Let them scan this reply to finish.'),
            const SizedBox(height: 16),
            QrPanel(key: const Key('identityReplyQr'), data: reply.encode()),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('identityReplyDoneButton'),
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
    final error = _error;
    if (error != null) {
      return Center(child: ScanErrorPanel(message: error, onRetry: retry));
    }
    return MobileScanner(
      key: const Key('identityScanner'),
      onDetect: _busy ? (_) {} : _onDetect,
    );
  }
}
