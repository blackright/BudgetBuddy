import 'package:isar/isar.dart';

part 'paired_peer.g.dart';

/// Another identity we have paired with (data-model §2.3).
///
/// Created on both sides at the end of a successful QR handshake
/// (`contracts/pairing.md` §3). [peerPublicKey] is what every incoming change's
/// signature is verified against, and it pins the LAN transport (research R2).
@collection
class PairedPeer {
  Id id = Isar.autoIncrement;

  /// The fingerprint of the peer's public key — the peer's stable identity id
  /// (pairing §1). Unique: one pairing row per peer identity.
  @Index(unique: true, replace: true)
  late String peerIdentityId;

  /// The peer's display label at pairing time (a label, never a lookup key).
  String peerUsername = '';

  /// Base64-encoded ed25519 public key, used to verify signatures and pin the
  /// transport (pairing §2).
  String peerPublicKey = '';

  /// Short human-comparable hash shown next to the username (FR-004).
  String peerFingerprint = '';

  late DateTime pairedAt;

  /// Last successful change exchange with this peer (FR-013).
  DateTime? lastSeenAt;
}
