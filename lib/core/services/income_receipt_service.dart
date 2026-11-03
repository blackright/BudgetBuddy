import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';

import '../models/currency_code.dart';
import '../models/fx_revision.dart';
import '../models/income_receipt_group.dart';
import '../models/income_source.dart';
import '../models/money_receipt.dart';
import '../models/monthly_budget.dart';
import '../models/salary_cycle.dart';
import '../models/user_profile.dart';
import '../../features/finance/repositories/audit_repository.dart';
import '../../features/pending_actions/services/pending_action_service.dart';
import '../../features/sync/domain/sync_guid.dart';
import '../../features/sync/repositories/sync_recorder.dart';
import 'salary_receipt_service.dart';

class IncomeReceiptException implements Exception {
  const IncomeReceiptException(this.code);
  final String code;
  @override
  String toString() => 'IncomeReceiptException: $code';
}

class IncomeReceiptPreview {
  const IncomeReceiptPreview({
    required this.source,
    required this.cycle,
    required this.amountMinor,
    required this.actualDate,
    required this.timezone,
    required this.cashMonth,
    required this.currency,
    this.note = '',
  });

  final IncomeSource source;
  final SalaryCycle cycle;
  final int amountMinor;
  final DateTime actualDate;
  final String timezone;
  final String cashMonth;
  final CurrencyCode currency;
  final String note;

  int get totalMinor => amountMinor;
}

/// Confirms a non-salary income receipt as one explicit bank-credit event.
///
/// Salary keeps its own, richer confirmation flow. This service reuses the
/// existing receipt group and component collections so no schema is added.
class IncomeReceiptService {
  IncomeReceiptService(
    this.db, {
    this.pendingActions,
    this.recorder,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  final Isar db;
  final PendingActionService? pendingActions;
  final SyncRecorder? recorder;
  final DateTime Function() clock;

  Future<IncomeReceiptPreview> preview({
    required IncomeSource source,
    required SalaryCycle cycle,
    required int amountMinor,
    required DateTime actualDate,
    required String timezone,
    String note = '',
    required bool Function() isAccessCurrent,
  }) async {
    if (!isAccessCurrent()) {
      throw const IncomeReceiptException('accessChanged');
    }
    if (source.profileId == null ||
        source.sharedSpaceId != null ||
        source.type == IncomeSourceType.salary) {
      throw const IncomeReceiptException('wrongOwner');
    }
    if (cycle.sourceGuid != source.syncGuid ||
        cycle.profileId != source.profileId ||
        cycle.confirmed) {
      throw const IncomeReceiptException('alreadyConfirmed');
    }
    if (amountMinor <= 0 || actualDate.isAfter(clock())) {
      throw const IncomeReceiptException('invalidAmount');
    }
    final currency = CurrencyCode.tryParse(source.currency);
    if (currency == null) {
      throw const IncomeReceiptException('unsupportedCurrency');
    }
    final owner = await db.userProfiles.get(source.profileId!);
    if (owner == null) {
      throw const IncomeReceiptException('wrongOwner');
    }
    if (owner.primaryCurrency.code != currency) {
      throw const IncomeReceiptException('currencyMismatch');
    }
    final String cashMonth;
    try {
      cashMonth = SalaryReceiptService.cashMonthFor(actualDate, timezone);
    } catch (_) {
      throw const IncomeReceiptException('invalidTimezone');
    }
    if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(cashMonth)) {
      throw const IncomeReceiptException('invalidTimezone');
    }
    final month = await db.monthlyBudgets
        .filter()
        .profileIdEqualTo(source.profileId)
        .yearMonthEqualTo(cashMonth)
        .findFirst();
    if (month == null) {
      throw const IncomeReceiptException('missingMonth');
    }
    if (!month.openingBalanceConfirmed) {
      throw const IncomeReceiptException('openingReviewRequired');
    }
    return IncomeReceiptPreview(
      source: source,
      cycle: cycle,
      amountMinor: checkedFxMinor(amountMinor),
      actualDate: actualDate,
      timezone: timezone,
      cashMonth: cashMonth,
      currency: currency,
      note: note.trim(),
    );
  }

  Future<IncomeReceiptGroup> confirm({
    required IncomeReceiptPreview preview,
    required String operationKey,
    required bool Function() isAccessCurrent,
  }) async {
    if (!isAccessCurrent() || operationKey.trim().isEmpty) {
      throw const IncomeReceiptException('accessChanged');
    }
    final group = await db.writeTxn(() async {
      final liveCycle = await db.salaryCycles
          .filter()
          .guidEqualTo(preview.cycle.guid)
          .findFirst();
      if (liveCycle == null) {
        throw const IncomeReceiptException('missingCycle');
      }
      final source = await db.incomeSources
          .filter()
          .syncGuidEqualTo(preview.source.syncGuid)
          .findFirst();
      if (source == null ||
          source.profileId != preview.source.profileId ||
          source.sharedSpaceId != null ||
          source.type == IncomeSourceType.salary) {
        throw const IncomeReceiptException('wrongOwner');
      }
      final identity =
          'income-receipt:${preview.source.syncGuid}:${preview.cycle.guid}';
      final fingerprint = _hash([
        preview.source.syncGuid,
        preview.cycle.guid,
        preview.amountMinor,
        preview.actualDate.toIso8601String(),
        preview.cashMonth,
        preview.currency.code,
        preview.note,
      ]);
      final old = await db.incomeReceiptGroups
          .filter()
          .operationIdentityEqualTo(identity)
          .findFirst();
      if (old != null) {
        if (old.fingerprint != fingerprint) {
          throw const IncomeReceiptException('duplicateMismatch');
        }
        return old;
      }
      if (liveCycle.confirmed) {
        throw const IncomeReceiptException('alreadyConfirmed');
      }
      final audit = AuditRepository(db,
          recorder: recorder, actorId: preview.source.profileId);
      final now = clock().toUtc();
      final groupGuid = newSyncGuid();
      final receipt = MoneyReceipt()
        ..billGuid = ''
        ..profileId = preview.source.profileId
        ..kind = 'income'
        ..actorId = preview.source.profileId!
        ..createdAt = now
        ..operationIdentity = '$identity:receipt'
        ..inputFingerprint = fingerprint;
      await audit.put(db.moneyReceipts, receipt,
          id: receipt.id, type: 'MoneyReceipt', derived: false);
      final revision = ReceiptRevision()
        ..receiptGuid = receipt.syncGuid
        ..billGuid = ''
        ..profileId = preview.source.profileId
        ..yearMonth = preview.cashMonth
        ..recordedAt = now
        ..actorId = preview.source.profileId!
        ..operationIdentity = '$identity:revision'
        ..inputFingerprint = fingerprint
        ..evidenceJson = jsonEncode({
          'kind': 'income',
          'groupGuid': groupGuid,
          'sourceGuid': preview.source.syncGuid,
          'cycleGuid': preview.cycle.guid,
          'amountMinor': preview.amountMinor,
          'currency': preview.currency.code,
          'destinationMonth': preview.cashMonth,
          'actualDate': preview.actualDate.toIso8601String(),
          'note': preview.note,
        });
      await audit.put(db.receiptRevisions, revision,
          id: revision.id, type: 'ReceiptRevision', derived: false);
      // The audit row verifies the group through the ledger, so the cycle must
      // already point at this group before the group itself is audited.
      liveCycle
        ..confirmed = true
        ..receiptGroupGuid = groupGuid
        ..state = 'confirmed'
        ..updatedAt = now;
      await db.salaryCycles.put(liveCycle);
      final row = IncomeReceiptGroup()
        ..guid = groupGuid
        ..profileId = preview.source.profileId
        ..sourceGuid = preview.source.syncGuid
        ..cycleGuid = preview.cycle.guid
        ..actualDate = preview.actualDate
        ..timezone = preview.timezone
        ..totalMinor = preview.amountMinor
        ..currency = preview.currency.code
        ..destinationMonth = preview.cashMonth
        ..componentReceiptGuids = [receipt.syncGuid]
        ..componentRevisionRefs = [revision.syncGuid]
        ..fingerprint = fingerprint
        ..operationIdentity = identity
        ..createdAt = now
        ..updatedAt = now;
      await audit.put(db.incomeReceiptGroups, row,
          id: row.id, type: 'IncomeReceiptGroup', derived: false);
      await audit.append(
          profileId: preview.source.profileId!,
          action: 'income.confirm',
          objectType: 'IncomeSource',
          objectGuid: preview.source.syncGuid,
          after: {
            'amountMinor': preview.amountMinor,
            'cashMonth': preview.cashMonth,
            'groupGuid': groupGuid,
          },
          requestId: operationKey);
      return row;
    });
    final service = pendingActions;
    if (service != null) {
      for (final actionType in const ['income.confirm', 'income.complete']) {
        try {
          await service.completeByRecord(
              actionType, preview.cycle.guid, preview.cycle.occurrenceMonth);
        } catch (_) {
          // Attention completion is best-effort; the money is already committed.
        }
      }
    }
    return group;
  }

  String _hash(List<Object?> parts) =>
      sha256.convert(utf8.encode(parts.join('|'))).toString();
}

/// Month existence check kept separate so the UI can explain it clearly.
Future<bool> incomeMonthIsOpen(Isar db, int profileId, String yearMonth) async {
  final month = await db.monthlyBudgets
      .filter()
      .profileIdEqualTo(profileId)
      .yearMonthEqualTo(yearMonth)
      .findFirst();
  return month != null && month.openingBalanceConfirmed;
}
