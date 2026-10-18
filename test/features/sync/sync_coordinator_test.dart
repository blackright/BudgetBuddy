import 'dart:convert';

import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:budget_buddy/features/sync/domain/hlc.dart';
import 'package:budget_buddy/features/sync/domain/sync_guid.dart';
import 'package:budget_buddy/features/sync/repositories/sync_coordinator.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'support/change_factory.dart';
import 'support/fake_transport.dart';
import 'support/sync_harness.dart';

/// T039: the runtime orchestration — discover → connect → per-context round, and
/// refusal of a peer that is not paired (`contracts/runtime-orchestration.md`).
///
/// Two coordinators run over one [FakeTransportHub] (no sockets), each with its
/// own Isar and a distinct local space id, so a round moves a real signed expense
/// across the wire and lands on the same `syncGuid`-keyed row.
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

Future<void> _waitFor(
  Future<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (await condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  throw StateError('condition not met within $timeout');
}

void main() {
  late SyncTestHarness a;
  late SyncTestHarness b;
  late FakeTransportHub hub;
  late DeviceKeys keysA;
  late DeviceKeys keysB;
  late SyncCoordinator coordA;
  late SyncCoordinator coordB;

  /// Round boundaries each side reported, with the **local** space id (T051).
  late List<int> startedA;
  late List<int> endedA;
  late List<int> startedB;
  late List<int> endedB;

  setUp(() async {
    startedA = [];
    endedA = [];
    startedB = [];
    endedB = [];
    a = await SyncTestHarness.create();
    b = await SyncTestHarness.create();
    hub = FakeTransportHub();
    keysA = await DeviceKeys.generate('idA');
    keysB = await DeviceKeys.generate('idB');

    // Same logical space under different local ids and the same syncGuid.
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
      discoveryTimeout: const Duration(milliseconds: 100),
      discoveryInterval: const Duration(milliseconds: 100),
      onRoundStart: startedA.add,
      onRoundEnd: endedA.add,
    );
    coordB = SyncCoordinator(
      isar: b.isar,
      engine: engineB,
      transport: hub.endpoint('idB', username: 'B'),
      host: hub.host('idB'),
      discoveryTimeout: const Duration(milliseconds: 100),
      discoveryInterval: const Duration(milliseconds: 100),
      onRoundStart: startedB.add,
      onRoundEnd: endedB.add,
    );
  });

  tearDown(() async {
    await coordA.stop();
    await coordB.stop();
    await a.close();
    await b.close();
  });

  test('two peers converge: discover → connect → per-context round', () async {
    final guidA = newSyncGuid();
    final guidB = newSyncGuid();
    final recordA = await signedChange(
      keys: keysA,
      deviceId: 'A',
      hlcMillis: 1000,
      payload: const ExpenseCodec().toPayload(_expense(
          title: 'From A', amount: 111, syncGuid: guidA, sharedSpaceId: 1)),
      contextSyncGuid: 'space-guid-1',
      contextLocalId: 1,
    );
    final recordB = await signedChange(
      keys: keysB,
      deviceId: 'B',
      hlcMillis: 2000,
      payload: const ExpenseCodec().toPayload(_expense(
          title: 'From B', amount: 222, syncGuid: guidB, sharedSpaceId: 2)),
      contextSyncGuid: 'space-guid-1',
      contextLocalId: 2,
    );
    await a.isar.writeTxn(() => a.isar.changeRecords.put(recordA));
    await b.isar.writeTxn(() => b.isar.changeRecords.put(recordB));

    await coordA.start();
    await coordB.start();

    // A's record lands on B and B's record lands on A, each under its own ids.
    await _waitFor(() async =>
        await b.expenseByGuid(guidA) != null &&
        await a.expenseByGuid(guidB) != null);

    final onB = (await b.expenseByGuid(guidA))!;
    final onA = (await a.expenseByGuid(guidB))!;
    expect(onB.title, 'From A');
    expect(onB.amount, 111);
    expect(onA.title, 'From B');
    expect(onA.amount, 222);

    // A successful round refreshes the peer's lastSeenAt (FR-013). It is written
    // just after the exchange, so wait for it rather than racing the assert.
    await _waitFor(() async {
      final peers = await a.isar.pairedPeers.where().findAll();
      return peers.single.lastSeenAt != null;
    });

    // T051: each side reports the round against its **own** local space id, so a
    // badge can say "in progress" for exactly the space on screen. The responding
    // side has no other way to know its id, which is why the engine calls back.
    await _waitFor(() async =>
        startedA.isNotEmpty &&
        endedA.isNotEmpty &&
        startedB.isNotEmpty &&
        endedB.isNotEmpty);
    expect(startedA.toSet(), {1});
    expect(endedA.toSet(), {1});
    expect(startedB.toSet(), {2},
        reason: "B's own local id, not the guid A knows it by");
    expect(endedB.toSet(), {2});
  });

  test('an inbound connection from an unpaired peer is refused', () async {
    final stranger = hub.endpoint('idX', username: 'Stranger');
    final advertisementB =
        hub.advertisements().firstWhere((ad) => ad.identityId == 'idB');

    await coordB.start();
    final connection = await stranger.connect(advertisementB);

    // The coordinator closes it before reading anything: the stranger's inbox
    // ends without ever receiving a snapshot (SC-008).
    await expectLater(connection.incoming, emitsDone);
    expect(await b.isar.changeRecords.count(), 0);
  });

  test('start is idempotent and stop closes the host loop', () async {
    await coordA.start();
    expect(coordA.isRunning, isTrue);
    await coordA.start(); // no-op
    expect(coordA.isRunning, isTrue);
    await coordA.stop();
    expect(coordA.isRunning, isFalse);
    await coordA.stop(); // no-op
    expect(coordA.isRunning, isFalse);
  });
}
