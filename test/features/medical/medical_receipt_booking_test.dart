import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/money_receipt.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/month_rate_seal.dart';
import 'package:budget_buddy/core/services/audit_financial_state.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/financial_report.dart';
import 'package:budget_buddy/core/services/report_calculation.dart';
import 'package:budget_buddy/core/services/fx_booking_service.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/vault/personal_month_funds.dart';
import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import 'package:budget_buddy/core/models/balance_checkpoint.dart';
import 'package:budget_buddy/core/services/financial_adoption_service.dart';
import 'package:budget_buddy/core/services/balance_checkpoint_service.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import '../../support/receipt_financial_harness.dart';

void main() {
  late ReceiptFinancialHarness h;
  late MedicalReceiptService service;
  late int billId;
  final now = DateTime.utc(2026, 10, 28, 16);
  setUp(() async {
    h = await ReceiptFinancialHarness.create();
    await h.db.writeTxn(() async {
      final expense = h.expense()
        ..amount = 10000
        ..type = ExpenseType.medical
        ..paidAt = DateTime.utc(2026, 10, 20);
      expense.id = await h.db.expenses.put(expense);
      billId = await h.db.medicalBills.put(MedicalBill()
        ..profileId = h.ownerId
        ..yearMonth = '2026-10'
        ..serviceDate = DateTime.utc(2026, 10, 20)
        ..billedAmount = 10000
        ..currency = 'huf'
        ..paymentMethod = MedicalPaymentMethod.selfPaid
        ..state = MedicalBillState.paid
        ..linkedExpenseId = expense.id);
    });
    service = MedicalReceiptService(h.db, clock: () => now);
    final adoption = FinancialAdoptionService(h.db, clock: () => now);
    final a = await adoption.preview(
        context: h.context(), actorId: h.ownerId, isAccessCurrent: () => true);
    await adoption.confirm(
        preview: a, operationKey: 'adopt', isAccessCurrent: () => true);
    final checkpoint = BalanceCheckpointService(h.db, clock: () => now);
    final sources = await checkpoint.load(
        context: h.context(), actorId: h.ownerId, isAccessCurrent: () => true);
    final c = await checkpoint.preview(
        sources: sources,
        draft: CheckpointDraft(
            balanceMinor: 600000,
            balanceAsOf: DateTime.utc(2026, 10, 1),
            localZone: 'UTC',
            pool: 'Fixture bank',
            choices: sources.movements.map((m) => MovementChoice(
                key: m.key,
                revision: m.revision,
                role: 'later',
                actualAt: m.actualAt))),
        isAccessCurrent: () => true);
    await checkpoint.confirm(
        preview: c, operationKey: 'checkpoint', isAccessCurrent: () => true);
  });
  tearDown(() async => h.close());
  Future<MedicalApproval> approve() => service.approve(
      billId: billId,
      actorId: h.ownerId,
      amountMinor: 8000,
      decisionDate: DateTime.utc(2026, 10, 22),
      operationKey: 'approval',
      isAccessCurrent: () => true);
  test('approval records waiting with zero cash and unchanged original expense',
      () async {
    final before = await h.db.expenses.where().exportJson();
    final a = await approve();
    expect(a.approvedMinor, 8000);
    expect(await h.db.reimbursements.count(), 0);
    expect(await h.db.moneyReceipts.count(), 0);
    expect(await h.db.expenses.where().exportJson(), before);
    expect(await h.db.auditEvents.count(), greaterThan(0));
    final again = await approve();
    expect(again.syncGuid, a.syncGuid);
  });
  test(
      'full receipt clears the remaining refund; retry never adds another payment',
      () async {
    await approve();
    final preview = await service.preview(
        billId: billId,
        actorId: h.ownerId,
        amountMinor: 8000,
        receivedAt: DateTime.utc(2026, 10, 27),
        destinationMonth: '2026-10',
        isAccessCurrent: () => true);
    final receipt = await h.db.writeTxn(() => service.recordInTransaction(
        preview: preview, operationKey: 'full', isAccessCurrent: () => true));
    final retry = await h.db.writeTxn(() => service.recordInTransaction(
        preview: preview, operationKey: 'full', isAccessCurrent: () => true));
    expect(retry.syncGuid, receipt.syncGuid);
    final state = await service.history(
        billId: billId, actorId: h.ownerId, isAccessCurrent: () => true);
    expect(state.receivedMinor, 8000);
    expect(state.remainingMinor, 0);
    expect(await h.db.reimbursements.count(), 1);
    expect((await h.db.expenses.where().findFirst())!.amount, 10000);
  });
  test('above approval and stale amount fail without partial financial writes',
      () async {
    await approve();
    await expectLater(
        service.preview(
            billId: billId,
            actorId: h.ownerId,
            amountMinor: 9000,
            receivedAt: now,
            destinationMonth: '2026-10',
            isAccessCurrent: () => true),
        throwsA(isA<MedicalReceiptException>()));
    expect(await h.db.reimbursements.count(), 0);
  });
  test('changed paid movement needs review before another receipt', () async {
    await approve();
    await h.db.writeTxn(() async {
      final expense = (await h.db.expenses.where().findFirst())!
        ..amount = 11000;
      await h.db.expenses.put(expense);
    });
    await expectLater(
        service.preview(
            billId: billId,
            actorId: h.ownerId,
            amountMinor: 8000,
            receivedAt: DateTime.utc(2026, 10, 27),
            destinationMonth: '2026-10',
            isAccessCurrent: () => true),
        throwsA(isA<MedicalReceiptException>()
            .having((error) => error.code, 'code', 'legacyNeedsReview')));
    expect(await h.db.moneyReceipts.count(), 0);
    expect(await h.db.reimbursements.count(), 0);
  });

  test('partial receipt is refused', () async {
    await approve();
    await expectLater(
        service.preview(
            billId: billId,
            actorId: h.ownerId,
            amountMinor: 6000,
            receivedAt: DateTime.utc(2026, 10, 27),
            destinationMonth: '2026-10',
            isAccessCurrent: () => true),
        throwsA(isA<MedicalReceiptException>()
            .having((error) => error.code, 'code', 'partialUnsupported')));
  });

  test('audit failure rolls back identity, revision and projected money',
      () async {
    await approve();
    final p = await service.preview(
        billId: billId,
        actorId: h.ownerId,
        amountMinor: 8000,
        receivedAt: DateTime.utc(2026, 10, 27),
        destinationMonth: '2026-10',
        isAccessCurrent: () => true);
    // Disposable corruption fixture: a chain head without its tip must refuse
    // the required append, never leave a financial write without history.
    await h.db.writeTxn(() => h.db.auditEvents.clear());
    await expectLater(
        h.db.writeTxn(() => service.recordInTransaction(
            preview: p,
            operationKey: 'audit-fail',
            isAccessCurrent: () => true)),
        throwsStateError);
    expect(await h.db.moneyReceipts.count(), 0);
    expect(await h.db.receiptRevisions.count(), 0);
    expect(await h.db.reimbursements.count(), 0);
  });

  test(
      'amount correction appends revisions and recalculates dependent principal',
      () async {
    await approve();
    Future<MoneyReceipt> receive(int amount, String key) async {
      final p = await service.preview(
          billId: billId,
          actorId: h.ownerId,
          amountMinor: amount,
          receivedAt: DateTime.utc(2026, 10, 27),
          destinationMonth: '2026-10',
          isAccessCurrent: () => true);
      return h.db.writeTxn(() => service.recordInTransaction(
          preview: p, operationKey: key, isAccessCurrent: () => true));
    }

    final first = await receive(8000, 'first');
    final p = await service.previewCorrection(
        billId: billId,
        actorId: h.ownerId,
        receiptGuid: first.syncGuid,
        amountMinor: 7000,
        receivedAt: DateTime.utc(2026, 10, 27),
        destinationMonth: '2026-10',
        reason: 'Correct actual amount',
        alreadyIncluded: false,
        isAccessCurrent: () => true);
    await h.db.writeTxn(() => service.correctInTransaction(
        preview: p, operationKey: 'correction', isAccessCurrent: () => true));
    final state = await service.history(
        billId: billId, actorId: h.ownerId, isAccessCurrent: () => true);
    expect(state.receivedMinor, 7000);
    expect(state.remainingMinor, 1000);
    expect(await h.db.receiptRevisions.count(), 2);
    expect((await h.db.expenses.where().findFirst())!.amount, 10000);
  });

  test('new November receipt can reference a closed October cost month',
      () async {
    final later = DateTime.utc(2026, 11, 15, 12);
    await h.db.writeTxn(() async {
      await h.db.monthlyBudgets.put(MonthlyBudget()
        ..profileId = h.ownerId
        ..yearMonth = '2026-11'
        ..baseAvailableAmount = 100000
        ..openingBalanceConfirmed = true
        ..createdAt = later
        ..updatedAt = later);
      await h.db.monthRateSeals.put(MonthRateSeal()
        ..yearMonth = '2026-10'
        ..asOf = now
        ..fetchedAt = now
        ..updatedAt = now);
    });
    final checkpoints = BalanceCheckpointService(h.db, clock: () => later);
    final s = await checkpoints.load(
        context: h.context('2026-11'),
        actorId: h.ownerId,
        isAccessCurrent: () => true);
    final c = await checkpoints.preview(
        sources: s,
        draft: CheckpointDraft(
            balanceMinor: 100000,
            balanceAsOf: DateTime.utc(2026, 11, 1),
            localZone: 'UTC',
            pool: 'Bank',
            choices: []),
        isAccessCurrent: () => true);
    await checkpoints.confirm(
        preview: c, operationKey: 'nov', isAccessCurrent: () => true);
    final current = MedicalReceiptService(h.db, clock: () => later);
    await current.approve(
        billId: billId,
        actorId: h.ownerId,
        amountMinor: 8000,
        decisionDate: DateTime.utc(2026, 11, 12),
        operationKey: 'nov-approval',
        isAccessCurrent: () => true);
    final before = await h.db.expenses.where().exportJson();
    final p = await current.preview(
        billId: billId,
        actorId: h.ownerId,
        amountMinor: 8000,
        receivedAt: DateTime.utc(2026, 11, 14),
        destinationMonth: '2026-11',
        isAccessCurrent: () => true);
    await h.db.writeTxn(() => current.recordInTransaction(
        preview: p, operationKey: 'nov-received', isAccessCurrent: () => true));
    expect((await h.db.reimbursements.where().findFirst())!.originYearMonth,
        '2026-11');
    expect(await h.db.expenses.where().exportJson(), before);
    await expectLater(
        current.previewCorrection(
            billId: billId,
            actorId: h.ownerId,
            receiptGuid:
                (await h.db.reimbursements.where().findFirst())!.syncGuid,
            amountMinor: 8000,
            receivedAt: DateTime.utc(2026, 10, 27),
            destinationMonth: '2026-10',
            reason: 'Wrong date',
            alreadyIncluded: false,
            isAccessCurrent: () => true),
        throwsA(isA<MedicalReceiptException>()));
  });
  test(
      'Free to spend, reserve, reviewed bank and report reconcile to one refund',
      () async {
    await h.db.writeTxn(() async {
      final month = (await h.db.monthlyBudgets.get(h.budgetId))!
        ..netSalaryOverride = 100000;
      await h.db.monthlyBudgets.put(month);
    });
    final rates = RateTableRegistry();
    final before = await h.db
        .txn(() => readPersonalMonthFunds(h.db, h.ownerId, '2026-10', rates));
    expect(before['available'], 90000);
    expect(before['reserve'], 90000);
    await approve();
    final approved = await h.db
        .txn(() => readPersonalMonthFunds(h.db, h.ownerId, '2026-10', rates));
    expect(approved, before);
    final p = await service.preview(
        billId: billId,
        actorId: h.ownerId,
        amountMinor: 8000,
        receivedAt: DateTime.utc(2026, 10, 27),
        destinationMonth: '2026-10',
        isAccessCurrent: () => true);
    await h.db.writeTxn(() => service.recordInTransaction(
        preview: p, operationKey: 'received', isAccessCurrent: () => true));
    final funds = await h.db
        .txn(() => readPersonalMonthFunds(h.db, h.ownerId, '2026-10', rates));
    expect(funds['available'], 98000);
    expect(funds['reserve'], 98000);
    expect(funds['bank'], 598000);
    final expenses = await h.db.expenses.where().findAll(),
        returns = await h.db.reimbursements.where().findAll();
    final summary = MonthSummary.from(
        yearMonth: '2026-10',
        income: 100000,
        usesOverriddenIncome: true,
        expenses: expenses,
        reimbursements: returns,
        convertExpense: expenseAccountingMoney,
        convertReimbursement: reimbursementAccountingMoney,
        usesReviewedBank: true,
        reviewedBank: funds['bank']!.toDouble(),
        openingBalance: 600000,
        convertMedicalAccounting: (money) => money);
    expect(summary.moneyInBank, 598000);
    expect(summary.insuranceReturned, 8000);
    final request = ReportRequest(
        scope: ReportScope.personal,
        personalProfileId: h.ownerId,
        owners: [ReportOwner.personal(h.ownerId)],
        firstMonth: '2026-10',
        lastMonth: '2026-10',
        currency: CurrencyCode.huf);
    final report = calculateReportMonth(
        ReportMonthInput(
            owner: ReportOwner.personal(h.ownerId),
            name: 'Fixture',
            currency: CurrencyCode.huf,
            month: (await h.db.monthlyBudgets.get(h.budgetId))!,
            defaultIncome: 100000,
            expenses: expenses,
            refunds: returns,
            budgets: [],
            directs: [],
            sources: [],
            settlements: [],
            vault: [],
            categories: {},
            recorded: {},
            requiresReviewedBank: true,
            reviewedBankMinor: funds['bank']),
        request,
        rates);
    expect(report.statement.amounts['free'], 98000);
    expect(report.statement.amounts['reserve'], 98000);
    expect(report.statement.amounts['bank'], 598000);
    expect(report.statement.amounts['net'], 2000);
    final audit = await auditFinancialState(
        h.db, AuditFinancialScope(h.ownerId, null, '2026-10'));
    expect(audit.containsKey('status'), isFalse);
  });
  test('old app overwrite or deletion cannot remove version2 receipt evidence',
      () async {
    await approve();
    final p = await service.preview(
        billId: billId,
        actorId: h.ownerId,
        amountMinor: 8000,
        receivedAt: DateTime.utc(2026, 10, 27),
        destinationMonth: '2026-10',
        isAccessCurrent: () => true);
    await h.db.writeTxn(() => service.recordInTransaction(
        preview: p, operationKey: 'protected', isAccessCurrent: () => true));
    final old = (await h.db.reimbursements.where().findFirst())!;
    final stale = Reimbursement(
        id: old.id,
        profileId: old.profileId,
        expenseId: old.expenseId,
        originYearMonth: old.originYearMonth,
        amount: old.amount,
        currency: old.currency,
        date: old.date)
      ..syncGuid = old.syncGuid;
    await expectLater(
        h.db.writeTxn(() => FxBookingService(h.db)
            .validateRemoteRefund(stale, old, carriesFx: true)),
        throwsStateError);
    await expectLater(
        h.db.writeTxn(() => AuditRepository(h.db, actorId: h.ownerId)
            .remove(h.db.reimbursements, old.id, type: 'Reimbursement')),
        throwsStateError);
    expect((await h.db.reimbursements.get(old.id))!.medicalReceiptJson,
        old.medicalReceiptJson);
  });
  test('wrong owner and lost access cannot record approval', () async {
    await expectLater(
        service.approve(
            billId: billId,
            actorId: h.ownerId + 99,
            amountMinor: 8000,
            decisionDate: now,
            operationKey: 'wrong',
            isAccessCurrent: () => true),
        throwsA(isA<MedicalReceiptException>()));
    await expectLater(
        service.approve(
            billId: billId,
            actorId: h.ownerId,
            amountMinor: 8000,
            decisionDate: now,
            operationKey: 'locked',
            isAccessCurrent: () => false),
        throwsA(isA<MedicalReceiptException>()));
    expect(await h.db.medicalApprovals.count(), 0);
  });
  test(
      'full coverage returns the whole paid amount; insurer-paid has no user receipt',
      () async {
    await h.db.writeTxn(() async {
      final bill = (await h.db.medicalBills.get(billId))!
        ..patientSharePercent = 0;
      await h.db.medicalBills.put(bill);
    });
    await service.approve(
        billId: billId,
        actorId: h.ownerId,
        amountMinor: 10000,
        decisionDate: DateTime.utc(2026, 10, 22),
        operationKey: 'full',
        isAccessCurrent: () => true);
    final p = await service.preview(
        billId: billId,
        actorId: h.ownerId,
        amountMinor: 10000,
        receivedAt: DateTime.utc(2026, 10, 27),
        destinationMonth: '2026-10',
        isAccessCurrent: () => true);
    await h.db.writeTxn(() => service.recordInTransaction(
        preview: p,
        operationKey: 'full-received',
        isAccessCurrent: () => true));
    expect(
        (await service.history(
                billId: billId,
                actorId: h.ownerId,
                isAccessCurrent: () => true))
            .remainingMinor,
        0);
    await h.db.writeTxn(() async {
      final expense = h.expense()
        ..type = ExpenseType.medical
        ..amount = 2000;
      expense.id = await h.db.expenses.put(expense);
      final other = MedicalBill()
        ..profileId = h.ownerId
        ..yearMonth = '2026-10'
        ..linkedExpenseId = expense.id
        ..billedAmount = 10000
        ..currency = 'huf'
        ..paymentMethod = MedicalPaymentMethod.insurerPaid;
      other.id = await h.db.medicalBills.put(other);
      billId = other.id;
    });
    await expectLater(
        service.approve(
            billId: billId,
            actorId: h.ownerId,
            amountMinor: 8000,
            decisionDate: now,
            operationKey: 'provider-paid',
            isAccessCurrent: () => true),
        throwsA(isA<MedicalReceiptException>()
            .having((e) => e.code, 'code', 'insurerPaid')));
  });
}
