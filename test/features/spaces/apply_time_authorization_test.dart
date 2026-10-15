import 'dart:convert';

import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/spaces/domain/shared_member_key.dart';
import 'package:budget_buddy/features/spaces/repositories/spaces_repository.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/shared_member_codec.dart';
import 'package:budget_buddy/features/sync/domain/hlc.dart';
import 'package:budget_buddy/features/sync/repositories/change_signer.dart';
import 'package:budget_buddy/features/sync/repositories/sync_engine.dart';
import 'package:budget_buddy/features/sync/repositories/sync_recorder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../sync/support/change_factory.dart';
import '../sync/support/sync_harness.dart';

/// T042: apply-time authorization (`contracts/role-authorization.md` §3,
/// FR-008/009, SC-005).
///
/// A signature only proves *who* signed; the role matrix must also hold on the
/// device that **applies** the change. These tests drive `SyncEngine.applyIncoming`
/// directly (the in-memory peer), so a removed/demoted author's later change, a
/// Viewer's money change and a non-Owner's membership change are all refused —
/// every peer drops them the same way, with no cooperation required.
Expense _expense(
        {required int id,
        String title = 'Coffee',
        int amount = 100,
        String yearMonth = '2026-03'}) =>
    Expense(
      id: id,
      profileId: 1,
      sharedSpaceId: 1,
      yearMonth: yearMonth,
      title: title,
      amount: amount,
      currency: 'usd',
      categoryId: 'general',
      date: DateTime.utc(2026, 3, 5),
      budgetId: 1,
    );

SharedMember _member({
  required int id,
  required int profileId,
  required SharedMemberRole role,
}) =>
    SharedMember()
      ..id = id
      ..sharedSpaceId = 1
      ..profileId = profileId
      ..role = role
      ..joinedAt = DateTime(2026)
      ..version = 1;

void main() {
  late SyncTestHarness harnessA;
  late SyncTestHarness harnessB;
  late DeviceKeys owner;
  late DeviceKeys editor;
  late DeviceKeys viewer;
  late SyncEngine engineB;

  /// Seeds the same signed (012-managed) space 1 on both devices, so the engine
  /// treats it as authorization-managed and enforces the role matrix.
  Future<void> seedSpace(SyncTestHarness h) async {
    await h.createSpace(name: 'Home');
    await h.addSignedMember(
        spaceId: 1, keys: owner, role: SharedMemberRole.owner);
    await h.addSignedMember(
        spaceId: 1, keys: editor, role: SharedMemberRole.editor);
    await h.addSignedMember(
        spaceId: 1, keys: viewer, role: SharedMemberRole.viewer);
  }

  Future<ChangeRecord> expenseChange(
    DeviceKeys author, {
    int millis = 1000,
    int id = 1,
    String yearMonth = '2026-03',
  }) =>
      signedChange(
        keys: author,
        deviceId: 'A',
        hlcMillis: millis,
        entityType: 'Expense',
        entityLocalId: id,
        payload: const ExpenseCodec()
            .toPayload(_expense(id: id, yearMonth: yearMonth)),
      );

  Future<ChangeRecord> memberChange(
    DeviceKeys author, {
    required SharedMember member,
    int millis = 1000,
  }) =>
      signedChange(
        keys: author,
        deviceId: 'A',
        hlcMillis: millis,
        entityType: 'SharedMember',
        entityLocalId: member.id,
        payload: const SharedMemberCodec().toPayload(member),
      );

  setUp(() async {
    harnessA = await SyncTestHarness.create();
    harnessB = await SyncTestHarness.create();
    owner = await DeviceKeys.generate('owner');
    editor = await DeviceKeys.generate('editor');
    viewer = await DeviceKeys.generate('viewer');
    final trusted = {
      owner.identityId: owner.publicKey,
      editor.identityId: editor.publicKey,
      viewer.identityId: viewer.publicKey,
    };
    engineB = SyncEngine(harnessB.isar, trustedKeys: trusted);
    await seedSpace(harnessA);
    await seedSpace(harnessB);
  });

  tearDown(() async {
    await harnessA.close();
    await harnessB.close();
  });

  test('an Editor\'s money change is applied (FR-008 baseline)', () async {
    final outcome = await engineB.applyIncoming(await expenseChange(editor));
    expect(outcome, ApplyOutcome.applied);
    expect((await harnessB.isar.expenses.get(1))!.title, 'Coffee');
  });

  test('a Viewer\'s money change is dropped on every peer (FR-009, SC-005)',
      () async {
    final outcome = await engineB.applyIncoming(await expenseChange(viewer));
    expect(outcome, ApplyOutcome.droppedUnauthorized);
    expect(await harnessB.isar.expenses.get(1), isNull);
  });

  test('an unknown author (trusted key, no membership) is dropped', () async {
    // The key is known (as if paired elsewhere) but the identity holds no
    // membership in this space, so authorization — not the signature — refuses.
    final stranger = await DeviceKeys.generate('stranger');
    engineB.trust(stranger.identityId, stranger.publicKey);

    final outcome = await engineB.applyIncoming(await expenseChange(stranger));
    expect(outcome, ApplyOutcome.droppedUnauthorized);
    expect(await harnessB.isar.expenses.get(1), isNull);
  });

  test('a removed author\'s later change is dropped (revokedAt, §2)', () async {
    // Remove the editor, then author a change strictly later than the removal.
    await harnessB.setMemberHead(
      spaceId: 1,
      keys: editor,
      role: SharedMemberRole.editor,
      version: 5000,
      revokedAt: DateTime.utc(2026, 1, 1),
    );

    final later =
        await engineB.applyIncoming(await expenseChange(editor, millis: 6000));
    expect(later, ApplyOutcome.droppedUnauthorized);
    expect(await harnessB.isar.expenses.get(1), isNull);
  });

  test(
      'a change authored before a removal still applies (authorization is '
      'resolved as of the change\'s HLC)', () async {
    await harnessB.setMemberHead(
      spaceId: 1,
      keys: editor,
      role: SharedMemberRole.editor,
      version: 5000,
      revokedAt: DateTime.utc(2026, 1, 1),
    );

    final earlier =
        await engineB.applyIncoming(await expenseChange(editor, millis: 1000));
    expect(earlier, ApplyOutcome.applied);
    expect(await harnessB.isar.expenses.get(1), isNotNull);
  });

  test('a demoted author\'s later money change is dropped', () async {
    await harnessB.setMemberHead(
      spaceId: 1,
      keys: editor,
      role: SharedMemberRole.viewer,
      version: 5000,
    );

    final outcome =
        await engineB.applyIncoming(await expenseChange(editor, millis: 6000));
    expect(outcome, ApplyOutcome.droppedUnauthorized);
    expect(await harnessB.isar.expenses.get(1), isNull);
  });

  test('a non-Owner cannot author a membership change (owner-only)', () async {
    final promote = _member(
      id: 3,
      profileId: sharedMemberKey(viewer.identityId),
      role: SharedMemberRole.owner,
    );

    final denied = await engineB
        .applyIncoming(await memberChange(editor, member: promote));
    expect(denied, ApplyOutcome.droppedUnauthorized);

    final allowed =
        await engineB.applyIncoming(await memberChange(owner, member: promote));
    expect(allowed, ApplyOutcome.applied);
    expect(
      (await harnessB.isar.sharedMembers.get(3))!.role,
      SharedMemberRole.owner,
      reason: 'the Owner-authored promotion is the one that lands',
    );
  });

  test(
      'a transfer authored by the Owner converges to exactly one Owner on the '
      'peer (FR-014)', () async {
    final promoteEditor = _member(
      id: 2,
      profileId: sharedMemberKey(editor.identityId),
      role: SharedMemberRole.owner,
    );
    final demoteOwner = _member(
      id: 1,
      profileId: sharedMemberKey(owner.identityId),
      role: SharedMemberRole.editor,
    );

    expect(
      await engineB.applyIncoming(
          await memberChange(owner, member: promoteEditor, millis: 1000)),
      ApplyOutcome.applied,
    );
    expect(
      await engineB.applyIncoming(
          await memberChange(owner, member: demoteOwner, millis: 1001)),
      ApplyOutcome.applied,
    );

    final ownerCount = await harnessB.isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(1)
        .roleEqualTo(SharedMemberRole.owner)
        .count();
    expect(ownerCount, 1, reason: 'a space never drops below one Owner');
    expect(
      (await harnessB.isar.sharedMembers
              .filter()
              .profileIdEqualTo(sharedMemberKey(editor.identityId))
              .findFirst())!
          .role,
      SharedMemberRole.owner,
    );
  });

  test(
      'T045: createSpace authors a signed, versioned Owner membership keyed by '
      'the derived identity id (T044a)', () async {
    final harness = await SyncTestHarness.create();
    addTearDown(harness.close);
    final keys = await DeviceKeys.generate('creator');

    final profileId = await harness.isar.writeTxn(
      () => harness.isar.userProfiles.put(
        UserProfile()
          ..name = 'Owner'
          ..primaryCurrency = PrimaryCurrency.usd
          ..monthlyAvailableAmount = 0
          ..defaultNetSalary = 0
          ..createdAt = DateTime(2026)
          ..updatedAt = DateTime(2026),
      ),
    );
    final identity = Identity()
      ..username = 'Owner'
      ..publicKey = base64Encode(keys.publicKey.bytes)
      ..keyAlgorithm = 'ed25519'
      ..localProfileId = profileId
      ..fingerprint = keys.identityId
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await harness.isar.writeTxn(() => harness.isar.identitys.put(identity));

    final repo = SpacesRepository(
      harness.isar,
      syncRecorder: SyncRecorder(
        harness.isar,
        signer: Ed25519ChangeSigner(
          authorIdentityId: keys.identityId,
          keyPair: keys.keyPair,
        ),
        clock: HlcClock(deviceId: 'devA'),
      ),
    );
    final space = await repo.createSpace(
      createdByProfileId: profileId,
      name: 'Home',
      currency: PrimaryCurrency.usd,
    );

    final member = await harness.isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(space.id)
        .findFirst();
    expect(member, isNotNull);
    expect(
      member!.profileId,
      sharedMemberKey(keys.identityId),
      reason: 'the creator membership is keyed by the derived identity id',
    );
    expect(member.authorIdentityId, keys.identityId);
    expect(member.version, greaterThan(0),
        reason: 'membership writes carry a fresh HLC version');
    expect(member.signature, isNotNull,
        reason: 'membership writes are signed for apply-time verification');
  });
}
