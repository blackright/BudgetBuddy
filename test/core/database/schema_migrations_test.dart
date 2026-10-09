import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/live_rate_set.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness harness;

  setUp(() async {
    harness = await MedicalTestHarness.createPreMigration();
  });

  tearDown(() async {
    await harness.close();
  });

  group('runSchemaMigrations', () {
    test('a pre-migration database starts with no version stamp', () async {
      expect(await harness.schemaStamps(), isEmpty);
      expect(await readSchemaVersion(harness.isar), 0);
    });

    test('step 6 confirms a pre-existing opening balance', () async {
      await harness.seedLegacyMonth('2026-01', openingBalance: 1200);

      // An older build wrote the figure but knew nothing about confirmation.
      final before = await harness.budgetFor('2026-01');
      expect(before, isNotNull);
      expect(before!.baseAvailableAmount, 1200);
      expect(before.openingBalanceConfirmed, isFalse);

      await harness.runMigrations();

      final after = await harness.budgetFor('2026-01');
      expect(after!.openingBalanceConfirmed, isTrue);
    });

    test('step 6 preserves the user-entered figure (non-destructive)',
        () async {
      await harness.seedLegacyMonth('2026-01', openingBalance: 1234.56);

      await harness.runMigrations();

      final after = await harness.budgetFor('2026-01');
      expect(after!.baseAvailableAmount, 1234.56);
    });

    test('covers every pre-existing month, not just one', () async {
      await harness.seedLegacyMonth('2026-01', openingBalance: 100);
      await harness.seedLegacyMonth('2026-02', openingBalance: 200);
      await harness.seedLegacyMonth('2025-12', openingBalance: 300);

      await harness.runMigrations();

      for (final month in ['2026-01', '2026-02', '2025-12']) {
        final budget = await harness.budgetFor(month);
        expect(budget!.openingBalanceConfirmed, isTrue, reason: month);
      }
    });

    test('a zero opening balance is confirmed, not treated as unset', () async {
      await harness.seedLegacyMonth('2026-01', openingBalance: 0);

      await harness.runMigrations();

      final after = await harness.budgetFor('2026-01');
      expect(after!.openingBalanceConfirmed, isTrue);
      expect(after.baseAvailableAmount, 0);
    });

    test('writes the version stamp exactly once', () async {
      await harness.seedLegacyMonth('2026-01');

      await harness.runMigrations();

      final stamps = await harness.schemaStamps();
      expect(stamps, hasLength(1));
      expect(stamps.single.key, schemaVersionKey);
      expect(await readSchemaVersion(harness.isar), schemaVersion);
    });

    test('is idempotent when executed twice', () async {
      await harness.seedLegacyMonth('2026-01', openingBalance: 1200);

      await harness.runMigrations();
      final afterFirst = await harness.budgetFor('2026-01');

      await harness.runMigrations();
      final afterSecond = await harness.budgetFor('2026-01');

      expect(afterSecond!.openingBalanceConfirmed, isTrue);
      expect(afterSecond.baseAvailableAmount, afterFirst!.baseAvailableAmount);
      expect(await harness.schemaStamps(), hasLength(1));
    });

    test('is safe on an empty database', () async {
      await harness.runMigrations();

      expect(await readSchemaVersion(harness.isar), schemaVersion);
      expect(await harness.budgetCount(), 0);
    });

    test('step 8 makes the new seal collections usable', () async {
      await harness.runMigrations();

      final seal = MonthRateSeal()
        ..yearMonth = '2026-01'
        ..status = SealStatus.sealed
        ..ratesUsd = 1.0
        ..ratesHuf = 345.0
        ..ratesEur = 0.86
        ..ratesCad = 1.36
        ..asOf = DateTime(2026, 1, 31)
        ..fetchedAt = DateTime(2026, 2, 1)
        ..closedAt = DateTime(2026, 2, 1)
        ..updatedAt = DateTime(2026, 2, 1);
      final live = LiveRateSet()
        ..ratesUsd = 1.0
        ..ratesHuf = 350.0
        ..ratesEur = 0.85
        ..ratesCad = 1.35
        ..fetchedAt = DateTime(2026, 2, 1);

      await harness.isar.writeTxn(() async {
        await harness.isar.monthRateSeals.put(seal);
        await harness.isar.liveRateSets.put(live);
      });

      final readSeal =
          await harness.isar.monthRateSeals.getByYearMonth('2026-01');
      expect(readSeal, isNotNull);
      expect(readSeal!.status, SealStatus.sealed);
      expect(readSeal.toRateTable(), isNotNull);

      // Singleton semantics: a second put overwrites, never appends.
      await harness.isar.writeTxn(() async {
        await harness.isar.liveRateSets
            .put(LiveRateSet()..fetchedAt = DateTime(2026, 3, 1));
      });
      expect(await harness.isar.liveRateSets.count(), 1);
    });

    test(
        'step 8 gives legacy bills the "follow linked expense" currency sentinel',
        () async {
      await harness.runMigrations();

      // A bill written without an explicit currency (the pre-step-8 shape)
      // reads back as the sentinel once the new column exists.
      final bill = MedicalBill()..billedAmount = 100;
      await harness.isar.writeTxn(() async {
        await harness.isar.medicalBills.put(bill);
      });

      final read = await harness.isar.medicalBills.get(bill.id);
      expect(read, isNotNull);
      expect(read!.currency, isEmpty);
    });

    test('step 8 is idempotent and leaves written seals untouched', () async {
      await harness.runMigrations();

      final seal = MonthRateSeal()
        ..yearMonth = '2026-02'
        ..status = SealStatus.provisional
        ..ratesUsd = 1.0
        ..ratesHuf = 400.0
        ..ratesEur = 0.9
        ..ratesCad = 1.4
        ..asOf = DateTime(2026, 2, 28)
        ..fetchedAt = DateTime(2026, 3, 1)
        ..updatedAt = DateTime(2026, 3, 1);
      await harness.isar.writeTxn(() async {
        await harness.isar.monthRateSeals.put(seal);
      });

      await harness.runMigrations();

      final after = await harness.isar.monthRateSeals.getByYearMonth('2026-02');
      expect(after, isNotNull);
      expect(after!.status, SealStatus.provisional);
      expect(after.ratesHuf, 400.0);
      expect(await harness.isar.monthRateSeals.count(), 1);
      expect(await readSchemaVersion(harness.isar), schemaVersion);
    });

    test(
        'step 10 clears unrecognised convert-to values and keeps canonical ones',
        () async {
      final garbage = MonthlyBudget()
        ..yearMonth = '2026-05'
        ..baseAvailableAmount = 0
        ..currency = 'GBP'
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);
      final canonical = MonthlyBudget()
        ..yearMonth = '2026-06'
        ..baseAvailableAmount = 0
        ..currency = 'EUR'
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);
      await harness.isar.writeTxn(() async {
        await harness.isar.monthlyBudgets.put(garbage);
        await harness.isar.monthlyBudgets.put(canonical);
      });

      await harness.runMigrations();

      expect((await harness.budgetFor('2026-05'))!.currency, isNull,
          reason: 'an unsupported code is cleared so the month follows main');
      expect((await harness.budgetFor('2026-06'))!.currency, 'eur',
          reason: 'a supported choice survives, normalised to its code');
    });

    test('step 10 is idempotent', () async {
      final budget = MonthlyBudget()
        ..yearMonth = '2026-07'
        ..baseAvailableAmount = 0
        ..currency = 'USD'
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);
      await harness.isar.writeTxn(() async {
        await harness.isar.monthlyBudgets.put(budget);
      });

      await harness.runMigrations();
      final afterFirst = await harness.budgetFor('2026-07');

      await harness.runMigrations();
      final afterSecond = await harness.budgetFor('2026-07');

      expect(afterFirst!.currency, 'usd');
      expect(afterSecond!.currency, 'usd');
      expect(await harness.schemaStamps(), hasLength(1));
    });
  });
}
