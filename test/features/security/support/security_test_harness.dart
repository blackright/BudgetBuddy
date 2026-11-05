import 'dart:io';

import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/domain/away_time.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/repositories/lock_setting_janitor.dart';
import 'package:budget_buddy/features/security/repositories/lock_setting_repository.dart';
import 'package:isar/isar.dart';

/// Shared Isar harness for the security tests (016).
///
/// Opens a **real** Isar in a temp directory with every collection the app
/// declares, including the new `LockSetting`, so the schema, the transaction
/// bounds and the FR-034 cascade are all exercised for real rather than against
/// a mock that could not disagree with them.
///
/// [createPreMigration] deliberately skips the version stamp, so
/// [runSchemaMigrations] runs every numbered step — that is how the migration
/// test sees the 18-to-19 upgrade the app performs on a user's phone.
class SecurityTestHarness {
  SecurityTestHarness._(this.isar, this.directory);

  static bool _coreReady = false;

  /// Isar 3 keys open instances by name within a process and refuses to open the
  /// same one twice, so every harness gets a distinct name.
  static int _nextInstance = 0;

  final Isar isar;
  final Directory directory;

  LockSettingRepository get settings => LockSettingRepository(isar);

  /// A janitor pointed at this database, with [store] standing in for the
  /// keystore so a cascade test can see the verifier and lockout records erased.
  LockSettingJanitor janitor(SecretStore store) =>
      LockSettingJanitor(settings, secretStore: store);

  /// Opens a database that looks like one written by an older build: no version
  /// stamp, so every migration step runs.
  static Future<SecurityTestHarness> createPreMigration() =>
      create(writeMigrationStamp: false);

  static Future<SecurityTestHarness> create({
    bool writeMigrationStamp = true,
  }) async {
    if (!_coreReady) {
      await Isar.initializeIsarCore(download: true);
      _coreReady = true;
    }
    final directory = Directory.systemTemp.createTempSync('budget_buddy_sec_');
    final isar = await Isar.open(
      IsarHelper.schemas,
      directory: directory.path,
      name: 'security_${_nextInstance++}',
    );

    if (writeMigrationStamp) {
      await writeSchemaVersion(isar, schemaVersion);
    }

    return SecurityTestHarness._(isar, directory);
  }

  Future<void> dispose() async {
    await isar.close(deleteFromDisk: true);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  }

  /// Seeds a profile with a budget row, so the migration test has real money
  /// rows to prove survive.
  Future<UserProfile> seedProfile({
    String name = 'Test',
    double available = 5000,
  }) async {
    final profile = UserProfile()
      ..name = name
      ..primaryCurrency = PrimaryCurrency.usd
      ..monthlyAvailableAmount = available
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    final budget = MonthlyBudget()
      ..yearMonth = '2026-01'
      ..baseAvailableAmount = available
      ..currency = 'usd'
      ..profileId = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);

    await isar.writeTxn(() async {
      profile.id = await isar.userProfiles.put(profile);
      budget.profileId = profile.id;
      budget.id = await isar.monthlyBudgets.put(budget);
    });
    return profile;
  }

  /// Inserts a space with [syncGuid] and an Owner membership for [ownerId].
  Future<SharedSpace> createSpace({
    required String syncGuid,
    required int ownerId,
    String name = 'Our space',
  }) async {
    final space = SharedSpace()
      ..syncGuid = syncGuid
      ..name = name
      ..avatar = '🏠'
      ..currency = PrimaryCurrency.usd
      ..defaultIncome = 0
      ..createdByProfileId = ownerId
      ..createdAt = DateTime(2026);
    await isar.writeTxn(() async {
      space.id = await isar.sharedSpaces.put(space);
      await isar.sharedMembers
          .put(_member(space.id, ownerId, SharedMemberRole.owner));
    });
    return space;
  }

  /// Adds a second membership, so a non-Owner can leave a space the Owner keeps.
  Future<void> addEditor(int spaceId, int profileId) => isar.writeTxn(
        () => isar.sharedMembers
            .put(_member(spaceId, profileId, SharedMemberRole.editor)),
      );

  SharedMember _member(int spaceId, int profileId, SharedMemberRole role) =>
      SharedMember()
        ..sharedSpaceId = spaceId
        ..profileId = profileId
        ..role = role
        ..joinedAt = DateTime(2026);

  /// Writes a configured setting for [subject].
  Future<LockSetting> enableLock(
    LockSubject subject, {
    bool biometrics = false,
    AwayTime awayTime = AwayTime.twoMinutes,
  }) async {
    final row = LockSetting.forSubject(subject)
      ..lockEnabled = true
      ..biometricsEnabled = biometrics
      ..awayTime = awayTime;
    await settings.upsert(row);
    return row;
  }
}
