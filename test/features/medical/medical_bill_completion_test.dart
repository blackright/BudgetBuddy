import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/medical_settlement_event.dart';
import 'package:budget_buddy/core/models/money_receipt.dart';
import 'package:budget_buddy/core/services/medical_receipt_service.dart';
import 'package:budget_buddy/core/services/medical_settlement_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../../support/d1_financial_harness.dart';

void main() {
  late D1FinancialHarness f;
  setUp(() async {
    f = await D1FinancialHarness.create();
  });
  tearDown(() => f.close());

  test('closure refuses approved money that has not been received', () async {
    await f.approve();
    await expectLater(
        f.medical.previewClose(
            billId: f.bill.id,
            actorId: f.h.ownerId,
            isAccessCurrent: () => true),
        throwsA(isA<MedicalReceiptException>()));
    expect(await f.h.db.medicalClaimClosures.count(), 0);
  });

  test('closure refuses inconsistent provider-payment amounts', () async {
    await f.approve();
    await f.h.db.writeTxn(() async {
      final expense = (await f.h.db.expenses.get(f.expense.id))!..amount = 8000;
      await f.h.db.expenses.put(expense);
    });
    await expectLater(
        f.medical.previewClose(
            billId: f.bill.id,
            actorId: f.h.ownerId,
            isAccessCurrent: () => true),
        throwsA(isA<MedicalReceiptException>()));
    expect(await f.h.db.medicalClaimClosures.count(), 0);
  });

  test('cancelling the claim keeps the paid cost and moves no money', () async {
    final beforeExpense = await f.h.db.expenses.where().exportJson();
    await f.medical.recordClaimAction(
        billId: f.bill.id,
        actorId: f.h.ownerId,
        kind: 'cancelled',
        reason: 'No longer claiming',
        operationKey: 'cancelled',
        isAccessCurrent: () => true);
    expect(await f.h.db.expenses.where().exportJson(), beforeExpense);
    expect((await f.h.db.expenses.get(f.expense.id))!.amount, 10000);
    expect(await f.h.db.moneyReceipts.count(), 0);
    final history = await f.medical.history(
        billId: f.bill.id, actorId: f.h.ownerId, isAccessCurrent: () => true);
    expect(history.cancelled, true);
    expect(history.receivedMinor, 0);
  });

  Future<MedicalBill> directBill({double share = 20}) async {
    late MedicalBill bill;
    await f.h.db.writeTxn(() async {
      final expense = f.h.expense()
        ..type = ExpenseType.medical
        ..amount = (10000 * share / 100).round()
        ..status = ExpenseStatus.paid
        ..paidAt = D1FinancialHarness.now;
      expense.id = await f.h.db.expenses.put(expense);
      bill = MedicalBill()
        ..profileId = f.h.ownerId
        ..linkedExpenseId = expense.id
        ..yearMonth = '2026-10'
        ..serviceDate = D1FinancialHarness.now
        ..billedAmount = 10000
        ..currency = 'huf'
        ..patientSharePercent = share
        ..paymentMethod = MedicalPaymentMethod.insurerPaid
        ..state = MedicalBillState.paid;
      bill.id = await f.h.db.medicalBills.put(bill);
    });
    return bill;
  }

  MedicalSettlementService settlement() =>
      MedicalSettlementService(f.h.db, clock: () => D1FinancialHarness.now);

  test('direct settlement works in both orders with no refund or approval',
      () async {
    for (final providerFirst in [true, false]) {
      final bill = await directBill();
      final service = settlement();
      if (providerFirst) {
        await service.recordProviderSettlement(
            billId: bill.id,
            actorId: f.h.ownerId,
            effectiveDate: DateTime.utc(2026, 10, 20),
            confirmed: true,
            operationKey: 'provider-$providerFirst',
            isAccessCurrent: () => true);
        await service.recordSharePayment(
            billId: bill.id,
            actorId: f.h.ownerId,
            amountMinor: 2000,
            effectiveDate: DateTime.utc(2026, 10, 21),
            operationKey: 'share-$providerFirst',
            isAccessCurrent: () => true);
      } else {
        await service.recordSharePayment(
            billId: bill.id,
            actorId: f.h.ownerId,
            amountMinor: 2000,
            effectiveDate: DateTime.utc(2026, 10, 21),
            operationKey: 'share-$providerFirst',
            isAccessCurrent: () => true);
        await service.recordProviderSettlement(
            billId: bill.id,
            actorId: f.h.ownerId,
            effectiveDate: DateTime.utc(2026, 10, 20),
            confirmed: true,
            operationKey: 'provider-$providerFirst',
            isAccessCurrent: () => true);
      }
      await service.closeBill(
          billId: bill.id,
          actorId: f.h.ownerId,
          reason: 'Settled',
          operationKey: 'close-$providerFirst',
          isAccessCurrent: () => true);
      expect(await f.h.db.medicalApprovals.count(), 0);
      final rows = await f.h.db.medicalSettlements
          .filter()
          .billGuidEqualTo(bill.syncGuid)
          .findAll();
      expect(activeSettlements(rows).length, 3);
    }
  });

  test('direct zero share closes with provider evidence only', () async {
    final bill = await directBill(share: 0);
    final service = settlement();
    await service.recordProviderSettlement(
        billId: bill.id,
        actorId: f.h.ownerId,
        effectiveDate: DateTime.utc(2026, 10, 20),
        confirmed: true,
        operationKey: 'provider-zero',
        isAccessCurrent: () => true);
    await service.closeBill(
        billId: bill.id,
        actorId: f.h.ownerId,
        reason: 'Insurer paid all',
        operationKey: 'close-zero',
        isAccessCurrent: () => true);
    final rows = await f.h.db.medicalSettlements
        .filter()
        .billGuidEqualTo(bill.syncGuid)
        .findAll();
    expect(activeSettlements(rows).length, 2);
    expect(
        activeSettlements(rows)
            .any((e) => e.kind == MedicalSettlementKind.shareSettlement),
        false);
  });
}
