import 'package:isar/isar.dart';
import '../models/user_profile.dart';
import '../models/shared_space.dart';
import '../models/shared_member.dart';
import '../models/lock_setting.dart';
import '../../features/spaces/domain/shared_member_key.dart';
import '../../features/security/domain/lock_subject.dart';

class ContextDestination {
  const ContextDestination(
      {required this.name, this.spaceId, required this.locked});
  final String name;
  final int? spaceId;
  final bool locked;
}

/// Reads current membership, including identity-backed keys and tombstones.
/// Never switches money ownership by guessing a name or a stale menu row.
class ContextNavigationRepository {
  const ContextNavigationRepository(this.db);
  final Isar db;
  Future<List<ContextDestination>> choices(int actor) => db.txn(() async {
        final profile = await db.userProfiles.get(actor);
        if (profile == null) {
          throw StateError('Your profile is no longer available.');
        }
        final key = await sharedMemberKeyForLocalProfile(db, actor);
        final members = await db.sharedMembers
            .filter()
            .group((q) => q.profileIdEqualTo(actor).or().profileIdEqualTo(key))
            .findAll();
        final locks = await db.lockSettings.where().findAll();
        bool locked(String key) =>
            locks.any((l) => l.subjectKey == key && l.lockEnabled);
        final result = <ContextDestination>[
          ContextDestination(
              name: profile.name, locked: locked(LockSubject.profileKey(actor)))
        ];
        for (final id in members.map((m) => m.sharedSpaceId).toSet()) {
          final rows = members.where((m) => m.sharedSpaceId == id).toList();
          final member =
              rows.where((m) => m.profileId == key).firstOrNull ?? rows.first;
          if (member.revokedAt != null) continue;
          final space = await db.sharedSpaces.get(id);
          if (space == null) continue;
          result.add(ContextDestination(
              name: space.displayName,
              spaceId: id,
              locked: space.requirePin ||
                  locked(LockSubject.spaceKey(space.syncGuid))));
        }
        result.sort((a, b) => a.spaceId == null
            ? -1
            : b.spaceId == null
                ? 1
                : a.name.compareTo(b.name));
        return List.unmodifiable(result);
      });
  Future<ContextDestination> require(int actor, int? spaceId) async {
    final found =
        (await choices(actor)).where((c) => c.spaceId == spaceId).firstOrNull;
    if (found == null) {
      throw StateError('Access to this space is no longer available.');
    }
    return found;
  }
}
