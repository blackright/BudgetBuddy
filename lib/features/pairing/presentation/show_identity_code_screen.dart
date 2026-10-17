import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../domain/pairing_protocol.dart';
import '../providers/pairing_providers.dart';
import 'widgets/qr_panel.dart';
import 'widgets/scan_error_panel.dart';

/// US7 (T062): the **presenter** side of an identity pairing.
///
/// Shows this device's space-independent identity code, then scans the other
/// person's reply. Both steps are offline QR codes — no network needed.
///
/// A refused scan **latches**: the camera stops and the reason is shown once by
/// [ScanErrorPanel], because `MobileScanner` re-fires every frame while a code
/// stays in view (otherwise the message would repeat without end).
class ShowIdentityCodeScreen extends ConsumerStatefulWidget {
  const ShowIdentityCodeScreen({super.key});

  @override
  ConsumerState<ShowIdentityCodeScreen> createState() =>
      ShowIdentityCodeScreenState();
}

class ShowIdentityCodeScreenState
    extends ConsumerState<ShowIdentityCodeScreen> {
  String? _code;
  String? _fingerprint;
  PairingIdentityInvite? _invite;
  String? _status;
  String? _error;
  bool _scanning = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _createCode();
  }

  void _createCode() {
    final service = ref.read(pairingServiceProvider);
    if (service == null) {
      _warn('Create your identity first.');
      return;
    }
    final invite = service.createIdentityInvite();
    setState(() {
      _invite = invite;
      _code = invite.payload.encode();
      _fingerprint = invite.payload.fingerprint;
    });
  }

  void _warn(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Stops the camera and shows [message] exactly once.
  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _scanning = false;
    });
  }

  /// Clears any latched refusal and resumes scanning.
  void startScan() {
    setState(() {
      _error = null;
      _scanning = true;
    });
  }

  /// The token of the invite currently on screen, so a test can build the
  /// matching reply without a camera.
  @visibleForTesting
  String? get inviteToken => _invite?.token;

  /// Handles one scanned string. Exposed so a test can drive the flow without a
  /// camera; the live path calls it from `MobileScanner.onDetect`.
  Future<void> handleScanned(String raw) async {
    if (_busy) return;
    final service = ref.read(pairingServiceProvider);
    if (service == null) {
      _fail('Create your identity first.');
      return;
    }
    final invite = _invite;
    if (invite == null) {
      _fail('No code to compare against yet. Go back and try again.');
      return;
    }
    // Friendly nudge for the most common mistake: scanning an identity code
    // where a reply code was expected.
    if (pairingCodeKindOf(raw) == PairingCodeKind.identity) {
      _fail(
        "That's an identity code, not a reply. Show them your code first, "
        'then scan the reply they show you.',
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final claim = service.parseIdentityClaim(raw);
      final peer = await service.handleIdentityClaim(invite.payload, claim);
      if (!mounted) return;
      setState(() {
        _scanning = false;
        _error = null;
        _status = 'You added ${peer.peerUsername}.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Show my code')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    if (_status != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline,
                  size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(_status!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
    }

    if (_scanning) {
      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Point the camera at their reply code.'),
          ),
          Expanded(
            child: MobileScanner(
              key: const Key('identityReplyScanner'),
              onDetect: _busy ? (_) {} : _onDetect,
            ),
          ),
        ],
      );
    }

    final code = _code;
    final error = _error;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text('Let the other person scan this code.'),
          const SizedBox(height: 16),
          if (code != null)
            QrPanel(key: const Key('identityCodeQr'), data: code),
          const SizedBox(height: 16),
          Text('Confirm this fingerprint out loud',
              style: theme.textTheme.titleMedium),
          Text(
            _fingerprint ?? '',
            key: const Key('identityCodeFingerprint'),
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontFamily: 'monospace'),
          ),
          const SizedBox(height: 24),
          if (error != null)
            ScanErrorPanel(message: error, onRetry: startScan)
          else
            FilledButton.icon(
              key: const Key('scanReplyButton'),
              onPressed: _busy ? null : startScan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan their reply'),
            ),
        ],
      ),
    );
  }
}
