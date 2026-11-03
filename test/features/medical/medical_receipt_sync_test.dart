import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/medical_approval.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_settlement_event.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/sync/domain/codecs/medical_approval_codec.dart';
import 'package:budget_buddy/features/sync/domain/codecs/medical_settlement_event_codec.dart';
import 'package:budget_buddy/features/sync/domain/entity_applier.dart';
import 'package:budget_buddy/features/sync/domain/sync_codec.dart';
import '../../support/receipt_financial_harness.dart';

void main() {
  test('approval codec carries no salary, checkpoint or private group data',
      () {
    final row = MedicalApproval()
      ..billGuid = 'bill'
      ..yearMonth = '2026-10'
      ..approvedMinor = 8000
      ..currency = 'huf'
      ..decisionDate = DateTime.utc(2026, 10, 22)
      ..recordedAt = DateTime.utc(2026, 10, 28)
      ..actorId = 1
      ..operationIdentity = 'approval:one'
      ..inputFingerprint = List.filled(64, 'a').join();
    final json = const MedicalApprovalCodec().toJson(row);
    final restored = const MedicalApprovalCodec().fromJson(json);
    expect(restored.approvedMinor, 8000);
    expect(restored.billGuid, 'bill');
    expect(json.keys, isNot(contains('groupGuid')));
    expect(json.keys, isNot(contains('salary')));
    expect(json.keys, isNot(contains('profileId')));
    expect(json.keys, isNot(contains('bankBalance')));
  });
  test(
      'shared approval apply is immutable, idempotent and tied to its actual owner',
      () async {
    final h = await ReceiptFinancialHarness.create();
    try {
      late SharedSpace space;
      late MedicalBill bill;
      await h.db.writeTxn(() async {
        space = SharedSpace()
          ..name = 'Family'
          ..currency = PrimaryCurrency.huf
          ..createdByProfileId = h.ownerId
          ..createdAt = DateTime.utc(2026);
        space.id = await h.db.sharedSpaces.put(space);
        final expense = h.expense()
          ..type = ExpenseType.medical
          ..sharedSpaceId = space.id;
        expense.id = await h.db.expenses.put(expense);
        bill = MedicalBill()
          ..sharedSpaceId = space.id
          ..linkedExpenseId = expense.id
          ..yearMonth = '2026-10'
          ..currency = 'huf'
          ..billedAmount = 10000
          ..state = MedicalBillState.paid;
        bill.id = await h.db.medicalBills.put(bill);
      });
      final row = MedicalApproval()
        ..billGuid = bill.syncGuid
        ..yearMonth = '2026-10'
        ..approvedMinor = 8000
        ..currency = 'huf'
        ..decisionDate = DateTime.utc(2026, 10, 22)
        ..recordedAt = DateTime.utc(2026, 10, 28)
        ..actorId = 1
        ..operationIdentity = 'approval:${bill.syncGuid}'
        ..inputFingerprint = List.filled(64, 'a').join();
      final json = const MedicalApprovalCodec().toJson(row)
        ..['sharedSpaceSyncGuid'] = space.syncGuid;
      const applier = MedicalApprovalApplier();
      final id = await h.db
          .writeTxn(() => applier.upsert(h.db, canonicalJsonEncode(json)));
      final retry = await h.db
          .writeTxn(() => applier.upsert(h.db, canonicalJsonEncode(json)));
      expect(id, retry);
      expect(await h.db.medicalApprovals.count(), 1);
      await expectLater(
          h.db.writeTxn(() => applier.upsert(
              h.db, canonicalJsonEncode({...json, 'approvedMinor': 7000}))),
          throwsFormatException);
      await expectLater(
          h.db.writeTxn(() => applier.upsert(
              h.db, canonicalJsonEncode({...json, 'currency': 'eur'}))),
          throwsFormatException);
      expect((await h.db.medicalApprovals.get(id))!.approvedMinor, 8000);
      expect(await h.db.reimbursements.count(), 0);
    } finally {
      await h.close();
    }
  });

  test('settlement codec keeps salary private and applier is immutable',
      () async {
    final h = await ReceiptFinancialHarness.create();
    try {
      late MedicalBill bill;
      await h.db.writeTxn(() async {
        final expense = h.expense()
          ..type = ExpenseType.medical
          ..amount = 2000;
        expense.id = await h.db.expenses.put(expense);
        bill = MedicalBill()
          ..profileId = h.ownerId
          ..linkedExpenseId = expense.id
          ..yearMonth = '2026-10'
          ..billedAmount = 10000
          ..currency = 'huf'
          ..patientSharePercent = 20
          ..paymentMethod = MedicalPaymentMethod.insurerPaid
          ..state = MedicalBillState.paid;
        bill.id = await h.db.medicalBills.put(bill);
      });
      final row = MedicalSettlementEvent()
        ..billGuid = bill.syncGuid
        ..kind = MedicalSettlementKind.shareSettlement
        ..confirmed = true
        ..effectiveDate = DateTime.utc(2026, 10, 20)
        ..recordedAt = DateTime.utc(2026, 10, 20)
        ..currency = 'huf'
        ..amountMinor = 2000
        ..expenseGuid = (await h.db.expenses.get(bill.linkedExpenseId!))!
            .syncGuid
        ..withholdingMatchGuid = 'match-reference'
        ..operationIdentity = 'settlement:one'
        ..inputFingerprint = 'fingerprint-one';
      final json = const MedicalSettlementEventCodec().toJson(row);
      expect(json.keys, isNot(contains('salaryReceiptGroupGuid')));
      expect(json.keys, isNot(contains('salary')));
      expect(json.keys, isNot(contains('netSalary')));
      expect(json.keys, isNot(contains('profileId')));
      final restored = const MedicalSettlementEventCodec().fromJson(json);
      expect(restored.amountMinor, 2000);
      expect(restored.withholdingMatchGuid, 'match-reference');

      const applier = MedicalSettlementEventApplier();
      final id = await h.db
          .writeTxn(() => applier.upsert(h.db, canonicalJsonEncode(json)));
      final retry = await h.db
          .writeTxn(() => applier.upsert(h.db, canonicalJsonEncode(json)));
      expect(id, retry);
      expect(await h.db.medicalSettlements.count(), 1);
      expect((await h.db.medicalSettlements.get(id))!.profileId, h.ownerId);
      await expectLater(
          h.db.writeTxn(() => applier.upsert(
              h.db, canonicalJsonEncode({...json, 'amountMinor': 1500}))),
          throwsFormatException);
    } finally {
      await h.close();
    }
  });
}
