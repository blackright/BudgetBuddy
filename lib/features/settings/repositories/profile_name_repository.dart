import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/profile_name.dart';

final profileNameRepositoryProvider =
    Provider((ref) => ProfileNameRepository(IsarHelper.instance));

/// A rename updates metadata only; IDs, identity keys and history stay intact.
class ProfileNameRepository {
  const ProfileNameRepository(this.db);
  final Isar db;
  Future<void> rename(int profileId, String name,
      {void Function()? assertCanRename}) async {
    final validated = checkedProfileName(name);
    await db.writeTxn(() async {
      assertCanRename?.call();
      final profile = await db.userProfiles.get(profileId);
      assertCanRename?.call();
      if (profile == null) {
        throw StateError('This profile is no longer available.');
      }
      profile.name = validated;
      profile.updatedAt = DateTime.now();
      await db.userProfiles.put(profile);
    });
  }
}
