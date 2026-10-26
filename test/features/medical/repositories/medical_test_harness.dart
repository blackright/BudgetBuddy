import 'package:budget_buddy/core/models/merchant.dart';
import 'package:budget_buddy/core/models/expense_evidence_chunk.dart';
import 'package:budget_buddy/core/models/expense_purchase.dart';
import 'package:budget_buddy/core/models/app_settings.dart';
import 'package:budget_buddy/core/models/allocation.dart';
import 'package:budget_buddy/core/models/transfer.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import 'package:budget_buddy/core/models/month_end_run.dart';
import 'dart:io';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/direct_expense_profile.dart';

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
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/consent_record.dart';
import 'package:budget_buddy/core/models/paired_peer.dart';
import 'package:budget_buddy/core/models/paired_context.dart';
import 'package:budget_buddy/core/models/pairing_token.dart';
import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/sync_cursor.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
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

  static List<CollectionSchema> get schemas => [
        AppSettingsSchema,
        MerchantSchema,
        ExpenseEvidenceChunkSchema,
        ExpensePurchaseSchema,
        AllocationSchema,
        TransferSchema,
        AuditEventSchema,
        UserProfileSchema,
        MonthlyBudgetSchema,
        ExpenseSchema,
        BudgetProfileSchema,
        IncomeSourceSchema,
        MonthEndRunSchema,
        DirectExpenseProfileSchema,
        ReimbursementSchema,
        SavingsVaultSchema,
        VaultEntrySchema,
        CategorySchema,
        MedicalBillSchema,
        InsuranceProfileSchema,
        FamilyMemberSchema,
        MedicalProviderSchema,
        MedicalServiceTypeSchema,
        SharedSpaceSchema,
        SharedMemberSchema,
        SchemaMigrationStampSchema,
        MonthRateSealSchema,
        LiveRateSetSchema,
        IdentitySchema,
        ConsentRecordSchema,
        PairedPeerSchema,
        PairedContextSchema,
        PairingTokenSchema,
        ChangeRecordSchema,
        SyncCursorSchema,
      ];

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
      schemas,
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
  ///
  /// Pass a [spaceId] to seed a **shared** month instead of a personal one: the
  /// budget row carries `sharedSpaceId` (exactly-one-context, FR-003) and the
  /// returned context is a shared [MedicalBillContext] with `profileId = 0`,
  /// mirroring `medicalBillContextProvider`'s shared branch. The caller owns
  /// creating the [SharedSpace] row itself (see [createSpace]).
  Future<MedicalBillContext> seedBudget({
    double available = 5000,
    double defaultPatientPercent = 20,
    String yearMonth = '2026-01',
    int year = 2026,
    int? spaceId,
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
      ..sharedSpaceId = spaceId
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
      profileId: spaceId == null ? seededProfileId : 0,
      sharedSpaceId: spaceId,
      budgetId: seededBudgetId,
      yearMonth: yearMonth,
      primaryCurrency: 'USD',
      rateTable: rates.tableFor(yearMonth),
    );
  }

  /// Creates a [SharedSpace] row (no members), returning its id.
  ///
  /// Seed a space budget with `seedBudget(spaceId: id)` afterwards so the
  /// exactly-one-context rows are consistent (T023).
  Future<int> createSpace({int year = 2026, int createdByProfileId = 1}) async {
    final space = SharedSpace()
      ..name = 'Test space'
      ..avatar = '👨‍👩‍👧'
      ..currency = PrimaryCurrency.usd
      ..defaultIncome = 0
      ..createdByProfileId = createdByProfileId
      ..createdAt = DateTime(year);
    await isar.writeTxn(() async {
      space.id = await isar.sharedSpaces.put(space);
    });
    return space.id;
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
      isar.schemaMigrationStamps
          .filter()
          .keyEqualTo(schemaVersionKey)
          .findAll();

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
