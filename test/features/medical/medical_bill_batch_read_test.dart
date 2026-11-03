import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/reconciliation_snapshot.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import 'package:budget_buddy/core/services/receipt_snapshot_repository.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/medical/presentation/medical_bill_view_state.dart';
import '../../support/receipt_financial_harness.dart';

void main() {
  late ReceiptFinancialHarness h;
  late MedicalReceiptService service;
  setUp(() async {
    h = await ReceiptFinancialHarness.create();
    service = MedicalReceiptService(h.db);
  });
  tearDown(() async => h.close());

  Future<MedicalBill> seed({int? owner, String month = '2026-10'}) async {
    final expense = h.expense(owner: owner, month: month)
      ..type = ExpenseType.medical
      ..status = ExpenseStatus.paid;
    final bill = MedicalBill()
      ..profileId = owner ?? h.ownerId
      ..yearMonth = month
      ..currency = 'huf'
      ..billedAmount = 10000
      ..patientSharePercent = 20
      ..state = MedicalBillState.waiting;
    await h.db.writeTxn(() async {
      expense.id = await h.db.expenses.put(expense);
      bill.linkedExpenseId = expense.id;
      bill.id = await h.db.medicalBills.put(bill);
    });
    return bill;
  }

  Future<MedicalHistoryBatch> read({bool Function()? access}) =>
      service.historyBatch(
          context: h.context(),
          actorId: h.ownerId,
          isAccessCurrent: access ?? () => true);
  Matcher code(String value) =>
      isA<MedicalReceiptException>().having((e) => e.code, 'code', value);

  test('batch matches single history and does not change money or old dates',
      () async {
    final bill = await seed();
    final approval = MedicalApproval()
      ..billGuid = bill.syncGuid
      ..profileId = h.ownerId
      ..yearMonth = '2026-10'
      ..currency = 'huf'
      ..approvedMinor = 8000
      ..decisionDate = DateTime.utc(2026, 10, 20)
      ..recordedAt = DateTime.utc(2026, 10, 20)
      ..actorId = h.ownerId
      ..operationIdentity = 'fixture-decision'
      ..inputFingerprint = 'fixture';
    await h.db.writeTxn(() async {
      await h.db.medicalApprovals.put(approval);
      await h.db.reimbursements.put(Reimbursement(
          profileId: h.ownerId,
          expenseId: bill.linkedExpenseId!,
          originYearMonth: '2026-10',
          amount: 6000,
          currency: 'huf',
          date: DateTime.utc(2026, 10, 22)));
    });
    Future<String> stored() async => jsonEncode([
          await h.db.medicalBills.where().exportJson(),
          await h.db.expenses.where().exportJson(),
          await h.db.medicalApprovals.where().exportJson(),
          await h.db.reimbursements.where().exportJson(),
          await h.db.medicalClaimActivitys.where().exportJson(),
          await h.db.medicalClaimClosures.where().exportJson(),
        ]);
    final before = await stored();
    final single = await service.history(
        billId: bill.id, actorId: h.ownerId, isAccessCurrent: () => true);
    final batch = await read();
    final history = batch.histories[bill.id]!;
    expect(history.receivedMinor, single.receivedMinor);
    expect(history.remainingMinor, single.remainingMinor);
    expect(history.approval?.syncGuid, single.approval?.syncGuid);
    expect(history.submitted, false);
    expect(history.activities, isEmpty);
    expect(await stored(), before);
    final facts = MedicalBillFacts.fromHistory(bill, history);
    bill.billedAmount = 99999;
    history.expense.status = ExpenseStatus.planned;
    expect(facts.billedMinor, 10000);
    expect(facts.providerPaid, true);
    expect(facts.submission, MedicalSubmission.unknown);
  });
  test('only selected owner and month rows appear', () async {
    final selected = await seed();
    await seed(owner: h.ownerId + 50);
    await seed(month: '2026-09');
    final batch = await read();
    expect(batch.bills.map((b) => b.id), [selected.id]);
    await expectLater(
        service.historyBatch(
            context: ContextRef.personal(
                profileId: h.ownerId + 50, yearMonth: '2026-10'),
            actorId: h.ownerId,
            isAccessCurrent: () => true),
        throwsA(code('wrongOwner')));
  });
  test('access loss during read aborts instead of publishing partial facts',
      () async {
    await seed();
    var checks = 0;
    await expectLater(
        read(access: () => ++checks < 3),
        throwsA(anyOf(
            code('accessChanged'),
            isA<ReceiptGuardException>()
                .having((e) => e.code, 'code', 'accessChanged'))));
    expect(checks, greaterThanOrEqualTo(3));
  });
  test('duplicate expense link remains review not paid zero', () async {
    final bill = await seed();
    await h.db.writeTxn(() async {
      await h.db.medicalBills.put(MedicalBill()
        ..profileId = h.ownerId + 50
        ..yearMonth = '2026-09'
        ..linkedExpenseId = bill.linkedExpenseId);
    });
    final batch = await read();
    expect(batch.histories, isEmpty);
    expect(batch.issues[bill.id], 'legacyNeedsReview');
    final facts = MedicalBillFacts.fromHistory(bill, null, readIssue: true);
    expect(facts.receivedMinor, isNull);
    expect(facts.needsReview, true);
  });
  test('corrupt refund is a review issue isolated from healthy bills',
      () async {
    final bad = await seed();
    final good = await seed();
    await h.db.writeTxn(() async {
      await h.db.reimbursements.put(Reimbursement(
          profileId: h.ownerId,
          expenseId: bad.linkedExpenseId!,
          originYearMonth: '2026-10',
          amount: 6000,
          currency: 'usd',
          date: DateTime.utc(2026, 10, 22)));
    });
    final batch = await read();
    expect(batch.issues[bad.id], 'legacyNeedsReview');
    expect(batch.histories.containsKey(good.id), true);
  });
  test('foreign decision is rejected, never disclosed as a valid history',
      () async {
    final bill = await seed();
    await h.db.writeTxn(() async {
      await h.db.medicalApprovals.put(MedicalApproval()
        ..billGuid = bill.syncGuid
        ..profileId = h.ownerId + 50
        ..yearMonth = '2026-10'
        ..currency = 'huf'
        ..approvedMinor = 8000
        ..decisionDate = DateTime.utc(2026, 10, 20)
        ..recordedAt = DateTime.utc(2026, 10, 20)
        ..actorId = h.ownerId + 50
        ..operationIdentity = 'bad-owner'
        ..inputFingerprint = 'fixture');
    });
    await expectLater(read(), throwsA(code('wrongOwner')));
  });
  test('missing budget is a real blocker, not successful empty readiness',
      () async {
    await seed();
    await h.db.writeTxn(() async {
      await h.db.monthlyBudgets.delete(h.budgetId);
    });
    expect((await read()).blockers, contains(ReceiptBlocker.missingMonth));
  });
  test('unmatched old received scalar remains unknown, not paid again',
      () async {
    final bill = await seed();
    await h.db.writeTxn(() async {
      bill.reimbursedAmount = 8000;
      await h.db.medicalBills.put(bill);
    });
    final batch = await read();
    final facts = MedicalBillFacts.fromHistory(bill, batch.histories[bill.id]);
    expect(facts.receivedMinor, isNull);
    expect(facts.submission, MedicalSubmission.unknown);
    expect(await h.db.reimbursements.count(), 0);
  });
  test('direct insurer paid expense never manufactures share settlement',
      () async {
    final bill = await seed();
    await h.db.writeTxn(() async {
      bill.paymentMethod = MedicalPaymentMethod.insurerPaid;
      bill.state = MedicalBillState.paid;
      await h.db.medicalBills.put(bill);
    });
    final batch = await read();
    final facts = MedicalBillFacts.fromHistory(bill, batch.histories[bill.id]);
    expect(facts.directProviderSettlement, MedicalEvidence.unknown);
    expect(facts.shareSettlement, MedicalEvidence.unknown);
  });
  test('legacy finished scalar without closure evidence remains review',
      () async {
    final bill = await seed();
    await h.db.writeTxn(() async {
      bill.state = MedicalBillState.finished;
      await h.db.medicalBills.put(bill);
    });
    final batch = await read();
    final facts = MedicalBillFacts.fromHistory(bill, batch.histories[bill.id]);
    expect(facts.closed, false);
    expect(facts.needsReview, true);
  });
  test(
      'invalid stored percentage cannot produce a fabricated zero-share figure',
      () async {
    final bill = await seed();
    final history = (await read()).histories[bill.id];
    bill.patientSharePercent = double.nan;
    final facts = MedicalBillFacts.fromHistory(bill, history);
    expect(facts.needsReview, true);
    expect(facts.currency, isNull);
  });
  test('missing linked expense is review, not an unpaid default', () async {
    final bill = await seed();
    await h.db.writeTxn(() async {
      await h.db.expenses.delete(bill.linkedExpenseId!);
    });
    final batch = await read();
    expect(batch.issues[bill.id], 'missingExpense');
    expect(MedicalBillFacts.fromHistory(bill, null).providerPaid, isNull);
  });
  test('shared viewer reads legacy facts only; revoked member is refused',
      () async {    final private = await seed();
    final space = SharedSpace()
      ..name = 'Fixture space'
      ..currency = PrimaryCurrency.huf
      ..createdByProfileId = h.ownerId
      ..createdAt = DateTime.utc(2026, 10);
    final member = SharedMember()
      ..profileId = h.ownerId
      ..role = SharedMemberRole.viewer
      ..joinedAt = DateTime.utc(2026, 10);
    final shared = MedicalBill()
      ..yearMonth = '2026-10'
      ..currency = 'huf'
      ..billedAmount = 10000;
    await h.db.writeTxn(() async {
      space.id = await h.db.sharedSpaces.put(space);
      member.sharedSpaceId = space.id;
      member.id = await h.db.sharedMembers.put(member);
      final expense = h.expense()
        ..profileId = 0
        ..sharedSpaceId = space.id
        ..type = ExpenseType.medical;
      expense.id = await h.db.expenses.put(expense);
      shared.sharedSpaceId = space.id;
      shared.linkedExpenseId = expense.id;
      shared.id = await h.db.medicalBills.put(shared);
    });
    Future<MedicalHistoryBatch> readSpace() => service.historyBatch(
        context: ContextRef.shared(spaceId: space.id, yearMonth: '2026-10'),
        actorId: h.ownerId,
        isAccessCurrent: () => true);
    final batch = await readSpace();
    expect(batch.bills.map((b) => b.id), [shared.id]);
    expect(batch.histories.containsKey(private.id), false);
    expect(batch.histories[shared.id]!.activities, isEmpty);
    await h.db.writeTxn(() async {
      member.revokedAt = DateTime.utc(2026, 10, 30);
      await h.db.sharedMembers.put(member);
    });
    await expectLater(readSpace(), throwsA(code('notPermitted')));
  });

  test('inbox batch spans months with per-bill readiness and owner isolation',
      () async {
    final september = await seed(month: '2026-09');
    final october = await seed();
    await seed(owner: h.ownerId + 50);
    final inbox = await service.historyInboxBatch(
        context: ContextRef.personal(
            profileId: h.ownerId, yearMonth: '2026-11'),
        actorId: h.ownerId,
        isAccessCurrent: () => true);
    expect(inbox.bills.map((b) => b.id).toSet(),
        {september.id, october.id});
    expect(inbox.blockersByBill.containsKey(september.id), true);
    expect(inbox.blockersByBill[september.id],
        contains(ReceiptBlocker.missingMonth));
    expect(inbox.blockersByBill[october.id],
        isNot(contains(ReceiptBlocker.missingMonth)));
    expect(inbox.blockers, isNull);
  });
}
