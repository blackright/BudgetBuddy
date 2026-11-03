import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/features/spaces/domain/shared_member_key.dart';
import 'package:budget_buddy/core/services/context_navigation.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import '../medical/repositories/medical_test_harness.dart';

void main() {
  late Isar db;
  late Directory dir;
  int serial = 0;
  setUp(() async {
    await Isar.initializeIsarCore(download: false);
    dir = await Directory.systemTemp.createTemp('phase14_');
    db = await Isar.open(MedicalTestHarness.schemas,
        directory: dir.path, name: 'p14_${serial++}');
    IsarHelper.instance = db;
  });
  tearDown(() async {
    await db.close(deleteFromDisk: true);
    await dir.delete(recursive: true);
  });
  UserProfile profile(String name) => UserProfile()
    ..name = name
    ..primaryCurrency = PrimaryCurrency.huf
    ..monthlyAvailableAmount = 100
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);
  test(
      'identity-keyed removal cannot fall back to a stale active legacy membership',
      () async {
    await db.writeTxn(() async {
      await db.userProfiles.put(profile('Jason')..id = 1);
      await db.identitys.put(Identity()
        ..localProfileId = 1
        ..username = 'Jason sharing'
        ..fingerprint = 'key-123'
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026));
      await db.sharedSpaces.put(SharedSpace()
        ..id = 7
        ..name = 'Family'
        ..currency = PrimaryCurrency.huf
        ..createdByProfileId = 1
        ..createdAt = DateTime(2026));
      for (final id in [1, sharedMemberKey('key-123')]) {
        await db.sharedMembers.put(SharedMember()
          ..profileId = id
          ..sharedSpaceId = 7
          ..role = SharedMemberRole.viewer
          ..joinedAt = DateTime(2026)
          ..revokedAt = (id == 1 ? null : DateTime(2026)));
      }
    });
    expect(
        (await ContextNavigationRepository(db).choices(1))
            .map((c) => c.spaceId),
        [null]);
  });
  test(
      'chooser exposes permitted contexts, lock metadata and rejects revoked selection',
      () async {
    await db.writeTxn(() async {
      await db.userProfiles.put(profile('Jason')..id = 1);
      await db.userProfiles.put(profile('Other')..id = 2);
      for (final id in [3, 4, 5]) {
        await db.sharedSpaces.put(SharedSpace()
          ..id = id
          ..name = 'Space $id'
          ..currency = PrimaryCurrency.huf
          ..createdByProfileId = 1
          ..createdAt = DateTime(2026)
          ..requirePin = (id == 3));
      }
      await db.sharedMembers.put(SharedMember()
        ..profileId = 1
        ..sharedSpaceId = 3
        ..role = SharedMemberRole.viewer
        ..joinedAt = DateTime(2026));
      await db.sharedMembers.put(SharedMember()
        ..profileId = 1
        ..sharedSpaceId = 4
        ..role = SharedMemberRole.owner
        ..joinedAt = DateTime(2026)
        ..revokedAt = DateTime(2026));
      await db.sharedMembers.put(SharedMember()
        ..profileId = 2
        ..sharedSpaceId = 5
        ..role = SharedMemberRole.owner
        ..joinedAt = DateTime(2026));
      await db.lockSettings.put(
          LockSetting.forSubject(LockSubject.profile(id: 1, name: 'Jason'))
            ..lockEnabled = true);
    });
    final repo = ContextNavigationRepository(db),
        choices = await ContextNavigationRepository(db).choices(1);
    expect(choices.map((c) => c.spaceId), [null, 3]);
    expect(choices.every((c) => c.locked), isTrue);
    await db.writeTxn(() async {
      final member = (await db.sharedMembers
          .filter()
          .sharedSpaceIdEqualTo(3)
          .findFirst())!
        ..revokedAt = DateTime(2026);
      await db.sharedMembers.put(member);
    });
    await expectLater(repo.require(1, 3), throwsStateError);
  });
}
