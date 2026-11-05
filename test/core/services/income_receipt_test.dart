import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/income_receipt_group.dart';
import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/core/services/income_receipt_ledger.dart';
import 'package:budget_buddy/core/services/income_receipt_service.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../../support/d1_financial_harness.dart';

/// Seeds the explicit current-period lifecycle that confirmation requires.
Future<SalaryCycle> seedCycle(Isar db, int ownerId, IncomeSource source) async {
  final cycle = SalaryCycle()
    ..guid = 'salary-cycle:${source.syncGuid}:2026-10'
    ..profileId = ownerId
    ..sourceGuid = source.syncGuid
    ..scheduleGuid = 'manual:${source.syncGuid}'
    ..expectedAmountMinor = source.amount
    ..currency = source.currency
    ..occurrenceMonth = '2026-10'
    ..nominalPayday = DateTime(2026, 10, 25)
    ..adjustedPayday = DateTime(2026, 10, 25)
    ..confirmed = false
    ..state = 'pending'
    ..createdAt = DateTime.utc(2026, 10, 1)
    ..updatedAt = DateTime.utc(2026, 10, 1);
  await db.writeTxn(() async {
    cycle.id = await db.salaryCycles.put(cycle);
  });
  return cycle;
}

void main() {
  test(
      'non-salary income confirms once, counts in its cash month and completes '
      'its attention action', () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final now = DateTime.utc(2026, 10, 28);
    final source = IncomeSource()
      ..profileId = f.h.ownerId
      ..name = 'Freelance'
      ..type = IncomeSourceType.freelance
      ..amount = 300000
      ..currency = 'huf'
      ..frequency = IncomeFrequency.monthly
      ..createdAt = DateTime.utc(2026, 10, 1)
      ..updatedAt = DateTime.utc(2026, 10, 1);
    await f.h.db.writeTxn(() async {
      source.id = await f.h.db.incomeSources.put(source);
    });
    final cycle = await seedCycle(f.h.db, f.h.ownerId, source);
    final actions =
        PendingActionService(f.h.db, profileId: f.h.ownerId, clock: () => now);
    await actions.upsert(PendingActionDraft(
      profileId: f.h.ownerId,
      actionType: 'income.confirm',
      title: 'Confirm Freelance received',
      nextAction: 'Confirm income received',
      feature: 'income',
      recordRef: cycle.guid,
      cycleOrMonth: '2026-10',
      expectedAmountMinor: 300000,
      currency: 'huf',
      expectedMonth: '2026-10',
    ));
    final service =
        IncomeReceiptService(f.h.db, clock: () => now, pendingActions: actions);
    final preview = await service.preview(
        source: source,
        cycle: cycle,
        amountMinor: 300000,
        actualDate: DateTime.utc(2026, 10, 27),
        timezone: 'UTC',
        isAccessCurrent: () => true);

    final group = await service.confirm(
        preview: preview, operationKey: 'once', isAccessCurrent: () => true);
    final savedCycle = (await f.h.db.salaryCycles
        .filter()
        .guidEqualTo(cycle.guid)
        .findFirst())!;
    expect(group.totalMinor, 300000);
    expect(group.destinationMonth, '2026-10');
    expect(group.cycleGuid, cycle.guid);
    final ledger = await IncomeReceiptLedger.read(f.h.db, group);
    expect(ledger.incomeMinor, 300000);
    expect(ledger.salaryMinor, 0);
    expect(savedCycle.confirmed, isTrue);
    expect(savedCycle.receiptGroupGuid, group.guid);
    final action = (await f.h.db.pendingActions
        .filter()
        .recordRefEqualTo(cycle.guid)
        .findFirst())!;
    expect(action.status, 'completed');

    final retry = await service.confirm(
        preview: preview, operationKey: 'retry', isAccessCurrent: () => true);
    expect(retry.guid, group.guid);
    expect(await f.h.db.incomeReceiptGroups.count(), 1);
  });

  test('future income dates are rejected without writes', () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final now = DateTime.utc(2026, 10, 28);
    final source = IncomeSource()
      ..profileId = f.h.ownerId
      ..name = 'Other'
      ..type = IncomeSourceType.other
      ..amount = 50000
      ..currency = 'huf'
      ..frequency = IncomeFrequency.monthly
      ..createdAt = DateTime.utc(2026, 10, 1)
      ..updatedAt = DateTime.utc(2026, 10, 1);
    await f.h.db.writeTxn(() async {
      source.id = await f.h.db.incomeSources.put(source);
    });
    final cycle = await seedCycle(f.h.db, f.h.ownerId, source);
    final service = IncomeReceiptService(f.h.db, clock: () => now);
    final before = await f.h.db.incomeReceiptGroups.count();

    await expectLater(
        service.preview(
            source: source,
            cycle: cycle,
            amountMinor: 50000,
            actualDate: DateTime.utc(2026, 10, 29),
            timezone: 'UTC',
            isAccessCurrent: () => true),
        throwsA(isA<IncomeReceiptException>()
            .having((e) => e.code, 'code', 'invalidAmount')));
    expect(await f.h.db.incomeReceiptGroups.count(), before);
  });

  test('salary cannot use the simple income confirmation flow', () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final now = DateTime.utc(2026, 10, 28);
    final service = IncomeReceiptService(f.h.db, clock: () => now);

    await expectLater(
        service.preview(
            source: f.source,
            cycle: f.cycle,
            amountMinor: 500000,
            actualDate: DateTime.utc(2026, 10, 27),
            timezone: 'UTC',
            isAccessCurrent: () => true),
        throwsA(isA<IncomeReceiptException>()
            .having((e) => e.code, 'code', 'wrongOwner')));
  });
}
