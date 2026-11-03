import '../models/reconciliation_snapshot.dart';
import '../models/balance_checkpoint.dart';
import '../models/fx_revision.dart';
import 'free_funds.dart';

/// Pure, unwired foundation. Never reads source estimates, performs a transfer,
/// confirms a receipt or makes all opening cash spendable. New receipt policy
/// must explicitly normalise its inputs in the later approved delivery.
class ReceiptReconciliationService {
  const ReceiptReconciliationService();

  /// Validates that a withholding match creates no additional cash movement.
  ///
  /// The withheld share is already part of the net salary receipt; linking it
  /// to a Medical bill must not create a second cash event, a fake refund or
  /// a duplicate deduction. Returns true when the match is zero-additional-cash.
  static bool isZeroAdditionalCash(int withheldMinor, int salaryTotalMinor) {
    // The withheld amount must be positive and must not exceed the salary total.
    if (withheldMinor <= 0 || withheldMinor > salaryTotalMinor) return false;
    // The match itself creates no cash: the salary was already recorded at its
    // net amount and the Medical cost was already recorded. The link is a
    // classification only.
    return true;
  }

  /// Derive bank cash once. Cost/funding facts remain separate and are never
  /// erased because a payment was already reflected in the reviewed balance.
  CashReviewResult reviewCash(
      {required int? balanceMinor,
      required DateTime balanceAsOf,
      required DateTime asOf,
      required List<CashMovement> movements,
      required List<MovementChoice> choices}) {
    final blockers = <String>{};
    final byKey = <String, MovementChoice>{};
    for (final choice in choices) {
      if (byKey.containsKey(choice.key)) blockers.add('duplicateMovement');
      byKey[choice.key] = choice;
    }
    if (balanceMinor == null) blockers.add('missingBalance');
    if (balanceAsOf.isAfter(asOf)) blockers.add('futureBalance');
    var includedCredit = 0, includedDebit = 0, laterCredit = 0, laterDebit = 0;
    final keys = <String>{};
    for (final movement in movements) {
      if (!keys.add(movement.key)) blockers.add('duplicateMovement');
      checkedFxMinor(movement.signedMinor);
      final choice = byKey[movement.key];
      if (choice == null || choice.revision != movement.revision) {
        blockers.add('movementNeedsReview');
        continue;
      }
      if (!{'included', 'later', 'outside'}.contains(choice.role)) {
        blockers.add('invalidInclusion');
        continue;
      }
      if (choice.role == 'outside') continue;
      final actual = movement.actualAt ?? choice.actualAt;
      if (actual == null ||
          (movement.actualAt != null &&
              choice.actualAt != null &&
              !movement.actualAt!.isAtSameMomentAs(choice.actualAt!))) {
        blockers.add('paymentDateNeedsReview');
        continue;
      }
      if (actual.isAfter(asOf)) {
        blockers.add('futurePayment');
        continue;
      }
      if (choice.role == 'included' && actual.isAfter(balanceAsOf)) {
        blockers.add('afterCheckpointIncluded');
        continue;
      }
      if (choice.role == 'later' && !actual.isAfter(balanceAsOf)) {
        blockers.add('beforeCheckpointNotIncluded');
        continue;
      }
      final amount = movement.signedMinor.abs();
      if (choice.role == 'included') {
        if (movement.signedMinor >= 0) {
          includedCredit = sumFinancialMinor([includedCredit, amount]);
        } else {
          includedDebit = sumFinancialMinor([includedDebit, amount]);
        }
      } else {
        if (movement.signedMinor >= 0) {
          laterCredit = sumFinancialMinor([laterCredit, amount]);
        } else {
          laterDebit = sumFinancialMinor([laterDebit, amount]);
        }
      }
    }
    if (byKey.keys.any((key) => !keys.contains(key))) {
      blockers.add('unknownMovement');
    }
    if (balanceMinor != null) checkedFxMinor(balanceMinor);
    return CashReviewResult(
        bankMinor: blockers.isEmpty
            ? sumFinancialMinor([balanceMinor!, laterCredit, -laterDebit])
            : null,
        includedCreditMinor: includedCredit,
        includedDebitMinor: includedDebit,
        laterCreditMinor: laterCredit,
        laterDebitMinor: laterDebit,
        blockers: blockers);
  }

  /// Trusted normalizers supply already-deduplicated funding and protected
  /// future claims. A date inclusion changes cash, never expense cost or income
  /// classification. Reserved money is deducted once, never added as income.
  ReconciliationSnapshot reconcileReviewed(
      {required ReconciliationInputs facts,
      required CashReviewResult cash,
      int reservedFundingMinor = 0}) {
    checkedFxMinor(reservedFundingMinor);
    if (reservedFundingMinor < 0) {
      throw const FormatException('Invalid reserved funds.');
    }
    final base = reconcile(facts);
    final ready = cash.blockers.isEmpty &&
        cash.bankMinor != null &&
        base.readiness == ReconciliationReadiness.ready;
    return ReconciliationSnapshot(
        currency: base.currency,
        readiness: ready
            ? ReconciliationReadiness.ready
            : ReconciliationReadiness.needsReview,
        bankMinor: ready ? cash.bankMinor : null,
        freeToSpendMinor: ready
            ? sumFinancialMinor([base.freeToSpendMinor!, -reservedFundingMinor])
            : null,
        reserveMinor: ready
            ? sumFinancialMinor([base.reserveMinor!, -reservedFundingMinor])
            : null,
        expectedIncomeMinor: base.expectedIncomeMinor,
        scheduledFundingMinor: base.scheduledFundingMinor,
        expenseCostMinor: base.expenseCostMinor);
  }

  ReconciliationSnapshot reconcile(ReconciliationInputs facts) {
    final nonnegative = [
      facts.eligibleIncomeMinor,
      facts.paidMinor,
      facts.returnedMinor,
      facts.unusedAllocationMinor,
      facts.allocatedMinor,
      facts.netDirectSpendingMinor,
      facts.cashCreditsAfterCheckpointMinor,
      facts.cashDebitsAfterCheckpointMinor,
      facts.carriedOutMinor,
      facts.carriedInMinor,
      facts.releasedMinor,
      facts.expectedIncomeMinor,
      facts.scheduledFundingMinor,
      facts.expenseCostMinor,
    ];
    for (final amount in nonnegative) {
      checkedFxMinor(amount);
      if (amount < 0) {
        throw const FormatException('A financial input needs review.');
      }
    }
    checkedFxMinor(facts.vaultPeriodCreditMinor);
    final checkpoint = facts.checkpointMinor;
    if (checkpoint != null) checkedFxMinor(checkpoint);
    final ready = checkpoint != null;
    final bank = ready
        ? sumFinancialMinor([
            checkpoint,
            facts.cashCreditsAfterCheckpointMinor,
            -facts.cashDebitsAfterCheckpointMinor,
          ])
        : null;
    final free = ready
        ? freeToSpend(
            income: facts.eligibleIncomeMinor,
            paid: facts.paidMinor,
            returned: facts.returnedMinor,
            unused: facts.unusedAllocationMinor,
            carry: facts.carriedOutMinor,
            incoming: facts.carriedInMinor,
            released: facts.releasedMinor,
            transfers: facts.vaultPeriodCreditMinor,
          ).toInt()
        : null;
    final reserve = ready
        ? sumFinancialMinor([
            facts.eligibleIncomeMinor,
            facts.vaultPeriodCreditMinor,
            facts.carriedInMinor,
            facts.releasedMinor,
            -facts.carriedOutMinor,
            -facts.allocatedMinor,
            -facts.netDirectSpendingMinor,
          ])
        : null;
    return ReconciliationSnapshot(
      currency: facts.currency,
      readiness: ready
          ? ReconciliationReadiness.ready
          : ReconciliationReadiness.needsReview,
      bankMinor: bank,
      freeToSpendMinor: free,
      reserveMinor: reserve,
      expectedIncomeMinor: facts.expectedIncomeMinor,
      scheduledFundingMinor: facts.scheduledFundingMinor,
      expenseCostMinor: facts.expenseCostMinor,
    );
  }
}
