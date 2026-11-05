import 'package:budget_buddy/core/models/balance_checkpoint.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import 'package:budget_buddy/core/services/financial_adoption_service.dart';
import 'package:budget_buddy/core/services/balance_checkpoint_service.dart';
import 'receipt_financial_harness.dart';

class D1FinancialHarness {
  D1FinancialHarness._(
      this.h, this.bill, this.expense, this.source, this.cycle);
  final ReceiptFinancialHarness h;
  final MedicalBill bill;
  final Expense expense;
  final IncomeSource source;
  final SalaryCycle cycle;
  static final now = DateTime.utc(2026, 10, 28, 16);
  MedicalReceiptService get medical =>
      MedicalReceiptService(h.db, clock: () => now);
  static Future<D1FinancialHarness> create() async {
    final h = await ReceiptFinancialHarness.create();
    late MedicalBill bill;
    late Expense expense;
    late IncomeSource source;
    late SalaryCycle cycle;
    await h.db.writeTxn(() async {
      expense = h.expense()
        ..type = ExpenseType.medical
        ..paidAt = DateTime.utc(2026, 10, 20);
      expense.id = await h.db.expenses.put(expense);
      bill = MedicalBill()
        ..profileId = h.ownerId
        ..linkedExpenseId = expense.id
        ..yearMonth = '2026-10'
        ..serviceDate = DateTime.utc(2026, 10, 20)
        ..billedAmount = 10000
        ..currency = 'huf'
        ..patientSharePercent = 20
        ..state = MedicalBillState.paid;
      bill.id = await h.db.medicalBills.put(bill);
      await h.db.monthlyBudgets.put(MonthlyBudget()
        ..profileId = h.ownerId
        ..yearMonth = '2026-11'
        ..baseAvailableAmount = 0
        ..openingBalanceConfirmed = true
        ..createdAt = now
        ..updatedAt = now);
      source = IncomeSource()
        ..profileId = h.ownerId
        ..name = 'Salary'
        ..type = IncomeSourceType.salary
        ..amount = 500000
        ..currency = 'huf'
        ..createdAt = now
        ..updatedAt = now;
      source.id = await h.db.incomeSources.put(source);
      cycle = SalaryCycle()
        ..profileId = h.ownerId
        ..sourceGuid = source.syncGuid
        ..scheduleGuid = 'fixture'
        ..expectedAmountMinor = 500000
        ..currency = 'huf'
        ..occurrenceMonth = '2026-10'
        ..nominalPayday = now
        ..adjustedPayday = now
        ..createdAt = now
        ..updatedAt = now;
      cycle.id = await h.db.salaryCycles.put(cycle);
    });
    final adoption = FinancialAdoptionService(h.db, clock: () => now);
    await adoption.confirm(
        preview: await adoption.preview(
            context: h.context(),
            actorId: h.ownerId,
            isAccessCurrent: () => true),
        operationKey: 'adopt',
        isAccessCurrent: () => true);
    final checkpoint = BalanceCheckpointService(h.db, clock: () => now);
    final sources = await checkpoint.load(
        context: h.context(), actorId: h.ownerId, isAccessCurrent: () => true);
    await checkpoint.confirm(
        preview: await checkpoint.preview(
            sources: sources,
            draft: CheckpointDraft(
                balanceMinor: 600000,
                balanceAsOf: DateTime.utc(2026, 10, 1),
                localZone: 'UTC',
                pool: 'Fixture',
                choices: sources.movements.map((m) => MovementChoice(
                    key: m.key,
                    revision: m.revision,
                    role: 'later',
                    actualAt: m.actualAt))),
            isAccessCurrent: () => true),
        operationKey: 'checkpoint',
        isAccessCurrent: () => true);
    return D1FinancialHarness._(h, bill, expense, source, cycle);
  }

  Future<MedicalApproval> approve([int amount = 7500]) => medical.approve(
      billId: bill.id,
      actorId: h.ownerId,
      amountMinor: amount,
      decisionDate: DateTime.utc(2026, 10, 22),
      operationKey: 'approval-$amount',
      isAccessCurrent: () => true);
  Future<void> close() => h.close();
}
