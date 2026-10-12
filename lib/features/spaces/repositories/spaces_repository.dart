import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../expenses/models/reimbursement.dart';
import '../models/bring_in_past.dart';
import 'month_move_operations.dart';
import 'space_role_guard.dart';

/// The single data-layer authority for shared-space membership and settings
/// (contracts/space-roles §1, FR-002/006/014).
///
/// Every write loads the acting profile's [SharedMember] row and funnels it
/// through [SpaceAccessGuard] inside the same write transaction — an Editor or
/// Viewer calling any of these methods directly gets [UnauthorizedSpaceAction]
/// and nothing is persisted (US4 "the UI hides, the guard refuses").
///
/// Invariants proven by the T031 matrix:
/// - a space always has at least one Owner (leave / demote / remove / transfer
///   all refuse the last Owner);
/// - one membership per (space, profile): a duplicate invite is refused rather
///   than silently rewriting the role;
/// - transfer flips new Owner on and drops the former Owner to Editor atomically.
class SpacesRepository {
  SpacesRepository(
    this._isar, {
    SpaceAccessGuard guard = const SpaceAccessGuard(),
    MonthMoveOperations? monthMoves,
  })  : _guard = guard,
        _monthMoves = monthMoves;

  final Isar _isar;
  final SpaceAccessGuard _guard;

  /// The month-move engine used to bring past months in at creation. Optional
  /// so a caller that never creates with a bring-in choice (or a test fake)
  /// needs no rate registry; when absent, creation never moves months.
  final MonthMoveOperations? _monthMoves;

  // ---------------------------------------------------------------------------
  // Creation
  // ---------------------------------------------------------------------------

  /// Creates a space, making [createdByProfileId] its first Owner in the same
  /// transaction (FR-006: creator becomes Owner, joinedAt == createdAt).
  ///
  /// When [bringIn] is given and a month-move engine is wired, the creator's
  /// eligible **personal** months are re-homed into the space inside the same
  /// transaction — move, never copy (FR-007/010, US5). A brand-new space still
  /// owns nothing when the creator has no matching personal month (the caller
  /// must not auto-provision the current month; FR-011).
  Future<SharedSpace> createSpace({
    required int createdByProfileId,
    required String name,
    String avatar = '👨‍👩‍👧',
    required PrimaryCurrency currency,
    int defaultIncome = 0,
    BringInPast bringIn = BringInPast.thisMonth,
    DateTime? now,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'A space needs a name');
    }
    if (defaultIncome < 0) {
      throw ArgumentError.value(
          defaultIncome, 'defaultIncome', 'Our income cannot be negative');
    }
    return _isar.writeTxn(() async {
      final clock = now ?? DateTime.now();
      final space = SharedSpace()
        ..name = trimmedName
        ..avatar = avatar
        ..currency = currency
        ..defaultIncome = defaultIncome
        ..createdByProfileId = createdByProfileId
        ..createdAt = clock;
      space.id = await _isar.sharedSpaces.put(space);

      final creator = SharedMember()
        ..sharedSpaceId = space.id
        ..profileId = createdByProfileId
        ..role = SharedMemberRole.owner
        ..joinedAt = clock;
      await _isar.sharedMembers.put(creator);

      await _bringInPast(
        spaceId: space.id,
        createdByProfileId: createdByProfileId,
        bringIn: bringIn,
        now: clock,
      );
      return space;
    });
  }

  /// Re-homes the creator's eligible personal months into [spaceId] (move, never
  /// copy), skipping months that do not exist. Caller holds the write txn.
  Future<void> _bringInPast({
    required int spaceId,
    required int createdByProfileId,
    required BringInPast bringIn,
    required DateTime now,
  }) async {
    final moves = _monthMoves;
    if (moves == null) return;

    final personal = await _isar.monthlyBudgets
        .filter()
        .profileIdEqualTo(createdByProfileId)
        .findAll();
    if (personal.isEmpty) return;

    final months = <String>{for (final budget in personal) budget.yearMonth};
    final eligible = _eligibleMonths(bringIn, months, now);
    eligible.sort();
    for (final yearMonth in eligible) {
      await moves.moveMonthInTxn(
        ContextRef.personal(
            profileId: createdByProfileId, yearMonth: yearMonth),
        ContextRef.shared(spaceId: spaceId, yearMonth: yearMonth),
        yearMonth,
        actingProfileId: createdByProfileId,
      );
    }
  }

  /// The months a [bringIn] choice selects from the creator's [owned] months,
  /// always skipping months that do not exist (FR-010).
  static List<String> _eligibleMonths(
    BringInPast bringIn,
    Set<String> owned,
    DateTime now,
  ) {
    switch (bringIn) {
      case BringInPast.thisMonth:
        final key = _monthKey(now);
        return owned.contains(key) ? <String>[key] : <String>[];
      case BringInPast.thisYear:
        final year = now.year.toString().padLeft(4, '0');
        return [
          for (final key in owned)
            if (key.startsWith('$year-')) key,
        ];
      case BringInPast.everything:
        return owned.toList();
    }
  }

  static String _monthKey(DateTime when) =>
      '${when.year.toString().padLeft(4, '0')}-'
      '${when.month.toString().padLeft(2, '0')}';

  // ---------------------------------------------------------------------------
  // Space settings (manage gate)
  // ---------------------------------------------------------------------------

  /// Updates the space identity ([name], [avatar], [currency],
  /// [defaultIncome]); Owner-only, partial updates allowed.
  Future<void> updateSpace({
    required int actingProfileId,
    required int spaceId,
    String? name,
    String? avatar,
    PrimaryCurrency? currency,
    int? defaultIncome,
  }) {
    return _isar.writeTxn(() async {
      _guard.assertManage(await _member(spaceId, actingProfileId));
      final space = await _requireSpace(spaceId);
      if (name != null) {
        final trimmed = name.trim();
        if (trimmed.isEmpty) {
          throw ArgumentError.value(name, 'name', 'A space needs a name');
        }
        space.name = trimmed;
      }
      if (avatar != null) space.avatar = avatar;
      if (currency != null) space.currency = currency;
      if (defaultIncome != null) {
        if (defaultIncome < 0) {
          throw ArgumentError.value(
              defaultIncome, 'defaultIncome', 'Our income cannot be negative');
        }
        space.defaultIncome = defaultIncome;
      }
      await _isar.sharedSpaces.put(space);
    });
  }

  /// Deletes an **empty** shared space and all its memberships atomically.
  ///
  /// A space that owns months or money rows is refused until the per-month
  /// move/delete flow (US3's `moveMonth`) settles each month — history is never
  /// silently destroyed (spec edge, FR-014). Member profiles are untouched.
  Future<void> deleteSpace({
    required int actingProfileId,
    required int spaceId,
  }) {
    return _isar.writeTxn(() async {
      _guard.assertManage(await _member(spaceId, actingProfileId));
      await _requireSpace(spaceId);

      final hasMoney = await _isar.monthlyBudgets
                  .filter()
                  .sharedSpaceIdEqualTo(spaceId)
                  .count() >
              0 ||
          await _isar.expenses.filter().sharedSpaceIdEqualTo(spaceId).count() >
              0 ||
          await _isar.reimbursements
                  .filter()
                  .sharedSpaceIdEqualTo(spaceId)
                  .count() >
              0 ||
          await _isar.medicalBills
                  .filter()
                  .sharedSpaceIdEqualTo(spaceId)
                  .count() >
              0;
      if (hasMoney) {
        throw const UnauthorizedSpaceAction(
          'this space owns months or money rows; move or delete them first '
          '(per-month flow)',
        );
      }

      await _isar.sharedMembers
          .filter()
          .sharedSpaceIdEqualTo(spaceId)
          .deleteAll();
      // The space's remaining context-level directory rows go with it; member
      // profiles and their personal rows are untouched (FR-014).
      await _isar.insuranceProfiles
          .filter()
          .sharedSpaceIdEqualTo(spaceId)
          .deleteAll();
      await _isar.familyMembers
          .filter()
          .sharedSpaceIdEqualTo(spaceId)
          .deleteAll();
      await _isar.medicalProviders
          .filter()
          .sharedSpaceIdEqualTo(spaceId)
          .deleteAll();
      await _isar.medicalServiceTypes
          .filter()
          .sharedSpaceIdEqualTo(spaceId)
          .deleteAll();
      await _isar.sharedSpaces.delete(spaceId);
    });
  }

  // ---------------------------------------------------------------------------
  // Membership (manage gate)
  // ---------------------------------------------------------------------------

  /// Invites a local profile with a role; Owner-only (FR-002). One membership
  /// per (space, profile) — inviting an existing member is refused (I2).
  Future<void> invite({
    required int actingProfileId,
    required int spaceId,
    required int profileId,
    required SharedMemberRole role,
  }) {
    return _isar.writeTxn(() async {
      _guard.assertManage(await _member(spaceId, actingProfileId));
      await _requireSpace(spaceId);
      final existing = await _isar.sharedMembers
          .filter()
          .sharedSpaceIdEqualTo(spaceId)
          .profileIdEqualTo(profileId)
          .findFirst();
      if (existing != null) {
        throw ArgumentError.value(
            profileId, 'profileId', 'Already a member of this space');
      }
      await _isar.sharedMembers.put(
        SharedMember()
          ..sharedSpaceId = spaceId
          ..profileId = profileId
          ..role = role
          ..joinedAt = DateTime.now(),
      );
    });
  }

  /// Changes a member's role; Owner-only. Demoting the **last** Owner is
  /// refused (FR-006, FR-014) so a space never drops to zero Owners.
  Future<void> setRole({
    required int actingProfileId,
    required int spaceId,
    required int profileId,
    required SharedMemberRole role,
  }) {
    return _isar.writeTxn(() async {
      _guard.assertManage(await _member(spaceId, actingProfileId));
      final member = await _member(spaceId, profileId);
      if (member == null) {
        throw ArgumentError.value(profileId, 'profileId', 'Not a member');
      }
      if (member.role == SharedMemberRole.owner &&
          role != SharedMemberRole.owner) {
        if (await _ownerCount(spaceId) <= 1) {
          throw const UnauthorizedSpaceAction(
            'a space must always have at least one Owner; transfer ownership '
            'first (FR-006/FR-014)',
          );
        }
      }
      member.role = role;
      await _isar.sharedMembers.put(member);
    });
  }

  /// Removes a member; Owner-only. Removing the **last** Owner is refused.
  Future<void> removeMember({
    required int actingProfileId,
    required int spaceId,
    required int profileId,
  }) {
    return _isar.writeTxn(() async {
      _guard.assertManage(await _member(spaceId, actingProfileId));
      final member = await _member(spaceId, profileId);
      if (member == null) {
        throw ArgumentError.value(profileId, 'profileId', 'Not a member');
      }
      if (member.role == SharedMemberRole.owner &&
          await _ownerCount(spaceId) <= 1) {
        throw const UnauthorizedSpaceAction(
          'a space must always have at least one Owner; transfer ownership '
          'first (FR-006/FR-014)',
        );
      }
      await _isar.sharedMembers.delete(member.id);
    });
  }

  /// Hands the space to [newOwnerProfileId] and drops the former Owner to
  /// Editor in the same transaction (FR-014). The former Owner may then stay
  /// or leave.
  Future<void> transferOwnership({
    required int actingProfileId,
    required int spaceId,
    required int newOwnerProfileId,
  }) {
    return _isar.writeTxn(() async {
      _guard.assertManage(await _member(spaceId, actingProfileId));
      final newOwner = await _member(spaceId, newOwnerProfileId);
      if (newOwner == null) {
        throw const UnauthorizedSpaceAction(
          'ownership can only transfer to an existing member',
        );
      }
      final former = await _member(spaceId, actingProfileId);
      newOwner.role = SharedMemberRole.owner;
      await _isar.sharedMembers.put(newOwner);
      if (former != null && former.id != newOwner.id) {
        former.role = SharedMemberRole.editor;
        await _isar.sharedMembers.put(former);
      }
    });
  }

  /// Leaves a space. Refused while [profileId] is the **only** Owner — transfer
  /// ownership (or delete the space) first (US2 AC3, FR-014).
  Future<void> leaveSpace({
    required int profileId,
    required int spaceId,
  }) {
    return _isar.writeTxn(() async {
      final member = await _member(spaceId, profileId);
      if (member == null) return;
      if (member.role == SharedMemberRole.owner &&
          await _ownerCount(spaceId) <= 1) {
        throw const UnauthorizedSpaceAction(
          'you are the only Owner; transfer ownership or delete the space '
          'before leaving (FR-014)',
        );
      }
      await _isar.sharedMembers.delete(member.id);
    });
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  Future<SharedMember?> _member(int spaceId, int profileId) =>
      _isar.sharedMembers
          .filter()
          .sharedSpaceIdEqualTo(spaceId)
          .profileIdEqualTo(profileId)
          .findFirst();

  Future<int> _ownerCount(int spaceId) => _isar.sharedMembers
      .filter()
      .sharedSpaceIdEqualTo(spaceId)
      .roleEqualTo(SharedMemberRole.owner)
      .count();

  Future<SharedSpace> _requireSpace(int spaceId) async {
    final space = await _isar.sharedSpaces.get(spaceId);
    if (space == null) {
      throw ArgumentError.value(spaceId, 'spaceId', 'No such shared space');
    }
    return space;
  }
}

final spacesRepositoryProvider = Provider<SpacesRepository>(
  (ref) {
    final isar = IsarHelper.instance;
    return SpacesRepository(
      isar,
      monthMoves: MonthMoveOperations(
        isar,
        rateRegistry: ref.watch(rateRegistryProvider),
        guard: ref.watch(spaceRoleGuardProvider),
      ),
    );
  },
);
