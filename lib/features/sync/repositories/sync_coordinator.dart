import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

import '../../../core/models/context_kind.dart';
import '../../../core/models/paired_context.dart';
import '../../../core/models/paired_peer.dart';
import '../transport/transport.dart';
import 'sync_engine.dart';

/// Runs the peer-to-peer exchange for real devices: it owns the advertise/accept
/// host, discovers paired peers on the LAN, and drives one exchange round per
/// shared context (`contracts/runtime-orchestration.md`).
///
/// It is plain Dart over the [Transport]/[TransportHost]/[SyncEngine]
/// abstractions, so it is unit-testable with the in-memory `FakeTransportHub` and
/// no sockets. It knows *when/which/how* to run — never the protocol itself.
///
/// **Lifecycle (§1)**: [start] opens the host and begins the bounded discovery
/// loop; [stop] cancels the loop, closes live connections and the host. Both are
/// idempotent. There is no background service: while stopped, the device sends
/// and receives nothing (FR-009).
///
/// **Pairing only (§2/§3)**: a discovered advertisement is dialed only when its
/// identity matches an active `PairedPeer`; an inbound connection whose peer is
/// not paired is closed before any record is read (SC-008).
///
/// **Rounds (§4)**: the dialing side runs `engine.exchange(initiator: true)` for
/// each shared context; the accepting side runs `engine.respond` for the context
/// named by the first envelope. Records only ever flow between the two paired
/// phones — the transport never carries a local row id.
class SyncCoordinator {
  SyncCoordinator({
    required Isar isar,
    required SyncEngine engine,
    required Transport transport,
    required TransportHost host,
    this.discoveryTimeout = const Duration(seconds: 5),
    this.discoveryInterval = const Duration(seconds: 10),
    this.onRoundStart,
    this.onRoundEnd,
  })  : _isar = isar,
        _engine = engine,
        _transport = transport,
        _host = host;

  final Isar _isar;
  final SyncEngine _engine;
  final Transport _transport;
  final TransportHost _host;

  /// Called with the **local** space id when a round for it begins (§4), so the
  /// UI can say "in progress" for exactly that space (T051).
  final void Function(int spaceId)? onRoundStart;

  /// Called with that same local space id when the round ends — successfully or
  /// not — so the caller can recompute what is still pending.
  final void Function(int spaceId)? onRoundEnd;

  /// How long one discovery pass listens before the next pass is scheduled.
  final Duration discoveryTimeout;

  /// The pause between discovery passes while the app is foregrounded.
  final Duration discoveryInterval;

  bool _running = false;
  StreamSubscription<TransportConnection>? _inbound;
  Timer? _discoveryTimer;

  /// Peers currently being dialed, so a duplicate advertisement in one pass does
  /// not open a second connection.
  final Set<String> _dialing = {};

  /// Every live connection (dialed or accepted), so [stop] can drop them all.
  final Set<TransportConnection> _live = {};

  /// In-flight rounds (dialed or accepted). [stop] closes the live connections
  /// first, which ends these, then waits for them so a stopped coordinator leaves
  /// no pending work behind.
  final Set<Future<void>> _inflight = {};

  /// Whether the loop is running. A second [start] while running is a no-op.
  bool get isRunning => _running;

  /// Opens the host and begins discovering/dialing paired peers (§1). Idempotent.
  Future<void> start() async {
    if (_running) return;
    _running = true;
    try {
      await _host.start();
    } on Object catch (error, stackTrace) {
      // Binding or advertising can fail transiently — the port is still held by
      // the previous socket, or the mDNS plugin is mid-teardown — and callers
      // are fire-and-forget (`unawaited(...)` in the lifecycle observer), so
      // throwing here would escape as an unhandled async error *and* leave
      // `_running` stuck `true` on a host that never opened. Report it, clear
      // the flag, and let the next foreground event start cleanly (T080).
      _running = false;
      debugPrint('SyncCoordinator.start failed: $error\n$stackTrace');
      return;
    }
    _inbound = _host.connections.listen((c) => _track(_serveInbound(c)));
    unawaited(_track(_discoverPass()));
  }

  /// Cancels discovery, drops every live connection and closes the host (§1).
  /// Idempotent.
  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    _discoveryTimer?.cancel();
    _discoveryTimer = null;
    await _inbound?.cancel();
    _inbound = null;
    _dialing.clear();
    // Close every live connection first: that ends the hung `await for` in any
    // in-flight exchange, so the rounds tracked below can finish.
    final live = List.of(_live);
    _live.clear();
    for (final connection in live) {
      await connection.close();
    }
    await _host.stop();
    // Now drain whatever was mid-round so `stop` truly quiesces.
    await Future.wait(List.of(_inflight));
  }

  /// Tracks [round] so [stop] can wait for it.
  Future<void> _track(Future<void> round) {
    final guarded = round.catchError((Object _) {});
    _inflight.add(guarded);
    return guarded.whenComplete(() => _inflight.remove(guarded));
  }

  // ---------------------------------------------------------------------------
  // Discovery (initiator side)
  // ---------------------------------------------------------------------------

  Future<void> _discoverPass() async {
    if (!_running) return;
    try {
      final peers = await _isar.pairedPeers.where().findAll();
      if (peers.isNotEmpty) {
        final byIdentity = {
          for (final peer in peers) peer.peerIdentityId: peer,
        };
        await for (final ad in _transport.discover(timeout: discoveryTimeout)) {
          if (!_running) break;
          final peer = byIdentity[ad.identityId];
          if (peer == null) continue; // not paired: ignore (§2)
          if (!_dialing.add(ad.identityId)) continue;
          unawaited(
            _track(
              _dialToPeer(peer, ad)
                  .whenComplete(() => _dialing.remove(ad.identityId)),
            ),
          );
        }
      }
    } on Object {
      // A failed pass is transient; the next one retries.
    }
    if (_running) {
      _discoveryTimer = Timer(discoveryInterval, _discoverPass);
    }
  }

  Future<void> _dialToPeer(PairedPeer peer, PeerAdvertisement ad) async {
    final contexts = await _activeSharedContexts(peer.id);
    for (final context in contexts) {
      if (!_running) return;
      final TransportConnection connection;
      try {
        connection = await _transport.connect(ad);
      } on Object {
        return; // unreachable or refused; the next pass retries
      }
      if (!_running) {
        // Stopped while connecting: drop it rather than leak a live socket.
        await connection.close();
        return;
      }
      _live.add(connection);
      try {
        await _engine.exchange(
          connection,
          contextLocalId: context.contextLocalId,
          initiator: true,
          peerId: peer.id,
          onRoundStart: onRoundStart,
          onRoundEnd: onRoundEnd,
        );
        await _touch(peer);
      } on Object {
        // A dropped round is retried on the next pass; nothing half-applies.
      } finally {
        _live.remove(connection);
        await connection.close();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Inbound (responder side)
  // ---------------------------------------------------------------------------

  Future<void> _serveInbound(TransportConnection connection) async {
    if (!_running) {
      await connection.close();
      return;
    }
    final peer = await _peerByIdentity(connection.peerIdentityId);
    if (peer == null) {
      // Not a paired peer: refuse and close before any record is read (SC-008).
      await connection.close();
      return;
    }
    if (!_running) {
      await connection.close();
      return;
    }
    _live.add(connection);
    try {
      await _engine.respond(
        connection,
        peerId: peer.id,
        onRoundStart: onRoundStart,
        onRoundEnd: onRoundEnd,
      );
      await _touch(peer);
    } on Object {
      // Dropped; closing the connection ends the round.
    } finally {
      _live.remove(connection);
      await connection.close();
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<List<PairedContext>> _activeSharedContexts(int peerId) =>
      _isar.pairedContexts
          .filter()
          .peerIdEqualTo(peerId)
          .contextKindEqualTo(ContextKind.shared)
          .activeEqualTo(true)
          .findAll();

  Future<PairedPeer?> _peerByIdentity(String identityId) async {
    if (identityId.isEmpty) return null;
    return _isar.pairedPeers
        .filter()
        .peerIdentityIdEqualTo(identityId)
        .findFirst();
  }

  /// Refreshes the peer's `lastSeenAt` after a successful round (FR-013).
  Future<void> _touch(PairedPeer peer) async {
    await _isar.writeTxn(() async {
      final row = await _isar.pairedPeers.get(peer.id);
      if (row == null) return;
      row.lastSeenAt = DateTime.now();
      await _isar.pairedPeers.put(row);
    });
  }
}
