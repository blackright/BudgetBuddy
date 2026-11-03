import 'medical_bill_basis.dart';
import '../models/currency_code.dart';
import 'dart:convert';
import '../logging/app_logger.dart';
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/medical_bill.dart';
import '../models/medical_approval.dart';
import '../models/medical_settlement_event.dart';
import '../models/medical_withholding_match.dart';
import '../models/reconciliation_snapshot.dart';
import '../models/money_receipt.dart';
import '../models/expense.dart';
import '../models/financial_adoption.dart';
import '../models/balance_checkpoint.dart';
import '../models/fx_revision.dart';
import '../models/shared_member.dart';
import '../models/user_profile.dart';
import '../providers/budget_context_provider.dart';
import '../../features/expenses/models/reimbursement.dart';
import '../../features/finance/repositories/audit_repository.dart';
import '../../features/spaces/repositories/space_write_guard.dart';
import '../../features/sync/repositories/sync_recorder.dart';
import '../../features/sync/domain/sync_guid.dart';
import 'balance_checkpoint_service.dart';
import 'receipt_snapshot_repository.dart';
import 'fx_booking_service.dart';
import 'medical_receipt_booking_service.dart';

export 'medical_receipt_booking_service.dart' show MedicalReceiptException;

/// Consistent read-only source for the Phase A presentation provider. Per-bill
/// corrupt evidence is retained as a review issue; access failure aborts the read.
class MedicalHistoryBatch {
  MedicalHistoryBatch(
      {required Iterable<MedicalBill> bills,
      required Map<int, MedicalReceiptHistory> histories,
      required Map<int, String> issues,
      required List<ReceiptBlocker>? blockers,
      Map<int, List<ReceiptBlocker>?> blockersByBill = const {}})
      : bills = List.unmodifiable(bills),
        histories = Map.unmodifiable(histories),
        issues = Map.unmodifiable(issues),
        blockers = blockers == null ? null : List.unmodifiable(blockers),
        blockersByBill = Map.unmodifiable(blockersByBill);
  final List<MedicalBill> bills;
  final Map<int, MedicalReceiptHistory> histories;
  final Map<int, String> issues;

  /// Null means readiness was not established, never an empty/ready result.
  final List<ReceiptBlocker>? blockers;

  /// Per-bill readiness for cross-month reads. A present null value means that
  /// bill's month readiness could not be established.
  final Map<int, List<ReceiptBlocker>?> blockersByBill;
}

class MedicalReceiptHistory {
  MedicalReceiptHistory(
      {required this.bill,
      required this.expense,
      required this.approvals,
      required this.returns,
      required this.revisions,
      required this.receivedMinor,
      required this.closure,
      this.activities = const [],
      this.settlements = const [],
      this.withholdingMatches = const []});
  final MedicalBill bill;
  final Expense expense;
  final List<MedicalApproval> approvals;
  final List<Reimbursement> returns;
  final List<ReceiptRevision> revisions;
  final int receivedMinor;
  final MedicalClaimClosure? closure;
  final List<MedicalClaimActivity> activities;
  final List<MedicalSettlementEvent> settlements;
  final List<MedicalWithholdingMatch> withholdingMatches;
  bool get cancelled => activities.any((a) => a.kind == 'cancelled');
  bool get enteredInError => activities.any((a) => a.kind == 'removed');
  bool get submitted => activities.any((a) => a.kind == 'submitted');
  bool get approvalNeedsReview =>
      approval != null &&
      ((approval!.approvedMinor == 0 &&
              !activities.any((a) =>
                  a.kind == 'noRefundDecision' &&
                  a.approvalGuid == approval!.syncGuid &&
                  a.reason.trim().isNotEmpty)) ||
          (approval!.basisJson != null &&
              approval!.basisJson != medicalBillBasis(bill)) ||
          activities.any((a) =>
              a.kind == 'corrected' && a.approvalGuid == approval!.syncGuid));
  String get paymentLabel =>
      enteredInError || expense.status == ExpenseStatus.cancelled
          ? 'Entered in error'
          : fxPaid(expense.status)
              ? 'Paid to provider'
              : 'Planned';
  String get claimLabel => enteredInError
      ? 'Bill entered in error'
      : cancelled
          ? 'Cancelled'
          : bill.reimbursedAmount > receivedMinor
              ? 'Legacy payment needs review'
              : approvalNeedsReview
                  ? 'Approval needs review'
                  : closure != null
                      ? 'Claim closed'
                      : approval != null
                          ? remainingMinor == 0
                              ? 'Received'
                              : receivedMinor > 0
                                  ? 'Partly received'
                                  : 'Approved - waiting for payment'
                          : receivedMinor > 0
                              ? 'Legacy payment recorded'
                              : submitted
                                  ? 'Awaiting decision'
                                  : activities.any((a) => a.kind == 'created')
                                      ? 'Not submitted'
                                      : 'Submission not recorded';

  MedicalApproval? get approval => approvals.firstOrNull;
  int get remainingMinor =>
      ((approval?.approvedMinor ?? 0) - receivedMinor).clamp(0, fxMoneyBound);
  int get shortfallMinor => closure?.shortfallMinor ?? 0;
}

/// Source-bound metadata-only closure; money is never recorded by closing.
class MedicalClosePreview {
  const MedicalClosePreview._(
      this.billId,
      this.actorId,
      this.approvalGuid,
      this.currency,
      this.paidMinor,
      this.receivedMinor,
      this.missingMinor,
      this.finalCostMinor,
      this.fingerprint);
  final int billId,
      actorId,
      paidMinor,
      receivedMinor,
      missingMinor,
      finalCostMinor;
  final String approvalGuid, currency, fingerprint;
}

class MedicalReceiptPreview {
  MedicalReceiptPreview._(
      {required this.history,
      required this.actorId,
      required this.evidence,
      required this.fingerprint,
      required this.months,
      required this.alreadyIncluded});
  final MedicalReceiptHistory history;
  final int actorId;
  final MedicalReceiptEvidence evidence;
  final String fingerprint;
  final List<ReceiptSourceSnapshot> months;
  final bool alreadyIncluded;
}

class MedicalReceiptCorrection {
  MedicalReceiptCorrection._(this.history, this.actorId, this.replacements,
      this.reason, this.fingerprint, this.targetReceiptGuid);
  final MedicalReceiptHistory history;
  final int actorId;
  final Map<int, MedicalReceiptEvidence> replacements;
  final String reason, fingerprint, targetReceiptGuid;
}

/// Approval is independently usable. Receipt posting is a caller-owned
/// transaction command for the later Income Sources coordinator, not another
/// public money-entry screen or a policy activation switch.
class MedicalReceiptService {
  MedicalReceiptService(this.db, {this.recorder, DateTime Function()? clock})
      : clock = clock ?? DateTime.now;
  final Isar db;
  final SyncRecorder? recorder;
  final DateTime Function() clock;
  static String _hash(Object value) =>
      sha256.convert(utf8.encode(jsonEncode(value))).toString();
  static String _month(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

  Future<void> closeClaim(
      {required int billId,
      required int actorId,
      required String reason,
      required bool Function() isAccessCurrent}) async {
    final original = await history(
        billId: billId, actorId: actorId, isAccessCurrent: isAccessCurrent);
    if (original.bill.sharedSpaceId != null) {
      if (reason.trim().isEmpty || reason.trim().length > 240) {
        throw const MedicalReceiptException('correctionReasonRequired');
      }
      await db.writeTxn(() async {
        final h = await _history(billId, actorId, isAccessCurrent, write: true);
        if (h.closure != null) {
          throw const MedicalReceiptException('claimClosed');
        }
        if (h.approval == null) {
          throw const MedicalReceiptException('approvalNeedsReview');
        }
        if (h.remainingMinor > 0) {
          throw const MedicalReceiptException('moneyStillMissing');
        }
        final closure = MedicalClaimClosure()
          ..billGuid = h.bill.syncGuid
          ..approvalGuid = h.approval!.syncGuid
          ..profileId = h.bill.profileId
          ..sharedSpaceId = h.bill.sharedSpaceId
          ..yearMonth = _month(h.approval!.decisionDate)
          ..receivedMinor = h.receivedMinor
          ..shortfallMinor = 0
          ..currency = h.expense.currency
          ..reason = reason.trim()
          ..actorId = actorId
          ..recordedAt = clock().toUtc()
          ..operationIdentity = 'shared-close:${h.bill.syncGuid}:${_hash([
                h.approval!.syncGuid,
                reason.trim()
              ])}';
        await AuditRepository(db, recorder: recorder, actorId: actorId).put(
            db.medicalClaimClosures, closure,
            id: closure.id, type: 'MedicalClaimClosure', derived: false);
        if (!isAccessCurrent()) {
          throw const MedicalReceiptException('accessChanged');
        }
      });
      return;
    }
    final preview = await previewClose(
        billId: billId, actorId: actorId, isAccessCurrent: isAccessCurrent);
    await confirmClose(
        preview: preview,
        reason: reason,
        operationKey: 'legacy-${_hash([preview.fingerprint, reason])}',
        isAccessCurrent: isAccessCurrent);
  }

  Future<MedicalClosePreview> previewClose(
          {required int billId,
          required int actorId,
          required bool Function() isAccessCurrent}) =>
      db.txn(() => _closePreview(billId, actorId, isAccessCurrent));

  Future<MedicalClosePreview> _closePreview(
      int billId, int actorId, bool Function() access) async {
    final h = await _history(billId, actorId, access, write: true);
    if (h.bill.sharedSpaceId != null ||
        !h.bill.canBeReimbursed ||
        h.cancelled ||
        h.enteredInError ||
        !fxPaid(h.expense.status) ||
        h.expense.currencyCode == null ||
        h.approval == null ||
        h.approvalNeedsReview ||
        h.bill.reimbursedAmount > h.receivedMinor ||
        h.expense.amount != h.bill.billedAmount ||
        h.closure != null) {
      throw const MedicalReceiptException('closureNeedsReview');
    }
    if (h.remainingMinor > 0) {
      throw const MedicalReceiptException('moneyStillMissing');
    }
    final fingerprint = _hash([
      medicalBillBasis(h.bill),
      h.bill.state.name,
      h.expense.status.name,
      h.expense.paidAt?.toUtc().toIso8601String(),
      h.expense.fxHistoryJson,
      h.approval!.syncGuid,
      h.approval!.inputFingerprint,
      h.receivedMinor,
      h.returns
          .map((r) => [r.syncGuid, r.medicalReceiptJson, r.amount])
          .toList(),
      h.activities.map((a) => a.syncGuid).toList()
    ]);
    if (!access()) throw const MedicalReceiptException('accessChanged');
    return MedicalClosePreview._(
        billId,
        actorId,
        h.approval!.syncGuid,
        h.expense.currencyCode!.code,
        h.bill.billedAmount,
        h.receivedMinor,
        h.remainingMinor,
        (h.bill.billedAmount - h.receivedMinor).clamp(0, fxMoneyBound),
        fingerprint);
  }

  Future<void> confirmClose(
          {required MedicalClosePreview preview,
          required String reason,
          required String operationKey,
          required bool Function() isAccessCurrent}) =>
      db.writeTxn(() async {
        if (!isAccessCurrent() ||
            operationKey.trim().isEmpty ||
            operationKey.length > 128 ||
            reason.trim().isEmpty ||
            reason.trim().length > 240) {
          throw const MedicalReceiptException('invalidOperation');
        }
        final bill = await _bill(
            preview.billId, preview.actorId, isAccessCurrent,
            write: true);
        final identity = 'medical-close:${bill.syncGuid}:$operationKey';
        final input = _hash([preview.fingerprint, reason.trim()]);
        final old = await db.medicalClaimActivitys
            .filter()
            .operationIdentityEqualTo(identity)
            .findFirst();
        if (old != null) {
          if (old.profileId != preview.actorId ||
              old.inputFingerprint != input) {
            throw const MedicalReceiptException('duplicateMismatch');
          }
          final saved = await _history(
              preview.billId, preview.actorId, isAccessCurrent,
              write: true);
          if (saved.closure?.operationIdentity != identity ||
              saved.approvalNeedsReview ||
              saved.cancelled ||
              saved.enteredInError ||
              !fxPaid(saved.expense.status)) {
            throw const MedicalReceiptException('closureNeedsReview');
          }
          return;
        }
        final fresh = await _closePreview(
            preview.billId, preview.actorId, isAccessCurrent);
        if (fresh.fingerprint != preview.fingerprint) {
          throw const MedicalReceiptException('stalePreview');
        }
        final now = clock().toUtc();
        final audit =
            AuditRepository(db, recorder: recorder, actorId: preview.actorId);
        final closure = MedicalClaimClosure()
          ..billGuid = bill.syncGuid
          ..approvalGuid = fresh.approvalGuid
          ..profileId = preview.actorId
          ..yearMonth = _month(now)
          ..receivedMinor = fresh.receivedMinor
          ..shortfallMinor = 0
          ..currency = fresh.currency
          ..reason = reason.trim()
          ..actorId = preview.actorId
          ..recordedAt = now
          ..operationIdentity = identity;
        await audit.put(db.medicalClaimClosures, closure,
            id: closure.id, type: 'MedicalClaimClosure', derived: false);
        final activity = MedicalClaimActivity()
          ..billGuid = bill.syncGuid
          ..profileId = preview.actorId
          ..yearMonth = _month(now)
          ..kind = 'closed'
          ..approvalGuid = fresh.approvalGuid
          ..reason = reason.trim()
          ..currency = fresh.currency
          ..recordedAt = now
          ..actorId = preview.actorId
          ..operationIdentity = identity
          ..inputFingerprint = input
          ..afterJson = jsonEncode({
            'basis': medicalBillBasis(bill),
            'receivedMinor': fresh.receivedMinor,
            'shortfallMinor': 0,
            'finalCostMinor': fresh.finalCostMinor
          });
        await audit.put(db.medicalClaimActivitys, activity,
            id: activity.id, type: 'MedicalClaimActivity', derived: false);
        if (!isAccessCurrent()) {
          throw const MedicalReceiptException('accessChanged');
        }
      });

  static bool _validMonth(String month) =>
      RegExp(r'^[1-9][0-9]{3}-(0[1-9]|1[0-2])$').hasMatch(month);

  Future<MedicalBill> _bill(int id, int actor, bool Function() access,
      {bool write = false}) async {
    if (!access() || actor <= 0) {
      throw const MedicalReceiptException('accessChanged');
    }
    final bill = await db.medicalBills.get(id);
    if (bill == null ||
        (bill.profileId == null) == (bill.sharedSpaceId == null) ||
        !_validMonth(bill.yearMonth)) {
      throw const MedicalReceiptException('missingBill');
    }
    if (await db.userProfiles.get(actor) == null) {
      throw const MedicalReceiptException('accessChanged');
    }
    if (bill.sharedSpaceId == null) {
      if (bill.profileId != actor) {
        throw const MedicalReceiptException('wrongOwner');
      }
    } else {
      final member =
          await SpaceWriteGuard(db).memberOf(bill.sharedSpaceId!, actor);
      if (member == null ||
          member.revokedAt != null ||
          (write && member.role == SharedMemberRole.viewer)) {
        throw const MedicalReceiptException('notPermitted');
      }
    }
    if (!access()) throw const MedicalReceiptException('accessChanged');
    return bill;
  }

  Future<MedicalReceiptHistory> history(
          {required int billId,
          required int actorId,
          required bool Function() isAccessCurrent}) =>
      db.txn(() => _history(billId, actorId, isAccessCurrent));

  /// Loads the selected owner/month in one read transaction. Query count is
  /// bounded by collections, not by the number of bill cards. Reuses exactly
  /// the validation used by the existing single-bill financial service reads.
  Future<MedicalHistoryBatch> historyBatch({
    required ContextRef context,
    required int actorId,
    required bool Function() isAccessCurrent,
  }) =>
      db.txn(() async {
        await _validateBatchAccess(context, actorId, isAccessCurrent);
        final bills = await _billsForMonth(context);
        // Failure propagates to AsyncError; it cannot become empty/ready blockers.
        final blockers = (await ReceiptSnapshotRepository(db).readInTransaction(
                context: context,
                actorId: actorId,
                isAccessCurrent: isAccessCurrent))
            .blockers;
        return _assembleBatch(
            context: context,
            actorId: actorId,
            isAccessCurrent: isAccessCurrent,
            bills: bills,
            blockers: blockers);
      });

  /// Owner-scoped, cross-month batch for the Medical action inbox.
  ///
  /// Readiness stays tied to each bill's own service month, so an old bill never
  /// inherits the selected budget month's setup state. The read is still one
  /// transaction and one bulk join; no query runs per card.
  Future<MedicalHistoryBatch> historyInboxBatch({
    required ContextRef context,
    required int actorId,
    required bool Function() isAccessCurrent,
  }) =>
      db.txn(() async {
        await _validateBatchAccess(context, actorId, isAccessCurrent);
        final bills = await _billsForOwner(context);
        final blockersByBill = <int, List<ReceiptBlocker>?>{};
        for (final month in bills.map((b) => b.yearMonth).toSet()) {
          final monthContext = context.isShared
              ? ContextRef.shared(spaceId: context.spaceId!, yearMonth: month)
              : ContextRef.personal(
                  profileId: context.profileId!, yearMonth: month);
          try {
            final blockers = (await ReceiptSnapshotRepository(db)
                    .readInTransaction(
                        context: monthContext,
                        actorId: actorId,
                        isAccessCurrent: isAccessCurrent))
                .blockers;
            for (final bill in bills.where((b) => b.yearMonth == month)) {
              blockersByBill[bill.id] = blockers;
            }
          } on MedicalReceiptException catch (error) {
            if (error.code == 'accessChanged' ||
                error.code == 'wrongOwner' ||
                error.code == 'notPermitted') {
              rethrow;
            }
            for (final bill in bills.where((b) => b.yearMonth == month)) {
              blockersByBill[bill.id] = null;
            }
          } on ReceiptGuardException catch (error) {
            if (error.code == 'accessChanged') rethrow;
            for (final bill in bills.where((b) => b.yearMonth == month)) {
              blockersByBill[bill.id] = null;
            }
          }
        }
        return _assembleBatch(
            context: context,
            actorId: actorId,
            isAccessCurrent: isAccessCurrent,
            bills: bills,
            blockers: null,
            blockersByBill: blockersByBill);
      });

  Future<void> _validateBatchAccess(
      ContextRef context, int actorId, bool Function() access) async {
    if (!access() ||
        actorId <= 0 ||
        await db.userProfiles.get(actorId) == null) {
      throw const MedicalReceiptException('accessChanged');
    }
    if (!_validMonth(context.yearMonth)) {
      throw const MedicalReceiptException('missingBill');
    }
    if (context.isShared) {
      final member =
          await SpaceWriteGuard(db).memberOf(context.spaceId!, actorId);
      if (member == null || member.revokedAt != null) {
        throw const MedicalReceiptException('notPermitted');
      }
    } else if (context.profileId != actorId) {
      throw const MedicalReceiptException('wrongOwner');
    }
  }

  Future<List<MedicalBill>> _billsForMonth(ContextRef context) => db
      .medicalBills
      .filter()
      .group((q) => context.isShared
          ? q.sharedSpaceIdEqualTo(context.spaceId)
          : q.profileIdEqualTo(context.profileKey).and().sharedSpaceIdIsNull())
      .and()
      .yearMonthEqualTo(context.yearMonth)
      .sortByServiceDateDesc()
      .findAll();

  Future<List<MedicalBill>> _billsForOwner(ContextRef context) => db
      .medicalBills
      .filter()
      .group((q) => context.isShared
          ? q.sharedSpaceIdEqualTo(context.spaceId)
          : q.profileIdEqualTo(context.profileKey).and().sharedSpaceIdIsNull())
      .sortByServiceDateDesc()
      .findAll();

  Future<MedicalHistoryBatch> _assembleBatch({
    required ContextRef context,
    required int actorId,
    required bool Function() isAccessCurrent,
    required List<MedicalBill> bills,
    required List<ReceiptBlocker>? blockers,
    Map<int, List<ReceiptBlocker>?> blockersByBill = const {},
  }) async {
    final ids = bills.map((b) => b.linkedExpenseId).whereType<int>().toSet();
    final guids = bills.map((b) => b.syncGuid).toSet();
    if (bills.isEmpty) {
      if (!isAccessCurrent()) {
        throw const MedicalReceiptException('accessChanged');
      }
      return MedicalHistoryBatch(
          bills: bills,
          histories: {},
          issues: {},
          blockers: blockers,
          blockersByBill: blockersByBill);
    }
    final expenseRows = await db.expenses.getAll(ids.toList());
    final expenses = {
      for (final e in expenseRows.whereType<Expense>()) e.id: e
    };
    final linkedBills = ids.isEmpty
        ? <MedicalBill>[]
        : await db.medicalBills
            .filter()
            .anyOf(ids, (q, int id) => q.linkedExpenseIdEqualTo(id))
            .findAll();
    final approvals = await db.medicalApprovals
        .filter()
        .anyOf(guids, (q, String guid) => q.billGuidEqualTo(guid))
        .sortByRevisionDesc()
        .findAll();
    final returns = ids.isEmpty
        ? <Reimbursement>[]
        : await db.reimbursements
            .filter()
            .anyOf(ids, (q, int id) => q.expenseIdEqualTo(id))
            .findAll();
    final revisions = await db.receiptRevisions
        .filter()
        .anyOf(guids, (q, String guid) => q.billGuidEqualTo(guid))
        .sortByRecordedAtDesc()
        .findAll();
    final closures = await db.medicalClaimClosures
        .filter()
        .anyOf(guids, (q, String guid) => q.billGuidEqualTo(guid))
        .findAll();
    final activities = context.isShared
        ? <MedicalClaimActivity>[]
        : await db.medicalClaimActivitys
            .filter()
            .anyOf(guids, (q, String guid) => q.billGuidEqualTo(guid))
            .sortByRecordedAtDesc()
            .findAll();
    final settlementRows = context.isShared
        ? <MedicalSettlementEvent>[]
        : await db.medicalSettlements
            .filter()
            .anyOf(guids, (q, String guid) => q.billGuidEqualTo(guid))
            .findAll();
    final withholdingRows = context.isShared
        ? <MedicalWithholdingMatch>[]
        : await db.medicalWithholdingMatchs
            .filter()
            .anyOf(guids, (q, String guid) => q.billGuidEqualTo(guid))
            .findAll();
    Map<K, List<T>> group<K, T>(Iterable<T> rows, K Function(T) key) {
      final result = <K, List<T>>{};
      for (final row in rows) {
        result.putIfAbsent(key(row), () => []).add(row);
      }
      return result;
    }

    final byExpense = group(linkedBills, (b) => b.linkedExpenseId);
    final decisions = group(approvals, (a) => a.billGuid);
    final refunds = group(returns, (r) => r.expenseId);
    final versions = group(revisions, (r) => r.billGuid);
    final endings = group(closures, (c) => c.billGuid);
    final events = group(activities, (a) => a.billGuid);
    final settlements = group(settlementRows, (s) => s.billGuid);
    final withholdings = group(withholdingRows, (m) => m.billGuid);
    final histories = <int, MedicalReceiptHistory>{};
    final issues = <int, String>{};
    for (final bill in bills) {
      if (!isAccessCurrent()) {
        throw const MedicalReceiptException('accessChanged');
      }
      try {
        if ((bill.profileId == null) == (bill.sharedSpaceId == null)) {
          throw const MedicalReceiptException('missingBill');
        }
        histories[bill.id] = _validatedHistory(
          bill: bill,
          expense: expenses[bill.linkedExpenseId],
          linkCount: byExpense[bill.linkedExpenseId]?.length ?? 0,
          approvals: decisions[bill.syncGuid] ?? [],
          returns: refunds[bill.linkedExpenseId] ?? [],
          revisions: versions[bill.syncGuid] ?? [],
          closure: endings[bill.syncGuid]?.firstOrNull,
          activities: events[bill.syncGuid] ?? [],
          settlements: settlements[bill.syncGuid] ?? [],
          withholdingMatches: (withholdings[bill.syncGuid] ?? [])
              .where((m) => !m.reversed)
              .toList(),
          access: isAccessCurrent,
        );
      } on MedicalReceiptException catch (error) {
        if (error.code == 'accessChanged' ||
            error.code == 'wrongOwner' ||
            error.code == 'notPermitted') {
          rethrow;
        }
        issues[bill.id] = error.code;
      }
    }
    if (!isAccessCurrent()) {
      throw const MedicalReceiptException('accessChanged');
    }
    return MedicalHistoryBatch(
        bills: bills,
        histories: histories,
        issues: issues,
        blockers: blockers,
        blockersByBill: blockersByBill);
  }

  /// Caller already owns a consistent transaction; never nests Isar transactions.
  Future<MedicalReceiptHistory> historyInTransaction(
          {required int billId,
          required int actorId,
          required bool Function() isAccessCurrent,
          bool write = false}) =>
      _history(billId, actorId, isAccessCurrent, write: write);

  Future<MedicalReceiptHistory> _history(
      int billId, int actor, bool Function() access,
      {bool write = false}) async {
    final bill = await _bill(billId, actor, access, write: write);
    final expense = bill.linkedExpenseId == null
        ? null
        : await db.expenses.get(bill.linkedExpenseId!);
    final linkCount = expense == null
        ? 0
        : await db.medicalBills
            .filter()
            .linkedExpenseIdEqualTo(expense.id)
            .count();
    final approvals = await db.medicalApprovals
        .filter()
        .billGuidEqualTo(bill.syncGuid)
        .sortByRevisionDesc()
        .findAll();
    final returns = expense == null
        ? <Reimbursement>[]
        : await db.reimbursements
            .filter()
            .expenseIdEqualTo(expense.id)
            .findAll();
    final revisions = await db.receiptRevisions
        .filter()
        .billGuidEqualTo(bill.syncGuid)
        .sortByRecordedAtDesc()
        .findAll();
    final closure = await db.medicalClaimClosures
        .filter()
        .billGuidEqualTo(bill.syncGuid)
        .findFirst();
    final activities = bill.sharedSpaceId != null
        ? <MedicalClaimActivity>[]
        : await db.medicalClaimActivitys
            .filter()
            .billGuidEqualTo(bill.syncGuid)
            .sortByRecordedAtDesc()
            .findAll();
    final settlements = bill.sharedSpaceId != null
        ? <MedicalSettlementEvent>[]
        : await db.medicalSettlements
            .filter()
            .billGuidEqualTo(bill.syncGuid)
            .findAll();
    final withholdingMatches = bill.sharedSpaceId != null
        ? <MedicalWithholdingMatch>[]
        : (await db.medicalWithholdingMatchs
                .filter()
                .billGuidEqualTo(bill.syncGuid)
                .findAll())
            .where((m) => !m.reversed)
            .toList();
    return _validatedHistory(
        bill: bill,
        expense: expense,
        linkCount: linkCount,
        approvals: approvals,
        returns: returns,
        revisions: revisions,
        closure: closure,
        activities: activities,
        settlements: settlements,
        withholdingMatches: withholdingMatches,
        access: access);
  }

  MedicalReceiptHistory _validatedHistory({
    required MedicalBill bill,
    required Expense? expense,
    required int linkCount,
    required List<MedicalApproval> approvals,
    required List<Reimbursement> returns,
    required List<ReceiptRevision> revisions,
    required MedicalClaimClosure? closure,
    required List<MedicalClaimActivity> activities,
    List<MedicalSettlementEvent> settlements = const [],
    List<MedicalWithholdingMatch> withholdingMatches = const [],
    required bool Function() access,
  }) {
    if (expense == null ||
        expense.type != ExpenseType.medical ||
        expense.sharedSpaceId != bill.sharedSpaceId ||
        (bill.sharedSpaceId == null && expense.profileId != bill.profileId)) {
      throw const MedicalReceiptException('missingExpense');
    }
    if (expense.yearMonth != bill.yearMonth ||
        (bill.currencyCode != null &&
            bill.currencyCode != expense.currencyCode)) {
      throw const MedicalReceiptException('legacyNeedsReview');
    }
    if (linkCount != 1) {
      throw const MedicalReceiptException('legacyNeedsReview');
    }
    if (approvals.any((a) =>
        a.profileId != bill.profileId ||
        a.sharedSpaceId != bill.sharedSpaceId)) {
      throw const MedicalReceiptException('wrongOwner');
    }
    var received = 0;
    for (final row in returns) {
      if (row.sharedSpaceId != bill.sharedSpaceId ||
          (bill.sharedSpaceId == null && row.profileId != bill.profileId) ||
          row.currencyCode != expense.currencyCode ||
          row.amount <= 0 ||
          row.orphaned) {
        throw const MedicalReceiptException('legacyNeedsReview');
      }
      checkedFxMinor(row.amount);
      received = checkedFxMinor(received + row.amount);
      final evidence = MedicalReceiptEvidence.of(row);
      if (evidence != null && evidence.text('billGuid') != bill.syncGuid) {
        throw const MedicalReceiptException('legacyNeedsReview');
      }
    }
    if (activities.any((a) => a.profileId != bill.profileId)) {
      throw const MedicalReceiptException('wrongOwner');
    }
    if (settlements.any((s) =>
        s.profileId != bill.profileId ||
        s.billGuid != bill.syncGuid ||
        (s.kind != MedicalSettlementKind.reversal &&
            s.currency != null &&
            CurrencyCode.tryParse(s.currency!) != expense.currencyCode))) {
      throw const MedicalReceiptException('legacyNeedsReview');
    }
    if (withholdingMatches.any((m) =>
        m.profileId != bill.profileId ||
        m.billGuid != bill.syncGuid ||
        m.reversed ||
        CurrencyCode.tryParse(m.currency) != expense.currencyCode ||
        m.withheldMinor <= 0)) {
      throw const MedicalReceiptException('legacyNeedsReview');
    }
    if (closure != null && bill.sharedSpaceId == null) {
      final decision = approvals
          .where((a) => a.syncGuid == closure.approvalGuid)
          .firstOrNull;
      if (closure.profileId != bill.profileId ||
          closure.sharedSpaceId != null ||
          decision == null ||
          CurrencyCode.tryParse(closure.currency) != expense.currencyCode ||
          closure.receivedMinor != received ||
          closure.shortfallMinor !=
              (decision.approvedMinor - received).clamp(0, fxMoneyBound) ||
          closure.operationIdentity.isEmpty) {
        throw const MedicalReceiptException('closureNeedsReview');
      }
    }
    if (!access()) throw const MedicalReceiptException('accessChanged');
    return MedicalReceiptHistory(
        bill: bill,
        expense: expense,
        approvals: List.unmodifiable(approvals),
        returns: List.unmodifiable(returns),
        revisions: List.unmodifiable(revisions),
        receivedMinor: received,
        closure: closure,
        activities: List.unmodifiable(activities),
        settlements: List.unmodifiable(settlements),
        withholdingMatches: List.unmodifiable(withholdingMatches));
  }

  Future<MedicalApproval> approve(
      {required int billId,
      required int actorId,
      required int amountMinor,
      required DateTime decisionDate,
      required String operationKey,
      required bool Function() isAccessCurrent,
      String? expectedBasis,
      String? noRefundReason}) {
    AppLogger.medicalReceipt(
        'APPROVE_START billId=$billId actorId=$actorId amountMinor=$amountMinor decisionDate=$decisionDate opKey=$operationKey');
    checkedFxMinor(amountMinor);
    if (amountMinor < 0 ||
        (amountMinor == 0 &&
            (noRefundReason == null ||
                noRefundReason.trim().isEmpty ||
                noRefundReason.trim().length > 240)) ||
        decisionDate.isAfter(clock()) ||
        operationKey.trim().isEmpty ||
        operationKey.length > 128) {
      throw const MedicalReceiptException('invalidApproval');
    }
    return db.writeTxn(() async {
      final h = await _history(billId, actorId, isAccessCurrent, write: true);
      AppLogger.medicalReceipt(
          'APPROVE_LOADED billId=$billId billState=${h.bill.state} paymentMethod=${h.bill.paymentMethod} canBeReimbursed=${h.bill.canBeReimbursed} receivedMinor=${h.receivedMinor}');
      if (expectedBasis != null && expectedBasis != medicalBillBasis(h.bill)) {
        throw const MedicalReceiptException('stalePreview');
      }
      if (h.cancelled || h.enteredInError) {
        throw const MedicalReceiptException('claimCancelled');
      }
      if (!h.bill.canBeReimbursed) {
        throw const MedicalReceiptException('insurerPaid');
      }
      if (amountMinor == 0 && h.bill.sharedSpaceId != null) {
        throw const MedicalReceiptException('notPermitted');
      }
      if (h.closure != null) throw const MedicalReceiptException('claimClosed');
      if (h.bill.billedAmount <= 0 ||
          h.bill.billedAmount > fxMoneyBound ||
          !h.bill.patientSharePercent.isFinite ||
          h.bill.patientSharePercent < 0 ||
          h.bill.patientSharePercent > 100 ||
          h.expense.currencyCode == null ||
          amountMinor < h.receivedMinor) {
        throw const MedicalReceiptException('invalidApproval');
      }
      final input = _hash([
        h.bill.syncGuid,
        if (amountMinor == 0) noRefundReason!.trim(),
        amountMinor,
        h.expense.currency,
        decisionDate.toUtc().toIso8601String()
      ]);
      final identity = 'medical-approval:${h.bill.syncGuid}:$operationKey';
      final existing = await db.medicalApprovals
          .filter()
          .operationIdentityEqualTo(identity)
          .findFirst();
      if (existing != null) {
        if (existing.inputFingerprint != input) {
          throw const MedicalReceiptException('duplicateMismatch');
        }
        AppLogger.medicalReceipt(
            'APPROVE_IDEMPOTENT billId=$billId approvalGuid=${existing.syncGuid}');
        return existing;
      }
      final now = clock().toUtc();
      final row = MedicalApproval()
        ..billGuid = h.bill.syncGuid
        ..profileId = h.bill.profileId
        ..sharedSpaceId = h.bill.sharedSpaceId
        ..yearMonth = _month(now)
        ..approvedMinor = amountMinor
        ..currency = h.expense.currencyCode!.code
        ..decisionDate = decisionDate.toUtc()
        ..recordedAt = now
        ..actorId = actorId
        ..revision = (h.approval?.revision ?? 0) + 1
        ..previousGuid = h.approval?.syncGuid
        ..operationIdentity = identity
        ..inputFingerprint = input
        ..basisJson =
            h.bill.sharedSpaceId == null ? medicalBillBasis(h.bill) : null;
      row.id = await AuditRepository(db, recorder: recorder, actorId: actorId)
          .put(db.medicalApprovals, row,
              id: row.id, type: 'MedicalApproval', derived: false);
      await recorder?.recordMedicalApproval(row);
      if (amountMinor == 0) {
        final activity = MedicalClaimActivity()
          ..billGuid = h.bill.syncGuid
          ..profileId = actorId
          ..yearMonth = _month(now)
          ..kind = 'noRefundDecision'
          ..approvalGuid = row.syncGuid
          ..reason = noRefundReason!.trim()
          ..currency = row.currency
          ..recordedAt = now
          ..actorId = actorId
          ..operationIdentity = '$identity:no-refund'
          ..inputFingerprint = input;
        await AuditRepository(db, recorder: recorder, actorId: actorId).put(
            db.medicalClaimActivitys, activity,
            id: activity.id, type: 'MedicalClaimActivity', derived: false);
      }
      await _bill(billId, actorId, isAccessCurrent, write: true);
      AppLogger.medicalReceipt(
          'APPROVE_DONE billId=$billId approvalGuid=${row.syncGuid} approvedMinor=$amountMinor');
      return row;
    });
  }

  Future<MedicalClaimActivity> recordClaimAction(
      {required int billId,
      required int actorId,
      required String kind,
      required String operationKey,
      required bool Function() isAccessCurrent,
      DateTime? submittedAt,
      String reason = ''}) {
    AppLogger.medicalReceipt(
        'RECORD_CLAIM_ACTION_START billId=$billId actorId=$actorId kind=$kind opKey=$operationKey');
    if (!{'submitted', 'cancelled'}.contains(kind) ||
        operationKey.trim().isEmpty ||
        operationKey.length > 128 ||
        reason.trim().length > 240 ||
        (kind == 'cancelled' && reason.trim().isEmpty) ||
        (kind == 'submitted' &&
            (submittedAt == null || submittedAt.isAfter(clock())))) {
      throw const MedicalReceiptException('invalidClaimAction');
    }
    return db.writeTxn(() async {
      final h = await _history(billId, actorId, isAccessCurrent, write: true);
      AppLogger.medicalReceipt(
          'RECORD_CLAIM_ACTION_LOADED billId=$billId state=${h.bill.state} submitted=${h.submitted} approvalPresent=${h.approval != null} cancelled=${h.cancelled}');
      if (h.bill.sharedSpaceId != null) {
        throw const MedicalReceiptException('notPermitted');
      }
      final identity = 'medical-claim:${h.bill.syncGuid}:$operationKey';
      final input =
          _hash([kind, submittedAt?.toUtc().toIso8601String(), reason.trim()]);
      final old = await db.medicalClaimActivitys
          .filter()
          .operationIdentityEqualTo(identity)
          .findFirst();
      if (old != null) {
        if (old.inputFingerprint != input) {
          throw const MedicalReceiptException('duplicateMismatch');
        }
        AppLogger.medicalReceipt(
            'RECORD_CLAIM_ACTION_IDEMPOTENT billId=$billId kind=$kind');
        return old;
      }
      if (h.cancelled || h.enteredInError) {
        throw const MedicalReceiptException('claimCancelled');
      }
      if (kind == 'cancelled' &&
          (h.returns.isNotEmpty ||
              h.bill.reimbursedAmount > 0 ||
              h.closure != null)) {
        throw const MedicalReceiptException('receivedCorrectionRequired');
      }
      if (kind == 'submitted' && (h.submitted || h.approval != null)) {
        throw const MedicalReceiptException('submissionAlreadyRecorded');
      }
      final row = MedicalClaimActivity()
        ..billGuid = h.bill.syncGuid
        ..profileId = actorId
        ..yearMonth = h.bill.yearMonth
        ..kind = kind
        ..submittedAt = submittedAt?.toUtc()
        ..reason = reason.trim()
        ..currency = h.expense.currency
        ..recordedAt = clock().toUtc()
        ..actorId = actorId
        ..operationIdentity = identity
        ..inputFingerprint = input;
      row.id = await AuditRepository(db, recorder: recorder, actorId: actorId)
          .put(db.medicalClaimActivitys, row,
              id: row.id, type: 'MedicalClaimActivity', derived: false);
      await _bill(billId, actorId, isAccessCurrent, write: true);
      AppLogger.medicalReceipt(
          'RECORD_CLAIM_ACTION_DONE billId=$billId kind=$kind');
      return row;
    });
  }

  Future<MedicalReceiptPreview> preview(
          {required int billId,
          required int actorId,
          required int amountMinor,
          required DateTime receivedAt,
          required String destinationMonth,
          required bool Function() isAccessCurrent,
          String localZone = 'UTC',
          String? groupGuid,
          bool alreadyIncluded = false}) =>
      db.txn(() => _preview(billId, actorId, amountMinor, receivedAt,
          destinationMonth, isAccessCurrent,
          localZone: localZone,
          groupGuid: groupGuid,
          alreadyIncluded: alreadyIncluded));

  Future<MedicalReceiptPreview> previewInTransaction(
          {required int billId,
          required int actorId,
          required int amountMinor,
          required DateTime receivedAt,
          required String destinationMonth,
          required bool Function() isAccessCurrent,
          String localZone = 'UTC',
          String? groupGuid,
          bool alreadyIncluded = false,
          bool validatedGroup = false}) =>
      _preview(billId, actorId, amountMinor, receivedAt, destinationMonth,
          isAccessCurrent,
          localZone: localZone,
          groupGuid: groupGuid,
          alreadyIncluded: alreadyIncluded,
          validatedGroup: validatedGroup);

  Future<MedicalReceiptPreview> _preview(int billId, int actor, int amount,
      DateTime date, String destination, bool Function() access,
      {required String localZone,
      String? groupGuid,
      required bool alreadyIncluded,
      bool validatedGroup = false}) async {
    checkedFxMinor(amount);
    if (amount <= 0 || !_validMonth(destination) || date.isAfter(clock())) {
      throw const MedicalReceiptException('invalidReceipt');
    }
    final h = await _history(billId, actor, access, write: true);
    if (h.cancelled || h.enteredInError) {
      throw const MedicalReceiptException('claimCancelled');
    }
    if (h.approvalNeedsReview) {
      throw const MedicalReceiptException('approvalNeedsReview');
    }
    if (!h.bill.canBeReimbursed) {
      throw const MedicalReceiptException('insurerPaid');
    }
    if (!fxPaid(h.expense.status)) {
      throw const MedicalReceiptException('paymentNotRecorded');
    }
    if (h.expense.amount != h.bill.billedAmount) {
      throw const MedicalReceiptException('legacyNeedsReview');
    }
    if (h.bill.reimbursedAmount > h.receivedMinor) {
      throw const MedicalReceiptException('legacyNeedsReview');
    }
    if (h.closure != null) throw const MedicalReceiptException('claimClosed');
    if (h.approval == null ||
        h.approval!.currency != h.expense.currencyCode?.code ||
        amount != h.remainingMinor) {
      throw MedicalReceiptException(amount > h.remainingMinor
          ? 'approvalNeedsReview'
          : 'partialUnsupported');
    }
    BalanceCheckpointService.initializeZones();
    DateTime local;
    try {
      local = tz.TZDateTime.from(
          date, BalanceCheckpointService.location(localZone));
    } catch (_) {
      throw const MedicalReceiptException('invalidTimezone');
    }
    final cashMonth = _month(local);
    if (groupGuid == null && destination != cashMonth) {
      throw const MedicalReceiptException('invalidDestination');
    }
    if (groupGuid != null &&
        (groupGuid.isEmpty || h.bill.sharedSpaceId != null)) {
      throw const MedicalReceiptException('groupNeedsReview');
    }
    ContextRef context(String month) => h.bill.sharedSpaceId == null
        ? ContextRef.personal(profileId: h.bill.profileId!, yearMonth: month)
        : ContextRef.shared(spaceId: h.bill.sharedSpaceId!, yearMonth: month);
    final months = <ReceiptSourceSnapshot>[];
    for (final month in {cashMonth, destination}) {
      final source = await ReceiptSnapshotRepository(db, clock: clock)
          .readInTransaction(
              context: context(month), actorId: actor, isAccessCurrent: access);
      final blockers = source.blockers.where((b) => !(month != cashMonth &&
          month.compareTo(_month(clock())) > 0 &&
          b == ReceiptBlocker.missingOpeningReview));
      if (blockers.isNotEmpty) {
        throw MedicalReceiptException(blockers.first.name);
      }
      months.add(source);
    }
    final owner = BalanceCheckpointService.ownerKey(context(cashMonth));
    final adoption = await db.financialAdoptions
        .filter()
        .ownerKeyEqualTo('$owner:2')
        .sortByRevisionDesc()
        .findFirst();
    if (adoption == null ||
        cashMonth.compareTo(adoption.effectiveYearMonth) < 0 ||
        destination.compareTo(adoption.effectiveYearMonth) < 0) {
      throw const MedicalReceiptException('adoptionRequired');
    }
    // D1's coordinator validates the complete personal bank group atomically.
    // Existing owner adoption and checkpoint review remain mandatory.
    final checkpoint = await db.balanceCheckpoints
        .filter()
        .ownerMonthEqualTo('$owner:$cashMonth')
        .sortByRevisionDesc()
        .findFirst();
    if (checkpoint == null ||
        checkpoint.adoptionGuid != adoption.guid ||
        checkpoint.currency != months.first.currency.code) {
      throw const MedicalReceiptException('openingReviewRequired');
    }
    // An existing checkpoint alone is insufficient: an edited payment may
    // have invalidated the inclusion decisions since that review was saved.
    try {
      if (!validatedGroup || groupGuid == null) {
        await BalanceCheckpointService(db, clock: clock).cashInTransaction(
            context: context(cashMonth),
            actorId: actor,
            isAccessCurrent: access);
      }
    } on FormatException {
      throw const MedicalReceiptException('openingReviewRequired');
    }
    if (alreadyIncluded == date.isAfter(checkpoint.balanceAsOf)) {
      throw const MedicalReceiptException('openingInclusionNeedsReview');
    }
    final original = h.expense.currencyCode!;
    final accounting = months.first.currency;
    final paid =
        expenseAccountingMoney(h.expense, expectedCurrency: accounting);
    if (paid.currency != accounting) {
      throw const MedicalReceiptException('originalFxNeedsReview');
    }
    final fx = expenseFx(h.expense);
    if (fx == null && original != accounting) {
      throw const MedicalReceiptException('originalFxNeedsReview');
    }
    var prior = 0, priorBase = 0;
    for (final row in h.returns) {
      final evidence = MedicalReceiptEvidence.of(row);
      if (evidence != null) {
        prior = checkedFxMinor(prior + evidence.number('principalMinor'));
        priorBase =
            checkedFxMinor(priorBase + evidence.number('principalBaseMinor'));
      } else {
        final value =
            reimbursementAccountingMoney(row, expectedCurrency: accounting);
        if (value.currency != accounting) {
          throw const MedicalReceiptException('legacyNeedsReview');
        }
        prior = checkedFxMinor(prior + row.amount);
        priorBase = checkedFxMinor(priorBase + value.minorUnits);
      }
    }
    final booked = const MedicalReceiptBookingService().book(
        paidMinor: h.expense.amount,
        paidBaseMinor: paid.minorUnits,
        priorPrincipalMinor: prior,
        priorPrincipalBaseMinor: priorBase,
        amountMinor: amount,
        original: original,
        accounting: accounting);
    final input = _hash([
      h.bill.syncGuid,
      h.approval!.syncGuid,
      h.closure?.syncGuid,
      h.returns
          .map((r) => [
                r.syncGuid,
                r.amount,
                r.originYearMonth,
                r.date.toUtc().toIso8601String(),
                r.fxHistoryJson,
                r.medicalReceiptJson
              ])
          .toList(),
      h.expense.amount,
      h.expense.fxHistoryJson,
      checkpoint.guid,
      adoption.guid,
      amount,
      date.toUtc().toIso8601String(),
      destination,
      localZone,
      groupGuid,
      alreadyIncluded,
      months.map((s) => s.fingerprint).toList()
    ]);
    final evidence = MedicalReceiptEvidence({
      'version': 2,
      'receiptGuid': newSyncGuid(),
      'revisionGuid': newSyncGuid(),
      'revision': 1,
      'sequence': h.returns.length + 1,
      'billGuid': h.bill.syncGuid,
      'expenseGuid': h.expense.syncGuid,
      'approvalGuid': h.approval!.syncGuid,
      'approvalMinor': h.approval!.approvedMinor,
      'receivedAt': date.toUtc().toIso8601String(),
      'receivedLocalDate': local.toIso8601String().substring(0, 10),
      'localZone': localZone,
      'fundingMonth': destination,
      'costMonth': h.expense.yearMonth,
      'groupGuid': groupGuid,
      'currency': original.code.toUpperCase(),
      'accountingCurrency': accounting.code.toUpperCase(),
      'amountMinor': amount,
      'paidMinor': h.expense.amount,
      'paidBaseMinor': paid.minorUnits,
      'priorPrincipalMinor': prior,
      'priorPrincipalBaseMinor': priorBase,
      'principalMinor': booked.principalMinor,
      'principalBaseMinor': booked.principalBaseMinor,
      'excessMinor': booked.excessMinor,
      'excessBaseMinor': booked.excessBaseMinor,
      'baseMinor': booked.baseMinor,
      'originalFxHash': fx?.current.hash ?? 'legacy-same-currency',
      'alreadyIncluded': alreadyIncluded,
      'checkpointGuid': checkpoint.guid
    });
    if (!access()) throw const MedicalReceiptException('accessChanged');
    return MedicalReceiptPreview._(
        history: h,
        actorId: actor,
        evidence: evidence,
        fingerprint: input,
        months: List.unmodifiable(months),
        alreadyIncluded: alreadyIncluded);
  }

  /// Caller owns ONE financial transaction, and (for grouped salary) must
  /// atomically write/validate the bank group and all its components as well.
  Future<MoneyReceipt> recordInTransaction(
      {required MedicalReceiptPreview preview,
      required String operationKey,
      required bool Function() isAccessCurrent,
      bool validatedGroup = false}) async {
    if (operationKey.trim().isEmpty || operationKey.length > 128) {
      throw const MedicalReceiptException('invalidOperation');
    }
    final original = preview.evidence;
    final bill = await _bill(
        preview.history.bill.id, preview.actorId, isAccessCurrent,
        write: true);
    if (bill.sharedSpaceId != null) {
      throw const MedicalReceiptException('peerUpgradeRequired');
    }
    final identity = 'medical-receipt:${bill.syncGuid}:$operationKey';
    final old = await db.moneyReceipts
        .filter()
        .operationIdentityEqualTo(identity)
        .findFirst();
    final fingerprint = _hash([preview.fingerprint]);
    if (old != null) {
      if (old.inputFingerprint != fingerprint) {
        throw const MedicalReceiptException('duplicateMismatch');
      }
      return old;
    }
    final fresh = await _preview(
        bill.id,
        preview.actorId,
        original.number('amountMinor'),
        original.receivedAt,
        original.fundingMonth,
        isAccessCurrent,
        localZone: original.text('localZone'),
        groupGuid: original.json['groupGuid'] as String?,
        alreadyIncluded: preview.alreadyIncluded,
        validatedGroup: validatedGroup);
    if (fresh.fingerprint != preview.fingerprint) {
      throw const MedicalReceiptException('stalePreview');
    }
    final now = clock().toUtc();
    final audit =
        AuditRepository(db, recorder: recorder, actorId: preview.actorId);
    final receipt = MoneyReceipt()
      ..syncGuid = original.text('receiptGuid')
      ..billGuid = bill.syncGuid
      ..profileId = bill.profileId
      ..sharedSpaceId = bill.sharedSpaceId
      ..actorId = preview.actorId
      ..createdAt = now
      ..operationIdentity = identity
      ..inputFingerprint = fingerprint;
    receipt.id = await audit.put(db.moneyReceipts, receipt,
        id: receipt.id, type: 'MoneyReceipt', derived: false);
    final revision = ReceiptRevision()
      ..syncGuid = original.text('revisionGuid')
      ..receiptGuid = receipt.syncGuid
      ..billGuid = bill.syncGuid
      ..profileId = bill.profileId
      ..sharedSpaceId = bill.sharedSpaceId
      ..yearMonth = original.fundingMonth
      ..evidenceJson = original.encode()
      ..recordedAt = now
      ..actorId = preview.actorId
      ..operationIdentity = '$identity:revision:1'
      ..inputFingerprint = fingerprint;
    revision.id = await audit.put(db.receiptRevisions, revision,
        id: revision.id, type: 'ReceiptRevision', derived: false);
    final row = Reimbursement(
        profileId: bill.profileId ?? preview.actorId,
        sharedSpaceId: bill.sharedSpaceId,
        expenseId: fresh.history.expense.id,
        originYearMonth: original.fundingMonth,
        amount: original.number('amountMinor'),
        currency: original.text('currency').toLowerCase(),
        date: original.receivedAt,
        medicalReceiptJson: original.encode())
      ..syncGuid = receipt.syncGuid;
    row.id = await audit.put(db.reimbursements, row,
        id: row.id, type: 'Reimbursement');
    if (original.json['groupGuid'] == null) {
      final cashMonth = original.text('receivedLocalDate').substring(0, 7);
      final cashContext =
          ContextRef.personal(profileId: bill.profileId!, yearMonth: cashMonth);
      final cashSources = await BalanceCheckpointService(db, clock: clock)
          .loadInTransaction(
              context: cashContext,
              actorId: preview.actorId,
              isAccessCurrent: isAccessCurrent);
      final movement = cashSources.movements
          .firstWhere((m) => m.key == 'return:${row.syncGuid}');
      final checkpoint = cashSources.previous!;
      await db.movementInclusions.put(MovementInclusion()
        ..identity = '${checkpoint.guid}:${movement.key}'
        ..checkpointGuid = checkpoint.guid
        ..movementKey = movement.key
        ..movementRevision = movement.revision
        ..role = preview.alreadyIncluded ? 'included' : 'later'
        ..reviewedActualAt = original.receivedAt
        ..signedMinor = movement.signedMinor
        ..confirmedBy = preview.actorId
        ..confirmedAt = now);
    }
    await _bill(bill.id, preview.actorId, isAccessCurrent, write: true);
    return receipt;
  }

  Future<MedicalReceiptCorrection> previewCorrection(
          {required int billId,
          required int actorId,
          required String receiptGuid,
          required int amountMinor,
          required DateTime receivedAt,
          required String destinationMonth,
          required String reason,
          required bool alreadyIncluded,
          required bool Function() isAccessCurrent}) =>
      db.txn(() => _correction(
          billId,
          actorId,
          receiptGuid,
          amountMinor,
          receivedAt,
          destinationMonth,
          reason,
          alreadyIncluded,
          isAccessCurrent));

  Future<MedicalReceiptCorrection> _correction(
      int billId,
      int actor,
      String receipt,
      int amount,
      DateTime date,
      String destination,
      String reason,
      bool included,
      bool Function() access) async {
    checkedFxMinor(amount);
    if (amount <= 0 ||
        reason.trim().isEmpty ||
        reason.trim().length > 240 ||
        date.isAfter(clock()) ||
        !_validMonth(destination)) {
      throw const MedicalReceiptException('invalidCorrection');
    }
    final h = await _history(billId, actor, access, write: true);
    if (h.bill.sharedSpaceId != null) {
      throw const MedicalReceiptException('peerUpgradeRequired');
    }
    final rows = [...h.returns];
    final target = rows.where((r) => r.syncGuid == receipt).firstOrNull;
    if (target == null ||
        target.medicalReceiptJson == null ||
        h.approval == null) {
      throw const MedicalReceiptException('legacyNeedsReview');
    }
    if (h.closure != null && target.amount != amount) {
      throw const MedicalReceiptException('claimClosed');
    }
    if (checkedFxMinor(h.receivedMinor - target.amount + amount) >
        h.approval!.approvedMinor) {
      throw const MedicalReceiptException('approvalNeedsReview');
    }
    final oldTarget = MedicalReceiptEvidence.of(target)!;
    final zone = oldTarget.text('localZone');
    BalanceCheckpointService.initializeZones();
    tz.TZDateTime local;
    try {
      local = tz.TZDateTime.from(date, BalanceCheckpointService.location(zone));
    } catch (_) {
      throw const MedicalReceiptException('invalidTimezone');
    }
    if (destination != _month(local)) {
      throw const MedicalReceiptException('groupNeedsReview');
    }
    if (rows
        .any((r) => MedicalReceiptEvidence.of(r)?.json['groupGuid'] != null)) {
      throw const MedicalReceiptException('groupNeedsReview');
    }
    rows.sort((a, b) => (MedicalReceiptEvidence.of(a)?.number('sequence') ?? 0)
        .compareTo(MedicalReceiptEvidence.of(b)?.number('sequence') ?? 0));
    final accounting = oldTarget.accounting;
    final original = h.expense.currencyCode!;
    final paid =
        expenseAccountingMoney(h.expense, expectedCurrency: accounting);
    final replacements = <int, MedicalReceiptEvidence>{};
    var prior = 0, base = 0;
    for (final row in rows) {
      final old = MedicalReceiptEvidence.of(row);
      if (old == null) {
        final money =
            reimbursementAccountingMoney(row, expectedCurrency: accounting);
        if (money.currency != accounting) {
          throw const MedicalReceiptException('legacyNeedsReview');
        }
        prior = checkedFxMinor(prior + row.amount);
        base = checkedFxMinor(base + money.minorUnits);
        continue;
      }
      final value = row.id == target.id ? amount : row.amount;
      final book = const MedicalReceiptBookingService().book(
          paidMinor: h.expense.amount,
          paidBaseMinor: paid.minorUnits,
          priorPrincipalMinor: prior,
          priorPrincipalBaseMinor: base,
          amountMinor: value,
          original: original,
          accounting: accounting);
      final json = Map<String, Object?>.of(old.json)
        ..addAll({
          'approvalGuid': h.approval!.syncGuid,
          'approvalMinor': h.approval!.approvedMinor,
          'amountMinor': value,
          'priorPrincipalMinor': prior,
          'priorPrincipalBaseMinor': base,
          'principalMinor': book.principalMinor,
          'principalBaseMinor': book.principalBaseMinor,
          'excessMinor': book.excessMinor,
          'excessBaseMinor': book.excessBaseMinor,
          'baseMinor': book.baseMinor,
        });
      if (row.id == target.id) {
        json.addAll({
          'receivedAt': date.toUtc().toIso8601String(),
          'receivedLocalDate': local.toIso8601String().substring(0, 10),
          'fundingMonth': destination,
          'alreadyIncluded': included
        });
      }
      if (jsonEncode(json) != old.encode()) {
        json.addAll({
          'revisionGuid': newSyncGuid(),
          'previousRevisionGuid': old.text('revisionGuid'),
          'revision': old.number('revision') + 1,
          'correctionReason': reason.trim()
        });
        replacements[row.id] = MedicalReceiptEvidence(json);
      }
      prior = checkedFxMinor(prior + book.principalMinor);
      base = checkedFxMinor(base + book.principalBaseMinor);
    }
    if (replacements.isEmpty) throw const MedicalReceiptException('noChange');
    final months = <String>{};
    for (final row in rows.where((r) => replacements.containsKey(r.id))) {
      final old = MedicalReceiptEvidence.of(row)!, next = replacements[row.id]!;
      months.addAll([
        old.text('receivedLocalDate').substring(0, 7),
        old.fundingMonth,
        next.text('receivedLocalDate').substring(0, 7),
        next.fundingMonth
      ]);
    }
    final monthHashes = <String>[];
    for (final month in months.toList()..sort()) {
      final ctx =
          ContextRef.personal(profileId: h.bill.profileId!, yearMonth: month);
      final source = await ReceiptSnapshotRepository(db, clock: clock)
          .readInTransaction(
              context: ctx, actorId: actor, isAccessCurrent: access);
      if (source.blockers.isNotEmpty) {
        throw MedicalReceiptException(source.blockers.first.name);
      }
      monthHashes.add(source.fingerprint);
    }
    for (final evidence in replacements.values) {
      final month = evidence.text('receivedLocalDate').substring(0, 7);
      final checkpoint = await db.balanceCheckpoints
          .filter()
          .ownerMonthEqualTo('personal:${h.bill.profileId}:$month')
          .sortByRevisionDesc()
          .findFirst();
      if (checkpoint == null) {
        throw const MedicalReceiptException('openingReviewRequired');
      }
      if ((evidence.json['alreadyIncluded'] == true) ==
          evidence.receivedAt.isAfter(checkpoint.balanceAsOf)) {
        throw const MedicalReceiptException('openingInclusionNeedsReview');
      }
    }
    final fingerprint = _hash([
      receipt,
      amount,
      date.toUtc().toIso8601String(),
      destination,
      reason.trim(),
      included,
      h.approval!.syncGuid,
      rows.map((r) => [r.id, r.medicalReceiptJson, r.amount]).toList(),
      monthHashes
    ]);
    return MedicalReceiptCorrection._(h, actor, Map.unmodifiable(replacements),
        reason.trim(), fingerprint, receipt);
  }

  Future<void> correctInTransaction(
      {required MedicalReceiptCorrection preview,
      required String operationKey,
      required bool Function() isAccessCurrent}) async {
    if (operationKey.trim().isEmpty || operationKey.length > 128) {
      throw const MedicalReceiptException('invalidOperation');
    }
    final identities = preview.replacements.values
        .map((e) => 'medical-correction:${e.text('receiptGuid')}:$operationKey')
        .toList();
    final existing = await db.receiptRevisions
        .filter()
        .operationIdentityEqualTo(identities.first)
        .findFirst();
    await _bill(preview.history.bill.id, preview.actorId, isAccessCurrent,
        write: true);
    if (existing != null) {
      if (existing.inputFingerprint != preview.fingerprint) {
        throw const MedicalReceiptException('duplicateMismatch');
      }
      return;
    }
    // Reconstruct the reviewed request from the explicitly changed target.
    final target = preview.replacements.entries.firstWhere((entry) =>
        entry.value.text('receiptGuid') == preview.targetReceiptGuid);
    final evidence = target.value;
    final fresh = await _correction(
        preview.history.bill.id,
        preview.actorId,
        evidence.text('receiptGuid'),
        evidence.number('amountMinor'),
        evidence.receivedAt,
        evidence.fundingMonth,
        preview.reason,
        evidence.json['alreadyIncluded'] == true,
        isAccessCurrent);
    if (fresh.fingerprint != preview.fingerprint) {
      throw const MedicalReceiptException('stalePreview');
    }
    final audit =
        AuditRepository(db, recorder: recorder, actorId: preview.actorId);
    final now = clock().toUtc();
    for (final entry in preview.replacements.entries) {
      final row = preview.history.returns.firstWhere((r) => r.id == entry.key);
      final e = entry.value;
      final revision = ReceiptRevision()
        ..syncGuid = e.text('revisionGuid')
        ..receiptGuid = row.syncGuid
        ..billGuid = preview.history.bill.syncGuid
        ..profileId = preview.history.bill.profileId
        ..yearMonth = e.fundingMonth
        ..revision = e.number('revision')
        ..previousGuid = (e.json['previousRevisionGuid'] as String?)
        ..evidenceJson = e.encode()
        ..recordedAt = now
        ..actorId = preview.actorId
        ..operationIdentity = 'medical-correction:${row.syncGuid}:$operationKey'
        ..inputFingerprint = preview.fingerprint;
      revision.id = await audit.put(db.receiptRevisions, revision,
          id: revision.id, type: 'ReceiptRevision', derived: false);
      final updated = Reimbursement(
          id: row.id,
          profileId: row.profileId,
          sharedSpaceId: row.sharedSpaceId,
          expenseId: row.expenseId,
          originYearMonth: e.fundingMonth,
          amount: e.number('amountMinor'),
          currency: row.currency,
          date: e.receivedAt,
          note: row.note,
          medicalReceiptJson: e.encode())
        ..syncGuid = row.syncGuid;
      await audit.put(db.reimbursements, updated,
          id: updated.id, type: 'Reimbursement');
    }
    await _bill(preview.history.bill.id, preview.actorId, isAccessCurrent,
        write: true);
  }
}
