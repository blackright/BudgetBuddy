import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_settlement_event.dart';
import 'package:budget_buddy/core/models/medical_withholding_match.dart';
import 'package:budget_buddy/core/models/money_receipt.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import '../../support/receipt_financial_harness.dart';

void main() {
  test('schema35 reopens without inventing approval basis or claim activities',
      () async {
    final fixture = await ReceiptFinancialHarness.create();
    var db = await Isar.open(
        ReceiptFinancialHarness.schemas
            .where((schema) => schema.name != 'MedicalClaimActivity')
            .toList(),
        directory: fixture.directory.path,
        name: 'medical_schema35');
    try {
      await writeSchemaVersion(db, 35);
      await db.writeTxn(() async {
        final expense = fixture.expense()..type = ExpenseType.medical;
        expense.id = await db.expenses.put(expense);
        await db.medicalApprovals.put(MedicalApproval()
          ..billGuid = 'legacy-bill'
          ..profileId = fixture.ownerId
          ..yearMonth = '2026-10'
          ..approvedMinor = 8000
          ..currency = 'huf'
          ..decisionDate = DateTime.utc(2026, 10, 22)
          ..recordedAt = DateTime.utc(2026, 10, 23)
          ..actorId = fixture.ownerId
          ..operationIdentity = 'legacy-approval'
          ..inputFingerprint = 'existing-evidence');
        await db.reimbursements.put(Reimbursement(
            profileId: fixture.ownerId,
            expenseId: expense.id,
            originYearMonth: '2026-10',
            amount: 8000,
            currency: 'huf',
            date: DateTime.utc(2026, 10, 27),
            note: 'Existing return; actual receipt date unknown'));
      });
      final expenses = await db.expenses.where().exportJson();
      final returns = await db.reimbursements.where().exportJson();
      final approvals = await db.medicalApprovals.where().exportJson();
      await db.close();
      db = await Isar.open(ReceiptFinancialHarness.schemas,
          directory: fixture.directory.path, name: 'medical_schema35');
      await runSchemaMigrations(db);
      await runSchemaMigrations(db);
      expect(await readSchemaVersion(db), schemaVersion);
      expect(await db.expenses.where().exportJson(), expenses);
      expect(await db.reimbursements.where().exportJson(), returns);
      expect((await db.reimbursements.where().findFirst())!.medicalReceiptJson,
          isNull);
      expect(await db.medicalApprovals.where().exportJson(), approvals);
      expect(
          (await db.medicalApprovals.where().findFirst())!.basisJson, isNull);
      expect(await db.medicalClaimActivitys.count(), 0);
      expect(await db.medicalClaimClosures.count(), 0);
      expect(await db.moneyReceipts.count(), 0);
      expect(await db.receiptRevisions.count(), 0);
    } finally {
      await db.close(deleteFromDisk: true);
      await fixture.close();
    }
  });

  test('schema40 reopens legacy direct bills without settlement evidence',
      () async {
    final fixture = await ReceiptFinancialHarness.create();
    var db = await Isar.open(
        ReceiptFinancialHarness.schemas
            .where((schema) => schema.name != 'MedicalSettlementEvent')
            .toList(),
        directory: fixture.directory.path,
        name: 'medical_schema40');
    try {
      await writeSchemaVersion(db, 39);
      late MedicalBill bill;
      await db.writeTxn(() async {
        final expense = fixture.expense()
          ..type = ExpenseType.medical
          ..amount = 2000
          ..status = ExpenseStatus.paid;
        expense.id = await db.expenses.put(expense);
        bill = MedicalBill()
          ..profileId = fixture.ownerId
          ..linkedExpenseId = expense.id
          ..yearMonth = '2026-10'
          ..serviceDate = DateTime.utc(2026, 10, 20)
          ..billedAmount = 10000
          ..currency = 'huf'
          ..patientSharePercent = 20
          ..paymentMethod = MedicalPaymentMethod.insurerPaid
          ..state = MedicalBillState.waiting;
        bill.id = await db.medicalBills.put(bill);
      });
      final before = await db.medicalBills.where().exportJson();
      await db.close();
      db = await Isar.open(ReceiptFinancialHarness.schemas,
          directory: fixture.directory.path, name: 'medical_schema40');
      await runSchemaMigrations(db);
      await runSchemaMigrations(db);
      expect(await readSchemaVersion(db), schemaVersion);
      final after = (await db.medicalBills.get(bill.id))!;
      expect(after.billedAmount, 10000);
      expect(after.patientSharePercent, 20);
      expect(after.linkedExpenseId, before.first['linkedExpenseId']);
      expect(after.state, MedicalBillState.waiting);
      expect(after.providerPaymentStatus,
          MedicalProviderPaymentStatus.notRequired);
      expect(after.insuranceRequestStatus,
          MedicalInsuranceRequestStatus.notSubmitted);
      expect(after.overallStatus, MedicalOverallStatus.open);
      expect(await db.medicalSettlements.count(), 0);
      expect(await db.medicalWithholdingMatches.count(), 0);
      expect(await db.expenses.count(), 1);
      expect(await db.reimbursements.count(), 0);
      expect(await db.medicalApprovals.count(), 0);
    } finally {
      await db.close(deleteFromDisk: true);
      await fixture.close();
    }
  });
}
