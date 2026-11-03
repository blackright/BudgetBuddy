import 'income_receipt_ledger.dart';
import '../models/income_receipt_group.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';
import 'package:timezone/data/latest.dart' as zones;
import 'package:timezone/timezone.dart' as tz;
import '../models/balance_checkpoint.dart';
import '../models/financial_adoption.dart';
import '../models/fx_revision.dart';
import '../models/expense.dart';
import '../models/monthly_budget.dart';
import '../models/period_funding_assignment.dart';
import '../models/reconciliation_snapshot.dart';
import '../models/shared_member.dart';
import '../providers/budget_context_provider.dart';
import '../../features/expenses/models/reimbursement.dart';
import '../../features/spaces/repositories/space_write_guard.dart';
import '../../features/vault/models/vault_entry.dart';
import '../../features/vault/vault_transfer_ledger.dart';
import 'fx_booking_service.dart';
import 'medical_receipt_booking_service.dart';
import 'receipt_snapshot_repository.dart';
import 'receipt_write_guard.dart';
import 'receipt_reconciliation_service.dart';

class CheckpointDraft {
  CheckpointDraft(
      {required this.balanceMinor,
      required this.balanceAsOf,
      required this.localZone,
      required this.pool,
      required Iterable<MovementChoice> choices})
      : choices = List.unmodifiable(choices);
  final int balanceMinor;
  final DateTime balanceAsOf;
  final String localZone, pool;
  final List<MovementChoice> choices;
}

/// A blocker found while reviewing the opening-money boundary.
///
/// It stays a [FormatException] so existing month-end and medical handling keeps
/// working, while receipt screens can show a specific message and repair action.
class OpeningReviewException extends FormatException {
  const OpeningReviewException(this.code, [String? message])
      : super(message ?? code);
  final String code;
}

class CheckpointSources {
  CheckpointSources._(
      {required this.source,
      required this.movements,
      required this.fingerprint,
      required this.adoptionGuid,
      required this.previous,
      required this.previousChoices,
      required this.blockers,
      required this.initialBalanceMinor,
      required this.reservedFundingMinor});
  final ReceiptSourceSnapshot source;
  final List<CashMovement> movements;
  final String fingerprint;
  final String? adoptionGuid;
  final BalanceCheckpoint? previous;
  final List<MovementChoice> previousChoices;
  final List<String> blockers;
  final int? initialBalanceMinor;
  final int reservedFundingMinor;
}

class CheckpointPreview {
  CheckpointPreview._(
      this.sources, this.draft, this.cash, this.fingerprint, this.blockers);
  final CheckpointSources sources;
  final CheckpointDraft draft;
  final CashReviewResult cash;
  final String fingerprint;
  final List<String> blockers;
  bool get canConfirm => blockers.isEmpty && cash.bankMinor != null;
}

/// Cash review only: no legacy balance rewrite or new policy activation. All
/// source selection and revision checks are repeated under the write lock.
class BalanceCheckpointService {
  BalanceCheckpointService(this.db, {DateTime Function()? clock})
      : clock = clock ?? DateTime.now;
  final Isar db;
  final DateTime Function() clock;
  static bool _zonesReady = false;
  static void initializeZones() {
    if (!_zonesReady || !tz.timeZoneDatabase.isInitialized) {
      zones.initializeTimeZones();
      _zonesReady = true;
    }
  }

  static tz.Location location(String name) {
    initializeZones();
    // The trimmed database omits the valid UTC alias; use exact UTC rather
    // than guessing a region or an offset.
    return name == 'UTC' || name == 'Etc/UTC' ? tz.UTC : tz.getLocation(name);
  }

  static String ownerKey(ContextRef c) =>
      c.isShared ? 'shared:${c.spaceId}' : 'personal:${c.profileId}';
  static String ownerMonth(ContextRef c) => '${ownerKey(c)}:${c.yearMonth}';
  static String _hash(Object value) =>
      sha256.convert(utf8.encode(jsonEncode(value))).toString();
  FilterOperation _owner(ContextRef c) => c.isShared
      ? FilterCondition.equalTo(property: 'sharedSpaceId', value: c.spaceId)
      : FilterGroup.and([
          FilterCondition.equalTo(property: 'profileId', value: c.profileId),
          const FilterCondition.equalTo(property: 'sharedSpaceId', value: null)
        ]);

  Future<CheckpointSources> load(
          {required ContextRef context,
          required int actorId,
          required bool Function() isAccessCurrent}) =>
      db.txn(() => _load(context, actorId, isAccessCurrent));

  /// Caller owns the transaction; used when recording a new, explicitly
  /// confirmed receipt against the existing checkpoint without nested reads.
  Future<CheckpointSources> loadInTransaction(
          {required ContextRef context,
          required int actorId,
          required bool Function() isAccessCurrent}) =>
      _load(context, actorId, isAccessCurrent);

  Future<CashReviewResult> cashInTransaction(
      {required ContextRef context,
      required int actorId,
      required bool Function() isAccessCurrent}) async {
    final sources = await _load(context, actorId, isAccessCurrent);
    final checkpoint = sources.previous;
    if (checkpoint == null || checkpoint.adoptionGuid != sources.adoptionGuid) {
      throw const OpeningReviewException('missingOpeningCheckpoint',
          'Review the current balance and its included payments.');
    }
    final reviewBlocker = sources.blockers.firstWhere(
        (b) => {'missingMonth', 'missingOpeningReview', 'settlementNeedsReview'}
            .contains(b),
        orElse: () => '');
    if (reviewBlocker.isNotEmpty) {
      throw OpeningReviewException(reviewBlocker,
          'Review the current balance and its included payments.');
    }
    final cash = const ReceiptReconciliationService().reviewCash(
        balanceMinor: checkpoint.balanceMinor,
        balanceAsOf: checkpoint.balanceAsOf,
        asOf: clock().toUtc(),
        movements: sources.movements,
        choices: sources.previousChoices);
    if (cash.blockers.isNotEmpty) {
      throw const OpeningReviewException(
          'movementNeedsReview', 'Review changed payments in opening money.');
    }
    return cash;
  }

  Future<CheckpointSources> _load(
      ContextRef context, int actorId, bool Function() access) async {
    final source = await ReceiptSnapshotRepository(db, clock: clock)
        .readInTransaction(
            context: context, actorId: actorId, isAccessCurrent: access);
    if (context.isShared) {
      final member =
          await SpaceWriteGuard(db).memberOf(context.spaceId!, actorId);
      if (member?.role != SharedMemberRole.owner || member?.revokedAt != null) {
        throw const ReceiptGuardException('ownerRequired');
      }
    }
    final blockers = source.blockers.map((b) => b.name).toSet();
    final adoption = await db.financialAdoptions
        .filter()
        .ownerKeyEqualTo('${ownerKey(context)}:2')
        .sortByRevisionDesc()
        .findFirst();
    if (adoption == null ||
        context.yearMonth.compareTo(adoption.effectiveYearMonth) < 0 ||
        adoption.chosenAccountingCurrency != source.currency.code) {
      blockers.add('adoptionRequired');
    }
    final previous = await db.balanceCheckpoints
        .filter()
        .ownerMonthEqualTo(ownerMonth(context))
        .sortByRevisionDesc()
        .findFirst();
    final previousRows = previous == null
        ? <MovementInclusion>[]
        : await db.movementInclusions
            .filter()
            .checkpointGuidEqualTo(previous.guid)
            .findAll();
    final monthRows = await db.monthlyBudgets
        .buildQuery<MonthlyBudget>(
            filter: FilterGroup.and([
          _owner(context),
          FilterCondition.equalTo(
              property: 'yearMonth', value: context.yearMonth)
        ]))
        .findAll();
    int? initial;
    if (monthRows.length == 1) {
      final raw = monthRows.single.baseAvailableAmount *
          source.currency.minorUnitsPerMajor;
      if (raw.isFinite && raw >= 0 && raw <= fxMoneyBound) {
        initial = raw.round();
      } else {
        blockers.add('invalidMoney');
      }
    }
    // Include cross-month cash events as well as current cost-month entries.
    // Date-only legacy facts remain unverified; no receipt date is guessed.
    final start = DateTime.parse('${context.yearMonth}-01');
    final end = DateTime(start.year, start.month + 1);
    final expenses = await db.expenses
        .buildQuery<Expense>(
            filter: FilterGroup.and([
          _owner(context),
          FilterGroup.or([
            FilterCondition.equalTo(
                property: 'yearMonth', value: context.yearMonth),
            FilterCondition.between(
                property: 'paidAt',
                lower: start.subtract(const Duration(days: 2)),
                upper: end.add(const Duration(days: 2))),
          ])
        ]))
        .findAll();
    final returns = await db.reimbursements
        .buildQuery<Reimbursement>(
            filter: FilterGroup.and([
          _owner(context),
          FilterGroup.or([
            FilterCondition.equalTo(
                property: 'originYearMonth', value: context.yearMonth),
            FilterCondition.between(
                property: 'date',
                lower: start.subtract(const Duration(days: 2)),
                upper: end.add(const Duration(days: 2))),
          ])
        ]))
        .findAll();
    final movements = <CashMovement>[];
    final identities = <String>{};
    void add(String key, String label, String kind, int amount, DateTime? date,
        Object revision) {
      if (!identities.add(key)) blockers.add('duplicateMovement');
      checkedFxMinor(amount);
      movements.add(CashMovement(
          key: key,
          revision: _hash(revision),
          label: label,
          kind: kind,
          signedMinor: amount,
          actualAt: date?.toUtc()));
    }

    for (final expense in expenses.where((e) => fxPaid(e.status))) {
      try {
        final money =
            expenseAccountingMoney(expense, expectedCurrency: source.currency);
        if (money.currency != source.currency || money.minorUnits < 0) {
          throw const FormatException();
        }
        add('expense:${expense.syncGuid}', expense.title, 'expense',
            -money.minorUnits, expense.paidAt, [
          expense.id,
          expense.syncGuid,
          expense.amount,
          expense.currency,
          expense.status.name,
          expense.paidAt?.toUtc().toIso8601String(),
          expense.fxHistoryJson,
          expense.yearMonth
        ]);
      } on FormatException {
        blockers.add('movementMoneyNeedsReview');
      }
    }
    final validGroups = <String>{};
    if (!context.isShared) {
      for (final group in await db.incomeReceiptGroups
          .filter()
          .profileIdEqualTo(context.profileId!)
          .findAll()) {
        try {
          await IncomeReceiptLedger.read(db, group);
          if (group.currency.toLowerCase() != source.currency.code) {
            throw const FormatException('Group currency');
          }
          validGroups.add(group.guid);
          add(
              IncomeReceiptLedger.key(group),
              'Salary and insurance bank credit',
              'receipt',
              group.totalMinor,
              group.actualDate, [
            group.fingerprint,
            group.componentReceiptGuids,
            group.componentRevisionRefs
          ]);
        } on FormatException {
          blockers.add('groupNeedsReview');
        }
      }
    }
    for (final refund in returns) {
      try {
        final target = refund.expenseId == null
            ? null
            : await db.expenses.get(refund.expenseId!);
        if (target == null ||
            target.sharedSpaceId != context.spaceId ||
            (!context.isShared && target.profileId != context.profileId)) {
          throw const FormatException();
        }
        final money = reimbursementAccountingMoney(refund,
            expectedCurrency: source.currency);
        if (money.currency != source.currency ||
            money.minorUnits <= 0 ||
            refund.orphaned) {
          throw const FormatException();
        }
        final medical = MedicalReceiptEvidence.of(refund);
        if (medical?.json['groupGuid'] != null) {
          if (!validGroups.contains(medical!.json['groupGuid'])) {
            blockers.add('groupNeedsReview');
          }
          continue;
        }
        add('return:${refund.syncGuid}', 'Recorded return', 'receipt',
            money.minorUnits, medical?.receivedAt, [
          refund.id,
          refund.syncGuid,
          refund.amount,
          refund.currency,
          refund.originYearMonth,
          refund.date.toUtc().toIso8601String(),
          refund.fxHistoryJson,
          refund.medicalReceiptJson,
          refund.expenseId,
          refund.orphaned
        ]);
      } on FormatException {
        blockers.add('movementMoneyNeedsReview');
      }
    }
    if (!context.isShared) {
      final entries = await db.vaultEntrys
          .filter()
          .profileIdEqualTo(context.profileId!)
          .findAll();
      for (final entry in entries.where((e) =>
          e.yearMonth == context.yearMonth &&
          vaultTransferKinds.contains(e.kind))) {
        if (transferDetails(entry) == null ||
            entry.currency != source.currency.code) {
          blockers.add('movementMoneyNeedsReview');
          continue;
        }
        add('vault:${entry.operationKey}', 'Savings ${entry.kind}', 'vault',
            -entry.amountMinor, entry.createdAt, [
          entry.id,
          entry.operationKey,
          entry.amountMinor,
          entry.currency,
          entry.createdAt.toUtc().toIso8601String(),
          entry.breakdownJson
        ]);
      }
    }
    movements.sort((a, b) => a.key.compareTo(b.key));
    var reserved = 0;
    final claims = await db.periodFundingAssignments
        .filter()
        .ownerKeyEqualTo(ownerKey(context))
        .findAll();
    claims.sort((a, b) => a.guid.compareTo(b.guid));
    final claimed = <String, int>{};
    for (final claim in claims.where((c) => c.state != 'reversed')) {
      final matching = movements.where((m) =>
          m.key == claim.sourceFactGuid && m.revision == claim.sourceRevision);
      if (!{'reserved', 'available'}.contains(claim.state) ||
          claim.policyRevision != 2 ||
          claim.currency != source.currency.code ||
          claim.amountMinor <= 0 ||
          claim.amountMinor > fxMoneyBound ||
          !RegExp(r'^[1-9][0-9]{3}-(0[1-9]|1[0-2])$')
              .hasMatch(claim.destinationMonth) ||
          matching.length != 1 ||
          matching.single.signedMinor <= 0) {
        blockers.add('fundingAssignmentNeedsReview');
        continue;
      }
      final prior = claimed[claim.sourceFactGuid] ?? 0;
      if (prior > matching.single.signedMinor - claim.amountMinor) {
        blockers.add('fundingAssignmentNeedsReview');
        continue;
      }
      claimed[claim.sourceFactGuid] = prior + claim.amountMinor;
      if (claim.destinationMonth != context.yearMonth ||
          clock().toUtc().isBefore(claim.availabilityBoundary)) {
        if (reserved > fxMoneyBound - claim.amountMinor) {
          blockers.add('invalidMoney');
        } else {
          reserved += claim.amountMinor;
        }
      }
    }
    final fingerprint = _hash([
      source.fingerprint,
      adoption?.guid,
      previous?.guid,
      movements.map((m) => [m.key, m.revision]).toList(),
      claims
          .map((c) => [
                c.guid,
                c.sourceFactGuid,
                c.sourceRevision,
                c.destinationMonth,
                c.amountMinor,
                c.currency,
                c.availabilityBoundary.toUtc().toIso8601String(),
                c.state,
                c.inclusionReviewRef,
                c.policyRevision
              ])
          .toList()
    ]);
    if (!access()) throw const ReceiptGuardException('accessChanged');
    return CheckpointSources._(
        source: source,
        movements: List.unmodifiable(movements),
        fingerprint: fingerprint,
        adoptionGuid: adoption?.guid,
        previous: previous,
        previousChoices: List.unmodifiable(previousRows.map((r) =>
            MovementChoice(
                key: r.movementKey,
                revision: r.movementRevision,
                role: r.role,
                actualAt: r.reviewedActualAt))),
        blockers: List.unmodifiable(blockers),
        initialBalanceMinor: previous?.balanceMinor ?? initial,
        reservedFundingMinor: reserved);
  }

  Future<CheckpointPreview> preview(
          {required CheckpointSources sources,
          required CheckpointDraft draft,
          required bool Function() isAccessCurrent}) =>
      db.txn(() async {
        final fresh = await _load(
            sources.source.context, sources.source.actorId, isAccessCurrent);
        if (fresh.fingerprint != sources.fingerprint) {
          throw const ReceiptGuardException('stalePreview');
        }
        return _evaluate(fresh, draft);
      });

  CheckpointPreview _evaluate(
      CheckpointSources sources, CheckpointDraft draft) {
    initializeZones();
    final blockers = sources.blockers.toSet();
    checkedFxMinor(draft.balanceMinor);
    if (draft.balanceMinor < 0) blockers.add('invalidMoney');
    if (draft.pool.trim().isEmpty || draft.pool.trim().length > 120) {
      blockers.add('missingCashScope');
    }
    try {
      final local =
          tz.TZDateTime.from(draft.balanceAsOf, location(draft.localZone));
      final month =
          '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}';
      if (month != sources.source.context.yearMonth) {
        blockers.add('balanceOutsideMonth');
      }
    } catch (_) {
      blockers.add('invalidTimezone');
    }
    final cash = const ReceiptReconciliationService().reviewCash(
        balanceMinor: draft.balanceMinor,
        balanceAsOf: draft.balanceAsOf,
        asOf: clock().toUtc(),
        movements: sources.movements,
        choices: draft.choices);
    blockers.addAll(cash.blockers);
    final choices = draft.choices.map((c) => c.json).toList()
      ..sort((a, b) => (a['key'] as String).compareTo(b['key'] as String));
    final hash = _hash([
      sources.fingerprint,
      draft.balanceMinor,
      draft.balanceAsOf.toUtc().toIso8601String(),
      draft.localZone,
      draft.pool.trim(),
      choices
    ]);
    return CheckpointPreview._(
        sources, draft, cash, hash, List.unmodifiable(blockers));
  }

  Future<BalanceCheckpoint> confirm(
      {required CheckpointPreview preview,
      required String operationKey,
      required bool Function() isAccessCurrent}) {
    if (operationKey.trim().isEmpty || operationKey.length > 128) {
      throw const ReceiptGuardException('invalidOperation');
    }
    final sources = preview.sources;
    return ReceiptWriteGuard(ReceiptSnapshotRepository(db)).run(
        previews: [sources.source],
        actorId: sources.source.actorId,
        isAccessCurrent: isAccessCurrent,
        write: () async {
          final fresh = await _load(
              sources.source.context, sources.source.actorId, isAccessCurrent);
          final identity =
              '${ownerMonth(sources.source.context)}:$operationKey';
          final old = await db.balanceCheckpoints
              .filter()
              .operationIdentityEqualTo(identity)
              .findFirst();
          if (old != null) {
            if (old.inputFingerprint != preview.fingerprint) {
              throw const ReceiptGuardException('duplicateMismatch');
            }
            return old;
          }
          if (fresh.fingerprint != sources.fingerprint) {
            throw const ReceiptGuardException('stalePreview');
          }
          final current = _evaluate(fresh, preview.draft);
          if (!current.canConfirm) {
            throw ReceiptGuardException(current.blockers.first);
          }
          final now = clock().toUtc();
          final record = BalanceCheckpoint()
            ..ownerMonth = ownerMonth(sources.source.context)
            ..profileId = sources.source.context.profileId
            ..sharedSpaceId = sources.source.context.spaceId
            ..yearMonth = sources.source.context.yearMonth
            ..balanceMinor = preview.draft.balanceMinor
            ..currency = sources.source.currency.code
            ..balanceAsOf = preview.draft.balanceAsOf.toUtc()
            ..localZone = preview.draft.localZone
            ..cashPoolDescription = preview.draft.pool.trim()
            ..adoptionGuid = fresh.adoptionGuid!
            ..sourceFingerprint = fresh.fingerprint
            ..inputFingerprint = preview.fingerprint
            ..operationIdentity = identity
            ..confirmedAt = now
            ..actorId = sources.source.actorId
            ..revision = (fresh.previous?.revision ?? 0) + 1
            ..previousCheckpointGuid = fresh.previous?.guid;
          record.id = await db.balanceCheckpoints.put(record);
          final byKey = {for (final m in sources.movements) m.key: m};
          await db.movementInclusions.putAll(preview.draft.choices
              .map((c) => MovementInclusion()
                ..identity = '${record.guid}:${c.key}'
                ..checkpointGuid = record.guid
                ..movementKey = c.key
                ..movementRevision = c.revision
                ..role = c.role
                ..reviewedActualAt = c.actualAt?.toUtc()
                ..signedMinor = byKey[c.key]!.signedMinor
                ..confirmedBy = record.actorId
                ..confirmedAt = now)
              .toList());
          return record;
        });
  }
}
