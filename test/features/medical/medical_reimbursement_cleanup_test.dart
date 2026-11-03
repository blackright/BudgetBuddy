import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/financial_adoption.dart';
import 'package:budget_buddy/core/services/legacy_medical_reimbursement_guard.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/expenses/repositories/reimbursement_repository.dart';
import 'package:budget_buddy/features/medical/repositories/medical_repository.dart';
import '../../support/receipt_financial_harness.dart';

void main() {
  late ReceiptFinancialHarness h;
  late MedicalBill bill;
  late Expense expense;
  setUp(() async {
    h = await ReceiptFinancialHarness.create();
    await h.db.writeTxn(() async {
      expense = h.expense()..type = ExpenseType.medical;
      expense.id = await h.db.expenses.put(expense);
      bill = MedicalBill()
        ..profileId = h.ownerId
        ..yearMonth = '2026-10'
        ..billedAmount = 10000
        ..currency = 'huf'
        ..state = MedicalBillState.paid
        ..linkedExpenseId = expense.id;
      bill.id = await h.db.medicalBills.put(bill);
      await h.db.financialAdoptions.put(FinancialAdoption()
        ..ownerKey = 'personal:${h.ownerId}:2'
        ..profileId = h.ownerId
        ..effectiveYearMonth = '2026-10'
        ..chosenAccountingCurrency = 'huf'
        ..operationIdentity = 'test-review'
        ..inputFingerprint = 'fixture'
        ..legacySourceFingerprint = 'fixture'
        ..reviewedFundingJson = '{}'
        ..actorId = h.ownerId
        ..confirmedAt = DateTime.utc(2026, 10, 28));
    });
  });
  tearDown(() => h.close());
  Reimbursement refund() => Reimbursement(
      profileId: h.ownerId,
      expenseId: expense.id,
      originYearMonth: '2026-11',
      amount: 8000,
      currency: 'huf',
      date: DateTime.utc(2026, 10, 28));

  test('old Medical log and finish cannot credit an adopted personal claim',
      () async {
    final repo = MedicalRepository(h.db);
    final before = await h.db.medicalBills.where().exportJson();
    await expectLater(
        repo.logReimbursement(bill, amount: 8000), throwsStateError);
    await expectLater(
        repo.setBillState(bill, MedicalBillState.finished,
            reimbursedAmount: 8000),
        throwsStateError);
    expect(await h.db.reimbursements.count(), 0);
    expect(await h.db.medicalBills.where().exportJson(), before);
  });
  test('generic reimbursement add and scalar update cannot bypass adoption',
      () async {
    await expectLater(ReimbursementRepository(h.db).addReimbursement(refund()),
        throwsStateError);
    await expectLater(
        MedicalRepository(h.db).updateMedicalBillReimbursement(bill, 8000),
        throwsStateError);
    expect(await h.db.reimbursements.count(), 0);
    expect((await h.db.medicalBills.get(bill.id))!.reimbursedAmount, 0);
  });
  test(
      'old receipt history cannot be edited or deleted through generic controls',
      () async {
    final row = refund();
    await h.db.writeTxn(() async {
      row.id = await h.db.reimbursements.put(row);
    });
    final before = await h.db.reimbursements.where().exportJson();
    await expectLater(
        ReimbursementRepository(h.db)
            .updateReimbursement(refund()..id = row.id),
        throwsStateError);
    await expectLater(ReimbursementRepository(h.db).deleteReimbursement(row.id),
        throwsStateError);
    expect(await h.db.reimbursements.where().exportJson(), before);
  });
  test('a new approval guards an older bill without inventing a migration',
      () async {
    await h.db.writeTxn(() async {
      await h.db.financialAdoptions.clear();
      await h.db.medicalApprovals.put(MedicalApproval()
        ..billGuid = bill.syncGuid
        ..profileId = h.ownerId
        ..yearMonth = '2026-10'
        ..approvedMinor = 8000
        ..currency = 'huf'
        ..decisionDate = DateTime.utc(2026, 10, 22)
        ..recordedAt = DateTime.utc(2026, 10, 28)
        ..actorId = h.ownerId
        ..operationIdentity = 'approval'
        ..inputFingerprint = 'fixture');
    });
    await expectLater(
        MedicalRepository(h.db).logReimbursement(bill, amount: 8000),
        throwsStateError);
    expect(await h.db.reimbursements.count(), 0);
  });
  test('shared scope remains eligible for its existing legacy policy',
      () async {
    final shared = MedicalBill()
      ..sharedSpaceId = 99
      ..profileId = h.ownerId
      ..yearMonth = '2026-10';
    await h.db
        .writeTxn(() => LegacyMedicalReimbursementGuard.forBill(h.db, shared));
    expect(await h.db.reimbursements.count(), 0);
  });
}
