import '../../../core/logging/app_logger.dart';
import '../../../core/services/medical_bill_basis.dart';
import '../../../core/services/medical_bill_review_service.dart';
import '../../../core/models/medical_approval.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/reconciliation_snapshot.dart';
import '../../../core/services/receipt_snapshot_repository.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/services/legacy_medical_reimbursement_guard.dart';
import '../../finance/repositories/audit_repository.dart';
import 'package:isar/isar.dart';

import '../../../core/models/expense.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_settlement_event.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/network/rate_types.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../core/services/reminder_notification_service.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../expenses/models/reimbursement.dart';
import '../../../core/services/medical_receipt_service.dart';
import '../../spaces/repositories/space_write_guard.dart';
import '../../sync/repositories/sync_recorder.dart';

/// Budget-scoped inputs needed to keep a [MedicalBill] and its linked [Expense]
/// consistent. Supplied by the UI layer from the active context.
class MedicalBillContext {
  const MedicalBillContext({
    required this.profileId,
    this.sharedSpaceId,
    required this.budgetId,
    required this.yearMonth,
    required this.primaryCurrency,
    this.rateTable,
  });

  /// Owning profile id, or `0` when the bill belongs to a shared space.
  final int profileId;
  final int? sharedSpaceId;
  final int budgetId;

  /// `YYYY-MM` of the active budget, stored on the linked expense so the
  /// engine's `trueAvailable` picks the bill up in the right month.
  final String yearMonth;
  final String primaryCurrency;

  /// Rates for [yearMonth], so deltas convert minor→primary instead of casting
  /// the stored minor unit as if it were major (T-R05). Optional for callers
  /// that only need linkage and never compute a money delta.
  final RateTable? rateTable;
}

/// Thrown when a state change would produce an impossible bill.
class InvalidBillTransitionException implements Exception {
  const InvalidBillTransitionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when a document is attached to a bill that cannot have one (FR-047).
class InvalidDocumentException implements Exception {
  const InvalidDocumentException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when a service type name collides with an existing one (FR-040).
class DuplicateServiceTypeException implements Exception {
  const DuplicateServiceTypeException(this.name);

  final String name;

  @override
  String toString() =>
      'A service type named "$name" already exists. Choose a different name.';
}

/// Thrown when deleting a reimbursed bill without an explicit override.
///
/// Removing a reimbursed bill rewrites budget history (FR-005), so the caller
/// must confirm with the user first.
class ReimbursedBillDeletionException implements Exception {
  const ReimbursedBillDeletionException(this.billId, this.reimbursedAmount);

  final int billId;
  final int reimbursedAmount;

  @override
  String toString() =>
      'Bill $billId has a logged reimbursement of $reimbursedAmount. '
      'Deleting it will remove that amount from your available budget.';
}

/// Single write path for medical bills and everything they touch.
///
/// Responsibilities:
/// - CRUD + reactive streams for the medical collections.
/// - Maintains the 1:1 [MedicalBill] <-> [Expense] link (FR-003).
/// - Injects/removes the [Reimbursement] row that moves `trueAvailable`
///   (FR-004, FR-005).
class MedicalRepository {
  MedicalRepository(
    this._isar, {
    RateTableRegistry? rateRegistry,
    SpaceWriteGuard? guard,
    int? actingProfileId,
    SyncRecorder? syncRecorder,
  })  : _rateRegistry = rateRegistry,
        _writeGuard = guard,
        _actingProfileId = actingProfileId,
        _syncRecorder = syncRecorder;

  /// Matches the seeded `Category` with `categoryId == 'health'`.
  static const String medicalCategoryId = 'health';

  final Isar _isar;

  /// Optional rates so expense deltas convert correctly. When absent, the
  /// bundled fallback is used via a registry built from nothing.
  final RateTableRegistry? _rateRegistry;

  /// Optional role guard + acting profile: when present, every shared bill or
  /// reimbursement write is refused for a Viewer or a sealed month (US4).
  final SpaceWriteGuard? _writeGuard;
  final int? _actingProfileId;

  /// Appends a signed change for a paired shared context on every write
  /// (FR-006). Optional and inert when no signer/identity is attached, so 011's
  /// behaviour and its tests are unchanged. Personal rows (a `null`
  /// `sharedSpaceId`) are never exchanged, so the recorder no-ops for them.
  final SyncRecorder? _syncRecorder;

  MedicalBillReviewService get billReviewService =>
      MedicalBillReviewService(_isar, recorder: _syncRecorder);
  Future<MedicalBillReview> reviewBill(
          {required MedicalBill proposed,
          required ExpenseStatus status,
          required String reason,
          required bool Function() isAccessCurrent,
          bool remove = false,
          DateTime? paymentDate}) =>
      billReviewService.preview(
          proposed: proposed,
          status: status,
          reason: reason,
          actorId: _actingProfileId ?? proposed.profileId ?? 0,
          isAccessCurrent: isAccessCurrent,
          remove: remove,
          paymentDate: paymentDate);

  Future<void> applyBillReview(
      {required MedicalBillReview review,
      required String operationKey,
      required bool Function() isAccessCurrent}) async {
    if (_actingProfileId != null && _actingProfileId != review.actorId) {
      throw const MedicalReceiptException('wrongOwner');
    }
    await _guardWrite(null, review.proposed.yearMonth);
    await _isar.writeTxn(() => billReviewService.applyInTransaction(
        review: review,
        operationKey: operationKey,
        isAccessCurrent: isAccessCurrent,
        persist: (bill, status) async {
          if (review.remove) {
            final expense = (await _isar.expenses.get(bill.linkedExpenseId!))!;
            expense.status = ExpenseStatus.cancelled;
            await AuditRepository(_isar,
                    recorder: _syncRecorder, actorId: review.actorId)
                .put(_isar.expenses, expense, id: expense.id, type: 'Expense');
            return;
          }
          _validateBill(bill);
          final month = await _isar.monthlyBudgets
              .filter()
              .profileIdEqualTo(review.actorId)
              .and()
              .sharedSpaceIdIsNull()
              .and()
              .yearMonthEqualTo(bill.yearMonth)
              .findFirst();
          final owner = await _isar.userProfiles.get(review.actorId);
          if (month == null || owner == null) {
            throw const MedicalReceiptException('missingMonth');
          }
          final context = MedicalBillContext(
              profileId: review.actorId,
              budgetId: month.id,
              yearMonth: bill.yearMonth,
              primaryCurrency: owner.primaryCurrency.name,
              rateTable: _rateRegistry?.tableFor(bill.yearMonth));
          final expense = await _syncLinkedExpense(bill, context,
              status: status,
              paymentDate: review.paymentDate,
              preservePaymentDate: true);
          bill.linkedExpenseId = expense.id;
          await _putBillRecorded(bill);
        }));
  }

  /// Recheck stored approval/receipt references under the same financial lock.
  Future<void> _ordinaryEditAllowed(MedicalBill bill,
      {ExpenseStatus? status, bool deleting = false}) async {
    final current = await _isar.medicalBills.get(bill.id);
    if (current == null || current.sharedSpaceId != null) return;
    final activities = await _isar.medicalClaimActivitys
        .filter()
        .billGuidEqualTo(current.syncGuid)
        .findAll();
    if (activities.any((a) => a.kind == 'removed')) {
      throw const MedicalReceiptException('billRemoved');
    }
    if (deleting && activities.any((a) => a.kind != 'created')) {
      throw const MedicalReceiptException('billReviewRequired');
    }
    final approval = await _isar.medicalApprovals
        .filter()
        .billGuidEqualTo(current.syncGuid)
        .findFirst();
    if (approval == null) return;
    final expense = current.linkedExpenseId == null
        ? null
        : await _isar.expenses.get(current.linkedExpenseId!);
    if (deleting ||
        medicalBillBasis(current) != medicalBillBasis(bill) ||
        current.profileId != bill.profileId ||
        current.sharedSpaceId != bill.sharedSpaceId ||
        current.linkedExpenseId != bill.linkedExpenseId ||
        current.syncGuid != bill.syncGuid ||
        current.reimbursedAmount != bill.reimbursedAmount ||
        current.fundsImpact != bill.fundsImpact ||
        current.state != bill.state ||
        (status != null && expense != null && status != expense.status)) {
      throw const MedicalReceiptException('billReviewRequired');
    }
  }

  MedicalReceiptService get receiptService =>
      MedicalReceiptService(_isar, recorder: _syncRecorder);

  /// Read-only presentation batch; never creates or patches a financial row.
  Future<MedicalHistoryBatch> readBillViewData(ContextRef context,
          {required bool Function() isAccessCurrent}) =>
      receiptService.historyBatch(
          context: context,
          actorId: _actingProfileId ??
              (throw const MedicalReceiptException('accessChanged')),
          isAccessCurrent: isAccessCurrent);

  /// Owner-scoped, cross-month batch for the action inbox.
  Future<MedicalHistoryBatch> readInboxViewData(ContextRef context,
          {required bool Function() isAccessCurrent}) =>
      receiptService.historyInboxBatch(
          context: context,
          actorId: _actingProfileId ??
              (throw const MedicalReceiptException('accessChanged')),
          isAccessCurrent: isAccessCurrent);

  Future<MedicalReceiptHistory> receiptHistory(int billId,
          {required bool Function() isAccessCurrent}) =>
      receiptService.history(
          billId: billId,
          actorId: _actingProfileId ??
              (throw const MedicalReceiptException('accessChanged')),
          isAccessCurrent: isAccessCurrent);

  Future<void> _guardWrite(int? sharedSpaceId, String yearMonth) async {
    await _writeGuard?.assertSharedMoneyWrite(
      sharedSpaceId: sharedSpaceId,
      actingProfileId: _actingProfileId,
      yearMonth: yearMonth,
    );
  }

  // ---------------------------------------------------------------------------
  // Reactive reads
  // ---------------------------------------------------------------------------

  /// Bills belonging to [profileId] whose owning month is [yearMonth].
  ///
  /// Month-scoped rather than year-scoped because a bill's money impact lands in
  /// exactly one month's totals (FR-055, FR-056).
  /// Bills belonging to [context]'s month — the context-scoped route (R3,
  /// data-model §3.5): `profileIdEqualTo` for personal, `sharedSpaceIdEqualTo`
  /// for shared.
  ///
  /// The personal branch also demands `sharedSpaceId == null`: the personal and
  /// the shared drawer never cross (FR-013), so a space row that carries a
  /// profile key — written by an older build, or delivered by a peer that way —
  /// can never answer for a personal profile.
  Stream<List<MedicalBill>> watchMedicalBillsForContext(ContextRef context) {
    return _isar.medicalBills
        .filter()
        .group((q) => context.isShared
            ? q.sharedSpaceIdEqualTo(context.spaceId)
            : q
                .profileIdEqualTo(context.profileKey)
                .and()
                .sharedSpaceIdIsNull())
        .and()
        .yearMonthEqualTo(context.yearMonth)
        .sortByServiceDateDesc()
        .watch(fireImmediately: true);
  }

  Stream<MedicalBill?> watchMedicalBill(int id) {
    return _isar.medicalBills.watchObject(id, fireImmediately: true);
  }

  Stream<InsuranceProfile?> watchInsuranceProfileForContext(
      ContextRef context) {
    return _isar.insuranceProfiles
        .filter()
        .group((q) => context.isShared
            ? q.sharedSpaceIdEqualTo(context.spaceId)
            : q
                .profileIdEqualTo(context.profileKey)
                .and()
                .sharedSpaceIdIsNull())
        .watch(fireImmediately: true)
        .map((rows) => rows.isEmpty
            ? null
            : context.isShared
                ? rows.first
                : _pickProfile(rows, context.profileKey));
  }

  Stream<List<FamilyMember>> watchFamilyMembersForContext(ContextRef context) {
    return _isar.familyMembers
        .filter()
        .group((q) => context.isShared
            ? q.sharedSpaceIdEqualTo(context.spaceId)
            : q
                .profileIdEqualTo(context.profileKey)
                .and()
                .sharedSpaceIdIsNull())
        .sortByName()
        .watch(fireImmediately: true);
  }

  Stream<List<MedicalProvider>> watchMedicalProvidersForContext(
      ContextRef context) {
    return _isar.medicalProviders
        .filter()
        .group((q) => context.isShared
            ? q.sharedSpaceIdEqualTo(context.spaceId)
            : q
                .profileIdEqualTo(context.profileKey)
                .and()
                .sharedSpaceIdIsNull())
        .sortByName()
        .watch(fireImmediately: true);
  }

  /// Reactive `expenseId -> ExpenseStatus` map for the supplied expenses.
  Stream<Map<int, ExpenseStatus>> watchExpenseStatuses(List<int> expenseIds) {
    if (expenseIds.isEmpty) return Stream.value(const <int, ExpenseStatus>{});
    return _isar.expenses
        .filter()
        .anyOf(expenseIds, (q, int id) => q.idEqualTo(id))
        .watch(fireImmediately: true)
        .map((expenses) => {for (final e in expenses) e.id: e.status});
  }

  // ---------------------------------------------------------------------------
  // One-shot reads
  // ---------------------------------------------------------------------------

  Future<MedicalBill?> getMedicalBill(int id) => _isar.medicalBills.get(id);

  Future<List<MedicalBill>> getMedicalBillsForMonth(
    int profileId,
    String yearMonth,
  ) {
    return _isar.medicalBills
        .filter()
        .profileIdEqualTo(profileId)
        .yearMonthEqualTo(yearMonth)
        .sortByServiceDateDesc()
        .findAll();
  }

  Future<InsuranceProfile?> getInsuranceProfile(int profileId) async {
    final rows = await _isar.insuranceProfiles
        .filter()
        .profileIdEqualTo(profileId)
        .findAll();
    return _pickProfile(rows, profileId);
  }

  Future<List<FamilyMember>> getFamilyMembers(int profileId) =>
      _isar.familyMembers
          .filter()
          .profileIdEqualTo(profileId)
          .sortByName()
          .findAll();

  Future<List<MedicalProvider>> getMedicalProviders(int profileId) =>
      _isar.medicalProviders
          .filter()
          .profileIdEqualTo(profileId)
          .sortByName()
          .findAll();

  // ---------------------------------------------------------------------------
  // Bill lifecycle
  // ---------------------------------------------------------------------------

  /// Creates or updates [bill] together with its linked [Expense].
  ///
  /// The expense is created `planned` unless [status] says the user already
  /// paid the provider, in which case `paidAt` is stamped and `trueAvailable`
  /// drops by the billed amount (FR-004). Amount and status edits flow straight
  /// through the engine's Isar watchers.
  Future<MedicalBill> saveBill(
    MedicalBill bill,
    MedicalBillContext context, {
    ExpenseStatus? status,
    bool Function()? isAccessCurrent,
  }) async {
    AppLogger.medicalRepo(
        'SAVE_BILL_START id=${bill.id} syncGuid=${bill.syncGuid} profileId=${bill.profileId} sharedSpaceId=${bill.sharedSpaceId} yearMonth=${bill.yearMonth} state=${bill.state} paymentMethod=${bill.paymentMethod} billedAmount=${bill.billedAmount} patientSharePercent=${bill.patientSharePercent} currency=${bill.currency} linkedExpenseId=${bill.linkedExpenseId} fundsImpact=${bill.fundsImpact}');
    if (isAccessCurrent != null && !isAccessCurrent()) {
      throw const MedicalReceiptException('accessChanged');
    }
    await _guardWrite(context.sharedSpaceId, context.yearMonth);
    _validateBill(bill);

    // The context owns the row (FR-003, FR-013): a bill saved into a space is
    // keyed on the space and never on a profile, whatever the caller pinned on
    // it. Without this a shared bill kept the personal key it was built with
    // and answered for the personal drawer too (data-model §3,
    // "exactly-one-context").
    bill
      ..serviceDate ??= DateTime.now()
      ..sharedSpaceId = context.sharedSpaceId
      ..profileId = context.profileId
      ..patientSharePercent = bill.patientSharePercent.clamp(0.0, 100.0);

    await _isar.writeTxn(() async {
      if (isAccessCurrent != null && !isAccessCurrent()) {
        throw const MedicalReceiptException('accessChanged');
      }
      final creating = await _isar.medicalBills.get(bill.id) == null;
      AppLogger.medicalRepo('SAVE_BILL_CREATING=$creating id=${bill.id}');
      await _ordinaryEditAllowed(bill, status: status);
      // A2 (improvements plan): never leave a bill in a month that has no
      // budget row, so the later reviewed-correction flow can always read a
      // receipt snapshot. Provision an unconfirmed month if needed; never
      // invent an opening balance or mark it confirmed.
      await _ensureBillMonth(bill, context);
      final approvalCount = !creating && bill.sharedSpaceId == null
          ? await _isar.medicalApprovals
              .filter()
              .billGuidEqualTo(bill.syncGuid)
              .count()
          : 0;
      if (!creating && bill.sharedSpaceId == null && approvalCount > 0) {
        AppLogger.medicalRepo(
            'SAVE_BILL_DOC_ONLY_EDIT id=${bill.id} approvalCount=$approvalCount');
        // Document-only edits must not re-sync or invent an old payment date.
        await _putBillRecorded(bill);
        if (isAccessCurrent != null && !isAccessCurrent()) {
          throw const MedicalReceiptException('accessChanged');
        }
        return;
      }
      AppLogger.medicalRepo(
          'SAVE_BILL_SYNCING_EXPENSE id=${bill.id} status=$status');
      final expense = await _syncLinkedExpense(bill, context, status: status);
      AppLogger.medicalRepo(
          'SAVE_BILL_SYNCED_EXPENSE id=${bill.id} expenseId=${expense.id} expenseAmount=${expense.amount} expenseStatus=${expense.status}');
      bill.linkedExpenseId = expense.id;
      await _putBillRecorded(bill);
      if (creating &&
          bill.sharedSpaceId == null &&
          bill.paymentMethod == MedicalPaymentMethod.insurerPaid &&
          (bill.state == MedicalBillState.paid ||
              bill.state == MedicalBillState.waiting)) {
        // T053: one atomic creation-time fact. Paid answers are confirmed;
        // waiting is an explicit pending fact, never guessed from legacy data.
        final confirmed = bill.state == MedicalBillState.paid;
        final settlement = MedicalSettlementEvent()
          ..profileId = bill.profileId
          ..billGuid = bill.syncGuid
          ..kind = MedicalSettlementKind.insurerProviderSettlement
          ..confirmed = confirmed
          ..effectiveDate =
              (expense.paidAt ?? bill.serviceDate ?? DateTime.now()).toUtc()
          ..recordedAt = DateTime.now().toUtc()
          ..currency = expense.currencyCode?.code
          ..amountMinor = bill.insurerPaidAmount
          ..basisJson = medicalBillBasis(bill)
          ..expenseId = expense.id
          ..expenseGuid = expense.syncGuid
          ..reason = ''
          ..actorId = _actingProfileId ?? bill.profileId!
          ..operationIdentity =
              'medical-settlement:provider:${bill.syncGuid}:create'
          ..inputFingerprint = medicalBillBasis(bill);
        await AuditRepository(_isar,
                recorder: _syncRecorder,
                actorId: _actingProfileId ?? bill.profileId)
            .put(_isar.medicalSettlements, settlement,
                id: settlement.id,
                type: 'MedicalSettlementEvent',
                derived: false);
      }
      if (creating && bill.sharedSpaceId == null) {
        final row = MedicalClaimActivity()
          ..billGuid = bill.syncGuid
          ..profileId = bill.profileId!
          ..yearMonth = bill.yearMonth
          ..kind = 'created'
          ..reason = ''
          ..currency = bill.currency
          ..recordedAt = DateTime.now().toUtc()
          ..actorId = _actingProfileId ?? bill.profileId!
          ..operationIdentity = 'medical-created:${bill.syncGuid}'
          ..inputFingerprint = bill.syncGuid;
        await AuditRepository(_isar,
                recorder: _syncRecorder,
                actorId: _actingProfileId ?? bill.profileId)
            .put(_isar.medicalClaimActivitys, row,
                id: row.id, type: 'MedicalClaimActivity', derived: false);
      }
      if (isAccessCurrent != null && !isAccessCurrent()) {
        throw const MedicalReceiptException('accessChanged');
      }
    });
    AppLogger.medicalRepo(
        'SAVE_BILL_DONE id=${bill.id} linkedExpenseId=${bill.linkedExpenseId} fundsImpact=${bill.fundsImpact} state=${bill.state}');
    return bill;
  }

  /// Validation gate for a state change (T2, FR-044).
  ///
  /// `finished` means "fully resolved, money accounted for". An insurer-paid
  /// bill has no reimbursement to account for, so the state cannot be reached.
  static void _validateTransition(MedicalBill bill, MedicalBillState next) {
    // `finished` is terminal: once the payout is recorded the bill is settled,
    // so it can never slip back to waiting, be rejected, or be un-finished.
    if (bill.state == MedicalBillState.finished &&
        next != MedicalBillState.finished) {
      throw const InvalidBillTransitionException(
        'This bill is finished — the insurer payout has been recorded, so its '
        'status is locked.',
      );
    }
    if (next == MedicalBillState.finished &&
        bill.paymentMethod == MedicalPaymentMethod.insurerPaid) {
      throw const InvalidBillTransitionException(
        'An insurer-paid bill has no reimbursement to finish. Mark it paid or '
        'rejected instead.',
      );
    }
  }

  /// Moves a bill to [state], keeping the linked expense and any reimbursement
  /// consistent (FR-054, M5).
  ///
  /// Entering or leaving `rejected` recomputes the expense from the method and
  /// percentage rather than leaving a stale amount, and any reimbursement is
  /// deleted when the bill is rejected or when it moves away from `finished`
  /// (T3, T4). Money that did not return must not appear as returned.
  Future<void> setBillState(
    MedicalBill bill,
    MedicalBillState state, {
    MedicalBillContext? context,
    int? reimbursedAmount,
  }) async {
    AppLogger.medicalRepo(
        'SET_BILL_STATE_START id=${bill.id} from=${bill.state} to=$state linkedExpenseId=${bill.linkedExpenseId} fundsImpact=${bill.fundsImpact} paymentMethod=${bill.paymentMethod}');
    await _guardWrite(
        bill.sharedSpaceId ?? context?.sharedSpaceId, bill.yearMonth);
    _validateTransition(bill, state);

    if (state == MedicalBillState.finished && bill.canBeReimbursed) {
      // T1 — a self-paid bill cannot be finished without the payout recorded, so
      // the amount is required rather than silently defaulted to zero.
      if (reimbursedAmount == null) {
        throw ArgumentError.notNull('reimbursedAmount');
      }
      await logReimbursement(bill, amount: reimbursedAmount);
      // `logReimbursement` sets the state itself.
      return;
    }

    await _isar.writeTxn(() async {
      await _ordinaryEditAllowed(copyMedicalBill(bill)..state = state,
          status: state == MedicalBillState.planned
              ? ExpenseStatus.planned
              : ExpenseStatus.paid);
      // T4 — a bill that is no longer finished, or is rejected, must not keep a
      // reimbursement.
      final losesReimbursement = state == MedicalBillState.rejected ||
          bill.state == MedicalBillState.finished;
      AppLogger.medicalRepo(
          'SET_BILL_STATE_TXN id=${bill.id} losesReimbursement=$losesReimbursement');
      if (losesReimbursement) {
        await _clearReimbursementFor(bill);
        bill.reimbursedAmount = 0;
      }

      bill.state = state;
      await _putBillRecorded(bill);

      final syncContext = context ?? await _contextForExistingBill(bill);
      if (syncContext != null) {
        final expense = await _syncLinkedExpense(bill, syncContext);
        AppLogger.medicalRepo(
            'SET_BILL_STATE_SYNCED id=${bill.id} expenseId=${expense.id} expenseAmount=${expense.amount} expenseStatus=${expense.status}');
      }
    });

    if (state == MedicalBillState.paid || state == MedicalBillState.finished) {
      await _clearReminder(bill);
    }
    AppLogger.medicalRepo(
        'SET_BILL_STATE_DONE id=${bill.id} state=${bill.state}');
  }

  /// Switches a bill between insurer-paid and self-paid (FR-041).
  ///
  /// The method is the biggest lever on the budget, so the linked expense is
  /// re-synced through the same money-impact rule as any other change. Moving to
  /// insurer-paid clears the insurer reply (D2) and any reimbursement, because
  /// neither is meaningful when the insurer settles directly.
  Future<void> setPaymentMethod(
    MedicalBill bill,
    MedicalPaymentMethod method, {
    MedicalBillContext? context,
  }) async {
    if (bill.paymentMethod == method) return;

    // `finished` is terminal, so the method that produced the payout is frozen.
    if (bill.state == MedicalBillState.finished) {
      throw const InvalidBillTransitionException(
        'This bill is finished, so its payment method is locked.',
      );
    }

    await _guardWrite(
        bill.sharedSpaceId ?? context?.sharedSpaceId, bill.yearMonth);

    await _isar.writeTxn(() async {
      await _ordinaryEditAllowed(copyMedicalBill(bill)..paymentMethod = method);
      final becomesInsurerPaid = method == MedicalPaymentMethod.insurerPaid;
      if (becomesInsurerPaid) {
        await _clearReimbursementFor(bill);
        bill
          ..reimbursedAmount = 0
          ..insurerReplyPath = null;
        // R-1 — an insurer-paid bill is settled with the provider, so it can
        // never be `finished`.
        if (bill.state == MedicalBillState.finished) {
          bill.state = MedicalBillState.paid;
        }
      }

      bill.paymentMethod = method;
      await _putBillRecorded(bill);

      final syncContext = context ?? await _contextForExistingBill(bill);
      if (syncContext != null) {
        await _syncLinkedExpense(bill, syncContext);
      }
    });
  }

  Future<void> updateMedicalBillReimbursement(
      MedicalBill bill, int totalReimbursed) async {
    await _guardWrite(bill.sharedSpaceId, bill.yearMonth);
    await _isar.writeTxn(() async {
      final current = await _isar.medicalBills.get(bill.id);
      if (current == null) throw StateError('Medical bill no longer exists.');
      await LegacyMedicalReimbursementGuard.forBill(_isar, current);
      bill.reimbursedAmount = totalReimbursed;
      // A finished bill stays finished: correcting the payout amount must not
      // silently reopen a settled bill.
      if (bill.state != MedicalBillState.finished) {
        bill.state = (totalReimbursed >= bill.insurerPaidAmount)
            ? MedicalBillState.finished
            : MedicalBillState
                .waiting; // or however we want to represent partial
      }
      await _putBillRecorded(bill);
    });
  }

  /// Records the insurer payout and injects it into the budget (FR-005).
  ///
  /// All-or-nothing and idempotent: re-logging replaces the previous amount
  /// instead of stacking a second reimbursement against the same expense (R-2,
  /// R-3, R-4). The money is attributed to the month *after* the bill's owning
  /// month — the payout lands with next month's income — not to the date it was
  /// recorded (R-5 revision).
  Future<void> logReimbursement(
    MedicalBill bill, {
    required int amount,
    DateTime? date,
  }) async {
    AppLogger.medicalRepo(
        'LOG_REIMBURSEMENT_START id=${bill.id} amount=$amount date=$date paymentMethod=${bill.paymentMethod} canBeReimbursed=${bill.canBeReimbursed} linkedExpenseId=${bill.linkedExpenseId}');
    if (amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'must be greater than zero',
      );
    }
    await _guardWrite(bill.sharedSpaceId, bill.yearMonth);
    // FR-044 / R-1: an insurer-paid bill is settled with the provider, so there
    // is no payout to record. Refuse before touching the budget rather than
    // silently injecting money that was never coming.
    if (!bill.canBeReimbursed) {
      throw ArgumentError.value(
        amount,
        'amount',
        'only a self-paid bill can be reimbursed; bill ${bill.id} is '
            '${bill.paymentMethod.label}',
      );
    }
    final expenseId = bill.linkedExpenseId;
    if (expenseId == null) {
      throw StateError(
        'Bill ${bill.id} has no linked expense, so a reimbursement cannot be '
        'applied to the budget.',
      );
    }
    final expense = await _isar.expenses.get(expenseId);
    if (expense == null) {
      throw StateError('Linked expense $expenseId no longer exists.');
    }

    await _isar.writeTxn(() async {
      final current = await _isar.medicalBills.get(bill.id);
      if (current == null) throw StateError('Medical bill no longer exists.');
      await LegacyMedicalReimbursementGuard.forBill(_isar, current);
      final existing = await _isar.reimbursements
          .filter()
          .expenseIdEqualTo(expenseId)
          .findAll();

      final Reimbursement reimbursement;
      if (existing.isEmpty) {
        final created = Reimbursement(
          profileId: bill.profileId ?? expense.profileId,
          sharedSpaceId: bill.sharedSpaceId ?? expense.sharedSpaceId,
          expenseId: expenseId,
          amount: amount,
          currency: expense.currency,
          originYearMonth: nextMonth(
              bill.yearMonth.isNotEmpty ? bill.yearMonth : expense.yearMonth),
          date: date ?? DateTime.now(),
        );
        created.id = await AuditRepository(_isar,
                recorder: _syncRecorder, actorId: _actingProfileId)
            .put(_isar.reimbursements, created,
                id: created.id, type: 'Reimbursement');
        reimbursement = created;
      } else {
        // Collapse to a single row so the engine never sees a doubled payout.
        existing.sort((a, b) => a.id.compareTo(b.id));
        existing.first
          ..amount = amount
          ..originYearMonth = nextMonth(
              bill.yearMonth.isNotEmpty ? bill.yearMonth : expense.yearMonth)
          ..date = date ?? existing.first.date;
        await AuditRepository(_isar,
                recorder: _syncRecorder, actorId: _actingProfileId)
            .put(_isar.reimbursements, existing.first,
                id: existing.first.id, type: 'Reimbursement');
        final extras = existing.skip(1).map((r) => r.id).toList();
        if (extras.isNotEmpty) {
          await _isar.reimbursements.deleteAll(extras);
        }
        reimbursement = existing.first;
      }
      await _syncRecorder?.recordReimbursement(reimbursement);

      bill
        ..reimbursedAmount = amount
        ..state = MedicalBillState.finished;
      await _putBillRecorded(bill);
      AppLogger.medicalRepo(
          'LOG_REIMBURSEMENT_TXN_DONE id=${bill.id} reimbursementId=${reimbursement.id} originYearMonth=${reimbursement.originYearMonth}');
    });
    AppLogger.medicalRepo(
        'LOG_REIMBURSEMENT_DONE id=${bill.id} reimbursedAmount=${bill.reimbursedAmount} state=${bill.state}');
  }

  /// Sets or clears the follow-up reminder date for a pending claim (FR-009).
  Future<void> setFollowUpDate(MedicalBill bill, DateTime? date,
      {bool Function()? isAccessCurrent}) async {
    final access = isAccessCurrent ?? () => true;
    if (!access()) throw const MedicalReceiptException('accessChanged');
    if (date != null && date.isBefore(DateTime.now())) {
      throw ArgumentError('Follow up date must be in the future.');
    }
    await _isar.writeTxn(() async {
      final current = await _isar.medicalBills.get(bill.id);
      if (current == null) {
        throw StateError('Medical bill no longer exists.');
      }
      if (isAccessCurrent != null) {
        await receiptService.historyInTransaction(
            billId: current.id,
            actorId: _actingProfileId ?? bill.profileId ?? 0,
            isAccessCurrent: access,
            write: true);
      }
      current.followUpDate = date;
      await _putBillRecorded(current);
      bill.followUpDate = date;
      if (!access()) throw const MedicalReceiptException('accessChanged');
    });

    if (date != null) {
      await ReminderNotificationService().scheduleReminder(
        id: bill.id,
        title: 'Claim Follow-up',
        body: 'Follow up on your pending medical bill',
        scheduledDate: date,
      );
    } else {
      await ReminderNotificationService().cancelReminder(bill.id);
    }
  }

  Future<void> setCalendarEventId(MedicalBill bill, String? eventId,
      {bool Function()? isAccessCurrent}) async {
    final access = isAccessCurrent ?? () => true;
    if (!access()) throw const MedicalReceiptException('accessChanged');
    await _isar.writeTxn(() async {
      final current = await _isar.medicalBills.get(bill.id);
      if (current == null) {
        throw StateError('Medical bill no longer exists.');
      }
      if (isAccessCurrent != null) {
        await receiptService.historyInTransaction(
            billId: current.id,
            actorId: _actingProfileId ?? bill.profileId ?? 0,
            isAccessCurrent: access,
            write: true);
      }
      current.calendarEventId = eventId;
      await _putBillRecorded(current);
      if (!access()) throw const MedicalReceiptException('accessChanged');
    });
  }

  Future<void> _clearReminder(MedicalBill bill) async {
    var cleared = false;
    await _isar.writeTxn(() async {
      final current = await _isar.medicalBills.get(bill.id);
      if (current?.followUpDate == null) {
        return;
      }
      current!.followUpDate = null;
      await _putBillRecorded(current);
      cleared = true;
    });
    if (cleared) {
      await ReminderNotificationService().cancelReminder(bill.id);
    }
  }

  /// Deletes the bill, its linked expense and any reimbursement.
  ///
  /// T5 — a bill carrying a reimbursement MUST NOT have that reimbursement
  /// deleted silently, because it removes money from a closed month's history.
  /// Throws [ReimbursedBillDeletionException] unless [force] is set, so the
  /// caller has to warn the user first.
  Future<void> deleteBill(int billId, {bool force = false}) async {
    AppLogger.medicalRepo('DELETE_BILL_START id=$billId force=$force');
    final bill = await _isar.medicalBills.get(billId);
    if (bill == null) {
      AppLogger.medicalRepo('DELETE_BILL_NOT_FOUND id=$billId');
      return;
    }

    AppLogger.medicalRepo(
        'DELETE_BILL_EXISTING id=${bill.id} profileId=${bill.profileId} sharedSpaceId=${bill.sharedSpaceId} yearMonth=${bill.yearMonth} linkedExpenseId=${bill.linkedExpenseId} reimbursedAmount=${bill.reimbursedAmount}');
    await _guardWrite(bill.sharedSpaceId, bill.yearMonth);

    if (!force && bill.reimbursedAmount > 0) {
      throw ReimbursedBillDeletionException(billId, bill.reimbursedAmount);
    }

    await _isar.writeTxn(() async {
      await _ordinaryEditAllowed(bill, deleting: true);
      await _clearReimbursementFor(bill);
      final expenseId = bill.linkedExpenseId;
      if (expenseId != null) {
        final expense = await _isar.expenses.get(expenseId);
        await AuditRepository(_isar,
                recorder: _syncRecorder, actorId: _actingProfileId)
            .remove(_isar.expenses, expenseId, type: 'Expense');
        if (expense != null) {
          await _syncRecorder?.recordExpenseRemoved(expense);
        }
      }
      await AuditRepository(_isar,
              recorder: _syncRecorder, actorId: _actingProfileId)
          .remove(_isar.medicalBills, billId, type: 'MedicalBill');
      await _syncRecorder?.recordMedicalBillRemoved(bill);
    });

    await ReminderNotificationService().cancelReminder(billId);
    AppLogger.medicalRepo('DELETE_BILL_DONE id=$billId');
  }

  // ---------------------------------------------------------------------------
  // Service types (FR-039, FR-040)
  // ---------------------------------------------------------------------------

  /// Service types available for new bills: not archived, in display order.
  Stream<List<MedicalServiceType>> watchServiceTypes(int profileId) {
    return _isar.medicalServiceTypes
        .filter()
        .profileIdEqualTo(profileId)
        .sortBySortOrder()
        .thenByName()
        .watch(fireImmediately: true);
  }

  /// Context-scoped variant for `watchServiceTypes` (R3, data-model §3.6).
  Stream<List<MedicalServiceType>> watchServiceTypesForContext(
      ContextRef context) {
    return _isar.medicalServiceTypes
        .filter()
        .group((q) => context.isShared
            ? q.sharedSpaceIdEqualTo(context.spaceId)
            : q
                .profileIdEqualTo(context.profileKey)
                .and()
                .sharedSpaceIdIsNull())
        .sortBySortOrder()
        .thenByName()
        .watch(fireImmediately: true);
  }

  /// The types still offered in the picker (FR-040).
  ///
  /// Archived types stay in the database so historical bills keep their label,
  /// but they must not clutter the list of new choices.
  Future<List<MedicalServiceType>> getServiceTypes(int profileId) {
    return _isar.medicalServiceTypes
        .filter()
        .profileIdEqualTo(profileId)
        .archivedEqualTo(false)
        .sortBySortOrder()
        .thenByName()
        .findAll();
  }

  /// Every type including archived ones, for rendering historical bills (FR-040).
  Future<List<MedicalServiceType>> getAllServiceTypes(int profileId) {
    return _isar.medicalServiceTypes
        .filter()
        .profileIdEqualTo(profileId)
        .sortBySortOrder()
        .thenByName()
        .findAll();
  }

  /// Seeds the six default service types when [profileId] has none (FR-039).
  ///
  /// Migration step 0 only runs for profiles that predate the schema bump, so a
  /// profile created at runtime (first-run onboarding) would otherwise start
  /// with an empty picker. Same rule as that step: seed only when the profile
  /// has no types at all, so a user who curated their own list is never
  /// re-seeded.
  ///
  /// Pass [sharedSpaceId] to seed a **shared space** instead: the rows carry the
  /// space key (`profileId == 0`, FR-013) and are journalised so the peer
  /// receives them. Seeding happens once, on the device that creates the space.
  Future<void> ensureDefaultServiceTypes(
    int profileId, {
    int? sharedSpaceId,
  }) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.medicalServiceTypes
          .filter()
          .group((q) => sharedSpaceId == null
              ? q.profileIdEqualTo(profileId).sharedSpaceIdIsNull()
              : q.sharedSpaceIdEqualTo(sharedSpaceId))
          .count();
      if (existing > 0) return;
      final seed = MedicalServiceTypeDefaults.seed(
          _directoryProfileId(profileId, sharedSpaceId));
      for (final type in seed) {
        type.sharedSpaceId = sharedSpaceId;
      }
      await _isar.medicalServiceTypes.putAll(seed);
      for (final type in seed) {
        await _syncRecorder?.recordMedicalServiceType(type);
      }
    });
  }

  /// Seeds the six default service types for a shared space (FR-039, FR-013).
  ///
  /// Called once by the device that creates the space; the change-log carries
  /// them to the peer, so two phones never seed a space twice.
  Future<void> ensureDefaultServiceTypesForSpace(int spaceId) =>
      ensureDefaultServiceTypes(0, sharedSpaceId: spaceId);

  /// Creates or renames a service type, rejecting a name that already exists in
  /// the same context regardless of case (FR-040, FR-013).
  ///
  /// [sharedSpaceId] routes the row into that shared space; without it the row
  /// is personal and keyed by [profileId].
  Future<MedicalServiceType> saveServiceType({
    int? id,
    required int profileId,
    int? sharedSpaceId,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'cannot be empty');
    }

    final siblings = await _isar.medicalServiceTypes
        .filter()
        .group((q) => sharedSpaceId == null
            ? q.profileIdEqualTo(profileId)
            : q.sharedSpaceIdEqualTo(sharedSpaceId))
        .findAll();

    for (final type in siblings) {
      if (type.id != id &&
          type.name.trim().toLowerCase() == trimmed.toLowerCase()) {
        throw DuplicateServiceTypeException(trimmed);
      }
    }

    final target = id == null
        ? MedicalServiceType()
        : siblings.firstWhere(
            (t) => t.id == id,
            orElse: () => MedicalServiceType(),
          );

    if (id == null) {
      target.sortOrder = siblings.length;
    }
    target
      ..id = id ?? target.id
      ..profileId = _directoryProfileId(profileId, sharedSpaceId)
      ..sharedSpaceId = sharedSpaceId
      ..name = trimmed
      // Renaming a seeded type keeps its seeded status; only an unseeded type
      // loses it.
      ..archived = false;

    await _isar.writeTxn(() async {
      await isarPutServiceType(target);
      await _syncRecorder?.recordMedicalServiceType(target);
    });
    return target;
  }

  Future<void> isarPutServiceType(MedicalServiceType type) =>
      _isar.medicalServiceTypes.put(type);

  /// Archives a type instead of deleting it, so historical bills keep a readable
  /// reference (FR-040, R10).
  Future<void> archiveServiceType(int id) async {
    final type = await _isar.medicalServiceTypes.get(id);
    if (type == null) return;
    type.archived = true;
    await _isar.writeTxn(() async {
      await _isar.medicalServiceTypes.put(type);
      await _syncRecorder?.recordMedicalServiceType(type);
    });
  }

  /// Archives or restores a type (FR-040).
  ///
  /// Archived types leave the picker but stay in the database so historical bills
  /// keep a readable label; restoring puts one back in the picker.
  Future<void> setServiceTypeArchived(int id, {required bool archived}) async {
    final type = await _isar.medicalServiceTypes.get(id);
    if (type == null) return;
    type.archived = archived;
    await _isar.writeTxn(() async {
      await _isar.medicalServiceTypes.put(type);
      await _syncRecorder?.recordMedicalServiceType(type);
    });
  }

  // ---------------------------------------------------------------------------
  // Insurance profile + directories
  // ---------------------------------------------------------------------------

  /// Creates or updates the insurance plan for the context the row belongs to.
  ///
  /// [sharedSpaceId] routes the row into that shared space (FR-013): a shared
  /// plan is keyed on the space (`profileId == 0`) and never on a personal
  /// profile, so saving inside a space can neither hide the plan from the space
  /// nor overwrite the personal one. Without it the row stays personal and keeps
  /// the profile key it already carries.
  Future<void> saveInsuranceProfile(
    InsuranceProfile profile, {
    int? sharedSpaceId,
  }) async {
    profile
      ..sharedSpaceId = sharedSpaceId
      ..profileId = sharedSpaceId == null ? profile.profileId : 0;
    await _isar.writeTxn(() async {
      await _isar.insuranceProfiles.put(profile);
      await _syncRecorder?.recordInsuranceProfile(profile);
    });
  }

  /// Creates or updates a family member (FR-008).
  ///
  /// [sharedSpaceId] routes the row into that shared space (FR-013); without it
  /// the row is personal and keyed by [profileId].
  Future<FamilyMember> saveFamilyMember({
    int? id,
    required int profileId,
    int? sharedSpaceId,
    required String name,
    required String relation,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'cannot be empty');
    }
    final existing = id == null ? null : await _isar.familyMembers.get(id);
    final member = existing ?? FamilyMember();
    member
      ..id = id ?? member.id
      ..profileId = _directoryProfileId(profileId, sharedSpaceId)
      ..sharedSpaceId = sharedSpaceId
      ..name = name.trim()
      ..relation = relation.trim();

    await _isar.writeTxn(() async {
      await _isar.familyMembers.put(member);
      await _syncRecorder?.recordFamilyMember(member);
    });
    return member;
  }

  Future<void> deleteFamilyMember(int id) async {
    final member = await _isar.familyMembers.get(id);
    await _isar.writeTxn(() async {
      await _isar.familyMembers.delete(id);
      if (member != null) {
        await _syncRecorder?.recordFamilyMemberRemoved(member);
      }
    });
  }

  /// Creates or updates a provider, de-duplicating on (case-insensitive) name
  /// so the directory does not fill with near-identical entries (FR-008).
  ///
  /// [sharedSpaceId] routes the row into that shared space (FR-013); without it
  /// the row is personal and keyed by [profileId].
  Future<MedicalProvider> saveProvider({
    int? id,
    required int profileId,
    int? sharedSpaceId,
    required String name,
    String? specialty,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'cannot be empty');
    }

    final siblings = await _isar.medicalProviders
        .filter()
        .group((q) => sharedSpaceId == null
            ? q.profileIdEqualTo(profileId)
            : q.sharedSpaceIdEqualTo(sharedSpaceId))
        .findAll();

    MedicalProvider? duplicate;
    for (final p in siblings) {
      if (p.id != id && p.name.trim().toLowerCase() == trimmed.toLowerCase()) {
        duplicate = p;
        break;
      }
    }

    final target = duplicate ??
        (id == null ? null : await _isar.medicalProviders.get(id)) ??
        MedicalProvider();
    target
      ..id = duplicate?.id ?? id ?? target.id
      ..profileId = _directoryProfileId(profileId, sharedSpaceId)
      ..sharedSpaceId = sharedSpaceId
      ..name = trimmed
      ..specialty = (specialty == null || specialty.trim().isEmpty)
          ? null
          : specialty.trim()
      ..autoCreated = false;

    await _isar.writeTxn(() async {
      await _isar.medicalProviders.put(target);
      await _syncRecorder?.recordMedicalProvider(target);
    });
    return target;
  }

  /// Returns the provider matching [name] for [profileId], creating a
  /// placeholder entry when it is new. Used when a bill is saved with a typed
  /// provider name instead of a directory pick.
  ///
  /// Mirrors [saveProvider]'s context: pass [sharedSpaceId] to keep the row in
  /// the shared space the bill was written from (FR-013).
  Future<MedicalProvider> findOrCreateProvider({
    required int profileId,
    int? sharedSpaceId,
    required String name,
    String? specialty,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'cannot be empty');
    }
    final existing = await _isar.medicalProviders
        .filter()
        .group((q) => sharedSpaceId == null
            ? q.profileIdEqualTo(profileId)
            : q.sharedSpaceIdEqualTo(sharedSpaceId))
        .findAll();
    for (final p in existing) {
      if (p.name.trim().toLowerCase() == trimmed.toLowerCase()) return p;
    }
    final created = MedicalProvider()
      ..profileId = _directoryProfileId(profileId, sharedSpaceId)
      ..sharedSpaceId = sharedSpaceId
      ..name = trimmed
      ..specialty = (specialty == null || specialty.trim().isEmpty)
          ? null
          : specialty.trim()
      ..autoCreated = true;
    await _isar.writeTxn(() async {
      await _isar.medicalProviders.put(created);
      await _syncRecorder?.recordMedicalProvider(created);
    });
    return created;
  }

  Future<void> deleteProvider(int id) async {
    final provider = await _isar.medicalProviders.get(id);
    await _isar.writeTxn(() async {
      await _isar.medicalProviders.delete(id);
      if (provider != null) {
        await _syncRecorder?.recordMedicalProviderRemoved(provider);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// The `profileId` a directory row carries: a shared row keys on the space, so
  /// its profile key is `0` — exactly how `MonthMoveOperations` re-homes
  /// directory rows and how the peer's applier stores them (FR-013).
  static int _directoryProfileId(int profileId, int? sharedSpaceId) =>
      sharedSpaceId == null ? profileId : 0;

  /// Pre-loaded so callers cannot fail the common case of a profile-less legacy
  /// row.
  static InsuranceProfile? _pickProfile(
    List<InsuranceProfile> rows,
    int profileId,
  ) {
    if (rows.isEmpty) return null;
    for (final row in rows) {
      if (row.profileId == profileId) return row;
    }
    return rows.first;
  }

  void _validateBill(MedicalBill bill) {
    if (bill.billedAmount <= 0) {
      throw ArgumentError.value(
        bill.billedAmount,
        'billedAmount',
        'must be greater than zero',
      );
    }
    if (bill.patientSharePercent < 0 || bill.patientSharePercent > 100) {
      throw ArgumentError.value(
        bill.patientSharePercent,
        'patientSharePercent',
        'must be between 0 and 100',
      );
    }
    // D2 — there is no reimbursement to claim on an insurer-paid bill, so an
    // insurer reply document cannot apply to one (FR-047).
    if (bill.insurerReplyPath != null &&
        bill.insurerReplyPath!.trim().isNotEmpty &&
        bill.paymentMethod == MedicalPaymentMethod.insurerPaid) {
      throw const InvalidDocumentException(
        'An insurer reply only applies to a self-paid bill. An insurer-paid '
        'bill is settled directly with the provider.',
      );
    }
    // T2 — mirrored here so a bill can never be constructed in an illegal state.
    _validateTransition(bill, bill.state);
  }

  /// Resolves the owning month and mirrors it onto the linked expense, inside the
  /// caller's transaction (FR-055, O2).
  ///
  /// Precedence, highest first:
  ///  1. a year-month already on the bill (an explicit user override),
  ///  2. the service date,
  ///  3. the month of the expense being written.
  ///
  /// The bill and its expense are written together, so they can never disagree
  /// about which month they belong to.
  void _applyOwningMonth(MedicalBill bill, String expenseYearMonth) {
    final serviceDate = bill.serviceDate;
    if (bill.yearMonth.isNotEmpty) return;
    bill.yearMonth =
        serviceDate == null ? expenseYearMonth : _yearMonthOf(serviceDate);
  }

  /// Persists a bill and appends its signed change if the context is shared
  /// (FR-006). Every bill write funnels through here so nothing is missed.
  Future<void> _putBillRecorded(MedicalBill bill) async {
    await AuditRepository(_isar,
            recorder: _syncRecorder, actorId: _actingProfileId)
        .put(_isar.medicalBills, bill, id: bill.id, type: 'MedicalBill');
    await _syncRecorder?.recordMedicalBill(bill);
  }

  /// Creates or refreshes the linked expense inside the caller's transaction.
  ///
  /// `Expense.amount` is set from [MedicalBill.fundsImpact], which *is* the
  /// money-impact table, so the bill and the budget can never disagree about
  /// what a bill cost (R07). M2 — the reduction is applied here, at entry, not
  /// deferred to a month-end event.
  Future<Expense> _syncLinkedExpense(
    MedicalBill bill,
    MedicalBillContext context, {
    ExpenseStatus? status,
    DateTime? paymentDate,
    bool preservePaymentDate = false,
  }) async {
    final providerName = await _providerNameFor(bill.providerId);
    final title = providerName ?? 'Medical Bill';

    final stored = bill.linkedExpenseId == null
        ? null
        : await _isar.expenses.get(bill.linkedExpenseId!);

    // O1 — the service month owns the bill, not the month it happened to be
    // entered in.
    final yearMonth =
        bill.yearMonth.isNotEmpty ? bill.yearMonth : context.yearMonth;
    _applyOwningMonth(bill, yearMonth);

    final expense = stored ??
        Expense(
          profileId: context.profileId,
          sharedSpaceId: context.sharedSpaceId,
          yearMonth: bill.yearMonth,
          title: title,
          amount: bill.fundsImpact,
          currency: context.primaryCurrency,
          categoryId: medicalCategoryId,
          date: bill.serviceDate ?? DateTime.now(),
          budgetId: context.budgetId,
        );

    expense
      ..profileId = context.profileId
      ..sharedSpaceId = context.sharedSpaceId
      // O2 — mirrored in the same transaction, never independently derived.
      ..yearMonth = bill.yearMonth
      ..budgetId = context.budgetId
      ..title = title
      // R-007 — the expense amount *is* the money impact.
      ..amount = bill.fundsImpact
      // Medical bills are tracked in the bill's own currency when it records
      // one, otherwise the budget's primary currency (FR-016).
      ..currency =
          bill.currency.isEmpty ? context.primaryCurrency : bill.currency
      ..categoryId = medicalCategoryId
      ..type = ExpenseType.medical
      // R-1 — only a self-paid bill can be reimbursed, so only a self-paid bill
      // offers the user a reimbursement.
      ..isReimbursable = bill.canBeReimbursed
      // M4 — a planned bill belongs to the planned pool, never to payments.
      // Derived from the bill's state rather than inherited from the stored row,
      // otherwise moving back to `planned` would leave the expense still paid.
      // Medical bills never write partial-reimbursement states; those remain
      // read-only history from older releases.
      ..status = switch (status ??
          (bill.state == MedicalBillState.planned
              ? ExpenseStatus.planned
              : ExpenseStatus.paid)) {
        ExpenseStatus.partiallyReimbursed ||
        ExpenseStatus.reimbursed =>
          ExpenseStatus.paid,
        final value => value,
      }
      ..date = bill.serviceDate ?? DateTime.now()
      ..notes = _notesFor(bill);

    if (expense.status == ExpenseStatus.paid) {
      expense.paidAt = paymentDate?.toUtc() ??
          expense.paidAt ??
          (preservePaymentDate ? null : DateTime.now());
    } else {
      expense.paidAt = null;
    }

    await AuditRepository(_isar,
            recorder: _syncRecorder, actorId: _actingProfileId)
        .put(_isar.expenses, expense, id: expense.id, type: 'Expense');
    await _syncRecorder?.recordExpense(expense);
    return expense;
  }

  /// Human-readable provenance shown on the linked expense.
  static String _notesFor(MedicalBill bill) {
    if (bill.paymentMethod == MedicalPaymentMethod.selfPaid) {
      return 'Self-paid';
    }
    return '${bill.patientSharePercent.toStringAsFixed(0)}% your share';
  }

  /// Provisions an unconfirmed `MonthlyBudget` row for [bill]'s owning month when
  /// none exists, so a bill can never be saved into a month that cannot later be
  /// reconciled. Never marks a month confirmed and never invents an opening
  /// balance (A2, improvements plan). Idempotent: reuses an existing row.
  Future<void> _ensureBillMonth(
      MedicalBill bill, MedicalBillContext context) async {
    if (bill.yearMonth.isEmpty) return;
    final isShared = context.sharedSpaceId != null;
    final rows = await _isar.monthlyBudgets
        .filter()
        .yearMonthEqualTo(bill.yearMonth)
        .findAll();
    final owned = rows.firstWhere(
      (m) => isShared
          ? m.sharedSpaceId == context.sharedSpaceId
          : (m.profileId == context.profileId && m.sharedSpaceId == null),
      orElse: () => MonthlyBudget()
        ..profileId = isShared ? null : context.profileId
        ..sharedSpaceId = isShared ? context.sharedSpaceId : null
        ..yearMonth = bill.yearMonth
        ..baseAvailableAmount = 0
        ..openingBalanceConfirmed = false
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now(),
    );
    final alreadyExists = rows.any((m) => isShared
        ? m.sharedSpaceId == context.sharedSpaceId
        : (m.profileId == context.profileId && m.sharedSpaceId == null));
    if (!alreadyExists) {
      await AuditRepository(_isar,
              recorder: _syncRecorder, actorId: _actingProfileId)
          .put(_isar.monthlyBudgets, owned,
              id: owned.id, type: 'MonthlyBudget');
    }
  }

  /// Read-only receipt-readiness blockers for [bill]'s owning month, used by the
  /// detail screen to surface month setup problems before the user is asked for
  /// a reason (A1, improvements plan). Propagates failures instead of treating
  /// access/actor problems so the UI can keep readiness unknown.
  Future<List<ReceiptBlocker>> monthBlockersFor(MedicalBill bill) async {
    final actor = _actingProfileId ?? bill.profileId ?? 0;
    if (actor <= 0 || bill.yearMonth.isEmpty) {
      throw const MedicalReceiptException('accessChanged');
    }
    final isShared = bill.sharedSpaceId != null;
    final context = isShared
        ? ContextRef.shared(
            spaceId: bill.sharedSpaceId!, yearMonth: bill.yearMonth)
        : ContextRef.personal(
            profileId: bill.profileId!, yearMonth: bill.yearMonth);
    final snap = await ReceiptSnapshotRepository(_isar)
        .read(context: context, actorId: actor, isAccessCurrent: () => true);
    return snap.blockers;
  }

  /// Rebuilds the context needed to re-sync a bill's expense when only the bill
  /// is in hand, by reading the month back off its own linked expense.
  Future<MedicalBillContext?> _contextForExistingBill(MedicalBill bill) async {
    final expenseId = bill.linkedExpenseId;
    if (expenseId == null) return null;
    final expense = await _isar.expenses.get(expenseId);
    if (expense == null) return null;
    return MedicalBillContext(
      profileId: expense.profileId,
      sharedSpaceId: expense.sharedSpaceId,
      budgetId: expense.budgetId,
      yearMonth: expense.yearMonth,
      primaryCurrency: expense.currency,
      rateTable: _rateRegistry?.tableFor(expense.yearMonth),
    );
  }

  Future<String?> _providerNameFor(int? providerId) async {
    if (providerId == null) return null;
    final provider = await _isar.medicalProviders.get(providerId);
    if (provider == null || provider.name.trim().isEmpty) return null;
    return provider.name.trim();
  }

  Future<void> _clearReimbursementFor(MedicalBill bill) async {
    final expenseId = bill.linkedExpenseId;
    if (expenseId == null) return;
    final rows = await _isar.reimbursements
        .filter()
        .expenseIdEqualTo(expenseId)
        .findAll();
    if (rows.isEmpty) return;
    if (rows.any((r) => r.medicalReceiptJson != null)) {
      throw const MedicalReceiptException('useIncomeSources');
    }
    await _isar.reimbursements.deleteAll(rows.map((r) => r.id).toList());
    for (final row in rows) {
      await _syncRecorder?.recordReimbursementRemoved(row);
    }
  }
}

/// `YYYY-MM` for a date, used for month attribution (FR-055).
String _yearMonthOf(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}';

/// `YYYY-MM` for a date offset by [months] from [from].
String shiftYearMonth(DateTime from, int months) =>
    _yearMonthOf(DateTime(from.year, from.month + months));
