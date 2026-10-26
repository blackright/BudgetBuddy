import 'package:isar/isar.dart';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness harness;

  tearDown(() async {
    await harness.close();
  });

  test('step 22 converts the legacy vault total once and stamps its currency',
      () async {
    harness = await MedicalTestHarness.createPreMigration();

    final profile = UserProfile()
      ..id = 1
      ..name = 'Me'
      ..primaryCurrency = PrimaryCurrency.usd
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await harness.isar.writeTxn(() async {
      await harness.isar.userProfiles.put(profile);
    });

    final vault = SavingsVault()
      ..profileId = 1
      ..lastSweepYearMonth = ''
      ..updatedAt = DateTime(2026);
    // ignore: deprecated_member_use_from_same_package
    vault.totalAmount = 1234.56;
    await harness.isar.writeTxn(() async {
      await harness.isar.savingsVaults.put(vault);
    });

    await harness.runMigrations();

    final list = await harness.isar.savingsVaults.where().findAll();
    final migrated = list.single;
    expect(migrated.currency, CurrencyCode.usd.code);
    expect(
      migrated.totalMinor,
      Money.fromMajor(1234.56, CurrencyCode.usd).minorUnits,
    );
    // ignore: deprecated_member_use_from_same_package
    expect(migrated.totalAmount, 0);
    expect(migrated.lastSweepYearMonth, isNotEmpty);
    expect(await readSchemaVersion(harness.isar), schemaVersion);
  });
}
