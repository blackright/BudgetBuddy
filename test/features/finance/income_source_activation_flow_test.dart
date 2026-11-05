import 'package:budget_buddy/core/models/income_receipt_group.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/money_receipt.dart';
import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/core/models/salary_schedule.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/services/income_activation_service.dart';
import 'package:budget_buddy/features/finance/providers/income_source_providers.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:budget_buddy/features/finance/repositories/income_source_repository.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_service.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../../support/income_activation_fixture.dart';

void main() {
  late IncomeActivationFixture fixture;
  late ProviderContainer container;
  late PendingActionService actions;

  setUp(() async {
    fixture = await IncomeActivationFixture.create();
    actions = PendingActionService(fixture.db,
        profileId: fixture.profileId, clock: () => DateTime.utc(2026, 11, 3));
    final activation = IncomeActivationService(
      fixture.db,
      profileId: fixture.profileId,
      audit: AuditRepository(fixture.db, actorId: fixture.profileId),
      pendingActions: actions,
      clock: () => DateTime.utc(2026, 11, 3),
    );
    container = ProviderContainer(overrides: [
      budgetContextProvider.overrideWithValue(ContextRef.personal(
        profileId: fixture.profileId,
        yearMonth: fixture.month,
      )),
      incomeSourceRepositoryProvider.overrideWithValue(
        IncomeSourceRepository(fixture.db, actorId: fixture.profileId),
      ),
      incomeActivationServiceProvider.overrideWithValue(activation),
    ]);
    addTearDown(container.dispose);
    addTearDown(fixture.close);
  });

  IncomeSource source(IncomeFrequency frequency) => IncomeSource()
    ..name = 'Salary'
    ..type = IncomeSourceType.salary
    ..amount = 500000
    ..currency = 'huf'
    ..frequency = frequency
    ..startDate = DateTime.utc(2026, 11, 1)
    ..createdAt = DateTime.utc(2026, 11, 1)
    ..updatedAt = DateTime.utc(2026, 11, 1);

  test('saving a recurring source writes no lifecycle, action or money',
      () async {
    final row = source(IncomeFrequency.monthly);

    await container
        .read(incomeSourceActionsProvider)
        .save(row, nominalDay: 10, timezone: 'UTC');

    expect(await fixture.db.incomeSources.count(), 1);
    final schedule = (await fixture.db.salarySchedules.where().findFirst())!;
    expect(schedule.nominalDay, 10);
    expect(schedule.sourceGuid, row.syncGuid);
    expect(await fixture.db.salaryCycles.count(), 0);
    expect(await fixture.db.pendingActions.count(), 0);
    expect(await fixture.db.moneyReceipts.count(), 0);
    expect(await fixture.db.incomeReceiptGroups.count(), 0);
  });

  test('a one-time source does not create a usual-day schedule', () async {
    final row = source(IncomeFrequency.oneTime);

    await container
        .read(incomeSourceActionsProvider)
        .save(row, nominalDay: 10, timezone: 'UTC');

    expect(await fixture.db.incomeSources.count(), 1);
    expect(await fixture.db.salarySchedules.count(), 0);
    expect(await fixture.db.salaryCycles.count(), 0);
    expect(await fixture.db.pendingActions.count(), 0);
  });

  test('deleting a source cancels its current setup action', () async {
    final row = await fixture.addSource(name: 'Delete me');
    final action = await fixture.addAction(
      actionType: PendingActionTypes.incomeActivate,
      recordRef: row.syncGuid,
      cycleOrMonth: '2026-11',
      status: 'due',
    );

    await container.read(incomeSourceActionsProvider).delete(row.id);

    final stored = (await fixture.db.pendingActions.get(action.id))!;
    expect(stored.status, 'cancelled');
    expect(stored.dismissedReason, 'sourceMissing');
    expect(await fixture.db.incomeSources.get(row.id), isNull);
  });

  test('ending a source cancels its current setup action', () async {
    final row = await fixture.addSource(name: 'Ending');
    final action = await fixture.addAction(
      actionType: PendingActionTypes.incomeActivate,
      recordRef: row.syncGuid,
      cycleOrMonth: '2026-11',
      status: 'due',
    );
    row.endDate = DateTime.utc(2026, 10, 31);

    await container.read(incomeSourceActionsProvider).save(row);

    final stored = (await fixture.db.pendingActions.get(action.id))!;
    expect(stored.status, 'cancelled');
    expect(stored.dismissedReason, 'sourceEnded');
  });
}
