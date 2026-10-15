import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/sync/domain/hlc.dart';
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

  setUp(() async {
    harnessA = await SyncTestHarness.create();
    harnessB = await SyncTestHarness.create();
    keysA = await DeviceKeys.generate('idA');
    keysB = await DeviceKeys.generate('idB');

    hub = harnessA.transport;
    endpointA = hub.endpoint('idA', username: 'A');
    hub.endpoint('idB', username: 'B');

    // Both devices hold the same shared space (id 1) and have paired it.
    await harnessA.createSpace(name: 'Home');
    await harnessB.createSpace(name: 'Home');
    await harnessA.pairContext(peerId: 2, spaceId: 1);
    await harnessB.pairContext(peerId: 1, spaceId: 1);

    final trustedKeys = {
      keysA.identityId: keysA.publicKey,
      keysB.identityId: keysB.publicKey,
    };
    engineA = SyncEngine(harnessA.isar, trustedKeys: trustedKeys);
    engineB = SyncEngine(harnessB.isar, trustedKeys: trustedKeys);

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
  Future<void> editExpense(
    SyncTestHarness harness,
    SyncRecorder recorder, {
    required int id,
    required String title,
    required int amount,
    DateTime? now,
  }) async {
    final expense = Expense(
      id: id,
      profileId: 1,
      sharedSpaceId: 1,
      yearMonth: '2026-03',
      title: title,
      amount: amount,
      currency: 'usd',
      categoryId: 'general',
      date: DateTime.utc(2026, 3, 5),
      budgetId: 1,
    );
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

    final bFuture = engineB.exchange(connectionB, contextLocalId: 1, peerId: 1);
    final aFuture = engineA.exchange(connectionA,
        contextLocalId: 1, initiator: true, peerId: 2);
    await Future.wait([aFuture, bFuture]);

    await connectionA.close();
    await connectionB.close();
  }

  test('offline edits on both devices converge with no duplicate copy',
      () async {
    await editExpense(harnessA, recorderA,
        id: 1, title: 'A coffee', amount: 100);
    await editExpense(harnessB, recorderB,
        id: 2, title: 'B lunch', amount: 200);

    // Offline: each device only knows its own row.
    expect(await harnessA.isar.expenses.count(), 1);
    expect(await harnessB.isar.expenses.count(), 1);

    await converge();

    // Co-present: both devices hold both rows exactly once.
    expect(await harnessA.isar.expenses.count(), 2);
    expect(await harnessB.isar.expenses.count(), 2);
    expect((await harnessA.isar.expenses.get(2))!.title, 'B lunch');
    expect((await harnessB.isar.expenses.get(1))!.title, 'A coffee');
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
    // Seed both devices with the same expense via A.
    await editExpense(harnessA, recorderA,
        id: 1, title: 'Original', amount: 100, now: DateTime.utc(2026, 3, 1));
    await converge();
    expect((await harnessB.isar.expenses.get(1))!.title, 'Original');

    // Both edit the same row while apart; B's edit is strictly later.
    await editExpense(harnessA, recorderA,
        id: 1, title: 'A version', amount: 100, now: DateTime.utc(2026, 3, 2));
    await editExpense(harnessB, recorderB,
        id: 1, title: 'B version', amount: 100, now: DateTime.utc(2026, 3, 3));

    await converge();

    expect((await harnessA.isar.expenses.get(1))!.title, 'B version');
    expect((await harnessB.isar.expenses.get(1))!.title, 'B version');
    expect(await harnessA.isar.expenses.count(), 1);
    expect(await harnessB.isar.expenses.count(), 1);
  });
}
