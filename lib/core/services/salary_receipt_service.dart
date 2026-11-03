import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';
import '../models/currency_code.dart';
import '../models/income_source.dart';
import '../models/salary_cycle.dart';
import '../models/income_receipt_group.dart';
import '../models/medical_bill.dart';
import '../models/month_rate_seal.dart';
import '../models/money_receipt.dart';
import '../models/period_funding_assignment.dart';
import '../models/balance_checkpoint.dart';
import '../models/reconciliation_snapshot.dart';
import '../providers/budget_context_provider.dart';
import '../../features/finance/repositories/audit_repository.dart';
import '../../features/pending_actions/services/pending_action_service.dart';
import '../../features/sync/domain/sync_guid.dart';
import '../../features/sync/repositories/sync_recorder.dart';
import 'medical_receipt_service.dart';
import 'income_receipt_ledger.dart';
import 'balance_checkpoint_service.dart';
import 'receipt_snapshot_repository.dart';
import '../models/fx_revision.dart';

class SalaryReceiptException implements Exception {
  const SalaryReceiptException(this.code);
  final String code;
  @override
  String toString() => 'SalaryReceiptException: $code';
}

class SalaryReceiptPreview {
  SalaryReceiptPreview._(
      this.source,
      this.cycle,
      this.actorId,
      this.salaryMinor,
      this.medicalMinor,
      this.actualDate,
      this.timezone,
      this.cashMonth,
      this.claimAmounts,
      this.medicalPreviews,
      this.fingerprint,
      this.months,
      this.groupGuid,
      this.alreadyIncluded);
  final IncomeSource source;
  final SalaryCycle cycle;
  final int actorId, salaryMinor, medicalMinor;
  int get totalMinor => checkedFxMinor(salaryMinor + medicalMinor);
  String get currency => source.currency.toLowerCase();
  final DateTime actualDate;
  final String timezone, cashMonth, fingerprint, groupGuid;

  /// The month the salary is posted to. New confirmations always use the
  /// actual cash month; legacy groups keep their stored destination month.
  String get destinationMonth => cashMonth;
  final Map<String, int> claimAmounts;
  List<String> get selectedClaimGuids => List.unmodifiable(claimAmounts.keys);
  final List<MedicalReceiptPreview> medicalPreviews;
  final List<ReceiptSourceSnapshot> months;
  final bool alreadyIncluded;
}

/// Coordinates one cash event and its independently classified components.
/// Previews are read-only. All validation and posting share one write transaction.
class SalaryReceiptService {
  SalaryReceiptService(this.db,
      {this.recorder, this.pendingActions, DateTime Function()? clock})
      : clock = clock ?? DateTime.now;
  final Isar db;
  final SyncRecorder? recorder;

  /// Attention only. Completion runs after the salary transaction commits and
  /// never blocks the saved money.
  final PendingActionService? pendingActions;
  final DateTime Function() clock;
  static String _hash(Object value) =>
      sha256.convert(utf8.encode(jsonEncode(value))).toString();

  /// The calendar month of [actualDate] in [timezone], using the same
  /// derivation as a posted receipt.
  static String cashMonthFor(DateTime actualDate, String timezone) =>
      IncomeReceiptLedger.cashMonth(IncomeReceiptGroup()
        ..actualDate = actualDate
        ..timezone = timezone);

  Future<SalaryCycle> prepareCycle(
      {required IncomeSource source,
      required int actorId,
      required String month}) async {
    if (source.profileId != actorId || source.sharedSpaceId != null) {
      throw const SalaryReceiptException('wrongOwner');
    }
    final old = await db.salaryCycles
        .filter()
        .sourceGuidEqualTo(source.syncGuid)
        .occurrenceMonthEqualTo(month)
        .findFirst();
    return old ??
        (SalaryCycle()
          ..guid = 'salary-cycle:${source.syncGuid}:$month'
          ..profileId = actorId
          ..sourceGuid = source.syncGuid
          ..scheduleGuid = 'manual:${source.syncGuid}'
          ..expectedAmountMinor = source.amount
          ..currency = source.currency
          ..occurrenceMonth = month
          ..nominalPayday = clock()
          ..adjustedPayday = clock()
          ..createdAt = clock().toUtc()
          ..updatedAt = clock().toUtc());
  }

  Future<SalaryReceiptPreview> preview(
          {required int actorId,
          required String sourceGuid,
          required String cycleGuid,
          required int salaryMinor,
          int medicalMinor = 0,
          required DateTime actualDate,
          String timezone = 'UTC',
          required List<String> selectedClaimGuids,
          Map<String, int>? claimAmounts,
          Map<String, String>? expectedApprovalGuids,
          SalaryCycle? cycleDraft,
          bool alreadyIncluded = false,
          required bool Function() isAccessCurrent}) =>
      db.txn(() => _preview(
          actorId,
          sourceGuid,
          cycleGuid,
          salaryMinor,
          medicalMinor,
          actualDate,
          timezone,
          selectedClaimGuids,
          claimAmounts,
          cycleDraft,
          newSyncGuid(),
          alreadyIncluded,
          isAccessCurrent,
          expectedApprovals: expectedApprovalGuids));

  Future<SalaryReceiptPreview> _preview(
      int actor,
      String sourceGuid,
      String cycleGuid,
      int salary,
      int medical,
      DateTime date,
      String zone,
      List<String> selected,
      Map<String, int>? amounts,
      SalaryCycle? draft,
      String groupGuid,
      bool included,
      bool Function() access,
      {Map<String, String>? expectedApprovals}) async {
    if (!access() || actor <= 0) {
      throw const SalaryReceiptException('accessChanged');
    }
    if (medical != 0 ||
        selected.isNotEmpty ||
        (amounts != null && amounts.isNotEmpty)) {
      throw const SalaryReceiptException('medicalReceiptMoved');
    }
    checkedFxMinor(salary);
    checkedFxMinor(medical);
    // A future bank credit is not cash yet; reject it before any month lookup.
    if (salary <= 0 ||
        medical < 0 ||
        date.isAfter(clock()) ||
        selected.toSet().length != selected.length) {
      throw const SalaryReceiptException('invalidAmount');
    }
    final String cashMonth;
    try {
      cashMonth = cashMonthFor(date, zone);
    } catch (_) {
      throw const SalaryReceiptException('invalidTimezone');
    }
    if (!_validMonth(cashMonth)) {
      throw const SalaryReceiptException('invalidTimezone');
    }
    final source =
        await db.incomeSources.filter().syncGuidEqualTo(sourceGuid).findFirst();
    if (source == null || source.type != IncomeSourceType.salary) {
      throw const SalaryReceiptException('missingSource');
    }
    if (source.profileId != actor || source.sharedSpaceId != null) {
      throw const SalaryReceiptException('wrongOwner');
    }
    final cycle =
        await db.salaryCycles.filter().guidEqualTo(cycleGuid).findFirst() ??
            draft;
    if (cycle == null ||
        cycle.sourceGuid != sourceGuid ||
        cycle.profileId != actor ||
        cycle.currency != source.currency ||
        !_validMonth(cycle.occurrenceMonth)) {
      throw const SalaryReceiptException('missingCycle');
    }
    if (cycle.confirmed) throw const SalaryReceiptException('alreadyConfirmed');
    final peers = await db.salaryCycles
        .filter()
        .sourceGuidEqualTo(sourceGuid)
        .occurrenceMonthEqualTo(cycle.occurrenceMonth)
        .findAll();
    if (peers.any((c) => c.guid != cycle.guid)) {
      throw const SalaryReceiptException('stalePreview');
    }
    final currency = CurrencyCode.tryParse(source.currency);
    if (currency == null) {
      throw const SalaryReceiptException('unsupportedCurrency');
    }
    final snap = await ReceiptSnapshotRepository(db, clock: clock)
        .readInTransaction(
            context:
                ContextRef.personal(profileId: actor, yearMonth: cashMonth),
            actorId: actor,
            isAccessCurrent: access);
    if (snap.currency != currency) {
      throw const SalaryReceiptException('currencyMismatch');
    }
    if (snap.blockers.isNotEmpty) {
      throw SalaryReceiptException(snap.blockers.first.name);
    }
    final months = <ReceiptSourceSnapshot>[snap];
    final cashContext =
        ContextRef.personal(profileId: actor, yearMonth: cashMonth);
    final cash = await BalanceCheckpointService(db, clock: clock)
        .loadInTransaction(
            context: cashContext, actorId: actor, isAccessCurrent: access);
    await BalanceCheckpointService(db, clock: clock).cashInTransaction(
        context: cashContext, actorId: actor, isAccessCurrent: access);
    if (cash.previous == null ||
        included == date.isAfter(cash.previous!.balanceAsOf)) {
      throw const SalaryReceiptException('openingReviewRequired');
    }
    final medicalService =
        MedicalReceiptService(db, recorder: recorder, clock: clock);
    final receipts = <MedicalReceiptPreview>[];
    final selectedAmounts = <String, int>{};
    var sum = 0;
    for (final guid in [...selected]..sort()) {
      final bill =
          await db.medicalBills.filter().syncGuidEqualTo(guid).findFirst();
      if (bill == null ||
          bill.profileId != actor ||
          bill.sharedSpaceId != null) {
        throw const SalaryReceiptException('wrongOwner');
      }
      final history = await medicalService.historyInTransaction(
          billId: bill.id,
          actorId: actor,
          isAccessCurrent: access,
          write: true);
      if (expectedApprovals != null &&
          expectedApprovals[guid] != history.approval?.syncGuid) {
        throw const SalaryReceiptException('stalePreview');
      }
      final amount = amounts?[guid] ?? history.remainingMinor;
      if (bill.currencyCode != currency ||
          amount <= 0 ||
          amount > history.remainingMinor) {
        throw const SalaryReceiptException('claimNeedsReview');
      }
      final receipt = await medicalService.previewInTransaction(
          billId: bill.id,
          actorId: actor,
          amountMinor: amount,
          receivedAt: date,
          destinationMonth: cashMonth,
          localZone: zone,
          groupGuid: groupGuid,
          alreadyIncluded: included,
          isAccessCurrent: access);
      receipts.add(receipt);
      selectedAmounts[guid] = amount;
      sum = checkedFxMinor(sum + amount);
    }
    if (sum != medical ||
        (amounts != null &&
            amounts.keys.toSet().difference(selected.toSet()).isNotEmpty)) {
      throw const SalaryReceiptException('componentMismatch');
    }
    final fingerprint = _hash([
      source.syncGuid,
      source.profileId,
      source.currency,
      source.amount,
      source.updatedAt.toIso8601String(),
      cycle.guid,
      cycle.occurrenceMonth,
      cycle.expectedAmountMinor,
      salary,
      medical,
      date.toUtc().toIso8601String(),
      zone,
      cashMonth,
      selectedAmounts,
      receipts.map((p) => p.fingerprint).toList(),
      months.map((m) => m.fingerprint).toList(),
      cash.fingerprint,
      included,
      groupGuid
    ]);
    if (!access()) throw const SalaryReceiptException('accessChanged');
    return SalaryReceiptPreview._(
        source,
        cycle,
        actor,
        salary,
        medical,
        date.toUtc(),
        zone,
        cashMonth,
        Map.unmodifiable(selectedAmounts),
        List.unmodifiable(receipts),
        fingerprint,
        List.unmodifiable(months),
        groupGuid,
        included);
  }

  Future<SalaryReceiptPreview> refreshPreview(
          SalaryReceiptPreview p, bool Function() access) =>
      db.txn(() => _preview(
              p.actorId,
              p.source.syncGuid,
              p.cycle.guid,
              p.salaryMinor,
              p.medicalMinor,
              p.actualDate,
              p.timezone,
              p.selectedClaimGuids,
              p.claimAmounts,
              p.cycle,
              p.groupGuid,
              p.alreadyIncluded,
              access,
              expectedApprovals: {
                for (final component in p.medicalPreviews)
                  component.history.bill.syncGuid:
                      component.history.approval!.syncGuid
              }));

  Future<IncomeReceiptGroup> confirm(
      {required SalaryReceiptPreview preview,
      required int bankTotalMinor,
      required String operationKey,
      required bool Function() isAccessCurrent}) async {
    final group = await db.writeTxn(() => _confirmInTransaction(
        p: preview,
        bankTotalMinor: bankTotalMinor,
        operationKey: operationKey,
        isAccessCurrent: isAccessCurrent));
    await _completeSalaryAction(preview.cycle, group);
    return group;
  }

  Future<IncomeReceiptGroup> _confirmInTransaction(
      {required SalaryReceiptPreview p,
      required int bankTotalMinor,
      required String operationKey,
      required bool Function() isAccessCurrent}) async {
    if (!isAccessCurrent() ||
        bankTotalMinor != p.totalMinor ||
        operationKey.trim().isEmpty ||
        operationKey.length > 128) {
      throw const SalaryReceiptException('invalidConfirmation');
    }
    final identity = 'salary-receipt:${p.cycle.guid}:$operationKey';
    final old = await db.incomeReceiptGroups
        .filter()
        .operationIdentityEqualTo(identity)
        .findFirst();
    if (old != null) {
      if (old.profileId != p.actorId ||
          old.fingerprint != p.fingerprint ||
          old.totalMinor != p.totalMinor ||
          old.currency != p.currency ||
          old.destinationMonth != p.cashMonth ||
          !old.actualDate.isAtSameMomentAs(p.actualDate)) {
        throw const SalaryReceiptException('duplicateMismatch');
      }
      await IncomeReceiptLedger.read(db, old);
      return old;
    }
    // One salary cycle may be confirmed exactly once, even when a second
    // device or a retried flow uses a different operation key.
    final sameCycle = await db.incomeReceiptGroups
        .filter()
        .sourceGuidEqualTo(p.source.syncGuid)
        .cycleGuidEqualTo(p.cycle.guid)
        .findFirst();
    if (sameCycle != null) {
      throw const SalaryReceiptException('alreadyConfirmed');
    }
    final fresh = await _preview(
        p.actorId,
        p.source.syncGuid,
        p.cycle.guid,
        p.salaryMinor,
        p.medicalMinor,
        p.actualDate,
        p.timezone,
        p.selectedClaimGuids,
        p.claimAmounts,
        p.cycle,
        p.groupGuid,
        p.alreadyIncluded,
        isAccessCurrent,
        expectedApprovals: {
          for (final component in p.medicalPreviews)
            component.history.bill.syncGuid:
                component.history.approval!.syncGuid
        });
    if (fresh.fingerprint != p.fingerprint) {
      throw const SalaryReceiptException('stalePreview');
    }
    final audit = AuditRepository(db, recorder: recorder, actorId: p.actorId);
    final now = clock().toUtc();
    final componentGuids = <String>[], revisions = <String>[];
    final medical = MedicalReceiptService(db, recorder: recorder, clock: clock);
    for (final component in fresh.medicalPreviews) {
      // All original previews were revalidated before ANY posting. Subsequent
      // components get current snapshot hashes under the same write lock.
      final current = await medical.previewInTransaction(
          billId: component.history.bill.id,
          actorId: p.actorId,
          amountMinor: p.claimAmounts[component.history.bill.syncGuid]!,
          receivedAt: p.actualDate,
          destinationMonth: p.cashMonth,
          localZone: p.timezone,
          groupGuid: p.groupGuid,
          alreadyIncluded: p.alreadyIncluded,
          validatedGroup: true,
          isAccessCurrent: isAccessCurrent);
      final receipt = await medical.recordInTransaction(
          preview: current,
          operationKey: '$operationKey:component',
          validatedGroup: true,
          isAccessCurrent: isAccessCurrent);
      componentGuids.add(receipt.syncGuid);
      revisions.add(current.evidence.text('revisionGuid'));
    }
    final salary = MoneyReceipt()
      ..billGuid = ''
      ..profileId = p.actorId
      ..kind = 'salary'
      ..actorId = p.actorId
      ..createdAt = now
      ..operationIdentity = '$identity:salary'
      ..inputFingerprint = p.fingerprint;
    await audit.put(db.moneyReceipts, salary,
        id: salary.id, type: 'MoneyReceipt', derived: false);
    final revision = ReceiptRevision()
      ..receiptGuid = salary.syncGuid
      ..billGuid = ''
      ..profileId = p.actorId
      ..yearMonth = p.cashMonth
      ..recordedAt = now
      ..actorId = p.actorId
      ..operationIdentity = '$identity:salary-revision'
      ..inputFingerprint = p.fingerprint
      ..evidenceJson = jsonEncode({
        'kind': 'salary',
        'groupGuid': p.groupGuid,
        'sourceGuid': p.source.syncGuid,
        'cycleGuid': p.cycle.guid,
        'occurrenceMonth': p.cycle.occurrenceMonth,
        'amountMinor': p.salaryMinor,
        'currency': p.currency,
        'actualDate': p.actualDate.toIso8601String(),
        'cashMonth': p.cashMonth,
        'destinationMonth': p.cashMonth
      });
    await audit.put(db.receiptRevisions, revision,
        id: revision.id, type: 'ReceiptRevision', derived: false);
    componentGuids.insert(0, salary.syncGuid);
    revisions.insert(0, revision.syncGuid);
    final group = IncomeReceiptGroup()
      ..guid = p.groupGuid
      ..profileId = p.actorId
      ..sourceGuid = p.source.syncGuid
      ..cycleGuid = p.cycle.guid
      ..actualDate = p.actualDate
      ..timezone = p.timezone
      ..totalMinor = p.totalMinor
      ..currency = p.currency
      ..destinationMonth = p.cashMonth
      ..componentReceiptGuids = componentGuids
      ..componentRevisionRefs = revisions
      ..fingerprint = p.fingerprint
      ..operationIdentity = identity
      ..createdAt = now
      ..updatedAt = now;
    // Do not mutate the preview's draft. A rolled-back confirmation must
    // remain retryable with the same user input and operation identity.
    final originalCycle = fresh.cycle;
    final cycle = SalaryCycle()
      ..id = originalCycle.id
      ..guid = originalCycle.guid
      ..profileId = originalCycle.profileId
      ..sourceGuid = originalCycle.sourceGuid
      ..scheduleGuid = originalCycle.scheduleGuid
      ..expectedAmountMinor = originalCycle.expectedAmountMinor
      ..currency = originalCycle.currency
      ..occurrenceMonth = originalCycle.occurrenceMonth
      ..nominalPayday = originalCycle.nominalPayday
      ..adjustedPayday = originalCycle.adjustedPayday
      ..createdAt = originalCycle.createdAt
      ..confirmed = true
      ..receiptGroupGuid = group.guid
      ..state = 'confirmed'
      ..updatedAt = now;
    await audit.put(db.salaryCycles, cycle, id: cycle.id, type: 'SalaryCycle');
    await audit.put(db.incomeReceiptGroups, group,
        id: group.id, type: 'IncomeReceiptGroup');
    final cashMonth = IncomeReceiptLedger.cashMonth(group);
    final cash = await BalanceCheckpointService(db, clock: clock)
        .loadInTransaction(
            context:
                ContextRef.personal(profileId: p.actorId, yearMonth: cashMonth),
            actorId: p.actorId,
            isAccessCurrent: isAccessCurrent);
    final movement = cash.movements
        .singleWhere((m) => m.key == IncomeReceiptLedger.key(group));
    final inclusion = MovementInclusion()
      ..identity = '${cash.previous!.guid}:${movement.key}'
      ..checkpointGuid = cash.previous!.guid
      ..movementKey = movement.key
      ..movementRevision = movement.revision
      ..role = p.alreadyIncluded ? 'included' : 'later'
      ..reviewedActualAt = p.actualDate
      ..signedMinor = p.totalMinor
      ..confirmedBy = p.actorId
      ..confirmedAt = now;
    // Inclusion is owned through its checkpoint (no profile column); the audited group retains its input fingerprint.
    await db.movementInclusions.put(inclusion);
    final assignment = PeriodFundingAssignment()
      ..profileId = p.actorId
      ..ownerKey = 'personal:${p.actorId}'
      ..sourceFactGuid = movement.key
      ..sourceRevision = movement.revision
      ..destinationMonth = cashMonth
      ..amountMinor = p.totalMinor
      ..currency = p.currency
      ..availabilityBoundary = DateTime.parse('$cashMonth-01')
      ..inclusionReviewRef = inclusion.identity
      ..state = 'available';
    await audit.put(db.periodFundingAssignments, assignment,
        id: assignment.id, type: 'PeriodFundingAssignment');
    if (!isAccessCurrent()) {
      throw const SalaryReceiptException('accessChanged');
    }
    return group;
  }

  /// Attention completion is best-effort: the money has already committed, so
  /// a locked identity can never roll the salary back or hide it.
  Future<void> _completeSalaryAction(
      SalaryCycle cycle, IncomeReceiptGroup group) async {
    final service = pendingActions;
    if (service == null) return;
    for (final actionType in const ['salary.confirm', 'income.complete']) {
      try {
        await service.completeByRecord(
            actionType, cycle.guid, cycle.occurrenceMonth);
      } catch (_) {
        // A later synthesis pass can reconcile the action from the group.
      }
    }
  }

  /// Posts an append-only salary correction. The original group, cycle,
  /// receipt and assignment are never edited; the correction is a new
  /// `MoneyReceipt` plus `ReceiptRevision` counted in the month it is recorded.
  Future<MoneyReceipt> correct(
      {required int actorId,
      required String groupGuid,
      required int correctionMinor,
      required String reason,
      required String operationKey,
      DateTime? correctedAt,
      String timezone = 'UTC',
      required bool Function() isAccessCurrent}) async {
    try {
      return await db.writeTxn(() async {
        if (!isAccessCurrent() ||
            actorId <= 0 ||
            operationKey.trim().isEmpty ||
            operationKey.length > 128 ||
            reason.trim().isEmpty) {
          throw const SalaryReceiptException('invalidCorrection');
        }
        checkedFxMinor(correctionMinor);
        if (correctionMinor == 0) {
          throw const SalaryReceiptException('invalidCorrection');
        }
        final group = await db.incomeReceiptGroups
            .filter()
            .guidEqualTo(groupGuid)
            .findFirst();
        if (group == null) {
          throw const SalaryReceiptException('missingGroup');
        }
        if (group.profileId != actorId) {
          throw const SalaryReceiptException('wrongOwner');
        }
        final ledger = await IncomeReceiptLedger.read(db, group);
        final original = ledger.salaryMinor;
        if (checkedFxMinor(original + correctionMinor) <= 0) {
          throw const SalaryReceiptException('invalidCorrection');
        }
        final at = correctedAt ?? clock();
        if (at.isAfter(clock())) {
          throw const SalaryReceiptException('invalidCorrection');
        }
        final String cashMonth;
        try {
          cashMonth = cashMonthFor(at, timezone);
        } catch (_) {
          throw const SalaryReceiptException('invalidTimezone');
        }
        if (!_validMonth(cashMonth)) {
          throw const SalaryReceiptException('invalidTimezone');
        }
        final seal = await db.monthRateSeals
            .filter()
            .yearMonthEqualTo(cashMonth)
            .findFirst();
        if (seal != null && seal.status != SealStatus.open) {
          throw const SalaryReceiptException('sealedMonth');
        }
        final identity = 'salary-correction:${group.guid}:$operationKey';
        final old = await db.moneyReceipts
            .filter()
            .operationIdentityEqualTo(identity)
            .findFirst();
        final fingerprint = _hash([
          group.guid,
          original,
          correctionMinor,
          reason.trim(),
          cashMonth,
          ledger.group.currency.toLowerCase(),
        ]);
        if (old != null) {
          if (old.kind != 'salary-correction' ||
              old.profileId != actorId ||
              old.inputFingerprint != fingerprint) {
            throw const SalaryReceiptException('duplicateMismatch');
          }
          return old;
        }
        final audit = AuditRepository(db, recorder: recorder, actorId: actorId);
        final now = clock().toUtc();
        final receipt = MoneyReceipt()
          ..billGuid = ''
          ..profileId = actorId
          ..kind = 'salary-correction'
          ..actorId = actorId
          ..createdAt = now
          ..operationIdentity = identity
          ..inputFingerprint = fingerprint;
        await audit.put(db.moneyReceipts, receipt,
            id: receipt.id, type: 'MoneyReceipt', derived: false);
        final revision = ReceiptRevision()
          ..receiptGuid = receipt.syncGuid
          ..billGuid = ''
          ..profileId = actorId
          ..yearMonth = cashMonth
          ..recordedAt = now
          ..actorId = actorId
          ..operationIdentity = '$identity:revision'
          ..inputFingerprint = fingerprint
          ..evidenceJson = jsonEncode({
            'kind': 'salary-correction',
            'correctsGroupGuid': group.guid,
            'sourceGuid': group.sourceGuid,
            'originalMinor': original,
            'correctionMinor': correctionMinor,
            'currency': ledger.group.currency.toLowerCase(),
            'cashMonth': cashMonth,
            'reason': reason.trim(),
          });
        await audit.put(db.receiptRevisions, revision,
            id: revision.id, type: 'ReceiptRevision', derived: false);
        await audit.append(
            profileId: actorId,
            action: 'salary.correction',
            objectType: 'IncomeReceiptGroup',
            objectGuid: group.guid,
            before: {'salaryMinor': original},
            after: {'salaryMinor': original + correctionMinor},
            requestId: operationKey);
        return receipt;
      });
    } on SalaryReceiptException catch (error) {
      // A sealed month is never rewritten. The user gets an explicit review
      // action instead, so the attempt is visible in the Pending Actions centre.
      if (error.code == 'sealedMonth') {
        await _raiseCorrectionReview(
            actorId: actorId,
            groupGuid: groupGuid,
            at: correctedAt ?? clock(),
            timezone: timezone);
      }
      rethrow;
    }
  }

  /// Best-effort: the correction was refused, so an action failure must never
  /// obscure the original `sealedMonth` error.
  Future<void> _raiseCorrectionReview({
    required int actorId,
    required String groupGuid,
    required DateTime at,
    required String timezone,
  }) async {
    final service = pendingActions;
    if (service == null) return;
    String? month;
    try {
      month = cashMonthFor(at, timezone);
    } catch (_) {
      month = null;
    }
    if (month != null && !_validMonth(month)) month = null;
    try {
      await service.upsert(PendingActionDraft(
        profileId: actorId,
        actionType: 'correction.review',
        title: 'Salary correction needs review',
        nextAction: 'Review the closed month',
        feature: 'salary',
        recordRef: groupGuid,
        cycleOrMonth: month ?? 'sealed',
        expectedMonth: month,
        expectedAt: clock(),
        priority: 2,
        deepLink: '/month_end',
      ));
    } catch (_) {
      // Attention metadata is best-effort; the refusal itself already stands.
    }
  }

  Future<MoneyReceipt> confirmRefund(
          {required MedicalReceiptPreview preview,
          required String operationKey,
          required bool Function() isAccessCurrent}) =>
      db.writeTxn(() =>
          MedicalReceiptService(db, recorder: recorder, clock: clock)
              .recordInTransaction(
                  preview: preview,
                  operationKey: operationKey,
                  isAccessCurrent: isAccessCurrent));

  /// Activates reserved future funding once the destination month has started.
  /// Idempotent: only rows still in 'reserved' state with an availability
  /// boundary on or before [currentMonth] are flipped to 'available'.
  static Future<int> activateReservedAssignments(
      Isar db, String currentMonth) async {
    final boundary = DateTime.parse('$currentMonth-01');
    final rows = await db.periodFundingAssignments
        .filter()
        .stateEqualTo('reserved')
        .findAll();
    var count = 0;
    await db.writeTxn(() async {
      for (final r in rows) {
        if (!r.availabilityBoundary.isAfter(boundary)) {
          r.state = 'available';
          await db.periodFundingAssignments.put(r);
          count++;
        }
      }
    });
    return count;
  }

  /// Ensures a [SalaryCycle] exists for [sourceGuid] + [occurrenceMonth],
  /// creating an unconfirmed one if needed. Returns the cycle.
  Future<SalaryCycle> ensureCycle({
    required String sourceGuid,
    required int profileId,
    required String occurrenceMonth,
    required int expectedAmountMinor,
    required String currency,
  }) async {
    final existing =
        await db.salaryCycles.filter().sourceGuidEqualTo(sourceGuid).findAll();
    for (final c in existing) {
      if (c.occurrenceMonth == occurrenceMonth) return c;
    }
    final now = DateTime.now().toUtc();
    final cycle = SalaryCycle()
      ..profileId = profileId
      ..sourceGuid = sourceGuid
      ..scheduleGuid = ''
      ..expectedAmountMinor = expectedAmountMinor
      ..currency = currency
      ..occurrenceMonth = occurrenceMonth
      ..nominalPayday = DateTime.parse('$occurrenceMonth-25')
      ..adjustedPayday = DateTime.parse('$occurrenceMonth-25')
      ..confirmed = false
      ..state = 'unconfirmed'
      ..createdAt = now
      ..updatedAt = now;
    await db.writeTxn(() async {
      cycle.id = await db.salaryCycles.put(cycle);
    });
    return cycle;
  }

  bool _validMonth(String month) =>
      RegExp(r'^[1-9][0-9]{3}-(0[1-9]|1[0-2])$').hasMatch(month);
}
