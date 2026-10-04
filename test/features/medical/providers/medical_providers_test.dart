import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/insurance_profile.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pure-function coverage for the derived aggregates the dashboard renders.
/// These need no Isar instance because they only read the bill objects handed
/// to them plus the joined expense statuses.
void main() {
  MedicalBill bill({
    int id = 1,
    required double billed,
    double coverage = 80,
    double reimbursed = 0,
    int? familyMemberId,
    int? expenseId = 100,
  }) {
    return MedicalBill()
      ..id = id
      ..billedAmount = billed
      ..insuranceCoveragePercent = coverage
      ..reimbursedAmount = reimbursed
      ..familyMemberId = familyMemberId
      ..linkedExpenseId = expenseId
      ..serviceDate = DateTime(2026, 1, 10);
  }

  group('DeductibleProgress', () {
    final insurance = InsuranceProfile()
      ..individualDeductible = 2000
      ..familyDeductible = 4000;

    test('no bills means an untouched individual bar', () {
      final progress = DeductibleProgress.from(
        bills: const [],
        insurance: insurance,
      );

      expect(progress.outOfPocketTotal, 0);
      expect(progress.billCount, 0);
      expect(progress.fractionOf(), 0);
      expect(progress.remainingFor(), 2000);
      expect(progress.hasInsuranceProfile, isTrue);
    });

    test('FR-006: a 1000 bill at 80% moves the bar by 200', () {
      final progress = DeductibleProgress.from(
        bills: [bill(billed: 1000)],
        insurance: insurance,
      );

      expect(progress.outOfPocketTotal, 200);
      expect(progress.fractionOf(), closeTo(0.1, 1e-9));
      expect(progress.remainingFor(), 1800);
      expect(progress.individualOutOfPocket, 200);
    });

    test('FR-006: a fully covered bill does not move the bar', () {
      final progress = DeductibleProgress.from(
        bills: [bill(billed: 1000, coverage: 100)],
        insurance: insurance,
      );

      expect(progress.outOfPocketTotal, 0);
      expect(progress.billedTotal, 1000);
    });

    test('out-of-pocket accumulates across bills in the same year', () {
      final progress = DeductibleProgress.from(
        bills: [
          bill(id: 1, billed: 1000, expenseId: 1),
          bill(id: 2, billed: 500, expenseId: 2),
        ],
        insurance: insurance,
      );

      expect(progress.outOfPocketTotal, 300);
      expect(progress.billedTotal, 1500);
      expect(progress.billCount, 2);
    });

    test('a reimbursable bill still counts what was estimated out-of-pocket',
        () {
      final progress = DeductibleProgress.from(
        bills: [bill(billed: 1000, reimbursed: 800)],
        insurance: insurance,
      );

      // Insurance money does not retroactively reduce what hit the deductible.
      expect(progress.outOfPocketTotal, 200);
      expect(progress.reimbursedTotal, 800);
    });

    test('family bills are excluded from the individual bar', () {
      final progress = DeductibleProgress.from(
        bills: [
          bill(id: 1, billed: 1000, expenseId: 1),
          bill(id: 2, billed: 1000, familyMemberId: 7, expenseId: 2),
        ],
        insurance: insurance,
      );

      expect(progress.outOfPocketTotal, 400);
      expect(progress.individualOutOfPocket, 200);
      expect(progress.fractionOf(), closeTo(0.1, 1e-9));
    });

    test('the bar caps at 100% once the limit is passed', () {
      final progress = DeductibleProgress.from(
        bills: [bill(billed: 12000)],
        insurance: insurance,
      );

      // 12000 billed at 80% leaves 2400 out of pocket against a 2000 limit.
      expect(progress.outOfPocketTotal, 2400);
      expect(progress.fractionOf(), 1);
      expect(progress.remainingFor(), 0);
      expect(progress.familyFraction(), closeTo(0.6, 1e-9));
    });

    test('an unset limit shows no progress instead of dividing by zero', () {
      final progress = DeductibleProgress.from(
        bills: [bill(billed: 1000)],
        insurance: InsuranceProfile(),
      );

      expect(progress.fractionOf(), 0);
      expect(progress.remainingFor(), 0);
    });

    test('a null insurance profile degrades gracefully', () {
      final progress = DeductibleProgress.from(
        bills: [bill(billed: 1000)],
        insurance: null,
      );

      expect(progress.outOfPocketTotal, 200);
      expect(progress.fractionOf(), 0);
    });
  });

  group('MedicalBudgetImpact', () {
    test('planned bills are not yet a budget cost (FR-004)', () {
      final impact = MedicalBudgetImpact.from(
        [bill(billed: 1000)],
        expenseStatuses: const {100: ExpenseStatus.planned},
      );

      expect(impact.plannedTotal, 1000);
      expect(impact.paidTotal, 0);
      expect(impact.netOutOfPocket, 0);
      expect(impact.hasPending, isTrue);
    });

    test('paying the provider makes the full billed amount due (FR-003)', () {
      final impact = MedicalBudgetImpact.from(
        [bill(billed: 1000)],
        expenseStatuses: const {100: ExpenseStatus.paid},
      );

      expect(impact.paidTotal, 1000);
      expect(impact.plannedTotal, 0);
      expect(impact.outOfPocketTotal, 200);
      // Nothing reimbursed yet, so the whole payment is still the user's cost.
      expect(impact.netOutOfPocket, 1000);
      expect(impact.hasPending, isFalse);
    });

    test('FR-005: a reimbursement cuts the net cost back to the estimate', () {
      final impact = MedicalBudgetImpact.from(
        [bill(billed: 1000, reimbursed: 800)],
        expenseStatuses: const {100: ExpenseStatus.paid},
      );

      expect(impact.reimbursedTotal, 800);
      expect(impact.netOutOfPocket, 200);
    });

    test('cancelled expenses leave the budget untouched', () {
      final impact = MedicalBudgetImpact.from(
        [bill(billed: 1000)],
        expenseStatuses: const {100: ExpenseStatus.cancelled},
      );

      expect(impact.paidTotal, 0);
      expect(impact.plannedTotal, 0);
      expect(impact.netOutOfPocket, 0);
    });

    test('a bill with no linked expense contributes nothing to the budget', () {
      final unbudgeted = bill(billed: 1000)..linkedExpenseId = null;

      final impact = MedicalBudgetImpact.from([unbudgeted]);

      expect(impact.paidTotal, 0);
      expect(impact.netOutOfPocket, 0);
      expect(impact.outOfPocketTotal, 200);
    });

    test('planned and paid bills are tracked separately in one view', () {
      final impact = MedicalBudgetImpact.from(
        [
          bill(id: 1, billed: 1000, expenseId: 1),
          bill(id: 2, billed: 250, expenseId: 2, reimbursed: 250),
        ],
        expenseStatuses: const {
          1: ExpenseStatus.planned,
          2: ExpenseStatus.paid,
        },
      );

      expect(impact.plannedTotal, 1000);
      expect(impact.paidTotal, 250);
      expect(impact.reimbursedTotal, 250);
      expect(impact.netOutOfPocket, 0);
      expect(impact.hasPending, isTrue);
    });

    test('an empty list is all zeroes', () {
      final impact = MedicalBudgetImpact.from(const []);
      expect(impact.plannedTotal, 0);
      expect(impact.paidTotal, 0);
      expect(impact.netOutOfPocket, 0);
      expect(impact.hasPending, isFalse);
    });
  });

  group('isPaidToProvider', () {
    test('reads the joined status of the linked expense', () {
      final subject = bill(billed: 100);

      expect(
        isPaidToProvider(subject, const {100: ExpenseStatus.paid}),
        isTrue,
      );
      expect(
        isPaidToProvider(subject, const {100: ExpenseStatus.planned}),
        isFalse,
      );
      expect(isPaidToProvider(subject, const {}), isFalse);
    });

    test('a bill with no expense is never considered paid', () {
      final unbudgeted = bill(billed: 100)..linkedExpenseId = null;
      expect(isPaidToProvider(unbudgeted, const {100: ExpenseStatus.paid}),
          isFalse);
    });
  });

  group('MedicalBill money math', () {
    test('coverage splits the bill into covered and out-of-pocket', () {
      final subject = bill(billed: 1000, coverage: 80);

      expect(subject.insuranceCoveredAmount, 800);
      expect(subject.estimatedOutPocket, 200);
    });

    test('net cost is the provider payment minus the payout', () {
      final subject = bill(billed: 1000, reimbursed: 800);

      expect(subject.netOutOfPocket, 200);
      expect(subject.patientShare, 200);
    });

    test('the patient share falls back to the estimate before any payout', () {
      final subject = bill(billed: 1000);

      expect(subject.netOutOfPocket, 1000);
      expect(subject.patientShare, 200);
    });

    test('net cost never goes negative on an overpayment', () {
      final subject = bill(billed: 1000, reimbursed: 1200);

      expect(subject.netOutOfPocket, 0);
      expect(subject.patientShare, 0);
    });
  });

  group('ClaimStatusLabel', () {
    test('unclaimed and processing are worth following up on', () {
      expect(ClaimStatus.unclaimed.isPending, isTrue);
      expect(ClaimStatus.processing.isPending, isTrue);
      expect(ClaimStatus.reimbursed.isPending, isFalse);
      expect(ClaimStatus.denied.isPending, isFalse);
    });

    test('every status has a human label', () {
      for (final status in ClaimStatus.values) {
        expect(status.label, isNotEmpty);
      }
    });
  });
}
