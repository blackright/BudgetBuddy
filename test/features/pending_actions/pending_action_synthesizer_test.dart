import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/month_end_run.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/core/models/sync_cursor.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_service.dart';
import 'package:budget_buddy/features/pending_actions/services/pending_action_synthesizer.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:budget_buddy/features/vault/models/vault_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import '../../features/medical/repositories/medical_test_harness.dart';

void main() {
  late MedicalTestHarness h;
  final now = DateTime.utc(2026, 10, 23, 12);

  setUp(() async {
    h = await MedicalTestHarness.create();
    await h.isar.writeTxn(() async {
      await h.isar.userProfiles.put(UserProfile()
        ..id = 1
        ..name = 'Owner'
        ..primaryCurrency = PrimaryCurrency.usd
        ..monthlyAvailableAmount = 0
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
      await h.isar.incomeSources.put(IncomeSource()
        ..syncGuid = 'source'
        ..profileId = 1
        ..name = 'Salary'
        ..type = IncomeSourceType.salary
        ..amount = 0
        ..currency = 'usd'
        ..frequency = IncomeFrequency.monthly
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });
  });

  tearDown(() => h.close());

  Future<PendingActionSynthesizer> synthesizer(
      {int? profileId = 1, int? spaceId}) {
    final service = PendingActionService(h.isar,
        profileId: profileId, sharedSpaceId: spaceId, clock: () => now);
    return Future.value(PendingActionSynthesizer(h.isar,
        profileId: profileId,
        sharedSpaceId: spaceId,
        service: service,
        clock: () => now));
  }

  test('salary, allocation and month-end sources each create one action',
      () async {
    await h.isar.writeTxn(() async {
      await h.isar.salaryCycles.put(SalaryCycle()
        ..guid = 'cycle-oct'
        ..profileId = 1
        ..sourceGuid = 'source'
        ..scheduleGuid = 'schedule'
        ..expectedAmountMinor = 500000
        ..currency = 'usd'
        ..occurrenceMonth = '2026-10'
        ..nominalPayday = DateTime.utc(2026, 10, 20)
        ..adjustedPayday = DateTime.utc(2026, 10, 20)
        ..confirmed = false
        ..state = 'pending'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
      await h.isar.monthlyBudgets.put(MonthlyBudget()
        ..profileId = 1
        ..yearMonth = '2026-09'
        ..baseAvailableAmount = 1000
        ..openingBalanceConfirmed = true
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
      await h.isar.budgetProfiles.put(BudgetProfile()
        ..syncGuid = 'car'
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..name = 'Car'
        ..allocation = 100
        ..spent = 150
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });

    await (await synthesizer()).synthesize();

    final rows = await h.isar.pendingActions.where().findAll();
    expect(rows.map((row) => row.actionType).toSet(),
        {'salary.confirm', 'allocation.overspent', 'monthend.close'});
    expect(
        rows
            .singleWhere((row) => row.actionType == 'salary.confirm')
            .expectedAmountMinor,
        500000);
    expect(
        rows
            .singleWhere((row) => row.actionType == 'allocation.overspent')
            .expectedAmountMinor,
        50);
    expect(
        rows.singleWhere((row) => row.actionType == 'monthend.close').deepLink,
        '/month_end?month=2026-09');
  });

  test('a month-end conflict deep link carries the run month', () async {
    await h.isar.writeTxn(() async {
      await h.isar.monthEndRuns.put(MonthEndRun()
        ..syncGuid = 'run-conflict'
        ..profileId = 1
        ..contextGuid = 'personal:1'
        ..yearMonth = '2026-09'
        ..destinationMonth = '2026-10'
        ..currency = 'usd'
        ..reportJson = '{"lines":[]}'
        ..fingerprint = 'fingerprint'
        ..actor = 'profile:1'
        ..createdAt = now
        ..hasConflict = true
        ..applied = false);
    });

    await (await synthesizer()).synthesize();

    final action = (await h.isar.pendingActions.where().findAll())
        .singleWhere((row) => row.actionType == 'monthend.conflict');
    expect(action.deepLink, '/month_end?month=2026-09');
    expect(action.expectedMonth, '2026-09');
  });

  test('a second synthesis produces the same rows', () async {
    await h.isar.writeTxn(() async {
      await h.isar.salaryCycles.put(SalaryCycle()
        ..guid = 'cycle-oct'
        ..profileId = 1
        ..sourceGuid = 'source'
        ..scheduleGuid = 'schedule'
        ..expectedAmountMinor = 500000
        ..currency = 'usd'
        ..occurrenceMonth = '2026-10'
        ..nominalPayday = DateTime.utc(2026, 10, 20)
        ..adjustedPayday = DateTime.utc(2026, 10, 20)
        ..confirmed = false
        ..state = 'pending'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });
    final s = await synthesizer();
    await s.synthesize();
    final first = await h.isar.pendingActions.where().findAll();
    await s.synthesize();
    final second = await h.isar.pendingActions.where().findAll();

    expect(second.length, first.length);
    expect(second.map((row) => row.guid).toSet(),
        first.map((row) => row.guid).toSet());
  });

  test('a confirmed cycle cancels the matching salary action', () async {
    await h.isar.writeTxn(() async {
      await h.isar.salaryCycles.put(SalaryCycle()
        ..guid = 'cycle-oct'
        ..profileId = 1
        ..sourceGuid = 'source'
        ..scheduleGuid = 'schedule'
        ..expectedAmountMinor = 500000
        ..currency = 'usd'
        ..occurrenceMonth = '2026-10'
        ..nominalPayday = DateTime.utc(2026, 10, 20)
        ..adjustedPayday = DateTime.utc(2026, 10, 20)
        ..confirmed = false
        ..state = 'pending'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });
    final s = await synthesizer();
    await s.synthesize();
    await h.isar.writeTxn(() async {
      final cycle = (await h.isar.salaryCycles
          .filter()
          .guidEqualTo('cycle-oct')
          .findFirst())!
        ..confirmed = true;
      await h.isar.salaryCycles.put(cycle);
    });

    await s.synthesize();

    final salary = (await h.isar.pendingActions.where().findAll()).single;
    expect(salary.status, 'cancelled');
    expect(salary.dismissedReason, 'periodClosed');
  });

  test('a legacy unconfirmed cycle creates one setup action', () async {
    await h.isar.writeTxn(() async {
      await h.isar.salaryCycles.put(SalaryCycle()
        ..guid = 'cycle-legacy'
        ..profileId = 1
        ..sourceGuid = 'source'
        ..scheduleGuid = 'schedule'
        ..expectedAmountMinor = 500000
        ..currency = 'usd'
        ..occurrenceMonth = '2026-10'
        ..nominalPayday = DateTime.utc(2026, 10, 20)
        ..adjustedPayday = DateTime.utc(2026, 10, 20)
        ..confirmed = false
        ..state = 'unconfirmed'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });

    await (await synthesizer()).synthesize();

    final action = (await h.isar.pendingActions.where().findAll()).single;
    expect(action.actionType, 'income.activate');
    expect(action.recordRef, 'source');
    expect(action.title, 'Set up current period');
  });

  test('a legacy confirmation action is replaced with a setup action',
      () async {
    await h.isar.writeTxn(() async {
      await h.isar.salaryCycles.put(SalaryCycle()
        ..guid = 'cycle-legacy'
        ..profileId = 1
        ..sourceGuid = 'source'
        ..scheduleGuid = 'schedule'
        ..expectedAmountMinor = 500000
        ..currency = 'usd'
        ..occurrenceMonth = '2026-10'
        ..nominalPayday = DateTime.utc(2026, 10, 20)
        ..adjustedPayday = DateTime.utc(2026, 10, 20)
        ..confirmed = false
        ..state = 'unconfirmed'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
      await h.isar.pendingActions.put(PendingAction()
        ..guid = 'legacy-action'
        ..profileId = 1
        ..actionType = 'salary.confirm'
        ..title = 'Legacy salary confirmation'
        ..nextAction = 'Confirm salary received'
        ..feature = 'salary'
        ..recordRef = 'cycle-legacy'
        ..expectedMonth = '2026-10'
        ..expectedAmountMinor = 500000
        ..currency = 'usd'
        ..expectedAt = DateTime.utc(2026, 10, 20)
        ..status = 'pending'
        ..dedupeKey = 'salary.confirm|cycle-legacy|2026-10'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });

    await (await synthesizer()).synthesize();

    final rows = await h.isar.pendingActions.where().findAll();
    final legacy = rows.singleWhere((row) => row.guid == 'legacy-action');
    expect(legacy.status, 'cancelled');
    expect(legacy.dismissedReason, 'legacyAutoExpected');
    final setup =
        rows.singleWhere((row) => row.actionType == 'income.activate');
    expect(setup.recordRef, 'source');
  });

  test('a skipped cycle creates no expected action', () async {
    await h.isar.writeTxn(() async {
      await h.isar.salaryCycles.put(SalaryCycle()
        ..guid = 'cycle-skipped'
        ..profileId = 1
        ..sourceGuid = 'source'
        ..scheduleGuid = 'schedule'
        ..expectedAmountMinor = 500000
        ..currency = 'usd'
        ..occurrenceMonth = '2026-10'
        ..nominalPayday = DateTime.utc(2026, 10, 20)
        ..adjustedPayday = DateTime.utc(2026, 10, 20)
        ..confirmed = false
        ..state = 'skipped'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });

    await (await synthesizer()).synthesize();

    expect(await h.isar.pendingActions.where().findAll(), isEmpty);
  });

  test('a skipped cycle cancels an active expected action', () async {
    await h.isar.writeTxn(() async {
      await h.isar.salaryCycles.put(SalaryCycle()
        ..guid = 'cycle-skipped'
        ..profileId = 1
        ..sourceGuid = 'source'
        ..scheduleGuid = 'schedule'
        ..expectedAmountMinor = 500000
        ..currency = 'usd'
        ..occurrenceMonth = '2026-10'
        ..nominalPayday = DateTime.utc(2026, 10, 20)
        ..adjustedPayday = DateTime.utc(2026, 10, 20)
        ..confirmed = false
        ..state = 'skipped'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
      await h.isar.pendingActions.put(PendingAction()
        ..profileId = 1
        ..actionType = 'salary.confirm'
        ..title = 'Confirm salary received'
        ..nextAction = 'Confirm salary received'
        ..feature = 'salary'
        ..recordRef = 'cycle-skipped'
        ..expectedMonth = '2026-10'
        ..expectedAt = DateTime.utc(2026, 10, 20)
        ..status = 'due'
        ..dedupeKey = 'salary.confirm|cycle-skipped|2026-10'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });

    await (await synthesizer()).synthesize();

    final action = (await h.isar.pendingActions.where().findAll()).single;
    expect(action.status, 'cancelled');
    expect(action.dismissedReason, 'periodClosed');
  });

  test('a cancelled cycle cancels an active completion action', () async {
    await h.isar.writeTxn(() async {
      await h.isar.salaryCycles.put(SalaryCycle()
        ..guid = 'cycle-cancelled'
        ..profileId = 1
        ..sourceGuid = 'source'
        ..scheduleGuid = 'schedule'
        ..expectedAmountMinor = 500000
        ..currency = 'usd'
        ..occurrenceMonth = '2026-10'
        ..nominalPayday = DateTime.utc(2026, 10, 20)
        ..adjustedPayday = DateTime.utc(2026, 10, 20)
        ..confirmed = false
        ..state = 'cancelled'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
      await h.isar.pendingActions.put(PendingAction()
        ..profileId = 1
        ..actionType = 'income.complete'
        ..title = 'Complete income confirmation'
        ..nextAction = 'Resume income confirmation'
        ..feature = 'salary'
        ..recordRef = 'cycle-cancelled'
        ..expectedMonth = '2026-10'
        ..expectedAt = DateTime.utc(2026, 10, 20)
        ..status = 'due'
        ..dedupeKey = 'income.complete|cycle-cancelled|2026-10'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });

    await (await synthesizer()).synthesize();

    final rows = await h.isar.pendingActions.where().findAll();
    expect(rows.single.status, 'cancelled');
    expect(rows.single.dismissedReason, 'periodClosed');
    expect(rows.single.actionType, 'income.complete');
  });

  test('a confirmed cycle completes an unfinished confirmation action',
      () async {
    await h.isar.writeTxn(() async {
      await h.isar.salaryCycles.put(SalaryCycle()
        ..guid = 'cycle-oct'
        ..profileId = 1
        ..sourceGuid = 'source'
        ..scheduleGuid = 'schedule'
        ..expectedAmountMinor = 500000
        ..currency = 'usd'
        ..occurrenceMonth = '2026-10'
        ..nominalPayday = DateTime.utc(2026, 10, 20)
        ..adjustedPayday = DateTime.utc(2026, 10, 20)
        ..confirmed = true
        ..state = 'confirmed'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
      await h.isar.pendingActions.put(PendingAction()
        ..profileId = 1
        ..actionType = 'income.complete'
        ..title = 'Complete income confirmation'
        ..nextAction = 'Resume income confirmation'
        ..feature = 'salary'
        ..recordRef = 'cycle-oct'
        ..expectedMonth = '2026-10'
        ..expectedAt = now
        ..status = 'due'
        ..dedupeKey = 'income.complete|cycle-oct|2026-10'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });

    await (await synthesizer()).synthesize();

    final action = (await h.isar.pendingActions.where().findAll()).single;
    expect(action.status, 'completed');
  });

  test('an unfinished confirmation does not also create an expected action',
      () async {
    await h.isar.writeTxn(() async {
      await h.isar.salaryCycles.put(SalaryCycle()
        ..guid = 'cycle-oct'
        ..profileId = 1
        ..sourceGuid = 'source'
        ..scheduleGuid = 'schedule'
        ..expectedAmountMinor = 500000
        ..currency = 'usd'
        ..occurrenceMonth = '2026-10'
        ..nominalPayday = DateTime.utc(2026, 10, 20)
        ..adjustedPayday = DateTime.utc(2026, 10, 20)
        ..confirmed = false
        ..state = 'pending'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
      await h.isar.pendingActions.put(PendingAction()
        ..profileId = 1
        ..actionType = 'income.complete'
        ..title = 'Complete income confirmation'
        ..nextAction = 'Resume income confirmation'
        ..feature = 'salary'
        ..recordRef = 'cycle-oct'
        ..expectedMonth = '2026-10'
        ..expectedAt = now
        ..status = 'due'
        ..dedupeKey = 'income.complete|cycle-oct|2026-10'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });

    await (await synthesizer()).synthesize();

    final rows = await h.isar.pendingActions.where().findAll();
    expect(rows.length, 1);
    expect(rows.single.actionType, 'income.complete');
    expect(rows.single.status, 'due');
  });

  test('a non-salary expected cycle creates an income action', () async {
    late IncomeSource source;
    await h.isar.writeTxn(() async {
      source = IncomeSource()
        ..profileId = 1
        ..name = 'Freelance'
        ..type = IncomeSourceType.freelance
        ..amount = 300000
        ..currency = 'usd'
        ..frequency = IncomeFrequency.monthly
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026);
      await h.isar.incomeSources.put(source);
      await h.isar.salaryCycles.put(SalaryCycle()
        ..guid = 'cycle-freelance'
        ..profileId = 1
        ..sourceGuid = source.syncGuid
        ..scheduleGuid = 'sched'
        ..expectedAmountMinor = 300000
        ..currency = 'usd'
        ..occurrenceMonth = '2026-10'
        ..nominalPayday = DateTime.utc(2026, 10, 20)
        ..adjustedPayday = DateTime.utc(2026, 10, 20)
        ..confirmed = false
        ..state = 'pending'
        ..createdAt = DateTime.utc(2026)
        ..updatedAt = DateTime.utc(2026));
    });

    await (await synthesizer()).synthesize();

    final action = (await h.isar.pendingActions.where().findAll())
        .singleWhere((row) => row.actionType == 'income.confirm');
    expect(action.actionType, 'income.confirm');
    expect(action.recordRef, 'cycle-freelance');
    expect(action.feature, 'income');
  });

  test('a planned Vault withdrawal creates a due action', () async {
    await h.isar.writeTxn(() async {
      await h.isar.savingsVaults.put(SavingsVault()
        ..profileId = 1
        ..totalMinor = 5000
        ..currency = 'usd'
        ..lastSweepYearMonth = '2026-10'
        ..updatedAt = DateTime.utc(2026));
      await h.isar.vaultEntrys.put(VaultEntry()
        ..operationKey = 'deposit-plan'
        ..profileId = 1
        ..kind = 'deposit'
        ..yearMonth = '2026-09'
        ..amountMinor = 5000
        ..currency = 'usd'
        ..balanceAfterMinor = 5000
        ..createdAt = DateTime.utc(2026, 9, 1)
        ..breakdownJson = '{"version":1,"vaultDelta":5000,"monthDelta":-5000,'
            '"month":"2026-09","currency":"usd","vaultBefore":0,'
            '"bankBefore":10000,"bankAfter":5000,'
            '"reserveBefore":10000,"reserveAfter":5000,"note":"",'
            '"targetWithdrawalMonth":"2026-10"}');
    });

    await (await synthesizer()).synthesize();

    final action = (await h.isar.pendingActions.where().findAll())
        .singleWhere((row) => row.actionType == 'vault.withdrawalDue');
    expect(action.expectedMonth, '2026-10');
    expect(action.recordRef, 'deposit-plan');
  });

  test('shared sync conflict is scoped to the space', () async {
    await h.isar.writeTxn(() async {
      await h.isar.syncCursors.put(SyncCursor()
        ..peerId = 1
        ..contextLocalId = 7
        ..conflictCount = 2
        ..updatedAt = DateTime.utc(2026));
    });

    await (await synthesizer(profileId: null, spaceId: 7)).synthesize();

    final action = (await h.isar.pendingActions.where().findAll()).single;
    expect(action.actionType, 'sync.conflict');
    expect(action.sharedSpaceId, 7);
    expect(action.profileId, isNull);
  });
}
