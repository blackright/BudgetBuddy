import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';

import '../logging/app_logger.dart';
import '../models/expense.dart';
import '../models/medical_bill.dart';
import '../models/medical_settlement_event.dart';
import '../models/medical_withholding_match.dart';
import '../services/medical_bill_basis.dart';
import '../../features/finance/repositories/audit_repository.dart';
import '../../features/spaces/repositories/space_write_guard.dart';
import '../../features/sync/repositories/sync_recorder.dart';

class MedicalSettlementException implements Exception {
  const MedicalSettlementException(this.code);
  final String code;
  @override
  String toString() => 'MedicalSettlementException: $code';
}

/// Active settlement evidence: originals minus anything a later reversal
/// supersedes. Reversal rows are links, never standalone facts.
List<MedicalSettlementEvent> activeSettlements(
    Iterable<MedicalSettlementEvent> all) {
  final rows = all.toList();
  final reversed = rows
      .where((e) => e.kind == MedicalSettlementKind.reversal)
      .map((e) => e.supersedesGuid)
      .whereType<String>()
      .toSet();
  return rows
      .where((e) =>
          e.kind != MedicalSettlementKind.reversal &&
          !reversed.contains(e.syncGuid))
      .toList();
}

/// Guarded commands for direct-insurer settlement.
///
/// The linked expense is the single cash booking for the patient share. These
/// commands only retain evidence, so they never create a second expense, refund
/// or approval. Legacy rows without evidence are refused rather than guessed.
class MedicalSettlementService {
  MedicalSettlementService(this.db, {this.recorder, DateTime Function()? clock})
      : clock = clock ?? DateTime.now;
  final Isar db;
  final SyncRecorder? recorder;
  final DateTime Function() clock;

  static String _hash(Object value) =>
      sha256.convert(utf8.encode(jsonEncode(value))).toString();

  /// Records or confirms the insurer's payment to the provider.
  ///
  /// A pending event may be written when the bill is created. Confirming it
  /// supersedes that pending evidence instead of writing a second active fact.
  Future<MedicalSettlementEvent> recordProviderSettlement({
    required int billId,
    required int actorId,
    required DateTime effectiveDate,
    required bool confirmed,
    required String operationKey,
    required bool Function() isAccessCurrent,
  }) async {
    AppLogger.medicalSettlement(
        'PROVIDER_START billId=$billId actorId=$actorId confirmed=$confirmed effectiveDate=$effectiveDate');
    return db.writeTxn(() async {
      if (!isAccessCurrent()) {
        throw const MedicalSettlementException('accessChanged');
      }
      final bill = await _bill(billId, actorId);
      final expense = await _expense(bill);
      _validateBill(bill, expense);
      _validateDate(effectiveDate);
      if (operationKey.trim().isEmpty || operationKey.length > 128) {
        throw const MedicalSettlementException('invalidOperation');
      }

      final currency = expense.currencyCode!.code;
      final amount = bill.insurerPaidAmount;
      final fingerprint = _hash([
        bill.syncGuid,
        MedicalSettlementKind.insurerProviderSettlement.name,
        confirmed,
        effectiveDate.toUtc().toIso8601String(),
        amount,
        currency,
      ]);
      final identity =
          'medical-settlement:provider:${bill.syncGuid}:$operationKey';
      final replay = await _replay(identity, fingerprint);
      if (replay != null) return replay;

      final rows = await _events(bill.syncGuid);
      final active = activeSettlements(rows)
          .where(
              (e) => e.kind == MedicalSettlementKind.insurerProviderSettlement)
          .toList();
      final current = active.isEmpty ? null : active.last;
      if (current != null && current.confirmed) {
        throw const MedicalSettlementException('alreadyConfirmed');
      }
      if (current != null && !confirmed) {
        throw const MedicalSettlementException('alreadyPending');
      }
      if (await _hasClosure(bill.syncGuid)) {
        throw const MedicalSettlementException('claimClosed');
      }

      final event = MedicalSettlementEvent()
        ..profileId = bill.profileId
        ..billGuid = bill.syncGuid
        ..kind = MedicalSettlementKind.insurerProviderSettlement
        ..confirmed = confirmed
        ..effectiveDate = effectiveDate.toUtc()
        ..recordedAt = clock().toUtc()
        ..currency = currency
        ..amountMinor = amount
        ..basisJson = medicalBillBasis(bill)
        ..expenseId = expense.id
        ..expenseGuid = expense.syncGuid
        ..supersedesGuid = confirmed ? current?.syncGuid : null
        ..reason = ''
        ..actorId = actorId
        ..operationIdentity = identity
        ..inputFingerprint = fingerprint;
      event.id = await AuditRepository(db, recorder: recorder, actorId: actorId)
          .put(db.medicalSettlements, event,
              id: event.id, type: 'MedicalSettlementEvent', derived: false);
      AppLogger.medicalSettlement(
          'PROVIDER_DONE billGuid=${bill.syncGuid} confirmed=$confirmed guid=${event.syncGuid}');
      return event;
    });
  }

  /// Records the one full separate payment of the patient share.
  ///
  /// The share is already carried by the linked expense; this command links that
  /// booking. Partial or mixed settlement is refused in this release.
  Future<MedicalSettlementEvent> recordSharePayment({
    required int billId,
    required int actorId,
    required int amountMinor,
    required DateTime effectiveDate,
    required String operationKey,
    required bool Function() isAccessCurrent,
  }) async {
    AppLogger.medicalSettlement(
        'SHARE_START billId=$billId actorId=$actorId amountMinor=$amountMinor');
    return db.writeTxn(() async {
      if (!isAccessCurrent()) {
        throw const MedicalSettlementException('accessChanged');
      }
      final bill = await _bill(billId, actorId);
      final expense = await _expense(bill);
      _validateBill(bill, expense);
      _validateDate(effectiveDate);
      final share = bill.patientShareAmount;
      if (share <= 0) {
        throw const MedicalSettlementException('zeroShare');
      }
      if (amountMinor != share) {
        throw MedicalSettlementException(
            amountMinor > share ? 'overmatched' : 'partialUnsupported');
      }
      if (operationKey.trim().isEmpty || operationKey.length > 128) {
        throw const MedicalSettlementException('invalidOperation');
      }
      if (await _hasClosure(bill.syncGuid)) {
        throw const MedicalSettlementException('claimClosed');
      }

      final currency = expense.currencyCode!.code;
      final fingerprint = _hash([
        bill.syncGuid,
        MedicalSettlementKind.shareSettlement.name,
        amountMinor,
        effectiveDate.toUtc().toIso8601String(),
        currency,
      ]);
      final identity =
          'medical-settlement:share:${bill.syncGuid}:$operationKey';
      final replay = await _replay(identity, fingerprint);
      if (replay != null) return replay;

      final rows = await _events(bill.syncGuid);
      if (activeSettlements(rows)
          .any((e) => e.kind == MedicalSettlementKind.shareSettlement)) {
        throw const MedicalSettlementException('alreadySettled');
      }
      if (await _activeWithholding(bill.syncGuid)) {
        throw const MedicalSettlementException('alreadySettled');
      }

      final event = MedicalSettlementEvent()
        ..profileId = bill.profileId
        ..billGuid = bill.syncGuid
        ..kind = MedicalSettlementKind.shareSettlement
        ..confirmed = true
        ..effectiveDate = effectiveDate.toUtc()
        ..recordedAt = clock().toUtc()
        ..currency = currency
        ..amountMinor = amountMinor
        ..basisJson = medicalBillBasis(bill)
        ..expenseId = expense.id
        ..expenseGuid = expense.syncGuid
        ..reason = ''
        ..actorId = actorId
        ..operationIdentity = identity
        ..inputFingerprint = fingerprint;
      event.id = await AuditRepository(db, recorder: recorder, actorId: actorId)
          .put(db.medicalSettlements, event,
              id: event.id, type: 'MedicalSettlementEvent', derived: false);
      AppLogger.medicalSettlement(
          'SHARE_DONE billGuid=${bill.syncGuid} guid=${event.syncGuid}');
      return event;
    });
  }

  /// Metadata-only closure of a direct-insurer bill.
  ///
  /// Requires confirmed provider settlement and a resolved patient share. It
  /// creates no refund, approval, cash movement or reopened cost month.
  Future<MedicalSettlementEvent> closeBill({
    required int billId,
    required int actorId,
    required String reason,
    required String operationKey,
    required bool Function() isAccessCurrent,
  }) async {
    AppLogger.medicalSettlement(
        'CLOSE_START billId=$billId actorId=$actorId reason=$reason');
    return db.writeTxn(() async {
      if (!isAccessCurrent()) {
        throw const MedicalSettlementException('accessChanged');
      }
      final bill = await _bill(billId, actorId);
      final expense = await _expense(bill);
      _validateBill(bill, expense);
      if (reason.trim().isEmpty || reason.trim().length > 240) {
        throw const MedicalSettlementException('reasonRequired');
      }
      if (operationKey.trim().isEmpty || operationKey.length > 128) {
        throw const MedicalSettlementException('invalidOperation');
      }

      final rows = await _events(bill.syncGuid);
      final active = activeSettlements(rows);
      if (!active.any((e) =>
          e.kind == MedicalSettlementKind.insurerProviderSettlement &&
          e.confirmed)) {
        throw const MedicalSettlementException('providerNotConfirmed');
      }
      final shareResolved = bill.patientShareAmount == 0 ||
          active.any((e) => e.kind == MedicalSettlementKind.shareSettlement) ||
          await _activeWithholding(bill.syncGuid);
      if (!shareResolved) {
        throw const MedicalSettlementException('shareNotRecorded');
      }

      final fingerprint = _hash([
        bill.syncGuid,
        MedicalSettlementKind.closure.name,
        reason.trim(),
        medicalBillBasis(bill),
      ]);
      final identity =
          'medical-settlement:close:${bill.syncGuid}:$operationKey';
      final replay = await _replay(identity, fingerprint);
      if (replay != null) return replay;
      if (active.any((e) => e.kind == MedicalSettlementKind.closure)) {
        throw const MedicalSettlementException('alreadyClosed');
      }

      final event = MedicalSettlementEvent()
        ..profileId = bill.profileId
        ..billGuid = bill.syncGuid
        ..kind = MedicalSettlementKind.closure
        ..confirmed = true
        ..effectiveDate = clock().toUtc()
        ..recordedAt = clock().toUtc()
        ..currency = expense.currencyCode!.code
        ..amountMinor = 0
        ..basisJson = medicalBillBasis(bill)
        ..expenseId = expense.id
        ..expenseGuid = expense.syncGuid
        ..reason = reason.trim()
        ..actorId = actorId
        ..operationIdentity = identity
        ..inputFingerprint = fingerprint;
      event.id = await AuditRepository(db, recorder: recorder, actorId: actorId)
          .put(db.medicalSettlements, event,
              id: event.id, type: 'MedicalSettlementEvent', derived: false);
      AppLogger.medicalSettlement(
          'CLOSE_DONE billGuid=${bill.syncGuid} guid=${event.syncGuid}');
      return event;
    });
  }

  /// Reviewed reversal. Keeps the original row and appends a link instead.
  Future<MedicalSettlementEvent> reverse({
    required String eventGuid,
    required int actorId,
    required String reason,
    required String operationKey,
    required bool Function() isAccessCurrent,
  }) async {
    return db.writeTxn(() async {
      if (!isAccessCurrent()) {
        throw const MedicalSettlementException('accessChanged');
      }
      if (reason.trim().isEmpty || reason.trim().length > 240) {
        throw const MedicalSettlementException('reasonRequired');
      }
      final original = await db.medicalSettlements
          .filter()
          .syncGuidEqualTo(eventGuid)
          .findFirst();
      if (original == null ||
          original.profileId == null ||
          original.profileId != actorId) {
        throw const MedicalSettlementException('notFound');
      }
      if (original.kind == MedicalSettlementKind.reversal) {
        throw const MedicalSettlementException('invalidReversal');
      }
      final bill = await db.medicalBills
          .filter()
          .syncGuidEqualTo(original.billGuid)
          .findFirst();
      if (bill != null &&
          await SpaceWriteGuard(db).monthIsSealed(bill.yearMonth)) {
        throw const MedicalSettlementException('sealedMonth');
      }
      final fingerprint = _hash([
        original.syncGuid,
        MedicalSettlementKind.reversal.name,
        reason.trim(),
      ]);
      final identity =
          'medical-settlement:reverse:${original.syncGuid}:$operationKey';
      final replay = await _replay(identity, fingerprint);
      if (replay != null) return replay;
      if (await _isReversed(original.syncGuid)) {
        throw const MedicalSettlementException('alreadyReversed');
      }
      final event = MedicalSettlementEvent()
        ..profileId = original.profileId
        ..billGuid = original.billGuid
        ..kind = MedicalSettlementKind.reversal
        ..confirmed = true
        ..effectiveDate = clock().toUtc()
        ..recordedAt = clock().toUtc()
        ..currency = original.currency
        ..amountMinor = 0
        ..basisJson = original.basisJson
        ..expenseId = original.expenseId
        ..expenseGuid = original.expenseGuid
        ..supersedesGuid = original.syncGuid
        ..reason = reason.trim()
        ..actorId = actorId
        ..operationIdentity = identity
        ..inputFingerprint = fingerprint;
      event.id = await AuditRepository(db, recorder: recorder, actorId: actorId)
          .put(db.medicalSettlements, event,
              id: event.id, type: 'MedicalSettlementEvent', derived: false);
      return event;
    });
  }

  Future<List<MedicalSettlementEvent>> eventsForBill(String billGuid) async {
    final rows = await _events(billGuid);
    return rows..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
  }

  Future<MedicalBill> _bill(int billId, int actorId) async {
    final bill = await db.medicalBills.get(billId);
    if (bill == null) throw const MedicalSettlementException('notFound');
    if (bill.sharedSpaceId != null) {
      throw const MedicalSettlementException('sharedNotSupported');
    }
    if (bill.profileId == null || bill.profileId != actorId) {
      throw const MedicalSettlementException('wrongOwner');
    }
    if (bill.paymentMethod != MedicalPaymentMethod.insurerPaid) {
      throw const MedicalSettlementException('notInsurerPaid');
    }
    return bill;
  }

  Future<Expense> _expense(MedicalBill bill) async {
    final expense = bill.linkedExpenseId == null
        ? null
        : await db.expenses.get(bill.linkedExpenseId!);
    if (expense == null ||
        expense.type != ExpenseType.medical ||
        expense.profileId != bill.profileId ||
        expense.sharedSpaceId != null) {
      throw const MedicalSettlementException('missingExpense');
    }
    return expense;
  }

  void _validateBill(MedicalBill bill, Expense expense) {
    if (expense.currencyCode == null ||
        bill.billedAmount <= 0 ||
        !bill.patientSharePercent.isFinite ||
        bill.patientSharePercent < 0 ||
        bill.patientSharePercent > 100 ||
        (bill.currencyCode != null &&
            bill.currencyCode != expense.currencyCode)) {
      throw const MedicalSettlementException('legacyNeedsReview');
    }
  }

  void _validateDate(DateTime effectiveDate) {
    if (effectiveDate.isAfter(clock())) {
      throw const MedicalSettlementException('futureDate');
    }
  }

  Future<List<MedicalSettlementEvent>> _events(String billGuid) =>
      db.medicalSettlements.filter().billGuidEqualTo(billGuid).findAll();

  Future<bool> _hasClosure(String billGuid) async =>
      activeSettlements(await _events(billGuid))
          .any((e) => e.kind == MedicalSettlementKind.closure);

  Future<bool> _activeWithholding(String billGuid) async {
    final rows = await db.medicalWithholdingMatchs
        .filter()
        .billGuidEqualTo(billGuid)
        .findAll();
    return rows.any((m) => !m.reversed);
  }

  Future<bool> _isReversed(String eventGuid) async {
    final rows = await db.medicalSettlements
        .filter()
        .supersedesGuidEqualTo(eventGuid)
        .findAll();
    return rows.any((e) => e.kind == MedicalSettlementKind.reversal);
  }

  Future<MedicalSettlementEvent?> _replay(
      String identity, String fingerprint) async {
    final row = await db.medicalSettlements
        .filter()
        .operationIdentityEqualTo(identity)
        .findFirst();
    if (row == null) return null;
    if (row.inputFingerprint != fingerprint) {
      throw const MedicalSettlementException('replayMismatch');
    }
    return row;
  }
}
