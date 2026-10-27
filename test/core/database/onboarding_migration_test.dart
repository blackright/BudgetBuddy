import 'package:budget_buddy/core/models/lock_setting.dart';
import 'dart:io';

import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/app_settings.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../../features/budget_setup/support/previous_onboarding_settings.dart';
import '../../features/medical/repositories/medical_test_harness.dart';

void main() {
  test(
      'schema-31 native settings reopen preserves values and adds nullable progress',
      () async {
    await Isar.initializeIsarCore(download: false);
    final dir = await Directory.systemTemp.createTemp('onboarding_upgrade_');
    var db = await Isar.open(
        [PreviousOnboardingSettingsSchema, SchemaMigrationStampSchema],
        directory: dir.path, name: 'onboarding-upgrade');
    final now = DateTime.utc(2026, 9, 15);
    await db.writeTxn(
        () => db.previousOnboardingSettings.put(PreviousOnboardingSettings()
          ..id = 1
          ..transferToggle = true
          ..decimalPreferences = '{"eur":2}'
          ..createdAt = now
          ..updatedAt = now));
    await writeSchemaVersion(db, 31);
    await db.close();
    db = await Isar.open([AppSettingsSchema, SchemaMigrationStampSchema],
        directory: dir.path, name: 'onboarding-upgrade');
    try {
      final before = (await db.appSettings.get(1))!;
      expect(before.onboardingStateJson, isNull);
      expect(before.starterCategoryPolicy, isNull);
      await runSchemaMigrations(db);
      await runSchemaMigrations(db);
      await db.close();
      db = await Isar.open([AppSettingsSchema, SchemaMigrationStampSchema],
          directory: dir.path, name: 'onboarding-upgrade');
      final row = (await db.appSettings.get(1))!;
      expect(row.transferToggle, isTrue);
      expect(row.decimalPreferences, '{"eur":2}');
      expect(row.createdAt.toUtc(), now);
      expect(row.updatedAt.toUtc(), now);
      expect(row.onboardingStateJson, isNull);
      expect(row.starterCategoryPolicy, 'preserveExisting');
      expect(await readSchemaVersion(db), 32);
    } finally {
      await db.close(deleteFromDisk: true);
      expect(
          dir.absolute.path.startsWith(
              '${Directory.systemTemp.absolute.path}${Platform.pathSeparator}onboarding_upgrade_'),
          isTrue);
      await dir.delete(recursive: true);
    }
  });

  test('established empty schema-31 installation is not fresh', () async {
    final h = await MedicalTestHarness.create();
    try {
      await writeSchemaVersion(h.isar, 31);
      await runSchemaMigrations(h.isar);
      expect((await h.isar.appSettings.get(1))!.starterCategoryPolicy,
          'preserveExisting');
      expect(await h.isar.categorys.count(), 0);
    } finally {
      await h.close();
    }
  });

  test('truly empty version-zero store is classified before legacy seeds',
      () async {
    final h = await MedicalTestHarness.createPreMigration();
    try {
      await runSchemaMigrations(h.isar);
      await runSchemaMigrations(h.isar);
      expect((await h.isar.appSettings.get(1))!.starterCategoryPolicy,
          'unifiedPending');
      expect(await h.isar.categorys.count(), 0);
    } finally {
      await h.close();
    }
  });

  test(
      'version zero with existing category retains data and established policy',
      () async {
    final h = await MedicalTestHarness.createPreMigration();
    try {
      final row = Category(
          categoryId: 'custom',
          name: 'My custom label',
          emoji: 'x',
          colorValue: 0);
      await h.isar.writeTxn(() => h.isar.categorys.put(row));
      await runSchemaMigrations(h.isar);
      expect((await h.isar.appSettings.get(1))!.starterCategoryPolicy,
          'preserveExisting');
      expect((await h.isar.categorys.get(row.id))!.name, 'My custom label');
    } finally {
      await h.close();
    }
  });

  for (final policy in [
    'preserveExisting',
    'unifiedPending',
    'unifiedSeeded'
  ]) {
    test('upgrade preserves existing valid marker $policy', () async {
      final h = await MedicalTestHarness.create();
      try {
        final now = DateTime.utc(2026);
        await h.isar.writeTxn(() => h.isar.appSettings.put(AppSettings()
          ..id = 1
          ..createdAt = now
          ..updatedAt = now
          ..starterCategoryPolicy = policy));
        await writeSchemaVersion(h.isar, 31);
        await runSchemaMigrations(h.isar);
        expect(
            (await h.isar.appSettings.get(1))!.starterCategoryPolicy, policy);
      } finally {
        await h.close();
      }
    });
  }

  test('version-zero security-only records are not classified as fresh',
      () async {
    final h = await MedicalTestHarness.createPreMigration();
    try {
      final now = DateTime.utc(2026);
      final lock = LockSetting()
        ..subjectKey = 'p7'
        ..subjectLocalId = 7
        ..createdAt = now
        ..updatedAt = now;
      await h.isar.writeTxn(() => h.isar.lockSettings.put(lock));
      await runSchemaMigrations(h.isar);
      expect((await h.isar.appSettings.get(1))!.starterCategoryPolicy,
          'preserveExisting');
      expect((await h.isar.lockSettings.get(lock.id))!.subjectKey, 'p7');
    } finally {
      await h.close();
    }
  });

  test(
      'existing metadata or preferences prevent version-zero fresh eligibility',
      () async {
    for (final metadata in [true, false]) {
      final h = await MedicalTestHarness.createPreMigration();
      try {
        await h.isar.writeTxn(() async {
          if (metadata) {
            await h.isar.schemaMigrationStamps.put(SchemaMigrationStamp()
              ..key = 'theme'
              ..value = 'dark');
          } else {
            final now = DateTime.utc(2026);
            await h.isar.appSettings.put(AppSettings()
              ..id = 1
              ..createdAt = now
              ..updatedAt = now
              ..decimalPreferences = '{"usd":2}');
          }
        });
        await runSchemaMigrations(h.isar);
        expect((await h.isar.appSettings.get(1))!.starterCategoryPolicy,
            'preserveExisting');
      } finally {
        await h.close();
      }
    }
  });

  test('an invalid version stamp is not proof of a fresh installation',
      () async {
    final h = await MedicalTestHarness.createPreMigration();
    try {
      await h.isar.writeTxn(
          () => h.isar.schemaMigrationStamps.put(SchemaMigrationStamp()
            ..key = schemaVersionKey
            ..value = 'invalid-version'));
      await runSchemaMigrations(h.isar);
      expect((await h.isar.appSettings.get(1))!.starterCategoryPolicy,
          'preserveExisting');
    } finally {
      await h.close();
    }
  });

  test('unknown future marker is preserved without granting fresh eligibility',
      () async {
    final h = await MedicalTestHarness.create();
    try {
      final now = DateTime.utc(2026);
      await h.isar.writeTxn(() => h.isar.appSettings.put(AppSettings()
        ..id = 1
        ..createdAt = now
        ..updatedAt = now
        ..starterCategoryPolicy = 'futurePolicy'));
      await writeSchemaVersion(h.isar, 31);
      await runSchemaMigrations(h.isar);
      expect((await h.isar.appSettings.get(1))!.starterCategoryPolicy,
          'futurePolicy');
    } finally {
      await h.close();
    }
  });
}
