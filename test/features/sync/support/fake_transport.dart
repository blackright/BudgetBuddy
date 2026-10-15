import 'dart:async';

import 'package:budget_buddy/features/sync/transport/transport.dart';

/// An in-memory LAN transport for tests (research R2, R9).
///
/// Two (or more) endpoints registered on one [FakeTransportHub] can discover and
/// connect to each other with no sockets, no mDNS and no TLS — which is exactly
/// what keeps the sync tests hermetic.
class FakeTransportHub {
  final Map<String, _FakeEndpoint> _endpoints = {};

  /// Registers a device endpoint and returns its [Transport].
  Transport endpoint(
    String identityId, {
    String username = 'peer',
    String host = '127.0.0.1',
  }) {
    final endpoint = _FakeEndpoint(this, identityId, username, host);
    _endpoints[identityId] = endpoint;
    return endpoint;
  }

  /// Every registered endpoint's advertisement.
  List<PeerAdvertisement> advertisements() =>
      [for (final endpoint in _endpoints.values) endpoint.advertisement];

  /// Waits for the next connection opened *to* the endpoint [identityId].
  ///
  /// Call this (and keep the returned future) **before** the peer calls
  /// `connect`, so the responder side can take part in an exchange.
  Future<TransportConnection> nextIncoming(String identityId) =>
      _endpoints[identityId]!.nextIncomingConnection();

  _FakeEndpoint? _lookup(String identityId) => _endpoints[identityId];
}

class _FakeEndpoint implements Transport {
  _FakeEndpoint(this._hub, this.identityId, this.username, this.host);

  final FakeTransportHub _hub;
  final String identityId;
  final String username;
  final String host;
  final StreamController<TransportConnection> _incomingConnections =
      StreamController.broadcast();

  PeerAdvertisement get advertisement => PeerAdvertisement(
        identityId: identityId,
        username: username,
        host: host,
        port: 0,
      );

  /// The next connection opened *to* this endpoint by a peer's `connect`.
  Future<TransportConnection> nextIncomingConnection() =>
      _incomingConnections.stream.first;

  @override
  Stream<PeerAdvertisement> discover({
    Duration timeout = const Duration(seconds: 5),
  }) async* {
    for (final ad in _hub.advertisements()) {
      if (ad.identityId != identityId) yield ad;
    }
  }

  @override
  Future<TransportConnection> connect(PeerAdvertisement peer) async {
    final target = _hub._lookup(peer.identityId);
    if (target == null) {
      throw StateError('No such peer: ${peer.identityId}');
    }
    // Two linked inboxes: what A sends lands in B's inbox and vice versa.
    final aInbox = StreamController<String>.broadcast();
    final bInbox = StreamController<String>.broadcast();
    final aSide = _FakeConnection(peer.identityId, aInbox, bInbox);
    final bSide = _FakeConnection(identityId, bInbox, aInbox);
    target._incomingConnections.add(bSide);
    return aSide;
  }
}

class _FakeConnection implements TransportConnection {
  _FakeConnection(this.peerIdentityId, this._inbox, this._outbox);

  @override
  final String peerIdentityId;

  final StreamController<String> _inbox;
  final StreamController<String> _outbox;
  bool _closed = false;

  @override
  Stream<String> get incoming => _inbox.stream;

  @override
  Future<void> send(String message) async {
    if (_closed || _outbox.isClosed) return;
    _outbox.add(message);
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    if (!_inbox.isClosed) await _inbox.close();
    if (!_outbox.isClosed) await _outbox.close();
  }
}
