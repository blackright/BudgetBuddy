import '../../../core/services/balance_checkpoint_service.dart';
import '../../../core/services/income_receipt_service.dart';
import '../../../core/services/medical_receipt_service.dart';
import '../../../core/services/receipt_snapshot_repository.dart';
import '../../../core/services/salary_receipt_service.dart';

/// Codes that mean "this month cannot accept a receipt yet" and should be
/// shown as a preflight blocker instead of a generic failure.
const receiptBlockerCodes = {
  'accessChanged',
  'missingActor',
  'invalidContext',
  'notActiveMember',
  'wrongOwner',
  'missingMonth',
  'missingOpeningReview',
  'openingReviewRequired',
  'missingOpeningCheckpoint',
  'movementNeedsReview',
  'settledMonth',
  'settlementNeedsReview',
  'sweptMonth',
  'sealedMonth',
};

/// The exact code carried by a receipt exception, or an empty string.
String receiptErrorCode(Object error) {
  if (error is SalaryReceiptException) return error.code;
  if (error is IncomeReceiptException) return error.code;
  if (error is MedicalReceiptException) return error.code;
  if (error is ReceiptGuardException) return error.code;
  if (error is OpeningReviewException) return error.code;
  return '';
}

/// Human-readable, actionable text for a receipt failure.
String receiptErrorMessage(Object error) {
  final code = error is String ? error : receiptErrorCode(error);
  return switch (code) {
    'accessChanged' ||
    'missingActor' ||
    'invalidContext' ||
    'notActiveMember' =>
      'The app locked or the active profile changed. Unlock the correct profile and reopen this confirmation.',
    'wrongOwner' =>
      'This salary belongs to a different profile. Unlock the owner and reopen it.',
    'missingMonth' =>
      'This month is not open yet. Open the month, confirm its opening money, then retry.',
    'missingOpeningReview' =>
      'Confirm the opening money for this month first, then return to confirm the salary.',
    'openingReviewRequired' =>
      'This receipt does not match your last reviewed balance. Review the opening balance. If this money is already inside it, mark that in the confirmation and retry.',
    'missingOpeningCheckpoint' =>
      'This month needs its opening money reviewed before the salary can be recorded. Confirm the opening balance, then retry.',
    'movementNeedsReview' =>
      'A payment changed since the opening money review. Review the opening balance and its included payments before recording salary.',
    'settledMonth' =>
      'This month is already month-end settled. Review Month-End; a normal salary receipt cannot be added to a settled month.',
    'settlementNeedsReview' =>
      'A month-end run for this month is incomplete or conflicted. Review Month-End before confirming salary.',
    'sweptMonth' =>
      'A Vault sweep already used this month’s leftover money. Review the Vault before adding salary.',
    'sealedMonth' =>
      'This month is closed by the rate seal. A late salary needs an audited correction; it cannot be added as a normal receipt.',
    'stalePreview' ||
    'claimNeedsReview' ||
    'approvalNeedsReview' =>
      'Something changed while this sheet was open. Reopen the confirmation and review it again.',
    'alreadyConfirmed' => 'This salary cycle was already confirmed.',
    'salaryUsesSalaryFlow' =>
      'Salary uses the salary confirmation flow. Open the salary action.',
    'invalidAmount' ||
    'invalidCorrection' =>
      'Enter a valid amount and a receipt date that is not in the future.',
    'missingSource' ||
    'missingCycle' =>
      'This salary source or expected month no longer exists. Reopen Income Sources.',
    'invalidTimezone' =>
      'The receipt timezone could not be read. Check the device timezone and retry.',
    'duplicateMismatch' =>
      'A different receipt was already saved for this salary period.',
    'unsupportedCurrency' =>
      'This salary uses a currency that cannot be recorded here.',
    'medicalReceiptMoved' =>
      'Medical refunds are recorded in the Medical bill, not in salary confirmation.',
    'currencyMismatch' => 'Salary must use the budget accounting currency.',
    'invalidConfirmation' ||
    'componentMismatch' =>
      'Check the actual salary and bank total.',
    'adoptionRequired' =>
      'Review your starting money before confirming actual receipts.',
    'groupNeedsReview' =>
      'An earlier bank credit has incomplete or changed component records. Review it before recording more money.',
    'originalFxNeedsReview' =>
      'The original currency or booked exchange rate needs review. No conversion is guessed.',
    _ =>
      'This receipt was blocked before saving. Review Month-End, Vault or the opening balance, then retry.',
  };
}

/// A debug-only detail line. Never includes a stack trace in the UI.
String receiptErrorDetails(Object error) {
  final code = error is String ? error : receiptErrorCode(error);
  if (code.isNotEmpty) return code;
  return error.runtimeType.toString();
}

/// Where the user can go to resolve a blocker.
String? receiptBlockerRoute(String code) => switch (code) {
      'settledMonth' ||
      'settlementNeedsReview' ||
      'sealedMonth' =>
        '/month_end',
      'sweptMonth' => '/vault',
      'missingMonth' ||
      'missingOpeningReview' ||
      'openingReviewRequired' =>
        '/dashboard',
      _ => null,
    };

/// Label for the blocker action.
String? receiptBlockerActionLabel(String code) => switch (code) {
      'settledMonth' ||
      'settlementNeedsReview' ||
      'sealedMonth' =>
        'Review Month-End',
      'sweptMonth' => 'Review Vault',
      'missingMonth' ||
      'missingOpeningReview' ||
      'openingReviewRequired' =>
        'Review opening balance',
      _ => null,
    };
