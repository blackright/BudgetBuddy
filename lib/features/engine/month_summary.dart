import '../../core/models/expense.dart';
import '../../core/models/money.dart';
import '../../core/services/free_funds.dart';
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
/// - `kept = income - paymentsMade + moneyReturned - setAside - carryOver`
/// - `moneyInBank = openingBalance + keptBeforeAllocations` (actual bank money,
///   not earmarked money)
///
/// `setAside` is the unused part of the allocations (allocation - spent, never
/// below zero): money still sitting in the profile envelopes, so it is not free
/// to spend. `carryOver` is 0 until Phase 8 (Carry Forward month-end) lands.
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
    this.insuranceReturned = 0.0,
    this.expenseReturned = 0.0,
    this.openingBalance,
    // T143: allocation data. `allocated` is the total set aside across every
    // budget profile; `setAside` is the part of that which has not been spent
    // yet (allocation - spent, never below zero). `kept` subtracts `setAside`
    // so the free money — the reserve overspending draws from — is what the
    // user sees. `moneyInBank` keeps its old meaning (actual bank money) via
    // `keptBeforeAllocations`, so nothing existing breaks.
    this.allocated = 0.0,
    this.setAside = 0.0,
    // T150: carry-over hook for Phase 8 month-end policies. When Carry
    // Forward is in effect, last month's unused allocation is added here so
    // the free money reflects it. Left at 0 until Phase 8 lands.
    this.carryOver = 0.0,
    this.carriedIn = 0.0,
    this.releasedAtMonthEnd = 0.0,
    this.vaultTransfers = 0.0,
    this.resolvedFreeToSpend,
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
  ///
  /// [medicalTargetIds] holds the `expenseId`s of reimbursements whose target is
  /// a **medical** bill. A payout against one of those is an insurance return;
  /// every other payout — an ordinary reimbursable expense, or a return whose
  /// target was deleted (`expenseId == null`) — is an expense return (US8).
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
    Set<int> medicalTargetIds = const {},
    // T143/T144: allocation inputs. `allocated` is the total set aside across
    // every budget profile; `setAside` is the unused portion (allocation -
    // spent, never below zero), both in the display currency. `carryOver` is
    // the unused allocation carried in from last month (Phase 8).
    double allocated = 0.0,
    double setAside = 0.0,
    double carryOver = 0.0,
    double carriedIn = 0.0,
    double releasedAtMonthEnd = 0.0,
    double vaultTransfers = 0.0,
    double? resolvedFreeToSpend,
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
    var insuranceReturned = 0.0;
    var expenseReturned = 0.0;
    for (final reimbursement in reimbursements) {
      final converted = convertReimbursement(reimbursement).majorValue;
      moneyReturned += converted;
      final target = reimbursement.expenseId;
      // Split every return by its target's kind (US8). A payout against a
      // medical bill is an insurance return; a payout against an ordinary
      // expense — or one whose target was deleted — is an expense return. The
      // two always sum back to [moneyReturned].
      if (target != null && medicalTargetIds.contains(target)) {
        insuranceReturned += converted;
      } else {
        expenseReturned += converted;
      }
      if (target == null) continue;
      // A target the caller does not know about lives in another month (a
      // payout credited to the month after its bill). Its paid amount cannot be
      // judged here, so it contributes no excess rather than being counted as
      // one in full.
      final targetPaid = targetPaidAmounts[target];
      if (targetPaid == null) continue;
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
      insuranceReturned: insuranceReturned,
      expenseReturned: expenseReturned,
      openingBalance: openingBalance,
      allocated: allocated,
      setAside: setAside,
      carryOver: carryOver,
      carriedIn: carriedIn,
      releasedAtMonthEnd: releasedAtMonthEnd,
      vaultTransfers: vaultTransfers,
      resolvedFreeToSpend: resolvedFreeToSpend,
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

  /// The part of [moneyReturned] paid back on a **medical** bill — an insurance
  /// return (US8). Always non-negative.
  final double insuranceReturned;

  /// The part of [moneyReturned] paid back on an ordinary expense (or a return
  /// whose target was deleted) — an expense return (US8). Always non-negative.
  ///
  /// [insuranceReturned] + [expenseReturned] always equals [moneyReturned].
  final double expenseReturned;

  /// Money in the bank at the start of the month, or `null` when the user has
  /// never confirmed one (FR-006, FR-010).
  final double? openingBalance;

  /// Total allocated across every budget profile this month, in the display
  /// currency (T143, FR-003). Reference only — it is `setAside` that
  /// reduces `kept`.
  final double allocated;

  /// The money still sitting inside the profile envelopes: the unused part of
  /// the allocations (allocation − spent, never below zero), in the display
  /// currency (T143, FR-003, FR-011).
  final double setAside;

  /// Additional outgoing carry reservation not already covered by the live
  /// unused envelopes. This stays reserved if late source spending consumes
  /// part of an envelope after its immutable settlement.
  final double carryOver;

  /// Settlement funds are not income or bank-balance changes. Incoming carry
  /// offsets its inclusion in next month's allocation; Reset releases an
  /// unused envelope without rewriting historical allocation records.
  final double carriedIn, releasedAtMonthEnd;

  /// Withdrawals minus deposits; an internal transfer, never income/spending.
  final double vaultTransfers;

  /// Accounting-currency verdict converted once at the display boundary.
  final double? resolvedFreeToSpend;

  /// `income - paymentsMade + moneyReturned - setAside - carryOver` (FR-012,
  /// T143). This is the free money — the reserve overspending draws from.
  double get kept =>
      resolvedFreeToSpend ??
      freeToSpend(
              income: income,
              paid: paymentsMade,
              returned: moneyReturned,
              unused: setAside,
              carry: carryOver,
              incoming: carriedIn,
              released: releasedAtMonthEnd,
              transfers: vaultTransfers)
          .toDouble();

  /// The same calculation without the allocation carve-out, so `moneyInBank`
  /// keeps its old meaning (actual money in the bank, not earmarked money).
  double get keptBeforeAllocations =>
      income - paymentsMade + moneyReturned + vaultTransfers;

  /// `openingBalance + keptBeforeAllocations`, or `null` when there is no
  /// confirmed opening balance — the app prompts rather than assuming a figure
  /// (FR-008, FR-010).
  double? get moneyInBank {
    final opening = openingBalance;
    if (opening == null) return null;
    return opening + keptBeforeAllocations;
  }

  /// Opening balance present *and* income recorded (FR-025).
  ///
  /// A future month holding only planned expenses is incomplete: `planned` is
  /// allowed there, but no real figure may be presented.
  bool get isComplete => openingBalance != null && income > 0;

  static bool _isMedical(Expense expense) =>
      expense.type == ExpenseType.medical ||
      expense.categoryId == _medicalCategoryId;

  /// The `id`s of the **medical** targets among [targets] (US8).
  ///
  /// Classification is strictly by [ExpenseType] (the user's choice for US8): an
  /// expense filed under the health category but stored as a standard expense is
  /// an expense return, not an insurance one.
  static Set<int> medicalTargetIdsOf(Iterable<Expense> targets) => {
        for (final expense in targets)
          if (expense.type == ExpenseType.medical) expense.id,
      };

  /// Mirrors `MedicalRepository.medicalCategoryId`. Duplicated as a literal so
  /// this file stays free of feature imports.
  static const String _medicalCategoryId = 'health';
}
