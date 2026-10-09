import 'package:budget_buddy/core/database/money_integrity.dart';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/medical/repositories/medical_test_harness.dart';

/// Guard for T-R11: a pre-`int` database reinterpreted by the step-9 money type
/// cut must be detected and reset, never rendered or computed with.
void main() {
  group('isCorruptedMoney', () {
    test('accepts plausible minor-unit amounts', () {
      expect(isCorruptedMoney(0), isFalse);
      expect(isCorruptedMoney(1999), isFalse);
      expect(isCorruptedMoney(1000000000000), isFalse);
    });

    test('rejects the int64 extremes a type change produces', () {
      expect(isCorruptedMoney(corruptedMinorSentinel), isTrue);
      expect(isCorruptedMoney(9223372036854775807), isTrue);
    });
  });

  group('findCorruptedMoney', () {
    late MedicalTestHarness harness;

    setUp(() async {
      harness = await MedicalTestHarness.create();
      await harness.seedBudget();
    });

    tearDown(() => harness.close());

    test('a clean database reports nothing', () async {
      expect(await findCorruptedMoney(harness.isar), isEmpty);
    });

    test('flags a reinterpreted expense amount', () async {
      await harness.isar.writeTxn(() async {
        await harness.isar.expenses.put(Expense(
          profileId: harness.profileId,
          yearMonth: '2026-01',
          title: 'Corrupted',
          amount: corruptedMinorSentinel,
          currency: 'huf',
          categoryId: Expense.defaultCategoryId,
          date: DateTime(2026, 1, 15),
          budgetId: harness.budgetId,
        ));
      });

      final issues = await findCorruptedMoney(harness.isar);

      expect(issues, hasLength(1));
      expect(issues.single.collection, 'expenses');
      expect(issues.single.field, 'amount');
      expect(issues.single.value, corruptedMinorSentinel);
    });

    test('flags both corrupted fields on one medical bill', () async {
      await harness.isar.writeTxn(() async {
        await harness.isar.medicalBills.put(
          MedicalBill()
            ..profileId = harness.profileId
            ..billedAmount = corruptedMinorSentinel
            ..reimbursedAmount = 9223372036854775807,
        );
      });

      final fields =
          (await findCorruptedMoney(harness.isar)).map((i) => i.field).toSet();
      expect(fields, {'billedAmount', 'reimbursedAmount'});
    });
  });

  group('resetLocalDatabase', () {
    late MedicalTestHarness harness;

    setUp(() async {
      harness = await MedicalTestHarness.create();
      await harness.seedBudget();
    });

    tearDown(() => harness.close());

    test('clears every collection and re-stamps the schema', () async {
      await harness.isar.writeTxn(() async {
        await harness.isar.expenses.put(Expense(
          profileId: harness.profileId,
          yearMonth: '2026-01',
          title: 'Corrupt',
          amount: corruptedMinorSentinel,
          currency: 'usd',
          categoryId: Expense.defaultCategoryId,
          date: DateTime(2026, 1, 15),
          budgetId: harness.budgetId,
        ));
      });
      expect(await harness.isar.expenses.count(), 1);

      await resetLocalDatabase(harness.isar);

      expect(await harness.isar.expenses.count(), 0);
      expect(await harness.isar.userProfiles.count(), 0);
      expect(await harness.isar.monthlyBudgets.count(), 0);
      expect(await findCorruptedMoney(harness.isar), isEmpty);
      expect(await readSchemaVersion(harness.isar), schemaVersion);
    });
  });
}
