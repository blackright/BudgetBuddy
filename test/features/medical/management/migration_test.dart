import 'package:flutter_test/flutter_test.dart';

import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import '../repositories/medical_test_harness.dart';

void main() {
  test('step 41 maps legacy states without changing money', () async {
    final harness = await MedicalTestHarness.create();
    addTearDown(harness.close);
    final context = await harness.seedBudget();
    await writeSchemaVersion(harness.isar, 40);

    final planned = await harness.seedManagementBill(context: context);
    final waiting = await harness.seedManagementBill(
      context: context,
      state: MedicalBillState.waiting,
    );
    final finished = await harness.seedManagementBill(
      context: context,
      state: MedicalBillState.finished,
    );
    final rejected = await harness.seedManagementBill(
      context: context,
      state: MedicalBillState.rejected,
    );
    final partial = await harness.seedManagementBill(
      context: context,
      state: MedicalBillState.waiting,
      reimbursedAmount: 2500,
    );

    await harness.isar.writeTxn(() async {
      await harness.isar.medicalClaimActivitys.put(MedicalClaimActivity()
        ..billGuid = waiting.bill.syncGuid
        ..profileId = context.profileId
        ..yearMonth = context.yearMonth
        ..kind = 'submitted'
        ..submittedAt = DateTime.utc(2026, 1, 10)
        ..reason = ''
        ..currency = 'usd'
        ..recordedAt = DateTime.utc(2026, 1, 10)
        ..actorId = context.profileId
        ..operationIdentity = 'submitted:${waiting.bill.syncGuid}'
        ..inputFingerprint = List.filled(64, 'a').join());

      final approval = MedicalApproval()
        ..billGuid = finished.bill.syncGuid
        ..profileId = context.profileId
        ..yearMonth = context.yearMonth
        ..approvedMinor = 8000
        ..currency = 'usd'
        ..decisionDate = DateTime.utc(2026, 1, 12)
        ..recordedAt = DateTime.utc(2026, 1, 12)
        ..actorId = context.profileId
        ..operationIdentity = 'approval:${finished.bill.syncGuid}'
        ..inputFingerprint = List.filled(64, 'b').join();
      approval.id = await harness.isar.medicalApprovals.put(approval);

      await harness.isar.medicalClaimClosures.put(MedicalClaimClosure()
        ..billGuid = finished.bill.syncGuid
        ..approvalGuid = approval.syncGuid
        ..profileId = context.profileId
        ..yearMonth = context.yearMonth
        ..receivedMinor = 8000
        ..shortfallMinor = 0
        ..currency = 'usd'
        ..reason = 'settled'
        ..actorId = context.profileId
        ..recordedAt = DateTime.utc(2026, 2, 1)
        ..operationIdentity = 'closure:${finished.bill.syncGuid}');

      await harness.isar.reimbursements.put(Reimbursement(
        profileId: context.profileId,
        expenseId: finished.bill.linkedExpenseId,
        originYearMonth: context.yearMonth,
        amount: 8000,
        currency: 'usd',
        date: DateTime.utc(2026, 2, 1),
      ));

      await harness.isar.reimbursements.put(Reimbursement(
        profileId: context.profileId,
        expenseId: partial.bill.linkedExpenseId,
        originYearMonth: context.yearMonth,
        amount: 2500,
        currency: 'usd',
        date: DateTime.utc(2026, 2, 2),
      ));
    });

    await harness.runMigrations();

    final plannedRow = (await harness.isar.medicalBills.get(planned.bill.id))!;
    expect(plannedRow.overallStatus, MedicalOverallStatus.open);
    expect(plannedRow.providerPaymentStatus,
        MedicalProviderPaymentStatus.notConfirmed);
    expect(plannedRow.insuranceRequestStatus,
        MedicalInsuranceRequestStatus.notSubmitted);
    expect(plannedRow.salarySettlementType,
        MedicalSalarySettlementType.insuranceRefund);

    final waitingRow = (await harness.isar.medicalBills.get(waiting.bill.id))!;
    expect(waitingRow.insuranceRequestStatus,
        MedicalInsuranceRequestStatus.submitted);
    expect(waitingRow.submissionDate?.toUtc(), DateTime.utc(2026, 1, 10));

    final finishedRow =
        (await harness.isar.medicalBills.get(finished.bill.id))!;
    expect(finishedRow.overallStatus, MedicalOverallStatus.closed);
    expect(finishedRow.insuranceRequestStatus,
        MedicalInsuranceRequestStatus.completed);
    expect(finishedRow.salarySettlementStatus,
        MedicalSalarySettlementStatus.received);
    expect(finishedRow.closedAt?.toUtc(), DateTime.utc(2026, 2, 1));
    expect(finishedRow.closeReason, 'settled');
    expect(finishedRow.needsReview, isTrue,
        reason: 'legacy receipts have no actual salary month');

    final rejectedRow =
        (await harness.isar.medicalBills.get(rejected.bill.id))!;
    expect(rejectedRow.insuranceRequestStatus,
        MedicalInsuranceRequestStatus.rejected);
    expect(rejectedRow.overallStatus, MedicalOverallStatus.open);

    final partialRow = (await harness.isar.medicalBills.get(partial.bill.id))!;
    expect(partialRow.needsReview, isTrue);
    expect(partialRow.salarySettlementStatus,
        MedicalSalarySettlementStatus.notReceived);
    expect(partialRow.settledAmountMinor, 2500);
    expect(partialRow.reimbursedAmount, 2500);

    final expenses = await harness.allExpenses();
    expect(expenses.every((e) => e.cashYearMonth == null), isTrue);
  });
}
