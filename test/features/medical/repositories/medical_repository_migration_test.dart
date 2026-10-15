import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/insurance_profile.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_service_type.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/medical/repositories/medical_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'medical_test_harness.dart';

/// T033 (FR-036, FR-037, FR-048, FR-052, FR-055) — the value migrations that
/// turn a database written by an older build into one this build understands.
///
/// The harness presents a pre-migration database by leaving the version stamp
/// absent; fields added since then read back as their declared defaults, which
/// is how Isar hands over a real old database after it reconciles the schema.
void main() {
  late MedicalTestHarness harness;

  setUp(() async {
    harness = await MedicalTestHarness.createPreMigration();
  });

  tearDown(() async {
    await harness.close();
  });

  group('migration steps 0-7 (FR-036)', () {
    test('step 0: every profile is given the default service types', () async {
      await harness.seedBudget();
      await harness.isar.writeTxn(() async {
        await harness.isar.userProfiles.put(
          UserProfile()
            ..name = 'Second'
            ..primaryCurrency = PrimaryCurrency.usd
            ..monthlyAvailableAmount = 1000
            ..createdAt = DateTime(2026)
            ..updatedAt = DateTime(2026),
        );
      });

      await harness.runMigrations();

      final types = await harness.serviceTypes();
      final profileIds = types.map((t) => t.profileId).toSet();
      expect(profileIds, hasLength(2));
      expect(types.length, MedicalServiceTypeDefaults.seedNames.length * 2);
    });

    test('step 0: a profile with a curated list keeps it', () async {
      final context = await harness.seedBudget();
      await harness.repository.saveServiceType(
        profileId: context.profileId,
        name: 'Chiropractic',
      );

      await harness.runMigrations();

      final names = (await harness.serviceTypes())
          .where((t) => t.profileId == context.profileId)
          .map((t) => t.name)
          .toList();
      expect(names, ['Chiropractic']);
    });

    test('steps 1-3: retired insurance concepts leave the declared defaults',
        () async {
      final context = await harness.seedBudget();

      await harness.runMigrations();

      final profile = await harness.repository.getInsuranceProfile(
        context.profileId,
      );
      // FR-048: the inverted share lands on the declared 20% default, which is
      // `100 - 80`, the coverage this app shipped with.
      expect(profile!.defaultPatientPercent, 20.0);
    });

    test('step 4: a reimbursement is credited to its expense month', () async {
      final context = await harness.seedBudget();
      await _seedExpense(harness, context.profileId, yearMonth: '2026-02');
      await _seedReimbursement(
        harness,
        expenseYearMonth: '2026-02',
        date: DateTime(2026, 3, 15),
      );

      await harness.runMigrations();

      final stored = await harness.allReimbursements();
      expect(stored.single.originYearMonth, '2026-02');
    });

    test('step 4: an existing origin month is never overwritten', () async {
      final context = await harness.seedBudget();
      await _seedExpense(harness, context.profileId, yearMonth: '2026-02');
      await _seedReimbursement(
        harness,
        expenseYearMonth: '2026-02',
        date: DateTime(2026, 3, 15),
        originYearMonth: '2026-05',
      );

      await harness.runMigrations();

      expect(
        (await harness.allReimbursements()).single.originYearMonth,
        '2026-05',
      );
    });

    test('step 4: an orphaned reimbursement falls back to its own month',
        () async {
      await harness.seedBudget();
      await _seedReimbursement(
        harness,
        expenseYearMonth: null,
        date: DateTime(2026, 4, 2),
      );

      await harness.runMigrations();

      final stored = await harness.allReimbursements();
      expect(stored.single.originYearMonth, '2026-04');
      // FR-035: an unresolvable target is kept and surfaced, never discarded.
      expect(stored.single.orphaned, isTrue);
    });

    test('step 5: the service month owns the bill (FR-055)', () async {
      final context = await harness.seedBudget();
      await _seedExpense(harness, context.profileId, yearMonth: '2026-03');
      await harness.isar.writeTxn(() async {
        await harness.isar.medicalBills.put(
          MedicalBill()
            ..profileId = context.profileId
            ..serviceDate = DateTime(2026, 1, 31)
            ..billedAmount = 400,
        );
      });

      await harness.runMigrations();

      // A January service paid in March is a January bill.
      expect((await harness.allBills()).single.yearMonth, '2026-01');
    });

    test('step 5: a bill without a service date borrows its expense month',
        () async {
      final context = await harness.seedBudget();
      final expenseId = await _seedExpense(
        harness,
        context.profileId,
        yearMonth: '2026-03',
      );
      await harness.isar.writeTxn(() async {
        await harness.isar.medicalBills.put(
          MedicalBill()
            ..profileId = context.profileId
            ..linkedExpenseId = expenseId
            ..billedAmount = 400,
        );
      });

      await harness.runMigrations();

      expect((await harness.allBills()).single.yearMonth, '2026-03');
    });

    test('step 5: a bill with neither date nor expense stays unowned',
        () async {
      final context = await harness.seedBudget();
      await harness.isar.writeTxn(() async {
        await harness.isar.medicalBills.put(
          MedicalBill()
            ..profileId = context.profileId
            ..billedAmount = 400,
        );
      });

      await harness.runMigrations();

      expect((await harness.allBills()).single.yearMonth, '');
    });

    test('step 6: an existing opening balance counts as confirmed (FR-010)',
        () async {
      await harness.seedLegacyMonth('2026-01', openingBalance: 1200);
      await harness.seedLegacyMonth('2026-02', openingBalance: 900);

      await harness.runMigrations();

      final budgets = await harness.allBudgets();
      expect(budgets, hasLength(2));
      for (final budget in budgets) {
        expect(budget.openingBalanceConfirmed, isTrue);
      }
    });

    test('step 7: setPlanDetails treats blank entries as unset', () async {
      final context = await harness.seedBudget();

      await _updateInsurance(
        harness,
        context.profileId,
        (profile) {
          profile.setPlanDetails(insurerName: 'Aetna', planName: '   ');
        },
      );

      await harness.runMigrations();

      final stored =
          (await harness.repository.getInsuranceProfile(context.profileId))!;
      // The rule has to survive the round trip through Isar, since a whitespace
      // string persisted would render as an empty segment in the summary.
      expect(stored.insurerName, 'Aetna');
      expect(stored.planName, isNull);
      expect(stored.planSummary, 'Aetna');
    });

    test('step 7: a whitespace-only plan name is normalised to unset',
        () async {
      final context = await harness.seedBudget();
      await _updateInsurance(
        harness,
        context.profileId,
        (profile) {
          profile
            ..insurerName = '  Blue Cross  '
            ..planName = '   ';
        },
      );

      await harness.runMigrations();

      final profile = await harness.repository.getInsuranceProfile(
        context.profileId,
      );
      // The surrounding spaces go, and an all-whitespace value becomes null
      // rather than a string that would render as an empty summary segment.
      expect(profile!.insurerName, 'Blue Cross');
      expect(profile.planName, isNull);
      // Both parts set, joined for the summary line.
      expect(profile.planSummary, 'Blue Cross');
    });

    test('planSummary is null when neither part is recorded', () async {
      final context = await harness.seedBudget();
      final profile =
          (await harness.repository.getInsuranceProfile(context.profileId))!;

      // Null, not an empty string: the caller skips the line entirely rather
      // than rendering a blank one.
      expect(profile.planSummary, isNull);
    });

    test('planSummary joins only the part that was recorded', () async {
      final context = await harness.seedBudget();
      final profile = InsuranceProfile()
        ..profileId = context.profileId
        ..planName = 'PPO 500';
      profile.setPlanDetails(planName: 'PPO 500');

      expect(profile.planSummary, 'PPO 500');
      // No leading separator when the insurer is missing.
      expect(profile.planSummary, isNot(contains('·')));
    });

    test('step 7: a real plan name survives untouched', () async {
      final context = await harness.seedBudget();
      await _updateInsurance(
        harness,
        context.profileId,
        (profile) {
          profile
            ..insurerName = 'Aetna'
            ..planName = 'Choice POS II';
        },
      );

      await harness.runMigrations();

      final profile = await harness.repository.getInsuranceProfile(
        context.profileId,
      );
      expect(profile!.insurerName, 'Aetna');
      expect(profile.planName, 'Choice POS II');
    });

    test('step 7: an existing row keeps its patient share', () async {
      final context = await harness.seedBudget();
      await _updateInsurance(
        harness,
        context.profileId,
        (profile) {
          profile
            ..defaultPatientPercent = 35
            ..planName = 'Silver';
        },
      );

      await harness.runMigrations();

      final profile = await harness.repository.getInsuranceProfile(
        context.profileId,
      );
      // The new nullable fields must not disturb the one that already had a
      // value the user chose.
      expect(profile!.defaultPatientPercent, 35.0);
      expect(profile.planName, 'Silver');
    });
  });

  group('idempotence (FR-036)', () {
    test('running the migrations twice changes nothing', () async {
      final context = await harness.seedBudget();
      await _seedExpense(harness, context.profileId, yearMonth: '2026-02');
      await _seedReimbursement(
        harness,
        expenseYearMonth: '2026-02',
        date: DateTime(2026, 3, 15),
      );

      await harness.runMigrations();
      await harness.runMigrations();

      expect(
          await harness.serviceTypes(),
          hasLength(
            MedicalServiceTypeDefaults.seedNames.length,
          ));
      expect((await harness.allReimbursements()).single.originYearMonth,
          '2026-02');
      expect((await harness.schemaStamps()).single.value, '$schemaVersion');
    });

    test('a stamped database skips every step', () async {
      final stamped = await MedicalTestHarness.create();
      await stamped.seedBudget();

      // Already at the current version, so this is the no-op startup path.
      await stamped.runMigrations();

      // Step 0 never fires, so the profile still has no service types.
      expect(await stamped.serviceTypes(), isEmpty);
      expect((await stamped.schemaStamps()).single.value, '$schemaVersion');

      await stamped.close();
    });
  });
}

/// Edits the one insurance row `seedBudget` created.
///
/// Updates that row rather than inserting another: `getInsuranceProfile` resolves
/// a profile to the first matching row, so a second row would shadow the edit and
/// the test would pass or fail for the wrong reason.
Future<void> _updateInsurance(
  MedicalTestHarness harness,
  int profileId,
  void Function(InsuranceProfile profile) change,
) async {
  final existing = await harness.repository.getInsuranceProfile(profileId);
  if (existing == null) {
    throw StateError('seedBudget should have created an insurance row');
  }
  change(existing);
  await harness.repository.saveInsuranceProfile(existing);
}

/// Writes an expense the way an older build would, with no origin-month
/// bookkeeping on any reimbursement pointing at it.
Future<int> _seedExpense(
  MedicalTestHarness harness,
  int profileId, {
  required String yearMonth,
}) async {
  late int id;
  await harness.isar.writeTxn(() async {
    id = await harness.isar.expenses.put(
      Expense(
        profileId: profileId,
        yearMonth: yearMonth,
        title: 'Legacy expense',
        amount: 500,
        currency: 'USD',
        categoryId: MedicalRepository.medicalCategoryId,
        date: DateTime(int.parse(yearMonth.substring(0, 4)),
            int.parse(yearMonth.substring(5, 7)), 10),
        budgetId: harness.budgetId,
      ),
    );
  });
  return id;
}

Future<void> _seedReimbursement(
  MedicalTestHarness harness, {
  required String? expenseYearMonth,
  required DateTime date,
  String originYearMonth = '',
}) async {
  late int expenseId;
  if (expenseYearMonth == null) {
    // Point at an id that does not exist, which is how a dangling reimbursement
    // looks after its expense was deleted.
    expenseId = 999999;
  } else {
    expenseId = await _seedExpense(
      harness,
      0,
      yearMonth: expenseYearMonth,
    );
  }

  await harness.isar.writeTxn(() async {
    await harness.isar.reimbursements.put(
      Reimbursement(
        profileId: 1,
        expenseId: expenseId,
        amount: 200,
        currency: 'USD',
        date: date,
        originYearMonth: originYearMonth,
      ),
    );
  });
}
