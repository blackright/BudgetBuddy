import '../../core/models/currency_code.dart';
import '../../core/models/expense.dart';

/// Minimal, immutable view of the fields that affect the engine. Lets the UI
/// compute deltas for unsaved form state without mutating the Isar object.
///
/// [amount] is stored in the expense's own currency (minor units) so it can be
/// converted with the same rates the engine uses. A `null` [currency] means the
/// row carries a legacy/unsupported code and contributes nothing to the delta.
class ExpenseSnapshot {
  final int amount;
  final CurrencyCode? currency;
  final ExpenseStatus status;

  const ExpenseSnapshot({
    required this.amount,
    required this.currency,
    required this.status,
  });

  factory ExpenseSnapshot.of(Expense e) => ExpenseSnapshot(
        amount: e.amount,
        currency: e.currencyCode,
        status: e.status,
      );

  double paidCost(double Function(ExpenseSnapshot) toPrimary) =>
      status == ExpenseStatus.paid ? toPrimary(this) : 0.0;

  double committedCost(double Function(ExpenseSnapshot) toPrimary) =>
      status == ExpenseStatus.paid || status == ExpenseStatus.planned
          ? toPrimary(this)
          : 0.0;
}

/// Difference in the converted (primary-currency) amounts an edit introduces to
/// the engine. The UI supplies a `toPrimary` converter so the delta is measured
/// with the active budget's rates.
class ExpenseDelta {
  final double trueAvailableDelta;
  final double safeToSpendDelta;

  const ExpenseDelta({
    required this.trueAvailableDelta,
    required this.safeToSpendDelta,
  });

  static const zero = ExpenseDelta(trueAvailableDelta: 0, safeToSpendDelta: 0);

  /// True when applying this delta pushes [currentSafeToSpend] below zero
  /// *and* the edit actually makes things worse.
  bool wouldOverspend(double currentSafeToSpend) =>
      safeToSpendDelta < 0 && currentSafeToSpend + safeToSpendDelta < 0;

  factory ExpenseDelta.between({
    ExpenseSnapshot? before,
    ExpenseSnapshot? after,
    required double Function(ExpenseSnapshot) toPrimary,
  }) {
    double paid(ExpenseSnapshot? s) => s == null ? 0.0 : s.paidCost(toPrimary);
    double committed(ExpenseSnapshot? s) =>
        s == null ? 0.0 : s.committedCost(toPrimary);
    return ExpenseDelta(
      trueAvailableDelta: paid(before) - paid(after),
      safeToSpendDelta: committed(before) - committed(after),
    );
  }

  @override
  String toString() =>
      'ExpenseDelta(trueAvailable: $trueAvailableDelta, safeToSpend: $safeToSpendDelta)';
}
