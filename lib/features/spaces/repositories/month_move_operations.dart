import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

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
    RateTableRegistry? rateRegistry,
    SpaceAccessGuard guard = const SpaceAccessGuard(),
  })  : _rates = rateRegistry ?? RateTableRegistry(),
        _guard = guard;

  final Isar _isar;
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

    // Resolve the source pot's income before the context columns change.
    final income = await _resolveSourceIncome(from, source);

    _applyBudgetContext(source, destination);
    await _applyIncomeCarry(source, from, destination, income, yearMonth);
    source.updatedAt = DateTime.now();
    await _isar.monthlyBudgets.put(source);

    await _moveExpenses(from, destination, yearMonth, source.id);
    await _moveReimbursements(from, destination, yearMonth);
    await _moveBills(from, destination, yearMonth);

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

      await _isar.monthlyBudgets
          .filter()
          .group((q) => target.isShared
              ? q.sharedSpaceIdEqualTo(target.spaceId)
              : q.profileIdEqualTo(target.profileKey))
          .and()
          .yearMonthEqualTo(yearMonth)
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
    });
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
  ) async {
    final rows = await _expensesIn(from, yearMonth);
    if (rows.isEmpty) return;
    for (final expense in rows) {
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
    }
    await _isar.expenses.putAll(rows);
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

  Future<SharedMember?> _member(int spaceId, int profileId) =>
      _isar.sharedMembers
          .filter()
          .sharedSpaceIdEqualTo(spaceId)
          .profileIdEqualTo(profileId)
          .findFirst();
}

/// The app-wide month-move operations, with the live rate registry so a sealed
/// month converts against its own seal and an open month against the live table.
final monthMoveOperationsProvider = Provider<MonthMoveOperations>((ref) {
  return MonthMoveOperations(
    IsarHelper.instance,
    rateRegistry: ref.watch(rateRegistryProvider),
    guard: ref.watch(spaceRoleGuardProvider),
  );
});
