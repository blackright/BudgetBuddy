import '../../../core/models/category.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/money.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/network/rate_types.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../engine/currency_conversion.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../expenses/models/reimbursement.dart';
import '../domain/chart_filters.dart';

/// One stored amount after normalization into the display currency.
///
/// [excluded] is the honest-degraded flag (FR-005): when `true`, the record's
/// currency could not be converted, so it contributes nothing to any total and
/// is counted in `ChartSeries.excludedCount` instead of being silently zeroed.
class NormalizedAmount {
  const NormalizedAmount(
    this.minorUnits, {
    this.excluded = false,
    this.stale = false,
  });

  /// A record that could not be converted and must be excluded, not zeroed.
  const NormalizedAmount.excluded({this.stale = false})
      : minorUnits = 0,
        excluded = true;

  /// The value in whole minor units of the display currency (`0` when
  /// [excluded]).
  final int minorUnits;

  /// Whether this record was dropped because its currency could not be
  /// converted.
  final bool excluded;

  /// Whether the rate that produced [minorUnits] was stale.
  final bool stale;
}

/// An [Expense] paired with its normalized value.
class NormalizedExpense {
  const NormalizedExpense({required this.expense, required this.amount});

  final Expense expense;
  final NormalizedAmount amount;
}

/// A [Reimbursement] paired with its normalized value.
class NormalizedReimbursement {
  const NormalizedReimbursement({
    required this.reimbursement,
    required this.amount,
  });

  final Reimbursement reimbursement;
  final NormalizedAmount amount;
}

/// A [MedicalBill] with each money field it exposes normalized.
class NormalizedMedicalBill {
  const NormalizedMedicalBill({
    required this.bill,
    required this.fundsImpact,
    required this.patientShare,
    required this.insurerPaid,
  });

  final MedicalBill bill;

  /// The bill's effect on the budget (see `MedicalBill.fundsImpact`).
  final NormalizedAmount fundsImpact;

  /// The user's share of the charge.
  final NormalizedAmount patientShare;

  /// The insurer's share of the charge.
  final NormalizedAmount insurerPaid;
}

/// Every context-scoped row a chart can need, already normalized into
/// [displayCurrency] (contracts/chart-data.md §2).
///
/// Pure with respect to the database: it is assembled once by a provider and
/// then read by the pure `chart_query.dart` functions. It carries no Isar
/// handle, so it unit-tests without a database.
class AnalyticsSnapshot {
  const AnalyticsSnapshot({
    required this.context,
    required this.filters,
    required this.displayCurrency,
    required this.rateTable,
    required this.expenses,
    required this.reimbursements,
    required this.medicalBills,
    required this.month,
    required this.members,
    required this.categories,
    this.openingAvailableMinorUnits = 0,
  });

  /// The context every row below belongs to.
  final ContextRef context;

  /// The active filters (already applied as restrictions, not yet aggregated).
  final ChartFilters filters;

  /// The currency every normalized amount is denominated in.
  final CurrencyCode displayCurrency;

  /// The rate table that governs [context]'s month (never `null` — the registry
  /// always falls back to the bundled baseline).
  final RateTable? rateTable;

  final List<NormalizedExpense> expenses;
  final List<NormalizedReimbursement> reimbursements;
  final List<NormalizedMedicalBill> medicalBills;
  final MonthlyBudget? month;
  final List<SharedMember> members;
  final Map<String, Category> categories;

  /// The month's starting available amount, normalized into [displayCurrency]
  /// (whole minor units). Zero when the month has no budget. It is the baseline
  /// the available-amount trend counts down from.
  final int openingAvailableMinorUnits;

  /// Whether the governing rate table is stale.
  bool get isStale => rateTable?.isStale ?? false;

  /// Whether there is nothing at all to draw in this context.
  bool get isEmpty =>
      expenses.isEmpty && reimbursements.isEmpty && medicalBills.isEmpty;
}

/// Turns context-scoped rows into a currency-safe [AnalyticsSnapshot].
///
/// This is the only class that touches the rate registry for the charts
/// (contracts/chart-data.md §1): it owns display-currency resolution and every
/// conversion, so no chart has to. The aggregation itself lives in the pure
/// `chart_query.dart` functions, which consume the snapshot — keeping the
/// "no chart converts on its own" guarantee (FR-001).
class AnalyticsRepository {
  AnalyticsRepository(this._rateRegistry);

  final RateTableRegistry _rateRegistry;

  /// The table that governs [yearMonth] (seal → live → bundled).
  RateTable? tableFor(String yearMonth) => _rateRegistry.tableFor(yearMonth);

  /// Normalizes [minorUnits] of [from] into [display].
  ///
  /// - `from == null` (a legacy/unsupported currency): excluded, never guessed.
  /// - not convertible (`rate == null`, missing or incomplete table): excluded,
  ///   never zero.
  /// - otherwise: the converted value, flagged stale when the table is stale.
  NormalizedAmount normalize(
    int minorUnits,
    CurrencyCode? from,
    CurrencyCode display,
    RateTable? table,
  ) {
    if (from == null) {
      return NormalizedAmount.excluded(stale: table?.isStale ?? false);
    }
    final result = convert(Money(minorUnits, from), display, table);
    if (result.isDegraded) {
      return NormalizedAmount.excluded(stale: result.isStale);
    }
    return NormalizedAmount(result.amount.minorUnits, stale: result.isStale);
  }

  /// Assembles a snapshot from the rows a context resolves to.
  ///
  /// Display currency is the month's convert-to choice when set, otherwise
  /// [mainCurrency] (the space's shared currency in a shared context, the
  /// profile's main currency otherwise).
  AnalyticsSnapshot build({
    required ContextRef context,
    required CurrencyCode mainCurrency,
    ChartFilters filters = ChartFilters.none,
    required List<Expense> expenses,
    required List<Reimbursement> reimbursements,
    required List<MedicalBill> medicalBills,
    required MonthlyBudget? month,
    required List<SharedMember> members,
    required List<Category> categories,
    CurrencyCode? displayOverride,
  }) {
    final display =
        displayOverride ?? resolveContextDisplayCurrency(month, mainCurrency);
    final table = _rateRegistry.tableFor(context.yearMonth);

    // The baseline the available trend counts down from, normalized through the
    // same path every other figure uses (contract chart-data.md §1).
    final opening = month == null
        ? 0
        : normalize(
            Money.fromMajor(month.baseAvailableAmount, mainCurrency).minorUnits,
            mainCurrency,
            display,
            table,
          ).minorUnits;

    return AnalyticsSnapshot(
      context: context,
      filters: filters,
      displayCurrency: display,
      rateTable: table,
      expenses: [
        for (final expense in expenses)
          NormalizedExpense(
            expense: expense,
            amount: normalize(
              expense.amount,
              expense.currencyCode,
              display,
              table,
            ),
          ),
      ],
      reimbursements: [
        for (final reimbursement in reimbursements)
          NormalizedReimbursement(
            reimbursement: reimbursement,
            amount: normalize(
              reimbursement.amount,
              reimbursement.currencyCode,
              display,
              table,
            ),
          ),
      ],
      medicalBills: [
        for (final bill in medicalBills) _normalizeBill(bill, display, table),
      ],
      month: month,
      members: members,
      categories: {
        for (final category in categories) category.categoryId: category,
      },
      openingAvailableMinorUnits: opening,
    );
  }

  /// A bill's own currency, or the display currency when it follows its linked
  /// expense (`''`) — matching the medical feature's existing behaviour so bills
  /// never disappear from a total (FR-016).
  NormalizedMedicalBill _normalizeBill(
    MedicalBill bill,
    CurrencyCode display,
    RateTable? table,
  ) {
    final from = bill.currencyCode ?? display;
    return NormalizedMedicalBill(
      bill: bill,
      fundsImpact: normalize(bill.fundsImpact, from, display, table),
      patientShare: normalize(bill.patientShareAmount, from, display, table),
      insurerPaid: normalize(bill.insurerPaidAmount, from, display, table),
    );
  }
}
