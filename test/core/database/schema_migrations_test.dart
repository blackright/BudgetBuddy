import 'package:budget_buddy/core/database/schema_migrations.dart';
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
  });
}
