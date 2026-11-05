import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/income_receipt_group.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/money_receipt.dart';
import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/core/services/income_activation_service.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_service.dart';
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

  test('start next creates a skipped period, no action and no money', () async {
    final source = await fixture.addSource();
    final schedule = await fixture.addSchedule(source, nominalDay: 10);

    final cycle = await activation.chooseStartNext(source, '2026-11');

    expect(cycle.state, IncomePeriodState.skipped.name);
    expect(cycle.confirmed, isFalse);
    expect(cycle.expectedAmountMinor, 500000);
    expect(cycle.scheduleGuid, schedule.guid);
    expect(cycle.nominalPayday, DateTime(2026, 11, 10));
    expect(await fixture.db.pendingActions.where().findAll(), isEmpty);
    expect(await fixture.db.moneyReceipts.count(), 0);
    expect(await fixture.db.incomeReceiptGroups.count(), 0);
    expect(
        await fixture.db.auditEvents
            .filter()
            .actionEqualTo('income.period.skipped')
            .count(),
        1);

    final cycles = await fixture.cyclesFor(source.syncGuid);
    expect(cycles.length, 2);
    final next = cycles.singleWhere((row) => row.occurrenceMonth == '2026-12');
    expect(next.state, IncomePeriodState.pending.name);
    expect(next.confirmed, isFalse);
    expect(next.expectedAmountMinor, 500000);
    expect(next.nominalPayday, DateTime(2026, 12, 10));
  });

  test('start next cancels an existing expected action', () async {
    final source = await fixture.addSource();
    await fixture.addSchedule(source, nominalDay: 10);
    await activation.chooseExpectLater(source, '2026-11');
    final action = (await fixture.db.pendingActions.where().findFirst())!;

    final cycle = await activation.chooseStartNext(source, '2026-11');

    final cancelled = (await fixture.db.pendingActions.get(action.id))!;
    final active = (await fixture.db.pendingActions.where().findAll())
        .where((row) => row.isActive)
        .length;
    expect(cycle.state, IncomePeriodState.skipped.name);
    expect(cancelled.status, 'cancelled');
    expect(cancelled.dismissedReason, 'startNextPeriod');
    expect(active, 0);
    expect(await fixture.db.pendingActions.count(), 1);

    final cycles = await fixture.cyclesFor(source.syncGuid);
    expect(cycles.length, 2);
    expect(cycles.singleWhere((row) => row.occurrenceMonth == '2026-12').state,
        IncomePeriodState.pending.name);
  });

  test('start next is idempotent and does not duplicate the next period',
      () async {
    final source = await fixture.addSource();
    await fixture.addSchedule(source, nominalDay: 10);

    await activation.chooseStartNext(source, '2026-11');
    await activation.chooseStartNext(source, '2026-11');

    expect(await fixture.db.salaryCycles.count(), 2);
    expect(await fixture.db.pendingActions.count(), 0);
    expect(
        await fixture.db.auditEvents
            .filter()
            .actionEqualTo('income.period.skipped')
            .count(),
        1);
  });

  test('start next refuses confirmed and cancelled periods', () async {
    final confirmed = await fixture.addSource(name: 'Confirmed');
    await fixture.addCycle(confirmed, state: IncomePeriodState.confirmed.name);
    final cancelled = await fixture.addSource(name: 'Cancelled');
    await fixture.addCycle(cancelled, state: IncomePeriodState.cancelled.name);

    await expectLater(
        activation.chooseStartNext(confirmed, '2026-11'),
        throwsA(isA<IncomeActivationException>()
            .having((e) => e.code, 'code', 'alreadyConfirmed')));
    await expectLater(
        activation.chooseStartNext(cancelled, '2026-11'),
        throwsA(isA<IncomeActivationException>()
            .having((e) => e.code, 'code', 'periodClosed')));
  });

  test('activation sync does not recreate a skipped period', () async {
    final source = await fixture.addSource();
    await fixture.addSchedule(source, nominalDay: 10);
    final skipped = await activation.chooseStartNext(source, '2026-11');

    await activation.ensureActivationActions(fixture.profileId, '2026-11');
    final result = await activation.stateFor(source, '2026-11');

    expect(result, IncomePeriodState.skipped);
    expect((await fixture.lifecycle(source))!.guid, skipped.guid);
    expect(await fixture.db.salaryCycles.count(), 2);
    expect(await fixture.db.pendingActions.count(), 0);
  });

  test('a one-time source skips without a next period', () async {
    final source = await fixture.addSource(
        name: 'Bonus',
        type: IncomeSourceType.bonus,
        frequency: IncomeFrequency.oneTime,
        startDate: DateTime(2026, 11, 15));

    final cycle = await activation.chooseStartNext(source, '2026-11');

    expect(cycle.state, IncomePeriodState.skipped.name);
    expect(await fixture.db.salaryCycles.count(), 1);
    expect(await fixture.db.pendingActions.count(), 0);
  });

  test('a source ending before the next period creates no next period',
      () async {
    final source = await fixture.addSource(
        name: 'Ending', endDate: DateTime(2026, 11, 30));
    await fixture.addSchedule(source, nominalDay: 10);

    await activation.chooseStartNext(source, '2026-11');

    expect(await fixture.db.salaryCycles.count(), 1);
    expect(await fixture.db.pendingActions.count(), 0);
  });

  test('a terminal next period is left untouched', () async {
    final source = await fixture.addSource();
    await fixture.addSchedule(source, nominalDay: 10);
    await fixture.addCycle(
      source,
      occurrenceMonth: '2026-12',
      state: IncomePeriodState.confirmed.name,
    );

    await activation.chooseStartNext(source, '2026-11');

    final next = (await fixture.cyclesFor(source.syncGuid))
        .singleWhere((row) => row.occurrenceMonth == '2026-12');
    expect(next.state, IncomePeriodState.confirmed.name);
    expect(next.confirmed, isTrue);
  });
}
