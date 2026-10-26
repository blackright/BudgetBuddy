import '../../expenses/repositories/merchant_repository.dart';
import '../../../core/models/expense_purchase.dart';
import '../../../core/services/expense_evidence.dart';
import '../../expenses/repositories/expense_evidence_repository.dart';
import '../../../core/models/merchant.dart';
import '../../finance/repositories/audit_repository.dart';
import '../../sync/repositories/sync_recorder.dart';
import '../../sync/providers/sync_recorder_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/models/month_end_run.dart';
import '../../vault/models/vault_entry.dart';
import '../../vault/vault_transfer_ledger.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../expenses/models/reimbursement.dart';
import '../../finance/repositories/income_carry.dart';
import '../domain/shared_member_key.dart';
import 'space_role_guard.dart';

/// The resolved income of the month being moved, in the pot that owns it.
class _SourceIncome {
  const _SourceIncome({
    required this.isShared,
    required this.currency,
    this.major = 0,
    this.minor = 0,
  });

  final bool isShared;
  final CurrencyCode currency;
  final double major;
  final int minor;
}

/// Re-homes one whole month between a personal profile and a shared space —
/// **move, never copy** (contracts/month-move-lifecycle §2, US3).
///
/// The whole re-home runs in a single [Isar.writeTxn], so a torn/half-moved
/// month is never observable (I1). It re-points the context columns on the
/// month, its expenses, its reimbursements (by `originYearMonth`) and its
/// medical bills; re-points the linked expenses' `budgetId`; moves the
/// referenced medical directory rows (de-duplicating by name in the target);
/// and carries the resolved income into the target pot's per-month override
/// (contracts/shared-income §3).
///
/// The acting profile's membership on the shared side of the move is verified
/// through [SpaceAccessGuard] at the data layer — a Viewer or a non-member is
/// refused with [UnauthorizedSpaceAction] before any write lands (US4, I1).
class MonthMoveOperations {
  MonthMoveOperations(
    this._isar, {
    this.recorder,
    RateTableRegistry? rateRegistry,
    SpaceAccessGuard guard = const SpaceAccessGuard(),
  })  : _rates = rateRegistry ?? RateTableRegistry(),
        _guard = guard;

  final Isar _isar;
  final SyncRecorder? recorder;
  final RateTableRegistry _rates;
  final SpaceAccessGuard _guard;

  /// Moves [yearMonth] from [from] to [to] in one transaction and returns the
  /// re-homed [MonthlyBudget] (its id is stable — the same row changes rooms).
  ///
  /// [actingProfileId] is the profile performing the move; it must be an
  /// Owner/Editor of whichever side of the move is the shared space. A move
  /// where the target already owns the month is refused before any write
  /// (US3 AC4).
  Future<MonthlyBudget> moveMonth(
    ContextRef from,
    ContextRef to,
    String yearMonth, {
    int? targetProfileId,
    required int actingProfileId,
  }) {
    return _isar.writeTxn(
      () => moveMonthInTxn(
        from,
        to,
        yearMonth,
        targetProfileId: targetProfileId,
        actingProfileId: actingProfileId,
      ),
    );
  }

  /// [moveMonth] without opening a transaction, for callers that already hold
  /// one (space creation brings months in inside its own create transaction).
  /// Isar does not support nested write transactions.
  Future<MonthlyBudget> moveMonthInTxn(
    ContextRef from,
    ContextRef to,
    String yearMonth, {
    int? targetProfileId,
    required int actingProfileId,
  }) async {
    if (from.isShared == to.isShared) {
      throw ArgumentError.value(
        'both contexts are ${from.isShared ? 'shared' : 'personal'}',
        'to',
        'moveMonth needs one personal and one shared context',
      );
    }
    if (from.yearMonth != yearMonth || to.yearMonth != yearMonth) {
      throw ArgumentError.value(
        yearMonth,
        'yearMonth',
        'must match both contexts',
      );
    }
    final destination = _resolveTarget(to, targetProfileId);

    final sharedSide = destination.isShared ? destination : from;
    _guard.assertEdit(
      await _member(sharedSide.spaceId!, actingProfileId),
    );

    final source = await _budget(from);
    if (source == null) {
      throw StateError(
        'no month $yearMonth in the source context to move '
        '(provision it first)',
      );
    }
    if (await _budget(destination) != null) {
      throw const UnauthorizedSpaceAction(
        'the target already owns this month; a month lives in exactly one '
        'room (US3 AC4)',
      );
    }
    await _assertNoSettlement(from, yearMonth);
    await _assertNoSettlement(destination, yearMonth);
    if ((await _expensesIn(from, yearMonth))
            .any((e) => e.fxHistoryJson != null) ||
        (await _reimbursementsIn(from, yearMonth))
            .any((r) => r.fxHistoryJson != null)) {
      throw StateError(
          'This month contains booked accounting evidence. Moving it to another owner requires a reviewed accounting transfer. No records were moved.');
    }

    final auditBefore = await _auditMoney(from, yearMonth);

    // Resolve the source pot's income before the context columns change.
    final income = await _resolveSourceIncome(from, source);

    _applyBudgetContext(source, destination);
    await _applyIncomeCarry(source, from, destination, income, yearMonth);
    source.updatedAt = DateTime.now();
    await _isar.monthlyBudgets.put(source);

    await _moveExpenses(
        from, destination, yearMonth, source.id, actingProfileId);
    await _moveReimbursements(from, destination, yearMonth);
    await _moveBills(from, destination, yearMonth);
    final auditAfter = await _auditMoney(destination, yearMonth);
    await _auditMove(
        auditBefore, auditAfter, from, destination, actingProfileId);

    return source;
  }

  /// Deletes one whole month — its budget and every money row scoped to it —
  /// leaving context-level directory rows (family members, providers, service
  /// types) intact (contracts/month-move-lifecycle §3, US3 AC4).
  ///
  /// Owner-only inside a shared space; in personal context the acting profile
  /// must be the profile that owns the month. Runs as a single transaction.
  Future<void> deleteMonth(
    ContextRef context,
    String yearMonth, {
    required int actingProfileId,
  }) {
    final target = context.isShared
        ? ContextRef.shared(spaceId: context.spaceId!, yearMonth: yearMonth)
        : ContextRef.personal(
            profileId: context.profileId!, yearMonth: yearMonth);
    return _isar.writeTxn(() async {
      if (target.isShared) {
        _guard.assertManage(await _member(target.spaceId!, actingProfileId));
      } else if (actingProfileId != target.profileId) {
        throw const UnauthorizedSpaceAction(
          'only the owning profile may delete a personal month',
        );
      }
      await _assertNoSettlement(target, yearMonth);
      final auditBefore = await _auditMoney(target, yearMonth);

      await _isar.monthlyBudgets
          .filter()
          .group((q) => target.isShared
              ? q.sharedSpaceIdEqualTo(target.spaceId)
              : q.profileIdEqualTo(target.profileKey))
          .and()
          .yearMonthEqualTo(yearMonth)
          .deleteAll();
      await _isar.expensePurchases
          .filter()
          .yearMonthEqualTo(yearMonth)
          .group((q) => target.isShared
              ? q.sharedSpaceIdEqualTo(target.spaceId)
              : q.sharedSpaceIdIsNull().profileIdEqualTo(target.profileKey))
          .deleteAll();
      await _isar.expenses
          .filter()
          .group((q) => target.isShared
              ? q.sharedSpaceIdEqualTo(target.spaceId)
              : q.profileIdEqualTo(target.profileKey))
          .and()
          .yearMonthEqualTo(yearMonth)
          .deleteAll();
      await _isar.reimbursements
          .filter()
          .group((q) => target.isShared
              ? q.sharedSpaceIdEqualTo(target.spaceId)
              : q.profileIdEqualTo(target.profileKey))
          .and()
          .originYearMonthEqualTo(yearMonth)
          .deleteAll();
      await _isar.medicalBills
          .filter()
          .group((q) => target.isShared
              ? q.sharedSpaceIdEqualTo(target.spaceId)
              : q.profileIdEqualTo(target.profileKey))
          .and()
          .yearMonthEqualTo(yearMonth)
          .deleteAll();
      for (final group in auditBefore.entries) {
        for (final row in group.value) {
          await AuditRepository(_isar,
                  recorder: recorder, actorId: actingProfileId)
              .append(
                  profileId: target.isShared ? null : target.profileId,
                  spaceId: target.spaceId,
                  action: '${group.key.toLowerCase()}.delete',
                  objectType: group.key,
                  objectGuid: row['syncGuid'] as String,
                  before: row);
        }
      }
    });
  }

  /// Re-homing only one leg would detach carry funding from its destination.
  /// The legacy month-resolution flow cannot rewrite an immutable settlement.
  Future<Map<String, List<Map<String, dynamic>>>> _auditMoney(
      ContextRef context, String month) async {
    final query = _isar.monthlyBudgets.filter().yearMonthEqualTo(month).group(
        (q) => context.isShared
            ? q.sharedSpaceIdEqualTo(context.spaceId)
            : q.sharedSpaceIdIsNull().profileIdEqualTo(context.profileId));
    return {
      'MonthlyBudget': await query.exportJson(),
      'Expense': await _isar.expenses
          .filter()
          .yearMonthEqualTo(month)
          .group((q) => context.isShared
              ? q.sharedSpaceIdEqualTo(context.spaceId)
              : q.sharedSpaceIdIsNull().profileIdEqualTo(context.profileKey))
          .exportJson(),
      'Reimbursement': await _isar.reimbursements
          .filter()
          .originYearMonthEqualTo(month)
          .group((q) => context.isShared
              ? q.sharedSpaceIdEqualTo(context.spaceId)
              : q.sharedSpaceIdIsNull().profileIdEqualTo(context.profileKey))
          .exportJson(),
      'MedicalBill': await _isar.medicalBills
          .filter()
          .yearMonthEqualTo(month)
          .group((q) => context.isShared
              ? q.sharedSpaceIdEqualTo(context.spaceId)
              : q.sharedSpaceIdIsNull().profileIdEqualTo(context.profileKey))
          .exportJson(),
    };
  }

  Future<void> _auditMove(
      Map<String, List<Map<String, dynamic>>> before,
      Map<String, List<Map<String, dynamic>>> after,
      ContextRef from,
      ContextRef to,
      int actor) async {
    final audit = AuditRepository(_isar, recorder: recorder, actorId: actor);
    for (final group in before.entries) {
      for (final row in group.value) {
        final next = after[group.key]!
            .where((r) => r['syncGuid'] == row['syncGuid'])
            .firstOrNull;
        if (next == null) {
          throw StateError('Moved financial evidence is missing.');
        }
        await audit.append(
            profileId: from.isShared ? null : from.profileId,
            spaceId: from.spaceId,
            action: '${group.key.toLowerCase()}.move.out',
            objectType: group.key,
            objectGuid: row['syncGuid'] as String,
            before: row,
            after: {
              'movedToSharedSpace': to.isShared,
              'yearMonth': to.yearMonth
            });
        await audit.append(
            profileId: to.isShared ? null : to.profileId,
            spaceId: to.spaceId,
            action: '${group.key.toLowerCase()}.move.in',
            objectType: group.key,
            objectGuid: row['syncGuid'] as String,
            before: {
              'movedFromSharedSpace': from.isShared,
              'yearMonth': from.yearMonth
            },
            after: next);
      }
    }
  }

  Future<void> _assertNoSettlement(ContextRef context, String month) async {
    if (!context.isShared) {
      final entries = await _isar.vaultEntrys
          .filter()
          .profileIdEqualTo(context.profileId!)
          .yearMonthEqualTo(month)
          .findAll();
      if (entries.any((e) => vaultTransferKinds.contains(e.kind))) {
        throw const UnauthorizedSpaceAction(
            'This personal month contains Savings Vault transfers and cannot be moved or deleted individually. Its linked financial history must remain intact.');
      }
    }
    final count = await _isar.monthEndRuns
        .filter()
        .group((q) => context.isShared
            ? q.sharedSpaceIdEqualTo(context.spaceId)
            : q.profileIdEqualTo(context.profileId).sharedSpaceIdIsNull())
        .and()
        .group((q) =>
            q.yearMonthEqualTo(month).or().destinationMonthEqualTo(month))
        .count();
    if (count > 0) {
      throw const UnauthorizedSpaceAction(
          'This month participates in a saved month-end settlement and cannot be moved or deleted individually. A settlement correction is required.');
    }
  }

  /// The context a personal [to] moves into, honouring an explicit
  /// [targetProfileId] when the caller wants a different local profile than the
  /// one carried on [to].
  ContextRef _resolveTarget(ContextRef to, int? targetProfileId) {
    if (targetProfileId == null || to.isShared) return to;
    if (targetProfileId == to.profileId) return to;
    return ContextRef.personal(
      profileId: targetProfileId,
      yearMonth: to.yearMonth,
    );
  }

  // ---------------------------------------------------------------------------
  // Income carry
  // ---------------------------------------------------------------------------

  Future<_SourceIncome> _resolveSourceIncome(
    ContextRef from,
    MonthlyBudget source,
  ) async {
    if (from.isShared) {
      final space = await _isar.sharedSpaces.get(from.spaceId!);
      final currency = space?.currency.code ?? CurrencyCode.huf;
      return _SourceIncome(
        isShared: true,
        currency: currency,
        minor: source.sharedIncomeOverride ?? space?.defaultIncome ?? 0,
      );
    }
    final profile = await _isar.userProfiles.get(from.profileId!);
    return _SourceIncome(
      isShared: false,
      currency: profile?.primaryCurrency.code ?? CurrencyCode.huf,
      major: source.netSalaryOverride ?? profile?.defaultNetSalary ?? 0,
    );
  }

  Future<void> _applyIncomeCarry(
    MonthlyBudget source,
    ContextRef from,
    ContextRef to,
    _SourceIncome income,
    String yearMonth,
  ) async {
    final table = _rates.tableFor(yearMonth);
    if (!from.isShared) {
      // personal → shared: "My income" lands as the "Our income" override.
      final space = await _isar.sharedSpaces.get(to.spaceId!);
      source.sharedIncomeOverride = IncomeCarry.toSharedMinor(
        resolvedMyIncomeMajor: income.major,
        profileMain: income.currency,
        spaceCurrency: space?.currency.code ?? income.currency,
        table: table,
      );
      source.netSalaryOverride = null;
    } else {
      // shared → personal: "Our income" lands as the "My income" override.
      final profile = await _isar.userProfiles.get(to.profileId!);
      source.netSalaryOverride = IncomeCarry.toPersonalMajor(
        resolvedOurIncomeMinor: income.minor,
        spaceCurrency: income.currency,
        profileMain: profile?.primaryCurrency.code ?? income.currency,
        table: table,
      );
      source.sharedIncomeOverride = null;
    }
  }

  // ---------------------------------------------------------------------------
  // Row re-homing
  // ---------------------------------------------------------------------------

  void _applyBudgetContext(MonthlyBudget budget, ContextRef to) {
    if (to.isShared) {
      budget
        ..sharedSpaceId = to.spaceId
        ..profileId = null;
    } else {
      budget
        ..profileId = to.profileId
        ..sharedSpaceId = null;
    }
  }

  Future<void> _moveExpenses(
    ContextRef from,
    ContextRef to,
    String yearMonth,
    int targetBudgetId,
    int actorId,
  ) async {
    final rows = await _expensesIn(from, yearMonth);
    if (rows.isEmpty) return;
    final sharedDocuments = <String, List<PreparedEvidence>>{};
    final remaining = <String, int>{};
    for (final row in rows) {
      if (row.purchaseSyncGuid != null) {
        remaining.update(row.purchaseSyncGuid!, (n) => n + 1,
            ifAbsent: () => 1);
      }
    }
    for (final expense in rows) {
      final evidenceRepository =
          ExpenseEvidenceRepository(_isar, recorder: recorder);
      final documents = expense.purchaseSyncGuid == null
          ? await evidenceRepository.prepareContextMove(expense)
          : sharedDocuments[expense.purchaseSyncGuid!] ??=
              await evidenceRepository.prepareContextMove(expense);
      if (expense.merchantSyncGuid != null && expense.merchantName == null) {
        final merchant = await _isar.merchants
            .filter()
            .syncGuidEqualTo(expense.merchantSyncGuid!)
            .findFirst();
        if (merchant != null &&
            (from.isShared
                ? merchant.sharedSpaceId == from.spaceId
                : merchant.sharedSpaceId == null &&
                    merchant.profileId == from.profileId)) {
          expense.merchantName = merchant.canonicalName;
        }
      }
      expense.merchantSyncGuid =
          null; // Rebind a portable target in the destination.
      if (to.isShared) {
        expense
          ..sharedSpaceId = to.spaceId
          ..profileId = 0;
      } else {
        expense
          ..profileId = to.profileId!
          ..sharedSpaceId = null;
      }
      // The linked budget is the re-homed month row itself (id stable), but
      // setting it explicitly keeps the invariant true even if provisioning
      // ever changes.
      expense.budgetId = targetBudgetId;
      await evidenceRepository.finishContextMoveInTxn(expense, documents);
      if (expense.purchaseSyncGuid != null) {
        final guid = expense.purchaseSyncGuid!;
        remaining[guid] = remaining[guid]! - 1;
        if (remaining[guid] == 0) {
          sharedDocuments.remove(guid);
        }
      }
      await MerchantRepository(_isar, recorder: recorder, actorId: actorId)
          .bindExpenseInTxn(expense);
    }
    await _isar.expenses.putAll(rows);
    for (final guid
        in rows.map((e) => e.purchaseSyncGuid).whereType<String>().toSet()) {
      final purchase = await _isar.expensePurchases
          .filter()
          .syncGuidEqualTo(guid)
          .findFirst();
      if (purchase == null) throw StateError('Purchase is missing.');
      purchase
        ..profileId = to.profileKey
        ..sharedSpaceId = to.spaceId
        ..budgetId = targetBudgetId
        ..advanceRevision();
      await _isar.expensePurchases.put(purchase);
    }
  }

  Future<void> _moveReimbursements(
    ContextRef from,
    ContextRef to,
    String yearMonth,
  ) async {
    final rows = await _reimbursementsIn(from, yearMonth);
    if (rows.isEmpty) return;
    for (final reimbursement in rows) {
      if (to.isShared) {
        reimbursement
          ..sharedSpaceId = to.spaceId
          ..profileId = 0;
      } else {
        reimbursement
          ..profileId = to.profileId!
          ..sharedSpaceId = null;
      }
    }
    await _isar.reimbursements.putAll(rows);
  }

  Future<void> _moveBills(
    ContextRef from,
    ContextRef to,
    String yearMonth,
  ) async {
    final bills = await _billsIn(from, yearMonth);
    if (bills.isEmpty) return;
    for (final bill in bills) {
      // Referenced directory rows move with the bill, recycled by name when the
      // target already has an equivalent (R3/R5) — the bill's ids stay valid.
      bill
        ..familyMemberId = await _relocateFamilyMember(bill.familyMemberId, to)
        ..providerId = await _relocateProvider(bill.providerId, to)
        ..serviceTypeId = await _relocateServiceType(bill.serviceTypeId, to);
      if (to.isShared) {
        bill
          ..sharedSpaceId = to.spaceId
          ..profileId = null;
      } else {
        bill
          ..profileId = to.profileId
          ..sharedSpaceId = null;
      }
    }
    await _isar.medicalBills.putAll(bills);
  }

  // ---------------------------------------------------------------------------
  // Directory relocation (find-or-create in the target context, by name)
  // ---------------------------------------------------------------------------

  Future<int?> _relocateFamilyMember(int? id, ContextRef to) async {
    if (id == null) return null;
    final row = await _isar.familyMembers.get(id);
    if (row == null) return id;
    if (_isInTarget(row.profileId, row.sharedSpaceId, to)) return id;
    final existing = await _findFamilyMember(to, row.name);
    if (existing != null) return existing.id;
    final clone = FamilyMember()
      ..profileId = to.isShared ? 0 : to.profileId
      ..sharedSpaceId = to.isShared ? to.spaceId : null
      ..name = row.name
      ..relation = row.relation;
    clone.id = await _isar.familyMembers.put(clone);
    return clone.id;
  }

  Future<int?> _relocateProvider(int? id, ContextRef to) async {
    if (id == null) return null;
    final row = await _isar.medicalProviders.get(id);
    if (row == null) return id;
    if (_isInTarget(row.profileId, row.sharedSpaceId, to)) return id;
    final existing = await _findProvider(to, row.name);
    if (existing != null) return existing.id;
    final clone = MedicalProvider()
      ..profileId = to.isShared ? 0 : to.profileId
      ..sharedSpaceId = to.isShared ? to.spaceId : null
      ..name = row.name
      ..specialty = row.specialty
      ..autoCreated = row.autoCreated;
    clone.id = await _isar.medicalProviders.put(clone);
    return clone.id;
  }

  Future<int?> _relocateServiceType(int? id, ContextRef to) async {
    if (id == null) return null;
    final row = await _isar.medicalServiceTypes.get(id);
    if (row == null) return id;
    if (_isInTarget(row.profileId, row.sharedSpaceId, to)) return id;
    final existing = await _findServiceType(to, row.name);
    if (existing != null) return existing.id;
    final clone = MedicalServiceType()
      ..profileId = to.isShared ? 0 : to.profileId
      ..sharedSpaceId = to.isShared ? to.spaceId : null
      ..name = row.name
      ..isDefault = row.isDefault
      ..sortOrder = row.sortOrder
      ..archived = row.archived;
    clone.id = await _isar.medicalServiceTypes.put(clone);
    return clone.id;
  }

  bool _isInTarget(int? profileId, int? sharedSpaceId, ContextRef to) =>
      to.isShared ? sharedSpaceId == to.spaceId : profileId == to.profileId;

  Future<FamilyMember?> _findFamilyMember(ContextRef to, String name) async {
    final rows = await (to.isShared
            ? _isar.familyMembers.filter().sharedSpaceIdEqualTo(to.spaceId)
            : _isar.familyMembers.filter().profileIdEqualTo(to.profileKey))
        .findAll();
    return _firstByName(rows, name, (r) => r.name);
  }

  Future<MedicalProvider?> _findProvider(ContextRef to, String name) async {
    final rows = await (to.isShared
            ? _isar.medicalProviders.filter().sharedSpaceIdEqualTo(to.spaceId)
            : _isar.medicalProviders.filter().profileIdEqualTo(to.profileKey))
        .findAll();
    return _firstByName(rows, name, (r) => r.name);
  }

  Future<MedicalServiceType?> _findServiceType(
      ContextRef to, String name) async {
    final rows = await (to.isShared
            ? _isar.medicalServiceTypes
                .filter()
                .sharedSpaceIdEqualTo(to.spaceId)
            : _isar.medicalServiceTypes
                .filter()
                .profileIdEqualTo(to.profileKey))
        .findAll();
    return _firstByName(rows, name, (r) => r.name);
  }

  static T? _firstByName<T>(
    List<T> rows,
    String name,
    String Function(T) nameOf,
  ) {
    final needle = name.trim().toLowerCase();
    for (final row in rows) {
      if (nameOf(row).trim().toLowerCase() == needle) return row;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  Future<MonthlyBudget?> _budget(ContextRef context) {
    final filter = _isar.monthlyBudgets.filter();
    final scoped = context.isShared
        ? filter.sharedSpaceIdEqualTo(context.spaceId)
        : filter.profileIdEqualTo(context.profileKey);
    return scoped.and().yearMonthEqualTo(context.yearMonth).findFirst();
  }

  Future<List<Expense>> _expensesIn(ContextRef context, String yearMonth) {
    return _isar.expenses
        .filter()
        .group(
          (q) => context.isShared
              ? q.sharedSpaceIdEqualTo(context.spaceId)
              : q.profileIdEqualTo(context.profileKey),
        )
        .and()
        .yearMonthEqualTo(yearMonth)
        .findAll();
  }

  Future<List<Reimbursement>> _reimbursementsIn(
    ContextRef context,
    String yearMonth,
  ) {
    return _isar.reimbursements
        .filter()
        .group(
          (q) => context.isShared
              ? q.sharedSpaceIdEqualTo(context.spaceId)
              : q.profileIdEqualTo(context.profileKey),
        )
        .and()
        .originYearMonthEqualTo(yearMonth)
        .findAll();
  }

  Future<List<MedicalBill>> _billsIn(ContextRef context, String yearMonth) {
    return _isar.medicalBills
        .filter()
        .group(
          (q) => context.isShared
              ? q.sharedSpaceIdEqualTo(context.spaceId)
              : q.profileIdEqualTo(context.profileKey),
        )
        .and()
        .yearMonthEqualTo(yearMonth)
        .findAll();
  }

  /// The acting profile's membership row for [spaceId], or `null` (T060).
  ///
  /// The write paths key every membership row by the **uniform** identity key
  /// ([sharedMemberKeyForLocalProfile]), so resolve it and match either that key
  /// or the raw [profileId] — the pre-012 fallback — the same dual-key read the
  /// spaces providers use. Matching only the raw id locked the Owner out of
  /// their own brand-new space: no row was found, so the edit gate refused.
  Future<SharedMember?> _member(int spaceId, int profileId) async {
    final key = await sharedMemberKeyForLocalProfile(_isar, profileId);
    final members = await _isar.sharedMembers
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .findAll();
    for (final member in members) {
      if (member.profileId == key || member.profileId == profileId) {
        return member;
      }
    }
    return null;
  }
}

/// The app-wide month-move operations, with the live rate registry so a sealed
/// month converts against its own seal and an open month against the live table.
final monthMoveOperationsProvider = Provider<MonthMoveOperations>((ref) {
  return MonthMoveOperations(
    IsarHelper.instance,
    recorder: ref.watch(syncRecorderProvider),
    rateRegistry: ref.watch(rateRegistryProvider),
    guard: ref.watch(spaceRoleGuardProvider),
  );
});
