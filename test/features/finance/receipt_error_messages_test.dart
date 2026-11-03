import 'package:budget_buddy/core/services/balance_checkpoint_service.dart';
import 'package:budget_buddy/core/services/income_receipt_service.dart';
import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import 'package:budget_buddy/core/services/receipt_snapshot_repository.dart';
import 'package:budget_buddy/core/services/salary_receipt_service.dart';
import 'package:budget_buddy/features/finance/presentation/receipt_errors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every receipt blocker has a specific, non-generic message', () {
    for (final code in const [
      'settledMonth',
      'settlementNeedsReview',
      'sweptMonth',
      'sealedMonth',
      'missingMonth',
      'missingOpeningReview',
      'openingReviewRequired',
      'missingOpeningCheckpoint',
      'movementNeedsReview',
      'accessChanged',
    ]) {
      final message = receiptErrorMessage(code);
      expect(message, isNot(contains('could not be verified')), reason: code);
      expect(message, isNotEmpty, reason: code);
    }
  });

  test('blocker actions point at the feature that can resolve them', () {
    expect(receiptBlockerRoute('settledMonth'), '/month_end');
    expect(receiptBlockerRoute('settlementNeedsReview'), '/month_end');
    expect(receiptBlockerRoute('sweptMonth'), '/vault');
    expect(receiptBlockerRoute('openingReviewRequired'), '/dashboard');
    expect(receiptBlockerActionLabel('sweptMonth'), 'Review Vault');
    expect(receiptBlockerRoute('accessChanged'), isNull);
  });

  test('error codes are extracted from all receipt exception types', () {
    expect(receiptErrorCode(const SalaryReceiptException('stalePreview')),
        'stalePreview');
    expect(receiptErrorCode(const IncomeReceiptException('invalidTimezone')),
        'invalidTimezone');
    expect(receiptErrorCode(const MedicalReceiptException('groupNeedsReview')),
        'groupNeedsReview');
    expect(receiptErrorCode(const ReceiptGuardException('accessChanged')),
        'accessChanged');
    expect(
        receiptErrorCode(
            const OpeningReviewException('missingOpeningCheckpoint')),
        'missingOpeningCheckpoint');
    expect(receiptErrorCode(StateError('plain')), '');
  });

  test('unknown errors stay generic but expose their type as debug detail', () {
    final error = StateError('plain');
    expect(receiptErrorMessage(error), contains('blocked before saving'));
    expect(receiptErrorDetails(error), 'StateError');
    expect(receiptErrorDetails('settledMonth'), 'settledMonth');
  });
}
