import 'package:isar/isar.dart';

part 'shared_member.g.dart';

/// A profile's membership in a shared space, with its role (FR-002, FR-005).
///
/// One row per (space, profile) — the unique composite index makes a second
/// membership impossible. Roles gate money and people operations through
/// `SpaceAccessGuard` at the data layer (`contracts/space-roles.md`).
enum SharedMemberRole {
  owner,
  editor,
  viewer,
}

@collection
class SharedMember {
  Id id = Isar.autoIncrement;

  /// Links to `SharedSpace.id`.
  @Index(composite: [CompositeIndex('profileId')], unique: true, replace: true)
  late int sharedSpaceId;

  /// Links to `UserProfile.id`.
  late int profileId;

  @enumerated
  late SharedMemberRole role;

  /// When the profile joined the space (FR-006).
  late DateTime joinedAt;
}
