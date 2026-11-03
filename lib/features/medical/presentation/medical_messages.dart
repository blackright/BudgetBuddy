import '../../../core/services/medical_receipt_service.dart';
import '../../../core/services/medical_settlement_service.dart';
import '../../../core/services/medical_withholding_service.dart';
import '../../../core/services/receipt_snapshot_repository.dart';

String _medicalErrorCode(Object error) => switch (error) {
      MedicalReceiptException(:final code) => code,
      ReceiptGuardException(:final code) => code,
      MedicalSettlementException(:final code) => code,
      MedicalWithholdingException(:final code) => code,
      _ => '',
    };

String medicalReceiptMessage(Object error) =>
    switch (_medicalErrorCode(error)) {
      'accessChanged' ||
      'wrongOwner' ||
      'notPermitted' ||
      'invalidContext' ||
      'missingActor' ||
      'notActiveMember' =>
        'Unlock the correct profile or space and reopen this bill.',
      'insurerPaid' =>
        'The insurer paid the provider directly. There is no refund to add to your money.',
      'invalidApproval' ||
      'approvalNeedsReview' =>
        'Check the insurer\'s approved amount and date. Received money cannot exceed the recorded approval without reviewing that decision.',
      'directoryBeforeCorrection' =>
        'Add the new provider or person to your Medical directory first, then review this approved bill correction.',
      'invalidBillCorrection' =>
        'Check the bill amount, currency and coverage before reviewing this correction.',
      'invalidClaimAction' =>
        'Check the submission date or cancellation reason.',
      'claimCancelled' =>
        'This claim is cancelled. Its original bill and history are retained.',
      'billRemoved' =>
        'This bill is retained as entered in error and cannot be changed through ordinary controls.',
      'billReviewRequired' =>
        'Use Review correction to change an approved bill or review its removal.',
      'receivedCorrectionRequired' =>
        'Money is already recorded as received. A financial reconciliation is required; ordinary bill changes or cancellation cannot erase it.',
      'correctionReasonRequired' =>
        'Enter a short reason for the reviewed change.',
      'submissionAlreadyRecorded' =>
        'Submission or an insurer decision is already recorded.',
      'claimClosed' =>
        'This claim was explicitly closed. Its recorded final result is preserved.',
      'providerNotConfirmed' =>
        'Record the insurer\'s payment to the provider before closing.',
      'shareNotRecorded' =>
        'Record your share, or link the salary withholding, before closing.',
      'alreadyConfirmed' ||
      'alreadyPending' ||
      'alreadySettled' ||
      'alreadyClosed' ||
      'alreadyMatched' ||
      'alreadyReversed' =>
        'This fact is already recorded. Refresh the bill to see it.',
      'partialUnsupported' =>
        'This release records one full share payment. Partial or mixed evidence stays Needs review.',
      'overmatched' => 'The amount is more than the eligible share.',
      'zeroShare' => 'There is no share to record for this bill.',
      'currencyMismatch' ||
      'receiptNotFound' ||
      'staleEligibility' =>
        'Choose a current salary receipt in the bill\'s currency and refresh the eligible share.',
      'futureDate' => 'Choose a date that is not in the future.',
      'stalePreview' ||
      'duplicateMismatch' =>
        'Information changed. Refresh the claim and review it again.',
      'sealedMonth' ||
      'settledMonth' ||
      'sweptMonth' ||
      'settlementNeedsReview' =>
        'A payment month is closed or already processed. No money was changed.',
      'openingReviewRequired' ||
      'adoptionRequired' ||
      'openingInclusionNeedsReview' =>
        'Review receipt setup and any unresolved opening-money information first.',
      'foreignExcessNeedsReview' ||
      'originalFxNeedsReview' =>
        'The original currency evidence needs review. No exchange rate or partial payment was guessed.',
      'peerUpgradeRequired' =>
        'Shared receipt confirmation needs compatible paired apps. Existing recorded money is unchanged.',
      'groupNeedsReview' ||
      'useIncomeSources' =>
        'Confirm or correct received money through the completed Income Sources flow.',
      'legacyNeedsReview' =>
        'An older payment needs review. Its recorded amount and history have been preserved.',
      'missingMonth' =>
        'This bill belongs to a month that has no budget yet. Open that month, set its opening balance, then review again.',
      'missingOpeningReview' =>
        'This bill\'s month still needs its opening balance confirmed. Open that month, confirm the starting money, then review again.',
      'missingBill' =>
        'This bill is no longer available. It may have been removed on another device.',
      'missingExpense' =>
        'This bill is not correctly linked to its budget expense. Reopen it from the profile that owns it.',
      'missingAccountingConverter' =>
        'This bill\'s currency needs a recorded exchange rate before it can be reviewed.',
      'invalidReceipt' ||
      'invalidReceiptEvidence' ||
      'invalidBooking' ||
      'invalidMoney' =>
        'Check the receipt amount, date and currency. Nothing was recorded.',
      'duplicateReceipt' => 'This receipt is already recorded for the claim.',
      'closureNeedsReview' =>
        'Record the provider payment and final insurance reply, then review any changed information before closing.',
      'moneyStillMissing' =>
        'Money is still outstanding. Record the receipt or explicitly accept a final shortfall.',
      'invalidOperation' =>
        'This request could not be matched to the saved claim action. Refresh the claim and try again.',
      'noChange' => 'Nothing changed, so there was nothing to save.',
      'paymentNotRecorded' =>
        'Record the payment to the provider first. An insurer refund needs a paid bill.',
      'invalidTimezone' =>
        'This bill\'s saved time zone is not recognised. Review the bill and save it again.',
      'invalidDestination' =>
        'Choose the month that contains the received date.',
      'finalReasonRequired' => 'Enter a short reason for closing the claim.',
      'invalidCorrection' =>
        'Check the corrected amount, date, month and reason.',
      _ =>
        'Could not save or verify this claim. No new money was added. Please retry.',
    };
