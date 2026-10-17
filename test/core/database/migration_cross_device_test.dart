import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/consent_record.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/paired_context.dart';
import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/core/models/pairing_token.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/sync_cursor.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness harness;

  tearDown(() async {
    await harness.close();
  });

  group('migration steps 14/15 - cross-device sync collections (SC-003)', () {
    test('a fresh install lands at v16 with empty sync collections', () async {
      harness = await MedicalTestHarness.create();

      expect(await readSchemaVersion(harness.isar), schemaVersion);
      expect(schemaVersion, 16);
      expect(await harness.schemaStamps(), hasLength(1));

      // The seven new collections exist and start empty.
      expect(await harness.isar.identitys.count(), 0);
      expect(await harness.isar.consentRecords.count(), 0);
      expect(await harness.isar.pairedPeers.count(), 0);
      expect(await harness.isar.pairedContexts.count(), 0);
      expect(await harness.isar.pairingTokens.count(), 0);
      expect(await harness.isar.changeRecords.count(), 0);
      expect(await harness.isar.syncCursors.count(), 0);
    });

    test('an upgrade creates the sync collections and stamps memberships',
        () async {
      harness = await MedicalTestHarness.createPreMigration();

      // Seed a membership the way a pre-sync build wrote it: no version bump and
      // no updatedAt (both columns did not exist yet).
      final space = SharedSpace()
        ..name = 'Home'
        ..currency = PrimaryCurrency.usd
        ..defaultIncome = 0
        ..createdByProfileId = 1
        ..createdAt = DateTime(2026, 1, 1);
      late int spaceId;
      late int memberId;
      await harness.isar.writeTxn(() async {
        spaceId = await harness.isar.sharedSpaces.put(space);
        final member = SharedMember()
          ..sharedSpaceId = spaceId
          ..profileId = 1
          ..role = SharedMemberRole.owner
          ..joinedAt = DateTime(2026, 1, 1);
        memberId = await harness.isar.sharedMembers.put(member);
      });

      await harness.runMigrations();

      expect(await readSchemaVersion(harness.isar), schemaVersion);
      final member = (await harness.isar.sharedMembers.get(memberId))!;
      expect(member.version, 0, reason: 'genesis version');
      expect(member.authorIdentityId, isNull);
      expect(member.signature, isNull);
      expect(member.revokedAt, isNull);
      expect(member.updatedAt, DateTime(2026, 1, 1),
          reason: 'step 15 stamps legacy rows from joinedAt');

      // Step 14 is additive: the collections are new and empty, but usable.
      expect(await harness.isar.identitys.count(), 0);
      expect(await harness.isar.changeRecords.count(), 0);
    });

    test('an upgrade leaves amounts, seals and totals byte-identical',
        () async {
      harness = await MedicalTestHarness.createPreMigration();

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

      final budget = MonthlyBudget()
        ..yearMonth = '2026-01'
        ..baseAvailableAmount = 1234.56
        ..currency = 'usd'
        ..netSalaryOverride = 300000.0
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);
      late int budgetId;
      await harness.isar.writeTxn(() async {
        budgetId = await harness.isar.monthlyBudgets.put(budget);
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
        profileId: 1,
        yearMonth: '2026-01',
        title: 'Legacy expense',
        amount: 12345,
        currency: 'usd',
        categoryId: 'general',
        date: DateTime(2026, 1, 10),
        budgetId: budgetId,
      );
      await harness.isar.writeTxn(() async {
        await harness.isar.medicalBills.put(bill);
        await harness.isar.expenses.put(expense);
      });

      final beforeBudget = (await harness.budgetFor('2026-01'))!;
      final beforeSeal =
          await harness.isar.monthRateSeals.getByYearMonth('2026-01');
      final beforeBill = await harness.isar.medicalBills.get(bill.id);

      await harness.runMigrations();

      final afterBudget = (await harness.budgetFor('2026-01'))!;
      final afterSeal =
          await harness.isar.monthRateSeals.getByYearMonth('2026-01');
      final afterBill = await harness.isar.medicalBills.get(bill.id);

      expect(afterBudget.baseAvailableAmount, beforeBudget.baseAvailableAmount);
      expect(afterBudget.netSalaryOverride, beforeBudget.netSalaryOverride);
      expect(afterBudget.currency, beforeBudget.currency);
      expect(afterSeal!.ratesHuf, beforeSeal!.ratesHuf);
      expect(afterSeal.ratesUsd, beforeSeal.ratesUsd);
      expect(afterBill!.billedAmount, beforeBill!.billedAmount);
      expect(afterBill.reimbursedAmount, beforeBill.reimbursedAmount);
      expect(await readSchemaVersion(harness.isar), schemaVersion);
    });

    test('step 15 is idempotent on re-run', () async {
      harness = await MedicalTestHarness.createPreMigration();

      final space = SharedSpace()
        ..name = 'Home'
        ..currency = PrimaryCurrency.usd
        ..defaultIncome = 0
        ..createdByProfileId = 1
        ..createdAt = DateTime(2026, 1, 1);
      late int memberId;
      await harness.isar.writeTxn(() async {
        final spaceId = await harness.isar.sharedSpaces.put(space);
        final member = SharedMember()
          ..sharedSpaceId = spaceId
          ..profileId = 1
          ..role = SharedMemberRole.owner
          ..joinedAt = DateTime(2026, 1, 1);
        memberId = await harness.isar.sharedMembers.put(member);
      });

      await harness.runMigrations();
      final afterFirst = (await harness.isar.sharedMembers.get(memberId))!;

      await harness.runMigrations();
      final afterSecond = (await harness.isar.sharedMembers.get(memberId))!;

      expect(afterSecond.updatedAt, afterFirst.updatedAt);
      expect(afterSecond.version, afterFirst.version);
      expect(await harness.schemaStamps(), hasLength(1));
      expect(await readSchemaVersion(harness.isar), schemaVersion);
    });
  });
}
