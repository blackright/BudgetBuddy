import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/income_receipt_group.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/money_receipt.dart';
import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/core/models/salary_schedule.dart';
import 'package:budget_buddy/core/services/balance_checkpoint_service.dart';
import 'package:budget_buddy/core/services/income_activation_service.dart';
import 'package:budget_buddy/core/services/income_receipt_ledger.dart';
import 'package:budget_buddy/core/services/income_receipt_service.dart';
import 'package:budget_buddy/core/services/salary_receipt_service.dart';
import 'package:budget_buddy/features/budget_setup/services/onboarding_opening_service.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../../support/d1_financial_harness.dart';
import '../../support/income_activation_fixture.dart';

void main() {
  final now = DateTime.utc(2026, 11, 3);

  group('income activation already received', () {
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

    test('prepares one pending lifecycle without money or a task', () async {
      final source = await fixture.addSource(
          name: 'Freelance', type: IncomeSourceType.freelance);
      final schedule = await fixture.addSchedule(source, nominalDay: 10);

      final cycle = await activation.chooseAlreadyReceived(source, '2026-11');

      expect(cycle.guid, 'salary-cycle:${source.syncGuid}:2026-11');
      expect(cycle.sourceGuid, source.syncGuid);
      expect(cycle.state, IncomePeriodState.pending.name);
      expect(cycle.confirmed, isFalse);
      expect(cycle.expectedAmountMinor, source.amount);
      expect(cycle.scheduleGuid, schedule.guid);
      expect(cycle.nominalPayday, DateTime(2026, 11, 10));
      expect(await fixture.db.moneyReceipts.count(), 0);
      expect(await fixture.db.incomeReceiptGroups.count(), 0);
      expect(await fixture.db.pendingActions.count(), 0);
      expect(
          await fixture.db.auditEvents
              .filter()
              .actionEqualTo('income.confirmation.started')
              .count(),
          1);
    });

    test('salary preview reports a missing opening checkpoint with a code',
        () async {
      final source = await fixture.addSource(name: 'Salary');
      await fixture.addSchedule(source, nominalDay: 10);
      final cycle = await activation.chooseAlreadyReceived(source, '2026-11');
      final salary = SalaryReceiptService(fixture.db, clock: () => now);

      await expectLater(
          salary.preview(
              actorId: fixture.profileId,
              sourceGuid: source.syncGuid,
              cycleGuid: cycle.guid,
              salaryMinor: 500000,
              actualDate: now,
              timezone: 'UTC',
              selectedClaimGuids: const [],
              isAccessCurrent: () => true),
          throwsA(isA<OpeningReviewException>().having(
              (error) => error.code, 'code', 'missingOpeningCheckpoint')));
    });

    test('salary preview succeeds after the opening boundary is prepared',
        () async {
      final source = await fixture.addSource(name: 'Salary');
      await fixture.addSchedule(source, nominalDay: 10);
      final cycle = await activation.chooseAlreadyReceived(source, '2026-11');
      await OnboardingOpeningService(fixture.db, clock: () => now).ensure(
          profileId: fixture.profileId,
          yearMonth: '2026-11',
          openingMinor: 1000000,
          timezone: 'UTC',
          flowId: 'salary-boundary',
          isAccessCurrent: () => true);
      final salary = SalaryReceiptService(fixture.db, clock: () => now);

      final preview = await salary.preview(
          actorId: fixture.profileId,
          sourceGuid: source.syncGuid,
          cycleGuid: cycle.guid,
          salaryMinor: 500000,
          actualDate: now,
          timezone: 'UTC',
          selectedClaimGuids: const [],
          isAccessCurrent: () => true);

      expect(preview.cashMonth, '2026-11');
      expect(preview.totalMinor, 500000);
    });

    test('choosing again reuses the same pending lifecycle', () async {
      final source = await fixture.addSource(
          name: 'Freelance', type: IncomeSourceType.freelance);
      await fixture.addSchedule(source, nominalDay: 10);

      final first = await activation.chooseAlreadyReceived(source, '2026-11');
      final second = await activation.chooseAlreadyReceived(source, '2026-11');

      expect(second.guid, first.guid);
      expect(await fixture.db.salaryCycles.count(), 1);
      expect(
          await fixture.db.auditEvents
              .filter()
              .actionEqualTo('income.confirmation.started')
              .count(),
          1);
    });

    test('terminal periods cannot start a new receipt', () async {
      final skipped = await fixture.addSource(name: 'Skipped');
      await fixture.addCycle(skipped, state: IncomePeriodState.skipped.name);
      final confirmed = await fixture.addSource(name: 'Confirmed');
      await fixture.addCycle(confirmed,
          state: IncomePeriodState.confirmed.name);

      await expectLater(
          activation.chooseAlreadyReceived(skipped, '2026-11'),
          throwsA(isA<IncomeActivationException>()
              .having((e) => e.code, 'code', 'periodClosed')));
      await expectLater(
          activation.chooseAlreadyReceived(confirmed, '2026-11'),
          throwsA(isA<IncomeActivationException>()
              .having((e) => e.code, 'code', 'alreadyConfirmed')));
    });

    test('the usual receipt day is clamped to the period length', () async {
      final source = await fixture.addSource(
          name: 'Rent',
          type: IncomeSourceType.rental,
          startDate: DateTime.utc(2026, 2, 1));
      await fixture.addSchedule(source, nominalDay: 31);

      final cycle = await activation.chooseAlreadyReceived(source, '2026-02');

      expect(cycle.nominalPayday, DateTime(2026, 2, 28));
    });

    test('a one-time source uses its single receipt date', () async {
      final source = await fixture.addSource(
          name: 'Bonus',
          type: IncomeSourceType.bonus,
          frequency: IncomeFrequency.oneTime,
          startDate: DateTime.utc(2026, 11, 15));

      final cycle = await activation.chooseAlreadyReceived(source, '2026-11');

      expect(cycle.nominalPayday, DateTime(2026, 11, 15));
      expect(await fixture.db.salarySchedules.count(), 0);
    });

    test('confirming an already-received income adds one receipt and no task',
        () async {
      final source = await fixture.addSource(
          name: 'Freelance', type: IncomeSourceType.freelance);
      await fixture.addSchedule(source, nominalDay: 10);
      final cycle = await activation.chooseAlreadyReceived(source, '2026-11');
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
          preview: preview, operationKey: 'once', isAccessCurrent: () => true);

      final saved = (await fixture.lifecycle(source))!;
      final ledger = await IncomeReceiptLedger.read(fixture.db, group);
      expect(await fixture.db.incomeReceiptGroups.count(), 1);
      expect(await fixture.db.moneyReceipts.count(), 1);
      expect(group.totalMinor, 480000);
      expect(group.destinationMonth, '2026-11');
      expect(group.cycleGuid, cycle.guid);
      expect(ledger.incomeMinor, 480000);
      expect(saved.confirmed, isTrue);
      expect(saved.state, IncomePeriodState.confirmed.name);
      expect(saved.receiptGroupGuid, group.guid);
      expect(await fixture.db.pendingActions.count(), 0);
      expect(
          await fixture.db.auditEvents
              .filter()
              .actionEqualTo('income.confirm')
              .count(),
          1);

      final retry = await receipts.confirm(
          preview: preview, operationKey: 'once', isAccessCurrent: () => true);
      expect(retry.guid, group.guid);
      expect(await fixture.db.incomeReceiptGroups.count(), 1);
    });
  });

  test('a successful salary receipt completes an unfinished confirmation task',
      () async {
    final f = await D1FinancialHarness.create();
    addTearDown(f.close);
    final actions = PendingActionService(f.h.db,
        profileId: f.h.ownerId, clock: () => D1FinancialHarness.now);
    await f.h.db.writeTxn(() async {
      await f.h.db.pendingActions.put(PendingAction()
        ..profileId = f.h.ownerId
        ..actionType = 'income.complete'
        ..title = 'Complete income confirmation'
        ..nextAction = 'Resume income confirmation'
        ..feature = 'salary'
        ..recordRef = f.cycle.guid
        ..expectedMonth = f.cycle.occurrenceMonth
        ..expectedAt = D1FinancialHarness.now
        ..status = 'due'
        ..dedupeKey =
            'income.complete|${f.cycle.guid}|${f.cycle.occurrenceMonth}'
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
        operationKey: 'activation-salary',
        isAccessCurrent: () => true);

    final saved = (await f.h.db.salaryCycles
        .filter()
        .guidEqualTo(f.cycle.guid)
        .findFirst())!;
    final action = (await f.h.db.pendingActions.where().findFirst())!;
    expect(saved.confirmed, isTrue);
    expect(saved.state, IncomePeriodState.confirmed.name);
    expect(saved.receiptGroupGuid, group.guid);
    expect(await f.h.db.incomeReceiptGroups.count(), 1);
    expect(action.status, 'completed');
    expect(action.completedAt, isNotNull);

    final retry = await salary.confirm(
        preview: preview,
        bankTotalMinor: 485000,
        operationKey: 'activation-salary',
        isAccessCurrent: () => true);
    expect(retry.guid, group.guid);
    expect(await f.h.db.incomeReceiptGroups.count(), 1);
  });
}
