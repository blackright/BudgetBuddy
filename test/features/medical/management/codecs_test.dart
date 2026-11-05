import 'package:flutter_test/flutter_test.dart';

import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_appeal.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_settlement_event.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/sync/domain/codecs/expense_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/medical_appeal_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/medical_approval_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/medical_bill_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/medical_claim_activity_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/medical_settlement_event_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/reimbursement_codec.dart';

void main() {
  test('bill codec round-trips the four trackers', () {
    final bill = MedicalBill()
      ..syncGuid = 'bill-guid'
      ..profileId = 1
      ..billedAmount = 10000
      ..patientSharePercent = 20
      ..currency = 'usd'
      ..yearMonth = '2026-10'
      ..overallStatus = MedicalOverallStatus.open
      ..providerPaymentStatus = MedicalProviderPaymentStatus.paid
      ..insuranceRequestStatus = MedicalInsuranceRequestStatus.approved
      ..salarySettlementType = MedicalSalarySettlementType.insuranceRefund
      ..salarySettlementStatus = MedicalSalarySettlementStatus.waitingForPayslip
      ..submissionDate = DateTime.utc(2026, 4, 1)
      ..expectedSalaryMonth = '2026-05'
      ..settlementAmountMinor = 8000
      ..needsReview = false;

    final restored = const MedicalBillCodec()
        .fromJson(const MedicalBillCodec().toJson(bill));

    expect(restored.providerPaymentStatus, MedicalProviderPaymentStatus.paid);
    expect(restored.insuranceRequestStatus,
        MedicalInsuranceRequestStatus.approved);
    expect(restored.salarySettlementStatus,
        MedicalSalarySettlementStatus.waitingForPayslip);
    expect(restored.submissionDate, DateTime.utc(2026, 4, 1));
    expect(restored.expectedSalaryMonth, '2026-05');
    expect(restored.settlementAmountMinor, 8000);
  });

  test('legacy bill payload derives trackers instead of resetting them', () {
    final legacy = {
      'syncGuid': 'legacy-bill',
      'profileId': 1,
      'paymentMethod': MedicalPaymentMethod.insurerPaid.name,
      'patientSharePercent': 20,
      'state': MedicalBillState.finished.name,
      'yearMonth': '2026-03',
      'serviceDate': DateTime.utc(2026, 3, 2).millisecondsSinceEpoch,
      'billedAmount': 10000,
      'currency': 'usd',
      'reimbursedAmount': 0,
    };

    final bill = const MedicalBillCodec().fromJson(legacy);

    expect(bill.overallStatus, MedicalOverallStatus.closed);
    expect(
        bill.providerPaymentStatus, MedicalProviderPaymentStatus.notRequired);
    expect(
        bill.insuranceRequestStatus, MedicalInsuranceRequestStatus.completed);
    expect(bill.salarySettlementType,
        MedicalSalarySettlementType.userShareDeduction);
  });

  test('approval codec still accepts a version 2 record', () {
    final v2 = {
      'version': 2,
      'syncGuid': 'approval-guid',
      'billGuid': 'bill-guid',
      'yearMonth': '2026-10',
      'approvedMinor': 8000,
      'currency': 'usd',
      'decisionDate': DateTime.utc(2026, 4, 2).millisecondsSinceEpoch,
      'recordedAt': DateTime.utc(2026, 4, 2).millisecondsSinceEpoch,
      'revision': 1,
      'previousGuid': null,
      'operationIdentity': 'approval:one',
      'inputFingerprint': List.filled(64, 'a').join(),
    };

    final row = const MedicalApprovalCodec().fromJson(v2);

    expect(row.approvedMinor, 8000);
    expect(row.approvedInsuranceMinor, 8000);
    expect(row.approvedBillMinor, 0);
  });

  test('approval codec enforces the approved split on version 3', () {
    final row = MedicalApproval()
      ..billGuid = 'bill-guid'
      ..yearMonth = '2026-10'
      ..approvedMinor = 8000
      ..approvedBillMinor = 10000
      ..approvedShareMinor = 2000
      ..approvedInsuranceMinor = 8000
      ..currency = 'usd'
      ..decisionDate = DateTime.utc(2026, 4, 2)
      ..recordedAt = DateTime.utc(2026, 4, 2)
      ..operationIdentity = 'approval:two'
      ..inputFingerprint = List.filled(64, 'b').join();

    final json = const MedicalApprovalCodec().toJson(row);
    expect(
        const MedicalApprovalCodec().fromJson(json).approvedShareMinor, 2000);

    json['approvedShareMinor'] = 3000;
    expect(() => const MedicalApprovalCodec().fromJson(json),
        throwsFormatException);
  });

  test('settlement codec accepts legacy v1 and new actual-month kinds', () {
    final legacy = {
      'version': 1,
      'syncGuid': 'settlement-guid',
      'billGuid': 'bill-guid',
      'kind': MedicalSettlementKind.closure.name,
      'confirmed': true,
      'effectiveDate': DateTime.utc(2026, 4, 2).millisecondsSinceEpoch,
      'recordedAt': DateTime.utc(2026, 4, 2).millisecondsSinceEpoch,
      'currency': null,
      'amountMinor': 0,
      'basisJson': null,
      'expenseSyncGuid': null,
      'withholdingMatchGuid': null,
      'supersedesGuid': null,
      'reason': '',
      'operationIdentity': 'close:one',
      'inputFingerprint': 'fp',
    };
    expect(const MedicalSettlementEventCodec().fromJson(legacy).kind,
        MedicalSettlementKind.closure);

    final row = MedicalSettlementEvent()
      ..billGuid = 'bill-guid'
      ..kind = MedicalSettlementKind.insuranceRefund
      ..confirmed = true
      ..effectiveDate = DateTime.utc(2026, 5, 2)
      ..recordedAt = DateTime.utc(2026, 5, 2)
      ..currency = 'usd'
      ..amountMinor = 8000
      ..transactionMonth = '2026-05'
      ..documentPaths = const ['payslip.pdf']
      ..operationIdentity = 'refund:one'
      ..inputFingerprint = 'fp';

    final restored = const MedicalSettlementEventCodec()
        .fromJson(const MedicalSettlementEventCodec().toJson(row));
    expect(restored.transactionMonth, '2026-05');
    expect(restored.documentPaths, ['payslip.pdf']);
  });

  test('activity and appeal codecs round-trip shared-safe evidence', () {
    final activity = MedicalClaimActivity()
      ..syncGuid = 'activity-guid'
      ..billGuid = 'bill-guid'
      ..profileId = 1
      ..yearMonth = '2026-10'
      ..kind = 'receiptConfirmed'
      ..reason = ''
      ..currency = 'usd'
      ..recordedAt = DateTime.utc(2026, 4, 3)
      ..transactionMonth = '2026-04'
      ..documentPaths = const ['receipt.pdf']
      ..operationIdentity = 'activity:one'
      ..inputFingerprint = 'fp';

    final activityJson = const MedicalClaimActivityCodec().toJson(activity);
    final restoredActivity =
        const MedicalClaimActivityCodec().fromJson(activityJson);
    expect(restoredActivity.kind, 'receiptConfirmed');
    expect(restoredActivity.transactionMonth, '2026-04');

    final appeal = MedicalAppeal()
      ..syncGuid = 'appeal-guid'
      ..billGuid = 'bill-guid'
      ..profileId = 1
      ..submittedAt = DateTime.utc(2026, 4, 4)
      ..recordedAt = DateTime.utc(2026, 4, 4)
      ..operationIdentity = 'appeal:one';
    final appealJson = const MedicalAppealCodec().toJson(appeal);
    final restoredAppeal = const MedicalAppealCodec().fromJson(appealJson);
    expect(restoredAppeal.outcome, MedicalAppealOutcome.pending);
    expect(restoredAppeal.billGuid, 'bill-guid');
  });

  test('expense and reimbursement codecs carry the cash-month overrides', () {
    final expense = Expense(
      profileId: 1,
      yearMonth: '2026-03',
      title: 'Medical',
      amount: 10000,
      currency: 'usd',
      categoryId: 'health',
      date: DateTime.utc(2026, 3, 2),
      budgetId: 1,
      type: ExpenseType.medical,
      cashYearMonth: '2026-04',
    );
    final restoredExpense =
        const ExpenseCodec().fromJson(const ExpenseCodec().toJson(expense));
    expect(restoredExpense.cashYearMonth, '2026-04');

    final reimbursement = Reimbursement(
      profileId: 1,
      originYearMonth: '2026-03',
      amount: 8000,
      currency: 'usd',
      date: DateTime.utc(2026, 5, 2),
      source: ReimbursementSource.medicalInsurance,
      creditYearMonth: '2026-05',
    );
    final restoredReimbursement = const ReimbursementCodec()
        .fromJson(const ReimbursementCodec().toJson(reimbursement));
    expect(restoredReimbursement.creditYearMonth, '2026-05');
    expect(restoredReimbursement.source, ReimbursementSource.medicalInsurance);
  });
}
