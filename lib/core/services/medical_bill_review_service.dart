import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';
import '../models/medical_bill.dart';
import '../models/medical_approval.dart';
import '../models/expense.dart';
import '../providers/budget_context_provider.dart';
import '../../features/finance/repositories/audit_repository.dart';
import '../../features/sync/repositories/sync_recorder.dart';
import 'medical_bill_basis.dart';
import 'medical_receipt_service.dart';
import 'receipt_snapshot_repository.dart';

class MedicalBillReview {
  MedicalBillReview._(
      this.billId,
      this.actorId,
      this.proposed,
      this.status,
      this.remove,
      this.reason,
      this.fingerprint,
      this.beforeMinor,
      this.afterMinor,
      this.approvalGuid,
      this.original,
      this.paymentDate,
      this.previousPaymentDate);
  final int billId, actorId, beforeMinor, afterMinor;
  final MedicalBill proposed, original;
  final ExpenseStatus status;
  final bool remove;
  final String reason, fingerprint;
  final String? approvalGuid;
  final DateTime? paymentDate, previousPaymentDate;
}

/// Explicit, source-bound correction. Old bill/approval evidence is retained.
/// Caller supplies the existing repository's atomic bill/expense persistence.
class MedicalBillReviewService {
  MedicalBillReviewService(this.db, {this.recorder, DateTime Function()? clock})
      : clock = clock ?? DateTime.now;
  final Isar db;
  final SyncRecorder? recorder;
  final DateTime Function() clock;
  static String _hash(Object value) =>
      sha256.convert(utf8.encode(jsonEncode(value))).toString();

  Future<MedicalBillReview> preview(
          {required MedicalBill proposed,
          required int actorId,
          required ExpenseStatus status,
          required String reason,
          required bool Function() isAccessCurrent,
          bool remove = false,
          DateTime? paymentDate}) =>
      db.txn(() => _preview(proposed, actorId, status, reason, isAccessCurrent,
          remove, paymentDate));

  Future<MedicalBillReview> _preview(
      MedicalBill proposed,
      int actor,
      ExpenseStatus status,
      String reason,
      bool Function() access,
      bool remove,
      DateTime? paymentDate) async {
    if (paymentDate != null &&
        (paymentDate.isAfter(clock()) ||
            paymentDate.year < 1970 ||
            status != ExpenseStatus.paid ||
            remove)) {
      throw const MedicalReceiptException('invalidPaymentDate');
    }
    if (reason.trim().isEmpty || reason.trim().length > 240) {
      throw const MedicalReceiptException('correctionReasonRequired');
    }
    final h = await MedicalReceiptService(db, clock: clock)
        .historyInTransaction(
            billId: proposed.id,
            actorId: actor,
            isAccessCurrent: access,
            write: true);
    if (h.bill.sharedSpaceId != null ||
        proposed.sharedSpaceId != null ||
        proposed.profileId != h.bill.profileId ||
        proposed.syncGuid != h.bill.syncGuid ||
        proposed.linkedExpenseId != h.expense.id) {
      throw const MedicalReceiptException('wrongOwner');
    }
    if (h.enteredInError) throw const MedicalReceiptException('billRemoved');
    if (h.returns.isNotEmpty ||
        h.bill.reimbursedAmount > 0 ||
        h.closure != null) {
      throw const MedicalReceiptException('receivedCorrectionRequired');
    }
    if (!remove &&
        (proposed.billedAmount <= 0 ||
            proposed.currencyCode == null ||
            !proposed.patientSharePercent.isFinite ||
            proposed.patientSharePercent < 0 ||
            proposed.patientSharePercent > 100 ||
            !{ExpenseStatus.paid, ExpenseStatus.planned}.contains(status))) {
      throw const MedicalReceiptException('invalidBillCorrection');
    }
    final sources = <String>[];
    for (final month in {
      h.bill.yearMonth,
      proposed.yearMonth,
      if (paymentDate != null) paymentDate.toLocal().toString().substring(0, 7),
      if (paymentDate != null && h.expense.paidAt != null)
        h.expense.paidAt!.toLocal().toString().substring(0, 7)
    }) {
      final source = await ReceiptSnapshotRepository(db, clock: clock)
          .readInTransaction(
              context: ContextRef.personal(profileId: actor, yearMonth: month),
              actorId: actor,
              isAccessCurrent: access);
      if (source.blockers.isNotEmpty) {
        throw MedicalReceiptException(source.blockers.first.name);
      }
      sources.add(source.fingerprint);
    }
    final safe = copyMedicalBill(remove ? h.bill : proposed);
    if (!remove) {
      // Insurance refusal and the insurer's own provider-payment answer are
      // separate from the user's linked expense booking. Do not erase them
      // while reviewing a saved bill or infer that the user paid a refusal.
      safe.state = proposed.state == MedicalBillState.rejected ||
              proposed.paymentMethod == MedicalPaymentMethod.insurerPaid
          ? proposed.state
          : status == ExpenseStatus.planned
              ? MedicalBillState.planned
              : MedicalBillState.paid;
    }
    final input = _hash([
      medicalBillBasis(h.bill),
      h.bill.state.name,
      h.expense.status.name,
      h.expense.paidAt?.toUtc().toIso8601String(),
      paymentDate?.toUtc().toIso8601String(),
      h.expense.fxHistoryJson,
      h.approval?.syncGuid,
      h.activities.map((a) => a.syncGuid).toList(),
      medicalBillBasis(safe),
      safe.state.name,
      status.name,
      reason.trim(),
      remove,
      sources
    ]);
    return MedicalBillReview._(
        h.bill.id,
        actor,
        safe,
        status,
        remove,
        reason.trim(),
        input,
        h.expense.status == ExpenseStatus.planned ? 0 : h.expense.amount,
        remove || status == ExpenseStatus.planned ? 0 : safe.fundsImpact,
        h.approval?.syncGuid,
        copyMedicalBill(h.bill),
        paymentDate?.toUtc(),
        h.expense.paidAt);
  }

  Future<void> applyInTransaction(
      {required MedicalBillReview review,
      required String operationKey,
      required bool Function() isAccessCurrent,
      required Future<void> Function(MedicalBill, ExpenseStatus)
          persist}) async {
    if (operationKey.trim().isEmpty || operationKey.length > 128) {
      throw const MedicalReceiptException('invalidOperation');
    }
    final identity =
        'medical-bill-review:${review.proposed.syncGuid}:$operationKey';
    final old = await db.medicalClaimActivitys
        .filter()
        .operationIdentityEqualTo(identity)
        .findFirst();
    if (old != null) {
      if (!isAccessCurrent() ||
          old.profileId != review.actorId ||
          old.inputFingerprint != review.fingerprint) {
        throw const MedicalReceiptException('duplicateMismatch');
      }
      return;
    }
    final fresh = await _preview(review.proposed, review.actorId, review.status,
        review.reason, isAccessCurrent, review.remove, review.paymentDate);
    if (fresh.fingerprint != review.fingerprint) {
      throw const MedicalReceiptException('stalePreview');
    }
    final before = (await db.medicalBills.get(review.billId))!;
    final beforeJson = jsonEncode({
      ...jsonDecode(medicalBillBasis(before)) as Map<String, dynamic>,
      'paidAt': review.previousPaymentDate?.toUtc().toIso8601String()
    });
    await persist(copyMedicalBill(review.proposed),
        review.remove ? ExpenseStatus.cancelled : review.status);
    final row = MedicalClaimActivity()
      ..billGuid = before.syncGuid
      ..profileId = review.actorId
      ..yearMonth = review.proposed.yearMonth
      ..kind = review.remove ? 'removed' : 'corrected'
      ..approvalGuid = review.approvalGuid
      ..reason = review.reason
      ..beforeJson = beforeJson
      ..afterJson = jsonEncode({
        ...jsonDecode(medicalBillBasis(review.proposed))
            as Map<String, dynamic>,
        'paidAt': review.status == ExpenseStatus.planned
            ? null
            : (review.paymentDate ?? review.previousPaymentDate)
                ?.toUtc()
                .toIso8601String()
      })
      ..beforeMinor = review.beforeMinor
      ..afterMinor = review.afterMinor
      ..currency = before.currency
      ..recordedAt = clock().toUtc()
      ..actorId = review.actorId
      ..operationIdentity = identity
      ..inputFingerprint = review.fingerprint;
    row.id =
        await AuditRepository(db, recorder: recorder, actorId: review.actorId)
            .put(db.medicalClaimActivitys, row,
                id: row.id, type: 'MedicalClaimActivity', derived: false);
    if (!isAccessCurrent()) {
      throw const MedicalReceiptException('accessChanged');
    }
  }
}
