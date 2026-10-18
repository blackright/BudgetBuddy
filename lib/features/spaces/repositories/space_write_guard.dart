import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/month_rate_seal.dart';
import '../../../core/models/shared_member.dart';
import '../domain/shared_member_key.dart';
import 'space_role_guard.dart';

/// Database-backed companion to [SpaceAccessGuard] (contracts/space-roles §2–3).
///
/// [SpaceAccessGuard] is pure and database-free; this service loads the two rows
/// it needs — the acting profile's [SharedMember] row and the month's seal — and
/// then applies the pure rules. Every shared write funnels through here so the
/// guard stays the single security boundary (I1).
class SpaceWriteGuard {
  const SpaceWriteGuard(
    this._isar, {
    SpaceAccessGuard guard = const SpaceAccessGuard(),
  }) : _guard = guard;

  final Isar _isar;
  final SpaceAccessGuard _guard;

  /// The acting profile's membership row in [spaceId], or `null` when the
  /// profile is not a member (which every gate treats as a refusal).
  ///
  /// The write paths key every membership row by the **uniform** identity key
  /// ([sharedMemberKeyForLocalProfile]), so resolve it and match either that key
  /// or the raw [profileId] — the pre-012 fallback — the same dual-key read the
  /// spaces providers use (T060). Matching only the raw id found no row and
  /// refused every shared write for an identity-keyed Owner.
  Future<SharedMember?> memberOf(int spaceId, int? profileId) async {
    if (profileId == null) return null;
    final key = await sharedMemberKeyForLocalProfile(_isar, profileId);
    final members = await _isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll();
    for (final member in members) {
      if (member.profileId == key || member.profileId == profileId) {
        return member;
      }
    }
    return null;
  }

  /// True when a `MonthRateSeal` row exists for [yearMonth] — the app's single
  /// definition of a closed month (RateTableRegistry.isSealedMonth).
  Future<bool> monthIsSealed(String yearMonth) async {
    final count =
        await _isar.monthRateSeals.filter().yearMonthEqualTo(yearMonth).count();
    return count > 0;
  }

  /// A shared money write (expense, bill, reimbursement, income, convert-to)
  /// requires Owner/Editor and an unsealed month (FR-005, FR-012).
  ///
  /// A `null` [sharedSpaceId] is a personal write, where no role applies, so it
  /// passes through untouched.
  Future<void> assertSharedMoneyWrite({
    required int? sharedSpaceId,
    required int? actingProfileId,
    required String yearMonth,
  }) async {
    if (sharedSpaceId == null) return;
    if (actingProfileId == null) {
      throw const UnauthorizedSpaceAction(
        'a shared write needs an acting profile to check membership against',
      );
    }
    final member = await memberOf(sharedSpaceId, actingProfileId);
    _guard.assertMonthEditable(member, sealed: await monthIsSealed(yearMonth));
  }

  /// A shared settings/member write requires the Owner (contracts/space-roles §2).
  Future<void> assertSharedManageWrite({
    required int sharedSpaceId,
    required int? actingProfileId,
  }) async {
    final member = await memberOf(sharedSpaceId, actingProfileId);
    _guard.assertManage(member);
  }
}

/// The app-wide [SpaceWriteGuard] over the live database (T022-style wiring).
final spaceWriteGuardProvider = Provider<SpaceWriteGuard>(
  (ref) => SpaceWriteGuard(IsarHelper.instance),
);
