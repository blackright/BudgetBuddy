import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/sync/domain/hlc.dart';
import 'package:budget_buddy/features/sync/domain/sync_guid.dart';
import 'package:budget_buddy/features/sync/repositories/change_signer.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'package:budget_buddy/features/sync/repositories/sync_recorder.dart';
import 'package:budget_buddy/features/sync/transport/transport.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/change_factory.dart';
import 'support/fake_transport.dart';
import 'support/sync_harness.dart';

void main() {
  late SyncTestHarness harnessA;
  late SyncTestHarness harnessB;
  late DeviceKeys keysA;
  late DeviceKeys keysB;
  late FakeTransportHub hub;
  late Transport endpointA;
  late SyncEngine engineA;
  late SyncEngine engineB;
  late SyncRecorder recorderA;
  late SyncRecorder recorderB;
  late String spaceGuid;

  // The *same* logical space lives under a different local id on each device —
  // the syncGuid, not the local id, is what identifies it on the wire.
  const int spaceA = 1;
  const int spaceB = 2;

  setUp(() async {
    harnessA = await SyncTestHarness.create();
    harnessB = await SyncTestHarness.create();
    keysA = await DeviceKeys.generate('idA');
    keysB = await DeviceKeys.generate('idB');

    hub = harnessA.transport;
    endpointA = hub.endpoint('idA', username: 'A');
    hub.endpoint('idB', username: 'B');

    // Both devices hold the *same* shared space, keyed by one device-independent
    // syncGuid (015) — so each device's records resolve to the peer's space
    // instead of provisioning a brand-new one (the pre-015 local-id shortcut).
    spaceGuid = newSyncGuid();
    await harnessA.createSpaceAt(localId: spaceA, syncGuid: spaceGuid);
    await harnessB.createSpaceAt(localId: spaceB, syncGuid: spaceGuid);
    await harnessA.pairContext(peerId: 2, spaceId: spaceA);
    await harnessB.pairContext(peerId: 1, spaceId: spaceB);

    final trustedKeys = {
      keysA.identityId: keysA.publicKey,
      keysB.identityId: keysB.publicKey,
    };
    engineA = SyncEngine(harnessA.isar,
        trustedKeys: trustedKeys, selfIdentityId: keysA.identityId);
    engineB = SyncEngine(harnessB.isar,
        trustedKeys: trustedKeys, selfIdentityId: keysB.identityId);

    recorderA = SyncRecorder(
      harnessA.isar,
      signer: Ed25519ChangeSigner(
        authorIdentityId: keysA.identityId,
        keyPair: keysA.keyPair,
      ),
      clock: HlcClock(deviceId: 'devA'),
    );
    recorderB = SyncRecorder(
      harnessB.isar,
      signer: Ed25519ChangeSigner(
        authorIdentityId: keysB.identityId,
        keyPair: keysB.keyPair,
      ),
      clock: HlcClock(deviceId: 'devB'),
    );
  });

  tearDown(() async {
    await harnessA.close();
    await harnessB.close();
  });

  /// Writes an expense locally and appends its signed change (an "offline edit").
  ///
  /// [syncGuid] pins the entity identity so two devices can edit the *same*
  /// logical row while apart; omit it to mint a fresh entity.
  Future<void> editExpense(
    SyncTestHarness harness,
    SyncRecorder recorder, {
    required int id,
    required int spaceId,
    required String title,
    required int amount,
    DateTime? now,
    String? syncGuid,
  }) async {
    final expense = Expense(
      id: id,
      profileId: 1,
      sharedSpaceId: spaceId,
      yearMonth: '2026-03',
      title: title,
      amount: amount,
      currency: 'usd',
      categoryId: 'general',
      date: DateTime.utc(2026, 3, 5),
      budgetId: 1,
    )..syncGuid = syncGuid ?? newSyncGuid();
    await harness.isar.writeTxn(() async {
      await harness.isar.expenses.put(expense);
      await recorder.recordExpense(expense, now: now);
    });
  }

  /// Runs one full snapshot exchange between A (initiator) and B (responder).
  Future<void> converge() async {
    final advertisementB =
        hub.advertisements().firstWhere((a) => a.identityId == 'idB');
    // Subscribe to B's incoming stream BEFORE A connects, so nothing is missed.
    final incomingB = hub.nextIncoming('idB');
    final connectionA = await endpointA.connect(advertisementB);
    final connectionB = await incomingB;

    final bFuture =
        engineB.exchange(connectionB, contextLocalId: spaceB, peerId: 1);
    final aFuture = engineA.exchange(connectionA,
        contextLocalId: spaceA, initiator: true, peerId: 2);
    await Future.wait([aFuture, bFuture]);

    await connectionA.close();
    await connectionB.close();
  }

  test('offline edits on both devices converge with no duplicate copy',
      () async {
    final guidA = newSyncGuid();
    final guidB = newSyncGuid();
    await editExpense(harnessA, recorderA,
        id: 1,
        spaceId: spaceA,
        title: 'A coffee',
        amount: 100,
        syncGuid: guidA);
    await editExpense(harnessB, recorderB,
        id: 2, spaceId: spaceB, title: 'B lunch', amount: 200, syncGuid: guidB);

    // Offline: each device only knows its own row.
    expect(await harnessA.isar.expenses.count(), 1);
    expect(await harnessB.isar.expenses.count(), 1);

    await converge();

    // Co-present: both devices hold both rows exactly once.
    expect(await harnessA.isar.expenses.count(), 2);
    expect(await harnessB.isar.expenses.count(), 2);
    expect((await harnessA.expenseByGuid(guidB))!.title, 'B lunch');
    expect((await harnessB.expenseByGuid(guidA))!.title, 'A coffee');
    expect(await harnessA.isar.changeRecords.count(), 2);
    expect(await harnessB.isar.changeRecords.count(), 2);

    // Converging again changes nothing (no duplicates, no half-apply).
    await converge();
    expect(await harnessA.isar.expenses.count(), 2);
    expect(await harnessB.isar.expenses.count(), 2);
    expect(await harnessA.isar.changeRecords.count(), 2);
    expect(await harnessB.isar.changeRecords.count(), 2);
  });

  test('a concurrent edit resolves to the same winner on both devices',
      () async {
    final guid = newSyncGuid();
    // Seed both devices with the same expense via A.
    await editExpense(harnessA, recorderA,
        id: 1,
        spaceId: spaceA,
        title: 'Original',
        amount: 100,
        now: DateTime.utc(2026, 3, 1),
        syncGuid: guid);
    await converge();
    expect((await harnessB.expenseByGuid(guid))!.title, 'Original');

    // Both edit the same row while apart; B's edit is strictly later.
    await editExpense(harnessA, recorderA,
        id: 1,
        spaceId: spaceA,
        title: 'A version',
        amount: 100,
        now: DateTime.utc(2026, 3, 2),
        syncGuid: guid);
    await editExpense(harnessB, recorderB,
        id: 1,
        spaceId: spaceB,
        title: 'B version',
        amount: 100,
        now: DateTime.utc(2026, 3, 3),
        syncGuid: guid);

    await converge();

    expect((await harnessA.expenseByGuid(guid))!.title, 'B version');
    expect((await harnessB.expenseByGuid(guid))!.title, 'B version');
    expect(await harnessA.isar.expenses.count(), 1);
    expect(await harnessB.isar.expenses.count(), 1);
  });
}
