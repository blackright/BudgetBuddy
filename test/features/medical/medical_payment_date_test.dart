import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import 'package:budget_buddy/core/services/medical_bill_basis.dart';
import 'package:budget_buddy/features/medical/repositories/medical_repository.dart';
import '../../support/receipt_financial_harness.dart';

void main() {
  late ReceiptFinancialHarness h;
  late MedicalBill bill;
  late Expense expense;
  late MedicalRepository repo;
  setUp(() async {
    h = await ReceiptFinancialHarness.create();
    await h.db.writeTxn(() async {
      expense = h.expense()
        ..type = ExpenseType.medical
        ..status = ExpenseStatus.planned;
      expense.id = await h.db.expenses.put(expense);
      bill = MedicalBill()
        ..profileId = h.ownerId
        ..linkedExpenseId = expense.id
        ..billedAmount = 10000
        ..patientSharePercent = 20
        ..currency = 'huf'
        ..yearMonth = '2026-10'
        ..serviceDate = DateTime(2026, 10, 20)
        ..state = MedicalBillState.planned;
      bill.id = await h.db.medicalBills.put(bill);
    });
    repo = MedicalRepository(h.db, actingProfileId: h.ownerId);
  });
  tearDown(() => h.close());
  Future<void> pay(DateTime date, String operation) async {
    final current = (await h.db.medicalBills.get(bill.id))!;
    final review = await repo.reviewBill(
        proposed: copyMedicalBill(current),
        status: ExpenseStatus.paid,
        reason: 'Provider paid on selected date',
        paymentDate: date,
        isAccessCurrent: () => true);
    await repo.applyBillReview(
        review: review, operationKey: operation, isAccessCurrent: () => true);
  }

  test(
      'actual payment date persists once and retains service month and exact cost',
      () async {
    final date = DateTime(2026, 10, 21);
    final review = await repo.reviewBill(
        proposed: copyMedicalBill(bill),
        status: ExpenseStatus.paid,
        reason: 'Actual provider payment',
        paymentDate: date,
        isAccessCurrent: () => true);
    for (var i = 0; i < 2; i++) {
      await repo.applyBillReview(
          review: review,
          operationKey: 'same-payment',
          isAccessCurrent: () => true);
    }
    final saved = (await h.db.expenses.get(expense.id))!;
    expect(saved.paidAt?.toUtc(), date.toUtc());
    expect(saved.yearMonth, '2026-10');
    expect(saved.amount, 10000);
    expect(await h.db.expenses.count(), 1);
    expect(await h.db.medicalClaimActivitys.count(), 1);
    expect((await h.db.medicalClaimActivitys.where().findFirst())!.afterJson,
        contains('paidAt'));
  });
  test(
      'reviewed date correction preserves previous date and no duplicate expense',
      () async {
    await pay(DateTime(2026, 10, 21), 'first');
    await pay(DateTime(2026, 10, 22), 'correction');
    expect((await h.db.expenses.get(expense.id))!.paidAt?.toLocal(),
        DateTime(2026, 10, 22));
    final rows = await h.db.medicalClaimActivitys.where().findAll();
    expect(rows.last.beforeJson,
        contains(DateTime(2026, 10, 21).toUtc().toIso8601String()));
    expect(await h.db.expenses.count(), 1);
  });
  test('a reviewed edit does not invent an unknown legacy payment date',
      () async {
    await h.db.writeTxn(() async {
      expense.status = ExpenseStatus.paid;
      bill.state = MedicalBillState.paid;
      await h.db.expenses.put(expense);
      await h.db.medicalBills.put(bill);
    });
    final review = await repo.reviewBill(
        proposed: copyMedicalBill(bill),
        status: ExpenseStatus.paid,
        reason: 'Review recorded details without dating old money',
        isAccessCurrent: () => true);
    await repo.applyBillReview(
        review: review,
        operationKey: 'unknown-date',
        isAccessCurrent: () => true);
    expect((await h.db.expenses.get(expense.id))!.paidAt, isNull);
  });
  test('future payment date is refused without changing money', () async {
    await expectLater(
        pay(DateTime.now().add(const Duration(days: 2)), 'future'),
        throwsA(isA<MedicalReceiptException>()));
    expect(
        (await h.db.expenses.get(expense.id))!.status, ExpenseStatus.planned);
  });
  test('stale payment-date preview is refused after another confirmation',
      () async {
    final old = await repo.reviewBill(
        proposed: copyMedicalBill(bill),
        status: ExpenseStatus.paid,
        reason: 'Old preview',
        paymentDate: DateTime(2026, 10, 21),
        isAccessCurrent: () => true);
    await pay(DateTime(2026, 10, 22), 'newer');
    await expectLater(
        repo.applyBillReview(
            review: old, operationKey: 'old', isAccessCurrent: () => true),
        throwsA(isA<MedicalReceiptException>()));
    expect((await h.db.expenses.get(expense.id))!.paidAt?.toLocal(),
        DateTime(2026, 10, 22));
  });
  test('lost access rolls back payment date and refuses reminders', () async {
    final review = await repo.reviewBill(
        proposed: copyMedicalBill(bill),
        status: ExpenseStatus.paid,
        reason: 'Pending payment',
        paymentDate: DateTime(2026, 10, 21),
        isAccessCurrent: () => true);
    await expectLater(
        repo.applyBillReview(
            review: review,
            operationKey: 'locked',
            isAccessCurrent: () => false),
        throwsA(isA<MedicalReceiptException>()));
    await expectLater(
        repo.setFollowUpDate(bill, DateTime.now().add(const Duration(days: 2)),
            isAccessCurrent: () => false),
        throwsA(isA<MedicalReceiptException>()));
    expect((await h.db.expenses.get(expense.id))!.paidAt, isNull);
  });
  test('unprepared actual-payment month blocks cross-month recording',
      () async {
    await expectLater(
        pay(DateTime(2026, 9, 21), 'old-month'), throwsA(isA<Exception>()));
    expect(
        (await h.db.expenses.get(expense.id))!.status, ExpenseStatus.planned);
  });
  test('prepared actual-payment month preserves owning cost month', () async {
    await h.db.writeTxn(() => h.db.monthlyBudgets.put(MonthlyBudget()
      ..profileId = h.ownerId
      ..yearMonth = '2026-09'
      ..baseAvailableAmount = 600000
      ..openingBalanceConfirmed = true
      ..createdAt = DateTime(2026, 9)
      ..updatedAt = DateTime(2026, 9)));
    await pay(DateTime(2026, 9, 21), 'prepared-month');
    final saved = (await h.db.expenses.get(expense.id))!;
    expect(saved.paidAt?.toLocal(), DateTime(2026, 9, 21));
    expect(saved.yearMonth, '2026-10');
    expect(saved.amount, 10000);
    expect((await h.db.medicalBills.get(bill.id))!.serviceDate,
        DateTime(2026, 10, 20));
  });
  test('readiness failures cannot become an empty successful check', () async {
    final other = MedicalRepository(h.db, actingProfileId: h.ownerId + 999);
    await expectLater(other.monthBlockersFor(bill), throwsA(isA<Exception>()));
  });
  test('calendar metadata refuses expired access before a write', () async {
    await expectLater(
        repo.setCalendarEventId(bill, 'private-event',
            isAccessCurrent: () => false),
        throwsA(isA<MedicalReceiptException>()));
    expect((await h.db.medicalBills.get(bill.id))!.calendarEventId, isNull);
  });
}
