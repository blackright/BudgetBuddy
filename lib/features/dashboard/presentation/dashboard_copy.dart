import '../../../core/models/currency_code.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../core/services/borrowing_service.dart';
import '../../../shared/presentation/money_format.dart';
import '../../engine/month_summary.dart';
import 'budget_status.dart';

/// One place for the Dashboard's short, user-facing copy.
///
/// The default view deliberately uses a small vocabulary (FR-056). Keeping the
/// words here means the hero, rows and tests cannot drift into synonyms such as
/// "Free to spend" or "Allocation" (FR-057/FR-058).
class DashboardCopy {
  const DashboardCopy._();

  static const String kept = 'Kept';
  static const String thisMonthCaption = 'this month';
  static const String monthBreakdown = 'Month breakdown';
  static const String paidOut = 'paid out';
  static const String back = 'back';

  static const String budgets = 'Budgets';
  static const String seeAll = 'See all';
  static const String addExpense = 'Add expense';
  static const String addMedicalBill = 'Add medical bill';
  static const String savings = 'Savings';
  static const String nextStep = 'Next step';
  static const String analytics = 'Analytics';

  static const String today = 'Today';
  static const String convertMonth = 'Convert month';
  static const String moveMonth = 'Move month';
  static const String history = 'History';
  static const String more = 'More';

  static const String loading = 'Loading';
  static const String couldNotLoad = "Couldn't load";
  static const String couldNotLoadThisMonth = "Couldn't load this month";
  static const String retry = 'Retry';
  static const String incomplete = 'Incomplete';
  static const String planThisMonth = 'Plan this month';
  static const String planThisMonthDetail =
      'Add income or a budget to get started.';
  static const String deficitThisMonth = 'Deficit this month';

  static const String left = 'left';
  static const String overBy = 'Over by';
  static const String spent = 'spent';
  static const String noBudget = 'no budget';
  static const String onTrack = 'On track';
  static const String close = 'Close';
  static const String fullyUsed = 'Fully used';
  static const String createFirstBudget = 'Create your first budget';

  static const String startSaving = 'Start saving';
  static const String needsReview = 'Needs review';
  static const String savingsPaused = 'Savings paused';

  static const String borrowed = 'Borrowed';
  static const String deficit = 'Deficit';
  static const String recent = 'Recent';

  /// The hero caption: `this month` only for the current calendar month.
  static String heroCaption(String yearMonth, {DateTime? now}) {
    return yearMonth == currentYearMonth(now)
        ? thisMonthCaption
        : 'in ${monthLabel(yearMonth)}';
  }

  /// The month-statement row title, using the same rule as [heroCaption].
  static String monthStatementLabel(String yearMonth, {DateTime? now}) {
    return yearMonth == currentYearMonth(now)
        ? monthBreakdown
        : '${monthLabel(yearMonth)} breakdown';
  }

  /// One supporting line: what left the account and, when non-zero, what came
  /// back. It never restates the kept figure (FR-003).
  static String heroSupportingLine(
      MonthSummary summary, CurrencyCode currency) {
    if (summary.paymentsMade == 0 && summary.moneyReturned == 0) {
      return '';
    }
    final paid = formatMajorUnits(summary.paymentsMade, currency);
    final base = '$paid $paidOut';
    if (summary.moneyReturned <= 0) return base;
    final returned = formatMajorUnits(summary.moneyReturned, currency);
    return '$base · $returned $back';
  }

  /// Dashboard wording for a budget status, always paired with text so colour
  /// is never the only signal (FR-030).
  static String budgetStatusLabel(
    BudgetStatus status, {
    required CurrencyCode currency,
    int overspendMinor = 0,
  }) {
    return status.dashboardLabel(
      currency: currency,
      overspendMinor: overspendMinor,
    );
  }
}
