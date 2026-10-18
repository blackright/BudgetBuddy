import 'dart:convert';

import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/context_kind.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/paired_context.dart';
import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/spaces/domain/shared_member_key.dart';
import 'package:budget_buddy/features/sync/domain/change_signing.dart';
import 'package:budget_buddy/features/sync/domain/codecs/shared_member_codec.dart';
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

/// 015 two-phone delivery fix: a snapshot must be judged as **one packet**, so
/// the memberships it carries can grant the authority the apply-time gate checks.
///
/// The phone delivered the Owner's space but the first membership row to land
/// was not the Owner's (the Owner's row arrived later in the same snapshot, or
/// had already been refused once). `SyncEngine._authorize` saw a "managed" space
/// with no local row for the author, so every later record — the Owner's own
/// membership and the money included — became `droppedUnauthorized`, on every
/// retry, forever. That is the deadlock the two-phone log showed: Phone B
/// `applied 0 of 9 record(s)` and stayed at `0 shared context(s)`.
///
/// The fix: resolve the author's membership from the **batch being applied** as
/// well as the local member table. These tests pin both shapes — a batch whose
/// first row is not the Owner, and a receiver that already holds its own
/// membership but no Owner yet.
void main() {
  late SyncTestHarness harnessA;
  late SyncTestHarness harnessB;
  late DeviceKeys owner; // A — authors every record
  late DeviceKeys joiner; // B — the phone being added
  late DeviceKeys
      third; // an older member, so a batch can lead with a non-Owner
  late Map<String, SimplePublicKey> trusted;
  late FakeTransportHub hub;
  late Transport endpointA;
  late SyncEngine engineA;
  late SyncEngine engineB;
  late SyncRecorder recorderA;

  const int spaceA = 1;
  const int spaceB = 2;
  const int peerBOnA = 8;
  const int peerAOnB = 7;
  const String month = '2026-03';

  // `remoteProfileIdFor` keys a membership by the first 12 hex digits of the
  // identity fingerprint, so identity ids must be hex and distinct here — a
  // pair like 'owner'/'joiner' would both reduce to 'e' and share one key.
  const String ownerIdentity = '111122223333';
  const String joinerIdentity = '444455556666';
  const String thirdIdentity = '777788889999';

  setUp(() async {
    harnessA = await SyncTestHarness.create();
    harnessB = await SyncTestHarness.create();
    owner = await DeviceKeys.generate(ownerIdentity);
    joiner = await DeviceKeys.generate(joinerIdentity);
    third = await DeviceKeys.generate(thirdIdentity);

    trusted = {
      owner.identityId: owner.publicKey,
      joiner.identityId: joiner.publicKey,
      third.identityId: third.publicKey,
    };
    engineA = SyncEngine(harnessA.isar,
        trustedKeys: trusted, selfIdentityId: owner.identityId);
    engineB = SyncEngine(harnessB.isar,
        trustedKeys: trusted, selfIdentityId: joiner.identityId);

    recorderA = SyncRecorder(
      harnessA.isar,
      signer: Ed25519ChangeSigner(
        authorIdentityId: owner.identityId,
        keyPair: owner.keyPair,
      ),
      clock: HlcClock(deviceId: 'devA'),
    );

    hub = harnessA.transport;
    endpointA = hub.endpoint('idA', username: 'A');
    hub.endpoint('idB', username: 'B');

    // A knows B and B knows A, so B can mirror the shared context once its own
    // membership lands (T067).
    await harnessA.isar
        .writeTxn(() => harnessA.isar.pairedPeers.put(PairedPeer()
          ..id = peerBOnA
          ..peerIdentityId = joiner.identityId
          ..pairedAt = DateTime(2026)));
    await harnessB.isar
        .writeTxn(() => harnessB.isar.pairedPeers.put(PairedPeer()
          ..id = peerAOnB
          ..peerIdentityId = owner.identityId
          ..pairedAt = DateTime(2026)));
  });

  tearDown(() async {
    await harnessA.close();
    await harnessB.close();
  });

  /// A membership row the Owner authored, signed with the Owner's key.
  Future<SharedMember> ownedMember({
    required int spaceId,
    required int profileId,
    required SharedMemberRole role,
  }) async {
    final member = SharedMember()
      ..sharedSpaceId = spaceId
      ..profileId = profileId
      ..role = role
      ..joinedAt = DateTime(2026)
      ..version = 1
      ..updatedAt = DateTime(2026)
      ..authorIdentityId = owner.identityId;
    final signature = await Ed25519()
        .sign(membershipCanonicalBytes(member), keyPair: owner.keyPair);
    member.signature = base64Encode(signature.bytes);
    return member;
  }

  Expense expenseAt(int id, int spaceId, String guid) => Expense(
        id: id,
        profileId: sharedMemberKey(owner.identityId),
        sharedSpaceId: spaceId,
        yearMonth: month,
        title: 'Groceries',
        amount: 4200,
        currency: 'usd',
        categoryId: 'general',
        date: DateTime.utc(2026, 3, 5),
        budgetId: 0,
      )..syncGuid = guid;

  /// One full snapshot round: A initiates, B responds.
  Future<int> converge() async {
    final advertisementB =
        hub.advertisements().firstWhere((a) => a.identityId == 'idB');
    final incomingB = hub.nextIncoming('idB');
    final connectionA = await endpointA.connect(advertisementB);
    final connectionB = await incomingB;
    final bFuture =
        engineB.exchange(connectionB, contextLocalId: 0, peerId: peerAOnB);
    final aFuture = engineA.exchange(connectionA,
        contextLocalId: spaceA, initiator: true, peerId: peerBOnA);
    final results = await Future.wait([aFuture, bFuture]);
    await connectionA.close();
    await connectionB.close();
    return results[1]; // how many records B applied
  }

  Future<SharedSpace> spaceOnB(String guid) async =>
      (await harnessB.isar.sharedSpaces
          .filter()
          .syncGuidEqualTo(guid)
          .findFirst())!;

  test('the Owner lands even when their membership is not first in the batch',
      () async {
    final spaceGuid = newSyncGuid();
    final expenseGuid = newSyncGuid();

    final space = SharedSpace()
      ..id = spaceA
      ..name = 'Family'
      ..currency = PrimaryCurrency.usd
      ..defaultIncome = 0
      ..createdByProfileId = 1
      ..createdAt = DateTime(2026)
      ..syncGuid = spaceGuid;
    final thirdMember = await ownedMember(
      spaceId: spaceA,
      profileId: sharedMemberKey(third.identityId),
      role: SharedMemberRole.editor,
    );
    final ownerMember = await ownedMember(
      spaceId: spaceA,
      profileId: sharedMemberKey(owner.identityId),
      role: SharedMemberRole.owner,
    );
    final joinerMember = await ownedMember(
      spaceId: spaceA,
      profileId: sharedMemberKey(joiner.identityId),
      role: SharedMemberRole.editor,
    );
    final expense = expenseAt(1, spaceA, expenseGuid);

    await harnessA.isar.writeTxn(() async {
      await harnessA.isar.sharedSpaces.put(space);
      thirdMember.id = await harnessA.isar.sharedMembers.put(thirdMember);
      ownerMember.id = await harnessA.isar.sharedMembers.put(ownerMember);
      joinerMember.id = await harnessA.isar.sharedMembers.put(joinerMember);
      await harnessA.isar.expenses.put(expense);
      // Deliberately author the third member BEFORE the Owner: the delivered
      // order is the batch order, and today the first row to land locks the
      // space, refusing every later author.
      await recorderA.recordSpace(space);
      await recorderA.recordMember(thirdMember);
      await recorderA.recordMember(ownerMember);
      await recorderA.recordMember(joinerMember);
      await recorderA.recordExpense(expense);
    });

    final appliedOnB = await converge();

    expect(appliedOnB, 5, reason: 'the whole snapshot must land');
    final onB = await spaceOnB(spaceGuid);
    expect(
      (await harnessB.memberFor(onB.id, sharedMemberKey(owner.identityId)))!
          .role,
      SharedMemberRole.owner,
      reason: 'the Owner is recognized on B',
    );
    expect(
      (await harnessB.memberFor(onB.id, sharedMemberKey(joiner.identityId)))!
          .role,
      SharedMemberRole.editor,
    );
    expect(await harnessB.expenseByGuid(expenseGuid), isNotNull,
        reason: 'the money authored by the Owner lands too');
    expect(
      await harnessB.isar.pairedContexts
          .filter()
          .contextKindEqualTo(ContextKind.shared)
          .count(),
      greaterThan(0),
      reason: 'B became a member, so it mirrors the context and can send back',
    );
  });

  test('a phone already holding a managed membership still accepts the Owner',
      () async {
    final spaceGuid = newSyncGuid();
    final expenseGuid = newSyncGuid();

    // B already holds the space and its own membership (a partial delivery from
    // an earlier round): the space is 012-managed, but no Owner row has landed
    // yet — the exact wedge the two-phone log showed.
    await harnessB.createSpaceAt(
        localId: spaceB, syncGuid: spaceGuid, name: 'Family');
    final mine = await ownedMember(
      spaceId: spaceB,
      profileId: sharedMemberKey(joiner.identityId),
      role: SharedMemberRole.editor,
    );
    await harnessB.isar.writeTxn(() => harnessB.isar.sharedMembers.put(mine));

    // A holds the same space with the Owner's own membership and a money row.
    final space = SharedSpace()
      ..id = spaceA
      ..name = 'Family'
      ..currency = PrimaryCurrency.usd
      ..defaultIncome = 0
      ..createdByProfileId = 1
      ..createdAt = DateTime(2026)
      ..syncGuid = spaceGuid;
    final ownerMember = await ownedMember(
      spaceId: spaceA,
      profileId: sharedMemberKey(owner.identityId),
      role: SharedMemberRole.owner,
    );
    final expense = expenseAt(1, spaceA, expenseGuid);
    await harnessA.isar.writeTxn(() async {
      await harnessA.isar.sharedSpaces.put(space);
      ownerMember.id = await harnessA.isar.sharedMembers.put(ownerMember);
      await harnessA.isar.expenses.put(expense);
      await recorderA.recordMember(ownerMember);
      await recorderA.recordExpense(expense);
    });

    final appliedOnB = await converge();

    expect(appliedOnB, 2, reason: 'the Owner and the money both land');
    final onB = await spaceOnB(spaceGuid);
    expect(
      (await harnessB.memberFor(onB.id, sharedMemberKey(owner.identityId)))!
          .role,
      SharedMemberRole.owner,
    );
    expect(await harnessB.expenseByGuid(expenseGuid), isNotNull);
  });

  test('a membership already held still names the joiner context', () async {
    final spaceGuid = newSyncGuid();
    await harnessB.createSpaceAt(
        localId: spaceB, syncGuid: spaceGuid, name: 'Family');

    // B already holds its own membership row (a delivery that predates the
    // pairing) and the exact change, so the next arrival is a duplicate.
    final memberGuid = newSyncGuid();
    final stored = SharedMember()
      ..syncGuid = memberGuid
      ..sharedSpaceId = spaceB
      ..profileId = sharedMemberKey(joiner.identityId)
      ..role = SharedMemberRole.editor
      ..joinedAt = DateTime(2026)
      ..version = 1
      ..updatedAt = DateTime(2026)
      ..authorIdentityId = owner.identityId;
    final record = await signedChange(
      keys: owner,
      deviceId: 'devA',
      hlcMillis: DateTime(2026).millisecondsSinceEpoch,
      entityType: 'SharedMember',
      entitySyncGuid: memberGuid,
      payload: const SharedMemberCodec().toPayload(stored),
    );

    await harnessB.isar.writeTxn(() async {
      await harnessB.isar.sharedMembers.put(stored);
      await harnessB.isar.changeRecords.put(record);
    });
    expect(
      await harnessB.isar.pairedContexts
          .filter()
          .contextKindEqualTo(ContextKind.shared)
          .count(),
      0,
      reason: 'B never mirrored a context for the Owner yet',
    );

    final outcome = await engineB.applyIncoming(record, peerId: peerAOnB);

    expect(outcome, ApplyOutcome.duplicate);
    expect(
      await harnessB.isar.pairedContexts
          .filter()
          .contextKindEqualTo(ContextKind.shared)
          .count(),
      1,
      reason: 'the duplicate still names the joiner context so B can send back',
    );
  });
}
