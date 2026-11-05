import '../models/medical_bill.dart';

/// The stage the management screen focuses on. Derived from the four trackers;
/// never persisted.
enum MedicalManagementStage {
  needsReview,
  planned,
  receiptPending,
  inProgress,
  approved,
  waitingForPayslip,
  rejected,
  appeal,
  requestCancelled,
  completed,
  closed,
  cancelled,
}

/// The one primary management action for a stage.
enum MedicalManagementAction {
  reviewBill,
  submitRequest,
  confirmReceipt,
  recordDecision,
  cancelRequest,
  reviewApprovedAmounts,
  checkPayslip,
  completeCase,
  resolveRejection,
  recordAppeal,
  recordAppealOutcome,
  recordProviderRefund,
  correctEvent,
  closeBill,
  reopenBill,
  viewActivity,
  setReminder,
  editBill,
}

/// Immutable, pure view of the management stage and the actions it allows.
class MedicalManagementState {
  const MedicalManagementState({
    required this.stage,
    required this.stageLabel,
    required this.primaryAction,
    required this.primaryActionLabel,
    this.secondaryActions = const [],
    this.blockers = const [],
    this.showProviderPayment = false,
    this.showInsuranceRequest = false,
    this.showApproval = false,
    this.showSettlement = false,
    this.showAppeal = false,
  });

  final MedicalManagementStage stage;
  final String stageLabel;
  final MedicalManagementAction primaryAction;
  final String primaryActionLabel;
  final List<MedicalManagementAction> secondaryActions;
  final List<String> blockers;

  final bool showProviderPayment;
  final bool showInsuranceRequest;
  final bool showApproval;
  final bool showSettlement;
  final bool showAppeal;

  bool get isClosed =>
      stage == MedicalManagementStage.closed ||
      stage == MedicalManagementStage.cancelled;
  bool get needsReview => stage == MedicalManagementStage.needsReview;
}

/// Pure stage mapper for both payment models. No database reads, writes or clock.
class MedicalManagementReducer {
  const MedicalManagementReducer();

  MedicalManagementState resolve(MedicalBill bill, {bool canEdit = true}) {
    if (bill.needsReview) {
      return _state(
        bill,
        MedicalManagementStage.needsReview,
        'Needs review',
        MedicalManagementAction.reviewBill,
        'Review bill',
        blockers: const [
          'This bill has legacy or ambiguous money that must be reviewed '
              'before the new workflow can continue.',
        ],
        secondary:
            canEdit ? const [MedicalManagementAction.editBill] : const [],
      );
    }

    if (bill.overallStatus == MedicalOverallStatus.closed) {
      return _state(
        bill,
        MedicalManagementStage.closed,
        'Bill closed',
        MedicalManagementAction.reopenBill,
        'Reopen bill',
        secondary: const [MedicalManagementAction.viewActivity],
      );
    }
    if (bill.overallStatus == MedicalOverallStatus.cancelled) {
      return _state(
        bill,
        MedicalManagementStage.cancelled,
        'Bill cancelled',
        MedicalManagementAction.viewActivity,
        'View activity',
      );
    }

    if (bill.paymentMethod == MedicalPaymentMethod.insurerPaid &&
        bill.insuranceRequestStatus == MedicalInsuranceRequestStatus.approved &&
        bill.salarySettlementType ==
            MedicalSalarySettlementType.userShareDeduction &&
        bill.salarySettlementStatus ==
            MedicalSalarySettlementStatus.notRequired &&
        (bill.settlementAmountMinor ?? -1) == 0) {
      return _state(
        bill,
        MedicalManagementStage.approved,
        'Approved at 100%',
        MedicalManagementAction.completeCase,
        'Confirm case complete',
        secondary: const [MedicalManagementAction.setReminder],
      );
    }

    if (bill.salarySettlementStatus ==
            MedicalSalarySettlementStatus.waitingForPayslip ||
        bill.salarySettlementStatus ==
            MedicalSalarySettlementStatus.notReceived ||
        bill.salarySettlementStatus ==
            MedicalSalarySettlementStatus.notDeducted) {
      return _state(
        bill,
        MedicalManagementStage.waitingForPayslip,
        'Waiting for payslip',
        MedicalManagementAction.checkPayslip,
        'Check payslip',
        secondary: const [MedicalManagementAction.setReminder],
      );
    }

    final status = bill.insuranceRequestStatus;
    switch (status) {
      case MedicalInsuranceRequestStatus.notSubmitted:
        return _state(
          bill,
          MedicalManagementStage.planned,
          'Planned',
          MedicalManagementAction.submitRequest,
          'Submit request',
          secondary:
              canEdit ? const [MedicalManagementAction.editBill] : const [],
        );
      case MedicalInsuranceRequestStatus.submitted:
      case MedicalInsuranceRequestStatus.receiptPending:
        return _state(
          bill,
          MedicalManagementStage.receiptPending,
          'Insurance received request',
          MedicalManagementAction.confirmReceipt,
          'Confirm insurance received it',
          secondary: const [
            MedicalManagementAction.setReminder,
            MedicalManagementAction.cancelRequest,
          ],
        );
      case MedicalInsuranceRequestStatus.inProgress:
        return _state(
          bill,
          MedicalManagementStage.inProgress,
          'Under review',
          MedicalManagementAction.recordDecision,
          'Record insurance decision',
          secondary: const [
            MedicalManagementAction.setReminder,
            MedicalManagementAction.cancelRequest,
          ],
        );
      case MedicalInsuranceRequestStatus.approved:
      case MedicalInsuranceRequestStatus.appealApproved:
        return _state(
          bill,
          MedicalManagementStage.approved,
          'Approved',
          MedicalManagementAction.reviewApprovedAmounts,
          'Review approved amounts',
          secondary: const [MedicalManagementAction.cancelRequest],
        );
      case MedicalInsuranceRequestStatus.rejected:
      case MedicalInsuranceRequestStatus.appealRejected:
        return _state(
          bill,
          MedicalManagementStage.rejected,
          'Rejected',
          MedicalManagementAction.resolveRejection,
          'Resolve rejection',
          secondary: const [MedicalManagementAction.recordAppeal],
        );
      case MedicalInsuranceRequestStatus.appealSubmitted:
      case MedicalInsuranceRequestStatus.appealInProgress:
        return _state(
          bill,
          MedicalManagementStage.appeal,
          'Appeal in progress',
          MedicalManagementAction.recordAppealOutcome,
          'Record appeal outcome',
          secondary: const [MedicalManagementAction.setReminder],
        );
      case MedicalInsuranceRequestStatus.requestCancelled:
        final direct = bill.paymentMethod == MedicalPaymentMethod.insurerPaid;
        return _state(
          bill,
          MedicalManagementStage.requestCancelled,
          'Request cancelled',
          direct
              ? MedicalManagementAction.resolveRejection
              : MedicalManagementAction.closeBill,
          direct ? 'Resolve remaining charge' : 'Close bill',
        );
      case MedicalInsuranceRequestStatus.completed:
        return _state(
          bill,
          MedicalManagementStage.completed,
          'Ready to close',
          MedicalManagementAction.closeBill,
          'Close bill',
        );
    }
  }

  MedicalManagementState _state(
    MedicalBill bill,
    MedicalManagementStage stage,
    String label,
    MedicalManagementAction action,
    String actionLabel, {
    List<MedicalManagementAction> secondary = const [],
    List<String> blockers = const [],
  }) {
    final direct = bill.paymentMethod == MedicalPaymentMethod.insurerPaid;
    final actions = <MedicalManagementAction>[...secondary];
    if (!direct &&
        bill.providerPaymentStatus == MedicalProviderPaymentStatus.paid &&
        !actions.contains(MedicalManagementAction.recordProviderRefund)) {
      actions.add(MedicalManagementAction.recordProviderRefund);
    }
    final canCorrect =
        bill.providerPaymentStatus == MedicalProviderPaymentStatus.refunded ||
            (!direct &&
                bill.salarySettlementType ==
                    MedicalSalarySettlementType.insuranceRefund &&
                bill.salarySettlementStatus ==
                    MedicalSalarySettlementStatus.received) ||
            (direct &&
                bill.salarySettlementType ==
                    MedicalSalarySettlementType.userShareDeduction &&
                bill.salarySettlementStatus ==
                    MedicalSalarySettlementStatus.deducted);
    if (canCorrect && !actions.contains(MedicalManagementAction.correctEvent)) {
      actions.add(MedicalManagementAction.correctEvent);
    }
    return MedicalManagementState(
      stage: stage,
      stageLabel: label,
      primaryAction: action,
      primaryActionLabel: actionLabel,
      secondaryActions: actions,
      blockers: blockers,
      showProviderPayment: !direct,
      showInsuranceRequest: stage != MedicalManagementStage.closed &&
          stage != MedicalManagementStage.cancelled,
      showApproval: stage == MedicalManagementStage.approved,
      showSettlement: stage == MedicalManagementStage.waitingForPayslip ||
          bill.salarySettlementStatus ==
              MedicalSalarySettlementStatus.received ||
          bill.salarySettlementStatus == MedicalSalarySettlementStatus.deducted,
      showAppeal: stage == MedicalManagementStage.appeal ||
          bill.insuranceRequestStatus ==
              MedicalInsuranceRequestStatus.appealSubmitted ||
          bill.insuranceRequestStatus ==
              MedicalInsuranceRequestStatus.appealInProgress,
    );
  }
}
