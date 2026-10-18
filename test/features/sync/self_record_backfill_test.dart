import 'dart:convert';

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

/// 015 back-fill: rows written while recording was inert — the identity had not
/// unlocked, or the recorder was not wired to the writer yet — never reached the
/// change-log. The outbound snapshot then carried **no** `SharedSpace` and no
/// Owner membership for the space (only the member rows recorded later), so the
/// receiving phone's apply-time gate refused everything: its space was already
/// 012-managed, and the batch's author had no membership head anywhere —
/// `droppedUnauthorized`, `applied 0 of 11`, `0 shared context(s)`.
///
/// [SyncRecorder.backfillContext] journals those missed rows just before the
/// engine builds a snapshot ([SyncEngine] runs it on every send path). These
/// tests pin both halves: the journal itself, and the two-phone delivery that
/// used to apply nothing.
void main() {
  late SyncTestHarness harnessA;
  late SyncTestHarness harnessB;
  late DeviceKeys owner; // A — the phone that wrote rows it never journalised
  late DeviceKeys joiner; // B — the phone waiting for them
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

  setUp(() async {
    harnessA = await SyncTestHarness.create();
    harnessB = await SyncTestHarness.create();
    owner = await DeviceKeys.generate(ownerIdentity);
    joiner = await DeviceKeys.generate(joinerIdentity);

    trusted = {
      owner.identityId: owner.publicKey,
      joiner.identityId: joiner.publicKey,
    };

    recorderA = SyncRecorder(
      harnessA.isar,
      signer: Ed25519ChangeSigner(
        authorIdentityId: owner.identityId,
        keyPair: owner.keyPair,
      ),
      clock: HlcClock(deviceId: 'devA'),
    );
    // The engine as the app wires it: it may journal a missed row itself, right
    // before it builds an outbound snapshot (015 back-fill).
    engineA = SyncEngine(
      harnessA.isar,
      trustedKeys: trusted,
      selfIdentityId: owner.identityId,
      recorder: recorderA,
    );
    engineB = SyncEngine(harnessB.isar,
        trustedKeys: trusted, selfIdentityId: joiner.identityId);

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

  /// A membership the Owner authored, signed with the Owner's key.
  Future<SharedMember> ownedMember({
    required int spaceId,
    required int profileId,
    required SharedMemberRole role,
    String? syncGuid,
  }) async {
    final member = SharedMember()
      ..sharedSpaceId = spaceId
      ..profileId = profileId
      ..role = role
      ..joinedAt = DateTime(2026)
      ..version = 1
      ..updatedAt = DateTime(2026)
      ..authorIdentityId = owner.identityId;
    if (syncGuid != null) member.syncGuid = syncGuid;
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

  SharedSpace ownerSpace(String guid) => SharedSpace()
    ..id = spaceA
    ..name = 'Family'
    ..currency = PrimaryCurrency.usd
    ..defaultIncome = 0
    ..createdByProfileId = 1
    ..createdAt = DateTime(2026)
    ..syncGuid = guid;

  /// The rows as the devices held them on the two-phone log: everything in
  /// place, the change-log **empty**, because the recorder had no signer when
  /// they were written. The repositories still called it on every write — each
  /// call was a no-op.
  Future<void> seedUnjournalised(
    SharedSpace space,
    List<SharedMember> members,
    Expense expense,
  ) async {
    final inert = SyncRecorder(
      harnessA.isar,
      clock: HlcClock(deviceId: 'devA'),
    );
    await harnessA.isar.writeTxn(() async {
      await harnessA.isar.sharedSpaces.put(space);
      for (final member in members) {
        member.id = await harnessA.isar.sharedMembers.put(member);
      }
      await harnessA.isar.expenses.put(expense);
      await inert.recordSpace(space);
      for (final member in members) {
        await inert.recordMember(member);
      }
      await inert.recordExpense(expense);
    });
  }

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

  test('rows written while the recorder was inert reach the change-log',
      () async {
    final spaceGuid = newSyncGuid();
    final expenseGuid = newSyncGuid();
    final space = ownerSpace(spaceGuid);
    final ownerMember = await ownedMember(
      spaceId: spaceA,
      profileId: sharedMemberKey(owner.identityId),
      role: SharedMemberRole.owner,
    );
    final expense = expenseAt(1, spaceA, expenseGuid);

    await seedUnjournalised(space, [ownerMember], expense);
    expect(await harnessA.changeRecords(), isEmpty,
        reason: 'nothing was journalised while recording was inert');
    expect(await engineA.recordsForContext(spaceA), isEmpty,
        reason: 'so today\'s snapshot would leave this phone empty');

    // The identity unlocks: the signed recorder takes over, and the next
    // snapshot sweeps the missed rows into the log before it sends.
    await recorderA.backfillContext(spaceA);

    final snapshot = await engineA.recordsForContext(spaceA);
    expect(
      snapshot.map((r) => r.entityType),
      unorderedEquals(['SharedSpace', 'SharedMember', 'Expense']),
      reason: 'every row of the space reaches the outbound snapshot',
    );
    expect(
        snapshot.every((r) => r.authorIdentityId == owner.identityId), isTrue,
        reason: 'each record is signed by the phone that holds the rows');
    expect(snapshot.every((r) => r.contextSyncGuid == spaceGuid), isTrue);

    // The head Phone B was missing — the Owner's own membership — is among them.
    final ownerRecord =
        snapshot.firstWhere((r) => r.entityType == 'SharedMember');
    final head = const SharedMemberCodec().fromPayload(ownerRecord.payload);
    expect(head.role, SharedMemberRole.owner);
    expect(head.profileId, sharedMemberKey(owner.identityId));

    // Idempotent: a second sweep journals nothing new.
    await recorderA.backfillContext(spaceA);
    expect(await engineA.recordsForContext(spaceA), hasLength(3),
        reason: 'back-fill never duplicates an already-journaled row');
  });

  test(
      'the un-journalised space reaches a phone already holding its membership',
      () async {
    final spaceGuid = newSyncGuid();
    final expenseGuid = newSyncGuid();
    final memberGuid = newSyncGuid();

    // B's phone: the space and its own membership are already here (the Owner
    // added it earlier), so the space is 012-managed and the apply-time gate is
    // live — but no Owner row has ever arrived. Same wire guid as A's row for
    // the joiner: one membership, not two.
    await harnessB.createSpaceAt(
        localId: spaceB, syncGuid: spaceGuid, name: 'Shared space');
    final mine = await ownedMember(
      spaceId: spaceB,
      profileId: sharedMemberKey(joiner.identityId),
      role: SharedMemberRole.editor,
      syncGuid: memberGuid,
    );
    await harnessB.isar.writeTxn(() => harnessB.isar.sharedMembers.put(mine));

    // A's phone: the whole space, nothing journalised — the exact wedge the
    // two-phone log showed (`applied 0 of 11 record(s)`).
    final space = ownerSpace(spaceGuid);
    final ownerMember = await ownedMember(
      spaceId: spaceA,
      profileId: sharedMemberKey(owner.identityId),
      role: SharedMemberRole.owner,
    );
    final joinerMember = await ownedMember(
      spaceId: spaceA,
      profileId: sharedMemberKey(joiner.identityId),
      role: SharedMemberRole.editor,
      syncGuid: memberGuid,
    );
    final expense = expenseAt(1, spaceA, expenseGuid);
    await seedUnjournalised(space, [ownerMember, joinerMember], expense);
    expect(await harnessA.changeRecords(), isEmpty,
        reason: 'the log was empty on the sending phone too');

    final appliedOnB = await converge();

    final sent = (await harnessA.changeRecords())
        .where((r) => r.contextLocalId == spaceA)
        .length;
    expect(sent, 4,
        reason:
            'back-fill journaled the space, both memberships and the money');
    expect(appliedOnB, sent,
        reason: 'applied N of N — no record refused as droppedUnauthorized');

    final onB = await spaceOnB(spaceGuid);
    expect(onB.name, 'Family', reason: 'the real name, not the anchor');
    expect(onB.id, isNot(spaceA), reason: 'B keeps its own local id');
    expect(
      (await harnessB.memberFor(onB.id, sharedMemberKey(owner.identityId)))!
          .role,
      SharedMemberRole.owner,
      reason: 'the Owner\'s head arrives, so B can authorize the space',
    );
    expect(
      (await harnessB.memberFor(onB.id, sharedMemberKey(joiner.identityId)))!
          .role,
      SharedMemberRole.editor,
    );
    expect(await harnessB.expenseByGuid(expenseGuid), isNotNull,
        reason: 'the money lands too');
    expect(
      await harnessB.isar.pairedContexts
          .filter()
          .contextKindEqualTo(ContextKind.shared)
          .contextLocalIdEqualTo(onB.id)
          .activeEqualTo(true)
          .count(),
      1,
      reason: 'B mirrors the context: `dialing … 1 shared context(s)`',
    );
  });
}
