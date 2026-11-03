import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/balance_checkpoint.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/reconciliation_snapshot.dart';
import 'package:budget_buddy/core/services/receipt_reconciliation_service.dart';

void main() {
  const service = ReceiptReconciliationService();
  final cutoff = DateTime.utc(2026, 11, 1, 9);
  final now = DateTime.utc(2026, 11, 6);
  CashMovement movement(String key, int value, DateTime? date) => CashMovement(
      key: key,
      revision: 'v1',
      label: key,
      kind: 'receipt',
      signedMinor: value,
      actualAt: date);
  MovementChoice choice(String key, String role, DateTime date) =>
      MovementChoice(key: key, revision: 'v1', role: role, actualAt: date);

  test('included salary stays 600,000; later receipt adds once; cost retained',
      () {
    final salary = DateTime.utc(2026, 10, 25),
        payment = DateTime.utc(2026, 11, 1, 8);
    final later = DateTime.utc(2026, 11, 5);
    final result = service.reviewCash(
        balanceMinor: 600000,
        balanceAsOf: cutoff,
        asOf: now,
        movements: [
          movement('salary', 500000, salary),
          movement('payment', -10000, payment),
          movement('return', 5000, later)
        ],
        choices: [
          choice('salary', 'included', salary),
          choice('payment', 'included', payment),
          choice('return', 'later', later)
        ]);
    expect(result.bankMinor, 605000);
    expect(result.includedCreditMinor, 500000);
    expect(result.includedDebitMinor, 10000);
  });
  test(
      'pre-checkpoint omission and missing legacy date need review, never extra money',
      () {
    final earlier = DateTime.utc(2026, 10, 28);
    final result = service.reviewCash(
        balanceMinor: 600000,
        balanceAsOf: cutoff,
        asOf: now,
        movements: [movement('legacy', 5000, null)],
        choices: [choice('legacy', 'later', earlier)]);
    expect(result.bankMinor, isNull);
    expect(result.blockers, contains('beforeCheckpointNotIncluded'));
  });
  test('duplicate, changed, unreviewed and future cash facts are blocked', () {
    final m = movement('one', 100, now);
    for (final choices in <List<MovementChoice>>[
      [],
      [choice('one', 'later', now), choice('one', 'later', now)],
      [
        MovementChoice(
            key: 'one', revision: 'old', role: 'later', actualAt: now)
      ]
    ]) {
      expect(
          service
              .reviewCash(
                  balanceMinor: 0,
                  balanceAsOf: cutoff,
                  asOf: now,
                  movements: [m],
                  choices: choices)
              .bankMinor,
          isNull);
    }
    final future = now.add(const Duration(days: 1));
    expect(
        service.reviewCash(
            balanceMinor: 0,
            balanceAsOf: cutoff,
            asOf: now,
            movements: [movement('one', 100, future)],
            choices: [choice('one', 'later', future)]).bankMinor,
        isNull);
  });
  test('zero is valid; outside-pool payment does not change this bank balance',
      () {
    final result = service.reviewCash(
        balanceMinor: 0,
        balanceAsOf: cutoff,
        asOf: now,
        movements: [
          movement('cash', -100, null)
        ],
        choices: [
          const MovementChoice(key: 'cash', revision: 'v1', role: 'outside')
        ]);
    expect(result.bankMinor, 0);
    expect(
        service.reviewCash(
            balanceMinor: null,
            balanceAsOf: cutoff,
            asOf: now,
            movements: [],
            choices: []).bankMinor,
        isNull);
  });
  test(
      'future claims protect funding without treating opening balance as income',
      () {
    final cash = service.reviewCash(
        balanceMinor: 600000,
        balanceAsOf: cutoff,
        asOf: now,
        movements: [],
        choices: []);
    const facts = ReconciliationInputs(
        currency: CurrencyCode.huf,
        checkpointMinor: 600000,
        eligibleIncomeMinor: 500000,
        paidMinor: 10000,
        returnedMinor: 0,
        unusedAllocationMinor: 100000,
        allocatedMinor: 100000,
        netDirectSpendingMinor: 10000,
        expenseCostMinor: 10000);
    final result = service.reconcileReviewed(
        facts: facts, cash: cash, reservedFundingMinor: 20000);
    expect(result.bankMinor, 600000);
    expect(result.freeToSpendMinor, 370000);
    expect(result.expenseCostMinor, 10000);
  });
}
