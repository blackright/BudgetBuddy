import 'dart:convert';

import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/sync_cursor.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/spaces/domain/shared_member_key.dart';
import 'package:budget_buddy/features/sync/domain/change_signing.dart';
import 'package:budget_buddy/features/sync/domain/hlc.dart';
import 'package:budget_buddy/features/sync/domain/sync_guid.dart';
import 'package:budget_buddy/features/sync/repositories/change_signer.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'package:budget_buddy/features/sync/repositories/sync_recorder.dart';
import 'package:budget_buddy/features/sync/transport/transport.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'support/change_factory.dart';
import 'support/fake_transport.dart';
import 'support/sync_harness.dart';

/// The **send-side** watermark (`SyncCursor.lastSent*`) is what the per-space
/// status derives "nothing is pending" from (T047, research R6): a locally
/// authored record above the lowest watermark has not reached that peer yet.
///
/// T030 claims the engine records that watermark when a snapshot is sent; before
/// this test the field was never written, so a space could never stop saying
/// "waiting for peer". This pins the behaviour down at the engine seam.
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

  const int spaceA = 1;
  const int peerAOnB = 7;
  const int peerBOnA = 8;

  /// The highest HLC in [records] — what a completed send should record.
  Hlc headOf(List<ChangeRecord> records) {
    var head = Hlc.genesis;
    for (final record in records) {
      final hlc = Hlc(record.hlcMillis, record.hlcCounter, record.deviceId);
      if (hlc > head) head = hlc;
    }
    return head;
  }

  Future<SharedMember> addMember({
    required DeviceKeys subject,
    required SharedMemberRole role,
  }) async {
    final member = SharedMember()
      ..sharedSpaceId = spaceA
      ..profileId = sharedMemberKey(subject.identityId)
      ..role = role
      ..joinedAt = DateTime(2026)
      ..version = 1
      ..updatedAt = DateTime(2026)
      ..authorIdentityId = keysA.identityId;
    final signature = await Ed25519()
        .sign(membershipCanonicalBytes(member), keyPair: keysA.keyPair);
    member.signature = base64Encode(signature.bytes);
    member.id = await harnessA.isar
        .writeTxn(() => harnessA.isar.sharedMembers.put(member));
    return member;
  }

  setUp(() async {
    harnessA = await SyncTestHarness.create();
    harnessB = await SyncTestHarness.create();
    keysA = await DeviceKeys.generate('idA');
    keysB = await DeviceKeys.generate('idB');

    hub = harnessA.transport;
    endpointA = hub.endpoint('idA', username: 'A');
    hub.endpoint('idB', username: 'B');

    final trusted = {
      keysA.identityId: keysA.publicKey,
      keysB.identityId: keysB.publicKey,
    };
    engineA = SyncEngine(harnessA.isar,
        trustedKeys: trusted, selfIdentityId: keysA.identityId);
    engineB = SyncEngine(harnessB.isar,
        trustedKeys: trusted, selfIdentityId: keysB.identityId);

    recorderA = SyncRecorder(
      harnessA.isar,
      signer: Ed25519ChangeSigner(
        authorIdentityId: keysA.identityId,
        keyPair: keysA.keyPair,
      ),
      clock: HlcClock(deviceId: 'devA'),
    );

    await harnessA.isar
        .writeTxn(() => harnessA.isar.pairedPeers.put(PairedPeer()
          ..id = peerBOnA
          ..peerIdentityId = keysB.identityId
          ..pairedAt = DateTime(2026)));
    await harnessB.isar
        .writeTxn(() => harnessB.isar.pairedPeers.put(PairedPeer()
          ..id = peerAOnB
          ..peerIdentityId = keysA.identityId
          ..pairedAt = DateTime(2026)));
  });

  tearDown(() async {
    await harnessA.close();
    await harnessB.close();
  });

  test('a completed round advances the send-side watermark to the sent head',
      () async {
    final space = SharedSpace()
      ..id = spaceA
      ..name = 'Family'
      ..currency = PrimaryCurrency.usd
      ..defaultIncome = 0
      ..createdByProfileId = 1
      ..createdAt = DateTime(2026)
      ..syncGuid = newSyncGuid();
    final ownerMember =
        await addMember(subject: keysA, role: SharedMemberRole.owner);
    final editorMember =
        await addMember(subject: keysB, role: SharedMemberRole.editor);

    await harnessA.isar.writeTxn(() async {
      await harnessA.isar.sharedSpaces.put(space);
      await recorderA.recordSpace(space);
      await recorderA.recordMember(ownerMember);
      await recorderA.recordMember(editorMember);
      final expense = Expense(
        id: 1,
        profileId: sharedMemberKey(keysA.identityId),
        sharedSpaceId: spaceA,
        yearMonth: '2026-03',
        title: 'Groceries',
        amount: 4200,
        currency: 'usd',
        categoryId: 'general',
        date: DateTime.utc(2026, 3, 5),
        budgetId: 0,
      )..syncGuid = newSyncGuid();
      await harnessA.isar.expenses.put(expense);
      await recorderA.recordExpense(expense);
    });

    final authored = await harnessA.isar.changeRecords
        .filter()
        .contextLocalIdEqualTo(spaceA)
        .findAll();
    final sentHead = headOf(authored);
    expect(authored, isNotEmpty);
    expect(await harnessA.isar.syncCursors.count(), 0,
        reason: 'nothing has been handed to a peer yet, so nothing is sent');

    // --- One round: A dials B and B answers --------------------------------
    final started = <int>[];
    final finished = <int>[];

    final advertisementB =
        hub.advertisements().firstWhere((a) => a.identityId == 'idB');
    final incomingB = hub.nextIncoming('idB');
    final connectionA = await endpointA.connect(advertisementB);
    final connectionB = await incomingB;
    final bFuture =
        engineB.exchange(connectionB, contextLocalId: 0, peerId: peerAOnB);
    final aFuture = engineA.exchange(
      connectionA,
      contextLocalId: spaceA,
      initiator: true,
      peerId: peerBOnA,
      onRoundStart: started.add,
      onRoundEnd: finished.add,
    );
    await Future.wait([aFuture, bFuture]);
    await connectionA.close();
    await connectionB.close();

    expect(started, [spaceA],
        reason:
            'the UI is told which space is exchanging, not just that one is');
    expect(finished, [spaceA]);

    final cursor = await harnessA.isar.syncCursors
        .filter()
        .peerIdEqualTo(peerBOnA)
        .contextLocalIdEqualTo(spaceA)
        .findFirst();
    expect(cursor, isNotNull,
        reason: 'a completed round records the exchange for the pair');
    expect(cursor!.lastSentHlcMillis, sentHead.millis,
        reason: 'the whole snapshot was handed over, so its head is delivered');
    expect(cursor.lastSentCounter, sentHead.counter);
    expect(cursor.lastSentDeviceId, sentHead.deviceId);

    // --- A later edit is above the watermark again (so it is "pending") -----
    late ChangeRecord laterRec;
    await harnessA.isar.writeTxn(() async {
      final later = Expense(
        id: 2,
        profileId: sharedMemberKey(keysA.identityId),
        sharedSpaceId: spaceA,
        yearMonth: '2026-03',
        title: 'After the round',
        amount: 999,
        currency: 'usd',
        categoryId: 'general',
        date: DateTime.utc(2026, 3, 7),
        budgetId: 0,
      )..syncGuid = newSyncGuid();
      await harnessA.isar.expenses.put(later);
      laterRec = (await recorderA.recordExpense(later))!;
    });

    final watermark = Hlc(cursor.lastSentHlcMillis, cursor.lastSentCounter,
        cursor.lastSentDeviceId);
    expect(Hlc(laterRec.hlcMillis, laterRec.hlcCounter, laterRec.deviceId),
        greaterThan(watermark),
        reason: 'a change made after the round is still owed to the peer');
  });
}
