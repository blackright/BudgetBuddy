import 'dart:io';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/financial_adoption.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/money_receipt.dart';
import 'package:budget_buddy/core/models/balance_checkpoint.dart';
import 'package:budget_buddy/core/models/period_funding_assignment.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import '../features/medical/repositories/medical_test_harness.dart';
import '../features/medical/management/fixtures.dart' as management_fixtures;

/// Isolated current-schema fixture only. Does not open the app database or run
/// migrations. Reuses the existing schema list, not another generated schema.
class ReceiptFinancialHarness {
  ReceiptFinancialHarness._(
      this.db, this.directory, this.ownerId, this.budgetId);
  final Isar db;
  final Directory directory;
  final int ownerId;
  final int budgetId;
  static int _serial = 0;
  static final schemas = [
    MedicalApprovalSchema,
    MedicalClaimClosureSchema,
    MoneyReceiptSchema,
    ReceiptRevisionSchema,
    ...MedicalTestHarness.schemas.where((schema) => !{
          'MedicalApproval',
          'MedicalClaimClosure',
          'MoneyReceipt',
          'ReceiptRevision',
          'FinancialAdoption',
          'BalanceCheckpoint',
          'MovementInclusion',
          'PeriodFundingAssignment'
        }.contains(schema.name)),
    FinancialAdoptionSchema,
    BalanceCheckpointSchema,
    MovementInclusionSchema,
    PeriodFundingAssignmentSchema
  ];

  static Future<ReceiptFinancialHarness> create() async {
    await Isar.initializeIsarCore(download: false);
    final directory =
        await Directory.systemTemp.createTemp('bb_receipt_fixture_');
    final db = await Isar.open(schemas,
        directory: directory.path, name: 'receipt_${_serial++}');
    final profile = UserProfile()
      ..name = 'Receipt fixture'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime.utc(2026, 10)
      ..updatedAt = DateTime.utc(2026, 10);
    var budgetId = 0;
    await writeSchemaVersion(db, schemaVersion);
    await db.writeTxn(() async {
      profile.id = await db.userProfiles.put(profile);
      budgetId = await db.monthlyBudgets.put(MonthlyBudget()
        ..profileId = profile.id
        ..yearMonth = '2026-10'
        ..baseAvailableAmount = 600000
        ..openingBalanceConfirmed = true
        ..createdAt = DateTime.utc(2026, 10)
        ..updatedAt = DateTime.utc(2026, 10));
    });
    return ReceiptFinancialHarness._(db, directory, profile.id, budgetId);
  }

  ContextRef context([String month = '2026-10']) =>
      ContextRef.personal(profileId: ownerId, yearMonth: month);

  Expense expense({int? owner, String month = '2026-10'}) => Expense(
        budgetId: budgetId,
        profileId: owner ?? ownerId,
        yearMonth: month,
        title: 'Fixture only',
        amount: 10000,
        currency: CurrencyCode.huf.code,
        categoryId: 'food',
        date: DateTime.utc(2026, 10, 28),
      );

  /// Seeds a medical bill and its linked expense through the shared fixture.
  ///
  /// The fixture uses the current schema and the harness budget/profile, so a
  /// test can focus on the behaviour it exercises instead of two-row setup.
  Future<management_fixtures.SeededManagementBill> seedMedicalBill({
    int? profileId,
    int billedAmount = 10000,
    double patientSharePercent = 20,
    MedicalPaymentMethod paymentMethod = MedicalPaymentMethod.selfPaid,
    MedicalBillState state = MedicalBillState.planned,
    String yearMonth = '2026-10',
    DateTime? serviceDate,
    DateTime? paidAt,
    int reimbursedAmount = 0,
  }) {
    return management_fixtures.seedManagementBill(
      db,
      profileId: profileId ?? ownerId,
      budgetId: budgetId,
      billedAmount: billedAmount,
      patientSharePercent: patientSharePercent,
      paymentMethod: paymentMethod,
      state: state,
      currency: CurrencyCode.huf.code,
      yearMonth: yearMonth,
      serviceDate: serviceDate,
      paidAt: paidAt,
      reimbursedAmount: reimbursedAmount,
    );
  }

  Future<void> close() async {
    await db.close(deleteFromDisk: true);
    // Only remove this exact newly created test directory, never an app path.
    if (directory.parent.absolute.path != Directory.systemTemp.absolute.path ||
        !directory.uri.pathSegments
            .where((p) => p.isNotEmpty)
            .last
            .startsWith('bb_receipt_fixture_')) {
      throw StateError('Refusing unexpected fixture cleanup path.');
    }
    await directory.delete(recursive: true);
  }
}
