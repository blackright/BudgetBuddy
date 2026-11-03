import 'package:isar/isar.dart';

import '../../../core/models/app_settings.dart';
import '../../../core/models/budget_profile.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/desired_salary_reminder.dart';
import '../../../core/models/income_source.dart';
import '../../../core/models/month_end_run.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/pending_action.dart';
import '../../../core/models/salary_cycle.dart';
import '../../../core/models/sync_cursor.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/fx_booking_service.dart';
import '../../../core/services/income_activation_period.dart';
import '../../../core/services/income_activation_service.dart';
import '../../budget_setup/domain/onboarding_state.dart';
import '../../medical/presentation/medical_bill_view_state.dart';
import '../../medical/providers/medical_providers.dart';
import '../../vault/models/savings_vault.dart';
import '../../vault/models/vault_entry.dart';
import '../../vault/vault_suggestion_service.dart';
import 'pending_action_service.dart';
import 'pending_action_types.dart';

/// Reads every existing attention source and upserts the corresponding
/// [PendingActionDraft] rows. It never changes money, allocations or Vault rows.
class PendingActionSynthesizer {
  PendingActionSynthesizer(
    this.db, {
    this.profileId,
    this.sharedSpaceId,
    required this.service,
    DateTime Function()? clock,
  })  : assert((profileId == null) != (sharedSpaceId == null)),
        clock = clock ?? DateTime.now;

  final Isar db;
  final int? profileId;
  final int? sharedSpaceId;
  final PendingActionService service;
  final DateTime Function() clock;

  Future<void> synthesize({MedicalInbox? medicalInbox}) async {
    final now = clock();
    if (profileId != null) {
      await _salary(now);
      await _reminders(now);
      await _allocations(now);
      await _vault(now);
      await _medical(medicalInbox, now);
      await _monthEnd(now);
      await _onboarding();
    }
    if (sharedSpaceId != null) {
      await _sync();
    }
  }

  Future<void> _salary(DateTime now) async {
    final rows =
        await db.salaryCycles.filter().profileIdEqualTo(profileId).findAll();
    final sources =
        await db.incomeSources.filter().profileIdEqualTo(profileId).findAll();
    final sourceByGuid = {
      for (final source in sources) source.syncGuid: source
    };
    final cyclesByKey = {
      for (final cycle in rows)
        '${cycle.sourceGuid}|${cycle.occurrenceMonth}': cycle
    };
    final currentMonth = _month(now);
    final currentDate = DateTime(now.year, now.month);
    final activation = IncomeActivationService(
      db,
      profileId: profileId,
      pendingActions: service,
      clock: clock,
    );
    final active = await _activeActionKeys();
    final completions =
        active[PendingActionTypes.incomeComplete] ?? const <String>{};
    final expectedActivations = <String>{};
    final expectedSalary = <String>{};
    final expectedIncome = <String>{};
    final handled = <String>{};

    // The current period of every active source needs exactly one decision.
    // A missing lifecycle is not "expected later": it needs an explicit setup
    // task, and an old automatic period is normalized instead of trusted.
    for (final source in sources) {
      final period = periodKeyFor(source, currentDate);
      final cycle = cyclesByKey['${source.syncGuid}|$period'];
      if (cycle == null) {
        if (!isPeriodActive(source, period)) continue;
        expectedActivations.add(source.syncGuid);
        await service.upsert(_activationDraft(source, period, now));
        continue;
      }
      final state = cycle.confirmed
          ? IncomePeriodState.confirmed
          : cycle.state == 'unconfirmed'
              ? IncomePeriodState.needsActivation
              : incomePeriodStateFromStored(cycle.state);
      // Pending periods are handled below so they keep their confirmation task.
      if (state == IncomePeriodState.pending) continue;
      handled.add('${cycle.guid}|${cycle.occurrenceMonth}');
      if (state == IncomePeriodState.confirmed) {
        await service.completeByRecord(PendingActionTypes.incomeComplete,
            cycle.guid, cycle.occurrenceMonth);
        await service.cancelActiveForRecord(
            cycle.guid, cycle.occurrenceMonth, 'periodClosed');
        continue;
      }
      if (state == IncomePeriodState.skipped ||
          state == IncomePeriodState.cancelled) {
        await service.cancelActiveForRecord(
            cycle.guid, cycle.occurrenceMonth, 'periodClosed');
        continue;
      }
      if (state == IncomePeriodState.needsActivation) {
        // Replace old automatic confirmation tasks with one setup task.
        await activation.normalizeLegacy(source,
            periodKey: cycle.occurrenceMonth);
        await service.cancelActiveForRecord(
            cycle.guid, cycle.occurrenceMonth, 'legacyAutoExpected',
            actionTypes: {
              PendingActionTypes.salaryConfirm,
              PendingActionTypes.incomeConfirm,
            });
        expectedActivations.add(source.syncGuid);
        await service
            .upsert(_activationDraft(source, cycle.occurrenceMonth, now));
      }
    }

    // Past pending periods still need their own confirmation task. Older
    // unconfigured periods never get a fabricated expectation.
    for (final cycle in rows) {
      if (handled.contains('${cycle.guid}|${cycle.occurrenceMonth}')) continue;
      final source = sourceByGuid[cycle.sourceGuid];
      if (source == null) continue;
      final salary = source.type == IncomeSourceType.salary;
      final key = '${cycle.guid}|${cycle.occurrenceMonth}';
      final confirmed =
          cycle.confirmed || cycle.state == IncomePeriodState.confirmed.name;
      if (confirmed) {
        if (completions.contains(key)) {
          await service.completeByRecord(PendingActionTypes.incomeComplete,
              cycle.guid, cycle.occurrenceMonth);
        }
        await service.cancelActiveForRecord(
            cycle.guid, cycle.occurrenceMonth, 'periodClosed');
        continue;
      }
      final state = incomePeriodStateFromStored(cycle.state);
      if (state == IncomePeriodState.skipped ||
          state == IncomePeriodState.cancelled) {
        await service.cancelActiveForRecord(
            cycle.guid, cycle.occurrenceMonth, 'periodClosed');
        continue;
      }
      if (cycle.occurrenceMonth.compareTo(currentMonth) > 0) continue;
      if (state == IncomePeriodState.needsActivation) {
        await activation.normalizeLegacy(source,
            periodKey: cycle.occurrenceMonth);
        await service.cancelActiveForRecord(
            cycle.guid, cycle.occurrenceMonth, 'legacyAutoExpected',
            actionTypes: {
              PendingActionTypes.salaryConfirm,
              PendingActionTypes.incomeConfirm,
            });
        continue;
      }
      if (state != IncomePeriodState.pending) continue;
      // An unfinished already-received confirmation already owns this period.
      if (completions.contains(key)) continue;
      (salary ? expectedSalary : expectedIncome).add(cycle.guid);
      await service.upsert(PendingActionDraft(
        profileId: profileId,
        actionType: salary
            ? PendingActionTypes.salaryConfirm
            : PendingActionTypes.incomeConfirm,
        title: salary
            ? 'Confirm salary received'
            : 'Confirm ${source.name} received',
        nextAction:
            salary ? 'Confirm salary received' : 'Confirm income received',
        feature: salary ? 'salary' : 'income',
        recordRef: cycle.guid,
        cycleOrMonth: cycle.occurrenceMonth,
        expectedAmountMinor: cycle.expectedAmountMinor,
        currency: cycle.currency,
        expectedAt: cycle.adjustedPayday,
        expectedMonth: cycle.occurrenceMonth,
        priority: 2,
        deepLink: '/income_sources',
      ));
    }
    await _cancelMissing(
        PendingActionTypes.incomeActivate, expectedActivations, 'periodClosed');
    await _cancelMissing(
        PendingActionTypes.salaryConfirm, expectedSalary, 'sourceMissing');
    await _cancelMissing(
        PendingActionTypes.incomeConfirm, expectedIncome, 'sourceMissing');
  }

  PendingActionDraft _activationDraft(
          IncomeSource source, String period, DateTime now) =>
      PendingActionDraft(
        profileId: profileId,
        actionType: PendingActionTypes.incomeActivate,
        title: 'Set up current period',
        nextAction: 'Choose what happened to this income',
        feature: 'income',
        recordRef: source.syncGuid,
        cycleOrMonth: period,
        expectedAmountMinor: source.amount,
        currency: source.currency,
        expectedAt: now,
        expectedMonth: period,
        priority: 2,
        deepLink: '/income_sources',
      );

  /// Active attention rows keyed by action type, using
  /// `recordRef|expectedMonth` so one period can be matched across actions.
  Future<Map<String, Set<String>>> _activeActionKeys() async {
    final rows = await db.pendingActions
        .filter()
        .profileIdEqualTo(profileId!)
        .sharedSpaceIdIsNull()
        .findAll();
    final result = <String, Set<String>>{};
    for (final row in rows) {
      if (!row.isActive || row.expectedMonth == null) continue;
      result
          .putIfAbsent(row.actionType, () => <String>{})
          .add('${row.recordRef}|${row.expectedMonth}');
    }
    return result;
  }

  Future<void> _reminders(DateTime now) async {
    final List<DesiredSalaryReminder> rows;
    try {
      rows = await db.desiredSalaryReminders
          .filter()
          .profileIdEqualTo(profileId)
          .findAll();
    } on IsarError {
      return;
    }
    final expected = <String>{};
    for (final reminder in rows) {
      if (reminder.status != 'overdue' && reminder.status != 'failed') {
        continue;
      }
      final cycle = await db.salaryCycles
          .filter()
          .guidEqualTo(reminder.cycleGuid)
          .findFirst();
      if (cycle == null || cycle.confirmed) continue;
      expected.add(reminder.cycleGuid);
      await service.upsert(PendingActionDraft(
        profileId: profileId,
        actionType: 'salary.reminder',
        title: 'Salary reminder needs review',
        nextAction: 'Review reminder',
        feature: 'salary',
        recordRef: reminder.guid,
        cycleOrMonth: reminder.cycleGuid,
        expectedAmountMinor: cycle.expectedAmountMinor,
        currency: cycle.currency,
        expectedAt: reminder.scheduledAt,
        expectedMonth: cycle.occurrenceMonth,
        priority: 1,
        deepLink: '/income_sources',
      ));
    }
    await _cancelMissing('salary.reminder', expected, 'sourceMissing');
  }

  Future<void> _allocations(DateTime now) async {
    final month = _month(now);
    final rows = await db.budgetProfiles
        .filter()
        .profileIdEqualTo(profileId)
        .sharedSpaceIdIsNull()
        .yearMonthEqualTo(month)
        .findAll();
    final owner = await db.userProfiles.get(profileId!);
    if (owner == null) return;
    final expected = <String>{};
    for (final profile in rows) {
      final overspend = profile.spent - profile.allocation;
      if (overspend <= 0) continue;
      expected.add(profile.syncGuid);
      await service.upsert(PendingActionDraft(
        profileId: profileId,
        actionType: 'allocation.overspent',
        title: '${profile.name} is overspent',
        nextAction: 'Resolve allocation',
        feature: 'allocations',
        recordRef: profile.syncGuid,
        cycleOrMonth: month,
        expectedAmountMinor: overspend,
        currency: owner.primaryCurrency.code.code,
        expectedMonth: month,
        priority: 2,
        deepLink: '/allocations',
      ));
    }
    await _cancelMissing('allocation.overspent', expected, 'sourceMissing');
  }

  Future<void> _vault(DateTime now) async {
    final owner = await db.userProfiles.get(profileId!);
    if (owner == null) return;
    final registry = await readFxRates(db);
    // The suggestion service owns finished-month discovery and idempotency.
    await VaultSuggestionService(
      db,
      profileId: profileId!,
      registry: registry,
      actions: service,
      clock: clock,
    ).check();

    final vault = await db.savingsVaults
        .filter()
        .profileIdEqualTo(profileId!)
        .findFirst();
    if (vault == null) return;
    final history =
        await db.vaultEntrys.filter().profileIdEqualTo(profileId!).findAll();
    final actions = await service.readAll();

    final expectedWithdrawals = <String>{};
    for (final planned
        in plannedWithdrawalsFrom(history: history, actions: actions)) {
      if (!planned.isDue(_month(now))) continue;
      expectedWithdrawals.add(planned.deposit.operationKey);
      await service.upsert(PendingActionDraft(
        profileId: profileId,
        actionType: vaultWithdrawalDueType,
        title: 'Planned withdrawal is due',
        nextAction: 'Withdraw from Vault',
        feature: 'vault',
        recordRef: planned.deposit.operationKey,
        cycleOrMonth: planned.targetMonth,
        expectedAmountMinor: planned.deposit.amountMinor,
        currency: planned.deposit.currency,
        expectedMonth: planned.targetMonth,
        priority: 2,
        deepLink: '/vault',
      ));
    }
    await _cancelMissing(
        vaultWithdrawalDueType, expectedWithdrawals, 'sourceMissing');

    final problem = vaultEntriesProblem(vault, history);
    final expectedReview = problem == null ? <String>{} : {'$profileId'};
    if (problem != null) {
      await service.upsert(PendingActionDraft(
        profileId: profileId,
        actionType: 'vault.review',
        title: 'Savings history needs review',
        nextAction: 'Review saved history',
        feature: 'vault',
        recordRef: '$profileId',
        cycleOrMonth: _month(now),
        priority: 2,
        deepLink: '/vault',
      ));
    }
    await _cancelMissing('vault.review', expectedReview, 'sourceMissing');
  }

  Future<void> _medical(MedicalInbox? inbox, DateTime now) async {
    if (inbox == null) return;
    final expected = <String>{};
    for (final item in inbox.items) {
      if (item.state.group != MedicalInboxGroup.needsYou) continue;
      final bill = item.bill;
      expected.add(bill.syncGuid);
      await service.upsert(PendingActionDraft(
        profileId: profileId,
        actionType: 'medical.review',
        title: item.state.headline,
        nextAction: item.state.actionLabel,
        feature: 'medical',
        recordRef: bill.syncGuid,
        cycleOrMonth: bill.yearMonth,
        expectedAmountMinor: item.state.remainingRefund?.minorUnits,
        currency:
            item.state.remainingRefund == null ? null : inbox.currency.code,
        expectedMonth: bill.yearMonth,
        priority: 2,
        deepLink: '/medical_detail?bill=${bill.id}',
      ));
    }
    // A bill that still exists but no longer needs you is completed, not
    // cancelled; a deleted bill is cancelled.
    final active = await db.pendingActions
        .filter()
        .profileIdEqualTo(profileId!)
        .sharedSpaceIdIsNull()
        .actionTypeEqualTo('medical.review')
        .findAll();
    for (final row in active.where((row) => row.isActive)) {
      if (expected.contains(row.recordRef)) continue;
      final bill = await db.medicalBills
          .filter()
          .syncGuidEqualTo(row.recordRef)
          .findFirst();
      if (bill == null) {
        await service.cancel(row.guid, 'sourceMissing');
      } else {
        await service.completeByRecord(
            'medical.review', row.recordRef, bill.yearMonth);
      }
    }
  }

  Future<void> _monthEnd(DateTime now) async {
    final previous = _previousMonth(_month(now));
    final previousBudget = await db.monthlyBudgets
        .filter()
        .profileIdEqualTo(profileId)
        .sharedSpaceIdIsNull()
        .yearMonthEqualTo(previous)
        .findFirst();
    final runs = await db.monthEndRuns
        .filter()
        .profileIdEqualTo(profileId)
        .sharedSpaceIdIsNull()
        .findAll();
    final expectedClose = <String>{};
    if (previousBudget != null &&
        !runs.any((r) => r.applied && r.yearMonth == previous)) {
      expectedClose.add(previous);
      await service.upsert(PendingActionDraft(
        profileId: profileId,
        actionType: 'monthend.close',
        title: 'Finish $previous month-end',
        nextAction: 'Review month-end',
        feature: 'month-end',
        recordRef: previous,
        cycleOrMonth: previous,
        expectedMonth: previous,
        priority: 1,
        deepLink: '/month_end',
      ));
    }
    if (runs.any((r) => r.applied && r.yearMonth == previous)) {
      await service.completeByRecord('monthend.close', previous, previous);
    }
    await _cancelMissing('monthend.close', expectedClose, 'sourceMissing');

    final expectedConflict = <String>{};
    for (final run in runs.where((r) => r.hasConflict)) {
      expectedConflict.add(run.syncGuid);
      await service.upsert(PendingActionDraft(
        profileId: profileId,
        actionType: 'monthend.conflict',
        title: 'Month-end conflict needs review',
        nextAction: 'Resolve conflict',
        feature: 'month-end',
        recordRef: run.syncGuid,
        cycleOrMonth: run.yearMonth,
        expectedMonth: run.yearMonth,
        priority: 2,
        deepLink: '/month_end',
      ));
    }
    await _cancelMissing(
        'monthend.conflict', expectedConflict, 'sourceMissing');
  }

  Future<void> _onboarding() async {
    final settings = await db.appSettings.get(1);
    final raw = settings?.onboardingStateJson;
    if (raw == null) return;
    try {
      final state = OnboardingState.decode(raw);
      if (state.stage == OnboardingStage.completed) {
        await service.completeByRecord(
            'onboarding.finish', '$profileId', 'once');
        return;
      }
    } catch (_) {
      // Fall through to the review action; corrupt setup still needs attention.
    }
    await service.upsert(PendingActionDraft(
      profileId: profileId,
      actionType: 'onboarding.finish',
      title: 'Finish setting up your profile',
      nextAction: 'Finish setup',
      feature: 'onboarding',
      recordRef: '$profileId',
      cycleOrMonth: 'once',
      priority: 1,
      deepLink: '/setup',
    ));
  }

  Future<void> _sync() async {
    final cursors = await db.syncCursors
        .filter()
        .contextLocalIdEqualTo(sharedSpaceId!)
        .findAll();
    final conflicts =
        cursors.fold<int>(0, (sum, row) => sum + row.conflictCount);
    final expected = conflicts > 0 ? {'$sharedSpaceId'} : <String>{};
    if (conflicts > 0) {
      await service.upsert(PendingActionDraft(
        sharedSpaceId: sharedSpaceId,
        actionType: 'sync.conflict',
        title: 'Shared changes need review',
        nextAction: 'Review sync',
        feature: 'sync',
        recordRef: '$sharedSpaceId',
        cycleOrMonth: 'once',
        expectedAmountMinor: null,
        priority: 2,
        deepLink: '/spaces',
      ));
    }
    if (conflicts == 0) {
      await service.completeByRecord('sync.conflict', '$sharedSpaceId', 'once');
    }
    await _cancelMissing('sync.conflict', expected, 'sourceMissing');
  }

  Future<void> _cancelMissing(
      String actionType, Set<String> expected, String reason) async {
    final query = db.pendingActions.filter().actionTypeEqualTo(actionType);
    final rows = profileId != null
        ? await query
            .profileIdEqualTo(profileId!)
            .sharedSpaceIdIsNull()
            .findAll()
        : await query
            .sharedSpaceIdEqualTo(sharedSpaceId!)
            .profileIdIsNull()
            .findAll();
    for (final row in rows) {
      if (!row.isActive) continue;
      if (expected.contains(row.recordRef)) continue;
      await service.cancel(row.guid, reason);
    }
  }

  String _month(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}';

  String _previousMonth(String month) {
    final parts = month.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]) - 1);
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}';
  }
}
