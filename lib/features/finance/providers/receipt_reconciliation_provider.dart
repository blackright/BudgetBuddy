import '../../../core/models/income_receipt_group.dart';
import '../../../core/models/money_receipt.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/models/balance_checkpoint.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/financial_adoption.dart';
import '../../../core/models/month_rate_seal.dart';
import '../../../core/models/month_end_run.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/period_funding_assignment.dart';
import '../../../core/models/income_source.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/clock_provider.dart';
import '../../../core/services/balance_checkpoint_service.dart';
import '../../../core/services/receipt_snapshot_repository.dart';
import '../../../core/services/receipt_reconciliation_service.dart';
import '../../expenses/models/reimbursement.dart';
import '../../vault/models/vault_entry.dart';
import '../../vault/models/savings_vault.dart';
import '../../identity/providers/device_auth_session.dart';
import '../../security/providers/lock_providers.dart';

/// Cash review readiness only. Live funding consumers switch in Phase1c;
/// unbuilt confirmed salary logic is never represented as zero or ready income.
class CheckpointReadiness {
  CheckpointReadiness(this.sources, this.cash);
  final CheckpointSources sources;
  final CashReviewResult? cash;
  bool get needsReview =>
      sources.previous == null ||
      sources.previous!.adoptionGuid != sources.adoptionGuid ||
      sources.blockers.any((b) => {
            'missingMonth',
            'missingOpeningReview',
            'settlementNeedsReview'
          }.contains(b)) ||
      cash == null ||
      cash!.blockers.isNotEmpty;
}

/// The minute ticker triggers refresh; it is not an exact timestamp for a
/// newly recorded payment. Capture a fresh instant for each consistent read.
final checkpointClockProvider =
    Provider<DateTime Function()>((ref) => DateTime.now);

final receiptReconciliationProvider =
    StreamProvider.autoDispose<CheckpointReadiness>((ref) async* {
  final context = ref.watch(budgetContextProvider);
  final actor = ref.watch(actingProfileIdProvider);
  final auth = ref.watch(deviceAuthSessionProvider);
  final lock = ref.watch(lockControllerProvider);
  ref.watch(clockProvider);
  final clock = ref.watch(checkpointClockProvider);
  if (actor == null || !auth.authenticated || lock.isLocked) {
    throw const ReceiptGuardException('accessChanged');
  }
  final session = ref.read(deviceAuthSessionProvider.notifier);
  var alive = true;
  ref.onDispose(() => alive = false);
  bool access() =>
      alive &&
      session.isCurrent(auth.generation) &&
      ref.read(deviceAuthSessionProvider).authenticated &&
      !ref.read(lockControllerProvider).isLocked;
  final db = IsarHelper.instance;
  final service = BalanceCheckpointService(db, clock: clock);
  final signals = StreamController<void>();
  var queued = false;
  void enqueue() {
    if (signals.isClosed || queued) return;
    queued = true;
    signals.add(null);
  }

  final subscriptions = <StreamSubscription<void>>[];
  // Subscribe before the first read to avoid a missed update between reading
  // and listening. One queued read at a time prevents stale async completions.
  final streams = <Stream<void>>[
    db.balanceCheckpoints.watchLazy(),
    db.movementInclusions.watchLazy(),
    db.financialAdoptions.watchLazy(),
    db.expenses.watchLazy(),
    db.reimbursements.watchLazy(),
    db.monthlyBudgets.watchLazy(),
    db.incomeSources.watchLazy(),
    db.monthRateSeals.watchLazy(),
    db.monthEndRuns.watchLazy(),
    db.sharedMembers.watchLazy(),
    db.userProfiles.watchLazy(),
    db.sharedSpaces.watchLazy(),
    db.vaultEntrys.watchLazy(),
    db.savingsVaults.watchLazy(),
    db.periodFundingAssignments.watchLazy(),
    db.incomeReceiptGroups.watchLazy(), db.moneyReceipts.watchLazy(), db.receiptRevisions.watchLazy(),
  ];
  for (final stream in streams) {
    subscriptions.add(stream.listen((_) {
      enqueue();
    }, onError: (Object error, StackTrace stack) {
      if (!signals.isClosed) signals.addError(error, stack);
    }));
  }
  ref.onDispose(() {
    for (final subscription in subscriptions) {
      unawaited(subscription.cancel());
    }
    if (!signals.isClosed) unawaited(signals.close());
  });
  enqueue();
  try {
    await for (final _ in signals.stream) {
      queued = false;
      final sources = await service.load(
          context: context, actorId: actor, isAccessCurrent: access);
      final checkpoint = sources.previous;
      final cash = checkpoint == null
          ? null
          : const ReceiptReconciliationService().reviewCash(
              balanceMinor: checkpoint.balanceMinor,
              balanceAsOf: checkpoint.balanceAsOf,
              asOf: sources.source.capturedAt,
              movements: sources.movements,
              choices: sources.previousChoices);
      if (!access()) throw const ReceiptGuardException('accessChanged');
      yield CheckpointReadiness(sources, cash);
    }
  } finally {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    if (!signals.isClosed) await signals.close();
  }
});
