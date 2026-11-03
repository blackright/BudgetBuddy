import 'package:flutter_test/flutter_test.dart';

import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';

import '../../../support/receipt_financial_harness.dart';
import '../repositories/medical_test_harness.dart';
import 'fixtures.dart';

void main() {
  group('management fixtures', () {
    late ReceiptFinancialHarness h;

    setUp(() async {
      h = await ReceiptFinancialHarness.create();
    });

    tearDown(() => h.close());

    test('planned user-paid seed writes one planned bill and linked expense',
        () async {
      final seeded = await h.seedMedicalBill(
        paymentMethod: MedicalPaymentMethod.selfPaid,
        state: MedicalBillState.planned,
      );

      expect(await h.db.medicalBills.count(), 1);
      expect(await h.db.expenses.count(), 1);
      expect(seeded.bill.state, MedicalBillState.planned);
      expect(seeded.bill.linkedExpenseId, seeded.expense.id);
      expect(seeded.expense.type, ExpenseType.medical);
      expect(seeded.expense.status, ExpenseStatus.planned);
      expect(seeded.expense.amount, 0);
      expect(seeded.expense.yearMonth, seeded.bill.yearMonth);
    });

    test('closed insurer-paid seed keeps only the share as paid cost',
        () async {
      final seeded = await h.seedMedicalBill(
        paymentMethod: MedicalPaymentMethod.insurerPaid,
        state: MedicalBillState.finished,
        patientSharePercent: 20,
      );

      expect(seeded.bill.paymentMethod, MedicalPaymentMethod.insurerPaid);
      expect(seeded.bill.state, MedicalBillState.finished);
      expect(seeded.expense.status, ExpenseStatus.paid);
      expect(seeded.expense.amount, 2000);
      expect(seeded.expense.paidAt, isNotNull);
    });

    test('legacy partial reimbursement is preserved, not converted', () async {
      final seeded = await h.seedMedicalBill(
        state: MedicalBillState.waiting,
        reimbursedAmount: 2500,
      );

      expect(seeded.bill.reimbursedAmount, 2500);
      expect(seeded.bill.state, MedicalBillState.waiting);
      expect(seeded.expense.amount, 10000);
    });

    test('access helpers expose current and revoked guards', () {
      expect(alwaysCurrentAccess()(), isTrue);
      expect(revokedAccess()(), isFalse);
    });
  });

  test('medical repository harness seeds through the same fixture', () async {
    final harness = await MedicalTestHarness.create();
    addTearDown(harness.close);
    final context = await harness.seedBudget();
    final seeded = await harness.seedManagementBill(
      context: context,
      paymentMethod: MedicalPaymentMethod.insurerPaid,
      state: MedicalBillState.paid,
    );

    expect(seeded.bill.currency, 'usd');
    expect(seeded.bill.profileId, context.profileId);
    expect(seeded.expense.amount, 2000);
    expect(await harness.allBills(), hasLength(1));
  });
}
