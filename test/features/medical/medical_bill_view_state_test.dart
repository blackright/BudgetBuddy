import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/features/medical/presentation/medical_bill_view_state.dart';
import 'package:budget_buddy/features/medical/presentation/medical_bill_state_resolver.dart';

void main() {
  const resolver = MedicalBillStateResolver();
  MedicalBillFacts facts({
    MedicalPaymentMethod method = MedicalPaymentMethod.selfPaid,
    bool paid = true,
    MedicalSubmission submission = MedicalSubmission.unknown,
    int? approved,
    int? received = 0,
    bool review = false,
    bool cancelled = false,
    bool removed = false,
    bool closed = false,
    int shortfall = 0,
    bool rejected = false,
    bool shared = false,
    MedicalBillState legacyState = MedicalBillState.paid,
    MedicalEvidence provider = MedicalEvidence.unknown,
    MedicalEvidence share = MedicalEvidence.unknown,
    int patientShare = 2000,
    DateTime? followUp,
  }) =>
      MedicalBillFacts(
        billId: 1,
        billGuid: 'bill-1',
        method: method,
        legacyState: rejected ? MedicalBillState.rejected : legacyState,
        isShared: shared,
        currency: CurrencyCode.huf,
        billedMinor: 10000,
        patientShareMinor: patientShare,
        providerPaid: paid,
        submission: submission,
        approvedMinor: approved,
        receivedMinor: received,
        needsReview: review,
        cancelled: cancelled,
        enteredInError: removed,
        closed: closed,
        shortfallMinor: shortfall,
        directProviderSettlement: provider,
        shareSettlement: share,
        followUp: followUp,
      );
  MedicalBillViewState resolve(MedicalBillFacts input,
          {bool canEdit = true, MedicalReadiness? readiness}) =>
      resolver.resolve(
        input,
        canEdit: canEdit,
        readiness: readiness ?? MedicalReadiness.ready(),
        now: DateTime(2026, 10, 30),
      );

  test('linked expense payment wins over a recorded decision', () {
    final state = resolve(facts(paid: false, approved: 8000));
    expect(state.primaryAction, MedicalBillAction.recordPayment);
    expect(state.providerLabel, 'Provider not paid');
    expect(state.approvedRefund?.minorUnits, 8000);
    expect(state.costSoFar?.minorUnits, 0);
  });
  test('old unknown submission is not called never sent', () {
    final old = resolve(facts());
    expect(old.headline, 'Sent date not recorded');
    expect(old.secondaryActions, contains(MedicalBillAction.recordReply));
    expect(() => old.secondaryActions.add(MedicalBillAction.recordPayment),
        throwsUnsupportedError);
    final state = resolve(facts(submission: MedicalSubmission.notSent));
    expect(state.headline, 'Claim not sent');
    expect(state.primaryAction, MedicalBillAction.markAsSent);
  });
  test('D1 decision without submission enables guarded incoming navigation',
      () {
    final state = resolve(facts(approved: 7500));
    expect(state.primaryAction, MedicalBillAction.reviewIncomingMoney);
    expect(state.actionEnabled, true);
    expect(state.remainingRefund?.minorUnits, 7500);
  });
  test('received partial legacy facts are shown as waiting for payslip', () {
    final state = resolve(facts(approved: 7500, received: 6000));
    expect(state.headline, 'Waiting for payslip');
    expect(state.expectedRefund?.minorUnits, 8000);
    expect(state.approvedRefund?.minorUnits, 7500);
    expect(state.receivedRefund?.minorUnits, 6000);
    expect(state.remainingRefund?.minorUnits, 1500);
    expect(state.costSoFar?.minorUnits, 4000);
    expect(state.estimatedFinalCost?.minorUnits, 2500);
  });
  test('D1 fully received offers explicit closure without auto closing', () {
    final state = resolve(facts(approved: 8000, received: 8000));
    expect(state.headline, 'Ready to close');
    expect(state.primaryAction, MedicalBillAction.closeBill);
    expect(state.actionEnabled, true);
    expect(state.group, MedicalInboxGroup.needsYou);
  });
  test('historical shortfall closure remains read-only without a refund', () {
    final state = resolve(
        facts(approved: 8000, received: 6000, closed: true, shortfall: 2000));
    expect(state.headline, 'Closed');
    expect(state.group, MedicalInboxGroup.closed);
    expect(state.costSoFar?.minorUnits, 4000);
    expect(state.remainingRefund?.minorUnits, 2000);
  });
  test('cancelled claim with unpaid provider still needs attention', () {
    final state = resolve(facts(cancelled: true, paid: false));
    expect(state.group, MedicalInboxGroup.needsYou);
    expect(state.providerLabel, 'Provider not paid');
    expect(state.primaryAction, MedicalBillAction.reviewBill);
    expect(state.actionEnabled, false);
  });
  test('paid cancelled claim preserves cost and original refund facts', () {
    final state = resolve(facts(cancelled: true));
    expect(state.headline, 'Claim cancelled');
    expect(state.group, MedicalInboxGroup.closed);
    expect(state.costSoFar?.minorUnits, 10000);
  });
  test('entered in error is retained rather than presented as paid', () {
    final state = resolve(facts(removed: true));
    expect(state.headline, 'Bill added by mistake');
    expect(state.group, MedicalInboxGroup.closed);
    expect(state.primaryAction, MedicalBillAction.viewActivity);
  });
  test('unknown received money never becomes a zero refund', () {
    final state = resolve(facts(approved: 8000, received: null));
    expect(state.headline, 'Needs review');
    expect(state.receivedRefund, isNull);
    expect(state.remainingRefund, isNull);
    expect(state.costSoFar, isNull);
  });
  test('review supersedes complete-looking money', () {
    final state = resolve(facts(approved: 8000, received: 8000, review: true));
    expect(state.headline, 'Needs review');
    expect(state.primaryAction, MedicalBillAction.reviewBill);
  });
  test('submitted waits until follow-up is due, not money inferred by time',
      () {
    final state = resolve(facts(submission: MedicalSubmission.sent));
    expect(state.group, MedicalInboxGroup.waiting);
    expect(state.primaryAction, MedicalBillAction.setReminder);
    final due = resolve(facts(
        submission: MedicalSubmission.sent, followUp: DateTime(2026, 10, 29)));
    expect(due.group, MedicalInboxGroup.needsYou);
    expect(due.receivedRefund?.minorUnits, 0);
  });
  test('readiness error and read-only disable commands without lying', () {
    final unknown =
        resolve(facts(paid: false), readiness: MedicalReadiness.unknown());
    expect(unknown.actionEnabled, false);
    expect(unknown.blocker, isNotEmpty);
    final readonly = resolve(facts(paid: false), canEdit: false);
    expect(readonly.actionEnabled, false);
    expect(readonly.providerLabel, 'Provider not paid');
  });
  for (final state in [MedicalBillState.waiting, MedicalBillState.paid]) {
    test('direct insurer $state does not prove separate share settlement', () {
      final result = resolve(
          facts(method: MedicalPaymentMethod.insurerPaid, legacyState: state));
      expect(result.headline, 'Needs review');
      expect(result.expectedRefund, isNull);
      expect(result.receivedRefund, isNull);
      expect(result.primaryAction, MedicalBillAction.reviewBill);
      expect(result.actionEnabled, false);
    });
  }
  test('synthetic direct evidence enables the D2 close action', () {
    final state = resolve(facts(
        method: MedicalPaymentMethod.insurerPaid,
        provider: MedicalEvidence.confirmed,
        share: MedicalEvidence.confirmed));
    expect(state.headline, 'Ready to close');
    expect(state.actionEnabled, true);
    expect(state.primaryAction, MedicalBillAction.closeBill);
  });
  test('direct bill shows the booked patient share as cost so far', () {
    final state = resolve(facts(
        method: MedicalPaymentMethod.insurerPaid,
        provider: MedicalEvidence.confirmed,
        share: MedicalEvidence.notConfirmed));
    expect(state.costSoFar?.minorUnits, 2000);
    expect(state.estimatedFinalCost?.minorUnits, 2000);
    expect(state.expectedRefund, isNull);
    expect(state.receivedRefund, isNull);
  });
  test('direct zero share shows zero cost, not missing cost', () {
    final state = resolve(facts(
        method: MedicalPaymentMethod.insurerPaid,
        patientShare: 0,
        provider: MedicalEvidence.confirmed,
        share: MedicalEvidence.confirmed));
    expect(state.costSoFar?.minorUnits, 0);
    expect(state.estimatedFinalCost?.minorUnits, 0);
  });
  test('legacy direct evidence still shows no invented cost so far', () {
    final state = resolve(facts(
        method: MedicalPaymentMethod.insurerPaid,
        legacyState: MedicalBillState.paid));
    expect(state.headline, 'Needs review');
    expect(state.costSoFar, isNull);
  });
  test('zero share needs no fake payment while provider evidence is required',
      () {
    final state = resolve(facts(
        method: MedicalPaymentMethod.insurerPaid,
        patientShare: 0,
        provider: MedicalEvidence.confirmed));
    expect(state.headline, 'Ready to close');
    expect(state.receivedRefund, isNull);
  });
  test('rejection shows full obligation without asserting user payment', () {
    final state = resolve(
        facts(method: MedicalPaymentMethod.insurerPaid, rejected: true));
    expect(state.headline, 'Insurance declined');
    expect(state.userObligation?.minorUnits, 10000);
    expect(state.costSoFar, isNull);
    expect(state.group, MedicalInboxGroup.needsYou);
  });
  test('shared bill stays on legacy workflow, no private claim action', () {
    final state = resolve(facts(shared: true, approved: 8000));
    expect(state.primaryAction, MedicalBillAction.legacyShared);
    expect(state.actionEnabled, false);
  });
  test('whole original charge at 100 percent has no expected refund', () {
    expect(resolve(facts(patientShare: 10000)).expectedRefund?.minorUnits, 0);
  });
}
