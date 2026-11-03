import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/models/medical_approval.dart';
import '../../../core/models/money_receipt.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/models/medical_settlement_event.dart';
import '../../../core/models/medical_withholding_match.dart';
import '../../../core/models/income_receipt_group.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/balance_checkpoint.dart';
import '../../../core/models/financial_adoption.dart';
import '../../../core/models/period_funding_assignment.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/month_rate_seal.dart';
import '../../../core/models/month_end_run.dart';
import '../../vault/models/savings_vault.dart';
import '../../vault/models/vault_entry.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../spaces/providers/spaces_providers.dart';
import '../../../core/providers/clock_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../core/services/medical_receipt_service.dart';
import '../../../core/services/receipt_snapshot_repository.dart';
import '../../expenses/models/reimbursement.dart';
import '../../identity/providers/device_auth_session.dart';
import '../../security/providers/lock_providers.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import 'medical_providers.dart';
import '../presentation/medical_bill_view_state.dart';

/// Bill detail is not restricted to the selected budget month. Reuse the
/// guarded bill history and the same pure resolver as the month/list provider;
/// never change the global month to read a bill from an older service month.
final medicalBillDetailViewStateProvider = Provider.autoDispose
    .family<AsyncValue<MedicalBillViewState>, int>((ref, billId) {
  final context = ref.watch(budgetContextProvider);
  final actor = ref.watch(actingProfileIdProvider);
  final native = ref.watch(deviceAuthSessionProvider);
  final locked = ref.watch(lockControllerProvider).isLocked;
  if (actor == null ||
      !native.authenticated ||
      locked ||
      (!context.isShared && actor != context.profileId)) {
    return AsyncError(
        const MedicalReceiptException('accessChanged'), StackTrace.current);
  }
  final source = ref.watch(medicalReceiptHistoryProvider(billId));
  if (source.isLoading) return const AsyncLoading();
  if (source.hasError) return AsyncError(source.error!, source.stackTrace!);
  final history = source.valueOrNull;
  if (history == null) return const AsyncLoading();
  final bill = history.bill;
  if (bill.id != billId ||
      bill.profileId != context.profileId ||
      bill.sharedSpaceId != context.spaceId) {
    return AsyncError(
        const MedicalReceiptException('wrongOwner'), StackTrace.current);
  }
  final setup = ref.watch(medicalBillMonthBlockersProvider(billId));
  return AsyncData(ref.watch(medicalBillStateResolverProvider).resolve(
      MedicalBillFacts.fromHistory(bill, history),
      canEdit: ref.watch(activeContextCanEditProvider),
      readiness: medicalViewReadiness(
          setup.isLoading || setup.hasError ? null : setup.valueOrNull),
      now: ref.watch(clockProvider)));
});

/// Cross-month, owner-scoped source for the Medical action inbox and detail.
/// A single collection-watching stream supplies a consistent batch, rather than
/// creating an independent history query for every card.
final medicalBillViewBatchProvider =
    StreamProvider.autoDispose<MedicalHistoryBatch>((ref) async* {
  final context = ref.watch(budgetContextProvider);
  final actor = ref.watch(actingProfileIdProvider);
  final native = ref.watch(deviceAuthSessionProvider);
  final locked = ref.watch(lockControllerProvider).isLocked;
  if (actor == null || !native.authenticated || locked) {
    throw const MedicalReceiptException('accessChanged');
  }
  final session = ref.read(deviceAuthSessionProvider.notifier);
  final repository = ref.watch(medicalRepositoryProvider);
  var alive = true;
  bool access() {
    if (!alive) return false;
    final current = ref.read(budgetContextProvider);
    return session.isCurrent(native.generation) &&
        ref.read(deviceAuthSessionProvider).authenticated &&
        !ref.read(lockControllerProvider).isLocked &&
        ref.read(actingProfileIdProvider) == actor &&
        current.profileId == context.profileId &&
        current.spaceId == context.spaceId &&
        current.yearMonth == context.yearMonth;
  }

  final db = IsarHelper.instance;
  final events = StreamController<void>();
  var queued = false;
  void enqueue() {
    if (!events.isClosed && !queued) {
      queued = true;
      events.add(null);
    }
  }

  final subscriptions = [
    for (final stream in [
      db.medicalBills.watchLazy(),
      db.expenses.watchLazy(),
      db.medicalApprovals.watchLazy(),
      db.medicalClaimActivitys.watchLazy(),
      db.medicalClaimClosures.watchLazy(),
      db.medicalSettlements.watchLazy(),
      db.medicalWithholdingMatchs.watchLazy(),
      db.incomeReceiptGroups.watchLazy(),
      db.reimbursements.watchLazy(),
      db.receiptRevisions.watchLazy(),
      db.monthlyBudgets.watchLazy(),
      db.balanceCheckpoints.watchLazy(),
      db.financialAdoptions.watchLazy(),
      db.periodFundingAssignments.watchLazy(),
      db.sharedMembers.watchLazy(),
      db.sharedSpaces.watchLazy(),
      db.userProfiles.watchLazy(),
      db.monthRateSeals.watchLazy(),
      db.monthEndRuns.watchLazy(),
      db.savingsVaults.watchLazy(),
      db.vaultEntrys.watchLazy(),
    ])
      stream.listen((_) => enqueue(), onError: (Object e, StackTrace s) {
        if (!events.isClosed) events.addError(e, s);
      }),
  ];
  ref.onDispose(() {
    alive = false;
    for (final sub in subscriptions) {
      unawaited(sub.cancel());
    }
    unawaited(events.close());
  });
  enqueue();
  try {
    await for (final _ in events.stream) {
      queued = false;
      if (!alive) return;
      if (!access()) throw const MedicalReceiptException('accessChanged');
      MedicalHistoryBatch batch;
      try {
        batch = await repository.readInboxViewData(context,
            isAccessCurrent: access);
      } on MedicalReceiptException catch (error) {
        if (!alive && error.code == 'accessChanged') return;
        rethrow;
      } on ReceiptGuardException catch (error) {
        if (!alive && error.code == 'accessChanged') return;
        rethrow;
      }
      // The old stream is no longer a recipient after a context change. Finish
      // it without emitting either old data or a late error into a new context.
      if (!alive) return;
      if (!access()) throw const MedicalReceiptException('accessChanged');
      yield batch;
    }
  } finally {
    alive = false;
    for (final sub in subscriptions) {
      await sub.cancel();
    }
    if (!events.isClosed) unawaited(events.close());
  }
});

/// Returns no previous owner's values while a new context/session is loading.
/// The immediate access gate also protects against a stream's previous AsyncData.
final medicalBillViewStatesProvider =
    Provider.autoDispose<AsyncValue<Map<int, MedicalBillViewState>>>((ref) {
  final context = ref.watch(budgetContextProvider);
  final actor = ref.watch(actingProfileIdProvider);
  final native = ref.watch(deviceAuthSessionProvider);
  final lock = ref.watch(lockControllerProvider);
  if (actor == null ||
      !native.authenticated ||
      lock.isLocked ||
      (!context.isShared && context.profileId != actor)) {
    return AsyncError(
        const MedicalReceiptException('accessChanged'), StackTrace.current);
  }
  final source = ref.watch(medicalBillViewBatchProvider);
  if (source.isLoading) return const AsyncLoading();
  if (source.hasError) return AsyncError(source.error!, source.stackTrace!);
  final batch = source.valueOrNull;
  if (batch == null) return const AsyncLoading();
  final canEdit = ref.watch(activeContextCanEditProvider);
  final resolver = ref.watch(medicalBillStateResolverProvider);
  final now = ref.watch(clockProvider);
  final values = <int, MedicalBillViewState>{};
  for (final bill in batch.bills) {
    if (!_ownsBill(bill, context)) {
      return AsyncError(
          const MedicalReceiptException('wrongOwner'), StackTrace.current);
    }
    // The detail/month list remains month-scoped. Other months in the same
    // owner batch are skipped, not treated as an ownership error.
    if (bill.yearMonth != context.yearMonth) continue;
    values[bill.id] = resolver.resolve(
        MedicalBillFacts.fromHistory(bill, batch.histories[bill.id],
            readIssue: batch.issues.containsKey(bill.id)),
        canEdit: canEdit,
        readiness: _billReadiness(batch, bill.id),
        now: now);
  }
  return AsyncData(Map.unmodifiable(values));
});

/// Cross-month action inbox. It uses the same batch, resolver, access checks and
/// money facts as detail; only the filtering and summary are new.
final medicalInboxProvider =
    Provider.autoDispose<AsyncValue<MedicalInbox>>((ref) {
  final context = ref.watch(budgetContextProvider);
  final actor = ref.watch(actingProfileIdProvider);
  final native = ref.watch(deviceAuthSessionProvider);
  final lock = ref.watch(lockControllerProvider);
  if (actor == null ||
      !native.authenticated ||
      lock.isLocked ||
      (!context.isShared && context.profileId != actor)) {
    return AsyncError(
        const MedicalReceiptException('accessChanged'), StackTrace.current);
  }
  final source = ref.watch(medicalBillViewBatchProvider);
  if (source.isLoading) return const AsyncLoading();
  if (source.hasError) return AsyncError(source.error!, source.stackTrace!);
  final batch = source.valueOrNull;
  if (batch == null) return const AsyncLoading();

  final canEdit = ref.watch(activeContextCanEditProvider);
  final resolver = ref.watch(medicalBillStateResolverProvider);
  final now = ref.watch(clockProvider);
  final directory = ref.watch(medicalDirectoryProvider);
  final serviceTypes =
      ref.watch(medicalServiceTypesProvider).valueOrNull ??
          const <MedicalServiceType>[];
  final serviceNames = {for (final type in serviceTypes) type.id: type.name};
  final display = ref.watch(medicalDisplayCurrencyProvider);
  final table = ref.watch(rateRegistryProvider).tableFor(
        ref.watch(selectedYearMonthProvider),
      );
  final items = <MedicalInboxItem>[];
  for (final bill in batch.bills) {
    if (!_ownsBill(bill, context)) {
      return AsyncError(
          const MedicalReceiptException('wrongOwner'), StackTrace.current);
    }
    final state = resolver.resolve(
        MedicalBillFacts.fromHistory(bill, batch.histories[bill.id],
            readIssue: batch.issues.containsKey(bill.id)),
        canEdit: canEdit,
        readiness: _billReadiness(batch, bill.id),
        now: now);
    items.add(MedicalInboxItem(
      bill: bill,
      state: state,
      providerName: directory.providerName(bill.providerId),
      memberName: directory.memberName(bill.familyMemberId),
      serviceTypeName: serviceNames[bill.serviceTypeId],
      issue: batch.issues[bill.id],
    ));
  }
  return AsyncData(buildMedicalInbox(
    items: items,
    filters: ref.watch(medicalInboxFiltersProvider),
    display: display,
    now: now,
    convert: (amount) => tryToDisplay(amount, display, table),
  ));
});

bool _ownsBill(MedicalBill bill, ContextRef context) =>
    bill.profileId == context.profileId &&
    bill.sharedSpaceId == context.spaceId;

MedicalReadiness _billReadiness(MedicalHistoryBatch batch, int billId) {
  final value = batch.blockersByBill.containsKey(billId)
      ? batch.blockersByBill[billId]
      : batch.blockers;
  return medicalViewReadiness(value);
}
final medicalReceiptHistoryProvider = StreamProvider.autoDispose
    .family<MedicalReceiptHistory, int>((ref, billId) async* {
  final context = ref.watch(budgetContextProvider);
  final actor = ref.watch(actingProfileIdProvider);
  final native = ref.watch(deviceAuthSessionProvider);
  final lock = ref.watch(lockControllerProvider);
  if (actor == null || !native.authenticated || lock.isLocked) {
    throw const MedicalReceiptException('accessChanged');
  }
  final session = ref.read(deviceAuthSessionProvider.notifier);
  var alive = true;
  ref.onDispose(() => alive = false);
  bool access() =>
      alive &&
      session.isCurrent(native.generation) &&
      ref.read(deviceAuthSessionProvider).authenticated &&
      !ref.read(lockControllerProvider).isLocked;
  final repository = ref.watch(medicalRepositoryProvider);
  final db = IsarHelper.instance;
  final events = StreamController<void>();
  var queued = false;
  void enqueue() {
    if (events.isClosed || queued) return;
    queued = true;
    events.add(null);
  }

  final streams = [
    db.medicalApprovals.watchLazy(),
    db.medicalClaimActivitys.watchLazy(),
    db.receiptRevisions.watchLazy(),
    db.medicalClaimClosures.watchLazy(),
    db.medicalSettlements.watchLazy(),
    db.medicalWithholdingMatchs.watchLazy(),
    db.incomeReceiptGroups.watchLazy(),
    db.reimbursements.watchLazy(),
    db.medicalBills.watchLazy(),
    db.expenses.watchLazy()
  ];
  final subscriptions = [
    for (final stream in streams)
      stream.listen((_) => enqueue(),
          onError: (Object error, StackTrace stack) {
        if (!events.isClosed) events.addError(error, stack);
      })
  ];
  ref.onDispose(() {
    for (final sub in subscriptions) {
      unawaited(sub.cancel());
    }
    if (!events.isClosed) unawaited(events.close());
  });
  enqueue();
  try {
    await for (final _ in events.stream) {
      queued = false;
      final history =
          await repository.receiptHistory(billId, isAccessCurrent: access);
      if (history.bill.profileId != context.profileId ||
          history.bill.sharedSpaceId != context.spaceId) {
        throw const MedicalReceiptException('wrongOwner');
      }
      yield history;
    }
  } finally {
    for (final sub in subscriptions) {
      await sub.cancel();
    }
    if (!events.isClosed) await events.close();
  }
});
