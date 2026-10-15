import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/spaces/repositories/space_role_guard.dart';
import 'package:budget_buddy/features/spaces/repositories/spaces_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../medical/repositories/medical_test_harness.dart';

/// T031: the `SpacesRepository` role/membership matrix (FR-002/006/014, US2
/// AC2-4; contracts/space-roles §3-5).
///
/// Every management operation is Owner-only and enforced inside the write
/// transaction — not by the calling screen — so an Editor or Viewer calling a
/// repository method directly gets `UnauthorizedSpaceAction` and nothing is
/// persisted. The last-Owner invariant (a space always has >= 1 Owner) is proven
/// across the leave / demote / remove / transfer paths (I3).
void main() {
  late MedicalTestHarness harness;
  late SpacesRepository repo;
  late int ownerId;
  late int editorId;
  late int viewerId;

  Future<int> addProfile(String name) async {
    final now = DateTime(2026, 1, 1);
    final profile = UserProfile()
      ..name = name
      ..avatar = '👤'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..defaultNetSalary = 0
      ..createdAt = now
      ..updatedAt = now;
    final id = await harness.isar.writeTxn(
      () => harness.isar.userProfiles.put(profile),
    );
    return id;
  }

  setUp(() async {
    harness = await MedicalTestHarness.create();
    repo = SpacesRepository(harness.isar);
    ownerId = await addProfile('Owner');
    editorId = await addProfile('Editor');
    viewerId = await addProfile('Viewer');
  });

  Future<int> createdSpace() async {
    final space = await repo.createSpace(
      createdByProfileId: ownerId,
      name: 'Home',
      avatar: '🏠',
      currency: PrimaryCurrency.huf,
      defaultIncome: 3000,
    );
    return space.id;
  }

  tearDown(() => harness.close());

  test('creator becomes the Owner with joinedAt == createdAt (FR-006)',
      () async {
    final spaceId = await createdSpace();
    final space = await harness.isar.sharedSpaces.get(spaceId);

    final members = await harness.isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll();
    expect(members, hasLength(1));
    expect(members.single.profileId, ownerId);
    expect(members.single.role, SharedMemberRole.owner);
    expect(
      members.single.joinedAt,
      space!.createdAt,
      reason: 'the creator joins at the moment the space is created',
    );
  });

  test('invite-only membership: only the Owner can invite (FR-002)', () async {
    final spaceId = await createdSpace();

    // The non-owner Editor cannot invite anyone.
    expect(
      () => repo.invite(
        actingProfileId: editorId,
        spaceId: spaceId,
        profileId: viewerId,
        role: SharedMemberRole.viewer,
      ),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );

    // The Owner invites the viewer; the membership row appears with the role.
    await repo.invite(
      actingProfileId: ownerId,
      spaceId: spaceId,
      profileId: viewerId,
      role: SharedMemberRole.viewer,
    );
    final members = await harness.isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll();
    expect(members, hasLength(2));
    final viewerMember = members.firstWhere((m) => m.profileId == viewerId);
    expect(viewerMember.role, SharedMemberRole.viewer);
    expect(viewerMember.joinedAt.isAfter(DateTime(2020)), isTrue);
  });

  test('a duplicate invite is refused (one membership per space/profile, I2)',
      () async {
    final spaceId = await createdSpace();
    await repo.invite(
      actingProfileId: ownerId,
      spaceId: spaceId,
      profileId: viewerId,
      role: SharedMemberRole.viewer,
    );
    expect(
      () => repo.invite(
        actingProfileId: ownerId,
        spaceId: spaceId,
        profileId: viewerId,
        role: SharedMemberRole.editor,
      ),
      throwsArgumentError,
    );
    final viewerMember = await harness.isar.sharedMembers
        .filter()
        .profileIdEqualTo(viewerId)
        .findFirst();
    expect(viewerMember!.role, SharedMemberRole.viewer,
        reason: 'the duplicate invite must not silently rewrite the role');
  });

  test('a non-member cannot manage a space it cannot even see (canView fails)',
      () async {
    final spaceId = await createdSpace();
    expect(
      () => repo.updateSpace(
        actingProfileId: viewerId,
        spaceId: spaceId,
        name: 'Hijacked',
      ),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );
  });

  test('Owner can rename a space; an Editor cannot (US4 AC3, manage gate)',
      () async {
    final spaceId = await createdSpace();
    await repo.invite(
      actingProfileId: ownerId,
      spaceId: spaceId,
      profileId: editorId,
      role: SharedMemberRole.editor,
    );

    expect(
      () => repo.updateSpace(
        actingProfileId: editorId,
        spaceId: spaceId,
        name: 'Editor rename',
      ),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );

    await repo.updateSpace(
      actingProfileId: ownerId,
      spaceId: spaceId,
      name: 'Family',
    );
    final renamed = await harness.isar.sharedSpaces.get(spaceId);
    expect(renamed!.name, 'Family');
  });

  test('setRole transitions roles under the Owner (FR-005)', () async {
    final spaceId = await createdSpace();
    await repo.invite(
      actingProfileId: ownerId,
      spaceId: spaceId,
      profileId: viewerId,
      role: SharedMemberRole.viewer,
    );

    await repo.setRole(
      actingProfileId: ownerId,
      spaceId: spaceId,
      profileId: viewerId,
      role: SharedMemberRole.editor,
    );
    var member = await harness.isar.sharedMembers
        .filter()
        .profileIdEqualTo(viewerId)
        .findFirst();
    expect(member!.role, SharedMemberRole.editor);

    // A Viewer cannot change anyone's role.
    expect(
      () => repo.setRole(
        actingProfileId: viewerId,
        spaceId: spaceId,
        profileId: editorId,
        role: SharedMemberRole.owner,
      ),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );

    await repo.setRole(
      actingProfileId: ownerId,
      spaceId: spaceId,
      profileId: viewerId,
      role: SharedMemberRole.viewer,
    );
    member = await harness.isar.sharedMembers
        .filter()
        .profileIdEqualTo(viewerId)
        .findFirst();
    expect(member!.role, SharedMemberRole.viewer);
  });

  test('demoting the last Owner is refused (FR-006 / FR-014)', () async {
    final spaceId = await createdSpace();
    final owners = await harness.isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .roleEqualTo(SharedMemberRole.owner)
        .findAll();
    expect(owners, hasLength(1));

    expect(
      () => repo.setRole(
        actingProfileId: ownerId,
        spaceId: spaceId,
        profileId: ownerId,
        role: SharedMemberRole.editor,
      ),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );
    // Nothing changed.
    final stillThere = await harness.isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .roleEqualTo(SharedMemberRole.owner)
        .findAll();
    expect(stillThere, hasLength(1));
  });

  test(
      'transferOwnership: new Owner wins, former Owner becomes Editor (FR-014)',
      () async {
    final spaceId = await createdSpace();
    await repo.invite(
      actingProfileId: ownerId,
      spaceId: spaceId,
      profileId: editorId,
      role: SharedMemberRole.editor,
    );

    await repo.transferOwnership(
      actingProfileId: ownerId,
      spaceId: spaceId,
      newOwnerProfileId: editorId,
    );
    final members = await harness.isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll();
    expect(members.firstWhere((m) => m.profileId == editorId).role,
        SharedMemberRole.owner);
    expect(members.firstWhere((m) => m.profileId == ownerId).role,
        SharedMemberRole.editor);
  });

  test('transfer to a non-member is refused (only members can own)', () async {
    final spaceId = await createdSpace();
    expect(
      () => repo.transferOwnership(
        actingProfileId: ownerId,
        spaceId: spaceId,
        newOwnerProfileId: viewerId,
      ),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );
  });

  test('leaveSpace: the only Owner cannot leave (US2 AC3)', () async {
    final spaceId = await createdSpace();
    expect(
      () => repo.leaveSpace(profileId: ownerId, spaceId: spaceId),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );

    // After a transfer the former Owner is an Editor and may leave.
    await repo.invite(
      actingProfileId: ownerId,
      spaceId: spaceId,
      profileId: editorId,
      role: SharedMemberRole.editor,
    );
    await repo.transferOwnership(
      actingProfileId: ownerId,
      spaceId: spaceId,
      newOwnerProfileId: editorId,
    );
    await repo.leaveSpace(profileId: ownerId, spaceId: spaceId);
    final remaining = await harness.isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll();
    expect(remaining.map((m) => m.profileId), isNot(contains(ownerId)));
    expect(remaining.map((m) => m.profileId), contains(editorId));
  });

  test('removeMember: Owner removes a member; the last Owner is protected',
      () async {
    final spaceId = await createdSpace();
    await repo.invite(
      actingProfileId: ownerId,
      spaceId: spaceId,
      profileId: viewerId,
      role: SharedMemberRole.viewer,
    );

    // The only Owner cannot be removed.
    expect(
      () => repo.removeMember(
        actingProfileId: ownerId,
        spaceId: spaceId,
        profileId: ownerId,
      ),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );

    await repo.removeMember(
      actingProfileId: ownerId,
      spaceId: spaceId,
      profileId: viewerId,
    );
    final remaining = await harness.isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll();
    expect(remaining, hasLength(1));
    expect(remaining.single.profileId, ownerId);
  });

  test(
      'deleteSpace: Owner can delete an empty space atomically; all members go',
      () async {
    final spaceId = await createdSpace();
    await repo.invite(
      actingProfileId: ownerId,
      spaceId: spaceId,
      profileId: viewerId,
      role: SharedMemberRole.viewer,
    );
    await repo.deleteSpace(actingProfileId: ownerId, spaceId: spaceId);

    expect(await harness.isar.sharedSpaces.get(spaceId), isNull);
    expect(
      await harness.isar.sharedMembers
          .filter()
          .sharedSpaceIdEqualTo(spaceId)
          .count(),
      0,
    );
    expect(await harness.isar.userProfiles.where().count(), 3,
        reason: 'member profiles are untouched (FR-014)');
  });

  test(
      'deleteSpace: a non-Owner cannot delete; a space with months is refused '
      'until the move/delete flow runs (spec edge, US3)', () async {
    final spaceId = await createdSpace();
    expect(
      () => repo.deleteSpace(actingProfileId: editorId, spaceId: spaceId),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );

    // A first navigation provisioned a month inside the space: the delete is
    // refused until the per-month move/delete flow (US3) decides each month.
    final now = DateTime(2026, 1, 2);
    await harness.isar.writeTxn(() async {
      await harness.isar.monthlyBudgets.put(
        MonthlyBudget()
          ..sharedSpaceId = spaceId
          ..yearMonth = '2026-01'
          ..baseAvailableAmount = 0
          ..openingBalanceConfirmed = false
          ..createdAt = now
          ..updatedAt = now,
      );
    });
    expect(
      () => repo.deleteSpace(actingProfileId: ownerId, spaceId: spaceId),
      throwsA(isA<UnauthorizedSpaceAction>()),
    );
    final space = await harness.isar.sharedSpaces.get(spaceId);
    expect(space, isNotNull);
  });
}
