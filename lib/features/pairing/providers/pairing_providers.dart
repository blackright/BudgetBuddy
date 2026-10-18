import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/context_kind.dart';
import '../../../core/models/paired_context.dart';
import '../../../core/models/paired_peer.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/providers/identity_provider.dart';
import '../../identity/providers/device_key_session.dart';
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
/// shared spaces they belong to and when they were last seen.
class Contact {
  const Contact({
    required this.peer,
    required this.sharedSpaceNames,
    this.sharedSpaceIds = const <int>[],
  });

  /// The underlying contact row (`PairedPeer`).
  final PairedPeer peer;

  /// Names of the shared spaces this contact is actively paired into.
  final List<String> sharedSpaceNames;

  /// The `SharedSpace.id`s matching [sharedSpaceNames], in the same order, so
  /// removal (T077) can act per space without another lookup.
  final List<int> sharedSpaceIds;
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
        final joined = <({String name, int spaceId})>[];
        for (final context in contexts) {
          final space = await isar.sharedSpaces.get(context.contextLocalId);
          if (space != null) {
            joined.add((name: space.name, spaceId: space.id));
          }
        }
        joined.sort((a, b) => a.name.compareTo(b.name));
        contacts.add(
          Contact(
            peer: peer,
            sharedSpaceNames: [for (final j in joined) j.name],
            sharedSpaceIds: [for (final j in joined) j.spaceId],
          ),
        );
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
/// keystore; the QR/claim paths that sign call
/// [signingPairingServiceProvider] instead (see `PairDeviceScreen`).
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

/// Hands out a [PairingService] that **can sign**, for the flows that must
/// (QR pairing, adding a contact to a space — US7 T064).
///
/// Awaited **inside a button handler**, never while a screen builds: reading it
/// releases the private key behind the phone's own authentication, via
/// [DeviceKeySession.require]. Returns `null` when there is no identity or the
/// user declined the prompt — and because the session never memoises a failure,
/// the next attempt prompts again instead of sticking on "locked" (T073).
///
/// Abstract so tests can swap in a locked/failing double without touching the
/// keystore or the device authenticator.
final signingPairingServiceProvider = Provider<SigningPairingService>(
  (ref) => _DeviceKeySigningService(ref),
);

/// The callable the flows above await.
///
/// A provider of a callable (rather than a `FutureProvider`) on purpose: the
/// unlock must happen **at the moment of the tap**, one prompt per action, and
/// a `FutureProvider` would cache that answer for the rest of the session.
abstract class SigningPairingService {
  /// A signing [PairingService], or `null` when there is no identity or the
  /// key stayed locked after [reason] was shown.
  Future<PairingService?> call({required String reason});
}

/// The real implementation: identity + unlocked key → a signing service.
class _DeviceKeySigningService implements SigningPairingService {
  const _DeviceKeySigningService(this._ref);

  final Ref _ref;

  @override
  Future<PairingService?> call({required String reason}) async {
    final identity = _ref.read(identityProvider).valueOrNull;
    if (identity == null) return null;
    final keyPair = await _ref
        .read(deviceKeySessionProvider.notifier)
        .require(reason: reason);
    if (keyPair == null) return null;
    final deviceId = _ref.read(deviceIdProvider).valueOrNull ?? '';
    return PairingService(
      IsarHelper.instance,
      identity: identity,
      signer: Ed25519ChangeSigner(
        authorIdentityId: identity.fingerprint,
        keyPair: keyPair,
      ),
      clock: HlcClock(deviceId: deviceId),
    );
  }
}
