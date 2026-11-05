import 'package:isar/isar.dart';

import '../models/currency_code.dart';
import '../models/income_source.dart';
import '../models/pending_action.dart';
import '../models/salary_cycle.dart';
import '../models/salary_schedule.dart';
import '../../features/finance/repositories/audit_repository.dart';
import '../../features/pending_actions/services/pending_action_service.dart';
import '../../features/pending_actions/services/pending_action_types.dart';
import 'income_activation_period.dart';

/// The lifecycle state of one income source and one income period.
enum IncomePeriodState {
  needsActivation,
  pending,
  confirmed,
  skipped,
  cancelled,
}

String incomePeriodStateValue(IncomePeriodState state) => state.name;

IncomePeriodState incomePeriodStateFromStored(String? value) => switch (value) {
      'pending' => IncomePeriodState.pending,
      'confirmed' => IncomePeriodState.confirmed,
      'skipped' => IncomePeriodState.skipped,
      'cancelled' => IncomePeriodState.cancelled,
      'needsActivation' ||
      'unconfirmed' ||
      null =>
        IncomePeriodState.needsActivation,
      _ => IncomePeriodState.needsActivation,
    };

class IncomeActivationException implements Exception {
  const IncomeActivationException(this.code);
  final String code;
  @override
  String toString() => 'IncomeActivationException: $code';
}

/// Owns the one lifecycle record for an income source and income period.
///
/// This service never writes a receipt or a balance. It creates/reads the
/// lifecycle, its schedule and attention-only completion/expected-income
/// actions, and records audit history. The receipt services own every money
/// write.
class IncomeActivationService {
  IncomeActivationService(
    this.db, {
    this.profileId,
    this.audit,
    this.pendingActions,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  final Isar db;
  final int? profileId;
  final AuditRepository? audit;

  /// Attention metadata only. The activation service may create the due-now
  /// completion action, but a receipt service still owns every money write.
  final PendingActionService? pendingActions;
  final DateTime Function() clock;

  Future<IncomePeriodState> stateFor(
      IncomeSource source, String periodKey) async {
    _validatePeriod(periodKey);
    _requireOwner(source);
    final cycle = await _findLifecycle(source, periodKey);
    if (cycle == null) return IncomePeriodState.needsActivation;
    if (!cycle.confirmed && cycle.state == 'unconfirmed') {
      // Normalize lazily on first read so old automatic periods never look
      // like a user-confirmed expectation.
      await normalizeLegacy(source, periodKey: periodKey);
      return IncomePeriodState.needsActivation;
    }
    return _stateOf(cycle);
  }

  Future<SalaryCycle?> lifecycleFor(
      IncomeSource source, String periodKey) async {
    _validatePeriod(periodKey);
    _requireOwner(source);
    return _findLifecycle(source, periodKey);
  }

  Future<SalarySchedule?> scheduleFor(IncomeSource source) async {
    _requireOwner(source);
    return db.salarySchedules
        .filter()
        .sourceGuidEqualTo(source.syncGuid)
        .findFirst();
  }

  /// The calendar date the current period is usually received.
  ///
  /// Recurring income uses the schedule's usual receipt day; one-time income
  /// uses its single start date. No banking-calendar adjustment is applied.
  Future<DateTime> expectedDateFor(
      IncomeSource source, String periodKey) async {
    _validatePeriod(periodKey);
    _requireOwner(source);
    final schedule = await scheduleFor(source);
    return _expectedPayday(source, schedule, periodKey);
  }

  /// Creates or updates the source's usual receipt day.
  Future<SalarySchedule> upsertSchedule(
    IncomeSource source, {
    required int nominalDay,
    required String timezone,
  }) async {
    _requireOwner(source);
    if (nominalDay < 1 || nominalDay > 31) {
      throw ArgumentError.value(nominalDay, 'nominalDay', 'Must be 1-31');
    }
    final zone = timezone.trim();
    if (zone.isEmpty) {
      throw ArgumentError.value(timezone, 'timezone', 'Must not be empty');
    }
    final existing = await scheduleFor(source);
    if (existing != null &&
        existing.nominalDay == nominalDay &&
        existing.timezone == zone) {
      return existing;
    }
    late SalarySchedule saved;
    await db.writeTxn(() async {
      final now = clock().toUtc();
      final before = existing == null
          ? null
          : {'nominalDay': existing.nominalDay, 'timezone': existing.timezone};
      if (existing == null) {
        saved = SalarySchedule()
          ..profileId = profileId
          ..sourceGuid = source.syncGuid
          ..nominalDay = nominalDay
          ..countryCode = ''
          ..timezone = zone
          ..createdAt = now
          ..updatedAt = now;
      } else {
        saved = existing
          ..nominalDay = nominalDay
          ..timezone = zone
          ..updatedAt = now;
      }
      saved.id = await db.salarySchedules.put(saved);
      await _audit(
        action: existing == null
            ? 'income.schedule.created'
            : 'income.schedule.updated',
        objectType: 'SalarySchedule',
        objectGuid: saved.guid,
        objectId: saved.id,
        before: before,
        after: {'nominalDay': saved.nominalDay, 'timezone': saved.timezone},
      );
    });
    return saved;
  }

  /// Creates or refreshes one lifecycle record. It never revives a terminal
  /// period and never creates money.
  Future<SalaryCycle> ensureLifecycle(
    IncomeSource source, {
    required String periodKey,
    IncomePeriodState state = IncomePeriodState.needsActivation,
    int? expectedAmountMinor,
    DateTime? expectedAt,
  }) async {
    _validatePeriod(periodKey);
    _requireOwner(source);
    if (state == IncomePeriodState.confirmed) {
      throw ArgumentError('A confirmation must use the receipt service.');
    }
    final amount = expectedAmountMinor ?? source.amount;
    if (amount <= 0 || CurrencyCode.tryParse(source.currency) == null) {
      throw const IncomeActivationException('invalidSource');
    }
    final schedule = await scheduleFor(source);
    final existing = await _findLifecycle(source, periodKey);
    final payday = expectedAt ?? _defaultPayday(periodKey);
    if (existing != null) {
      final current = _stateOf(existing);
      if (current == IncomePeriodState.confirmed ||
          current == IncomePeriodState.skipped ||
          current == IncomePeriodState.cancelled) {
        return existing;
      }
      if (current == IncomePeriodState.pending &&
          state == IncomePeriodState.needsActivation) {
        return existing;
      }
      final unchanged = existing.expectedAmountMinor == amount &&
          existing.currency == source.currency &&
          existing.state == state.name &&
          existing.nominalPayday.isAtSameMomentAs(payday) &&
          existing.adjustedPayday.isAtSameMomentAs(payday) &&
          existing.scheduleGuid ==
              (schedule?.guid ?? 'manual:${source.syncGuid}');
      if (unchanged) return existing;

      late SalaryCycle saved;
      await db.writeTxn(() async {
        final before = {
          'state': existing.state,
          'expectedAmountMinor': existing.expectedAmountMinor,
          'currency': existing.currency,
        };
        saved = existing
          ..expectedAmountMinor = amount
          ..currency = source.currency
          ..scheduleGuid = schedule?.guid ?? 'manual:${source.syncGuid}'
          ..nominalPayday = payday
          ..adjustedPayday = payday
          ..state = state.name
          ..confirmed = false
          ..updatedAt = clock().toUtc();
        saved.id = await db.salaryCycles.put(saved);
        await _audit(
          action: 'income.period.updated',
          objectType: 'SalaryCycle',
          objectGuid: saved.guid,
          objectId: saved.id,
          before: before,
          after: {
            'state': saved.state,
            'expectedAmountMinor': saved.expectedAmountMinor,
            'currency': saved.currency,
          },
        );
      });
      return saved;
    }

    final cycle = SalaryCycle()
      ..guid = 'salary-cycle:${source.syncGuid}:$periodKey'
      ..profileId = profileId
      ..sourceGuid = source.syncGuid
      ..scheduleGuid = schedule?.guid ?? 'manual:${source.syncGuid}'
      ..expectedAmountMinor = amount
      ..currency = source.currency
      ..occurrenceMonth = periodKey
      ..nominalPayday = payday
      ..adjustedPayday = payday
      ..confirmed = false
      ..state = state.name
      ..createdAt = clock().toUtc()
      ..updatedAt = clock().toUtc();
    await db.writeTxn(() async {
      cycle.id = await db.salaryCycles.put(cycle);
      await _audit(
        action: 'income.period.created',
        objectType: 'SalaryCycle',
        objectGuid: cycle.guid,
        objectId: cycle.id,
        after: {
          'state': cycle.state,
          'expectedAmountMinor': cycle.expectedAmountMinor,
          'currency': cycle.currency,
          'occurrenceMonth': cycle.occurrenceMonth,
        },
      );
    });
    return cycle;
  }

  /// Moves an unfinished lifecycle to a non-confirmed state.
  Future<void> updateLifecycleState(
    SalaryCycle cycle,
    IncomePeriodState state, {
    String? reason,
    String? auditAction,
  }) async {
    if (profileId == null || cycle.profileId != profileId) {
      throw const IncomeActivationException('wrongOwner');
    }
    if (state == IncomePeriodState.confirmed) {
      throw ArgumentError('A confirmation must use the receipt service.');
    }
    if (state == IncomePeriodState.cancelled &&
        (reason == null || reason.trim().isEmpty)) {
      throw ArgumentError('Cancelling expected income requires a reason.');
    }
    final current = _stateOf(cycle);
    if (current == state) return;
    if (current == IncomePeriodState.confirmed ||
        current == IncomePeriodState.skipped ||
        current == IncomePeriodState.cancelled) {
      throw StateError('A terminal income period cannot be reopened here.');
    }
    if (cycle.receiptGroupGuid != null) {
      throw StateError('A linked receipt cannot change lifecycle state here.');
    }
    await db.writeTxn(() async {
      final before = {'state': cycle.state};
      cycle
        ..state = state.name
        ..confirmed = false
        ..updatedAt = clock().toUtc();
      cycle.id = await db.salaryCycles.put(cycle);
      await _audit(
        action: auditAction ?? 'income.period.stateChanged',
        objectType: 'SalaryCycle',
        objectGuid: cycle.guid,
        objectId: cycle.id,
        before: before,
        after: {
          'state': cycle.state,
          'period': cycle.occurrenceMonth,
          if (reason != null && reason.trim().isNotEmpty)
            'reason': reason.trim(),
        },
      );
    });
  }

  /// Prepares the current period for the existing receipt confirmation.
  ///
  /// The lifecycle becomes `pending`, but no receipt, money or Pending Action is
  /// written. The caller opens the salary/income confirmation sheet, and the
  /// receipt service is the only writer of the actual money.
  Future<SalaryCycle> chooseAlreadyReceived(
      IncomeSource source, String periodKey) async {
    _validatePeriod(periodKey);
    _requireOwner(source);
    if (!isPeriodActive(source, periodKey)) {
      throw const IncomeActivationException('inactivePeriod');
    }
    final existing = await _findLifecycle(source, periodKey);
    if (existing != null) {
      final state = _stateOf(existing);
      if (state == IncomePeriodState.confirmed) {
        throw const IncomeActivationException('alreadyConfirmed');
      }
      if (state == IncomePeriodState.skipped ||
          state == IncomePeriodState.cancelled) {
        throw const IncomeActivationException('periodClosed');
      }
    }
    final schedule = await scheduleFor(source);
    final wasPending =
        existing != null && _stateOf(existing) == IncomePeriodState.pending;
    final cycle = await ensureLifecycle(
      source,
      periodKey: periodKey,
      state: IncomePeriodState.pending,
      expectedAt: _expectedPayday(source, schedule, periodKey),
    );
    if (!wasPending) {
      await db.writeTxn(() async {
        await _audit(
          action: 'income.confirmation.started',
          objectType: 'SalaryCycle',
          objectGuid: cycle.guid,
          objectId: cycle.id,
          after: {
            'state': cycle.state,
            'period': periodKey,
            'expectedAmountMinor': cycle.expectedAmountMinor,
            'currency': cycle.currency,
          },
        );
      });
    }
    return cycle;
  }

  /// Records that the current period is expected later.
  ///
  /// The lifecycle becomes `pending` and one `salary.confirm`/`income.confirm`
  /// action is created or reused. No receipt, money or Free-to-Use change is
  /// written.
  Future<SalaryCycle> chooseExpectLater(
      IncomeSource source, String periodKey) async {
    _validatePeriod(periodKey);
    _requireOwner(source);
    if (!isPeriodActive(source, periodKey)) {
      throw const IncomeActivationException('inactivePeriod');
    }
    final existing = await _findLifecycle(source, periodKey);
    if (existing != null) {
      final state = _stateOf(existing);
      if (state == IncomePeriodState.confirmed) {
        throw const IncomeActivationException('alreadyConfirmed');
      }
      if (state == IncomePeriodState.skipped ||
          state == IncomePeriodState.cancelled) {
        throw const IncomeActivationException('periodClosed');
      }
    }
    final service = pendingActions;
    if (service == null) {
      throw const IncomeActivationException('actionServiceUnavailable');
    }
    final schedule = await scheduleFor(source);
    final wasPending =
        existing != null && _stateOf(existing) == IncomePeriodState.pending;
    final cycle = await ensureLifecycle(
      source,
      periodKey: periodKey,
      state: IncomePeriodState.pending,
      expectedAt: _expectedPayday(source, schedule, periodKey),
    );
    if (!wasPending) {
      await db.writeTxn(() async {
        await _audit(
          action: 'income.period.expectationCreated',
          objectType: 'SalaryCycle',
          objectGuid: cycle.guid,
          objectId: cycle.id,
          after: {
            'state': cycle.state,
            'period': periodKey,
            'expectedAmountMinor': cycle.expectedAmountMinor,
            'currency': cycle.currency,
            'expectedAt': cycle.adjustedPayday.toIso8601String(),
          },
        );
      });
    }
    final salary = source.type == IncomeSourceType.salary;
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
      cycleOrMonth: periodKey,
      expectedAmountMinor: cycle.expectedAmountMinor,
      currency: cycle.currency,
      expectedAt: cycle.adjustedPayday,
      expectedMonth: periodKey,
      priority: 2,
      deepLink: '/income_sources',
    ));
    // A past expected date becomes due immediately; a future one stays pending.
    await service.refreshStatuses(clock());
    return cycle;
  }

  /// Skips the current period and starts the next applicable period.
  ///
  /// The current lifecycle becomes `skipped`, any active current-period action
  /// is cancelled with reason `startNextPeriod`, and the next applicable period
  /// is prepared as `pending`. No receipt or money is written.
  Future<SalaryCycle> chooseStartNext(
      IncomeSource source, String periodKey) async {
    _validatePeriod(periodKey);
    _requireOwner(source);
    if (!isPeriodActive(source, periodKey)) {
      throw const IncomeActivationException('inactivePeriod');
    }
    final service = pendingActions;
    if (service == null) {
      throw const IncomeActivationException('actionServiceUnavailable');
    }
    final existing = await _findLifecycle(source, periodKey);
    if (existing != null) {
      final state = _stateOf(existing);
      if (state == IncomePeriodState.confirmed) {
        throw const IncomeActivationException('alreadyConfirmed');
      }
      if (state == IncomePeriodState.cancelled) {
        throw const IncomeActivationException('periodClosed');
      }
      if (state == IncomePeriodState.skipped) {
        await _cancelCurrentActions(service, existing, 'startNextPeriod');
        await _ensureNextPeriod(source, periodKey);
        return existing;
      }
    }
    final schedule = await scheduleFor(source);
    final cycle = await ensureLifecycle(
      source,
      periodKey: periodKey,
      expectedAt: _expectedPayday(source, schedule, periodKey),
    );
    await updateLifecycleState(
      cycle,
      IncomePeriodState.skipped,
      auditAction: 'income.period.skipped',
    );
    await _cancelCurrentActions(service, cycle, 'startNextPeriod');
    await _ensureNextPeriod(source, periodKey);
    return cycle;
  }

  /// Cancels an expected income period with a required reason.
  ///
  /// The lifecycle becomes `cancelled`, its active action is cancelled with the
  /// same reason, and no receipt or money is written.
  Future<void> cancelExpected(
      IncomeSource source, String periodKey, String reason) async {
    _validatePeriod(periodKey);
    _requireOwner(source);
    final cleaned = reason.trim();
    if (cleaned.isEmpty) {
      throw ArgumentError.value(
          reason, 'reason', 'Cancelling expected income requires a reason.');
    }
    final service = pendingActions;
    if (service == null) {
      throw const IncomeActivationException('actionServiceUnavailable');
    }
    final cycle = await _findLifecycle(source, periodKey);
    if (cycle == null) {
      throw const IncomeActivationException('missingLifecycle');
    }
    final state = _stateOf(cycle);
    if (state == IncomePeriodState.confirmed) {
      throw const IncomeActivationException('alreadyConfirmed');
    }
    if (state == IncomePeriodState.skipped) {
      throw const IncomeActivationException('periodClosed');
    }
    if (state == IncomePeriodState.cancelled) {
      await _cancelCurrentActions(service, cycle, cleaned);
      return;
    }
    await updateLifecycleState(
      cycle,
      IncomePeriodState.cancelled,
      reason: cleaned,
      auditAction: 'income.period.cancelled',
    );
    await _cancelCurrentActions(service, cycle, cleaned);
  }

  /// Creates one due-now setup task for every active source with no current
  /// period decision.
  ///
  /// It is used when onboarding finishes with unconfigured sources. It never
  /// creates a lifecycle, receipt or money. Decided, future-start and ended
  /// sources are left alone.
  Future<void> ensureActivationActions(int ownerId, String periodKey) async {
    _validatePeriod(periodKey);
    if (profileId == null || ownerId != profileId) {
      throw const IncomeActivationException('wrongOwner');
    }
    final service = pendingActions;
    if (service == null) {
      throw const IncomeActivationException('actionServiceUnavailable');
    }
    final sources =
        await db.incomeSources.filter().profileIdEqualTo(ownerId).findAll();
    final sourceGuids = {for (final source in sources) source.syncGuid};
    final monthDate = DateTime.parse('$periodKey-01');
    final expected = <String>{};
    for (final source in sources) {
      final period = periodKeyFor(source, monthDate);
      if (!isPeriodActive(source, period)) continue;
      // Replace any old automatic confirmation task before deciding the state.
      await normalizeLegacy(source, periodKey: period);
      final cycle = await _findLifecycle(source, period);
      final state =
          cycle == null ? IncomePeriodState.needsActivation : _stateOf(cycle);
      if (state != IncomePeriodState.needsActivation) continue;
      if (cycle != null) {
        // Normalization normally cancels these; repeat the idempotent cleanup
        // so an interrupted migration cannot leave both tasks active.
        await service.cancelActiveForRecord(
            cycle.guid, period, 'legacyAutoExpected',
            actionTypes: {
              PendingActionTypes.salaryConfirm,
              PendingActionTypes.incomeConfirm,
            });
      }
      expected.add(source.syncGuid);
      await service.upsert(PendingActionDraft(
        profileId: ownerId,
        actionType: PendingActionTypes.incomeActivate,
        title: 'Set up current period',
        nextAction: 'Choose what happened to this income',
        feature: 'income',
        recordRef: source.syncGuid,
        cycleOrMonth: period,
        expectedAmountMinor: source.amount,
        currency: source.currency,
        expectedAt: clock(),
        expectedMonth: period,
        priority: 2,
        deepLink: '/income_sources',
      ));
    }
    // A source that became decided, ended, moved to a future period or was
    // deleted must not keep a stale setup task for this period.
    final stale = await db.pendingActions
        .filter()
        .profileIdEqualTo(ownerId)
        .actionTypeEqualTo(PendingActionTypes.incomeActivate)
        .expectedMonthEqualTo(periodKey)
        .findAll();
    for (final row in stale) {
      if (!row.isActive || expected.contains(row.recordRef)) continue;
      await service.cancel(
          row.guid,
          sourceGuids.contains(row.recordRef)
              ? 'periodClosed'
              : 'sourceMissing');
    }
    await service.refreshStatuses(clock());
  }

  /// Creates or reuses the due-now action for an unfinished confirmation.
  ///
  /// The lifecycle stays `pending` and no money is written. Confirmed, skipped
  /// and cancelled periods are left untouched.
  Future<void> markConfirmationUnfinished(
      IncomeSource source, String periodKey) async {
    _validatePeriod(periodKey);
    _requireOwner(source);
    final cycle = await _findLifecycle(source, periodKey);
    if (cycle == null) {
      throw const IncomeActivationException('missingLifecycle');
    }
    if (_stateOf(cycle) != IncomePeriodState.pending) return;
    final service = pendingActions;
    if (service == null) {
      throw const IncomeActivationException('actionServiceUnavailable');
    }
    final salary = source.type == IncomeSourceType.salary;
    await service.upsert(PendingActionDraft(
      profileId: profileId,
      actionType: PendingActionTypes.incomeComplete,
      title: 'Complete income confirmation',
      nextAction: 'Resume income confirmation',
      feature: salary ? 'salary' : 'income',
      recordRef: cycle.guid,
      cycleOrMonth: periodKey,
      expectedAmountMinor: cycle.expectedAmountMinor,
      currency: cycle.currency,
      expectedAt: clock(),
      expectedMonth: periodKey,
      priority: 2,
      deepLink: '/income_sources',
    ));
    // The action is due immediately, even before the next synthesis run.
    await service.refreshStatuses(clock());
  }

  /// Persists the legacy `unconfirmed` state as `needsActivation` and cancels
  /// its old automatic confirmation action with `legacyAutoExpected`.
  ///
  /// Confirmed rows are preserved. The setup action itself is created by the
  /// caller after normalization.
  Future<int> normalizeLegacy(IncomeSource source, {String? periodKey}) async {
    _requireOwner(source);
    if (periodKey != null) _validatePeriod(periodKey);
    final rows = await db.salaryCycles
        .filter()
        .sourceGuidEqualTo(source.syncGuid)
        .findAll();
    final cancellations = <SalaryCycle>[];
    var changed = 0;
    await db.writeTxn(() async {
      for (final cycle in rows) {
        if (periodKey != null && cycle.occurrenceMonth != periodKey) continue;
        if (cycle.confirmed) {
          if (cycle.state != IncomePeriodState.confirmed.name) {
            final before = {'state': cycle.state, 'confirmed': cycle.confirmed};
            cycle
              ..state = IncomePeriodState.confirmed.name
              ..confirmed = true
              ..updatedAt = clock().toUtc();
            await db.salaryCycles.put(cycle);
            await _audit(
              action: 'income.period.legacyNormalized',
              objectType: 'SalaryCycle',
              objectGuid: cycle.guid,
              objectId: cycle.id,
              before: before,
              after: {'state': cycle.state, 'confirmed': cycle.confirmed},
            );
            changed++;
          }
          continue;
        }
        if (cycle.state == 'unconfirmed') {
          final before = {'state': cycle.state};
          cycle
            ..state = IncomePeriodState.needsActivation.name
            ..updatedAt = clock().toUtc();
          await db.salaryCycles.put(cycle);
          await _audit(
            action: 'income.period.legacyNormalized',
            objectType: 'SalaryCycle',
            objectGuid: cycle.guid,
            objectId: cycle.id,
            before: before,
            after: {'state': cycle.state},
          );
          // The old automatic expectation is not a user decision. Replace its
          // confirmation task with an explicit setup task outside this txn.
          cancellations.add(cycle);
          changed++;
        }
      }
    });
    final service = pendingActions;
    if (service != null) {
      for (final cycle in cancellations) {
        await service.cancelActiveForRecord(
            cycle.guid, cycle.occurrenceMonth, 'legacyAutoExpected',
            actionTypes: {
              PendingActionTypes.salaryConfirm,
              PendingActionTypes.incomeConfirm,
            });
      }
    }
    return changed;
  }

  /// Cancels the source's active attention for its current period.
  ///
  /// Deleting or ending a source keeps history and money untouched; only the
  /// no-longer-actionable task is closed with [reason].
  Future<void> cancelSourceActions(
    IncomeSource source, {
    String? periodKey,
    String reason = 'sourceEnded',
  }) async {
    _requireOwner(source);
    final service = pendingActions;
    if (service == null) return;
    final period = periodKey ?? periodKeyFor(source, clock());
    _validatePeriod(period);
    await service.cancelActiveForRecord(source.syncGuid, period, reason);
    final cycles = await db.salaryCycles
        .filter()
        .sourceGuidEqualTo(source.syncGuid)
        .findAll();
    for (final cycle in cycles) {
      if (cycle.occurrenceMonth != period) continue;
      await service.cancelActiveForRecord(
          cycle.guid, cycle.occurrenceMonth, reason);
    }
    await service.refreshStatuses(clock());
  }

  Future<void> _cancelCurrentActions(
      PendingActionService service, SalaryCycle cycle, String reason) async {
    await service.cancelActiveForRecord(
        cycle.guid, cycle.occurrenceMonth, reason);
  }

  /// Prepares the next applicable period only when the source is still active.
  Future<void> _ensureNextPeriod(IncomeSource source, String periodKey) async {
    final next = nextPeriodKey(source, periodKey);
    if (next == null || !isPeriodActive(source, next)) return;
    final schedule = await scheduleFor(source);
    await ensureLifecycle(
      source,
      periodKey: next,
      state: IncomePeriodState.pending,
      expectedAt: _expectedPayday(source, schedule, next),
    );
  }

  Future<SalaryCycle?> _findLifecycle(
      IncomeSource source, String periodKey) async {
    final rows = await db.salaryCycles
        .filter()
        .sourceGuidEqualTo(source.syncGuid)
        .occurrenceMonthEqualTo(periodKey)
        .findAll();
    return rows.firstOrNull;
  }

  IncomePeriodState _stateOf(SalaryCycle cycle) {
    if (cycle.confirmed) return IncomePeriodState.confirmed;
    return incomePeriodStateFromStored(cycle.state);
  }

  void _requireOwner(IncomeSource source) {
    if (profileId == null ||
        source.profileId != profileId ||
        source.sharedSpaceId != null) {
      throw const IncomeActivationException('wrongOwner');
    }
  }

  void _validatePeriod(String periodKey) {
    if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(periodKey)) {
      throw FormatException('Invalid income period: $periodKey');
    }
  }

  /// The nominal receipt date for [periodKey].
  ///
  /// Recurring income uses the schedule's usual receipt day. One-time income
  /// uses its single start date. A day beyond the month length is clamped, so a
  /// 31st schedule still produces a valid February date.
  DateTime _expectedPayday(
      IncomeSource source, SalarySchedule? schedule, String periodKey) {
    final parts = periodKey.split('-').map(int.parse).toList();
    final lastDay = DateTime.utc(parts[0], parts[1] + 1, 0).day;
    final preferred = source.frequency == IncomeFrequency.oneTime
        ? (source.startDate?.day ?? schedule?.nominalDay ?? 25)
        : (schedule?.nominalDay ?? source.startDate?.day ?? 25);
    final day = preferred < 1 ? 1 : (preferred > lastDay ? lastDay : preferred);
    // A receipt day is a calendar date, not an instant. Keep it local so the
    // Pending Action and reminders show the same day in every timezone.
    return DateTime(parts[0], parts[1], day);
  }

  DateTime _defaultPayday(String periodKey) {
    final parts = periodKey.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], 25);
  }

  Future<void> _audit({
    required String action,
    required String objectType,
    required String objectGuid,
    int? objectId,
    Object? before,
    Object? after,
  }) async {
    final repo = audit;
    final owner = profileId;
    if (repo == null || owner == null) return;
    await repo.append(
      profileId: owner,
      action: action,
      objectType: objectType,
      objectGuid: objectGuid,
      objectId: objectId,
      before: before,
      after: after,
    );
  }
}
