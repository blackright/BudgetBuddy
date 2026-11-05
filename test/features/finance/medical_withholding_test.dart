import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/income_receipt_group.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_settlement_event.dart';
import 'package:budget_buddy/core/models/medical_withholding_match.dart';
import '../../support/receipt_financial_harness.dart';
import 'package:budget_buddy/core/services/medical_withholding_service.dart';

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

  test('match creates a non-reversed record and share settlement', () async {
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
    expect(match.withheldMinor, 6000);
    expect(match.reversed, false);
    expect(await db.medicalWithholdingMatches.count(), 1);
    expect(
        await db.medicalSettlements
            .filter()
            .withholdingMatchGuidEqualTo(match.guid)
            .count(),
        1);
  });

  test('duplicate match on same bill is refused', () async {
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

  test('reverse creates a reversal record', () async {
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
    final reversal = await service.reverse(
      matchGuid: match.guid,
      reason: 'wrong bill',
      isAccessCurrent: () => true,
    );
    expect(reversal.reversed, true);
    expect(reversal.withheldMinor, -6000);
    expect((await service.matchesForBill('bill-1')).isEmpty, true);
  });
}
