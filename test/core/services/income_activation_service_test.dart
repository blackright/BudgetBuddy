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
  late IncomeActivationFixture fixture;
  late IncomeActivationService service;
  late PendingActionService actions;

  setUp(() async {
    fixture = await IncomeActivationFixture.create();
    actions = PendingActionService(fixture.db,
        profileId: fixture.profileId, clock: () => DateTime.utc(2026, 11, 3));
    service = IncomeActivationService(
      fixture.db,
      profileId: fixture.profileId,
      audit: AuditRepository(fixture.db, actorId: fixture.profileId),
      pendingActions: actions,
      clock: () => DateTime.utc(2026, 11, 3),
    );
    addTearDown(fixture.close);
  });

  test('a source without a lifecycle is unconfigured', () async {
    final source = await fixture.addSource();

    expect(await service.stateFor(source, '2026-11'),
        IncomePeriodState.needsActivation);
    expect(await service.lifecycleFor(source, '2026-11'), isNull);
  });

  test('legacy unconfirmed and confirmed rows map to explicit states',
      () async {
    final legacy = await fixture.addSource(name: 'Legacy');
    await fixture.addCycle(legacy, state: 'unconfirmed');
    final confirmed = await fixture.addSource(name: 'Confirmed');
    await fixture.addCycle(confirmed, state: 'confirmed');

    expect(await service.stateFor(legacy, '2026-11'),
        IncomePeriodState.needsActivation);
    expect(await service.stateFor(confirmed, '2026-11'),
        IncomePeriodState.confirmed);
  });

  test('pending, skipped and cancelled states are read exactly', () async {
    for (final state in [
      IncomePeriodState.pending,
      IncomePeriodState.skipped,
      IncomePeriodState.cancelled,
    ]) {
      final source = await fixture.addSource(name: state.name);
      await fixture.addCycle(source, state: state.name);
      expect(await service.stateFor(source, '2026-11'), state);
    }
  });

  test('schedule creation is one per source and updates in place', () async {
    final source = await fixture.addSource();
    final created =
        await service.upsertSchedule(source, nominalDay: 10, timezone: 'UTC');
    final updated =
        await service.upsertSchedule(source, nominalDay: 12, timezone: 'UTC');

    expect(created.guid, updated.guid);
    expect(updated.nominalDay, 12);
    expect(await fixture.db.salarySchedules.count(), 1);
    expect(
        await fixture.db.auditEvents
            .filter()
            .actionEqualTo('income.schedule.created')
            .count(),
        1);
    expect(
        await fixture.db.auditEvents
            .filter()
            .actionEqualTo('income.schedule.updated')
            .count(),
        1);
  });

  test('schedule validation refuses invalid day and timezone', () async {
    final source = await fixture.addSource();

    await expectLater(
        service.upsertSchedule(source, nominalDay: 0, timezone: 'UTC'),
        throwsArgumentError);
    await expectLater(
        service.upsertSchedule(source, nominalDay: 10, timezone: ' '),
        throwsArgumentError);
  });

  test('lifecycle creation is idempotent and keeps schedule and amount',
      () async {
    final source = await fixture.addSource(amount: 700000);
    final schedule =
        await service.upsertSchedule(source, nominalDay: 10, timezone: 'UTC');
    final first = await service.ensureLifecycle(
      source,
      periodKey: '2026-11',
      state: IncomePeriodState.pending,
      expectedAt: DateTime.utc(2026, 11, 10),
    );
    final second = await service.ensureLifecycle(
      source,
      periodKey: '2026-11',
      state: IncomePeriodState.pending,
      expectedAt: DateTime.utc(2026, 11, 10),
    );

    expect(first.guid, 'salary-cycle:${source.syncGuid}:2026-11');
    expect(first.sourceGuid, source.syncGuid);
    expect(first.scheduleGuid, schedule.guid);
    expect(first.expectedAmountMinor, 700000);
    expect(first.occurrenceMonth, '2026-11');
    expect(first.state, IncomePeriodState.pending.name);
    expect(second.guid, first.guid);
    expect(await fixture.db.salaryCycles.count(), 1);
    expect(
        await fixture.db.auditEvents
            .filter()
            .actionEqualTo('income.period.created')
            .count(),
        1);
  });

  test('terminal lifecycles are not revived by ensureLifecycle', () async {
    final source = await fixture.addSource();
    final skipped = await fixture.addCycle(
      source,
      state: IncomePeriodState.skipped.name,
    );

    final result = await service.ensureLifecycle(source,
        periodKey: '2026-11', state: IncomePeriodState.pending);

    expect(result.guid, skipped.guid);
    expect(result.state, IncomePeriodState.skipped.name);
    expect(await fixture.db.salaryCycles.count(), 1);
  });

  test('state changes are audited and terminal rows cannot be reopened',
      () async {
    final source = await fixture.addSource();
    final cycle = await service.ensureLifecycle(source,
        periodKey: '2026-11', state: IncomePeriodState.pending);

    await service.updateLifecycleState(cycle, IncomePeriodState.cancelled,
        reason: 'Not coming');
    final saved = (await fixture.lifecycle(source))!;
    expect(saved.state, IncomePeriodState.cancelled.name);
    expect(
        await fixture.db.auditEvents
            .filter()
            .actionEqualTo('income.period.stateChanged')
            .count(),
        1);

    await expectLater(
        service.updateLifecycleState(saved, IncomePeriodState.pending),
        throwsStateError);
  });

  test('legacy normalization persists needsActivation and preserves confirmed',
      () async {
    final legacy = await fixture.addSource(name: 'Legacy');
    await fixture.addCycle(legacy, state: 'unconfirmed');
    final confirmed = await fixture.addSource(name: 'Confirmed');
    await fixture.addCycle(confirmed, state: 'confirmed');

    expect(await service.normalizeLegacy(legacy), 1);
    expect((await fixture.lifecycle(legacy))!.state,
        IncomePeriodState.needsActivation.name);
    expect(await service.normalizeLegacy(legacy), 0);

    await service.normalizeLegacy(confirmed);
    final confirmedRow = (await fixture.lifecycle(confirmed))!;
    expect(confirmedRow.state, IncomePeriodState.confirmed.name);
    expect(confirmedRow.confirmed, isTrue);
    expect(
        await fixture.db.auditEvents
            .filter()
            .actionEqualTo('income.period.legacyNormalized')
            .count(),
        1);
  });

  test('legacy normalization replaces the old confirmation with setup',
      () async {
    final legacy = await fixture.addSource(name: 'Legacy');
    final legacyCycle = await fixture.addCycle(legacy, state: 'unconfirmed');
    final oldAction = await fixture.addAction(
      actionType: PendingActionTypes.salaryConfirm,
      recordRef: legacyCycle.guid,
      cycleOrMonth: '2026-11',
      status: 'due',
      title: 'Confirm salary received',
    );
    final confirmed = await fixture.addSource(name: 'Confirmed');
    await fixture.addCycle(confirmed, state: 'confirmed');

    await service.ensureActivationActions(fixture.profileId, '2026-11');

    final cancelled = (await fixture.db.pendingActions.get(oldAction.id))!;
    expect(cancelled.status, 'cancelled');
    expect(cancelled.dismissedReason, 'legacyAutoExpected');
    final activation =
        (await fixture.actionsFor(PendingActionTypes.incomeActivate)).single;
    expect(activation.recordRef, legacy.syncGuid);
    expect(activation.status, 'due');
    expect((await fixture.lifecycle(legacy))!.state,
        IncomePeriodState.needsActivation.name);
    expect((await fixture.lifecycle(confirmed))!.state, 'confirmed');
    expect(await fixture.db.moneyReceipts.count(), 0);
    expect(await fixture.db.incomeReceiptGroups.count(), 0);
  });

  test('ensure closes setup tasks for future, ended or missing sources',
      () async {
    final current = await fixture.addSource(name: 'Current');
    await service.ensureActivationActions(fixture.profileId, '2026-11');
    final activation =
        (await fixture.actionsFor(PendingActionTypes.incomeActivate)).single;
    expect(activation.recordRef, current.syncGuid);

    current
      ..endDate = DateTime.utc(2026, 10, 31)
      ..updatedAt = DateTime.utc(2026, 11);
    await fixture.db.writeTxn(() => fixture.db.incomeSources.put(current));
    await service.ensureActivationActions(fixture.profileId, '2026-11');
    final ended = (await fixture.db.pendingActions.get(activation.id))!;
    expect(ended.status, 'cancelled');
    expect(ended.dismissedReason, 'periodClosed');

    final removed = await fixture.addSource(name: 'Removed');
    await service.ensureActivationActions(fixture.profileId, '2026-11');
    final removedAction =
        (await fixture.actionsFor(PendingActionTypes.incomeActivate))
            .singleWhere((row) => row.recordRef == removed.syncGuid);
    await fixture.db
        .writeTxn(() => fixture.db.incomeSources.delete(removed.id));
    await service.ensureActivationActions(fixture.profileId, '2026-11');
    final missing = (await fixture.db.pendingActions.get(removedAction.id))!;
    expect(missing.status, 'cancelled');
    expect(missing.dismissedReason, 'sourceMissing');
  });

  test('wrong owner and malformed period are refused', () async {
    final source = await fixture.addSource();
    source.profileId = fixture.profileId + 99;
    await fixture.db.writeTxn(() => fixture.db.incomeSources.put(source));

    await expectLater(service.stateFor(source, '2026-11'),
        throwsA(isA<IncomeActivationException>()));
    final owned = await fixture.addSource();
    await expectLater(
        service.stateFor(owned, '2026-13'), throwsFormatException);
  });

  test('unconfigured active sources get one due activation action', () async {
    final unconfigured = await fixture.addSource(
        name: 'Freelance', type: IncomeSourceType.freelance);
    final pending = await fixture.addSource(name: 'Pending');
    await fixture.addCycle(pending, state: IncomePeriodState.pending.name);
    final skipped = await fixture.addSource(name: 'Skipped');
    await fixture.addCycle(skipped, state: IncomePeriodState.skipped.name);
    await fixture.addSource(
        name: 'Future',
        type: IncomeSourceType.freelance,
        startDate: DateTime(2026, 12, 1));

    await service.ensureActivationActions(fixture.profileId, '2026-11');

    final rows = await fixture.db.pendingActions.where().findAll();
    final action = rows.single;
    expect(action.actionType, PendingActionTypes.incomeActivate);
    expect(action.title, 'Set up current period');
    expect(action.recordRef, unconfigured.syncGuid);
    expect(action.expectedMonth, '2026-11');
    expect(action.expectedAmountMinor, 500000);
    expect(action.status, 'due');
    expect(await fixture.db.moneyReceipts.count(), 0);
    expect(await fixture.db.incomeReceiptGroups.count(), 0);

    await service.ensureActivationActions(fixture.profileId, '2026-11');
    expect(await fixture.db.pendingActions.count(), 1);
  });

  test('foundational lifecycle writes never create money', () async {
    final source = await fixture.addSource();
    await service.upsertSchedule(source, nominalDay: 10, timezone: 'UTC');
    await service.ensureLifecycle(source,
        periodKey: '2026-11', state: IncomePeriodState.pending);

    expect(await fixture.db.moneyReceipts.count(), 0);
    expect(await fixture.db.incomeReceiptGroups.count(), 0);
    expect(await fixture.db.pendingActions.count(), 0);
  });
}
