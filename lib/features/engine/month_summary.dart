import '../../core/models/expense.dart';
import '../../core/models/money.dart';
import '../../features/expenses/models/reimbursement.dart';

/// The financial verdict for exactly one calendar month.
///
/// A pure derivation — never persisted, never cached across writes (FR-017) —
/// so the arithmetic in `contracts/month-summary.md` can be verified as a plain
/// unit test with no database (SC-004). No row from any other month can reach
/// this object, which is what makes month isolation hold by construction
/// (FR-016).
///
/// Money semantics, straight from the contract:
/// - `kept = income - paymentsMade + moneyReturned`
/// - `moneyInBank = openingBalance + kept`
///
/// Neither figure is ever floored at zero: an over-reimbursement is surfaced
/// through [excessReturned] instead of being silently clamped (R14, invariant
/// I7).
class MonthSummary {
  const MonthSummary({
    required this.yearMonth,
    required this.income,
    required this.usesOverriddenIncome,
    required this.paymentsMade,
    required this.moneyReturned,
    required this.planned,
    required this.cancelled,
    required this.medicalPaid,
    required this.excessReturned,
    this.openingBalance,
  });

  /// Assembles a summary for [yearMonth].
  ///
  /// [expenses] must already be scoped to [yearMonth]; [reimbursements] must
  /// already be scoped by `originYearMonth == yearMonth` (FR-032), not by the
  /// month they happened to be recorded in.
  ///
  /// [targetPaidAmounts] maps a reimbursement's `expenseId` to that target's
  /// paid amount in primary currency, for reimbursements that belong to this
  /// month but whose target expense lives in another one. It is only used to
  /// compute [excessReturned]; a missing entry contributes zero excess.
  factory MonthSummary.from({
    required String yearMonth,
    required double income,
    required bool usesOverriddenIncome,
    required List<Expense> expenses,
    required List<Reimbursement> reimbursements,
    required Money Function(Expense expense) convertExpense,
    required Money Function(Reimbursement reimbursement) convertReimbursement,
    double? openingBalance,
    Map<int, double> targetPaidAmounts = const {},
  }) {
    var paymentsMade = 0.0;
    var planned = 0.0;
    var cancelled = 0.0;
    var medicalPaid = 0.0;

    for (final expense in expenses) {
      final converted = convertExpense(expense).majorValue;
      switch (expense.status) {
        case ExpenseStatus.paid:
        case ExpenseStatus.reimbursed:
        case ExpenseStatus.partiallyReimbursed:
          paymentsMade += converted;
          if (_isMedical(expense)) medicalPaid += converted;
        case ExpenseStatus.planned:
          planned += converted;
        case ExpenseStatus.cancelled:
          cancelled += converted;
      }
    }

    var moneyReturned = 0.0;
    var excessReturned = 0.0;
    for (final reimbursement in reimbursements) {
      final converted = convertReimbursement(reimbursement).majorValue;
      moneyReturned += converted;
      final target = reimbursement.expenseId;
      if (target == null) continue;
      final targetPaid = targetPaidAmounts[target] ?? 0.0;
      final excess = converted - targetPaid;
      if (excess > 0) excessReturned += excess;
    }

    return MonthSummary(
      yearMonth: yearMonth,
      income: income,
      usesOverriddenIncome: usesOverriddenIncome,
      paymentsMade: paymentsMade,
      moneyReturned: moneyReturned,
      planned: planned,
      cancelled: cancelled,
      medicalPaid: medicalPaid,
      excessReturned: excessReturned,
      openingBalance: openingBalance,
    );
  }

  /// The month this report describes, as `YYYY-MM`.
  final String yearMonth;

  /// Resolved income: the month's override if present, else the profile
  /// default (FR-002, FR-003).
  final double income;

  /// True when [income] came from a per-month override (FR-005).
  final bool usesOverriddenIncome;

  /// Σ paid expense amounts, converted to primary currency.
  final double paymentsMade;

  /// Σ reimbursements attributed to this month (FR-032).
  final double moneyReturned;

  /// Σ planned expense amounts. Never affects [kept] or [moneyInBank]
  /// (FR-014, FR-015).
  final double planned;

  /// Σ cancelled expense amounts. Contributes to nothing but itself
  /// (Constitution IV); hidden detail only.
  final double cancelled;

  /// The medical subset of [paymentsMade] (FR-022, FR-056). Never exceeds it.
  final double medicalPaid;

  /// The portion of reimbursements that exceeded what was paid out, surfaced as
  /// its own figure rather than netted away (R14).
  final double excessReturned;

  /// Money in the bank at the start of the month, or `null` when the user has
  /// never confirmed one (FR-006, FR-010).
  final double? openingBalance;

  /// `income - paymentsMade + moneyReturned` (FR-012).
  double get kept => income - paymentsMade + moneyReturned;

  /// `openingBalance + kept`, or `null` when there is no confirmed opening
  /// balance — the app prompts rather than assuming a figure (FR-008, FR-010).
  double? get moneyInBank {
    final opening = openingBalance;
    if (opening == null) return null;
    return opening + kept;
  }

  /// Opening balance present *and* income recorded (FR-025).
  ///
  /// A future month holding only planned expenses is incomplete: `planned` is
  /// allowed there, but no real figure may be presented.
  bool get isComplete => openingBalance != null && income > 0;

  static bool _isMedical(Expense expense) =>
      expense.type == ExpenseType.medical ||
      expense.categoryId == _medicalCategoryId;

  /// Mirrors `MedicalRepository.medicalCategoryId`. Duplicated as a literal so
  /// this file stays free of feature imports.
  static const String _medicalCategoryId = 'health';
}
