import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../spaces/repositories/space_write_guard.dart';
import '../../sync/providers/sync_recorder_provider.dart';
import '../../sync/repositories/sync_recorder.dart';

final monthFinanceRepositoryProvider = Provider<MonthFinanceRepository>((ref) {
  return MonthFinanceRepository(
    IsarHelper.instance,
    guard: ref.watch(spaceWriteGuardProvider),
    actingProfileId: ref.watch(actingProfileIdProvider),
    syncRecorder: ref.watch(syncRecorderProvider),
  );
});

/// The income figure actually applied to a month, plus where it came from.
class ResolvedIncome {
  const ResolvedIncome({required this.amount, required this.usesOverride});

  const ResolvedIncome.empty()
      : amount = 0.0,
        usesOverride = false;

  /// The single place the override-beats-default rule lives (FR-002, FR-003).
  ///
  /// Both the async repository read and the synchronous provider read go through
  /// here, so the two can never disagree about a month's income.
  factory ResolvedIncome.resolve({
    required double? override,
    required double profileDefault,
  }) {
    if (override != null) {
      return ResolvedIncome(amount: override, usesOverride: true);
    }
    return ResolvedIncome(amount: profileDefault, usesOverride: false);
  }

  final double amount;

  /// True when the figure came from the month's override rather than the
  /// profile default (FR-005).
  final bool usesOverride;
}

/// Month-scoped finance reads and writes: provisioning, opening balance and
/// income resolution.
///
/// Every month-scoped record the app needs lives on [MonthlyBudget], keyed by
/// the owning context + `yearMonth` (FR-004). Income is resolved through the
/// context's pot: the personal pot (`defaultNetSalary`/`netSalaryOverride`,
/// legacy `double`) or the shared pot (`sharedSpaceId`/`sharedIncomeOverride`,
/// whole minor units) — the two never read each other (FR-009,
/// shared-income contract §1–2).
///
/// The legacy `yearMonth`-only methods keep their signatures for existing
/// callers and resolve to the lowest-id personal profile, matching the app's
/// pre-011 single-profile behaviour (R2).
class MonthFinanceRepository {
  MonthFinanceRepository(
    this._isar, {
    SpaceWriteGuard? guard,
    int? actingProfileId,
    SyncRecorder? syncRecorder,
  })  : _writeGuard = guard,
        _actingProfileId = actingProfileId,
        _syncRecorder = syncRecorder;

  final Isar _isar;

  /// Optional role guard + acting profile: when present, every shared month
  /// write is refused for a Viewer or a sealed month (US4, FR-005, FR-012).
  final SpaceWriteGuard? _writeGuard;
  final int? _actingProfileId;

  /// Appends a signed change for a paired shared month on every write (FR-006).
  /// Optional and inert when no signer/identity is attached; a personal budget
  /// (`sharedSpaceId == null`) is never exchanged, so [SyncRecorder.recordBudget]
  /// no-ops for it.
  final SyncRecorder? _syncRecorder;

  Future<void> _guardWrite(ContextRef context) async {
    await _writeGuard?.assertSharedMoneyWrite(
      sharedSpaceId: context.spaceId,
      actingProfileId: _actingProfileId,
      yearMonth: context.yearMonth,
    );
  }

  /// Appends a change record for a just-written shared month (FR-006). No-op
  /// for a personal budget (never exchanged) or when recording is inert.
  Future<void> _recordBudget(MonthlyBudget budget) =>
      _syncRecorder?.recordBudget(budget) ?? Future.value();

  // ---------------------------------------------------------------------------
  // Context-scoped API (the single route, FR-004)
  // ---------------------------------------------------------------------------

  /// The row for [context]'s month, or `null` if the month has never been opened.
  Future<MonthlyBudget?> getMonthInContext(ContextRef context) {
    return _budgetQuery(context).findFirst();
  }

  /// Whether the shared [spaceId] owns at least one month (FR-011).
  ///
  /// A brand-new space owns nothing and must not auto-provision its first
  /// month; once it owns one, later navigations may provision normally.
  Future<bool> spaceOwnsAnyMonth(int spaceId) async {
    final count = await _isar.monthlyBudgets
        .filter()
        .sharedSpaceIdEqualTo(spaceId)
        .count();
    return count > 0;
  }

  /// Live view of [context]'s month, yielding `null` until provisioned.
  Stream<MonthlyBudget?> watchMonthInContext(ContextRef context) {
    return _budgetQuery(context)
        .watch(fireImmediately: true)
        .map((budgets) => budgets.isNotEmpty ? budgets.first : null);
  }

  /// Returns [context]'s row for its month, creating it if this is the first
  /// time that month is visited in that context.
  ///
  /// A new month is provisioned with a zero opening balance explicitly *not*
  /// confirmed and no convert-to choice, so it follows the context's main
  /// currency. Nothing is copied from the previous month (FR-007, FR-011).
  Future<MonthlyBudget> ensureMonthInContext(ContextRef context) {
    return _isar.writeTxn(() => _ensureMonthInTxn(context));
  }

  /// [ensureMonthInContext] without opening a transaction, for callers that
  /// already hold one. Isar does not support nested write transactions.
  Future<MonthlyBudget> _ensureMonthInTxn(ContextRef context) async {
    final existing = await _budgetQuery(context).findFirst();
    if (existing != null) return existing;

    // A pre-011 row (no context columns) for this month is claimed for the
    // context that first opens it rather than shadowed by a duplicate (R2,
    // migration step 13: exactly-one-context invariant).
    final unclaimed = await _unclaimedRow(context.yearMonth);
    if (unclaimed != null) {
      if (context.isShared) {
        unclaimed.sharedSpaceId = context.spaceId;
      } else {
        unclaimed.profileId = context.profileKey;
      }
      unclaimed.updatedAt = DateTime.now();
      await _isar.monthlyBudgets.put(unclaimed);
      await _recordBudget(unclaimed);
      return unclaimed;
    }

    final now = DateTime.now();
    final budget = MonthlyBudget()
      ..yearMonth = context.yearMonth
      ..baseAvailableAmount = 0.0
      ..openingBalanceConfirmed = false
      ..createdAt = now
      ..updatedAt = now;
    if (context.isShared) {
      budget.sharedSpaceId = context.spaceId;
    } else {
      budget.profileId = context.profileKey;
    }
    budget.id = await _isar.monthlyBudgets.put(budget);
    await _recordBudget(budget);
    return budget;
  }

  /// The pre-011 row for [yearMonth]: a budget with no context columns at all.
  Future<MonthlyBudget?> _unclaimedRow(String yearMonth) async {
    final rows = await _isar.monthlyBudgets
        .filter()
        .yearMonthEqualTo(yearMonth)
        .findAll();
    for (final row in rows) {
      if (row.profileId == null && row.sharedSpaceId == null) return row;
    }
    return null;
  }

  /// A fresh unclaimed row for [yearMonth], for the legacy no-profile path.
  Future<MonthlyBudget> _provisionUnclaimed(String yearMonth) async {
    final now = DateTime.now();
    final budget = MonthlyBudget()
      ..yearMonth = yearMonth
      ..baseAvailableAmount = 0.0
      ..openingBalanceConfirmed = false
      ..createdAt = now
      ..updatedAt = now;
    budget.id = await _isar.monthlyBudgets.put(budget);
    return budget;
  }

  /// Records [context]'s month opening balance and marks it confirmed
  /// (FR-006, FR-011). Stays editable after the month passes.
  Future<void> saveOpeningBalanceInContext(
      ContextRef context, double amount) async {
    if (amount < 0) {
      throw ArgumentError.value(
          amount, 'amount', 'Opening balance cannot be negative');
    }
    await _guardWrite(context);
    await _isar.writeTxn(() async {
      final budget = await _ensureMonthInTxn(context);
      budget.baseAvailableAmount = amount;
      budget.openingBalanceConfirmed = true;
      budget.updatedAt = DateTime.now();
      await _isar.monthlyBudgets.put(budget);
      await _recordBudget(budget);
    });
  }

  /// Sets [context]'s month display-only convert-to choice (FR-011).
  Future<void> saveConvertToInContext(
      ContextRef context, CurrencyCode? currency) async {
    await _guardWrite(context);
    await _isar.writeTxn(() async {
      final budget = await _ensureMonthInTxn(context);
      budget.currency = currency?.name;
      budget.updatedAt = DateTime.now();
      await _isar.monthlyBudgets.put(budget);
      await _recordBudget(budget);
    });
  }

  /// Overrides the personal income for [context]'s month. Pass `null` to hand
  /// the month back to the profile default (FR-003).
  Future<void> saveNetSalaryOverrideInContext(
      ContextRef context, double? amount) {
    if (context.isShared) {
      throw ArgumentError.value(
          amount,
          'context',
          'Net salary override is personal-only; a shared month uses the '
              '"Our income" pot');
    }
    if (amount != null && amount < 0) {
      throw ArgumentError.value(
          amount, 'amount', 'Net salary cannot be negative');
    }
    return _isar.writeTxn(() async {
      final budget = await _ensureMonthInTxn(context);
      budget.netSalaryOverride = amount;
      budget.updatedAt = DateTime.now();
      await _isar.monthlyBudgets.put(budget);
      await _recordBudget(budget);
    });
  }

  /// Overrides the shared "Our income" for [context]'s month, in whole minor
  /// units. Pass `null` to hand the month back to the space default (FR-009).
  Future<void> saveOurIncomeOverrideInContext(ContextRef context, int? amount) {
    if (!context.isShared) {
      throw ArgumentError.value(
          amount,
          'context',
          '"Our income" override is shared-only; a personal month uses the '
              '"My income" pot');
    }
    if (amount != null && amount < 0) {
      throw ArgumentError.value(
          amount, 'amount', 'Our income cannot be negative');
    }
    return _guardWrite(context).then((_) => _isar.writeTxn(() async {
          final budget = await _ensureMonthInTxn(context);
          budget.sharedIncomeOverride = amount;
          budget.updatedAt = DateTime.now();
          await _isar.monthlyBudgets.put(budget);
        }));
  }

  /// Income applied to [context]'s month: the month's own override when it has
  /// one, otherwise the pot default (FR-002, FR-003, FR-009).
  ///
  /// The personal pot reports legacy `double` major units; the shared pot is
  /// stored as whole minor units and reported here in the space currency's
  /// major units (divided once), so the engine's display pipeline treats both
  /// pots identically. Reporting [ResolvedIncome.usesOverride] lets the UI mark
  /// a month whose figure does not come from the default (FR-005).
  Future<ResolvedIncome> resolveIncomeInContext(ContextRef context) async {
    final month = await getMonthInContext(context);
    if (context.isShared) {
      final space = await _isar.sharedSpaces.get(context.spaceId!);
      final override = month?.sharedIncomeOverride;
      final minorUnits = override ?? space?.defaultIncome ?? 0;
      final major = minorUnits /
          (space?.currency.code.minorUnitsPerMajor ??
              CurrencyCode.huf.minorUnitsPerMajor);
      return ResolvedIncome(amount: major, usesOverride: override != null);
    }
    return ResolvedIncome.resolve(
      override: month?.netSalaryOverride,
      profileDefault: await getDefaultNetSalary(profileId: context.profileKey),
    );
  }

  /// The profile-wide default applied to any personal month without an override
  /// (FR-001). Reads [profileId]'s row, or the lowest-id profile when none is
  /// named (the pre-011 single-profile shape).
  Future<double> getDefaultNetSalary({int? profileId}) async {
    final profile = profileId != null
        ? await _isar.userProfiles.get(profileId)
        : await _isar.userProfiles.where().findFirst();
    return profile?.defaultNetSalary ?? 0.0;
  }

  /// Updates the profile default. Months that already exist are untouched —
  /// they only stop following the default once they carry their own override
  /// (FR-004). Writes [profileId]'s row, or the lowest-id profile when none is
  /// named.
  Future<void> saveDefaultNetSalary(double amount, {int? profileId}) async {
    if (amount < 0) {
      throw ArgumentError.value(
          amount, 'amount', 'Net salary cannot be negative');
    }
    await _isar.writeTxn(() async {
      final profile = profileId != null
          ? await _isar.userProfiles.get(profileId)
          : await _isar.userProfiles.where().findFirst();
      if (profile == null) return;
      profile.defaultNetSalary = amount;
      profile.updatedAt = DateTime.now();
      await _isar.userProfiles.put(profile);
    });
  }

  QueryBuilder<MonthlyBudget, MonthlyBudget, QAfterFilterCondition>
      _budgetQuery(ContextRef context) {
    final filter = _isar.monthlyBudgets.filter();
    final scoped = context.isShared
        ? filter.sharedSpaceIdEqualTo(context.spaceId)
        : filter.profileIdEqualTo(context.profileKey);
    return scoped.and().yearMonthEqualTo(context.yearMonth);
  }

  // ---------------------------------------------------------------------------
  // Legacy personal-context wrappers (single-profile behaviour, R2)
  // ---------------------------------------------------------------------------

  /// Lowest-id profile's context, or `null` when no profile exists yet.
  ///
  /// Legacy methods also work with zero profiles: they then operate on the
  /// unclaimed row for the month, keeping the pre-011 single-profile shape.
  Future<ContextRef?> _personalContext(String yearMonth) async {
    final profiles = await _isar.userProfiles.where().findAll();
    if (profiles.isEmpty) return null;
    profiles.sort((a, b) => a.id.compareTo(b.id));
    return ContextRef.personal(
        profileId: profiles.first.id, yearMonth: yearMonth);
  }

  /// The legacy single-profile write target for [yearMonth]: the lowest-id
  /// profile's row (claiming a pre-011 row for it), or the unclaimed row when
  /// no profile exists. Caller holds a write transaction.
  Future<MonthlyBudget> _ensureLegacyMonthTxn(String yearMonth) async {
    final context = await _personalContext(yearMonth);
    if (context == null) {
      final existing = await _unclaimedRow(yearMonth);
      return existing ?? await _provisionUnclaimed(yearMonth);
    }
    return _ensureMonthInTxn(context);
  }

  /// The row for [yearMonth], or `null` if the month has never been opened.
  ///
  /// Serves the personal-context row when a profile exists, and otherwise the
  /// unclaimed row — reads never write a claim.
  Future<MonthlyBudget?> getMonth(String yearMonth) async {
    final context = await _personalContext(yearMonth);
    if (context != null) {
      final inContext = await _budgetQuery(context).findFirst();
      if (inContext != null) return inContext;
    }
    return _unclaimedRow(yearMonth);
  }

  /// Live view of [yearMonth], yielding `null` until provisioned.
  Stream<MonthlyBudget?> watchMonth(String yearMonth) {
    return _isar.monthlyBudgets
        .filter()
        .yearMonthEqualTo(yearMonth)
        .watch(fireImmediately: true)
        .map((budgets) => budgets.isNotEmpty ? budgets.first : null);
  }

  /// Returns the row for [yearMonth], creating it if this is the first time the
  /// month is visited.
  ///
  /// A new month is provisioned with a zero opening balance that is explicitly
  /// *not* confirmed and no convert-to choice, so it follows the profile's main
  /// currency. Nothing is copied from the previous month (FR-007, FR-011).
  Future<MonthlyBudget> ensureMonth(String yearMonth) {
    return _isar.writeTxn(() => _ensureLegacyMonthTxn(yearMonth));
  }

  Future<void> saveOpeningBalance(String yearMonth, double amount) {
    if (amount < 0) {
      throw ArgumentError.value(
          amount, 'amount', 'Opening balance cannot be negative');
    }
    return _isar.writeTxn(() async {
      final budget = await _ensureLegacyMonthTxn(yearMonth);
      budget.baseAvailableAmount = amount;
      budget.openingBalanceConfirmed = true;
      budget.updatedAt = DateTime.now();
      await _isar.monthlyBudgets.put(budget);
    });
  }

  Future<void> saveConvertTo(String yearMonth, CurrencyCode? currency) {
    return _isar.writeTxn(() async {
      final budget = await _ensureLegacyMonthTxn(yearMonth);
      budget.currency = currency?.name;
      budget.updatedAt = DateTime.now();
      await _isar.monthlyBudgets.put(budget);
    });
  }

  Future<void> saveNetSalaryOverride(String yearMonth, double? amount) {
    if (amount != null && amount < 0) {
      throw ArgumentError.value(
          amount, 'amount', 'Net salary cannot be negative');
    }
    return _isar.writeTxn(() async {
      final budget = await _ensureLegacyMonthTxn(yearMonth);
      budget.netSalaryOverride = amount;
      budget.updatedAt = DateTime.now();
      await _isar.monthlyBudgets.put(budget);
    });
  }

  /// Income applied to [yearMonth]: the month's own override when it has one,
  /// otherwise the profile default (FR-002, FR-003).
  ///
  /// With no profile the default is zero (`[getDefaultNetSalary]` on an empty
  /// profile table), matching the pre-011 no-row behaviour.
  Future<ResolvedIncome> resolveIncome(String yearMonth) async {
    final context = await _personalContext(yearMonth);
    if (context == null) {
      final month = await _unclaimedRow(yearMonth);
      return ResolvedIncome.resolve(
        override: month?.netSalaryOverride,
        profileDefault: await getDefaultNetSalary(),
      );
    }
    return resolveIncomeInContext(context);
  }
}
