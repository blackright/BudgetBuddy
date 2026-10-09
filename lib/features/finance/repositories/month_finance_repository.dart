import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/user_profile.dart';

final monthFinanceRepositoryProvider = Provider<MonthFinanceRepository>((ref) {
  return MonthFinanceRepository(IsarHelper.instance);
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
/// `yearMonth`. Income is resolved through the active profile rather than a
/// foreign key, so there is nothing to keep in sync.
class MonthFinanceRepository {
  MonthFinanceRepository(this._isar);

  final Isar _isar;

  /// The row for [yearMonth], or `null` if the month has never been opened.
  Future<MonthlyBudget?> getMonth(String yearMonth) {
    return _isar.monthlyBudgets
        .filter()
        .yearMonthEqualTo(yearMonth)
        .findFirst();
  }

  /// Live view of [yearMonth], yielding `null` until it is provisioned.
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
    return _isar.writeTxn(() => _ensureMonthInTxn(yearMonth));
  }

  /// [ensureMonth] without opening a transaction, for callers that already hold
  /// one. Isar does not support nested write transactions.
  Future<MonthlyBudget> _ensureMonthInTxn(String yearMonth) async {
    final existing = await _isar.monthlyBudgets
        .filter()
        .yearMonthEqualTo(yearMonth)
        .findFirst();
    if (existing != null) return existing;

    final now = DateTime.now();
    final budget = MonthlyBudget()
      ..yearMonth = yearMonth
      ..baseAvailableAmount = 0.0
      ..openingBalanceConfirmed = false
      // No convert-to choice yet: the month follows the profile's main currency
      // until the user picks otherwise (FR-011).
      ..createdAt = now
      ..updatedAt = now;
    budget.id = await _isar.monthlyBudgets.put(budget);
    return budget;
  }

  /// Records the month's opening balance and marks it confirmed (FR-006,
  /// FR-011).
  ///
  /// Stays editable after the month has passed. Passing `0` is a legitimate
  /// value and is stored as confirmed, unlike a month that was never touched.
  Future<void> saveOpeningBalance(String yearMonth, double amount) {
    if (amount < 0) {
      throw ArgumentError.value(
          amount, 'amount', 'Opening balance cannot be negative');
    }
    return _isar.writeTxn(() async {
      final budget = await _ensureMonthInTxn(yearMonth);
      budget.baseAvailableAmount = amount;
      budget.openingBalanceConfirmed = true;
      budget.updatedAt = DateTime.now();
      await _isar.monthlyBudgets.put(budget);
    });
  }

  /// Sets the month's display-only convert-to choice (FR-011).
  ///
  /// Pass `null` to clear it so the month follows the profile's main currency
  /// again. Display-only: no stored amount, rate or seal is touched.
  Future<void> saveConvertTo(String yearMonth, CurrencyCode? currency) {
    return _isar.writeTxn(() async {
      final budget = await _ensureMonthInTxn(yearMonth);
      budget.currency = currency?.name;
      budget.updatedAt = DateTime.now();
      await _isar.monthlyBudgets.put(budget);
    });
  }

  /// Overrides income for [yearMonth] only. Pass `null` to hand the month back
  /// to the profile default (FR-003).
  Future<void> saveNetSalaryOverride(String yearMonth, double? amount) {
    if (amount != null && amount < 0) {
      throw ArgumentError.value(
          amount, 'amount', 'Net salary cannot be negative');
    }
    return _isar.writeTxn(() async {
      final budget = await _ensureMonthInTxn(yearMonth);
      budget.netSalaryOverride = amount;
      budget.updatedAt = DateTime.now();
      await _isar.monthlyBudgets.put(budget);
    });
  }

  /// The profile-wide default applied to any month without an override
  /// (FR-001).
  Future<double> getDefaultNetSalary() async {
    final profile = await _isar.userProfiles.where().findFirst();
    return profile?.defaultNetSalary ?? 0.0;
  }

  /// Updates the profile default. Months that already exist are untouched —
  /// they only stop following the default once they carry their own override
  /// (FR-004).
  Future<void> saveDefaultNetSalary(double amount) async {
    if (amount < 0) {
      throw ArgumentError.value(
          amount, 'amount', 'Net salary cannot be negative');
    }
    await _isar.writeTxn(() async {
      final profile = await _isar.userProfiles.where().findFirst();
      if (profile == null) return;
      profile.defaultNetSalary = amount;
      profile.updatedAt = DateTime.now();
      await _isar.userProfiles.put(profile);
    });
  }

  /// Income applied to [yearMonth]: the month's own override when it has one,
  /// otherwise the profile default (FR-002, FR-003).
  ///
  /// Reporting [ResolvedIncome.usesOverride] lets the UI mark a month whose
  /// figure does not come from the default (FR-005).
  Future<ResolvedIncome> resolveIncome(String yearMonth) async {
    final month = await getMonth(yearMonth);
    return ResolvedIncome.resolve(
      override: month?.netSalaryOverride,
      profileDefault: await getDefaultNetSalary(),
    );
  }
}
