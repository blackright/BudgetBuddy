import 'dart:convert';

import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/income_receipt_group.dart';
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

  test('cancel expected income requires a reason', () async {
    final source = await fixture.addSource();
    await fixture.addSchedule(source, nominalDay: 10);
    await activation.chooseExpectLater(source, '2026-11');
    final action = (await fixture.db.pendingActions.where().findFirst())!;

    await expectLater(activation.cancelExpected(source, '2026-11', '   '),
        throwsArgumentError);

    final cycle = (await fixture.lifecycle(source))!;
    final unchanged = (await fixture.db.pendingActions.get(action.id))!;
    expect(cycle.state, IncomePeriodState.pending.name);
    expect(unchanged.status, 'pending');
    expect(
        await fixture.db.auditEvents
            .filter()
            .actionEqualTo('income.period.cancelled')
            .count(),
        0);
  });

  test('cancel expected income marks the period and action cancelled',
      () async {
    final source = await fixture.addSource();
    await fixture.addSchedule(source, nominalDay: 10);
    await activation.chooseExpectLater(source, '2026-11');
    final action = (await fixture.db.pendingActions.where().findFirst())!;

    await activation.cancelExpected(source, '2026-11', 'Not coming this month');

    final cycle = (await fixture.lifecycle(source))!;
    final cancelled = (await fixture.db.pendingActions.get(action.id))!;
    final active = (await fixture.db.pendingActions.where().findAll())
        .where((row) => row.isActive)
        .length;
    expect(cycle.state, IncomePeriodState.cancelled.name);
    expect(cycle.confirmed, isFalse);
    expect(cancelled.status, 'cancelled');
    expect(cancelled.dismissedReason, 'Not coming this month');
    expect(active, 0);
    expect(await fixture.db.salaryCycles.count(), 1);
    expect(await fixture.db.moneyReceipts.count(), 0);
    expect(await fixture.db.incomeReceiptGroups.count(), 0);

    final event = (await fixture.db.auditEvents
        .filter()
        .actionEqualTo('income.period.cancelled')
        .findFirst())!;
    final after = jsonDecode(event.newValue!) as Map<String, dynamic>;
    expect(after['state'], IncomePeriodState.cancelled.name);
    expect(after['reason'], 'Not coming this month');
  });

  test('cancel is idempotent and never regenerates the period', () async {
    final source = await fixture.addSource();
    await fixture.addSchedule(source, nominalDay: 10);
    await activation.chooseExpectLater(source, '2026-11');
    await activation.cancelExpected(source, '2026-11', 'Not coming');

    await activation.cancelExpected(source, '2026-11', 'Not coming');

    final result = await activation.stateFor(source, '2026-11');
    expect(result, IncomePeriodState.cancelled);
    expect(await fixture.db.salaryCycles.count(), 1);
    expect(await fixture.db.pendingActions.count(), 1);
    expect(
        await fixture.db.auditEvents
            .filter()
            .actionEqualTo('income.period.cancelled')
            .count(),
        1);
  });

  test('cancel refuses confirmed and skipped periods', () async {
    final confirmed = await fixture.addSource(name: 'Confirmed');
    await fixture.addCycle(confirmed, state: IncomePeriodState.confirmed.name);
    final skipped = await fixture.addSource(name: 'Skipped');
    await fixture.addCycle(skipped, state: IncomePeriodState.skipped.name);

    await expectLater(
        activation.cancelExpected(confirmed, '2026-11', 'Stop'),
        throwsA(isA<IncomeActivationException>()
            .having((e) => e.code, 'code', 'alreadyConfirmed')));
    await expectLater(
        activation.cancelExpected(skipped, '2026-11', 'Stop'),
        throwsA(isA<IncomeActivationException>()
            .having((e) => e.code, 'code', 'periodClosed')));
  });

  test('cancel without a lifecycle is refused', () async {
    final source = await fixture.addSource();

    await expectLater(
        activation.cancelExpected(source, '2026-11', 'Stop'),
        throwsA(isA<IncomeActivationException>()
            .having((e) => e.code, 'code', 'missingLifecycle')));
    expect(await fixture.db.pendingActions.count(), 0);
  });
}
