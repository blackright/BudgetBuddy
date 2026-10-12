import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/shared_member.dart';

/// Thrown by [SpaceAccessGuard] when a shared-space write is refused
/// (contracts/space-roles §3–4).
///
/// Every refusal shares one meaning: the operation did not happen and nothing
/// was persisted. Callers surface the message to identify which rule fired.
class UnauthorizedSpaceAction implements Exception {
  const UnauthorizedSpaceAction(this.message);

  /// Human-readable reason, always mentioning the refusing rule so tests and
  /// logs can pin the exact failure.
  final String message;

  @override
  String toString() => 'UnauthorizedSpaceAction: $message';
}

/// The single authority for shared-space writes (contracts/space-roles §1).
///
/// Pure Dart — no Isar, no Riverpod — so the role matrix is unit-testable
/// without a database (FR-005, SC-005, I1). Repositories load the acting
/// profile's [SharedMember] row and pass it in; a `null` member is a
/// non-member and every gate fails closed.
class SpaceAccessGuard {
  const SpaceAccessGuard();

  /// View = opened membership of any role (Owner/Editor/Viewer, §2).
  ///
  /// `canView(null)` is false — a profile with no membership row cannot even
  /// read the space (failure matrix: "Non-member reads or writes a space").
  bool canView(SharedMember? member) => member != null;

  /// Edit = money operations (§2): Owner and Editor write shared money rows;
  /// Viewer only reads.
  bool canEdit(SharedMember? member) =>
      member != null && member.role != SharedMemberRole.viewer;

  /// Manage = people + space settings (§2): only the Owner.
  bool canManage(SharedMember? member) =>
      member != null && member.role == SharedMemberRole.owner;

  /// Read refusal — throws instead of returning false so write paths cannot
  /// accidentally ignore a failed check.
  void assertView(SharedMember? member) {
    if (!canView(member)) {
      throw const UnauthorizedSpaceAction(
        'a profile without a membership row cannot access this space',
      );
    }
  }

  /// Edit refusal — every shared money write funnels through here (I1).
  void assertEdit(SharedMember? member) {
    if (!canEdit(member)) {
      throw const UnauthorizedSpaceAction(
        'SharedMember.role does not permit editing money (needs Owner/Editor)',
      );
    }
  }

  /// Manage refusal — space settings, invites, roles, transfer, delete.
  void assertManage(SharedMember? member) {
    if (!canManage(member)) {
      throw const UnauthorizedSpaceAction(
        'SharedMember.role does not permit managing the space (needs Owner)',
      );
    }
  }

  /// Sealed-month refusal (I4, FR-012): a sealed shared month is immutable for
  /// **every** role — the guard refuses even the Owner.
  ///
  /// [sealed] comes from the month-seal table the caller already read inside
  /// its transaction, so the guard itself stays database-free.
  void assertMonthEditable(SharedMember? member, {required bool sealed}) {
    assertEdit(member);
    if (sealed) {
      throw const UnauthorizedSpaceAction(
        'sealed months are frozen for every role; no write may land',
      );
    }
  }

  /// Exactly-one-context invariant (I5, FR-003): a money row must carry exactly
  /// one owner — a personal [profileId] **or** a [sharedSpaceId], never both
  /// and never neither.
  ///
  /// [owner] names the row for the message (e.g. 'MonthlyBudget').
  void assertExactlyOneContext({
    required int? profileId,
    required int? sharedSpaceId,
    String owner = 'money row',
  }) {
    if ((profileId == null) == (sharedSpaceId == null)) {
      throw UnauthorizedSpaceAction(
        '$owner must resolve to exactly one context: got profileId=$profileId, '
        'sharedSpaceId=$sharedSpaceId',
      );
    }
  }
}

/// The app-wide guard instance exposed for repositories and UI (T022).
final spaceRoleGuardProvider = Provider<SpaceAccessGuard>(
  (ref) => const SpaceAccessGuard(),
);
