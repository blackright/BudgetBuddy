import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/income_receipt_group.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/medical_settlement_event.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/core/services/medical_settlement_service.dart';
import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import 'package:budget_buddy/core/services/medical_withholding_service.dart';
import 'package:budget_buddy/core/services/profile_spending_service.dart';
import 'package:budget_buddy/features/medical/presentation/medical_bill_state_resolver.dart';
import 'package:budget_buddy/features/medical/presentation/medical_bill_view_state.dart';
import '../../support/receipt_financial_harness.dart';

void main() {
  late ReceiptFinancialHarness f;
  late Isar db;
  final now = DateTime.utc(2026, 10, 28, 16);

  setUp(() async {
    f = await ReceiptFinancialHarness.create();
    db = f.db;
  });

  tearDown(() => f.close());

  Future<({MedicalBill bill, Expense expense})> seed({
    int billed = 10000,
    double share = 20,
  }) async {
    late MedicalBill bill;
    late Expense expense;
    await db.writeTxn(() async {
      expense = f.expense()
        ..type = ExpenseType.medical
        ..amount = (billed * share / 100).round()
        ..status = ExpenseStatus.paid
        ..paidAt = now;
      expense.id = await db.expenses.put(expense);
      bill = MedicalBill()
        ..profileId = f.ownerId
        ..linkedExpenseId = expense.id
        ..yearMonth = '2026-10'
        ..serviceDate = now
        ..billedAmount = billed
        ..currency = 'huf'
        ..patientSharePercent = share
        ..paymentMethod = MedicalPaymentMethod.insurerPaid
        ..state = MedicalBillState.paid;
      bill.id = await db.medicalBills.put(bill);
    });
    return (bill: bill, expense: expense);
  }

  Future<void> receipt(String guid) => db.writeTxn(() async {
        await db.incomeReceiptGroups.put(IncomeReceiptGroup()
          ..guid = guid
          ..profileId = f.ownerId
          ..sourceGuid = 'source-1'
          ..cycleGuid = 'cycle-1'
          ..actualDate = now
          ..timezone = 'UTC'
          ..totalMinor = 500000
          ..currency = 'huf'
          ..destinationMonth = '2026-10'
          ..fingerprint = 'fp-$guid'
          ..operationIdentity = 'receipt-$guid'
          ..createdAt = now
          ..updatedAt = now);
      });

  MedicalSettlementService service() =>
      MedicalSettlementService(db, clock: () => now);

  test('provider and separate share are independent, one cash booking', () async {
    final fixture = await seed();
    final s = service();
    final provider = await s.recordProviderSettlement(
      billId: fixture.bill.id,
      actorId: f.ownerId,
      effectiveDate: DateTime.utc(2026, 10, 20),
      confirmed: true,
      operationKey: 'provider-1',
      isAccessCurrent: () => true,
    );
    final share = await s.recordSharePayment(
      billId: fixture.bill.id,
      actorId: f.ownerId,
      amountMinor: 2000,
      effectiveDate: DateTime.utc(2026, 10, 21),
      operationKey: 'share-1',
      isAccessCurrent: () => true,
    );

    expect(provider.kind, MedicalSettlementKind.insurerProviderSettlement);
    expect(provider.amountMinor, 8000);
    expect(share.kind, MedicalSettlementKind.shareSettlement);
    expect(share.amountMinor, 2000);
    expect(await db.expenses.count(), 1);
    expect((await db.expenses.get(fixture.expense.id))!.amount, 2000);
    final active = activeSettlements(await s.eventsForBill(fixture.bill.syncGuid));
    expect(active.length, 2);
  });

  test('salary withholding resolves share without a second cash deduction',
      () async {
    final fixture = await seed();
    await receipt('salary-1');
    final withholding = MedicalWithholdingService(db, clock: () => now);
    final match = await withholding.match(
      profileId: f.ownerId,
      billGuid: fixture.bill.syncGuid,
      salaryReceiptGroupGuid: 'salary-1',
      withheldMinor: 2000,
      currency: 'huf',
      affectedMonths: ['2026-10'],
      isAccessCurrent: () => true,
    );

    final s = service();
    await expectLater(
        s.recordSharePayment(
          billId: fixture.bill.id,
          actorId: f.ownerId,
          amountMinor: 2000,
          effectiveDate: now,
          operationKey: 'share',
          isAccessCurrent: () => true,
        ),
        throwsA(isA<MedicalSettlementException>()));
    expect(match.withheldMinor, 2000);
    expect(await db.expenses.count(), 1);
    expect((await db.expenses.get(fixture.expense.id))!.amount, 2000);

    // Cash consumers can exclude the already-netted expense; cost is unchanged.
    final expenses = await db.expenses.where().findAll();
    const spending = ProfileSpendingService();
    expect(
        spending.spentInYearMonth(
            profileId: null,
            yearMonth: '2026-10',
            expenses: expenses,
            convert: (e) => e.amount),
        2000);
    expect(
        spending.spentInYearMonth(
            profileId: null,
            yearMonth: '2026-10',
            expenses: expenses,
            excludedExpenseIds: {fixture.expense.id},
            convert: (e) => e.amount),
        0);
  });

  test('zero share closes after provider settlement with no fake payment',
      () async {
    final fixture = await seed(billed: 10000, share: 0);
    final s = service();
    await s.recordProviderSettlement(
      billId: fixture.bill.id,
      actorId: f.ownerId,
      effectiveDate: DateTime.utc(2026, 10, 20),
      confirmed: true,
      operationKey: 'provider-zero',
      isAccessCurrent: () => true,
    );
    final closure = await s.closeBill(
      billId: fixture.bill.id,
      actorId: f.ownerId,
      reason: 'Insurer paid in full',
      operationKey: 'close-zero',
      isAccessCurrent: () => true,
    );
    expect(closure.kind, MedicalSettlementKind.closure);
    expect(await db.medicalClaimClosures.count(), 0);
    expect(await db.medicalApprovals.count(), 0);
    expect(await db.expenses.count(), 1);
  });

  test('100 percent share requires the share before close', () async {
    final fixture = await seed(billed: 10000, share: 100);
    final s = service();
    await s.recordProviderSettlement(
      billId: fixture.bill.id,
      actorId: f.ownerId,
      effectiveDate: DateTime.utc(2026, 10, 20),
      confirmed: true,
      operationKey: 'provider-100',
      isAccessCurrent: () => true,
    );
    await expectLater(
        s.closeBill(
          billId: fixture.bill.id,
          actorId: f.ownerId,
          reason: 'try early',
          operationKey: 'close-early',
          isAccessCurrent: () => true,
        ),
        throwsA(isA<MedicalSettlementException>()));
    await s.recordSharePayment(
      billId: fixture.bill.id,
      actorId: f.ownerId,
      amountMinor: 10000,
      effectiveDate: now,
      operationKey: 'share-100',
      isAccessCurrent: () => true,
    );
    final closure = await s.closeBill(
      billId: fixture.bill.id,
      actorId: f.ownerId,
      reason: 'Share paid',
      operationKey: 'close-100',
      isAccessCurrent: () => true,
    );
    expect(closure.kind, MedicalSettlementKind.closure);
  });

  test('identical retry returns the prior event; a changed retry is refused',
      () async {
    final fixture = await seed();
    final s = service();
    final first = await s.recordProviderSettlement(
      billId: fixture.bill.id,
      actorId: f.ownerId,
      effectiveDate: DateTime.utc(2026, 10, 20),
      confirmed: true,
      operationKey: 'provider-retry',
      isAccessCurrent: () => true,
    );
    final retry = await s.recordProviderSettlement(
      billId: fixture.bill.id,
      actorId: f.ownerId,
      effectiveDate: DateTime.utc(2026, 10, 20),
      confirmed: true,
      operationKey: 'provider-retry',
      isAccessCurrent: () => true,
    );
    expect(retry.syncGuid, first.syncGuid);
    expect(await db.medicalSettlements.count(), 1);
    await expectLater(
        s.recordProviderSettlement(
          billId: fixture.bill.id,
          actorId: f.ownerId,
          effectiveDate: DateTime.utc(2026, 10, 21),
          confirmed: true,
          operationKey: 'provider-retry',
          isAccessCurrent: () => true,
        ),
        throwsA(isA<MedicalSettlementException>()));
  });

  test('partial share, access changes and legacy ownership are refused',
      () async {
    final fixture = await seed();
    final s = service();
    await s.recordProviderSettlement(
      billId: fixture.bill.id,
      actorId: f.ownerId,
      effectiveDate: DateTime.utc(2026, 10, 20),
      confirmed: true,
      operationKey: 'provider',
      isAccessCurrent: () => true,
    );
    await expectLater(
        s.recordSharePayment(
          billId: fixture.bill.id,
          actorId: f.ownerId,
          amountMinor: 1000,
          effectiveDate: now,
          operationKey: 'partial',
          isAccessCurrent: () => true,
        ),
        throwsA(isA<MedicalSettlementException>()));
    await expectLater(
        s.recordSharePayment(
          billId: fixture.bill.id,
          actorId: f.ownerId,
          amountMinor: 2000,
          effectiveDate: now,
          operationKey: 'access',
          isAccessCurrent: () => false,
        ),
        throwsA(isA<MedicalSettlementException>()));
    await expectLater(
        s.recordSharePayment(
          billId: fixture.bill.id,
          actorId: f.ownerId + 1,
          amountMinor: 2000,
          effectiveDate: now,
          operationKey: 'owner',
          isAccessCurrent: () => true,
        ),
        throwsA(isA<MedicalSettlementException>()));
  });

  test('a legacy paid share expense is retained, never duplicated', () async {
    final fixture = await seed();
    final s = service();
    await s.recordProviderSettlement(
      billId: fixture.bill.id,
      actorId: f.ownerId,
      effectiveDate: DateTime.utc(2026, 10, 20),
      confirmed: true,
      operationKey: 'provider-legacy',
      isAccessCurrent: () => true,
    );
    await s.recordSharePayment(
      billId: fixture.bill.id,
      actorId: f.ownerId,
      amountMinor: 2000,
      effectiveDate: now,
      operationKey: 'share-legacy',
      isAccessCurrent: () => true,
    );
    final rows = await db.expenses.where().findAll();
    expect(rows.length, 1);
    expect(rows.single.status, ExpenseStatus.paid);
    expect(rows.single.amount, 2000);
    expect(await db.reimbursements.count(), 0);
  });

  test('joined evidence resolves direct bill to close then closed', () async {
    final fixture = await seed();
    final s = service();
    await s.recordProviderSettlement(
      billId: fixture.bill.id,
      actorId: f.ownerId,
      effectiveDate: DateTime.utc(2026, 10, 20),
      confirmed: true,
      operationKey: 'provider-join',
      isAccessCurrent: () => true,
    );
    await s.recordSharePayment(
      billId: fixture.bill.id,
      actorId: f.ownerId,
      amountMinor: 2000,
      effectiveDate: now,
      operationKey: 'share-join',
      isAccessCurrent: () => true,
    );
    final receipt = MedicalReceiptService(db, clock: () => now);
    final history = await receipt.history(
        billId: fixture.bill.id,
        actorId: f.ownerId,
        isAccessCurrent: () => true);
    var facts = MedicalBillFacts.fromHistory(history.bill, history);
    expect(facts.directProviderSettlement, MedicalEvidence.confirmed);
    expect(facts.shareSettlement, MedicalEvidence.confirmed);
    var view = const MedicalBillStateResolver().resolve(facts,
        canEdit: true, readiness: MedicalReadiness.ready(), now: now);
    expect(view.primaryAction, MedicalBillAction.closeBill);

    await s.closeBill(
      billId: fixture.bill.id,
      actorId: f.ownerId,
      reason: 'Settled',
      operationKey: 'close-join',
      isAccessCurrent: () => true,
    );
    final closed = await receipt.history(
        billId: fixture.bill.id,
        actorId: f.ownerId,
        isAccessCurrent: () => true);
    facts = MedicalBillFacts.fromHistory(closed.bill, closed);
    view = const MedicalBillStateResolver().resolve(facts,
        canEdit: true, readiness: MedicalReadiness.ready(), now: now);
    expect(view.primaryAction, MedicalBillAction.viewActivity);
    expect(view.headline, 'Closed');
  });

  test('legacy direct bill without evidence stays Needs review', () async {
    final fixture = await seed();
    final bill = (await db.medicalBills.get(fixture.bill.id))!;
    final history = MedicalReceiptHistory(
      bill: bill,
      expense: fixture.expense,
      approvals: const [],
      returns: const [],
      revisions: const [],
      receivedMinor: 0,
      closure: null,
    );
    final facts = MedicalBillFacts.fromHistory(bill, history);
    expect(facts.directProviderSettlement, MedicalEvidence.unknown);
    final view = const MedicalBillStateResolver().resolve(facts,
        canEdit: true, readiness: MedicalReadiness.ready(), now: now);
    expect(view.headline, 'Needs review');
    expect(view.primaryAction, MedicalBillAction.reviewBill);
  });
}
