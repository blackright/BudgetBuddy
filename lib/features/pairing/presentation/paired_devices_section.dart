import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/paired_peer.dart';
import '../../../core/providers/active_space_provider.dart';
import '../providers/pairing_providers.dart';
import 'pair_device_screen.dart';

/// FR-014 / US3: the "Paired devices" card.
///
/// Lists every peer this device has paired with — disambiguated as
/// `username (fingerprint)` — and lets the user pair a new one (when a shared
/// space is active) or unpair an existing one. Unpairing keeps the local copy of
/// the data and simply stops exchanging with that peer (`pairing.md` §5).
class PairedDevicesSection extends ConsumerWidget {
  const PairedDevicesSection({super.key});

  Future<void> _pair(BuildContext context, WidgetRef ref) async {
    final space = ref.read(activeSpaceProvider).value;
    if (space == null) return;
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => PairDeviceScreen(spaceId: space.id),
      ),
    );
  }

  Future<void> _unpair(
    BuildContext context,
    WidgetRef ref,
    PairedPeer peer,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unpair this device?'),
        content: Text(
          'You will stop exchanging changes with '
          '${peer.peerUsername} (${peer.peerFingerprint}). '
          'The data you already have stays on this phone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirmUnpairButton'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Unpair'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final spaceId = ref.read(activeSpaceProvider).value?.id;
    await ref.read(pairingServiceProvider)?.unpair(
          peerIdentityId: peer.peerIdentityId,
          spaceId: spaceId,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(pairingServiceProvider) == null) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final peers = ref.watch(pairedPeersProvider).value ?? const <PairedPeer>[];
    final hasSpace = ref.watch(activeSpaceProvider).value != null;
    final format = DateFormat.yMMMd().add_jm();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('Paired devices', style: theme.textTheme.titleMedium),
            trailing: Text('${peers.length}'),
          ),
          if (peers.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'No devices paired yet. Pair in person so a username is bound '
                'to its key.',
              ),
            ),
          for (final peer in peers)
            ListTile(
              key: Key('pairedPeer_${peer.peerIdentityId}'),
              dense: true,
              leading: const CircleAvatar(child: Icon(Icons.smartphone)),
              title: Text('${peer.peerUsername} (${peer.peerFingerprint})'),
              subtitle: Text(
                'Paired ${format.format(peer.pairedAt.toLocal())}'
                '${peer.lastSeenAt == null ? '' : ' · Last synced ${format.format(peer.lastSeenAt!.toLocal())}'}',
              ),
              trailing: TextButton(
                key: Key('unpair_${peer.peerIdentityId}'),
                onPressed: () => _unpair(context, ref, peer),
                child: const Text('Unpair'),
              ),
            ),
          if (hasSpace)
            ListTile(
              dense: true,
              leading: const Icon(Icons.qr_code_2),
              title: TextButton(
                key: const Key('pairDeviceButton'),
                onPressed: () => _pair(context, ref),
                child: const Text('Pair a device'),
              ),
            ),
        ],
      ),
    );
  }
}
