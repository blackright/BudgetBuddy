/// Transport abstractions for the local-network exchange (research R2,
/// `contracts/pairing.md` §3, `contracts/sync-protocol.md` §3).
///
/// Real devices advertise via mDNS and open a pinned-TLS socket
/// (`lan_transport.dart`, US3); tests use an in-memory [FakeTransport]
/// (`test/features/sync/support/fake_transport.dart`). Keeping the surface this
/// small is what keeps CI hermetic — no sockets, no discovery.
library;

/// A peer discovered on the local network, pinned to its paired identity.
class PeerAdvertisement {
  const PeerAdvertisement({
    required this.identityId,
    required this.username,
    required this.host,
    required this.port,
  });

  /// The peer's identity fingerprint (matches `PairedPeer.peerIdentityId`).
  final String identityId;

  /// Display label (never a lookup key).
  final String username;

  final String host;
  final int port;
}

/// A live, ordered message channel with one paired peer.
///
/// Messages are opaque strings (the sync layer sends canonical JSON envelopes);
/// the transport stays payload-agnostic so it can be faked trivially.
abstract class TransportConnection {
  /// The pinned identity of the peer on the other end.
  String get peerIdentityId;

  Future<void> send(String message);

  Stream<String> get incoming;

  Future<void> close();
}

/// Discovers paired peers and opens connections to them.
abstract class Transport {
  /// Emits a [PeerAdvertisement] for each peer currently reachable on the LAN.
  ///
  /// Discovery must expose nothing financial before mutual pairing (SC-008).
  Stream<PeerAdvertisement> discover({
    Duration timeout = const Duration(seconds: 5),
  });

  /// Opens a connection to [peer].
  Future<TransportConnection> connect(PeerAdvertisement peer);
}
