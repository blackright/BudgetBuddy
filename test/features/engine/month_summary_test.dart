import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:flutter_test/flutter_test.dart';

/// Oracle for `contracts/month-summary.md` §4 invariants and §5 worked
/// examples. Pure arithmetic, so no Isar instance is involved.
void main() {
  Expense expense({
    required double amount,
    int id = 1,
    ExpenseStatus status = ExpenseStatus.paid,
    String yearMonth = '2026-01',
    String categoryId = 'general',
    ExpenseType type = ExpenseType.standard,
    double rate = 1.0,
  }) {
    return Expense(
      id: id,
      profileId: 1,
      yearMonth: yearMonth,
      exchangeRateToPrimary: rate,
      type: type,
      title: 'Test expense',
      amount: amount,
      currency: 'USD',
      categoryId: categoryId,
      status: status,
      date: DateTime(2026, 1, 15),
      budgetId: 1,
    );
  }

  Reimbursement reimbursement({
    required double amount,
    int id = 1,
    int? expenseId = 1,
    String originYearMonth = '2026-01',
  }) {
    return Reimbursement(
      id: id,
      profileId: 1, // Add mock profileId
      expenseId: expenseId,
      originYearMonth: originYearMonth,
      amount: amount,
      currency: 'USD', // Add mock currency
      date: DateTime(2026, 4, 2),
    );
  }

  MonthSummary build({
    String yearMonth = '2026-01',
    double income = 0.0,
    bool usesOverriddenIncome = false,
    double? openingBalance,
    List<Expense> expenses = const [],
    List<Reimbursement> reimbursements = const [],
    Map<int, double> targetPaidAmounts = const {},
  }) {
    return MonthSummary.from(
      yearMonth: yearMonth,
      income: income,
      usesOverriddenIncome: usesOverriddenIncome,
      expenses: expenses,
      reimbursements: reimbursements,
      openingBalance: openingBalance,
      targetPaidAmounts: targetPaidAmounts,
    );
  }

  group('invariants', () {
    test('I1: kept == income - paymentsMade + moneyReturned exactly', () {
      final summary = build(
        income: 4000,
        expenses: [expense(amount: 1200)],
        reimbursements: [reimbursement(amount: 300)],
      );

      expect(summary.kept, 4000 - 1200 + 300);
      expect(summary.kept, closeTo(3100, 1e-9));
    });

    test('I2: moneyInBank == openingBalance + income - paymentsMade + returned',
        () {
      final summary = build(
        income: 4000,
        openingBalance: 1200,
        expenses: [expense(amount: 1200)],
        reimbursements: [reimbursement(amount: 800)],
      );

      expect(summary.moneyInBank, 1200 + 4000 - 1200 + 800);
      expect(summary.moneyInBank, closeTo(4800, 1e-9));
    });

    test('I3: planned appears in none of kept, paymentsMade or moneyInBank',
        () {
      final withoutPlanned = build(
        income: 4000,
        openingBalance: 1000,
        expenses: [expense(amount: 1200)],
      );
      final withPlanned = build(
        income: 4000,
        openingBalance: 1000,
        expenses: [
          expense(amount: 1200, id: 1),
          expense(amount: 800, id: 2, status: ExpenseStatus.planned),
        ],
      );

      expect(withPlanned.planned, 800);
      expect(withPlanned.kept, withoutPlanned.kept);
      expect(withPlanned.paymentsMade, withoutPlanned.paymentsMade);
      expect(withPlanned.moneyInBank, withoutPlanned.moneyInBank);
    });

    test('I4: openingBalance appears in no term of kept', () {
      final withoutBalance = build(
        income: 4000,
        expenses: [expense(amount: 1200)],
      );
      final withBalance = build(
        income: 4000,
        openingBalance: 99999,
        expenses: [expense(amount: 1200)],
      );

      expect(withBalance.kept, withoutBalance.kept);
    });

    test('I5: moneyInBank is absent iff there is no confirmed balance', () {
      expect(build(openingBalance: null).moneyInBank, isNull);
      expect(build(openingBalance: 0).moneyInBank, isNotNull);
      expect(build(openingBalance: 500).moneyInBank, isNotNull);
    });

    test('I6: medicalPaid <= paymentsMade', () {
      final summary = build(
        income: 4000,
        expenses: [
          expense(amount: 300, id: 1, type: ExpenseType.medical),
          expense(amount: 500, id: 2, categoryId: 'health'),
          expense(amount: 400, id: 3),
          expense(
              amount: 999,
              id: 4,
              status: ExpenseStatus.planned,
              type: ExpenseType.medical),
        ],
      );

      expect(summary.medicalPaid, 800);
      expect(summary.medicalPaid, lessThanOrEqualTo(summary.paymentsMade));
    });

    test(
        'I7: neither kept nor moneyInBank is floored by an excess reimbursement',
        () {
      final summary = build(
        income: 500,
        openingBalance: 100,
        expenses: [expense(amount: 800)],
        reimbursements: [reimbursement(amount: 900)],
        targetPaidAmounts: const {1: 800},
      );

      expect(summary.excessReturned, 100);
      expect(summary.paymentsMade, 800,
          reason: 'paymentsMade is never reduced');
      expect(summary.moneyReturned, 900, reason: 'the full amount is credited');
      // 500 - 800 + 900 = 600, which is positive but the same reasoning applies
      // when it would have been negative.
      expect(summary.kept, 600);
      expect(summary.moneyInBank, 700);
    });

    test('I7b: a negative balance is reported, not clamped to zero', () {
      final summary = build(
        income: 100,
        expenses: [expense(amount: 800)],
        reimbursements: const [],
      );

      expect(summary.kept, -700);
      expect(summary.moneyInBank, isNull);
    });

    test('I8: cancelled expenses contribute to nothing but cancelled', () {
      final summary = build(
        income: 4000,
        openingBalance: 500,
        expenses: [
          expense(amount: 1200, id: 1),
          expense(amount: 300, id: 2, status: ExpenseStatus.cancelled),
          expense(
              amount: 700,
              id: 3,
              status: ExpenseStatus.cancelled,
              type: ExpenseType.medical),
        ],
      );

      expect(summary.cancelled, 1000);
      expect(summary.paymentsMade, 1200);
      expect(summary.medicalPaid, 0);
      expect(summary.kept, 4000 - 1200);
    });

    test('I9: one month\'s rows cannot influence another month\'s summary', () {
      final january = [expense(amount: 1200, yearMonth: '2026-01')];
      final february = [
        expense(amount: 5000, id: 2, yearMonth: '2026-02'),
        expense(
            amount: 900,
            id: 3,
            yearMonth: '2026-02',
            status: ExpenseStatus.planned),
      ];

      final januaryBefore = build(income: 4000, expenses: january);
      build(income: 4000, expenses: february, reimbursements: [
        reimbursement(amount: 777, originYearMonth: '2026-02', expenseId: 2),
      ]);
      final januaryAfter = build(income: 4000, expenses: january);

      expect(januaryAfter.kept, januaryBefore.kept);
      expect(januaryAfter.moneyReturned, 0);
      expect(januaryAfter.paymentsMade, 1200);
    });

    test(
        'I10: moneyInBank == trueAvailable + income when the balance is confirmed',
        () {
      final summary = build(
        income: 4000,
        openingBalance: 1200,
        expenses: [expense(amount: 1200)],
        reimbursements: [reimbursement(amount: 800)],
      );

      final trueAvailable = summary.openingBalance! -
          summary.paymentsMade +
          summary.moneyReturned;
      expect(
          summary.moneyInBank, closeTo(trueAvailable + summary.income, 1e-9));
    });

    test('multi-currency expenses are converted before summing', () {
      final summary = build(
        income: 4000,
        expenses: [
          expense(amount: 1000, id: 1, rate: 1.0),
          expense(amount: 100, id: 2, rate: 4.0),
        ],
      );

      expect(summary.paymentsMade, 1400);
    });
  });

  group('worked examples', () {
    test('E1: income 4000, one paid expense of 1200 keeps 2800', () {
      final summary = build(
        income: 4000,
        expenses: [expense(amount: 1200)],
      );

      expect(summary.paymentsMade, 1200);
      expect(summary.moneyReturned, 0);
      expect(summary.planned, 0);
      expect(summary.kept, 2800);
    });

    test('E2: adding a planned 800 leaves kept unchanged', () {
      final summary = build(
        income: 4000,
        expenses: [
          expense(amount: 1200, id: 1),
          expense(amount: 800, id: 2, status: ExpenseStatus.planned),
        ],
      );

      expect(summary.planned, 800);
      expect(summary.kept, 2800);
    });

    test('E3: a reimbursement of 300 raises kept to 3100', () {
      final summary = build(
        income: 4000,
        expenses: [expense(amount: 1200)],
        reimbursements: [reimbursement(amount: 300)],
      );

      expect(summary.moneyReturned, 300);
      expect(summary.kept, 3100);
    });

    test('E7: a 900 reimbursement against 800 paid surfaces 100 excess', () {
      final summary = build(
        income: 4000,
        expenses: [expense(amount: 800)],
        reimbursements: [reimbursement(amount: 900)],
        targetPaidAmounts: const {1: 800},
      );

      expect(summary.moneyReturned, 900);
      expect(summary.excessReturned, 100);
      expect(summary.paymentsMade, 800);
      expect(summary.kept, 4000 - 800 + 900);
    });

    test('E10: a future month with only planned entries is incomplete', () {
      final summary = build(
        yearMonth: '2026-12',
        income: 0,
        expenses: [
          expense(
              amount: 400,
              id: 1,
              yearMonth: '2026-12',
              status: ExpenseStatus.planned),
          expense(
              amount: 250,
              id: 2,
              yearMonth: '2026-12',
              status: ExpenseStatus.planned),
        ],
      );

      expect(summary.planned, 650);
      expect(summary.isComplete, isFalse);
      expect(summary.moneyInBank, isNull);
    });

    test('isComplete requires both a confirmed balance and income', () {
      expect(build(income: 4000, openingBalance: 100).isComplete, isTrue);
      expect(build(income: 0, openingBalance: 100).isComplete, isFalse);
      expect(build(income: 4000, openingBalance: null).isComplete, isFalse);
    });

    test('usesOverriddenIncome is surfaced for the override marker', () {
      final summary = build(
        income: 4000,
        usesOverriddenIncome: true,
        expenses: [expense(amount: 100)],
      );

      expect(summary.usesOverriddenIncome, isTrue);
    });
  });
}
