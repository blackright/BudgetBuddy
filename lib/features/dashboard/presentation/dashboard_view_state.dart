import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../core/services/borrowing_service.dart';
import '../../../shared/presentation/money_format.dart';
import '../../engine/month_summary.dart';
import '../../vault/models/savings_vault.dart';
import '../providers/dashboard_providers.dart';
import 'budget_status.dart';
import 'dashboard_copy.dart';

/// Whether a presentation surface has usable data.
enum DashboardDataStatus { loading, error, ready }

/// The savings row's specific ready state.
enum DashboardSavingsState { value, empty, needsReview, paused }

/// The selected month's verdict, derived from the engine without changing it.
///
/// The provider supplies an [AsyncValue] so "still loading" and "failed" are
/// distinguishable from a genuine zero (FR-079). This model turns that state
/// into the labels and flags the hero needs.
class DashboardMonthVerdict {
  const DashboardMonthVerdict({
    required this.status,
    required this.yearMonth,
    required this.isCurrentMonth,
    required this.isFutureMonth,
    this.summary,
  });

  final DashboardDataStatus status;
  final String yearMonth;
  final bool isCurrentMonth;
  final bool isFutureMonth;
  final MonthSummary? summary;

  bool get isReady => status == DashboardDataStatus.ready;

  bool get isComplete => summary?.isComplete ?? false;

  bool get isIncomplete => isReady && summary != null && !summary!.isComplete;

  bool get hasDeficit => (summary?.kept ?? 0) < 0;

  /// A future month with no recorded money is a planning surface, not a
  /// computed zero (FR-010).
  bool get isFutureEmpty => isFutureMonth && isReady && _hasNoRecordedMoney;

  double? get kept => summary?.kept;

  double? get paidOut => summary?.paymentsMade;

  double? get returned => summary?.moneyReturned;

  String get caption => isCurrentMonth
      ? DashboardCopy.thisMonthCaption
      : 'in ${monthLabel(yearMonth)}';

  String get statementLabel => isCurrentMonth
      ? DashboardCopy.monthBreakdown
      : '${monthLabel(yearMonth)} breakdown';

  bool get _hasNoRecordedMoney {
    final value = summary;
    if (value == null) return false;
    return value.openingBalance == null &&
        value.income == 0 &&
        value.paymentsMade == 0 &&
        (value.cashPaymentsMade ?? 0) == 0 &&
        value.moneyReturned == 0 &&
        (value.cashMoneyReturned ?? 0) == 0 &&
        value.planned == 0 &&
        value.cancelled == 0 &&
        value.medicalPaid == 0 &&
        value.allocated == 0 &&
        value.setAside == 0 &&
        value.carryOver == 0 &&
        value.carriedIn == 0 &&
        value.releasedAtMonthEnd == 0 &&
        value.vaultTransfers == 0 &&
        value.actualSalaryFunding == 0 &&
        value.resolvedFreeToSpend == null;
  }

  /// Maps the provider's state without showing stale data on failure.
  factory DashboardMonthVerdict.fromAsync(
    AsyncValue<MonthSummary> async, {
    required String yearMonth,
    DateTime? now,
  }) {
    final current = currentYearMonth(now);
    final status = async.hasError
        ? DashboardDataStatus.error
        : async.isLoading && !async.hasValue
            ? DashboardDataStatus.loading
            : DashboardDataStatus.ready;
    return DashboardMonthVerdict(
      status: status,
      yearMonth: yearMonth,
      isCurrentMonth: yearMonth == current,
      isFutureMonth: yearMonth.compareTo(current) > 0,
      summary: status == DashboardDataStatus.ready ? async.valueOrNull : null,
    );
  }
}

/// One line in the Budgets ledger, already mapped to Dashboard vocabulary.
class DashboardBudgetRow {
  const DashboardBudgetRow({
    required this.identity,
    required this.profileId,
    required this.isDirect,
    required this.name,
    required this.status,
    required this.statusLabel,
    required this.remainingMinor,
    required this.spentMinor,
    required this.usagePercent,
    required this.borrowedMinor,
    required this.deficitMinor,
    required this.recentExpenses,
    required this.expenseCount,
  });

  final String identity;
  final int profileId;
  final bool isDirect;
  final String name;
  final BudgetStatus status;
  final String statusLabel;
  final int remainingMinor;
  final int spentMinor;
  final double usagePercent;
  final int borrowedMinor;
  final int deficitMinor;
  final List<Expense> recentExpenses;
  final int expenseCount;

  bool get showsProgress => !isDirect;

  bool get isOverBudget => !isDirect && status == BudgetStatus.red;

  int get overspendMinor => remainingMinor < 0 ? -remainingMinor : 0;

  /// The amount the row presents when it is not showing an over-by label.
  int get shownAmountMinor => isDirect ? spentMinor : remainingMinor.abs();

  factory DashboardBudgetRow.fromProfile(
    DashboardProfileState profile,
    CurrencyCode currency,
  ) {
    final overspend = profile.remaining < 0 ? -profile.remaining : 0;
    final label = profile.isDirect
        ? DashboardCopy.noBudget
        : profile.status.dashboardLabel(
            currency: currency,
            overspendMinor: overspend,
          );
    return DashboardBudgetRow(
      identity: profile.identity,
      profileId: profile.id,
      isDirect: profile.isDirect,
      name: profile.name,
      status: profile.status,
      statusLabel: label,
      remainingMinor: profile.remaining,
      spentMinor: profile.spent,
      usagePercent: profile.state.usagePercent,
      borrowedMinor: profile.borrowed,
      deficitMinor: profile.deficit,
      recentExpenses: profile.recentExpenses,
      expenseCount: profile.expenseCount,
    );
  }
}

/// The Savings row's presentation state.
class DashboardSavingsRow {
  const DashboardSavingsRow({
    required this.status,
    required this.state,
    required this.message,
    this.balanceMinor,
    this.currency,
  });

  final DashboardDataStatus status;
  final DashboardSavingsState? state;
  final String message;
  final int? balanceMinor;
  final CurrencyCode? currency;

  bool get showRetry => status == DashboardDataStatus.error;

  bool get isValue => state == DashboardSavingsState.value;

  /// Maps the vault stream and its review message in the order fixed by
  /// `contracts/dashboard-rows.md` §5.
  factory DashboardSavingsRow.from({
    required AsyncValue<SavingsVault?> vault,
    required String? reviewMessage,
  }) {
    if (vault.hasError) {
      return const DashboardSavingsRow(
        status: DashboardDataStatus.error,
        state: null,
        message: DashboardCopy.couldNotLoad,
      );
    }
    if (vault.isLoading && !vault.hasValue) {
      return const DashboardSavingsRow(
        status: DashboardDataStatus.loading,
        state: null,
        message: DashboardCopy.loading,
      );
    }
    final value = vault.valueOrNull;
    if (value == null) {
      return const DashboardSavingsRow(
        status: DashboardDataStatus.ready,
        state: DashboardSavingsState.empty,
        message: DashboardCopy.startSaving,
      );
    }
    if (reviewMessage != null) {
      return const DashboardSavingsRow(
        status: DashboardDataStatus.ready,
        state: DashboardSavingsState.needsReview,
        message: DashboardCopy.needsReview,
      );
    }
    if (value.sweepPaused) {
      return const DashboardSavingsRow(
        status: DashboardDataStatus.ready,
        state: DashboardSavingsState.paused,
        message: DashboardCopy.savingsPaused,
      );
    }
    final code = value.currencyCode;
    if (code == null || !value.hasValidBalance) {
      return const DashboardSavingsRow(
        status: DashboardDataStatus.ready,
        state: DashboardSavingsState.needsReview,
        message: DashboardCopy.needsReview,
      );
    }
    return DashboardSavingsRow(
      status: DashboardDataStatus.ready,
      state: DashboardSavingsState.value,
      message: formatMinorUnits(value.totalMinor, code),
      balanceMinor: value.totalMinor,
      currency: code,
    );
  }
}

/// One outstanding setup suggestion, ranked for the single Next step row.
///
/// The icon deliberately stays on the source `SetupSuggestion`; this model is
/// pure Dart so it can be tested without a widget tree.
class DashboardSetupStep {
  const DashboardSetupStep({
    required this.title,
    required this.detail,
    required this.route,
    required this.priority,
  });

  final String title;
  final String detail;
  final String route;
  final int priority;

  /// FR-039 order: opening balance, income, budgets, first expense, optional
  /// exploration.
  static int priorityFor(String route) {
    switch (route) {
      case 'opening':
        return 1;
      case '/income_sources':
        return 2;
      case '/allocations':
        return 3;
      case '/add_expense':
        return 4;
      case '/medical':
        return 5;
      case '/spaces':
        return 6;
      default:
        return 7;
    }
  }

  factory DashboardSetupStep.from({
    required String title,
    required String detail,
    required String route,
  }) {
    return DashboardSetupStep(
      title: title,
      detail: detail,
      route: route,
      priority: priorityFor(route),
    );
  }

  /// Sorts by priority while keeping provider order for equal priorities.
  static List<DashboardSetupStep> ordered(
    Iterable<DashboardSetupStep> steps,
  ) {
    final list = steps.toList();
    final indexed = <({int index, DashboardSetupStep step})>[
      for (var index = 0; index < list.length; index++)
        (index: index, step: list[index]),
    ]..sort((a, b) {
        final byPriority = a.step.priority.compareTo(b.step.priority);
        return byPriority != 0 ? byPriority : a.index.compareTo(b.index);
      });
    return [for (final entry in indexed) entry.step];
  }
}

/// The month-tool visibility rules used by the overflow menu.
class DashboardMonthTools {
  const DashboardMonthTools({
    required this.canConvert,
    required this.canMove,
    required this.canViewHistory,
    required this.isCurrentMonth,
  });

  final bool canConvert;
  final bool canMove;
  final bool canViewHistory;
  final bool isCurrentMonth;

  bool get showToday => !isCurrentMonth;

  factory DashboardMonthTools.from({
    required bool hasBudget,
    required bool canEdit,
    required String yearMonth,
    DateTime? now,
  }) {
    final editable = hasBudget && canEdit;
    return DashboardMonthTools(
      canConvert: editable,
      canMove: editable,
      canViewHistory: true,
      isCurrentMonth: yearMonth == currentYearMonth(now),
    );
  }
}
