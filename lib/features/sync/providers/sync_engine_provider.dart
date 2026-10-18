import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/paired_peer.dart';
import '../../../core/providers/identity_provider.dart';
import '../../pairing/providers/pairing_providers.dart';
import '../../spaces/repositories/space_role_guard.dart';
import '../domain/hlc.dart';
import '../repositories/sync_engine.dart';
import 'sync_recorder_provider.dart';

/// The merge-and-exchange engine, wired with exactly the paired peers as trust
/// anchors (research R3).
///
/// The trusted map is rebuilt whenever a pairing is added or removed, so
/// `SyncEngine._verify` accepts only records authored by a known contact
/// (FR-004/FR-012/FR-014). The device's **own** identity is deliberately not
/// added: a device never accepts its own records back over the wire. It is,
/// however, passed as `selfIdentityId` so an outbound snapshot carries only the
/// records this device itself authored (FR-014, research R4).
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final deviceId = ref.watch(deviceIdProvider).valueOrNull ?? '';
  final peers =
      ref.watch(pairedPeersProvider).valueOrNull ?? const <PairedPeer>[];
  final trusted = <String, SimplePublicKey>{
    for (final peer in peers)
      if (peer.peerPublicKey.isNotEmpty)
        peer.peerIdentityId: SimplePublicKey(
          base64Decode(peer.peerPublicKey),
          type: KeyPairType.ed25519,
        ),
  };
  return SyncEngine(
    IsarHelper.instance,
    trustedKeys: trusted,
    clock: HlcClock(deviceId: deviceId),
    guard: const SpaceAccessGuard(),
    selfIdentityId: ref.watch(identityProvider).valueOrNull?.fingerprint,
    // So an outbound snapshot can first journal rows written while recording
    // was inert (015 back-fill); the engine swaps to the inert recorder while
    // the identity is locked and back-fill becomes a no-op.
    recorder: ref.watch(syncRecorderProvider),
  );
});
