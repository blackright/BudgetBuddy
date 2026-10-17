import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/models/shared_member.dart';
import '../../pairing/domain/pairing_protocol.dart';
import '../../pairing/presentation/widgets/scan_error_panel.dart';
import '../../pairing/providers/pairing_providers.dart';

String _roleLabel(SharedMemberRole role) => switch (role) {
      SharedMemberRole.owner => 'Owner',
      SharedMemberRole.editor => 'Editor',
      SharedMemberRole.viewer => 'Viewer',
    };

/// US7 (T064): adds a person to the **active shared space** by scanning their
/// identity code.
///
/// Offline, like the People flow: the scan creates the contact and grants the
/// membership in one step, so the person never has to be paired first. The
/// membership is signed by this device's identity (same trust as a QR invite).
///
/// A refused scan **latches**: the camera stops and [ScanErrorPanel] shows the
/// reason once, rather than repeating it every camera frame.
class ScanContactIntoSpaceScreen extends ConsumerStatefulWidget {
  const ScanContactIntoSpaceScreen({
    super.key,
    required this.spaceId,
    required this.spaceName,
    this.role = SharedMemberRole.editor,
  });

  final int spaceId;
  final String spaceName;
  final SharedMemberRole role;

  @override
  ConsumerState<ScanContactIntoSpaceScreen> createState() =>
      ScanContactIntoSpaceScreenState();
}

class ScanContactIntoSpaceScreenState
    extends ConsumerState<ScanContactIntoSpaceScreen> {
  String? _addedName;
  String? _error;
  bool _busy = false;

  /// Stops the camera and shows [message] exactly once.
  void _fail(String message) {
    if (!mounted) return;
    setState(() => _error = message);
  }

  /// Clears a latched refusal and resumes the camera.
  void retry() {
    setState(() => _error = null);
  }

  /// Handles one scanned string. Exposed so a test can drive the flow without a
  /// camera; the live path calls it from `MobileScanner.onDetect`.
  Future<void> handleScanned(String raw) async {
    if (_busy) return;
    if (pairingCodeKindOf(raw) != PairingCodeKind.identity) {
      _fail(
        "That's not someone's identity code. Ask them to show their code "
        'first, then scan it here.',
      );
      return;
    }
    // Claim before the first `await` so a slow identity unlock cannot let a
    // second camera frame open a second confirm dialog.
    _busy = true;
    try {
      final service = await ref.read(signingPairingServiceProvider.future);
      if (!mounted) return;
      if (service == null) {
        _fail('Your identity stayed locked, so nothing was shared.');
        return;
      }
      final payload = await service.parseIdentityPayload(raw);
      if (!mounted) return;
      final confirmed = await _confirmScanned(payload);
      if (confirmed != true || !mounted) return;

      final peer = await service.acceptIdentityPayload(payload);
      await service.addContactToSpace(
        spaceId: widget.spaceId,
        peerIdentityId: peer.peerIdentityId,
        role: widget.role,
      );
      if (!mounted) return;
      setState(() {
        _addedName = peer.peerUsername;
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
        title: Text('Add to ${widget.spaceName}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${payload.username} (${payload.fingerprint})',
                key: const Key('scannedSpaceContact')),
            const SizedBox(height: 8),
            Text('Role: ${_roleLabel(widget.role)}'),
            const SizedBox(height: 4),
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
            key: const Key('confirmAddToSpaceButton'),
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
      appBar: AppBar(title: Text('Add to ${widget.spaceName}')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final addedName = _addedName;
    if (addedName != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline,
                  size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                'You added $addedName to ${widget.spaceName}.',
                key: const Key('addToSpaceSuccess'),
                textAlign: TextAlign.center,
              ),
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
    final error = _error;
    if (error != null) {
      return Center(child: ScanErrorPanel(message: error, onRetry: retry));
    }
    return MobileScanner(
      key: const Key('addToSpaceScanner'),
      onDetect: _busy ? (_) {} : _onDetect,
    );
  }
}
