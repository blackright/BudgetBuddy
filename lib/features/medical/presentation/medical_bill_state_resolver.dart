import '../../../core/models/medical_bill.dart';
import '../../../core/models/money.dart';
import 'medical_bill_view_state.dart';
import 'medical_copy.dart';

/// Pure presentation logic. No database reads, financial writes or clock globals.
class MedicalBillStateResolver {
  const MedicalBillStateResolver();

  MedicalBillViewState resolve(
    MedicalBillFacts f, {
    required bool canEdit,
    required MedicalReadiness readiness,
    required DateTime now,
  }) {
    final direct = f.method == MedicalPaymentMethod.insurerPaid;
    final rejected = f.legacyState == MedicalBillState.rejected ||
        (!direct && f.approvedMinor == 0 && !f.needsReview);
    final unknownMoney = f.currency == null || f.receivedMinor == null;
    final received = f.receivedMinor;
    final remaining = f.approvedMinor == null || received == null
        ? null
        : (f.approvedMinor! - received).clamp(0, f.approvedMinor!);
    final review = f.needsReview ||
        f.currency == null ||
        (!direct && (unknownMoney || f.providerPaid == null));
    final directEvidenceUnknown = direct &&
        (f.directProviderSettlement == MedicalEvidence.unknown ||
            (f.patientShareMinor != 0 &&
                f.shareSettlement == MedicalEvidence.unknown));
    var headline = MedicalCopy.needsReview;
    var group = MedicalInboxGroup.needsYou;
    var action = MedicalBillAction.reviewBill;
    final due = f.followUp != null && !f.followUp!.isAfter(now);

    if (f.isShared) {
      // Keep the existing shared state contract; never route into salary.
      headline = f.legacyState.label;
      action = MedicalBillAction.legacyShared;
      group = f.legacyState == MedicalBillState.finished
          ? MedicalInboxGroup.closed
          : MedicalInboxGroup.needsYou;
    } else if (f.enteredInError) {
      headline = MedicalCopy.mistake;
      action = MedicalBillAction.viewActivity;
      group = MedicalInboxGroup.closed;
    } else if (review) {
      headline = MedicalCopy.needsReview;
    } else if (f.cancelled) {
      headline = MedicalCopy.cancelled;
      if (f.providerPaid == true && !direct) {
        group = MedicalInboxGroup.closed;
        action = MedicalBillAction.viewActivity;
      }
    } else if (rejected && f.approvedMinor != 0) {
      headline = MedicalCopy.declined;
    } else if (direct) {
      if (directEvidenceUnknown) {
        headline = MedicalCopy.needsReview;
      } else if (f.directProviderSettlement != MedicalEvidence.confirmed) {
        headline = MedicalCopy.waitingInsurer;
        action = MedicalBillAction.recordInsurerPayment;
        group = due ? MedicalInboxGroup.needsYou : MedicalInboxGroup.waiting;
      } else if (f.patientShareMinor != 0 &&
          f.shareSettlement != MedicalEvidence.confirmed) {
        headline = MedicalCopy.shareNeedsRecording;
        action = MedicalBillAction.recordShare;
      } else if (f.closed) {
        headline = MedicalCopy.closed;
        action = MedicalBillAction.viewActivity;
        group = MedicalInboxGroup.closed;
      } else {
        headline = MedicalCopy.readyToClose;
        action = MedicalBillAction.closeBill;
      }
    } else if (f.providerPaid != true) {
      headline = MedicalCopy.providerUnpaid;
      action = MedicalBillAction.recordPayment;
    } else if (f.closed) {
      headline = MedicalCopy.closed;
      action = MedicalBillAction.viewActivity;
      group = MedicalInboxGroup.closed;
    } else if (f.approvedMinor != null) {
      if (remaining == 0) {
        headline = MedicalCopy.readyToClose;
        action = MedicalBillAction.closeBill;
      } else {
        headline = received! > 0
            ? MedicalCopy.waitingPayslip
            : MedicalCopy.waitingRefund;
        action = MedicalBillAction.reviewIncomingMoney;
        group = due ? MedicalInboxGroup.needsYou : MedicalInboxGroup.waiting;
      }
    } else if (f.submission == MedicalSubmission.sent) {
      headline = MedicalCopy.waitingReply;
      action = MedicalBillAction.setReminder;
      group = due ? MedicalInboxGroup.needsYou : MedicalInboxGroup.waiting;
    } else {
      headline = f.submission == MedicalSubmission.notSent
          ? MedicalCopy.notSent
          : MedicalCopy.sentUnknown;
      action = MedicalBillAction.markAsSent;
    }

    // Phase A exported no new financial capability. Existing service guards must
    // still be applied when later screens adopt these action identifiers.
    final future = action == MedicalBillAction.legacyShared;
    // Navigation validates receiving/funding periods; metadata-only closure
    // never rewrites the historical cost month.
    final destinationGuarded = !direct &&
        {MedicalBillAction.reviewIncomingMoney, MedicalBillAction.closeBill}
            .contains(action);
    final reviewAction = action == MedicalBillAction.reviewBill;
    final inspect = action == MedicalBillAction.viewActivity;
    final blocker = inspect
        ? null
        : !canEdit
            ? MedicalCopy.readOnly
            : future
                ? MedicalCopy.futureAction
                : reviewAction
                    ? MedicalCopy.reviewHelp
                    : !destinationGuarded && !readiness.known
                        ? MedicalCopy.readinessUnknown
                        : !destinationGuarded && readiness.blockers.isNotEmpty
                            ? MedicalCopy.monthBlocked
                            : null;
    final canSettle = direct &&
        !review &&
        !rejected &&
        !f.closed &&
        !f.cancelled &&
        !f.enteredInError &&
        canEdit &&
        readiness.known &&
        readiness.blockers.isEmpty;
    Money? money(int? value) =>
        value == null || f.currency == null ? null : Money(value, f.currency!);
    final cost = f.enteredInError
        ? 0
        : direct
            ? review || directEvidenceUnknown
                ? null
                : rejected
                    ? (f.providerPaid == true ? f.billedMinor : 0)
                    : f.patientShareMinor
            : received == null || f.providerPaid == null
                ? null
                : f.providerPaid == true
                    ? (f.billedMinor - received).clamp(0, f.billedMinor)
                    : 0;
    return MedicalBillViewState(
      billId: f.billId,
      arrangementLabel: direct ? MedicalCopy.insurerPay : MedicalCopy.selfPay,
      paymentMethod: f.method,
      sharePaymentLabel: f.needsReview || f.currency == null
          ? 'Needs review'
          : f.patientShareMinor == 0
              ? 'No payment needed'
              : f.shareSettlement == MedicalEvidence.confirmed
                  ? 'Recorded'
                  : f.shareSettlement == MedicalEvidence.notConfirmed
                      ? 'Not recorded'
                      : 'Not confirmed',
      insuranceShare: direct
          ? money(rejected ? 0 : f.billedMinor - f.patientShareMinor)
          : null,
      isFinalCost: f.closed &&
          !review &&
          (!direct ||
              (f.directProviderSettlement == MedicalEvidence.confirmed &&
                  (f.patientShareMinor == 0 ||
                      f.shareSettlement == MedicalEvidence.confirmed))),
      insuranceDeclined: rejected,
      isCancelled: f.cancelled,
      isEnteredInError: f.enteredInError,
      isClosed: f.closed,
      headline: headline,
      providerLabel: direct
          ? f.directProviderSettlement == MedicalEvidence.confirmed
              ? MedicalCopy.insurerPaid
              : MedicalCopy.providerUnknown
          : f.providerPaid == null
              ? MedicalCopy.providerUnknown
              : f.providerPaid!
                  ? MedicalCopy.providerPaid
                  : MedicalCopy.providerUnpaid,
      insuranceLabel: review
          ? MedicalCopy.needsReview
          : !direct && f.approvedMinor == 0
              ? 'No insurance refund'
              : rejected
                  ? MedicalCopy.declined
                  : f.cancelled
                      ? MedicalCopy.cancelled
                      : direct
                          ? headline
                          : f.approvedMinor != null
                              ? MedicalCopy.approvedRefund
                              : f.submission == MedicalSubmission.sent
                                  ? MedicalCopy.waitingReply
                                  : f.submission == MedicalSubmission.notSent
                                      ? MedicalCopy.notSent
                                      : MedicalCopy.sentUnknown,
      group: group,
      primaryAction: action,
      actionLabel: _actionLabel(action),
      actionEnabled: inspect || blocker == null,
      blocker: blocker,
      billTotal: money(f.billedMinor),
      userObligation: money(rejected ? f.billedMinor : f.patientShareMinor),
      expectedRefund:
          direct ? null : money(f.billedMinor - f.patientShareMinor),
      approvedRefund: direct ? null : money(f.approvedMinor),
      receivedRefund: direct ? null : money(received),
      remainingRefund: direct ? null : money(remaining),
      costSoFar: money(cost),
      estimatedFinalCost: money(review
          ? null
          : rejected
              ? f.billedMinor
              : direct
                  ? f.patientShareMinor
                  : f.cancelled
                      ? cost
                      : f.closed
                          ? cost
                          : f.approvedMinor == null
                              ? f.patientShareMinor
                              : (f.billedMinor - f.approvedMinor!)
                                  .clamp(0, f.billedMinor)),
      secondaryActions: direct
          ? [
              if (canSettle &&
                  f.patientShareMinor != 0 &&
                  f.shareSettlement != MedicalEvidence.confirmed &&
                  action != MedicalBillAction.recordShare)
                MedicalBillAction.recordShare,
            ]
          : !f.isShared &&
                  !review &&
                  !rejected &&
                  !f.closed &&
                  !f.cancelled &&
                  !f.enteredInError &&
                  canEdit &&
                  readiness.known &&
                  readiness.blockers.isEmpty
              ? [MedicalBillAction.recordReply, MedicalBillAction.setReminder]
                  .where((a) => a != action)
              : const [],
    );
  }

  String _actionLabel(MedicalBillAction action) => switch (action) {
        MedicalBillAction.recordPayment => MedicalCopy.recordPayment,
        MedicalBillAction.markAsSent => MedicalCopy.markAsSent,
        MedicalBillAction.recordReply => MedicalCopy.recordReply,
        MedicalBillAction.reviewIncomingMoney => MedicalCopy.incomingMoney,
        MedicalBillAction.recordInsurerPayment =>
          MedicalCopy.recordInsurerPayment,
        MedicalBillAction.recordShare => MedicalCopy.recordShare,
        MedicalBillAction.closeBill => MedicalCopy.closeBill,
        MedicalBillAction.setReminder => MedicalCopy.setReminder,
        MedicalBillAction.reviewBill => MedicalCopy.reviewChanges,
        MedicalBillAction.viewActivity => MedicalCopy.viewActivity,
        MedicalBillAction.legacyShared => MedicalCopy.legacyShared,
      };
}
