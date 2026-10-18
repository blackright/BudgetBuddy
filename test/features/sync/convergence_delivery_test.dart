import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
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

/// T042: cross-device convergence when the two peers hold a shared space under
/// **different** local row ids — the case 012's same-id tests never exercised
/// (research R5, SC-001/SC-003/SC-007).
///
/// Each device resolves an incoming space to its *own* local id from the signed
/// `contextSyncGuid`, so a create on one phone lands on the other under its own
/// id, and a member's edit to a row the Owner created merges into the **same**
/// row (never a duplicate) because both sides key identity on `syncGuid`.
void main() {
  late SyncTestHarness harnessA;
  late SyncTestHarness harnessB;
  late DeviceKeys owner; // device A
  late DeviceKeys editor; // device B
  late FakeTransportHub hub;
  late Transport endpointA;
  late SyncEngine engineA;
  late SyncEngine engineB;
  late SyncRecorder recorderA;
  late SyncRecorder recorderB;
  late String spaceGuid;

  const int spaceA = 1;
  const int spaceB = 2;

  setUp(() async {
    harnessA = await SyncTestHarness.create();
    harnessB = await SyncTestHarness.create();
    owner = await DeviceKeys.generate('owner');
    editor = await DeviceKeys.generate('editor');

    // One device-independent space identity (015), held under a *distinct* local
    // id on each device — A at 1, B at 2.
    spaceGuid = newSyncGuid();
    await harnessA.createSpaceAt(localId: spaceA, syncGuid: spaceGuid);
    await harnessB.createSpaceAt(localId: spaceB, syncGuid: spaceGuid);

    // A signed (012-managed) space: the Owner authors shared settings and money;
    // the Editor may author money too. Both members are seeded on both devices so
    // apply-time authorization resolves the author's head locally.
    for (final h in [harnessA, harnessB]) {
      final localId = identical(h, harnessA) ? spaceA : spaceB;
      await h.addSignedMember(
          spaceId: localId, keys: owner, role: SharedMemberRole.owner);
      await h.addSignedMember(
          spaceId: localId, keys: editor, role: SharedMemberRole.editor);
    }

    await harnessA.pairContext(peerId: 2, spaceId: spaceA);
    await harnessB.pairContext(peerId: 1, spaceId: spaceB);

    final trusted = {
      owner.identityId: owner.publicKey,
      editor.identityId: editor.publicKey,
    };
    // Both engines run the production own-authored-only snapshot rule (T040).
    engineA = SyncEngine(harnessA.isar,
        trustedKeys: trusted, selfIdentityId: owner.identityId);
    engineB = SyncEngine(harnessB.isar,
        trustedKeys: trusted, selfIdentityId: editor.identityId);

    recorderA = SyncRecorder(
      harnessA.isar,
      signer: Ed25519ChangeSigner(
        authorIdentityId: owner.identityId,
        keyPair: owner.keyPair,
      ),
      clock: HlcClock(deviceId: 'devA'),
    );
    recorderB = SyncRecorder(
      harnessB.isar,
      signer: Ed25519ChangeSigner(
        authorIdentityId: editor.identityId,
        keyPair: editor.keyPair,
      ),
      clock: HlcClock(deviceId: 'devB'),
    );

    hub = harnessA.transport;
    endpointA = hub.endpoint('idA', username: 'A');
    hub.endpoint('idB', username: 'B');
  });

  tearDown(() async {
    await harnessA.close();
    await harnessB.close();
  });

  /// Writes an expense locally and appends its signed change (an "offline edit").
  Future<void> writeExpense(
    SyncTestHarness harness,
    SyncRecorder recorder, {
    required int id,
    required int spaceId,
    required String title,
    required int amount,
    required String syncGuid,
    DateTime? now,
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
    )..syncGuid = syncGuid;
    await harness.isar.writeTxn(() async {
      await harness.isar.expenses.put(expense);
      await recorder.recordExpense(expense, now: now);
    });
  }

  /// Edits an *existing* local row in place and appends the signed change.
  Future<void> editLocal(
    SyncTestHarness harness,
    SyncRecorder recorder,
    Expense expense,
    void Function(Expense) change, {
    DateTime? now,
  }) async {
    change(expense);
    await harness.isar.writeTxn(() async {
      await harness.isar.expenses.put(expense);
      await recorder.recordExpense(expense, now: now);
    });
  }

  /// One full snapshot exchange, A (initiator, local space [spaceA]) against B
  /// (responder, local space [spaceB]).
  Future<void> converge() async {
    final advertisementB =
        hub.advertisements().firstWhere((a) => a.identityId == 'idB');
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

  test(
      'a create on each device converges under distinct local ids '
      '(SC-001/SC-003)', () async {
    final guidA = newSyncGuid();
    final guidB = newSyncGuid();
    await writeExpense(harnessA, recorderA,
        id: 1,
        spaceId: spaceA,
        title: 'A coffee',
        amount: 100,
        syncGuid: guidA);
    await writeExpense(harnessB, recorderB,
        id: 7, spaceId: spaceB, title: 'B lunch', amount: 200, syncGuid: guidB);

    expect(await harnessA.isar.expenses.count(), 1);
    expect(await harnessB.isar.expenses.count(), 1);

    await converge();

    // Both devices hold both rows exactly once, keyed by GUID.
    expect(await harnessA.isar.expenses.count(), 2);
    expect(await harnessB.isar.expenses.count(), 2);

    // Each device re-homes the incoming row onto its *own* space id.
    final aSeesB = await harnessA.expenseByGuid(guidB);
    expect(aSeesB!.title, 'B lunch');
    expect(aSeesB.sharedSpaceId, spaceA,
        reason: "A resolves the incoming space to its own local id ($spaceA)");

    final bSeesA = await harnessB.expenseByGuid(guidA);
    expect(bSeesA!.title, 'A coffee');
    expect(bSeesA.sharedSpaceId, spaceB,
        reason: "B resolves the incoming space to its own local id ($spaceB)");

    // Converging again is a no-op (idempotent, no duplicates).
    await converge();
    expect(await harnessA.isar.expenses.count(), 2);
    expect(await harnessB.isar.expenses.count(), 2);
  });

  test(
      "a member's edit to an Owner-created row merges into the same row "
      '(SC-007)', () async {
    final guid = newSyncGuid();

    // The Owner creates the row on device A.
    await writeExpense(harnessA, recorderA,
        id: 1, spaceId: spaceA, title: 'Original', amount: 100, syncGuid: guid);
    await converge();

    final onB = await harnessB.expenseByGuid(guid);
    expect(onB, isNotNull);
    final rowIdOnB = onB!.id;

    // The member (editor) edits that shared row on device B while apart.
    await editLocal(harnessB, recorderB, onB, (e) {
      e
        ..title = 'B version'
        ..amount = 150;
    });
    await converge();

    // A sees the member's edit land in the *same* row (same local id, no dupe).
    final onA = await harnessA.expenseByGuid(guid);
    expect(onA!.id, 1,
        reason: 'the edit merged into the original row, not a new one');
    expect(onA.title, 'B version');
    expect(onA.amount, 150);
    expect(await harnessA.isar.expenses.count(), 1);
    expect(await harnessB.isar.expenses.count(), 1);
    expect((await harnessB.expenseByGuid(guid))!.id, rowIdOnB);
  });
}
