import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/paired_peer.dart';
import '../../pairing/providers/pairing_providers.dart';
import '../repositories/sync_coordinator.dart';
import '../transport/lan_transport.dart';
import 'sync_engine_provider.dart';
import 'sync_session_provider.dart';
import 'sync_status_provider.dart';

/// The running exchange coordinator, or `null` while the identity is locked
/// (research R1).
///
/// Built from the unlocked [syncSessionProvider] (identity keypair), the
/// [syncEngineProvider] (trusted peers) and the active `PairedPeer` rows (the
/// transport pins each peer's public key). It is **not** started here: the app
/// lifecycle observer in `main.dart` starts it while foregrounded and stops it on
/// background/session-loss (`contracts/runtime-orchestration.md` §1).
final syncCoordinatorProvider = Provider<SyncCoordinator?>((ref) {
  final session = ref.watch(syncSessionProvider).valueOrNull;
  if (session == null) return null;

  final peers =
      ref.watch(pairedPeersProvider).valueOrNull ?? const <PairedPeer>[];
  final pinned = <String, String>{
    for (final peer in peers)
      if (peer.peerPublicKey.isNotEmpty)
        peer.peerIdentityId: peer.peerPublicKey,
  };

  final identityId = session.identity.fingerprint;
  final username = session.identity.username;

  return SyncCoordinator(
    isar: IsarHelper.instance,
    engine: ref.watch(syncEngineProvider),
    transport: LanTransport(
      identityId: identityId,
      username: username,
      pinnedPublicKey: (peerIdentityId) => pinned[peerIdentityId] ?? '',
    ),
    host: LanTransportHost(
      identityId: identityId,
      username: username,
      signingKey: session.keyPair,
    ),
    onRoundStart: (spaceId) => _reportRoundStart(ref, spaceId),
    onRoundEnd: (spaceId) => _reportRoundEnd(ref, spaceId),
  );
});

/// Tells the per-space badge that a round for [spaceId] has begun (T051).
///
/// Swallows its own failures on purpose: the coordinator treats any throw from a
/// round as a dropped exchange, so a cosmetic badge error must never stop the
/// records flowing.
void _reportRoundStart(Ref ref, int spaceId) {
  try {
    ref.read(syncStatusProvider(spaceId).notifier).roundStarted();
  } on Object {
    // The container is gone (app teardown, tests); only the badge is affected.
  }
}

/// The round is over: clear "in progress" and re-read the store so `pending`
/// reflects exactly what that round delivered.
void _reportRoundEnd(Ref ref, int spaceId) {
  try {
    ref.read(syncStatusProvider(spaceId).notifier).roundFinished();
    ref.invalidate(syncStatusFactsProvider(spaceId));
  } on Object {
    // Same: the exchange already happened; only the badge would be stale.
  }
}
