import '../../support/audit_test_support.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/identity/domain/identity_profile_key.dart';
import 'package:budget_buddy/features/spaces/domain/shared_member_key.dart';
import 'package:budget_buddy/features/spaces/models/bring_in_past.dart';
import 'package:budget_buddy/features/spaces/repositories/month_move_operations.dart';
import 'package:budget_buddy/features/spaces/repositories/spaces_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../medical/repositories/medical_test_harness.dart';

/// Regression: creating a space with a "bring in past months" choice must not
/// lock the Owner out of their own brand-new space (T060 follow-up).
///
/// `createSpace` keys the creator's membership row by the **uniform** identity
/// key ([sharedMemberKeyForLocalProfile]) whenever the profile owns an
/// [Identity] — every paired/syncing phone. But [MonthMoveOperations] resolved
/// the acting member by the raw profile id, found no row, and
/// [SpaceAccessGuard.assertEdit] refused: `bringIn` threw
/// `UnauthorizedSpaceAction` and the whole creation rolled back. The gate now
/// resolves the uniform key too, matching either it or the raw id.
void main() {
  late MedicalTestHarness h;

  setUp(() async {
    h = await MedicalTestHarness.create();
  });
  tearDown(() => h.close());

  test(
      'create with bring-in succeeds when the Owner is keyed by an identity '
      'fingerprint (not the raw profile id)', () async {
    // A personal month the creation will re-home into the new space.
    final seeded = await h.seedBudget(yearMonth: '2026-01');
    final profileId = seeded.profileId;

    // The profile owns an Identity, so the write path keys its membership row by
    // the fingerprint-derived key — not the raw profile id. This is exactly the
    // condition that made bring-in fail on a real phone.
    const fingerprint = 'FINGERPRINT_OWNER';
    final now = DateTime(2026, 1, 1);
    await h.isar.writeTxn(() async {
      await h.isar.identitys.put(
        Identity()
          ..username = 'me'
          ..publicKey = 'pk'
          ..fingerprint = fingerprint
          ..localProfileId = profileId
          ..createdAt = now
          ..updatedAt = now,
      );
      // Claim the seeded month for the profile so it is eligible to be moved.
      final budgets = await h.isar.monthlyBudgets
          .filter()
          .yearMonthEqualTo('2026-01')
          .findAll();
      for (final budget in budgets) {
        budget
          ..profileId = profileId
          ..sharedSpaceId = null;
        await h.isar.monthlyBudgets.put(budget);
      }
    });

    final repo = SpacesRepository(
      h.isar,
      syncRecorder: await auditTestRecorder(h.isar),
      monthMoves: MonthMoveOperations(h.isar,
          recorder: await auditTestRecorder(h.isar),
          rateRegistry: MedicalTestHarness.rates),
    );

    // Before the fix this threw UnauthorizedSpaceAction inside the write txn, so
    // the space was never created.
    final space = await repo.createSpace(
      createdByProfileId: profileId,
      name: 'Home',
      currency: PrimaryCurrency.usd,
      bringIn: BringInPast.thisMonth,
      now: DateTime(2026, 1, 15),
    );

    // The Owner's row is keyed by the uniform membership key, not the raw id.
    final members = await h.isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(space.id)
        .findAll();
    expect(members, hasLength(1));
    expect(members.single.profileId, sharedMemberKey(fingerprint));
    expect(members.single.role, SharedMemberRole.owner);

    // The personal month was re-homed into the new space (move, not copy).
    final moved = await h.isar.monthlyBudgets
        .filter()
        .sharedSpaceIdEqualTo(space.id)
        .and()
        .yearMonthEqualTo('2026-01')
        .findFirst();
    expect(moved, isNotNull, reason: 'bring-in moved the personal month in');

    final personalLeft = await h.isar.monthlyBudgets
        .filter()
        .profileIdEqualTo(profileId)
        .and()
        .yearMonthEqualTo('2026-01')
        .findFirst();
    expect(personalLeft, isNull,
        reason: 'origin month is empty (move, not copy)');
  });

  test(
      'a write still finds the Owner whose membership row keeps the raw '
      'profile id (space made before the identity existed)', () async {
    final seeded = await h.seedBudget(yearMonth: '2026-02');
    final profileId = seeded.profileId;
    final now = DateTime(2026, 2, 1);
    const fingerprint = 'FINGERPRINT_OWNER';
    final peerKey = remoteProfileIdFor('PEER_FINGERPRINT');

    final repo =
        SpacesRepository(h.isar, syncRecorder: await auditTestRecorder(h.isar));

    // The space and its Owner row were written while this profile had no
    // Identity, so the row keeps the raw profile id. The profile gains an
    // Identity afterwards (i.e. it is now a syncing phone), which is what makes
    // the resolution diverge: `sharedMemberKeyForLocalProfile` now returns the
    // fingerprint-derived key, and a single-key lookup would find no row and
    // refuse the real Owner with `UnauthorizedSpaceAction`.
    final space = await h.isar.writeTxn(() async {
      final spaceId = await h.isar.sharedSpaces.put(
        SharedSpace()
          ..name = 'Home'
          ..currency = PrimaryCurrency.usd
          ..createdByProfileId = profileId
          ..createdAt = now,
      );
      await h.isar.sharedMembers.put(
        SharedMember()
          ..sharedSpaceId = spaceId
          ..profileId = profileId
          ..role = SharedMemberRole.owner
          ..joinedAt = now,
      );
      // A paired person, keyed by their identity (always negative).
      await h.isar.sharedMembers.put(
        SharedMember()
          ..sharedSpaceId = spaceId
          ..profileId = peerKey
          ..role = SharedMemberRole.viewer
          ..joinedAt = now,
      );
      await h.isar.identitys.put(
        Identity()
          ..username = 'me'
          ..publicKey = 'pk'
          ..fingerprint = fingerprint
          ..localProfileId = profileId
          ..createdAt = now
          ..updatedAt = now,
      );
      return spaceId;
    });

    // Before the fix this threw for the acting Owner, so removing a person from
    // the space was impossible on a phone that had a space before it had an
    // identity (exactly the reported "nothing was shared" shape).
    await repo.removeMember(
      actingProfileId: profileId,
      spaceId: space,
      profileId: peerKey,
    );

    final remaining = await h.isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(space)
        .findAll();
    expect([for (final member in remaining) member.profileId], [profileId]);
  });
}
