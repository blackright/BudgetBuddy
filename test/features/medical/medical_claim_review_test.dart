import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/settings/presentation/profile_switcher_section.dart';
import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import 'package:budget_buddy/core/services/medical_bill_basis.dart';
import 'package:budget_buddy/features/medical/repositories/medical_repository.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import '../../support/receipt_financial_harness.dart';

void main() {
  late ReceiptFinancialHarness h;
  late MedicalBill bill;
  late Expense expense;
  late MedicalRepository repo;
  late MedicalReceiptService service;
  final now = DateTime.utc(2026, 10, 28, 16);
  setUp(() async {
    h = await ReceiptFinancialHarness.create();
    await h.db.writeTxn(() async {
      expense = h.expense()..type = ExpenseType.medical;
      expense.id = await h.db.expenses.put(expense);
      bill = MedicalBill()
        ..profileId = h.ownerId
        ..linkedExpenseId = expense.id
        ..billedAmount = 10000
        ..patientSharePercent = 20
        ..currency = 'huf'
        ..yearMonth = '2026-10'
        ..serviceDate = DateTime.utc(2026, 10, 20)
        ..state = MedicalBillState.waiting;
      bill.id = await h.db.medicalBills.put(bill);
    });
    repo = MedicalRepository(h.db, actingProfileId: h.ownerId);
    service = MedicalReceiptService(h.db, clock: () => now);
  });
  tearDown(() => h.close());
  Future<MedicalReceiptHistory> history() => service.history(
      billId: bill.id, actorId: h.ownerId, isAccessCurrent: () => true);
  Future<MedicalApproval> approve([String key = 'approval']) => service.approve(
      billId: bill.id,
      actorId: h.ownerId,
      amountMinor: 8000,
      decisionDate: DateTime.utc(2026, 10, 22),
      operationKey: key,
      isAccessCurrent: () => true);

  test('approval captures exact expected basis without adding cash', () async {
    final before = await h.db.expenses.where().exportJson();
    final a = await approve();
    final basis = jsonDecode(a.basisJson!) as Map;
    expect(basis['billedMinor'], 10000);
    expect(basis['patientMinor'], 2000);
    expect(basis['expectedMinor'], 8000);
    expect(await h.db.reimbursements.count(), 0);
    expect(await h.db.expenses.where().exportJson(), before);
  });
  test(
      'a bill month with no budget is refused as missingMonth, not a retry loop',
      () async {
    await approve();
    await h.db.writeTxn(() => h.db.monthlyBudgets.clear());
    await expectLater(
        repo.reviewBill(
            proposed: copyMedicalBill(bill)..state = MedicalBillState.paid,
            status: ExpenseStatus.paid,
            reason: 'Paid 10000 HUF for this service',
            isAccessCurrent: () => true),
        throwsA(isA<MedicalReceiptException>()
            .having((e) => e.code, 'code', 'missingMonth')));
  });
  test(
      'a month whose opening money is unconfirmed is refused as '
      'missingOpeningReview', () async {
    await approve();
    await h.db.writeTxn(() async {
      final month = (await h.db.monthlyBudgets.get(h.budgetId))!;
      month.openingBalanceConfirmed = false;
      await h.db.monthlyBudgets.put(month);
    });
    await expectLater(
        repo.reviewBill(
            proposed: copyMedicalBill(bill)..state = MedicalBillState.paid,
            status: ExpenseStatus.paid,
            reason: 'Paid 10000 HUF for this service',
            isAccessCurrent: () => true),
        throwsA(isA<MedicalReceiptException>()
            .having((e) => e.code, 'code', 'missingOpeningReview')));
  });
  test(
      'legacy Waiting displays the recorded Paid expense without a guessed submission',
      () async {
    final before = await h.db.medicalBills.where().exportJson();
    final value = await history();
    expect(value.paymentLabel, 'Paid to provider');
    expect(value.claimLabel, 'Submission not recorded');
    expect(await h.db.medicalBills.where().exportJson(), before);
  });
  test(
      'submission and cancellation preserve expense, reason and idempotent history',
      () async {
    final before = await h.db.expenses.where().exportJson();
    await service.recordClaimAction(
        billId: bill.id,
        actorId: h.ownerId,
        kind: 'submitted',
        operationKey: 'submitted',
        submittedAt: DateTime.utc(2026, 10, 21),
        isAccessCurrent: () => true);
    expect((await history()).claimLabel, 'Awaiting decision');
    await approve();
    for (var i = 0; i < 2; i++) {
      await service.recordClaimAction(
          billId: bill.id,
          actorId: h.ownerId,
          kind: 'cancelled',
          operationKey: 'cancel',
          reason: 'No longer claiming',
          isAccessCurrent: () => true);
    }
    expect((await history()).claimLabel, 'Cancelled');
    expect(await h.db.medicalClaimActivitys.count(), 2);
    expect(await h.db.expenses.where().exportJson(), before);
    await expectLater(approve('later'), throwsFormatException);
  });
  test(
      'ordinary amount edit and force deletion are blocked after approval; documents remain editable',
      () async {
    await approve();
    final changed = copyMedicalBill(bill)..billedAmount = 12000;
    final context = MedicalBillContext(
        profileId: h.ownerId,
        budgetId: h.budgetId,
        yearMonth: '2026-10',
        primaryCurrency: 'huf');
    await expectLater(
        repo.saveBill(changed, context, status: ExpenseStatus.paid),
        throwsFormatException);
    await expectLater(
        repo.deleteBill(bill.id, force: true), throwsFormatException);
    final beforeExpense = await h.db.expenses.where().exportJson();
    await repo.saveBill(
        copyMedicalBill(bill)..billPhotoPath = 'fixture-document-only', context,
        status: ExpenseStatus.paid);
    expect(await h.db.expenses.where().exportJson(), beforeExpense);
    expect((await h.db.medicalBills.get(bill.id))!.billedAmount, 10000);
    expect((await h.db.expenses.get(expense.id))!.amount, 10000);
  });
  test(
      'reviewed correction retains old basis and requires explicit approval review',
      () async {
    final original = await approve();
    final originalBasis = original.basisJson;
    final preview = await repo.reviewBill(
        proposed: copyMedicalBill(bill)..billedAmount = 12000,
        status: ExpenseStatus.paid,
        reason: 'Correct invoice total',
        isAccessCurrent: () => true);
    await repo.applyBillReview(
        review: preview, operationKey: 'correct', isAccessCurrent: () => true);
    await repo.applyBillReview(
        review: preview, operationKey: 'correct', isAccessCurrent: () => true);
    expect(await h.db.medicalClaimActivitys.count(), 1);
    await expectLater(
        service.preview(
            billId: bill.id,
            actorId: h.ownerId,
            amountMinor: 8000,
            receivedAt: now,
            destinationMonth: '2026-10',
            isAccessCurrent: () => true),
        throwsA(isA<MedicalReceiptException>()
            .having((e) => e.code, 'code', 'approvalNeedsReview')));
    expect((await history()).approvalNeedsReview, isTrue);
    expect((await h.db.medicalApprovals.get(original.id))!.basisJson,
        originalBasis);
    expect((await h.db.expenses.get(expense.id))!.amount, 12000);
    await approve('reviewed-approval');
    expect((await history()).approvalNeedsReview, isFalse);
    expect(await h.db.medicalApprovals.count(), 2);
  });
  test('stale reviewed correction and closed month leave bill untouched',
      () async {
    await approve();
    final proposed = copyMedicalBill(bill)..billedAmount = 12000;
    final preview = await repo.reviewBill(
        proposed: proposed,
        status: ExpenseStatus.paid,
        reason: 'Correct invoice',
        isAccessCurrent: () => true);
    await h.db.writeTxn(() async {
      await h.db.monthRateSeals.put(MonthRateSeal()
        ..yearMonth = '2026-10'
        ..asOf = now
        ..fetchedAt = now
        ..updatedAt = now);
    });
    await expectLater(
        repo.applyBillReview(
            review: preview,
            operationKey: 'closed',
            isAccessCurrent: () => true),
        throwsFormatException);
    expect((await h.db.medicalBills.get(bill.id))!.billedAmount, 10000);
    expect(await h.db.medicalClaimActivitys.count(), 0);
  });
  test(
      'recorded money prevents claim cancellation and original bill financial correction',
      () async {
    await approve();
    await h.db.writeTxn(() => h.db.reimbursements.put(Reimbursement(
        profileId: h.ownerId,
        expenseId: expense.id,
        originYearMonth: '2026-11',
        amount: 8000,
        currency: 'huf',
        date: now)));
    await expectLater(
        service.recordClaimAction(
            billId: bill.id,
            actorId: h.ownerId,
            kind: 'cancelled',
            reason: 'Wrong bill',
            operationKey: 'cancel',
            isAccessCurrent: () => true),
        throwsFormatException);
    await expectLater(
        repo.reviewBill(
            proposed: copyMedicalBill(bill)..billedAmount = 12000,
            status: ExpenseStatus.paid,
            reason: 'Change original',
            isAccessCurrent: () => true),
        throwsFormatException);
    expect(await h.db.reimbursements.count(), 1);
  });
  test(
      'reviewed entered-in-error keeps bill and approval; cancels only its expense effect',
      () async {
    await approve();
    final review = await repo.reviewBill(
        proposed: copyMedicalBill(bill),
        status: ExpenseStatus.paid,
        reason: 'Duplicate entry',
        remove: true,
        isAccessCurrent: () => true);
    await repo.applyBillReview(
        review: review, operationKey: 'remove', isAccessCurrent: () => true);
    expect(await h.db.medicalBills.get(bill.id), isNotNull);
    expect(await h.db.medicalApprovals.count(), 1);
    expect(
        (await h.db.expenses.get(expense.id))!.status, ExpenseStatus.cancelled);
    expect((await history()).enteredInError, isTrue);
    final totals = MedicalBudgetImpact.from([bill],
        display: CurrencyCode.huf,
        convert: (money) => money,
        expenseStatuses: {expense.id: ExpenseStatus.cancelled});
    expect(totals.paidTotal, 0);
    expect(totals.outOfPocketTotal, 0);
  });
  test('lost access rolls back reviewed changes and their history', () async {
    await approve();
    await expectLater(
        repo.saveBill(
            copyMedicalBill(bill)..billPhotoPath = 'not-saved',
            MedicalBillContext(
                profileId: h.ownerId,
                budgetId: h.budgetId,
                yearMonth: '2026-10',
                primaryCurrency: 'huf'),
            status: ExpenseStatus.paid,
            isAccessCurrent: () => false),
        throwsFormatException);
    final review = await repo.reviewBill(
        proposed: copyMedicalBill(bill)..billedAmount = 12000,
        status: ExpenseStatus.paid,
        reason: 'Correction',
        isAccessCurrent: () => true);
    await expectLater(
        repo.applyBillReview(
            review: review, operationKey: 'lost', isAccessCurrent: () => false),
        throwsFormatException);
    expect((await h.db.medicalBills.get(bill.id))!.billedAmount, 10000);
    expect(await h.db.medicalClaimActivitys.count(), 0);
  });
  test('required audit failure rolls back reviewed bill and expense writes',
      () async {
    await approve();
    final review = await repo.reviewBill(
        proposed: copyMedicalBill(bill)..billedAmount = 12000,
        status: ExpenseStatus.paid,
        reason: 'Correction',
        isAccessCurrent: () => true);
    // Disposable integrity fixture only: leave a chain head without its tip.
    await h.db.writeTxn(() => h.db.auditEvents.clear());
    await expectLater(
        repo.applyBillReview(
            review: review,
            operationKey: 'audit-failure',
            isAccessCurrent: () => true),
        throwsStateError);
    expect((await h.db.medicalBills.get(bill.id))!.billedAmount, 10000);
    expect((await h.db.expenses.get(expense.id))!.amount, 10000);
    expect(await h.db.medicalClaimActivitys.count(), 0);
  });
  test(
      'new planned bill is Not submitted and provider payment debits full cost once',
      () async {
    final context = MedicalBillContext(
        profileId: h.ownerId,
        budgetId: h.budgetId,
        yearMonth: '2026-10',
        primaryCurrency: 'huf');
    final fresh = MedicalBill()
      ..billedAmount = 5000
      ..currency = 'huf'
      ..yearMonth = '2026-10'
      ..state = MedicalBillState.planned;
    final saved =
        await repo.saveBill(fresh, context, status: ExpenseStatus.planned);
    var view = await service.history(
        billId: saved.id, actorId: h.ownerId, isAccessCurrent: () => true);
    expect(view.claimLabel, 'Not submitted');
    expect(view.paymentLabel, 'Planned');
    await repo.setBillState(copyMedicalBill(saved), MedicalBillState.paid);
    view = await service.history(
        billId: saved.id, actorId: h.ownerId, isAccessCurrent: () => true);
    expect(view.expense.amount, 5000);
    expect(view.paymentLabel, 'Paid to provider');
    expect(await h.db.reimbursements.count(), 0);
  });
  test(
      'a proposed shared destination cannot bypass a stored personal approval guard',
      () async {
    await approve();
    final context = MedicalBillContext(
        profileId: h.ownerId,
        sharedSpaceId: 99,
        budgetId: h.budgetId,
        yearMonth: '2026-10',
        primaryCurrency: 'huf');
    await expectLater(
        repo.saveBill(copyMedicalBill(bill)..sharedSpaceId = 99, context,
            status: ExpenseStatus.paid),
        throwsFormatException);
    expect((await h.db.medicalBills.get(bill.id))!.sharedSpaceId, isNull);
    expect((await h.db.expenses.get(expense.id))!.sharedSpaceId, isNull);
  });
  test(
      'an unmatched legacy received total is held for review instead of paid twice',
      () async {
    await approve();
    await h.db.writeTxn(() async {
      final old = (await h.db.medicalBills.get(bill.id))!
        ..reimbursedAmount = 8000;
      await h.db.medicalBills.put(old);
    });
    await expectLater(
        service.preview(
            billId: bill.id,
            actorId: h.ownerId,
            amountMinor: 8000,
            receivedAt: now,
            destinationMonth: '2026-10',
            isAccessCurrent: () => true),
        throwsA(isA<MedicalReceiptException>()
            .having((e) => e.code, 'code', 'legacyNeedsReview')));
    expect(await h.db.reimbursements.count(), 0);
    expect((await history()).claimLabel, 'Legacy payment needs review');
    expect((await h.db.medicalBills.get(bill.id))!.reimbursedAmount, 8000);
  });
  test(
      'confirmed profile deletion removes its private claim history and keeps other/shared approvals',
      () async {
    await approve();
    // Seed a known personal activity and unrelated scopes in a disposable DB.
    late int other;
    await h.db.writeTxn(() async {
      other = await h.db.userProfiles.put(UserProfile()
        ..name = 'Other fixture'
        ..monthlyAvailableAmount = 0
        ..primaryCurrency = PrimaryCurrency.huf
        ..createdAt = now
        ..updatedAt = now);
      await h.db.medicalClaimActivitys.put(MedicalClaimActivity()
        ..billGuid = bill.syncGuid
        ..profileId = h.ownerId
        ..yearMonth = '2026-10'
        ..kind = 'submitted'
        ..submittedAt = DateTime.utc(2026, 10, 21)
        ..reason = ''
        ..currency = 'huf'
        ..recordedAt = now
        ..actorId = h.ownerId
        ..operationIdentity = 'fixture-activity'
        ..inputFingerprint = 'fixture');
      for (final shared in [false, true]) {
        await h.db.medicalApprovals.put(MedicalApproval()
          ..billGuid = 'unrelated'
          ..profileId = shared ? h.ownerId : other
          ..sharedSpaceId = shared ? 99 : null
          ..yearMonth = '2026-10'
          ..approvedMinor = 500
          ..currency = 'huf'
          ..decisionDate = now
          ..recordedAt = now
          ..actorId = other
          ..operationIdentity = 'other-$shared'
          ..inputFingerprint = 'fixture');
      }
    });
    await ProfileSwitcherController(h.db)
        .deleteProfile(h.ownerId, activeProfileId: h.ownerId);
    expect(
        await h.db.medicalClaimActivitys
            .filter()
            .profileIdEqualTo(h.ownerId)
            .count(),
        0);
    expect(await h.db.medicalApprovals.count(), 2);
    expect(await h.db.userProfiles.get(other), isNotNull);
  });
  test('stale calendar metadata cannot overwrite a reviewed bill correction',
      () async {
    await approve();
    final review = await repo.reviewBill(
        proposed: copyMedicalBill(bill)..billedAmount = 12000,
        status: ExpenseStatus.paid,
        reason: 'Invoice correction',
        isAccessCurrent: () => true);
    await repo.applyBillReview(
        review: review,
        operationKey: 'correction',
        isAccessCurrent: () => true);
    await repo.setCalendarEventId(bill, 'fixture-event');
    final stored = (await h.db.medicalBills.get(bill.id))!;
    expect(stored.billedAmount, 12000);
    expect(stored.calendarEventId, 'fixture-event');
    expect((await h.db.expenses.get(expense.id))!.amount, 12000);
  });
}
