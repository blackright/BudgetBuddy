import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/services/medical_management_service.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import '../../features/medical/repositories/medical_test_harness.dart';

import '../../features/medical/management/fixtures.dart' as fixtures;

void main() {
  Future<
      ({
        MedicalTestHarness harness,
        MedicalManagementService service,
        MedicalBill bill,
      })> setup({bool access = true}) async {
    final harness = await MedicalTestHarness.create();
    final context = await harness.seedBudget(yearMonth: '2026-03');
    final seeded = await fixtures.seedManagementBill(
      harness.isar,
      profileId: context.profileId,
      budgetId: context.budgetId,
      currency: 'usd',
      yearMonth: '2026-03',
      serviceDate: DateTime.utc(2026, 3, 15),
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

  test('user-paid flow moves money only on confirmation and actual months',
      () async {
    final f = await setup();
    addTearDown(f.harness.close);
    final expenseBefore =
        (await f.harness.isar.expenses.get(f.bill.linkedExpenseId!))!;
    expect(expenseBefore.status, ExpenseStatus.planned);
    expect(expenseBefore.amount, 0);

    final submitted = await f.service.submitRequest(
      billId: f.bill.id,
      providerAmountMinor: 10000,
      paymentDate: DateTime.utc(2026, 4, 2),
      paymentMonth: '2026-04',
      submissionDate: DateTime.utc(2026, 4, 3),
      reference: 'REF-1',
      operationKey: 'submit-1',
      isAccessCurrent: () => true,
    );
    final expense =
        (await f.harness.isar.expenses.get(submitted.linkedExpenseId!))!;
    expect(expense.status, ExpenseStatus.paid);
    expect(expense.amount, 10000);
    expect(expense.yearMonth, '2026-03');
    expect(expense.cashYearMonth, '2026-04');
    expect(submitted.providerPaymentStatus, MedicalProviderPaymentStatus.paid);
    expect(submitted.insuranceRequestStatus,
        MedicalInsuranceRequestStatus.receiptPending);
    expect(submitted.submissionDate, DateTime.utc(2026, 4, 3));

    final receipt = await f.service.confirmReceipt(
      billId: f.bill.id,
      receiptDate: DateTime.utc(2026, 4, 4),
      operationKey: 'receipt-1',
      isAccessCurrent: () => true,
    );
    expect(receipt.insuranceRequestStatus,
        MedicalInsuranceRequestStatus.inProgress);

    final decided = await f.service.recordDecision(
      billId: f.bill.id,
      decision: MedicalDecision.approved,
      decisionDate: DateTime.utc(2026, 4, 5),
      operationKey: 'decision-1',
      isAccessCurrent: () => true,
    );
    expect(
        decided.insuranceRequestStatus, MedicalInsuranceRequestStatus.approved);

    final approved = await f.service.reviewApprovedAmounts(
      billId: f.bill.id,
      approvedBillMinor: 10000,
      approvedShareMinor: 2000,
      approvedInsuranceMinor: 8000,
      expectedSalaryMonth: '2026-05',
      operationKey: 'approval-1',
      isAccessCurrent: () => true,
    );
    expect(approved.salarySettlementStatus,
        MedicalSalarySettlementStatus.waitingForPayslip);
    expect(approved.settlementAmountMinor, 8000);
    final approval = await f.harness.isar.medicalApprovals
        .filter()
        .billGuidEqualTo(f.bill.syncGuid)
        .findFirst();
    expect(approval?.approvedBillMinor, 10000);
    expect(approval?.expectedInsuranceMinor, 8000);

    final refunded = await f.service.recordRefundReceived(
      billId: f.bill.id,
      amountMinor: 8000,
      actualSalaryMonth: '2026-05',
      receivedDate: DateTime.utc(2026, 5, 10),
      operationKey: 'refund-1',
      isAccessCurrent: () => true,
    );
    expect(refunded.salarySettlementStatus,
        MedicalSalarySettlementStatus.received);
    expect(refunded.insuranceRequestStatus,
        MedicalInsuranceRequestStatus.completed);
    expect(refunded.reimbursedAmount, 8000);
    final reimbursement =
        (await f.harness.isar.reimbursements.where().findAll()).single;
    expect(reimbursement.originYearMonth, '2026-03');
    expect(reimbursement.creditYearMonth, '2026-05');
    expect(reimbursement.source, ReimbursementSource.medicalInsurance);

    final closed = await f.service.closeBill(
      billId: f.bill.id,
      operationKey: 'close-1',
      isAccessCurrent: () => true,
      reason: 'settled',
    );
    expect(closed.overallStatus, MedicalOverallStatus.closed);
    expect(closed.state, MedicalBillState.finished);
    expect(await f.harness.isar.medicalClaimClosures.count(), 1);
  });

  test('submit rejects revoked access and duplicate operation', () async {
    final f = await setup();
    addTearDown(f.harness.close);
    await f.service.submitRequest(
      billId: f.bill.id,
      providerAmountMinor: 10000,
      paymentDate: DateTime.utc(2026, 4, 2),
      paymentMonth: '2026-04',
      submissionDate: DateTime.utc(2026, 4, 3),
      operationKey: 'same',
      isAccessCurrent: () => true,
    );
    final again = await f.service.submitRequest(
      billId: f.bill.id,
      providerAmountMinor: 10000,
      paymentDate: DateTime.utc(2026, 4, 2),
      paymentMonth: '2026-04',
      submissionDate: DateTime.utc(2026, 4, 3),
      operationKey: 'same',
      isAccessCurrent: () => true,
    );
    expect(again.providerPaymentStatus, MedicalProviderPaymentStatus.paid);
    expect(await f.harness.isar.medicalClaimActivitys.count(), 1);

    expect(
      () => f.service.submitRequest(
        billId: f.bill.id,
        providerAmountMinor: 10000,
        paymentDate: DateTime.utc(2026, 4, 2),
        paymentMonth: '2026-04',
        submissionDate: DateTime.utc(2026, 4, 3),
        operationKey: 'other',
        isAccessCurrent: () => false,
      ),
      throwsA(isA<MedicalManagementException>()),
    );
  });
}
