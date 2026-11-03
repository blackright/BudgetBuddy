import 'package:budget_buddy/core/models/income_receipt_group.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/money_receipt.dart';
import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/core/services/income_activation_service.dart';
import 'package:budget_buddy/core/services/income_receipt_service.dart';
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

  Future<IncomeSource> unfinishedSource() async {
    final source = await fixture.addSource(
        name: 'Freelance', type: IncomeSourceType.freelance);
    await fixture.addSchedule(source, nominalDay: 10);
    await activation.chooseAlreadyReceived(source, '2026-11');
    await activation.markConfirmationUnfinished(source, '2026-11');
    return source;
  }

  test('closing before confirmation creates one due-now task and no money',
      () async {
    final source = await unfinishedSource();

    final rows = await fixture.db.pendingActions.where().findAll();
    final action = rows.single;
    expect(action.actionType, PendingActionTypes.incomeComplete);
    expect(action.title, 'Complete income confirmation');
    expect(action.nextAction, 'Resume income confirmation');
    expect(action.recordRef, 'salary-cycle:${source.syncGuid}:2026-11');
    expect(action.expectedMonth, '2026-11');
    expect(action.expectedAmountMinor, source.amount);
    expect(action.currency, source.currency);
    expect(action.expectedAt!.isAtSameMomentAs(now), isTrue);
    expect(action.expectedMonth, '2026-11');
    expect(action.status, 'due');
    expect(action.deepLink, '/income_sources');
    expect(await fixture.db.moneyReceipts.count(), 0);
    expect(await fixture.db.incomeReceiptGroups.count(), 0);

    final cycle = (await fixture.lifecycle(source))!;
    expect(cycle.state, IncomePeriodState.pending.name);
    expect(cycle.confirmed, isFalse);
  });

  test('closing twice reuses the same task', () async {
    final source = await unfinishedSource();
    final first = (await fixture.db.pendingActions.where().findFirst())!;

    await activation.markConfirmationUnfinished(source, '2026-11');

    final rows = await fixture.db.pendingActions.where().findAll();
    expect(rows.length, 1);
    expect(rows.single.guid, first.guid);
    expect(rows.single.status, 'due');
  });

  test('a confirmed period does not receive an unfinished task', () async {
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
    await receipts.confirm(
        preview: preview, operationKey: 'once', isAccessCurrent: () => true);

    await activation.markConfirmationUnfinished(source, '2026-11');

    expect(await fixture.db.pendingActions.count(), 0);
  });

  test('resuming an unfinished confirmation completes its task once', () async {
    final source = await unfinishedSource();
    final action = (await fixture.db.pendingActions.where().findFirst())!;
    final receipts = IncomeReceiptService(fixture.db,
        pendingActions: actions, clock: () => now);
    final cycle = (await fixture.lifecycle(source))!;
    final preview = await receipts.preview(
      source: source,
      cycle: cycle,
      amountMinor: 480000,
      actualDate: DateTime.utc(2026, 11, 3),
      timezone: 'UTC',
      isAccessCurrent: () => true,
    );

    final group = await receipts.confirm(
        preview: preview, operationKey: 'resume', isAccessCurrent: () => true);

    final saved = (await fixture.lifecycle(source))!;
    final completed = await fixture.db.pendingActions.get(action.id);
    expect(completed!.status, 'completed');
    expect(completed.completedAt, isNotNull);
    expect(saved.confirmed, isTrue);
    expect(saved.state, IncomePeriodState.confirmed.name);
    expect(saved.receiptGroupGuid, group.guid);
    expect(await fixture.db.incomeReceiptGroups.count(), 1);
    expect(await fixture.db.salaryCycles.count(), 1);
  });
}
