import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/context_kind.dart';
import '../../../core/models/paired_context.dart';
import '../../../core/models/paired_peer.dart';
import '../../../core/providers/identity_provider.dart';
import '../../sync/domain/hlc.dart';
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

/// The identity's private key, released behind the phone's own authentication
/// (FR-002). Watched only on demand, so opening Settings never prompts.
final unlockedKeyPairProvider = FutureProvider<SimpleKeyPair?>((ref) {
  final requireAuth = ref.watch(deviceAuthEnabledProvider);
  return ref.watch(identityServiceProvider).unlock(
        requireDeviceAuth: requireAuth,
        reason: 'Pair with a device',
      );
});
