import 'package:flutter_test/flutter_test.dart';

import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/services/medical_management_reducer.dart';

void main() {
  const reducer = MedicalManagementReducer();

  MedicalBill bill({
    MedicalPaymentMethod method = MedicalPaymentMethod.selfPaid,
    MedicalOverallStatus overall = MedicalOverallStatus.open,
    MedicalInsuranceRequestStatus request =
        MedicalInsuranceRequestStatus.notSubmitted,
    MedicalSalarySettlementStatus settlement =
        MedicalSalarySettlementStatus.notRequired,
    bool needsReview = false,
  }) =>
      MedicalBill()
        ..paymentMethod = method
        ..overallStatus = overall
        ..insuranceRequestStatus = request
        ..salarySettlementStatus = settlement
        ..needsReview = needsReview;

  test('maps each request stage to one primary action', () {
    expect(reducer.resolve(bill()).primaryAction,
        MedicalManagementAction.submitRequest);
    expect(
        reducer
            .resolve(bill(request: MedicalInsuranceRequestStatus.submitted))
            .primaryAction,
        MedicalManagementAction.confirmReceipt);
    expect(
        reducer
            .resolve(bill(request: MedicalInsuranceRequestStatus.inProgress))
            .primaryAction,
        MedicalManagementAction.recordDecision);
    expect(
        reducer
            .resolve(bill(request: MedicalInsuranceRequestStatus.approved))
            .primaryAction,
        MedicalManagementAction.reviewApprovedAmounts);
    expect(
        reducer
            .resolve(bill(request: MedicalInsuranceRequestStatus.rejected))
            .primaryAction,
        MedicalManagementAction.resolveRejection);
    expect(
        reducer
            .resolve(
                bill(request: MedicalInsuranceRequestStatus.appealSubmitted))
            .primaryAction,
        MedicalManagementAction.recordAppealOutcome);
    expect(
        reducer
            .resolve(bill(request: MedicalInsuranceRequestStatus.completed))
            .primaryAction,
        MedicalManagementAction.closeBill);
  });

  test('settlement waiting overrides the approved stage with payslip check',
      () {
    final state = reducer.resolve(bill(
      request: MedicalInsuranceRequestStatus.approved,
      settlement: MedicalSalarySettlementStatus.waitingForPayslip,
    ));

    expect(state.stage, MedicalManagementStage.waitingForPayslip);
    expect(state.primaryAction, MedicalManagementAction.checkPayslip);
    expect(state.showSettlement, isTrue);
  });

  test('closed, cancelled and needs-review bills have safe primaries', () {
    expect(
        reducer
            .resolve(bill(overall: MedicalOverallStatus.closed))
            .primaryAction,
        MedicalManagementAction.reopenBill);
    expect(
        reducer
            .resolve(bill(overall: MedicalOverallStatus.cancelled))
            .primaryAction,
        MedicalManagementAction.viewActivity);
    final review = reducer.resolve(bill(needsReview: true));
    expect(review.stage, MedicalManagementStage.needsReview);
    expect(review.primaryAction, MedicalManagementAction.reviewBill);
    expect(review.blockers, isNotEmpty);
  });

  test('card visibility follows the payment model and stage', () {
    final self = reducer.resolve(bill());
    expect(self.showProviderPayment, isTrue);
    expect(self.showInsuranceRequest, isTrue);

    final direct =
        reducer.resolve(bill(method: MedicalPaymentMethod.insurerPaid));
    expect(direct.showProviderPayment, isFalse);

    final closed = reducer.resolve(bill(overall: MedicalOverallStatus.closed));
    expect(closed.showInsuranceRequest, isFalse);
  });

  test('edit is only offered when the caller can edit', () {
    final editable = reducer.resolve(bill(), canEdit: true);
    final readOnly = reducer.resolve(bill(), canEdit: false);

    expect(
        editable.secondaryActions, contains(MedicalManagementAction.editBill));
    expect(readOnly.secondaryActions,
        isNot(contains(MedicalManagementAction.editBill)));
  });
}
