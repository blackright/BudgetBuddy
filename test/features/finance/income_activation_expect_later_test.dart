import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/income_receipt_group.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/money_receipt.dart';
import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/core/models/salary_schedule.dart';
import 'package:budget_buddy/core/services/income_activation_service.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_service.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../../support/income_activation_fixture.dart';

void main() {
  final now = DateTime.utc(2026, 11, 3);

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

  test('expect later creates one pending salary action and no money', () async {
    final source = await fixture.addSource();
    final schedule = await fixture.addSchedule(source, nominalDay: 10);

    final cycle = await activation.chooseExpectLater(source, '2026-11');

    expect(cycle.state, IncomePeriodState.pending.name);
    expect(cycle.confirmed, isFalse);
    expect(cycle.expectedAmountMinor, 500000);
    expect(cycle.scheduleGuid, schedule.guid);
    expect(cycle.occurrenceMonth, '2026-11');
    expect(cycle.nominalPayday, DateTime(2026, 11, 10));
    expect(cycle.adjustedPayday, DateTime(2026, 11, 10));

    final action = (await fixture.db.pendingActions.where().findFirst())!;
    expect(action.actionType, PendingActionTypes.salaryConfirm);
    expect(action.title, 'Confirm salary received');
    expect(action.nextAction, 'Confirm salary received');
    expect(action.feature, 'salary');
    expect(action.recordRef, cycle.guid);
    expect(action.expectedMonth, '2026-11');
    expect(action.expectedAmountMinor, 500000);
    expect(action.currency, 'huf');
    expect(action.expectedAt!.isAtSameMomentAs(DateTime(2026, 11, 10)), isTrue);
    expect(action.priority, 2);
    expect(action.deepLink, '/income_sources');
    expect(action.status, 'pending');
    expect(await fixture.db.pendingActions.count(), 1);
    expect(await fixture.db.moneyReceipts.count(), 0);
    expect(await fixture.db.incomeReceiptGroups.count(), 0);
    expect(
        await fixture.db.auditEvents
            .filter()
            .actionEqualTo('income.period.expectationCreated')
            .count(),
        1);
  });

  test('expect later creates an income action for a non-salary source',
      () async {
    final source = await fixture.addSource(
        name: 'Freelance', type: IncomeSourceType.freelance);
    await fixture.addSchedule(source, nominalDay: 5);

    final cycle = await activation.chooseExpectLater(source, '2026-11');

    final action = (await fixture.db.pendingActions.where().findFirst())!;
    expect(action.actionType, PendingActionTypes.incomeConfirm);
    expect(action.title, 'Confirm Freelance received');
    expect(action.nextAction, 'Confirm income received');
    expect(action.feature, 'income');
    expect(action.recordRef, cycle.guid);
    expect(action.expectedAt!.isAtSameMomentAs(DateTime(2026, 11, 5)), isTrue);
    expect(action.status, 'pending');
    expect(await fixture.db.moneyReceipts.count(), 0);
  });

  test('an expected date that already passed is due immediately', () async {
    final source =
        await fixture.addSource(name: 'Rent', type: IncomeSourceType.rental);
    await fixture.addSchedule(source, nominalDay: 1);

    await activation.chooseExpectLater(source, '2026-11');

    final action = (await fixture.db.pendingActions.where().findFirst())!;
    expect(action.status, 'due');
  });

  test('repeating the choice reuses the lifecycle and the action', () async {
    final source = await fixture.addSource();
    await fixture.addSchedule(source, nominalDay: 10);

    final firstCycle = await activation.chooseExpectLater(source, '2026-11');
    final firstAction = (await fixture.db.pendingActions.where().findFirst())!;
    final secondCycle = await activation.chooseExpectLater(source, '2026-11');

    final rows = await fixture.db.pendingActions.where().findAll();
    expect(rows.length, 1);
    expect(rows.single.guid, firstAction.guid);
    expect(secondCycle.guid, firstCycle.guid);
    expect(await fixture.db.salaryCycles.count(), 1);
    expect(
        await fixture.db.auditEvents
            .filter()
            .actionEqualTo('income.period.expectationCreated')
            .count(),
        1);
  });

  test('terminal periods cannot choose expect later', () async {
    final skipped = await fixture.addSource(name: 'Skipped');
    await fixture.addCycle(skipped, state: IncomePeriodState.skipped.name);
    final cancelled = await fixture.addSource(name: 'Cancelled');
    await fixture.addCycle(cancelled, state: IncomePeriodState.cancelled.name);
    final confirmed = await fixture.addSource(name: 'Confirmed');
    await fixture.addCycle(confirmed, state: IncomePeriodState.confirmed.name);

    for (final source in [skipped, cancelled]) {
      await expectLater(
          activation.chooseExpectLater(source, '2026-11'),
          throwsA(isA<IncomeActivationException>()
              .having((e) => e.code, 'code', 'periodClosed')));
    }
    await expectLater(
        activation.chooseExpectLater(confirmed, '2026-11'),
        throwsA(isA<IncomeActivationException>()
            .having((e) => e.code, 'code', 'alreadyConfirmed')));
    expect(await fixture.db.pendingActions.count(), 0);
  });

  test('the expected date is clamped to the period length', () async {
    final source = await fixture.addSource(
        name: 'Rent',
        type: IncomeSourceType.rental,
        startDate: DateTime(2026, 2, 1));
    await fixture.addSchedule(source, nominalDay: 31);

    final cycle = await activation.chooseExpectLater(source, '2026-02');

    final action = (await fixture.db.pendingActions.where().findFirst())!;
    expect(cycle.adjustedPayday, DateTime(2026, 2, 28));
    expect(action.expectedAt!.isAtSameMomentAs(DateTime(2026, 2, 28)), isTrue);
    expect(await activation.expectedDateFor(source, '2026-02'),
        DateTime(2026, 2, 28));
  });

  test('a one-time source uses its single receipt date', () async {
    final source = await fixture.addSource(
        name: 'Bonus',
        type: IncomeSourceType.bonus,
        frequency: IncomeFrequency.oneTime,
        startDate: DateTime(2026, 11, 15));

    final cycle = await activation.chooseExpectLater(source, '2026-11');

    final action = (await fixture.db.pendingActions.where().findFirst())!;
    expect(cycle.adjustedPayday, DateTime(2026, 11, 15));
    expect(action.expectedAt!.isAtSameMomentAs(DateTime(2026, 11, 15)), isTrue);
    expect(await fixture.db.salarySchedules.count(), 0);
  });
}
