import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_appeal.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/services/medical_management_service.dart';
import '../../features/medical/repositories/medical_test_harness.dart';

import '../../features/medical/management/fixtures.dart' as fixtures;

void main() {
  Future<
      ({
        MedicalTestHarness harness,
        MedicalManagementService service,
        MedicalBill bill,
      })> setup({
    MedicalPaymentMethod method = MedicalPaymentMethod.selfPaid,
    double share = 20,
  }) async {
    final harness = await MedicalTestHarness.create();
    final context = await harness.seedBudget(yearMonth: '2026-03');
    final seeded = await fixtures.seedManagementBill(
      harness.isar,
      profileId: context.profileId,
      budgetId: context.budgetId,
      currency: 'usd',
      yearMonth: '2026-03',
      paymentMethod: method,
      patientSharePercent: share,
      providerPaymentStatus: method == MedicalPaymentMethod.insurerPaid
          ? MedicalProviderPaymentStatus.notRequired
          : MedicalProviderPaymentStatus.notConfirmed,
      salarySettlementType: method == MedicalPaymentMethod.insurerPaid
          ? MedicalSalarySettlementType.userShareDeduction
          : MedicalSalarySettlementType.insuranceRefund,
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

  Future<void> reject(
    MedicalManagementService service,
    MedicalBill bill, {
    bool insurer = false,
  }) async {
    if (insurer) {
      await service.submitInsuranceRequest(
        billId: bill.id,
        submissionDate: DateTime.utc(2026, 4, 1),
        operationKey: 'sub',
        isAccessCurrent: () => true,
      );
    } else {
      await service.submitRequest(
        billId: bill.id,
        providerAmountMinor: 10000,
        paymentDate: DateTime.utc(2026, 4, 2),
        paymentMonth: '2026-04',
        submissionDate: DateTime.utc(2026, 4, 3),
        operationKey: 'sub',
        isAccessCurrent: () => true,
      );
    }
    await service.confirmReceipt(
      billId: bill.id,
      receiptDate: DateTime.utc(2026, 4, 4),
      operationKey: 'rec',
      isAccessCurrent: () => true,
    );
    await service.recordDecision(
      billId: bill.id,
      decision: MedicalDecision.rejected,
      decisionDate: DateTime.utc(2026, 4, 5),
      operationKey: 'dec',
      isAccessCurrent: () => true,
    );
  }

  test('accepting a user-paid rejection keeps the payment and allows close',
      () async {
    final f = await setup();
    addTearDown(f.harness.close);
    await reject(f.service, f.bill);

    final accepted = await f.service.acceptRejection(
      billId: f.bill.id,
      decisionDate: DateTime.utc(2026, 4, 6),
      operationKey: 'accept',
      isAccessCurrent: () => true,
    );
    expect(accepted.rejectionResolution, MedicalRejectionResolution.accepted);
    expect(accepted.salarySettlementStatus,
        MedicalSalarySettlementStatus.notRequired);
    expect(accepted.providerPaymentStatus, MedicalProviderPaymentStatus.paid);

    final closed = await f.service.closeBill(
      billId: f.bill.id,
      operationKey: 'close',
      isAccessCurrent: () => true,
    );
    expect(closed.overallStatus, MedicalOverallStatus.closed);
  });

  test('appeal approved returns to amount review; appeal rejected can close',
      () async {
    final f = await setup();
    addTearDown(f.harness.close);
    await reject(f.service, f.bill);

    final appealed = await f.service.recordAppeal(
      billId: f.bill.id,
      submittedAt: DateTime.utc(2026, 4, 7),
      reference: 'AP-1',
      operationKey: 'appeal',
      isAccessCurrent: () => true,
    );
    expect(appealed.insuranceRequestStatus,
        MedicalInsuranceRequestStatus.appealSubmitted);
    final appeals = await f.harness.isar.medicalAppeals.where().findAll();
    expect(appeals.single.outcome, MedicalAppealOutcome.pending);

    final approved = await f.service.recordAppealOutcome(
      billId: f.bill.id,
      approved: true,
      decidedAt: DateTime.utc(2026, 4, 9),
      operationKey: 'appeal-ok',
      isAccessCurrent: () => true,
    );
    expect(approved.insuranceRequestStatus,
        MedicalInsuranceRequestStatus.appealApproved);

    final reviewed = await f.service.reviewApprovedAmounts(
      billId: f.bill.id,
      approvedBillMinor: 10000,
      approvedShareMinor: 2000,
      approvedInsuranceMinor: 8000,
      expectedSalaryMonth: '2026-05',
      operationKey: 'after-appeal',
      isAccessCurrent: () => true,
    );
    expect(reviewed.salarySettlementStatus,
        MedicalSalarySettlementStatus.waitingForPayslip);
  });

  test('appeal rejected allows the final close', () async {
    final f = await setup();
    addTearDown(f.harness.close);
    await reject(f.service, f.bill);
    await f.service.recordAppeal(
      billId: f.bill.id,
      submittedAt: DateTime.utc(2026, 4, 7),
      operationKey: 'appeal-final',
      isAccessCurrent: () => true,
    );
    final rejected = await f.service.recordAppealOutcome(
      billId: f.bill.id,
      approved: false,
      decidedAt: DateTime.utc(2026, 4, 9),
      operationKey: 'appeal-rejected',
      isAccessCurrent: () => true,
    );
    expect(rejected.insuranceRequestStatus,
        MedicalInsuranceRequestStatus.appealRejected);
    final closed = await f.service.closeBill(
      billId: f.bill.id,
      operationKey: 'close-final',
      isAccessCurrent: () => true,
    );
    expect(closed.overallStatus, MedicalOverallStatus.closed);
  });

  test('cancelling a paid self-paid request does not reverse the payment',
      () async {
    final f = await setup();
    addTearDown(f.harness.close);
    await f.service.submitRequest(
      billId: f.bill.id,
      providerAmountMinor: 10000,
      paymentDate: DateTime.utc(2026, 4, 2),
      paymentMonth: '2026-04',
      submissionDate: DateTime.utc(2026, 4, 3),
      operationKey: 'sub',
      isAccessCurrent: () => true,
    );
    final cancelled = await f.service.cancelRequest(
      billId: f.bill.id,
      cancelledAt: DateTime.utc(2026, 4, 4),
      reason: 'Claim withdrawn',
      operationKey: 'cancel',
      isAccessCurrent: () => true,
    );
    expect(cancelled.insuranceRequestStatus,
        MedicalInsuranceRequestStatus.requestCancelled);
    final expense =
        (await f.harness.isar.expenses.get(f.bill.linkedExpenseId!))!;
    expect(expense.status, ExpenseStatus.paid);
    expect(expense.amount, 10000);

    final closed = await f.service.closeBill(
      billId: f.bill.id,
      operationKey: 'close',
      isAccessCurrent: () => true,
    );
    expect(closed.overallStatus, MedicalOverallStatus.closed);
  });

  test('insurance rejection resolves as adjusted deduction or other', () async {
    final adjusted = await setup(method: MedicalPaymentMethod.insurerPaid);
    addTearDown(adjusted.harness.close);
    await reject(adjusted.service, adjusted.bill, insurer: true);
    final resolved = await adjusted.service.resolveInsurancePaidRejection(
      billId: adjusted.bill.id,
      resolution: MedicalRejectionResolution.adjustedDeduction,
      amountMinor: 1500,
      expectedSalaryMonth: '2026-05',
      operationKey: 'adjusted',
      isAccessCurrent: () => true,
    );
    expect(resolved.salarySettlementStatus,
        MedicalSalarySettlementStatus.waitingForPayslip);
    expect(resolved.settlementAmountMinor, 1500);
    await adjusted.service.recordDeductionConfirmed(
      billId: adjusted.bill.id,
      amountMinor: 1500,
      actualSalaryMonth: '2026-05',
      deductionDate: DateTime.utc(2026, 5, 10),
      operationKey: 'deduct-adjusted',
      isAccessCurrent: () => true,
    );
    final closed = await adjusted.service.closeBill(
      billId: adjusted.bill.id,
      operationKey: 'close-adjusted',
      isAccessCurrent: () => true,
    );
    expect(closed.overallStatus, MedicalOverallStatus.closed);

    final other = await setup(method: MedicalPaymentMethod.insurerPaid);
    addTearDown(other.harness.close);
    await reject(other.service, other.bill, insurer: true);
    await other.service.resolveInsurancePaidRejection(
      billId: other.bill.id,
      resolution: MedicalRejectionResolution.other,
      reason: 'Provider agreed to settle separately',
      operationKey: 'other',
      isAccessCurrent: () => true,
    );
    final otherClosed = await other.service.closeBill(
      billId: other.bill.id,
      operationKey: 'close-other',
      isAccessCurrent: () => true,
    );
    expect(otherClosed.overallStatus, MedicalOverallStatus.closed);
  });

  test('insurance rejection resolves as cancelled or user payment', () async {
    final cancelled = await setup(method: MedicalPaymentMethod.insurerPaid);
    addTearDown(cancelled.harness.close);
    await reject(cancelled.service, cancelled.bill, insurer: true);
    final result = await cancelled.service.resolveInsurancePaidRejection(
      billId: cancelled.bill.id,
      resolution: MedicalRejectionResolution.providerCancelled,
      operationKey: 'provider-cancelled',
      isAccessCurrent: () => true,
    );
    expect(result.overallStatus, MedicalOverallStatus.cancelled);

    final paid = await setup(method: MedicalPaymentMethod.insurerPaid);
    addTearDown(paid.harness.close);
    await reject(paid.service, paid.bill, insurer: true);
    final resolved = await paid.service.resolveInsurancePaidRejection(
      billId: paid.bill.id,
      resolution: MedicalRejectionResolution.userPaidProvider,
      amountMinor: 10000,
      paymentDate: DateTime.utc(2026, 4, 8),
      paymentMonth: '2026-04',
      operationKey: 'user-paid',
      isAccessCurrent: () => true,
    );
    expect(resolved.providerPaymentStatus, MedicalProviderPaymentStatus.paid);
    final expense =
        (await paid.harness.isar.expenses.get(paid.bill.linkedExpenseId!))!;
    expect(expense.cashYearMonth, '2026-04');
    expect(expense.amount, 10000);

    final closed = await paid.service.closeBill(
      billId: paid.bill.id,
      operationKey: 'close',
      isAccessCurrent: () => true,
    );
    expect(closed.overallStatus, MedicalOverallStatus.closed);
  });
}
