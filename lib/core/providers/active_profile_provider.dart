import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../database/isar_helper.dart';
import '../models/user_profile.dart';

final activeProfileProvider = StreamProvider<UserProfile?>((ref) {
  final isar = IsarHelper.instance;
  return isar.userProfiles
      .where()
      .watch(fireImmediately: true)
      .map((profiles) => profiles.isNotEmpty ? profiles.first : null);
});
