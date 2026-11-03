import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/services/medical_receipt_booking_service.dart';
import 'package:budget_buddy/core/services/receipt_snapshot_repository.dart';
import 'package:budget_buddy/features/medical/presentation/medical_messages.dart';

void main() {
  const fallback =
      'Could not save or verify this claim. No new money was added. Please retry.';
  String message(String code) =>
      medicalReceiptMessage(MedicalReceiptException(code));

  test('a bill month without a budget says how to unblock it', () {
    expect(message('missingMonth'), isNot(fallback));
    expect(message('missingMonth'), contains('no budget yet'));
    expect(message('missingMonth'), contains('opening balance'));
  });

  test('an unconfirmed month opening says how to unblock it', () {
    expect(message('missingOpeningReview'), isNot(fallback));
    expect(message('missingOpeningReview'), contains('opening balance'));
  });

  test('every receipt code that can surface has its own message', () {
    const codes = [
      'missingMonth',
      'missingOpeningReview',
      'missingBill',
      'missingExpense',
      'missingAccountingConverter',
      'invalidReceipt',
      'invalidReceiptEvidence',
      'invalidBooking',
      'invalidMoney',
      'duplicateReceipt',
      'invalidOperation',
      'noChange',
      'paymentNotRecorded',
      'invalidTimezone',
      'invalidDestination',
      'finalReasonRequired',
      'invalidCorrection',
    ];
    for (final code in codes) {
      expect(message(code), isNot(fallback), reason: code);
    }
  });

  test('read-guard errors keep their code instead of collapsing', () {
    expect(medicalReceiptMessage(const ReceiptGuardException('invalidContext')),
        'Unlock the correct profile or space and reopen this bill.');
    expect(
        medicalReceiptMessage(const ReceiptGuardException('notActiveMember')),
        'Unlock the correct profile or space and reopen this bill.');
  });

  test('every MedicalReceiptException code surfaced in lib is mapped', () {
    const codes = [
      'invalidMoney',
      'invalidBooking',
      'foreignExcessNeedsReview',
      'invalidReceiptEvidence',
      'duplicateReceipt',
      'correctionReasonRequired',
      'wrongOwner',
      'billRemoved',
      'receivedCorrectionRequired',
      'invalidBillCorrection',
      'invalidOperation',
      'duplicateMismatch',
      'stalePreview',
      'accessChanged',
      'missingBill',
      'missingExpense',
      'legacyNeedsReview',
      'wrongOwner',
      'notPermitted',
      'invalidApproval',
      'claimCancelled',
      'insurerPaid',
      'claimClosed',
      'approvalNeedsReview',
      'paymentNotRecorded',
      'invalidReceipt',
      'invalidTimezone',
      'invalidDestination',
      'groupNeedsReview',
      'openingReviewRequired',
      'openingInclusionNeedsReview',
      'originalFxNeedsReview',
      'adoptionRequired',
      'peerUpgradeRequired',
      'useIncomeSources',
      'noChange',
      'invalidCorrection',
      'finalReasonRequired',
      'invalidClaimAction',
      'submissionAlreadyRecorded',
      'directoryBeforeCorrection',
      'billReviewRequired',
      'missingMonth',
      'missingOpeningReview',
      'missingAccountingConverter',
      'invalidMoney',
    ];
    for (final code in codes.toSet()) {
      expect(message(code), isNot(fallback), reason: code);
    }
  });
  test('existing messages are unchanged', () {
    expect(message('stalePreview'),
        'Information changed. Refresh the claim and review it again.');
    expect(message('claimClosed'),
        'This claim was explicitly closed. Its recorded final result is preserved.');
    expect(message('notARealCode'), fallback);
  });
}
