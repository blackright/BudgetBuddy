import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/services/medical_bill_basis.dart';
import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import 'package:budget_buddy/features/medical/repositories/medical_repository.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import '../../support/receipt_financial_harness.dart';

void main() {
  late ReceiptFinancialHarness h;
  late MedicalRepository repo;
  setUp(() async {
    h = await ReceiptFinancialHarness.create();
    repo = MedicalRepository(h.db, actingProfileId: h.ownerId);
  });
  tearDown(() async => h.close());
  Future<MedicalBill> seed({bool paid = true}) async {
    final expense = h.expense()
      ..type = ExpenseType.medical
      ..amount = paid ? 2000 : 0
      ..status = paid ? ExpenseStatus.paid : ExpenseStatus.planned;
    final bill = MedicalBill()
      ..profileId = h.ownerId
      ..yearMonth = '2026-10'
      ..currency = 'huf'
      ..billedAmount = 10000
      ..patientSharePercent = 20
      ..paymentMethod = MedicalPaymentMethod.insurerPaid
      ..state = MedicalBillState.waiting;
    await h.db.writeTxn(() async {
      expense.id = await h.db.expenses.put(expense);
      bill.linkedExpenseId = expense.id;
      bill.id = await h.db.medicalBills.put(bill);
    });
    return bill;
  }

  test('reviewed refusal retains rejected state and full responsibility once',
      () async {
    final bill = await seed();
    final review = await repo.reviewBill(
        proposed: copyMedicalBill(bill)..state = MedicalBillState.rejected,
        status: ExpenseStatus.paid,
        reason: 'Insurance declined the saved bill.',
        isAccessCurrent: () => true);
    expect(review.proposed.state, MedicalBillState.rejected);
    expect(review.beforeMinor, 2000);
    expect(review.afterMinor, 10000);
    expect((await h.db.medicalBills.get(bill.id))!.state,
        MedicalBillState.waiting);
    await repo.applyBillReview(
        review: review, operationKey: 'refusal', isAccessCurrent: () => true);
    expect((await h.db.medicalBills.get(bill.id))!.state,
        MedicalBillState.rejected);
    expect((await h.db.expenses.get(bill.linkedExpenseId!))!.amount, 10000);
    expect(await h.db.expenses.count(), 1);
    expect(await h.db.reimbursements.count(), 0);
    expect((await h.db.medicalClaimActivitys.where().findAll()).single.reason,
        'Insurance declined the saved bill.');
  });
  test('refusal does not invent a payment on an unpaid linked expense',
      () async {
    final bill = await seed(paid: false);
    final review = await repo.reviewBill(
        proposed: copyMedicalBill(bill)..state = MedicalBillState.rejected,
        status: ExpenseStatus.planned,
        reason: 'No insurance coverage; provider not paid.',
        isAccessCurrent: () => true);
    expect(review.afterMinor, 0);
    await repo.applyBillReview(
        review: review,
        operationKey: 'unpaid-refusal',
        isAccessCurrent: () => true);
    final expense = (await h.db.expenses.get(bill.linkedExpenseId!))!;
    expect(expense.status, ExpenseStatus.planned);
    expect(expense.paidAt, isNull);
    expect(expense.amount, 10000);
  });
  test('normal reviewed direct bill keeps waiting distinct from share booking',
      () async {
    final bill = await seed();
    final review = await repo.reviewBill(
        proposed: copyMedicalBill(bill)..billedAmount = 12000,
        status: ExpenseStatus.paid,
        reason: 'Correct bill total.',
        isAccessCurrent: () => true);
    expect(review.proposed.state, MedicalBillState.waiting);
    expect(review.afterMinor, 2400);
  });
  test('changed proposed insurance state invalidates the reviewed fingerprint',
      () async {
    final bill = await seed();
    final review = await repo.reviewBill(
        proposed: copyMedicalBill(bill)..state = MedicalBillState.rejected,
        status: ExpenseStatus.paid,
        reason: 'Insurance declined.',
        isAccessCurrent: () => true);
    review.proposed.state = MedicalBillState.paid;
    await expectLater(
        repo.applyBillReview(
            review: review,
            operationKey: 'tampered',
            isAccessCurrent: () => true),
        throwsA(isA<MedicalReceiptException>()
            .having((e) => e.code, 'code', 'stalePreview')));
    expect((await h.db.medicalBills.get(bill.id))!.state,
        MedicalBillState.waiting);
    expect((await h.db.expenses.get(bill.linkedExpenseId!))!.amount, 2000);
  });
}
