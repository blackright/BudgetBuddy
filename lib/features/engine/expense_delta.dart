import '../../core/models/expense.dart';

/// The exact impact an expense edit has on the engine, expressed in the
/// budget's primary currency. Positive values mean *more* money available.
///
/// Mirrors the engine rules:
/// - `trueAvailable` is reduced only by **paid** expenses.
/// - `safeToSpend` is reduced by **paid + planned** expenses.
/// - Cancelled expenses have no impact.
class ExpenseDelta {
  final double trueAvailableDelta;
  final double safeToSpendDelta;

  const ExpenseDelta({
    required this.trueAvailableDelta,
    required this.safeToSpendDelta,
  });

  static const zero = ExpenseDelta(trueAvailableDelta: 0, safeToSpendDelta: 0);

  /// Computes the delta between an [before] and [after] snapshot of an
  /// expense. Pass `null` for [before] when creating (e.g. duplicate), or
  /// `null` for [after] when deleting.
  factory ExpenseDelta.between({
    ExpenseSnapshot? before,
    ExpenseSnapshot? after,
  }) {
    final oldPaid = before?.paidCost ?? 0.0;
    final newPaid = after?.paidCost ?? 0.0;
    final oldCommitted = before?.committedCost ?? 0.0;
    final newCommitted = after?.committedCost ?? 0.0;

    return ExpenseDelta(
      trueAvailableDelta: oldPaid - newPaid,
      safeToSpendDelta: oldCommitted - newCommitted,
    );
  }

  /// True when applying this delta pushes [currentSafeToSpend] below zero
  /// *and* the edit actually makes things worse (avoids nagging on edits that
  /// reduce spending while already over budget).
  bool wouldOverspend(double currentSafeToSpend) =>
      safeToSpendDelta < 0 && currentSafeToSpend + safeToSpendDelta < 0;

  @override
  String toString() =>
      'ExpenseDelta(trueAvailable: $trueAvailableDelta, safeToSpend: $safeToSpendDelta)';
}

/// Minimal, immutable view of the fields that affect the engine. Lets the UI
/// compute deltas for unsaved form state without mutating the Isar object.
class ExpenseSnapshot {
  final double amount;
  final double exchangeRateToPrimary;
  final ExpenseStatus status;

  const ExpenseSnapshot({
    required this.amount,
    required this.exchangeRateToPrimary,
    required this.status,
  });

  factory ExpenseSnapshot.of(Expense e) => ExpenseSnapshot(
        amount: e.amount,
        exchangeRateToPrimary: e.exchangeRateToPrimary,
        status: e.status,
      );

  double get _primaryAmount => amount * exchangeRateToPrimary;

  double get paidCost => status == ExpenseStatus.paid ? _primaryAmount : 0.0;

  double get committedCost =>
      status == ExpenseStatus.paid || status == ExpenseStatus.planned
          ? _primaryAmount
          : 0.0;
}
