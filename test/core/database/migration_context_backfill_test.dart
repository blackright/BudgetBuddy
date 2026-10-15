import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
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

  group('migration steps 12/13 backfill context ownership (SC-003)', () {
    test('assigns every existing month to the single personal profile',
        () async {
      final profile = UserProfile()
        ..id = 1
        ..name = 'User'
        ..primaryCurrency = PrimaryCurrency.huf
        ..monthlyAvailableAmount = 250000
        ..createdAt = DateTime(2026, 1, 1)
        ..updatedAt = DateTime(2026, 1, 1);
      await harness.isar.writeTxn(() async {
        await harness.isar.userProfiles.put(profile);
      });

      final january = await _seedBudget(harness, '2026-01', 1200);
      await _seedBudget(harness, '2026-02', 2400);
      final expense = Expense(
        profileId: 0, // pre-context sentinel: the column did not exist yet
        yearMonth: '2026-01',
        title: 'Legacy expense',
        amount: 12345,
        currency: 'usd',
        categoryId: 'general',
        date: DateTime(2026, 1, 10),
        budgetId: january,
      );
      final reimbursement = Reimbursement(
        profileId: 0,
        originYearMonth: '2026-01',
        amount: 5000,
        currency: 'usd',
        date: DateTime(2026, 1, 15),
      );
      final freeBill = MedicalBill()
        ..yearMonth = '2026-01'
        ..billedAmount = 20000
        ..currency = 'usd';
      final linkedBill = MedicalBill()
        ..yearMonth = '2026-01'
        ..billedAmount = 30000
        ..currency = 'usd';

      late int expenseId;
      await harness.isar.writeTxn(() async {
        expenseId = await harness.isar.expenses.put(expense);
        await harness.isar.reimbursements.put(reimbursement);
        await harness.isar.medicalBills.put(freeBill);
        final id = await harness.isar.medicalBills.put(linkedBill);
        linkedBill.id = id;
        linkedBill.linkedExpenseId = expenseId;
        await harness.isar.medicalBills.put(linkedBill);
      });

      // Sanity: the seeded rows really are all-null-context before migrating.
      expect((await harness.budgetFor('2026-01'))!.profileId, isNull);

      await harness.runMigrations();

      for (final month in ['2026-01', '2026-02']) {
        final budget = await harness.budgetFor(month);
        expect(budget!.profileId, 1,
            reason: '$month must own the legacy profile');
        expect(budget.sharedSpaceId, isNull);
      }

      final migratedExpense = await harness.isar.expenses.get(expenseId);
      expect(migratedExpense!.profileId, 1);
      expect(migratedExpense.sharedSpaceId, isNull);

      final migratedReimbursement = (await harness.allReimbursements()).first;
      expect(migratedReimbursement.profileId, 1);
      expect(migratedReimbursement.sharedSpaceId, isNull);

      final free = await harness.isar.medicalBills.get(freeBill.id);
      final linked = await harness.isar.medicalBills.get(linkedBill.id);
      expect(free!.profileId, 1);
      expect(free.sharedSpaceId, isNull);
      expect(linked!.profileId, 1,
          reason: 'follows the linked expense context');
      expect(linked.sharedSpaceId, isNull);

      expect(await readSchemaVersion(harness.isar), schemaVersion);
    });

    test('leaves amounts, seals and totals byte-identical', () async {
      final profile = UserProfile()
        ..id = 1
        ..name = 'User'
        ..primaryCurrency = PrimaryCurrency.huf
        ..monthlyAvailableAmount = 250000
        ..createdAt = DateTime(2026, 1, 1)
        ..updatedAt = DateTime(2026, 1, 1);
      final seeded = await harness.isar.writeTxn(
        () => harness.isar.userProfiles.put(profile),
      );
      expect(seeded, 1);

      final january = await _seedBudget(harness, '2026-01', 1234.56);
      await _seedBudget(harness, '2026-02', 987.65);
      final budget = await harness.budgetFor('2026-01');
      budget!.openingBalanceConfirmed = true;
      budget.currency = 'usd';
      budget.netSalaryOverride = 300000.0;
      await harness.isar.writeTxn(() async {
        await harness.isar.monthlyBudgets.put(budget);
      });

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
      await harness.isar.writeTxn(() async {
        await harness.isar.monthRateSeals.put(seal);
      });

      final bill = MedicalBill()
        ..yearMonth = '2026-01'
        ..billedAmount = 500000
        ..patientSharePercent = 20
        ..state = MedicalBillState.waiting
        ..currency = 'usd';
      final expense = Expense(
        profileId: 0,
        yearMonth: '2026-01',
        title: 'Legacy expense',
        amount: 12345,
        currency: 'usd',
        categoryId: 'general',
        date: DateTime(2026, 1, 10),
        budgetId: january,
      );
      await harness.isar.writeTxn(() async {
        await harness.isar.medicalBills.put(bill);
        await harness.isar.expenses.put(expense);
      });

      final beforeBudgets = await harness.allBudgets();
      final beforeSeal =
          await harness.isar.monthRateSeals.getByYearMonth('2026-01');
      final beforeBill = await harness.isar.medicalBills.get(bill.id);

      await harness.runMigrations();

      final afterBudgets = await harness.allBudgets();
      final afterSeal =
          await harness.isar.monthRateSeals.getByYearMonth('2026-01');
      final afterBill = await harness.isar.medicalBills.get(bill.id);

      expect(afterBudgets, hasLength(beforeBudgets.length));
      for (var i = 0; i < beforeBudgets.length; i++) {
        expect(afterBudgets[i].baseAvailableAmount,
            beforeBudgets[i].baseAvailableAmount);
        // `openingBalanceConfirmed` is deliberately skipped: step 6 turns it
        // on for every legacy month (that is its whole purpose), so the flag
        // is not a stored amount/seal/total and is not byte-identical by design.
        expect(afterBudgets[i].netSalaryOverride,
            beforeBudgets[i].netSalaryOverride);
        expect(afterBudgets[i].currency, beforeBudgets[i].currency,
            reason: 'a deliberate convert-to choice survives');
      }

      expect(afterSeal!.status, beforeSeal!.status);
      expect(afterSeal.ratesUsd, beforeSeal.ratesUsd);
      expect(afterSeal.ratesHuf, beforeSeal.ratesHuf);
      expect(afterSeal.closedAt, beforeSeal.closedAt);

      expect(afterBill!.billedAmount, beforeBill!.billedAmount);
      expect(afterBill.patientSharePercent, beforeBill.patientSharePercent);
      expect(afterBill.state, beforeBill.state);
      expect(afterBill.reimbursedAmount, beforeBill.reimbursedAmount);
    });

    test('step 13 is idempotent on re-run and leaves owned rows untouched',
        () async {
      final profile = UserProfile()
        ..id = 1
        ..name = 'User'
        ..primaryCurrency = PrimaryCurrency.huf
        ..monthlyAvailableAmount = 250000
        ..createdAt = DateTime(2026, 1, 1)
        ..updatedAt = DateTime(2026, 1, 1);
      await harness.isar.writeTxn(() async {
        await harness.isar.userProfiles.put(profile);
      });
      await _seedBudget(harness, '2026-01', 1200);

      // A space-owned month must stay space-owned through the backfill.
      final sharedSpace = await harness.createSpace();
      final shared = MonthlyBudget()
        ..yearMonth = '2026-03'
        ..sharedSpaceId = sharedSpace
        ..baseAvailableAmount = 100
        ..currency = 'usd'
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);
      await harness.isar.writeTxn(() async {
        await harness.isar.monthlyBudgets.put(shared);
      });

      await harness.runMigrations();
      final afterFirst = (await harness.budgetFor('2026-01'))!;

      await harness.runMigrations();
      final afterSecond = (await harness.budgetFor('2026-01'))!;

      expect(afterSecond.profileId, afterFirst.profileId);
      expect(afterSecond.baseAvailableAmount, afterFirst.baseAvailableAmount);
      expect((await harness.budgetFor('2026-03'))!.sharedSpaceId, sharedSpace,
          reason: 'an already-owned row is never re-pointed');
      expect(await harness.schemaStamps(), hasLength(1));
      expect(await readSchemaVersion(harness.isar), schemaVersion);
    });

    test('an empty database fabricates no legacy profile', () async {
      await harness.runMigrations();

      expect(await readSchemaVersion(harness.isar), schemaVersion);
      expect(await harness.isar.userProfiles.count(), 0,
          reason:
              'step 13 must not invent a profile when nothing needs owning');
      expect(await harness.isar.monthlyBudgets.count(), 0);
    });
  });
}

/// Seeds a pre-context month exactly as an older build would have written it:
/// an all-null-context `MonthlyBudget` row.
Future<int> _seedBudget(
  MedicalTestHarness harness,
  String yearMonth,
  double baseAvailable,
) async {
  final budget = MonthlyBudget()
    ..yearMonth = yearMonth
    ..baseAvailableAmount = baseAvailable
    ..currency = 'usd'
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);
  await harness.isar.writeTxn(() async {
    budget.id = await harness.isar.monthlyBudgets.put(budget);
  });
  return budget.id;
}
