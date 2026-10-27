// ignore_for_file: deprecated_member_use_from_same_package
import 'package:budget_buddy/core/models/app_settings.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/database/money_integrity.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import 'support/legacy_savings_vault.dart';
import 'support/previous_goal_vault.dart';

void main() {
  setUpAll(() => Isar.initializeIsarCore(download: false));
  test(
      'native version-25 goal reopens undated without rewriting money or history',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('budget_buddy_goal_upgrade_');
    Isar? db;
    try {
      db = await Isar.open([
        PreviousGoalVaultSchema,
        VaultEntrySchema,
        SchemaMigrationStampSchema
      ], directory: directory.path, name: 'goal_upgrade');
      await db.writeTxn(() async {
        await db!.previousGoalVaults.put(PreviousGoalVault()
          ..profileId = 1
          ..totalMinor = 50000
          ..goalName = 'Emergency'
          ..goalTargetMinor = 1000000
          ..currency = 'huf'
          ..lastSweepYearMonth = '2026-10'
          ..updatedAt = DateTime(2026, 10));
        await db!.vaultEntrys.put(VaultEntry()
          ..operationKey = 'vault:1:opening'
          ..profileId = 1
          ..kind = 'opening'
          ..amountMinor = 50000
          ..balanceAfterMinor = 50000
          ..currency = 'huf'
          ..createdAt = DateTime(2026, 10)
          ..breakdownJson = '{"preserved":true}');
      });
      await writeSchemaVersion(db, 25);
      await db.close();
      db = await Isar.open([
        AppSettingsSchema,
        SavingsVaultSchema,
        VaultEntrySchema,
        SchemaMigrationStampSchema
      ], directory: directory.path, name: 'goal_upgrade');
      await runSchemaMigrations(db);
      final vault = (await db.savingsVaults.where().findAll()).single;
      expect(vault.goalTargetYearMonth, isNull);
      expect(vault.goalName, 'Emergency');
      expect(vault.goalTargetMinor, 1000000);
      expect(vault.totalMinor, 50000);
      expect(vault.lastSweepYearMonth, '2026-10');
      expect((await db.vaultEntrys.where().findAll()).single.breakdownJson,
          '{"preserved":true}');
      expect(await readSchemaVersion(db), schemaVersion);
    } finally {
      if (db?.isOpen == true) await db!.close(deleteFromDisk: true);
      if (directory.existsSync()) directory.deleteSync(recursive: true);
    }
  });
  for (final primary in PrimaryCurrency.values) {
    test(
        'native old-schema reopen migrates missing ${primary.name} minor total from preserved legacy money',
        () async {
      final directory =
          await Directory.systemTemp.createTemp('budget_buddy_vault_upgrade_');
      const name = 'vault_native_upgrade';
      Isar? db;
      try {
        db = await Isar.open([LegacySavingsVaultSchema, UserProfileSchema],
            directory: directory.path, name: name);
        await db.writeTxn(() async {
          await db!.userProfiles.put(UserProfile()
            ..id = 1
            ..name = 'Me'
            ..primaryCurrency = primary
            ..monthlyAvailableAmount = 0
            ..createdAt = DateTime(2026)
            ..updatedAt = DateTime(2026));
          await db!.legacyVaults.put(LegacySavingsVault()
            ..profileId = 1
            ..totalAmount = 125000
            ..lastSweepYearMonth = '2026-10'
            ..updatedAt = DateTime(2026));
        });
        await db.close();
        db = await Isar.open([
          AppSettingsSchema,
          SavingsVaultSchema,
          VaultEntrySchema,
          UserProfileSchema
        ], directory: directory.path, name: name);
        final before = (await db.savingsVaults.where().findAll()).single;
        expect(before.totalMinor, corruptedMinorSentinel,
            reason:
                'Native absent integer does not use the Dart field initializer.');
        expect(before.totalAmount, 125000);
        await db.writeTxn(() => migrateLegacyVaultToMinorUnits(db!));
        final migrated = (await db.savingsVaults.where().findAll()).single;
        final expectedMinor =
            primary == PrimaryCurrency.huf ? 125000 : 12500000;
        expect(migrated.totalMinor, expectedMinor);
        expect(migrated.currency, primary.name);
        expect(migrated.totalAmount, 0);
        await db.writeTxn(
            () => seedVaultOpeningInTxn(db!, migrated, DateTime(2026)));
        expect((await db.vaultEntrys.where().findAll()).single.amountMinor,
            expectedMinor);
      } finally {
        if (db?.isOpen == true) await db!.close(deleteFromDisk: true);
        if (directory.existsSync()) directory.deleteSync(recursive: true);
      }
    });
  }
}
