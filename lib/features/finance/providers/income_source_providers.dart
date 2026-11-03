import '../../../core/models/fx_revision.dart' show checkedFxMinor;
import 'dart:async';
import '../../../core/services/income_receipt_ledger.dart';
import '../../../core/models/money_receipt.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../identity/providers/device_auth_session.dart';
import '../../security/providers/lock_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/models/income_source.dart';
import '../../../core/models/salary_cycle.dart';
import '../../../core/models/income_receipt_group.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../sync/providers/sync_recorder_provider.dart';
import '../../pending_actions/providers/pending_actions_providers.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/services/salary_receipt_service.dart';
import '../../../core/services/income_activation_period.dart';
import '../../../core/services/income_activation_service.dart';
import '../../../core/services/income_receipt_service.dart';
import '../../../core/services/medical_withholding_service.dart';
import '../repositories/audit_repository.dart';
import '../repositories/income_source_repository.dart';

final incomeSourcesProvider = StreamProvider<List<IncomeSource>>((ref) {
  final context = ref.watch(budgetContextProvider);
  final repo = ref.watch(incomeSourceRepositoryProvider);
  if (context.isShared) {
    return repo.watchAll(sharedSpaceId: context.spaceId);
  }
  return repo.watchAll(profileId: context.profileId);
});

/// Saved sources for a profile, used by the onboarding activation step.
final onboardingActivationSourcesProvider = FutureProvider.autoDispose
    .family<List<IncomeSource>, int>((ref, profileId) =>
        ref.read(incomeSourceRepositoryProvider).getAll(profileId: profileId));

final salaryReceiptServiceProvider = Provider<SalaryReceiptService>((ref) {
  return SalaryReceiptService(IsarHelper.instance,
      recorder: ref.watch(syncRecorderProvider),
      pendingActions: ref.watch(pendingActionServiceProvider));
});

/// Lifecycle, schedule and period rules for the active personal income context.
final incomeActivationServiceProvider =
    Provider<IncomeActivationService>((ref) {
  final context = ref.watch(budgetContextProvider);
  final profileId = context.profileId;
  return IncomeActivationService(
    IsarHelper.instance,
    profileId: profileId,
    audit: profileId == null
        ? null
        : AuditRepository(IsarHelper.instance, actorId: profileId),
    pendingActions: ref.watch(pendingActionServiceProvider),
  );
});

final incomeReceiptServiceProvider = Provider<IncomeReceiptService>((ref) {
  return IncomeReceiptService(IsarHelper.instance,
      recorder: ref.watch(syncRecorderProvider),
      pendingActions: ref.watch(pendingActionServiceProvider));
});

/// Confirmed salary groups plus append-only salary corrections for one owner.
class IncomeLedgerSnapshot {
  const IncomeLedgerSnapshot({required this.groups, required this.corrections});
  final List<IncomeReceiptLedger> groups;
  final List<SalaryCorrection> corrections;
  bool get isEmpty => groups.isEmpty && corrections.isEmpty;
}

/// Owner-scoped, authenticated and reactive actual receipt classifications.
final actualIncomeLedgerProvider =
    StreamProvider.autoDispose<IncomeLedgerSnapshot>((ref) async* {
  final context = ref.watch(budgetContextProvider);
  final actor = ref.watch(actingProfileIdProvider);
  final auth = ref.watch(deviceAuthSessionProvider);
  final locked = ref.watch(lockControllerProvider).isLocked;
  if (context.isShared) {
    yield const IncomeLedgerSnapshot(groups: [], corrections: []);
    return;
  }
  if (actor == null ||
      actor != context.profileId ||
      !auth.authenticated ||
      locked) {
    throw const FormatException('Unlock the correct income owner.');
  }
  final session = ref.read(deviceAuthSessionProvider.notifier);
  final db = IsarHelper.instance;
  final signals = StreamController<void>();
  var queued = false;
  var alive = true;
  void enqueue() {
    if (!queued && !signals.isClosed) {
      queued = true;
      signals.add(null);
    }
  }

  final subscriptions = [
    for (final stream in [
      db.incomeReceiptGroups.watchLazy(),
      db.moneyReceipts.watchLazy(),
      db.receiptRevisions.watchLazy()
    ])
      stream.listen((_) => enqueue(),
          onError: (Object error, StackTrace stack) {
        if (!signals.isClosed) signals.addError(error, stack);
      })
  ];
  ref.onDispose(() {
    alive = false;
    for (final s in subscriptions) {
      unawaited(s.cancel());
    }
    unawaited(signals.close());
  });
  enqueue();
  await for (final _ in signals.stream) {
    queued = false;
    if (!alive ||
        !session.isCurrent(auth.generation) ||
        !ref.read(deviceAuthSessionProvider).authenticated ||
        ref.read(lockControllerProvider).isLocked ||
        ref.read(budgetContextProvider) != context) {
      throw const FormatException('Income access changed.');
    }
    final rows = await db.txn(() async {
      return IncomeLedgerSnapshot(
          groups: await IncomeReceiptLedger.forOwner(db, actor),
          corrections: await SalaryCorrection.forOwner(db, actor));
    });
    if (!alive ||
        !session.isCurrent(auth.generation) ||
        !ref.read(deviceAuthSessionProvider).authenticated ||
        ref.read(lockControllerProvider).isLocked ||
        ref.read(budgetContextProvider) != context) {
      throw const FormatException('Income access changed.');
    }
    yield rows;
  }
});

/// Salary classification only, in original accounting minor units.
final actualSalaryFundingProvider = Provider.family<AsyncValue<int>, String>(
    (ref, month) => ref.watch(actualIncomeLedgerProvider).whenData((ledger) =>
        ledger.groups
            .where((g) => g.group.destinationMonth == month)
            .fold<int>(0, (sum, g) => checkedFxMinor(sum + g.salaryMinor)) +
        ledger.corrections
            .where((c) => c.cashMonth == month)
            .fold<int>(0, (sum, c) => checkedFxMinor(sum + c.amountMinor))));

/// Salary cycles for the active personal profile.
final salaryCyclesProvider = FutureProvider<List<SalaryCycle>>((ref) async {
  final context = ref.watch(budgetContextProvider);
  if (context.isShared || context.profileId == null) {
    return const <SalaryCycle>[];
  }
  final db = IsarHelper.instance;
  return db.salaryCycles
      .filter()
      .profileIdEqualTo(context.profileId!)
      .findAll();
});

final medicalWithholdingServiceProvider =
    Provider<MedicalWithholdingService>((ref) {
  return MedicalWithholdingService(IsarHelper.instance,
      recorder: ref.watch(syncRecorderProvider));
});

final incomeSourceActionsProvider = Provider<IncomeSourceActions>((ref) {
  return IncomeSourceActions(ref);
});

class IncomeSourceActions {
  final Ref _ref;
  IncomeSourceActions(this._ref);

  Future<void> save(IncomeSource source,
      {int? nominalDay, String? timezone}) async {
    final context = _ref.read(budgetContextProvider);
    if (context.isShared) {
      source.sharedSpaceId = context.spaceId;
      source.profileId = null;
    } else {
      source.profileId = context.profileId;
      source.sharedSpaceId = null;
    }
    await _ref.read(incomeSourceRepositoryProvider).save(source);
    if (!context.isShared && context.profileId != null) {
      final activation = _ref.read(incomeActivationServiceProvider);
      if (source.frequency != IncomeFrequency.oneTime && nominalDay != null) {
        await activation.upsertSchedule(source,
            nominalDay: nominalDay, timezone: timezone ?? 'UTC');
      }
      final period = periodKeyFor(source, DateTime.now());
      if (!isPeriodActive(source, period)) {
        // Ending (or moving) a source must close its current attention task.
        await activation.cancelSourceActions(source,
            periodKey: period,
            reason: source.endDate != null ? 'sourceEnded' : 'periodClosed');
      }
    }
  }

  Future<void> delete(int id) async {
    final repository = _ref.read(incomeSourceRepositoryProvider);
    final source = await repository.getById(id);
    final context = _ref.read(budgetContextProvider);
    if (source != null &&
        !context.isShared &&
        source.profileId != null &&
        source.sharedSpaceId == null) {
      await _ref
          .read(incomeActivationServiceProvider)
          .cancelSourceActions(source, reason: 'sourceMissing');
    }
    await repository.delete(id);
  }
}
