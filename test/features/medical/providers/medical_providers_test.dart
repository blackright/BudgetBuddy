import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pure-function coverage for the derived aggregates the dashboard renders.
/// These need no Isar instance because they only read the bill objects handed
/// to them plus the joined expense statuses.
void main() {
  /// A bill with the US2 model in mind: a 20% patient share is the default, so
  /// most tests only vary what they actually care about.
  MedicalBill bill({
    int id = 1,
    required double billed,
    double patientShare = 20,
    double reimbursed = 0,
    MedicalPaymentMethod method = MedicalPaymentMethod.insurerPaid,
    MedicalBillState state = MedicalBillState.waiting,
    int? familyMemberId,
    int? expenseId = 100,
  }) {
    return MedicalBill()
      ..id = id
      ..billedAmount = billed
      ..patientSharePercent = patientShare
      ..reimbursedAmount = reimbursed
      ..paymentMethod = method
      ..state = state
      ..familyMemberId = familyMemberId
      ..linkedExpenseId = expenseId
      ..serviceDate = DateTime(2026, 1, 10);
  }

  group('PatientShareTotals', () {
    test('no bills yields an empty aggregate', () {
      final totals = PatientShareTotals.from(const []);

      expect(totals.isEmpty, isTrue);
      expect(totals.billCount, 0);
      expect(totals.billedTotal, 0);
      expect(totals.patientShareTotal, 0);
      expect(totals.insurerPaidTotal, 0);
      expect(totals.reimbursedTotal, 0);
      expect(totals.netPatientCost, 0);
    });

    test('FR-048: the share is the user\'s, so 1000 at 20% leaves them 200',
        () {
      final totals = PatientShareTotals.from([bill(billed: 1000)]);

      expect(totals.billedTotal, 1000);
      expect(totals.patientShareTotal, 200);
      expect(totals.insurerPaidTotal, 800);
      expect(totals.billCount, 1);
      expect(totals.isEmpty, isFalse);
    });

    test('the split accumulates across every bill in the month', () {
      final totals = PatientShareTotals.from([
        bill(id: 1, billed: 1000, expenseId: 1),
        bill(id: 2, billed: 500, expenseId: 2),
      ]);

      expect(totals.billedTotal, 1500);
      expect(totals.patientShareTotal, 300);
      expect(totals.insurerPaidTotal, 1200);
      expect(totals.billCount, 2);
    });

    test('a self-paid bill still shows the share arithmetic', () {
      final totals = PatientShareTotals.from([
        bill(
          billed: 1000,
          method: MedicalPaymentMethod.selfPaid,
          state: MedicalBillState.finished,
        ),
      ]);

      // The totals are descriptive: who paid what on the bill itself. What the
      // budget felt is `fundsImpact`, covered separately.
      expect(totals.patientShareTotal, 200);
      expect(totals.insurerPaidTotal, 800);
    });

    test('a reimbursement reduces the net cost but not the original share', () {
      final totals = PatientShareTotals.from([
        bill(billed: 1000, reimbursed: 800, state: MedicalBillState.finished),
      ]);

      // Money that came back does not retroactively change what was billed.
      expect(totals.patientShareTotal, 200);
      expect(totals.reimbursedTotal, 800);
      expect(totals.netPatientCost, 200);
    });

    test('FR-037: there is no deductible limit, so nothing is ever excluded',
        () {
      final totals = PatientShareTotals.from([
        bill(id: 1, billed: 1000, expenseId: 1),
        bill(id: 2, billed: 1000, familyMemberId: 7, expenseId: 2),
      ]);

      // A family member used to be filtered out of an "individual" bar. With no
      // deductible there is nothing to exclude, so both bills count.
      expect(totals.billedTotal, 2000);
      expect(totals.patientShareTotal, 400);
      expect(totals.billCount, 2);
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

    test('FR-042: an insurer-paid bill costs only the patient share', () {
      final impact = MedicalBudgetImpact.from(
        [bill(billed: 1000)],
        expenseStatuses: const {100: ExpenseStatus.paid},
      );

      expect(impact.paidTotal, 200);
      expect(impact.plannedTotal, 0);
      expect(impact.outOfPocketTotal, 200);
      // An insurer-paid bill never cost the full charge, so there is nothing to
      // give back: the net cost is the share all along.
      expect(impact.netOutOfPocket, 200);
      expect(impact.hasPending, isFalse);
    });

    test('FR-042: a self-paid bill costs the full charge', () {
      final impact = MedicalBudgetImpact.from(
        [
          bill(
            billed: 1000,
            method: MedicalPaymentMethod.selfPaid,
            state: MedicalBillState.waiting,
          ),
        ],
        expenseStatuses: const {100: ExpenseStatus.paid},
      );

      expect(impact.paidTotal, 1000);
      expect(impact.netOutOfPocket, 1000);
    });

    test('a planned bill never costs anything, whatever the method', () {
      final impact = MedicalBudgetImpact.from(
        [
          bill(
            billed: 1000,
            method: MedicalPaymentMethod.selfPaid,
            state: MedicalBillState.planned,
          ),
        ],
        expenseStatuses: const {100: ExpenseStatus.planned},
      );

      expect(impact.plannedTotal, 1000);
      expect(impact.paidTotal, 0);
      expect(impact.netOutOfPocket, 0);
    });

    test('FR-034: a reimbursement cuts the net cost back to the share', () {
      final impact = MedicalBudgetImpact.from(
        [
          bill(
            billed: 1000,
            reimbursed: 800,
            state: MedicalBillState.finished,
          ),
        ],
        expenseStatuses: const {100: ExpenseStatus.paid},
      );

      expect(impact.reimbursedTotal, 800);
      expect(impact.netOutOfPocket, 200);
    });

    test('a rejected insurer-paid bill falls back to the full charge', () {
      final impact = MedicalBudgetImpact.from(
        [bill(billed: 1000, state: MedicalBillState.rejected)],
        expenseStatuses: const {100: ExpenseStatus.paid},
      );

      // Rejected means no insurer contribution, so the user owes everything.
      expect(impact.paidTotal, 1000);
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
          bill(
            id: 2,
            billed: 250,
            expenseId: 2,
            reimbursed: 250,
            method: MedicalPaymentMethod.selfPaid,
            state: MedicalBillState.finished,
          ),
        ],
        expenseStatuses: const {
          1: ExpenseStatus.planned,
          2: ExpenseStatus.paid,
        },
      );

      expect(impact.plannedTotal, 1000);
      // A self-paid bill costs its full charge until a payout reduces the net.
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
    test('FR-048: the percentage is the user\'s share, not the insurer\'s', () {
      final subject = bill(billed: 1000, patientShare: 20);

      expect(subject.patientShareAmount, 200);
      expect(subject.insurerPaidAmount, 800);
    });

    test('a 100% patient share leaves the insurer owing nothing', () {
      final subject = bill(billed: 1000, patientShare: 100);

      expect(subject.patientShareAmount, 1000);
      expect(subject.insurerPaidAmount, 0);
    });

    test('a 0% patient share is fully covered by the insurer', () {
      final subject = bill(billed: 1000, patientShare: 0);

      expect(subject.patientShareAmount, 0);
      expect(subject.insurerPaidAmount, 1000);
    });
  });

  group('fundsImpact (R07)', () {
    test('a planned bill leaves the budget untouched', () {
      final subject = bill(billed: 1000, state: MedicalBillState.planned);

      expect(subject.fundsImpact, 0);
      expect(subject.countsAsPaid, isFalse);
    });

    test('a rejected bill costs the full charge whatever the method', () {
      final insurerPaid = bill(billed: 1000, state: MedicalBillState.rejected);
      final selfPaid = bill(
        billed: 1000,
        method: MedicalPaymentMethod.selfPaid,
        state: MedicalBillState.rejected,
      );

      expect(insurerPaid.fundsImpact, 1000);
      expect(selfPaid.fundsImpact, 1000);
    });

    test('a rejected insurer-paid bill is settled, so it is not pending', () {
      final subject = bill(billed: 1000, state: MedicalBillState.rejected);

      expect(subject.state.isPending, isFalse);
      expect(subject.countsAsPaid, isTrue);
    });

    test('an insurer-paid bill in flight costs only the share', () {
      for (final state in [
        MedicalBillState.waiting,
        MedicalBillState.paid,
        MedicalBillState.finished,
      ]) {
        expect(
          bill(billed: 1000, state: state).fundsImpact,
          200,
          reason: 'state $state should cost only the patient share',
        );
      }
    });

    test('a self-paid bill in flight costs the full charge', () {
      for (final state in [
        MedicalBillState.waiting,
        MedicalBillState.paid,
      ]) {
        expect(
          bill(
            billed: 1000,
            method: MedicalPaymentMethod.selfPaid,
            state: state,
          ).fundsImpact,
          1000,
          reason: 'state $state should cost the full charge',
        );
      }
    });

    test('an insurer-paid bill can never be finished (R-1)', () {
      expect(bill(billed: 1000).canBeReimbursed, isFalse);
      expect(
        bill(
          billed: 1000,
          method: MedicalPaymentMethod.selfPaid,
        ).canBeReimbursed,
        isTrue,
      );
    });
  });

  group('MedicalBillState labels', () {
    // `isPending` means "submitted but unanswered", which is exactly `waiting`.
    // A `planned` bill has not been submitted yet, and `paid`/`finished`/
    // `rejected` are already resolved.
    test('only a waiting claim is unanswered', () {
      expect(MedicalBillState.planned.isPending, isFalse);
      expect(MedicalBillState.waiting.isPending, isTrue);
      expect(MedicalBillState.paid.isPending, isFalse);
      expect(MedicalBillState.finished.isPending, isFalse);
      expect(MedicalBillState.rejected.isPending, isFalse);
    });

    test(
        'anything other than planned or waiting has settled one way or the other',
        () {
      expect(MedicalBillState.paid.isSettled, isTrue);
      expect(MedicalBillState.finished.isSettled, isTrue);
      expect(MedicalBillState.rejected.isSettled, isTrue);
      expect(MedicalBillState.planned.isSettled, isFalse);
      expect(MedicalBillState.waiting.isSettled, isFalse);
    });

    test('every state and method has a human label', () {
      for (final state in MedicalBillState.values) {
        expect(state.label, isNotEmpty);
      }
      for (final method in MedicalPaymentMethod.values) {
        expect(method.label, isNotEmpty);
      }
    });
  });
}
