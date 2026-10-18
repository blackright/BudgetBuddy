import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/providers/identity_provider.dart';
import '../../identity/providers/device_key_session.dart';
import '../../sync/domain/hlc.dart';
import '../../sync/repositories/change_signer.dart';
import '../domain/pairing_protocol.dart';
import '../providers/pairing_providers.dart';
import '../repositories/pairing_service.dart';
import 'widgets/scan_error_panel.dart';

String roleLabel(SharedMemberRole role) => switch (role) {
      SharedMemberRole.owner => 'Owner',
      SharedMemberRole.editor => 'Editor',
      SharedMemberRole.viewer => 'Viewer',
    };

/// The in-person pairing screen (`contracts/pairing.md` §2, FR-004).
///
/// The Owner shows a QR for a space + role; the other person scans it and
/// confirms `username (fingerprint)` before anything is shared. The private key
/// is released only when the QR is created, behind the phone's own
/// authentication.
class PairDeviceScreen extends ConsumerStatefulWidget {
  const PairDeviceScreen({
    super.key,
    required this.spaceId,
    this.initialRole = SharedMemberRole.editor,
  });

  /// The `SharedSpace.id` being offered.
  final int spaceId;

  final SharedMemberRole initialRole;

  @override
  ConsumerState<PairDeviceScreen> createState() => _PairDeviceScreenState();
}

class _PairDeviceScreenState extends ConsumerState<PairDeviceScreen> {
  late SharedMemberRole _role = widget.initialRole;
  PairingInvite? _invite;
  bool _busy = false;
  String? _status;
  String? _scanError;

  Future<PairingService?> _signingService() async {
    final identity = ref.read(identityProvider).valueOrNull;
    if (identity == null) {
      _warn('Create your identity first.');
      return null;
    }
    // A prompt the user cancels leaves the session retryable, so pressing the
    // button again asks once more instead of failing forever (T073).
    final keyPair = await ref
        .read(deviceKeySessionProvider.notifier)
        .require(reason: 'Pair with a device');
    if (keyPair == null) {
      _warn('Your identity stayed locked, so nothing was shared.');
      return null;
    }
    return PairingService(
      IsarHelper.instance,
      identity: identity,
      signer: Ed25519ChangeSigner(
        authorIdentityId: identity.fingerprint,
        keyPair: keyPair,
      ),
      clock: HlcClock(deviceId: ref.read(deviceIdProvider).valueOrNull ?? ''),
    );
  }

  void _warn(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showQr() async {
    setState(() => _busy = true);
    try {
      final service = await _signingService();
      if (service == null) return;
      final invite = await service.createInvite(
        spaceId: widget.spaceId,
        offeredRole: _role,
      );
      if (!mounted) return;
      setState(() {
        _invite = invite;
        _status = null;
      });
    } on PairingException catch (error) {
      _warn(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelInvite() async {
    final invite = _invite;
    if (invite == null) return;
    await ref.read(pairingServiceProvider)?.cancelInvite(token: invite.token);
    if (!mounted) return;
    setState(() {
      _invite = null;
      _status = null;
    });
  }

  /// Stops the camera and shows [message] exactly once. `MobileScanner` fires
  /// once per frame while a code is in view, so a refusal must latch instead of
  /// repeating as a toast.
  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _scanError = message;
      _busy = false;
    });
  }

  /// Clears a latched refusal and resumes the camera.
  void _retryScan() {
    setState(() => _scanError = null);
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final raw =
        capture.barcodes.isEmpty ? null : capture.barcodes.first.rawValue;
    if (raw == null) return;
    // Claim the busy flag before the first `await`, so frames arriving while
    // the confirmation dialog is open cannot open a second dialog.
    setState(() => _busy = true);
    try {
      final service = ref.read(pairingServiceProvider);
      if (service == null) {
        _fail('Create your identity first.');
        return;
      }
      final payload = await service.parsePayload(raw);
      if (!mounted) return;
      final confirmed = await _confirmScanned(payload);
      if (confirmed != true || !mounted) return;
      // A space code only carries the *invite*: completing it needs the claim to
      // reach the presenter's device, and that LAN meeting flow is not wired yet
      // (the claim would be discarded here). Say so plainly instead of implying
      // the two phones are paired — an implied-but-missing pairing is exactly
      // the bug where a phone "paired" yet never received the space.
      setState(() {
        _scanError = null;
        _status = 'That is ${payload.username} (${payload.fingerprint}). '
            'This code cannot finish here yet — open Settings → People and '
            "scan each other's codes to become contacts, then add them from "
            "the space's Invite button.";
      });
    } on PairingException catch (error) {
      _fail(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _confirmScanned(PairingPayload payload) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pair with this person?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${payload.username} (${payload.fingerprint})',
                key: const Key('scannedPeerIdentity')),
            const SizedBox(height: 8),
            Text('Role: ${roleLabel(payload.offeredRole)}'),
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
            key: const Key('confirmScannedPairingButton'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pair a device'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Show code'),
              Tab(text: 'Scan code'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _PresenterPane(
              role: _role,
              onRoleChanged: (role) => setState(() => _role = role),
              invite: _invite,
              busy: _busy,
              onShowQr: _showQr,
              onCancel: _cancelInvite,
            ),
            _ScannerPane(
              busy: _busy,
              status: _status,
              scanError: _scanError,
              onDetect: _onDetect,
              onRetry: _retryScan,
            ),
          ],
        ),
      ),
    );
  }
}

class _PresenterPane extends StatelessWidget {
  const _PresenterPane({
    required this.role,
    required this.onRoleChanged,
    required this.invite,
    required this.busy,
    required this.onShowQr,
    required this.onCancel,
  });

  final SharedMemberRole role;
  final ValueChanged<SharedMemberRole> onRoleChanged;
  final PairingInvite? invite;
  final bool busy;
  final VoidCallback onShowQr;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentInvite = invite;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('They join as', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<SharedMemberRole>(
            key: const Key('offeredRoleSelector'),
            segments: [
              for (final option in SharedMemberRole.values)
                ButtonSegment(value: option, label: Text(roleLabel(option))),
            ],
            selected: {role},
            onSelectionChanged: (selection) => onRoleChanged(selection.first),
          ),
          const SizedBox(height: 24),
          if (currentInvite == null)
            FilledButton.icon(
              key: const Key('showPairingQrButton'),
              onPressed: busy ? null : onShowQr,
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Show pairing code'),
            )
          else ...[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: QrImageView(
                key: const Key('pairingQrImage'),
                data: currentInvite.payload.encode(),
                version: QrVersions.auto,
                size: 240,
              ),
            ),
            const SizedBox(height: 16),
            Text('Confirm this fingerprint out loud',
                style: theme.textTheme.titleMedium),
            Text(
              currentInvite.payload.fingerprint,
              key: const Key('pairingFingerprint'),
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              key: const Key('cancelPairingButton'),
              onPressed: onCancel,
              child: const Text('Cancel code'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScannerPane extends StatelessWidget {
  const _ScannerPane({
    required this.busy,
    required this.status,
    required this.scanError,
    required this.onDetect,
    required this.onRetry,
  });

  final bool busy;
  final String? status;
  final String? scanError;
  final ValueChanged<BarcodeCapture> onDetect;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (status != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline,
                  size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(status!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    final error = scanError;
    if (error != null) {
      return Center(child: ScanErrorPanel(message: error, onRetry: onRetry));
    }
    return MobileScanner(
      key: const Key('pairingScanner'),
      onDetect: busy ? (_) {} : onDetect,
    );
  }
}
