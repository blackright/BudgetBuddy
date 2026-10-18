import 'dart:async';
import 'dart:convert';

import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/context_kind.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/paired_context.dart';
import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:budget_buddy/features/sync/domain/hlc.dart';
import 'package:budget_buddy/features/sync/domain/sync_guid.dart';
import 'package:budget_buddy/features/sync/repositories/sync_coordinator.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'package:budget_buddy/features/sync/transport/transport.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'support/change_factory.dart';
import 'support/fake_transport.dart';
import 'support/sync_harness.dart';

/// US4 (T055): offline & private — SC-004 (offline transmits nothing), SC-008
/// (an unproven/unpaired device is refused before any data) and FR-010 (a
/// deactivated context stops being exchanged).
///
/// These use two in-memory coordinators over one [FakeTransportHub] (no sockets),
/// exactly like `sync_coordinator_test.dart`.
Expense _expense({
  required String title,
  required int amount,
  required String syncGuid,
  required int sharedSpaceId,
}) =>
    Expense(
      id: 99,
      profileId: 1,
      sharedSpaceId: sharedSpaceId,
      yearMonth: '2026-03',
      title: title,
      amount: amount,
      currency: 'usd',
      categoryId: 'general',
      date: DateTime.utc(2026, 3, 5),
      budgetId: 0,
    )..syncGuid = syncGuid;

/// A [Transport] for the offline case: a paired peer exists but nothing is ever
/// discovered, so the coordinator must not dial or send (SC-004).
class _OfflineTransport implements Transport {
  int connects = 0;
  final List<String> payloads = [];

  @override
  Stream<PeerAdvertisement> discover({
    Duration timeout = const Duration(seconds: 5),
  }) async* {
    // No peer is reachable on the LAN.
  }

  @override
  Future<TransportConnection> connect(PeerAdvertisement peer) async {
    connects++;
    return _RecordingConnection(peer.identityId, payloads);
  }
}

/// A host that never yields an inbound connection, for the offline case.
class _SilentHost implements TransportHost {
  final StreamController<TransportConnection> _connections =
      StreamController<TransportConnection>.broadcast();

  @override
  Stream<TransportConnection> get connections => _connections.stream;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {
    if (!_connections.isClosed) await _connections.close();
  }
}

/// Records every message a dialer would put on the wire, so "zero bytes
/// transmitted" is a real assertion.
class _RecordingConnection implements TransportConnection {
  _RecordingConnection(this.peerIdentityId, this._payloads);

  @override
  final String peerIdentityId;
  final List<String> _payloads;

  @override
  Stream<String> get incoming => const Stream.empty();

  @override
  Future<void> send(String message) async => _payloads.add(message);

  @override
  Future<void> close() async {}
}

void main() {
  late SyncTestHarness a;
  late SyncTestHarness b;
  late FakeTransportHub hub;
  late DeviceKeys keysA;
  late DeviceKeys keysB;
  late SyncCoordinator coordA;
  late SyncCoordinator coordB;

  setUp(() async {
    a = await SyncTestHarness.create();
    b = await SyncTestHarness.create();
    hub = FakeTransportHub();
    keysA = await DeviceKeys.generate('idA');
    keysB = await DeviceKeys.generate('idB');

    // The same logical space under different local ids and one syncGuid.
    await a.createSpaceAt(localId: 1, syncGuid: 'space-guid-1');
    await b.createSpaceAt(localId: 2, syncGuid: 'space-guid-1');

    final peerAId = await a.isar.writeTxn(
      () => a.isar.pairedPeers.put(
        PairedPeer()
          ..peerIdentityId = 'idB'
          ..peerPublicKey = base64Encode(keysB.publicKey.bytes)
          ..peerFingerprint = 'B'
          ..pairedAt = DateTime(2026),
      ),
    );
    final peerBId = await b.isar.writeTxn(
      () => b.isar.pairedPeers.put(
        PairedPeer()
          ..peerIdentityId = 'idA'
          ..peerPublicKey = base64Encode(keysA.publicKey.bytes)
          ..peerFingerprint = 'A'
          ..pairedAt = DateTime(2026),
      ),
    );
    await a.pairContext(peerId: peerAId, spaceId: 1);
    await b.pairContext(peerId: peerBId, spaceId: 2);

    final engineA = SyncEngine(
      a.isar,
      trustedKeys: {'idB': keysB.publicKey},
      clock: HlcClock(deviceId: 'A'),
    );
    final engineB = SyncEngine(
      b.isar,
      trustedKeys: {'idA': keysA.publicKey},
      clock: HlcClock(deviceId: 'B'),
    );

    coordA = SyncCoordinator(
      isar: a.isar,
      engine: engineA,
      transport: hub.endpoint('idA', username: 'A'),
      host: hub.host('idA'),
      discoveryTimeout: const Duration(milliseconds: 50),
      discoveryInterval: const Duration(milliseconds: 50),
    );
    coordB = SyncCoordinator(
      isar: b.isar,
      engine: engineB,
      transport: hub.endpoint('idB', username: 'B'),
      host: hub.host('idB'),
      discoveryTimeout: const Duration(milliseconds: 50),
      discoveryInterval: const Duration(milliseconds: 50),
    );
  });

  tearDown(() async {
    await coordA.stop();
    await coordB.stop();
    await a.close();
    await b.close();
  });

  test(
      'offline: a paired peer that is unreachable causes no transmission '
      '(FR-007, SC-004)', () async {
    final offline = _OfflineTransport();
    final coord = SyncCoordinator(
      isar: a.isar,
      engine: SyncEngine(
        a.isar,
        trustedKeys: {'idB': keysB.publicKey},
        clock: HlcClock(deviceId: 'A'),
      ),
      transport: offline,
      host: _SilentHost(),
      discoveryTimeout: const Duration(milliseconds: 50),
      discoveryInterval: const Duration(milliseconds: 50),
    );
    addTearDown(coord.stop);

    // There really is a paired peer and a pending change...
    final record = await signedChange(
      keys: keysA,
      deviceId: 'A',
      hlcMillis: 1000,
      payload: const ExpenseCodec().toPayload(_expense(
        title: 'Offline edit',
        amount: 111,
        syncGuid: newSyncGuid(),
        sharedSpaceId: 1,
      )),
      contextSyncGuid: 'space-guid-1',
      contextLocalId: 1,
    );
    await a.isar.writeTxn(() => a.isar.changeRecords.put(record));

    await coord.start();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // ...but nothing is reachable, so nothing is dialed and zero bytes leave.
    expect(offline.connects, 0, reason: 'nothing reachable, nothing dialed');
    expect(offline.payloads, isEmpty, reason: 'zero bytes transmitted');
    // The change is still queued locally; offline use loses nothing.
    expect(await a.changeRecords(), hasLength(1));
  });

  test(
      'a signer we never paired is refused before any apply '
      '(droppedBadSignature, SC-008)', () async {
    final stranger = await DeviceKeys.generate('idX');
    final guid = newSyncGuid();
    final record = await signedChange(
      keys: stranger,
      deviceId: 'X',
      hlcMillis: 500,
      payload: const ExpenseCodec().toPayload(_expense(
        title: 'Injected',
        amount: 999,
        syncGuid: guid,
        sharedSpaceId: 2,
      )),
      contextSyncGuid: 'space-guid-1',
      contextLocalId: 2,
    );

    final engineB = SyncEngine(
      b.isar,
      trustedKeys: {'idA': keysA.publicKey},
      clock: HlcClock(deviceId: 'B'),
    );
    expect(
      await engineB.applyIncoming(record, peerId: 1),
      ApplyOutcome.droppedBadSignature,
    );
    expect(await b.expenseByGuid(guid), isNull,
        reason: 'refused before any apply');
  });

  test('a deactivated context is neither dialed nor accepted (FR-010)',
      () async {
    final guidA = newSyncGuid();
    final guidB = newSyncGuid();
    final recordA = await signedChange(
      keys: keysA,
      deviceId: 'A',
      hlcMillis: 1000,
      payload: const ExpenseCodec().toPayload(_expense(
        title: 'From A',
        amount: 111,
        syncGuid: guidA,
        sharedSpaceId: 1,
      )),
      contextSyncGuid: 'space-guid-1',
      contextLocalId: 1,
    );
    final recordB = await signedChange(
      keys: keysB,
      deviceId: 'B',
      hlcMillis: 2000,
      payload: const ExpenseCodec().toPayload(_expense(
        title: 'From B',
        amount: 222,
        syncGuid: guidB,
        sharedSpaceId: 2,
      )),
      contextSyncGuid: 'space-guid-1',
      contextLocalId: 2,
    );
    await a.isar.writeTxn(() => a.isar.changeRecords.put(recordA));
    await b.isar.writeTxn(() => b.isar.changeRecords.put(recordB));

    // A unpaired/left the space: its context for it goes inactive.
    await a.isar.writeTxn(() async {
      final context = (await a.isar.pairedContexts
          .filter()
          .contextKindEqualTo(ContextKind.shared)
          .contextLocalIdEqualTo(1)
          .findFirst())!;
      context.active = false;
      await a.isar.pairedContexts.put(context);
    });

    await coordA.start();
    await coordB.start();
    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(await b.expenseByGuid(guidA), isNull,
        reason: "A's inactive context is never dialed");
    expect(await a.expenseByGuid(guidB), isNull,
        reason: "A never accepts B's change for the deactivated context");
  });
}
