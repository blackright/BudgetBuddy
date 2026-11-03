import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_settlement_event.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/core/services/medical_management_service.dart';
import '../../features/medical/repositories/medical_test_harness.dart';

import '../../features/medical/management/fixtures.dart' as fixtures;

void main() {
  Future<
      ({
        MedicalTestHarness harness,
        MedicalManagementService service,
        MedicalBill bill,
      })> setup() async {
    final harness = await MedicalTestHarness.create();
    final context = await harness.seedBudget(yearMonth: '2026-03');
    final seeded = await fixtures.seedManagementBill(
      harness.isar,
      profileId: context.profileId,
      budgetId: context.budgetId,
      currency: 'usd',
      yearMonth: '2026-03',
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

  Future<void> submit(
      MedicalManagementService service, MedicalBill bill) async {
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

  test('provider refund is full-only and credits the actual month', () async {
    final f = await setup();
    addTearDown(f.harness.close);
    await submit(f.service, f.bill);
    await f.service.cancelRequest(
      billId: f.bill.id,
      cancelledAt: DateTime.utc(2026, 4, 4),
      reason: 'Charge returned',
      operationKey: 'cancel',
      isAccessCurrent: () => true,
    );

    expect(
      () => f.service.recordProviderRefund(
        billId: f.bill.id,
        amountMinor: 5000,
        actualMonth: '2026-05',
        receivedDate: DateTime.utc(2026, 5, 2),
        operationKey: 'partial',
        isAccessCurrent: () => true,
      ),
      throwsA(isA<MedicalManagementException>()),
    );

    final refunded = await f.service.recordProviderRefund(
      billId: f.bill.id,
      amountMinor: 10000,
      actualMonth: '2026-05',
      receivedDate: DateTime.utc(2026, 5, 2),
      operationKey: 'full',
      isAccessCurrent: () => true,
    );
    expect(
        refunded.providerPaymentStatus, MedicalProviderPaymentStatus.refunded);
    final row = (await f.harness.isar.reimbursements.where().findAll())
        .singleWhere(
            (r) => r.source == ReimbursementSource.medicalProviderRefund);
    expect(row.creditYearMonth, '2026-05');
    expect(row.originYearMonth, '2026-03');
    expect(row.amount, 10000);

    final corrected = await f.service.correctFinancialEvent(
      billId: f.bill.id,
      newAmountMinor: 10000,
      actualMonth: '2026-06',
      reason: 'Refund arrived in June',
      operationKey: 'correct-provider-refund',
      isAccessCurrent: () => true,
    );
    expect(
        corrected.providerPaymentStatus, MedicalProviderPaymentStatus.refunded);
    final correctedRow = (await f.harness.isar.reimbursements.where().findAll())
        .singleWhere(
            (r) => r.source == ReimbursementSource.medicalProviderRefund);
    expect(correctedRow.creditYearMonth, '2026-06');

    final closed = await f.service.closeBill(
      billId: f.bill.id,
      operationKey: 'close',
      isAccessCurrent: () => true,
    );
    expect(closed.overallStatus, MedicalOverallStatus.closed);
  });

  test('reopen preserves the closure and allows a second close', () async {
    final f = await setup();
    addTearDown(f.harness.close);
    await submit(f.service, f.bill);
    await f.service.cancelRequest(
      billId: f.bill.id,
      cancelledAt: DateTime.utc(2026, 4, 4),
      reason: 'No claim',
      operationKey: 'cancel',
      isAccessCurrent: () => true,
    );
    await f.service.closeBill(
      billId: f.bill.id,
      operationKey: 'close-1',
      isAccessCurrent: () => true,
    );
    final activitiesBefore = await f.harness.isar.medicalClaimActivitys.count();

    final reopened = await f.service.reopenBill(
      billId: f.bill.id,
      reason: 'Wrong month',
      operationKey: 'reopen',
      isAccessCurrent: () => true,
    );
    expect(reopened.overallStatus, MedicalOverallStatus.open);
    expect(reopened.closedAt, isNull);
    expect(await f.harness.isar.medicalClaimActivitys.count(),
        greaterThan(activitiesBefore));

    final closedAgain = await f.service.closeBill(
      billId: f.bill.id,
      operationKey: 'close-2',
      isAccessCurrent: () => true,
    );
    expect(closedAgain.overallStatus, MedicalOverallStatus.closed);
  });

  test('correcting a refund appends reversal and corrected evidence', () async {
    final f = await setup();
    addTearDown(f.harness.close);
    await submit(f.service, f.bill);
    await f.service.confirmReceipt(
      billId: f.bill.id,
      receiptDate: DateTime.utc(2026, 4, 4),
      operationKey: 'rec',
      isAccessCurrent: () => true,
    );
    await f.service.recordDecision(
      billId: f.bill.id,
      decision: MedicalDecision.approved,
      decisionDate: DateTime.utc(2026, 4, 5),
      operationKey: 'dec',
      isAccessCurrent: () => true,
    );
    await f.service.reviewApprovedAmounts(
      billId: f.bill.id,
      approvedBillMinor: 10000,
      approvedShareMinor: 2000,
      approvedInsuranceMinor: 8000,
      expectedSalaryMonth: '2026-05',
      operationKey: 'app',
      isAccessCurrent: () => true,
    );
    await f.service.recordRefundReceived(
      billId: f.bill.id,
      amountMinor: 8000,
      actualSalaryMonth: '2026-05',
      receivedDate: DateTime.utc(2026, 5, 10),
      operationKey: 'refund',
      isAccessCurrent: () => true,
    );
    await f.service.closeBill(
      billId: f.bill.id,
      operationKey: 'close',
      isAccessCurrent: () => true,
    );
    await f.service.reopenBill(
      billId: f.bill.id,
      reason: 'Correct refund',
      operationKey: 'reopen',
      isAccessCurrent: () => true,
    );

    final corrected = await f.service.correctFinancialEvent(
      billId: f.bill.id,
      newAmountMinor: 7000,
      actualMonth: '2026-06',
      reason: 'Payslip showed 7,000',
      operationKey: 'correct',
      isAccessCurrent: () => true,
    );
    expect(corrected.settledAmountMinor, 7000);
    expect(corrected.actualSalaryMonth, '2026-06');
    expect(corrected.reimbursedAmount, 7000);

    final row = (await f.harness.isar.reimbursements.where().findAll())
        .singleWhere((r) => r.source == ReimbursementSource.medicalInsurance);
    expect(row.amount, 7000);
    expect(row.creditYearMonth, '2026-06');

    final events = await f.harness.isar.medicalSettlements.where().findAll();
    expect(events.any((e) => e.kind == MedicalSettlementKind.reversal), isTrue);
    expect(
        events.any((e) => e.kind == MedicalSettlementKind.correction), isTrue);

    final approvals = await f.harness.isar.medicalApprovals
        .filter()
        .billGuidEqualTo(f.bill.syncGuid)
        .findAll();
    approvals.sort((a, b) => a.revision.compareTo(b.revision));
    expect(approvals.last.approvedInsuranceMinor, 7000);
    expect(approvals.last.approvedShareMinor, 3000);
  });
}
