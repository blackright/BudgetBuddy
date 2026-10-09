import 'dart:io';

import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/insurance_profile.dart';
import 'package:budget_buddy/core/models/live_rate_set.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_service_type.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/medical/repositories/medical_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

/// Shared Isar harness for the medical tests.
///
/// The engine math that FR-003/004/005 depend on only exists once real rows sit
/// in a real collection, so these tests drive an actual Isar instance rather
/// than stubbing the repository.
class MedicalTestHarness {
  MedicalTestHarness._(this.isar, this.directory)
      : repository = MedicalRepository(isar, rateRegistry: rates);

  /// A registry backed only by the bundled baseline; enough for same-currency
  /// (USD→USD) conversion in these tests, and it keeps the repository's delta
  /// path on the real `toDisplay` code path instead of a raw cast (T-R05).
  static final RateTableRegistry rates = RateTableRegistry();

  static bool _coreReady = false;

  /// Isar 3 keys open instances by name within a process and refuses to open the
  /// same one twice, so every harness gets a distinct name. Without this a test
  /// that opens a second harness alongside the `setUp` one fails to open.
  static int _nextInstance = 0;

  final Isar isar;
  final Directory directory;
  final MedicalRepository repository;

  int profileId = 0;
  int budgetId = 0;
  double baseAvailable = 0;

  /// Opens a harness whose database looks like one written by an older build:
  /// the migration stamp is absent, so [runMigrations] will execute every step.
  ///
  /// Fields added by newer schemas read back as their declared defaults, which
  /// is exactly how a real pre-migration database presents itself after Isar
  /// upgrades the schema.
  static Future<MedicalTestHarness> createPreMigration() =>
      createWithSchemas(writeMigrationStamp: false);

  static Future<MedicalTestHarness> create() =>
      createWithSchemas(writeMigrationStamp: true);

  static Future<MedicalTestHarness> createWithSchemas({
    bool writeMigrationStamp = true,
  }) async {
    if (!_coreReady) {
      await Isar.initializeIsarCore(download: true);
      _coreReady = true;
    }
    final directory =
        Directory.systemTemp.createTempSync('budget_buddy_medical_');
    final isar = await Isar.open(
      [
        UserProfileSchema,
        MonthlyBudgetSchema,
        ExpenseSchema,
        ReimbursementSchema,
        CategorySchema,
        MedicalBillSchema,
        InsuranceProfileSchema,
        FamilyMemberSchema,
        MedicalProviderSchema,
        MedicalServiceTypeSchema,
        SchemaMigrationStampSchema,
        MonthRateSealSchema,
        LiveRateSetSchema,
      ],
      directory: directory.path,
      name: 'medical_${_nextInstance++}',
    );

    if (writeMigrationStamp) {
      await writeSchemaVersion(isar, schemaVersion);
    }

    return MedicalTestHarness._(isar, directory);
  }

  /// Seeds the profile + budget every medical bill needs, and returns the
  /// budget context the repository expects.
  Future<MedicalBillContext> seedBudget({
    double available = 5000,
    double defaultPatientPercent = 20,
    String yearMonth = '2026-01',
    int year = 2026,
  }) async {
    final profile = UserProfile()
      ..name = 'Test'
      ..primaryCurrency = PrimaryCurrency.usd
      ..monthlyAvailableAmount = available
      ..createdAt = DateTime(year)
      ..updatedAt = DateTime(year);

    final budget = MonthlyBudget()
      ..yearMonth = yearMonth
      ..baseAvailableAmount = available
      ..currency = 'usd'
      ..createdAt = DateTime(year)
      ..updatedAt = DateTime(year);

    late int seededProfileId;
    late int seededBudgetId;

    await isar.writeTxn(() async {
      seededProfileId = await isar.userProfiles.put(profile);
      seededBudgetId = await isar.monthlyBudgets.put(budget);
      // Keep the first seeded pair as the harness "primary" profile so tests
      // can add extra profiles without losing their own handles.
      if (profileId == 0) profileId = seededProfileId;
      if (budgetId == 0) budgetId = seededBudgetId;
      if (baseAvailable == 0) baseAvailable = available;
      if (await isar.categorys.count() == 0) {
        await isar.categorys.put(
          Category(
            categoryId: MedicalRepository.medicalCategoryId,
            name: 'Health & Medical',
            emoji: 'H',
            colorValue: 0xFFF44336,
            isDefault: true,
          ),
        );
      }
    });

    await repository.saveInsuranceProfile(
      InsuranceProfile()
        ..profileId = seededProfileId
        ..defaultPatientPercent = defaultPatientPercent,
    );

    return MedicalBillContext(
      profileId: seededProfileId,
      budgetId: seededBudgetId,
      yearMonth: yearMonth,
      primaryCurrency: 'USD',
      rateTable: rates.tableFor(yearMonth),
    );
  }

  /// Mirrors `trueAvailableProvider`:
  /// base - sum(paid expenses) + sum(reimbursements).
  ///
  /// Amounts are stored in minor units, so each is converted to major units in
  /// its own currency before summing (T-R06) instead of casting the minor int.
  Future<double> trueAvailable(
      {required int profileId, required String yearMonth}) async {
    final expenses = await isar.expenses
        .filter()
        .profileIdEqualTo(profileId)
        .yearMonthEqualTo(yearMonth)
        .findAll();
    final byId = {for (final e in expenses) e.id: e};

    var totalPaid = 0.0;
    for (final expense in expenses) {
      if (expense.status == ExpenseStatus.paid) {
        totalPaid +=
            Money(expense.amount, expense.currencyCode ?? CurrencyCode.usd)
                .majorValue;
      }
    }

    var totalReimbursements = 0.0;
    for (final reimbursement in await isar.reimbursements.where().findAll()) {
      final expense = byId[reimbursement.expenseId];
      if (expense != null) {
        totalReimbursements += Money(
          reimbursement.amount,
          reimbursement.currencyCode ?? CurrencyCode.usd,
        ).majorValue;
      }
    }

    return baseAvailable - totalPaid + totalReimbursements;
  }

  Future<Expense?> expenseFor(MedicalBill bill) async {
    final id = bill.linkedExpenseId;
    return id == null ? null : isar.expenses.get(id);
  }

  Future<List<Expense>> allExpenses() => isar.expenses.where().findAll();

  Future<List<Reimbursement>> allReimbursements() =>
      isar.reimbursements.where().findAll();

  Future<List<MedicalBill>> allBills() => isar.medicalBills.where().findAll();

  Future<List<MedicalProvider>> allProviders() =>
      isar.medicalProviders.where().findAll();

  Future<List<MedicalServiceType>> serviceTypes() =>
      isar.medicalServiceTypes.where().findAll();

  Future<List<SchemaMigrationStamp>> schemaStamps() =>
      isar.schemaMigrationStamps.where().findAll();

  Future<MonthlyBudget?> budgetFor(String yearMonth) =>
      isar.monthlyBudgets.filter().yearMonthEqualTo(yearMonth).findFirst();

  Future<int> budgetCount() => isar.monthlyBudgets.count();

  Future<List<MonthlyBudget>> allBudgets() =>
      isar.monthlyBudgets.filter().yearMonthIsNotEmpty().findAll();

  /// Seeds a `MonthlyBudget` the way an older build would have written it: an
  /// opening balance recorded by the user, but no `openingBalanceConfirmed`
  /// flag, because the field did not exist yet.
  Future<MonthlyBudget> seedLegacyMonth(
    String yearMonth, {
    double openingBalance = 1200,
  }) async {
    final budget = MonthlyBudget()
      ..yearMonth = yearMonth
      ..baseAvailableAmount = openingBalance
      ..currency = 'usd'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await isar.writeTxn(() async {
      budget.id = await isar.monthlyBudgets.put(budget);
    });
    return budget;
  }

  /// Applies the pending schema migrations, exactly as app startup does.
  Future<void> runMigrations() => runSchemaMigrations(isar);

  Future<void> close() async {
    await isar.close(deleteFromDisk: true);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  }
}
