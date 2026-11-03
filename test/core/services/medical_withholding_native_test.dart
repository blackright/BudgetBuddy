import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/income_receipt_group.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_settlement_event.dart';
import 'package:budget_buddy/core/models/medical_withholding_match.dart';
import 'package:budget_buddy/core/services/medical_settlement_service.dart';
import 'package:budget_buddy/core/services/medical_withholding_service.dart';
import '../../support/receipt_financial_harness.dart';

void main() {
  late ReceiptFinancialHarness f;
  late Isar db;

  setUp(() async {
    f = await ReceiptFinancialHarness.create();
    db = f.db;
    final now = DateTime.utc(2026, 10, 28);
    await db.writeTxn(() async {
      await db.medicalBills.put(MedicalBill()
        ..profileId = f.ownerId
        ..syncGuid = 'bill-1'
        ..yearMonth = '2026-10'
        ..serviceDate = now
        ..billedAmount = 30000
        ..currency = 'huf'
        ..patientSharePercent = 20
        ..paymentMethod = MedicalPaymentMethod.insurerPaid
        ..state = MedicalBillState.paid);
      for (final guid in ['salary-1', 'salary-2']) {
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
          ..fingerprint = 'fingerprint-$guid'
          ..operationIdentity = 'receipt-$guid'
          ..createdAt = now
          ..updatedAt = now);
      }
    });
  });

  tearDown(() => f.close());

  test('match is refused on already-matched bill (stale retry)', () async {
    final service = MedicalWithholdingService(db);
    await service.match(
      profileId: f.ownerId,
      billGuid: 'bill-1',
      salaryReceiptGroupGuid: 'salary-1',
      withheldMinor: 6000,
      currency: 'huf',
      affectedMonths: ['2026-10'],
      isAccessCurrent: () => true,
    );
    await expectLater(
      service.match(
        profileId: f.ownerId,
        billGuid: 'bill-1',
        salaryReceiptGroupGuid: 'salary-2',
        withheldMinor: 6000,
        currency: 'huf',
        affectedMonths: ['2026-10'],
        isAccessCurrent: () => true,
      ),
      throwsA(isA<MedicalWithholdingException>()),
    );
  });

  test('reverse requires a reason', () async {
    final service = MedicalWithholdingService(db);
    final match = await service.match(
      profileId: f.ownerId,
      billGuid: 'bill-1',
      salaryReceiptGroupGuid: 'salary-1',
      withheldMinor: 6000,
      currency: 'huf',
      affectedMonths: ['2026-10'],
      isAccessCurrent: () => true,
    );
    await expectLater(
      service.reverse(
        matchGuid: match.guid,
        reason: '',
        isAccessCurrent: () => true,
      ),
      throwsA(isA<MedicalWithholdingException>()),
    );
  });

  test('double reverse is refused', () async {
    final service = MedicalWithholdingService(db);
    final match = await service.match(
      profileId: f.ownerId,
      billGuid: 'bill-1',
      salaryReceiptGroupGuid: 'salary-1',
      withheldMinor: 6000,
      currency: 'huf',
      affectedMonths: ['2026-10'],
      isAccessCurrent: () => true,
    );
    await service.reverse(
      matchGuid: match.guid,
      reason: 'undo',
      isAccessCurrent: () => true,
    );
    await expectLater(
      service.reverse(
        matchGuid: match.guid,
        reason: 'undo again',
        isAccessCurrent: () => true,
      ),
      throwsA(isA<MedicalWithholdingException>()),
    );
  });

  test('stored bill/receipt ownership, currency and full share are required',
      () async {
    final service = MedicalWithholdingService(db);
    Future<void> attempt({
      int? profileId,
      String receiptGuid = 'salary-1',
      int amount = 6000,
      String currency = 'huf',
      bool access = true,
    }) =>
        service.match(
          profileId: profileId ?? f.ownerId,
          billGuid: 'bill-1',
          salaryReceiptGroupGuid: receiptGuid,
          withheldMinor: amount,
          currency: currency,
          affectedMonths: ['2026-10'],
          isAccessCurrent: () => access,
        );

    await expectLater(attempt(profileId: f.ownerId + 1),
        throwsA(isA<MedicalWithholdingException>()));
    await expectLater(
        attempt(currency: 'usd'), throwsA(isA<MedicalWithholdingException>()));
    await expectLater(
        attempt(amount: 3000), throwsA(isA<MedicalWithholdingException>()));
    await expectLater(attempt(receiptGuid: 'missing'),
        throwsA(isA<MedicalWithholdingException>()));
    await expectLater(
        attempt(access: false), throwsA(isA<MedicalWithholdingException>()));
  });

  test('identical natural-key retry returns one match and one settlement',
      () async {
    final service = MedicalWithholdingService(db);
    final first = await service.match(
      profileId: f.ownerId,
      billGuid: 'bill-1',
      salaryReceiptGroupGuid: 'salary-1',
      withheldMinor: 6000,
      currency: 'huf',
      affectedMonths: ['2026-10'],
      isAccessCurrent: () => true,
    );
    final retry = await service.match(
      profileId: f.ownerId,
      billGuid: 'bill-1',
      salaryReceiptGroupGuid: 'salary-1',
      withheldMinor: 6000,
      currency: 'huf',
      affectedMonths: ['2026-10'],
      isAccessCurrent: () => true,
    );
    expect(retry.guid, first.guid);
    expect(await db.medicalWithholdingMatches.count(), 1);
    expect(await db.medicalSettlements.count(), 1);
  });

  test('reversal invalidates the share settlement without deleting it',
      () async {
    final service = MedicalWithholdingService(db);
    final match = await service.match(
      profileId: f.ownerId,
      billGuid: 'bill-1',
      salaryReceiptGroupGuid: 'salary-1',
      withheldMinor: 6000,
      currency: 'huf',
      affectedMonths: ['2026-10'],
      isAccessCurrent: () => true,
    );
    expect(await db.medicalSettlements.count(), 1);
    await service.reverse(
      matchGuid: match.guid,
      reason: 'wrong receipt',
      isAccessCurrent: () => true,
    );
    final rows = await db.medicalSettlements.where().findAll();
    expect(rows.length, 2);
    expect(
        activeSettlements(rows).where((e) => e.kind.name == 'shareSettlement'),
        isEmpty);
  });
}
