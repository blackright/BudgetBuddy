import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/context_kind.dart';
import '../../../core/models/paired_context.dart';
import '../../../core/models/paired_peer.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/providers/identity_provider.dart';
import '../../sync/domain/hlc.dart';
import '../../sync/repositories/change_signer.dart';
import '../repositories/pairing_service.dart';

/// Every peer this device has paired with (FR-014 "Paired devices").
///
/// Ordered in the UI, not here: `pairedAt` is not indexed, so Isar sorting is
/// avoided and a plain `watch` keeps the stream cheap.
final pairedPeersProvider = StreamProvider<List<PairedPeer>>((ref) {
  return IsarHelper.instance.pairedPeers.where().watch(fireImmediately: true);
});

/// The active paired contexts for one shared space (`spaceId`).
final spacePairedContextsProvider =
    StreamProvider.family<List<PairedContext>, int>((ref, spaceId) {
  return IsarHelper.instance.pairedContexts
      .filter()
      .contextKindEqualTo(ContextKind.shared)
      .contextLocalIdEqualTo(spaceId)
      .activeEqualTo(true)
      .watch(fireImmediately: true);
});

/// A person in the global People list (US7, T061): a paired contact plus the
/// shared spaces they belong to (by name) and when they were last seen.
class Contact {
  const Contact({required this.peer, required this.sharedSpaceNames});

  /// The underlying contact row (`PairedPeer`).
  final PairedPeer peer;

  /// Names of the shared spaces this contact is actively paired into.
  final List<String> sharedSpaceNames;
}

/// Every contact this device knows, enriched with the shared spaces they are in
/// (US7, T061). Reuses `PairedPeer` as the contact store — no new collection, so
/// no Isar migration is required.
///
/// Watches the peer rows (which fire whenever a contact is added or seen) and
/// joins `PairedContext` + `SharedSpace` for the space names. Ordered by
/// username, then fingerprint, for a stable list.
final contactsProvider = StreamProvider<List<Contact>>((ref) {
  final isar = IsarHelper.instance;
  return isar.pairedPeers.where().watch(fireImmediately: true).asyncMap(
    (peers) async {
      final contacts = <Contact>[];
      for (final peer in peers) {
        final contexts = await isar.pairedContexts
            .filter()
            .peerIdEqualTo(peer.id)
            .contextKindEqualTo(ContextKind.shared)
            .activeEqualTo(true)
            .findAll();
        final names = <String>[];
        for (final context in contexts) {
          final space = await isar.sharedSpaces.get(context.contextLocalId);
          if (space != null) names.add(space.name);
        }
        names.sort();
        contacts.add(Contact(peer: peer, sharedSpaceNames: names));
      }
      contacts.sort((a, b) {
        final byName = a.peer.peerUsername
            .toLowerCase()
            .compareTo(b.peer.peerUsername.toLowerCase());
        if (byName != 0) return byName;
        return a.peer.peerFingerprint.compareTo(b.peer.peerFingerprint);
      });
      return contacts;
    },
  );
});

/// A [PairingService] for the local identity.
///
/// Built **without** a signer so listing and unpairing never prompt for the
/// keystore; the QR/claim paths that sign call [unlockedKeyPairProvider] first
/// and build a signing service (see `PairDeviceScreen`).
final pairingServiceProvider = Provider<PairingService?>((ref) {
  final identity = ref.watch(identityProvider).valueOrNull;
  if (identity == null) return null;
  final deviceId = ref.watch(deviceIdProvider).valueOrNull ?? '';
  return PairingService(
    IsarHelper.instance,
    identity: identity,
    clock: HlcClock(deviceId: deviceId),
  );
});

/// A [PairingService] that **can sign**, for the flows that must (QR pairing,
/// adding a contact to a space — US7 T064).
///
/// Reading it releases the private key behind the phone's own authentication,
/// so it is awaited **inside a button handler**, never while a screen builds.
/// Returns null when there is no identity or the key stayed locked.
final signingPairingServiceProvider =
    FutureProvider<PairingService?>((ref) async {
  final identity = ref.watch(identityProvider).valueOrNull;
  if (identity == null) return null;
  final keyPair = await ref.watch(unlockedKeyPairProvider.future);
  if (keyPair == null) return null;
  final deviceId = ref.watch(deviceIdProvider).valueOrNull ?? '';
  return PairingService(
    IsarHelper.instance,
    identity: identity,
    signer: Ed25519ChangeSigner(
      authorIdentityId: identity.fingerprint,
      keyPair: keyPair,
    ),
    clock: HlcClock(deviceId: deviceId),
  );
});

/// The identity's private key, released behind the phone's own authentication
/// (FR-002). Watched only on demand, so opening Settings never prompts.
final unlockedKeyPairProvider = FutureProvider<SimpleKeyPair?>((ref) {
  final requireAuth = ref.watch(deviceAuthEnabledProvider);
  return ref.watch(identityServiceProvider).unlock(
        requireDeviceAuth: requireAuth,
        reason: 'Pair with a device',
      );
});
