import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_settlement_event.dart';
import 'package:budget_buddy/core/services/medical_management_service.dart';
import '../../features/medical/repositories/medical_test_harness.dart';

import '../../features/medical/management/fixtures.dart' as fixtures;

void main() {
  Future<
      ({
        MedicalTestHarness harness,
        MedicalManagementService service,
        MedicalBill bill,
      })> setup({int patientShare = 20}) async {
    final harness = await MedicalTestHarness.create();
    final context = await harness.seedBudget(yearMonth: '2026-03');
    final seeded = await fixtures.seedManagementBill(
      harness.isar,
      profileId: context.profileId,
      budgetId: context.budgetId,
      currency: 'usd',
      yearMonth: '2026-03',
      paymentMethod: MedicalPaymentMethod.insurerPaid,
      patientSharePercent: patientShare.toDouble(),
      providerPaymentStatus: MedicalProviderPaymentStatus.notRequired,
      salarySettlementType: MedicalSalarySettlementType.userShareDeduction,
    );
    return (
      harness: harness,
      service: MedicalManagementService(
        db: harness.isar,
        actingProfileId: context.profileId,
      ),
      bill: seeded.bill,
    );
  }

  test('insurance-paid share is deducted only on payslip confirmation',
      () async {
    final f = await setup();
    addTearDown(f.harness.close);

    final submitted = await f.service.submitInsuranceRequest(
      billId: f.bill.id,
      submissionDate: DateTime.utc(2026, 4, 1),
      reference: 'REF-9',
      operationKey: 'isubmit',
      isAccessCurrent: () => true,
    );
    expect(submitted.providerPaymentStatus,
        MedicalProviderPaymentStatus.notRequired);
    expect(submitted.insuranceRequestStatus,
        MedicalInsuranceRequestStatus.receiptPending);
    final before =
        (await f.harness.isar.expenses.get(f.bill.linkedExpenseId!))!;
    expect(before.status, ExpenseStatus.planned);
    expect(before.amount, 0);

    await f.service.confirmReceipt(
      billId: f.bill.id,
      receiptDate: DateTime.utc(2026, 4, 2),
      operationKey: 'ir',
      isAccessCurrent: () => true,
    );
    await f.service.recordDecision(
      billId: f.bill.id,
      decision: MedicalDecision.approved,
      decisionDate: DateTime.utc(2026, 4, 3),
      operationKey: 'id',
      isAccessCurrent: () => true,
    );
    final approved = await f.service.reviewApprovedAmounts(
      billId: f.bill.id,
      approvedBillMinor: 10000,
      approvedShareMinor: 2000,
      approvedInsuranceMinor: 8000,
      expectedSalaryMonth: '2026-05',
      operationKey: 'ia',
      isAccessCurrent: () => true,
    );
    expect(approved.salarySettlementType,
        MedicalSalarySettlementType.userShareDeduction);
    expect(approved.salarySettlementStatus,
        MedicalSalarySettlementStatus.waitingForPayslip);
    expect(approved.settlementAmountMinor, 2000);

    final afterApproval =
        (await f.harness.isar.expenses.get(f.bill.linkedExpenseId!))!;
    expect(afterApproval.status, ExpenseStatus.planned);
    expect(afterApproval.amount, 0);

    final deducted = await f.service.recordDeductionConfirmed(
      billId: f.bill.id,
      amountMinor: 2000,
      actualSalaryMonth: '2026-05',
      deductionDate: DateTime.utc(2026, 5, 10),
      operationKey: 'ded',
      isAccessCurrent: () => true,
    );
    expect(deducted.salarySettlementStatus,
        MedicalSalarySettlementStatus.deducted);
    expect(deducted.insuranceRequestStatus,
        MedicalInsuranceRequestStatus.completed);
    final expense =
        (await f.harness.isar.expenses.get(f.bill.linkedExpenseId!))!;
    expect(expense.status, ExpenseStatus.paid);
    expect(expense.amount, 2000);
    expect(expense.yearMonth, '2026-03');
    expect(expense.cashYearMonth, '2026-05');
    final settlement = (await f.harness.isar.medicalSettlements
            .filter()
            .billGuidEqualTo(f.bill.syncGuid)
            .findAll())
        .single;
    expect(settlement.kind, MedicalSettlementKind.shareSettlement);
    expect(settlement.transactionMonth, '2026-05');

    final closed = await f.service.closeBill(
      billId: f.bill.id,
      operationKey: 'iclose',
      isAccessCurrent: () => true,
    );
    expect(closed.overallStatus, MedicalOverallStatus.closed);
  });

  test('different deduction amount revises the share, not the insurer payment',
      () async {
    final f = await setup();
    addTearDown(f.harness.close);
    await f.service.submitInsuranceRequest(
      billId: f.bill.id,
      submissionDate: DateTime.utc(2026, 4, 1),
      operationKey: 'msub',
      isAccessCurrent: () => true,
    );
    await f.service.confirmReceipt(
      billId: f.bill.id,
      receiptDate: DateTime.utc(2026, 4, 2),
      operationKey: 'mrec',
      isAccessCurrent: () => true,
    );
    await f.service.recordDecision(
      billId: f.bill.id,
      decision: MedicalDecision.approved,
      decisionDate: DateTime.utc(2026, 4, 3),
      operationKey: 'mdec',
      isAccessCurrent: () => true,
    );
    await f.service.reviewApprovedAmounts(
      billId: f.bill.id,
      approvedBillMinor: 10000,
      approvedShareMinor: 2000,
      approvedInsuranceMinor: 8000,
      expectedSalaryMonth: '2026-05',
      operationKey: 'mapp',
      isAccessCurrent: () => true,
    );

    final corrected = await f.service.resolveMismatch(
      billId: f.bill.id,
      confirmedAmountMinor: 1500,
      reason: 'Payslip showed a different deduction',
      expectedSalaryMonth: '2026-05',
      operationKey: 'mmis',
      isAccessCurrent: () => true,
    );

    expect(corrected.settlementAmountMinor, 1500);
    expect(corrected.salarySettlementType,
        MedicalSalarySettlementType.userShareDeduction);
    final approvals = await f.harness.isar.medicalApprovals
        .filter()
        .billGuidEqualTo(f.bill.syncGuid)
        .findAll();
    approvals.sort((a, b) => a.revision.compareTo(b.revision));
    expect(approvals.last.approvedShareMinor, 1500);
    expect(approvals.last.approvedInsuranceMinor, 8500);
  });

  test('100% coverage completes and closes without a deduction', () async {
    final f = await setup(patientShare: 0);
    addTearDown(f.harness.close);

    await f.service.submitInsuranceRequest(
      billId: f.bill.id,
      submissionDate: DateTime.utc(2026, 4, 1),
      operationKey: 'isubmit0',
      isAccessCurrent: () => true,
    );
    await f.service.confirmReceipt(
      billId: f.bill.id,
      receiptDate: DateTime.utc(2026, 4, 2),
      operationKey: 'ir0',
      isAccessCurrent: () => true,
    );
    await f.service.recordDecision(
      billId: f.bill.id,
      decision: MedicalDecision.approved,
      decisionDate: DateTime.utc(2026, 4, 3),
      operationKey: 'id0',
      isAccessCurrent: () => true,
    );
    final approved = await f.service.reviewApprovedAmounts(
      billId: f.bill.id,
      approvedBillMinor: 10000,
      approvedShareMinor: 0,
      approvedInsuranceMinor: 10000,
      expectedSalaryMonth: null,
      operationKey: 'ia0',
      isAccessCurrent: () => true,
    );
    expect(approved.salarySettlementStatus,
        MedicalSalarySettlementStatus.notRequired);
    expect(approved.settlementAmountMinor, 0);

    final completed = await f.service.completeAt100Percent(
      billId: f.bill.id,
      operationKey: 'complete0',
      isAccessCurrent: () => true,
    );
    expect(completed.insuranceRequestStatus,
        MedicalInsuranceRequestStatus.completed);

    final expense =
        (await f.harness.isar.expenses.get(f.bill.linkedExpenseId!))!;
    expect(expense.status, ExpenseStatus.planned);
    expect(expense.amount, 0);
    expect(await f.harness.isar.medicalSettlements.count(), 0);

    final closed = await f.service.closeBill(
      billId: f.bill.id,
      operationKey: 'iclose0',
      isAccessCurrent: () => true,
    );
    expect(closed.overallStatus, MedicalOverallStatus.closed);
    expect(await f.harness.isar.medicalClaimClosures.count(), 1);
  });
}
