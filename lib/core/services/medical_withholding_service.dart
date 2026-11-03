import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';

import '../logging/app_logger.dart';
import '../models/expense.dart';
import '../models/income_receipt_group.dart';
import '../models/medical_approval.dart';
import '../models/medical_bill.dart';
import '../models/medical_settlement_event.dart';
import '../models/medical_withholding_match.dart';
import 'medical_settlement_service.dart';
import '../../features/finance/repositories/audit_repository.dart';
import '../../features/spaces/repositories/space_write_guard.dart';
import '../../features/sync/repositories/sync_recorder.dart';

class MedicalWithholdingException implements Exception {
  const MedicalWithholdingException(this.code);
  final String code;
  @override
  String toString() => 'MedicalWithholdingException: $code';
}

class MedicalWithholdingService {
  MedicalWithholdingService(this.db,
      {this.recorder, DateTime Function()? clock})
      : clock = clock ?? DateTime.now;
  final Isar db;
  final SyncRecorder? recorder;
  final DateTime Function() clock;

  static String _hash(Object value) =>
      sha256.convert(utf8.encode(jsonEncode(value))).toString();

  /// Creates an owner-only link between a salary receipt and a Medical bill's
  /// patient share. The withheld amount is the full eligible share in this
  /// release; partial or mixed settlement is refused. Never infers from salary
  /// variance (FR-049).
  Future<MedicalWithholdingMatch> match({
    required int profileId,
    required String billGuid,
    required String salaryReceiptGroupGuid,
    required int withheldMinor,
    required String currency,
    required List<String> affectedMonths,
    int? eligibleUnpaidShare,
    required bool Function() isAccessCurrent,
  }) async {
    AppLogger.medicalWithholding(
        'MATCH_START billGuid=$billGuid profileId=$profileId receiptGroupGuid=$salaryReceiptGroupGuid withheldMinor=$withheldMinor currency=$currency affectedMonths=$affectedMonths eligibleUnpaidShare=$eligibleUnpaidShare');
    if (!isAccessCurrent()) {
      throw const MedicalWithholdingException('accessChanged');
    }
    if (withheldMinor <= 0) {
      throw const MedicalWithholdingException('invalidAmount');
    }
    for (final m in affectedMonths) {
      if (!RegExp(r'^[1-9][0-9]{3}-(0[1-9]|1[0-2])$').hasMatch(m)) {
        throw const MedicalWithholdingException('invalidMonth');
      }
      if (await SpaceWriteGuard(db).monthIsSealed(m)) {
        throw const MedicalWithholdingException('sealedMonth');
      }
    }

    final bill = await db.medicalBills
        .filter()
        .syncGuidEqualTo(billGuid)
        .findFirst();
    if (bill == null ||
        bill.profileId == null ||
        bill.profileId != profileId) {
      throw const MedicalWithholdingException('wrongOwner');
    }
    if (bill.sharedSpaceId != null) {
      throw const MedicalWithholdingException('sharedNotSupported');
    }
    if (bill.paymentMethod != MedicalPaymentMethod.insurerPaid) {
      throw const MedicalWithholdingException('notInsurerPaid');
    }
    final billCurrency = bill.currencyCode;
    if (billCurrency != null && billCurrency.code != currency) {
      throw const MedicalWithholdingException('currencyMismatch');
    }
    final receipt = await db.incomeReceiptGroups
        .getByGuid(salaryReceiptGroupGuid);
    if (receipt == null ||
        receipt.profileId == null ||
        receipt.profileId != profileId) {
      throw const MedicalWithholdingException('receiptNotFound');
    }
    if (receipt.currency.toLowerCase() != currency.toLowerCase()) {
      throw const MedicalWithholdingException('currencyMismatch');
    }
    final activities = await db.medicalClaimActivitys
        .filter()
        .billGuidEqualTo(billGuid)
        .findAll();
    if (activities.any((a) => a.kind == 'cancelled' || a.kind == 'removed')) {
      throw const MedicalWithholdingException('claimClosed');
    }
    final settlements = await db.medicalSettlements
        .filter()
        .billGuidEqualTo(billGuid)
        .findAll();
    final active = activeSettlements(settlements);
    if (active.any((e) => e.kind == MedicalSettlementKind.closure)) {
      throw const MedicalWithholdingException('claimClosed');
    }

    final existing = await db.medicalWithholdingMatchs
        .filter()
        .billGuidEqualTo(billGuid)
        .findAll();
    final existingReceipt = await db.medicalWithholdingMatchs
        .filter()
        .salaryReceiptGroupGuidEqualTo(salaryReceiptGroupGuid)
        .findAll();
    final same = existing
        .where((m) =>
            !m.reversed &&
            m.salaryReceiptGroupGuid == salaryReceiptGroupGuid &&
            m.withheldMinor == withheldMinor &&
            m.currency == currency)
        .firstOrNull;
    if (same != null) {
      // Identical retry: return the prior outcome without another write.
      await _ensureSettlement(
          bill: bill, match: same, isAccessCurrent: isAccessCurrent);
      return same;
    }
    if (active.any((e) => e.kind == MedicalSettlementKind.shareSettlement)) {
      throw const MedicalWithholdingException('alreadySettled');
    }
    if (existing.any((m) => !m.reversed) ||
        existingReceipt.any((m) => !m.reversed)) {
      throw const MedicalWithholdingException('alreadyMatched');
    }

    final alreadyWithheld = existing
        .where((m) => !m.reversed)
        .fold<int>(0, (sum, m) => sum + m.withheldMinor);
    final remaining = (bill.patientShareAmount - alreadyWithheld)
        .clamp(0, bill.patientShareAmount);
    if (eligibleUnpaidShare != null && eligibleUnpaidShare != remaining) {
      throw const MedicalWithholdingException('staleEligibility');
    }
    if (withheldMinor > remaining) {
      throw const MedicalWithholdingException('overmatched');
    }
    if (withheldMinor != remaining) {
      throw const MedicalWithholdingException('partialUnsupported');
    }

    final now = clock().toUtc();
    final match = MedicalWithholdingMatch()
      ..profileId = profileId
      ..billGuid = billGuid
      ..salaryReceiptGroupGuid = salaryReceiptGroupGuid
      ..withheldMinor = withheldMinor
      ..currency = currency
      ..affectedMonths = List<String>.from(affectedMonths)
      ..reversed = false
      ..createdAt = now
      ..updatedAt = now;

    await db.writeTxn(() async {
      if (!isAccessCurrent()) {
        throw const MedicalWithholdingException('accessChanged');
      }
      // Recheck under the transaction so two concurrent links cannot both win.
      final raced = await db.medicalWithholdingMatchs
          .filter()
          .billGuidEqualTo(billGuid)
          .findAll();
      final receiptRace = await db.medicalWithholdingMatchs
          .filter()
          .salaryReceiptGroupGuidEqualTo(salaryReceiptGroupGuid)
          .findAll();
      if (raced.any((m) => !m.reversed) ||
          receiptRace.any((m) => !m.reversed)) {
        throw const MedicalWithholdingException('alreadyMatched');
      }
      final racedSettlements = await db.medicalSettlements
          .filter()
          .billGuidEqualTo(billGuid)
          .findAll();
      if (activeSettlements(racedSettlements)
          .any((e) => e.kind == MedicalSettlementKind.shareSettlement)) {
        throw const MedicalWithholdingException('alreadySettled');
      }
      match.id = await AuditRepository(db, recorder: recorder, actorId: profileId)
          .put(db.medicalWithholdingMatchs, match,
              id: match.id, type: 'MedicalWithholdingMatch', derived: false);
      await _writeSettlement(
          bill: bill, match: match, actorId: profileId, now: now);
    });
    AppLogger.medicalWithholding(
        'MATCH_DONE billGuid=$billGuid receiptGroupGuid=$salaryReceiptGroupGuid withheldMinor=$withheldMinor matchGuid=${match.guid}');
    return match;
  }

  Future<void> _ensureSettlement({
    required MedicalBill bill,
    required MedicalWithholdingMatch match,
    required bool Function() isAccessCurrent,
  }) async {
    final rows = await db.medicalSettlements
        .filter()
        .withholdingMatchGuidEqualTo(match.guid)
        .findAll();
    if (rows.any((e) => e.kind == MedicalSettlementKind.shareSettlement)) {
      return;
    }
    await db.writeTxn(() async {
      if (!isAccessCurrent()) {
        throw const MedicalWithholdingException('accessChanged');
      }
      await _writeSettlement(
          bill: bill,
          match: match,
          actorId: match.profileId ?? 0,
          now: match.createdAt);
    });
  }

  Future<void> _writeSettlement({
    required MedicalBill bill,
    required MedicalWithholdingMatch match,
    required int actorId,
    required DateTime now,
  }) async {
    final expense = bill.linkedExpenseId == null
        ? null
        : await db.expenses.get(bill.linkedExpenseId!);
    final event = MedicalSettlementEvent()
      ..profileId = match.profileId
      ..billGuid = match.billGuid
      ..kind = MedicalSettlementKind.shareSettlement
      ..confirmed = true
      ..effectiveDate = now
      ..recordedAt = now
      ..currency = match.currency
      ..amountMinor = match.withheldMinor
      ..expenseId = expense?.id
      ..expenseGuid = expense?.syncGuid
      ..withholdingMatchGuid = match.guid
      ..reason = ''
      ..actorId = actorId
      ..operationIdentity = 'medical-settlement:withholding:${match.guid}'
      ..inputFingerprint = _hash([
        match.billGuid,
        match.guid,
        match.salaryReceiptGroupGuid,
        match.withheldMinor,
        match.currency,
      ]);
    event.id = await AuditRepository(db, recorder: recorder, actorId: actorId)
        .put(db.medicalSettlements, event,
            id: event.id, type: 'MedicalSettlementEvent', derived: false);
  }

  /// Reverses an existing match. Requires a reason. The original and its
  /// settlement evidence stay in place; a reversal row records the change.
  Future<MedicalWithholdingMatch> reverse({
    required String matchGuid,
    required String reason,
    required bool Function() isAccessCurrent,
  }) async {
    AppLogger.medicalWithholding(
        'REVERSE_START matchGuid=$matchGuid reason=$reason');
    if (!isAccessCurrent()) {
      throw const MedicalWithholdingException('accessChanged');
    }
    if (reason.trim().isEmpty || reason.trim().length > 240) {
      throw const MedicalWithholdingException('reasonRequired');
    }
    final match = await db.medicalWithholdingMatchs
        .filter()
        .guidEqualTo(matchGuid)
        .findFirst();
    if (match == null) {
      throw const MedicalWithholdingException('notFound');
    }
    if (match.reversed) {
      throw const MedicalWithholdingException('alreadyReversed');
    }
    for (final m in match.affectedMonths) {
      if (await SpaceWriteGuard(db).monthIsSealed(m)) {
        throw const MedicalWithholdingException('sealedMonth');
      }
    }
    final now = clock().toUtc();
    final reversal = MedicalWithholdingMatch()
      ..profileId = match.profileId
      ..billGuid = match.billGuid
      ..salaryReceiptGroupGuid = match.salaryReceiptGroupGuid
      ..withheldMinor = -match.withheldMinor
      ..currency = match.currency
      ..affectedMonths = List<String>.from(match.affectedMonths)
      ..reversed = true
      ..reversalGuid = match.guid
      ..reversalReason = reason.trim()
      ..createdAt = now
      ..updatedAt = now;

    await db.writeTxn(() async {
      if (!isAccessCurrent()) {
        throw const MedicalWithholdingException('accessChanged');
      }
      final current = await db.medicalWithholdingMatchs
          .filter()
          .guidEqualTo(matchGuid)
          .findFirst();
      if (current == null || current.reversed) {
        throw const MedicalWithholdingException('alreadyReversed');
      }
      current.reversed = true;
      current.reversalGuid = reversal.guid;
      current.reversalReason = reason.trim();
      current.updatedAt = now;
      await db.medicalWithholdingMatchs.put(current);
      reversal.id = await AuditRepository(db,
              recorder: recorder, actorId: current.profileId ?? 0)
          .put(db.medicalWithholdingMatchs, reversal,
              id: reversal.id, type: 'MedicalWithholdingMatch', derived: false);
      final settlements = await db.medicalSettlements
          .filter()
          .withholdingMatchGuidEqualTo(matchGuid)
          .findAll();
      for (final original in settlements
          .where((e) => e.kind == MedicalSettlementKind.shareSettlement)) {
        final already = await db.medicalSettlements
            .filter()
            .supersedesGuidEqualTo(original.syncGuid)
            .findAll();
        if (already.any((e) => e.kind == MedicalSettlementKind.reversal)) {
          continue;
        }
        final event = MedicalSettlementEvent()
          ..profileId = original.profileId
          ..billGuid = original.billGuid
          ..kind = MedicalSettlementKind.reversal
          ..confirmed = true
          ..effectiveDate = now
          ..recordedAt = now
          ..currency = original.currency
          ..amountMinor = 0
          ..basisJson = original.basisJson
          ..expenseId = original.expenseId
          ..expenseGuid = original.expenseGuid
          ..supersedesGuid = original.syncGuid
          ..reason = reason.trim()
          ..actorId = current.profileId ?? 0
          ..operationIdentity =
              'medical-settlement:withholding-reverse:${reversal.guid}:${original.syncGuid}'
          ..inputFingerprint =
              _hash([original.syncGuid, reversal.guid, reason.trim()]);
        event.id = await AuditRepository(db,
                recorder: recorder, actorId: current.profileId ?? 0)
            .put(db.medicalSettlements, event,
                id: event.id, type: 'MedicalSettlementEvent', derived: false);
      }
    });
    AppLogger.medicalWithholding(
        'REVERSE_DONE matchGuid=${match.guid} reversalGuid=${reversal.guid}');
    return reversal;
  }

  /// Returns all non-reversed matches for a bill.
  Future<List<MedicalWithholdingMatch>> matchesForBill(String billGuid) async {
    final all = await db.medicalWithholdingMatchs
        .filter()
        .billGuidEqualTo(billGuid)
        .findAll();
    return all.where((m) => !m.reversed).toList();
  }

  /// Returns all non-reversed matches for a salary receipt group.
  Future<List<MedicalWithholdingMatch>> matchesForReceipt(
      String receiptGroupGuid) async {
    final all = await db.medicalWithholdingMatchs
        .filter()
        .salaryReceiptGroupGuidEqualTo(receiptGroupGuid)
        .findAll();
    return all.where((m) => !m.reversed).toList();
  }
}
