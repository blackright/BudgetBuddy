/// User-facing terminology for the new Medical presentation foundation.
/// Stored enums and legacy screen copy are intentionally unchanged in Phase A.
abstract final class MedicalCopy {
  static const selfPay = 'I pay the provider';
  static const insurerPay = 'Insurance pays the provider';
  static const insurerPayHelp =
      'Insurance pays the provider directly. You cover your share.';
  static const yourShare = 'Your share';
  static const insuranceCoverage = 'Insurance coverage';
  static const coverageHelp =
      'The share of the bill insurance is expected to cover.';
  static const expectedInsuranceRefund = 'Expected insurance refund';
  static const insurancePaysProviderAmount = 'Insurance pays the provider';
  static const plannedBudgetEffect = 'Planned Budget Effect';
  static const creationMovesNoMoney =
      'Creating a bill plans it only. No money moves until you record a '
      'payment or an insurance reply in bill details.';
  static const refund = 'Insurance refund';
  static const approvedRefund = 'Approved refund';
  static const received = 'Money received';
  static const stillToReceive = 'Still to receive';
  static const shareLeft = 'Share left to pay';
  static const recordPayment = 'Record payment';
  static const markAsSent = 'Submit request';
  static const recordReply = 'Record insurance reply';
  static const incomingMoney = 'Review incoming money';
  static const closeBill = 'Close bill';
  static const takenFromSalary = 'Taken from salary';
  static const reviewChanges = 'Review changes';
  static const mistake = 'Bill added by mistake';
  static const needsReview = 'Needs review';
  static const providerUnpaid = 'Provider not paid';
  static const providerPaid = 'Provider paid';
  static const providerUnknown = 'Provider payment not confirmed';
  static const notSent = 'Claim not sent';
  static const sentUnknown = 'Sent date not recorded';
  static const waitingReply = 'Waiting for insurance reply';
  static const waitingRefund = 'Waiting for insurance refund';
  static const waitingPayslip = 'Waiting for payslip';
  static const readyToClose = 'Ready to close';
  static const closed = 'Closed';
  static const cancelled = 'Claim cancelled';
  static const declined = 'Insurance declined';
  static const waitingInsurer = 'Waiting for insurance to pay';
  static const shareNeedsRecording = 'Your share needs recording';
  static const insurerPaid = 'Insurance paid the provider';
  static const recordInsurerPayment = 'Record insurance payment';
  static const recordShare = 'Record your share';
  static const setReminder = 'Set reminder';
  static const viewActivity = 'View activity';
  static const legacyShared = 'Open bill';
  static const sentHelp =
      'Record when you sent the claim. BudgetBuddy does not send it for you.';
  static const paymentHelp =
      'Record a payment you made. No money is sent from this app.';
  static const readinessUnknown = 'Month readiness could not be confirmed.';
  static const monthBlocked = 'Review this month before recording a payment.';
  static const futureAction = 'Shared bills keep their existing controls.';
  static const reviewHelp = 'Review the recorded facts before continuing.';
  static const readOnly = 'This bill is read-only.';
}
