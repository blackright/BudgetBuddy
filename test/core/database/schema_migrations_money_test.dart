import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/medical/repositories/medical_test_harness.dart';

/// Oracle for step 9 (FR-015, FR-021, data-model §6): the phase-1 dry-run report
/// and the guarantee that committed amounts are preserved exactly.
void main() {
  group('buildMoneyMigrationReport (phase 1 dry run)', () {
    test('commits nothing — it is a pure function', () {
      final report = buildMoneyMigrationReport(const []);
      expect(report.entries, isEmpty);
      expect(report.hasLossy, isFalse);
      expect(report.significantMovements, isEmpty);
    });

    test('a whole-cent USD amount converts exactly and is not flagged', () {
      final report = buildMoneyMigrationReport(const [
        LegacyMoneyAmount(
          collection: 'expenses',
          rowId: 1,
          majorUnits: 1234.56,
          minorUnitsPerMajor: 100,
        ),
      ]);

      final entry = report.entries.single;
      expect(entry.minorUnits, 123456);
      expect(entry.afterMajorUnits, 1234.56);
      expect(entry.lossy, isFalse);
      expect(report.hasLossy, isFalse);
    });

    test('HUF (exponent 0) keeps whole forints exactly', () {
      final report = buildMoneyMigrationReport(const [
        LegacyMoneyAmount(
          collection: 'expenses',
          rowId: 7,
          majorUnits: 1500,
          minorUnitsPerMajor: 1,
        ),
      ]);

      expect(report.entries.single.minorUnits, 1500);
      expect(report.entries.single.lossy, isFalse);
    });

    test('a sub-cent remainder is flagged lossy, never silently dropped', () {
      final report = buildMoneyMigrationReport(const [
        LegacyMoneyAmount(
          collection: 'reimbursements',
          rowId: 3,
          majorUnits: 1234.567,
          minorUnitsPerMajor: 100,
        ),
      ]);

      final entry = report.entries.single;
      expect(entry.minorUnits, 123457);
      expect(entry.lossy, isTrue);
      expect(report.lossyEntries, hasLength(1));
    });

    test('a value that rounds away by more than 1% is surfaced for review', () {
      final report = buildMoneyMigrationReport(const [
        LegacyMoneyAmount(
          collection: 'medical_bills',
          rowId: 9,
          majorUnits: 0.004,
          minorUnitsPerMajor: 100,
        ),
      ]);

      final entry = report.entries.single;
      expect(entry.minorUnits, 0);
      expect(entry.movement, greaterThan(0.01));
      expect(report.significantMovements.single.rowId, 9);
    });

    test('rows are reported in input order with their collection and id', () {
      final report = buildMoneyMigrationReport(const [
        LegacyMoneyAmount(
          collection: 'expenses',
          rowId: 1,
          majorUnits: 1,
          minorUnitsPerMajor: 100,
        ),
        LegacyMoneyAmount(
          collection: 'reimbursements',
          rowId: 2,
          majorUnits: 2,
          minorUnitsPerMajor: 100,
        ),
      ]);

      expect(report.entries.map((e) => e.collection),
          ['expenses', 'reimbursements']);
      expect(report.entries.map((e) => e.rowId), [1, 2]);
    });
  });

  group('step 9 commit path', () {
    late MedicalTestHarness harness;

    setUp(() async {
      harness = await MedicalTestHarness.createPreMigration();
      await harness.seedBudget();
    });

    tearDown(() => harness.close());

    test('stamps the schema at the current version exactly once', () async {
      await harness.runMigrations();

      expect(await readSchemaVersion(harness.isar), schemaVersion);
      expect(schemaVersion, greaterThanOrEqualTo(10),
          reason: 'step 10 bumped the schema past the step 9 migration');
      expect(await harness.schemaStamps(), hasLength(1));
    });

    test('amounts written as minor units survive the migration unchanged',
        () async {
      final expense = Expense(
        profileId: harness.profileId,
        yearMonth: '2026-01',
        title: 'HUF lunch',
        amount: 123456,
        currency: 'huf',
        categoryId: Expense.defaultCategoryId,
        date: DateTime(2026, 1, 15),
        budgetId: harness.budgetId,
      );
      final reimbursement = Reimbursement(
        profileId: harness.profileId,
        originYearMonth: '2026-01',
        amount: 26000,
        currency: 'usd',
        date: DateTime(2026, 1, 16),
      );
      final bill = MedicalBill()
        ..profileId = harness.profileId
        ..billedAmount = 9900
        ..currency = 'eur'
        ..serviceDate = DateTime(2026, 1, 20);

      await harness.isar.writeTxn(() async {
        await harness.isar.expenses.put(expense);
        await harness.isar.reimbursements.put(reimbursement);
        await harness.isar.medicalBills.put(bill);
      });

      await harness.runMigrations();

      expect((await harness.isar.expenses.get(expense.id))!.amount, 123456);
      expect(
        (await harness.isar.reimbursements.get(reimbursement.id))!.amount,
        26000,
      );
      expect(
          (await harness.isar.medicalBills.get(bill.id))!.billedAmount, 9900);
    });

    test('is idempotent — a second run neither changes nor re-stamps',
        () async {
      final expense = Expense(
        profileId: harness.profileId,
        yearMonth: '2026-01',
        title: 'CAD coffee',
        amount: 450,
        currency: 'cad',
        categoryId: Expense.defaultCategoryId,
        date: DateTime(2026, 1, 5),
        budgetId: harness.budgetId,
      );
      await harness.isar.writeTxn(() async {
        await harness.isar.expenses.put(expense);
      });

      await harness.runMigrations();
      await harness.runMigrations();

      expect((await harness.isar.expenses.get(expense.id))!.amount, 450);
      expect(await harness.schemaStamps(), hasLength(1));
      expect(await readSchemaVersion(harness.isar), schemaVersion);
    });
  });
}
