import 'package:budget_buddy/core/models/income_receipt_group.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/core/services/income_activation_service.dart';
import 'package:budget_buddy/core/services/income_receipt_ledger.dart';
import 'package:budget_buddy/core/services/income_receipt_service.dart';
import 'package:budget_buddy/core/services/salary_receipt_service.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_service.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../../support/d1_financial_harness.dart';
import '../../support/income_activation_fixture.dart';

void main() {
  final now = DateTime.utc(2026, 11, 3);

  group('confirm expected income later', () {
    late IncomeActivationFixture fixture;
    late PendingActionService actions;
    late IncomeActivationService activation;

    setUp(() async {
      fixture = await IncomeActivationFixture.create();
      actions = PendingActionService(fixture.db,
          profileId: fixture.profileId, clock: () => now);
      activation = IncomeActivationService(
        fixture.db,
        profileId: fixture.profileId,
        audit: AuditRepository(fixture.db, actorId: fixture.profileId),
        pendingActions: actions,
        clock: () => now,
      );
      addTearDown(fixture.close);
    });

    test('a non-salary expected action adds once and completes its task',
        () async {
      final source = await fixture.addSource(
          name: 'Freelance', type: IncomeSourceType.freelance);
      await fixture.addSchedule(source, nominalDay: 10);
      final cycle = await activation.chooseExpectLater(source, '2026-11');
      final action = (await fixture.db.pendingActions.where().findFirst())!;
      final receipts = IncomeReceiptService(fixture.db,
          pendingActions: actions, clock: () => now);

      final preview = await receipts.preview(
        source: source,
        cycle: cycle,
        amountMinor: 480000,
        actualDate: DateTime.utc(2026, 11, 3),
        timezone: 'UTC',
        isAccessCurrent: () => true,
      );
      final group = await receipts.confirm(
          preview: preview,
          operationKey: 'expected-once',
          isAccessCurrent: () => true);

      final saved = (await fixture.lifecycle(source))!;
      final completed = (await fixture.db.pendingActions.get(action.id))!;
      final ledger = await IncomeReceiptLedger.read(fixture.db, group);
      final active = (await fixture.db.pendingActions.where().findAll())
          .where((row) => row.isActive)
          .length;
      expect(completed.status, 'completed');
      expect(completed.completedAt, isNotNull);
      expect(saved.confirmed, isTrue);
      expect(saved.state, IncomePeriodState.confirmed.name);
      expect(saved.receiptGroupGuid, group.guid);
      expect(saved.expectedAmountMinor, 500000);
      expect(await fixture.db.incomeReceiptGroups.count(), 1);
      expect(ledger.incomeMinor, 480000);
      expect(active, 0);

      final retry = await receipts.confirm(
          preview: preview,
          operationKey: 'expected-once',
          isAccessCurrent: () => true);
      expect(retry.guid, group.guid);
      expect(await fixture.db.incomeReceiptGroups.count(), 1);
    });
  });

  test('a salary expected action adds once and completes its task', () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final actions = PendingActionService(f.h.db,
        profileId: f.h.ownerId, clock: () => D1FinancialHarness.now);
    await f.h.db.writeTxn(() async {
      final cycle = (await f.h.db.salaryCycles
          .filter()
          .guidEqualTo(f.cycle.guid)
          .findFirst())!;
      cycle.state = IncomePeriodState.pending.name;
      await f.h.db.salaryCycles.put(cycle);
      await f.h.db.pendingActions.put(PendingAction()
        ..profileId = f.h.ownerId
        ..actionType = PendingActionTypes.salaryConfirm
        ..title = 'Confirm salary received'
        ..nextAction = 'Confirm salary received'
        ..feature = 'salary'
        ..recordRef = cycle.guid
        ..expectedMonth = cycle.occurrenceMonth
        ..expectedAmountMinor = cycle.expectedAmountMinor
        ..currency = cycle.currency
        ..expectedAt = DateTime(2026, 10, 25)
        ..status = 'pending'
        ..dedupeKey =
            '${PendingActionTypes.salaryConfirm}|${cycle.guid}|${cycle.occurrenceMonth}'
        ..createdAt = D1FinancialHarness.now
        ..updatedAt = D1FinancialHarness.now);
    });

    final salary = SalaryReceiptService(f.h.db,
        pendingActions: actions, clock: () => D1FinancialHarness.now);
    final preview = await salary.preview(
        actorId: f.h.ownerId,
        sourceGuid: f.source.syncGuid,
        cycleGuid: f.cycle.guid,
        salaryMinor: 485000,
        actualDate: DateTime.utc(2026, 10, 25),
        selectedClaimGuids: const [],
        isAccessCurrent: () => true);
    final group = await salary.confirm(
        preview: preview,
        bankTotalMinor: 485000,
        operationKey: 'expected-salary',
        isAccessCurrent: () => true);

    final saved = (await f.h.db.salaryCycles
        .filter()
        .guidEqualTo(f.cycle.guid)
        .findFirst())!;
    final action = (await f.h.db.pendingActions.where().findFirst())!;
    final ledger = await IncomeReceiptLedger.read(f.h.db, group);
    expect(action.status, 'completed');
    expect(action.completedAt, isNotNull);
    expect(saved.confirmed, isTrue);
    expect(saved.state, IncomePeriodState.confirmed.name);
    expect(saved.receiptGroupGuid, group.guid);
    expect(saved.expectedAmountMinor, 500000);
    expect(await f.h.db.incomeReceiptGroups.count(), 1);
    expect(ledger.salaryMinor, 485000);

    final retry = await salary.confirm(
        preview: preview,
        bankTotalMinor: 485000,
        operationKey: 'expected-salary',
        isAccessCurrent: () => true);
    expect(retry.guid, group.guid);
    expect(await f.h.db.incomeReceiptGroups.count(), 1);
  });
}
