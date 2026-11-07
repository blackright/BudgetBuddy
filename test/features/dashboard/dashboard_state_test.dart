import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/services/borrowing_service.dart';
import 'package:budget_buddy/features/dashboard/presentation/dashboard_copy.dart';
import 'package:budget_buddy/features/dashboard/presentation/dashboard_view_state.dart';
import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/engine/month_summary.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// T007: the pure mappings behind the new Dashboard.
///
/// No widget tree and no Isar are needed here. The calculation itself is
/// already covered by `month_summary_test.dart`.
void main() {
  MonthSummary summary({
    String yearMonth = '2026-11',
    double income = 1000,
    double paymentsMade = 200,
    double moneyReturned = 50,
    double planned = 0,
    double cancelled = 0,
    double medicalPaid = 0,
    double? openingBalance = 100,
    double allocated = 0,
    double setAside = 0,
    double carryOver = 0,
    double carriedIn = 0,
    double releasedAtMonthEnd = 0,
    double vaultTransfers = 0,
    double expectedIncome = 0,
  }) {
    return MonthSummary(
      yearMonth: yearMonth,
      income: income,
      usesOverriddenIncome: false,
      paymentsMade: paymentsMade,
      moneyReturned: moneyReturned,
      planned: planned,
      cancelled: cancelled,
      medicalPaid: medicalPaid,
      excessReturned: 0,
      openingBalance: openingBalance,
      allocated: allocated,
      setAside: setAside,
      carryOver: carryOver,
      carriedIn: carriedIn,
      releasedAtMonthEnd: releasedAtMonthEnd,
      vaultTransfers: vaultTransfers,
      expectedIncome: expectedIncome,
    );
  }

  DashboardProfileState profile({
    int id = 1,
    String name = 'Food',
    bool isDirect = false,
    int allocation = 1000,
    int spent = 500,
    int reserve = 1000,
    int expenseCount = 0,
  }) {
    return DashboardProfileState(
      id: id,
      name: name,
      isDirect: isDirect,
      allocation: allocation,
      spent: spent,
      expenseCount: expenseCount,
      availableReserve: reserve,
      recentExpenses: const [],
    );
  }

  SavingsVault vault({
    int totalMinor = 5000,
    String currency = 'huf',
    bool paused = false,
  }) {
    return SavingsVault()
      ..profileId = 1
      ..totalMinor = totalMinor
      ..currency = currency
      ..sweepPaused = paused
      ..lastSweepYearMonth = '2026-11'
      ..updatedAt = DateTime(2026);
  }

  DashboardSetupStep step(String route, {String? title}) {
    return DashboardSetupStep.from(
      title: title ?? route,
      detail: 'detail',
      route: route,
    );
  }

  group('DashboardMonthVerdict', () {
    test('maps a ready complete month', () {
      final verdict = DashboardMonthVerdict.fromAsync(
        AsyncData(summary()),
        yearMonth: '2026-11',
        now: DateTime(2026, 11, 15),
      );

      expect(verdict.status, DashboardDataStatus.ready);
      expect(verdict.isReady, isTrue);
      expect(verdict.isCurrentMonth, isTrue);
      expect(verdict.isComplete, isTrue);
      expect(verdict.isIncomplete, isFalse);
      expect(verdict.caption, 'this month');
      expect(verdict.statementLabel, 'Month breakdown');
      expect(verdict.kept, isNotNull);
    });

    test('uses the month name outside the current month', () {
      final verdict = DashboardMonthVerdict.fromAsync(
        AsyncData(summary(yearMonth: '2026-10')),
        yearMonth: '2026-10',
        now: DateTime(2026, 11, 15),
      );

      expect(verdict.isCurrentMonth, isFalse);
      expect(verdict.caption, 'in October 2026');
      expect(verdict.statementLabel, 'October 2026 breakdown');
    });

    test('does not present a figure while loading', () {
      final verdict = DashboardMonthVerdict.fromAsync(
        const AsyncLoading<MonthSummary>(),
        yearMonth: '2026-11',
        now: DateTime(2026, 11, 15),
      );

      expect(verdict.status, DashboardDataStatus.loading);
      expect(verdict.summary, isNull);
      expect(verdict.kept, isNull);
    });

    test('does not present a stale figure on error', () {
      final verdict = DashboardMonthVerdict.fromAsync(
        const AsyncError<MonthSummary>(
          FormatException('Confirmed income needs review.'),
          StackTrace.empty,
        ),
        yearMonth: '2026-11',
        now: DateTime(2026, 11, 15),
      );

      expect(verdict.status, DashboardDataStatus.error);
      expect(verdict.summary, isNull);
      expect(verdict.kept, isNull);
    });

    test('marks a month with no opening balance as incomplete', () {
      final verdict = DashboardMonthVerdict.fromAsync(
        AsyncData(summary(openingBalance: null)),
        yearMonth: '2026-11',
        now: DateTime(2026, 11, 15),
      );

      expect(verdict.isComplete, isFalse);
      expect(verdict.isIncomplete, isTrue);
    });

    test('treats an empty future month as a planning surface', () {
      final verdict = DashboardMonthVerdict.fromAsync(
        AsyncData(summary(
          yearMonth: '2026-12',
          income: 0,
          paymentsMade: 0,
          moneyReturned: 0,
          openingBalance: null,
        )),
        yearMonth: '2026-12',
        now: DateTime(2026, 11, 15),
      );

      expect(verdict.isFutureMonth, isTrue);
      expect(verdict.isFutureEmpty, isTrue);
    });

    test('still invites planning when only a forecast salary exists', () {
      final verdict = DashboardMonthVerdict.fromAsync(
        AsyncData(summary(
          yearMonth: '2026-12',
          income: 0,
          paymentsMade: 0,
          moneyReturned: 0,
          expectedIncome: 500,
          openingBalance: null,
        )),
        yearMonth: '2026-12',
        now: DateTime(2026, 11, 15),
      );

      expect(verdict.isFutureEmpty, isTrue);
    });

    test('does not call a future month empty when it has planned money', () {
      final verdict = DashboardMonthVerdict.fromAsync(
        AsyncData(summary(
          yearMonth: '2026-12',
          income: 0,
          paymentsMade: 0,
          moneyReturned: 0,
          planned: 25,
          openingBalance: null,
        )),
        yearMonth: '2026-12',
        now: DateTime(2026, 11, 15),
      );

      expect(verdict.isFutureEmpty, isFalse);
    });
  });

  group('DashboardBudgetRow', () {
    test('maps a healthy budget profile', () {
      final row = DashboardBudgetRow.fromProfile(
        profile(spent: 500),
        CurrencyCode.huf,
      );

      expect(row.identity, 'budget:1');
      expect(row.status, BudgetStatus.green);
      expect(row.statusLabel, 'On track');
      expect(row.showsProgress, isTrue);
      expect(row.remainingMinor, 500);
      expect(row.usagePercent, 50);
    });

    test('maps close and fully used labels', () {
      final close = DashboardBudgetRow.fromProfile(
        profile(spent: 850),
        CurrencyCode.huf,
      );
      final full = DashboardBudgetRow.fromProfile(
        profile(spent: 1000),
        CurrencyCode.huf,
      );

      expect(close.statusLabel, 'Close');
      expect(full.statusLabel, 'Fully used');
    });

    test('states an over-budget amount in words', () {
      final row = DashboardBudgetRow.fromProfile(
        profile(spent: 1200, reserve: 100),
        CurrencyCode.huf,
      );

      expect(row.status, BudgetStatus.red);
      expect(row.isOverBudget, isTrue);
      expect(row.overspendMinor, 200);
      expect(row.statusLabel, 'Over by Ft 200');
      expect(row.borrowedMinor, 100);
      expect(row.deficitMinor, 100);
    });

    test('maps a direct profile to spent and no budget', () {
      final row = DashboardBudgetRow.fromProfile(
        profile(
          id: 2,
          name: 'Travel',
          isDirect: true,
          allocation: 0,
          spent: 300,
          reserve: 1000,
        ),
        CurrencyCode.huf,
      );

      expect(row.identity, 'direct:2');
      expect(row.isDirect, isTrue);
      expect(row.statusLabel, 'no budget');
      expect(row.showsProgress, isFalse);
      expect(row.spentMinor, 300);
      expect(row.shownAmountMinor, 300);
    });
  });

  group('DashboardSavingsRow', () {
    test('maps loading without a balance', () {
      final row = DashboardSavingsRow.from(
        vault: const AsyncLoading<SavingsVault?>(),
        reviewMessage: null,
      );

      expect(row.status, DashboardDataStatus.loading);
      expect(row.state, isNull);
      expect(row.message, 'Loading');
      expect(row.showRetry, isFalse);
    });

    test('maps failure with a retry', () {
      final row = DashboardSavingsRow.from(
        vault: AsyncError<SavingsVault?>(
          StateError('offline'),
          StackTrace.empty,
        ),
        reviewMessage: null,
      );

      expect(row.status, DashboardDataStatus.error);
      expect(row.message, "Couldn't load");
      expect(row.showRetry, isTrue);
    });

    test('maps a missing vault to start saving', () {
      final row = DashboardSavingsRow.from(
        vault: const AsyncData<SavingsVault?>(null),
        reviewMessage: null,
      );

      expect(row.state, DashboardSavingsState.empty);
      expect(row.message, 'Start saving');
    });

    test('maps review, paused and invalid states before a balance', () {
      final review = DashboardSavingsRow.from(
        vault: AsyncData<SavingsVault?>(vault()),
        reviewMessage: 'Saved history could not be verified',
      );
      final paused = DashboardSavingsRow.from(
        vault: AsyncData<SavingsVault?>(vault(paused: true)),
        reviewMessage: null,
      );
      final invalid = DashboardSavingsRow.from(
        vault: AsyncData<SavingsVault?>(vault(currency: '')),
        reviewMessage: null,
      );

      expect(review.state, DashboardSavingsState.needsReview);
      expect(review.message, 'Needs review');
      expect(paused.state, DashboardSavingsState.paused);
      expect(paused.message, 'Savings paused');
      expect(invalid.state, DashboardSavingsState.needsReview);
      expect(invalid.message, 'Needs review');
    });

    test('maps a valid balance in the vault currency', () {
      final row = DashboardSavingsRow.from(
        vault: AsyncData<SavingsVault?>(vault()),
        reviewMessage: null,
      );

      expect(row.status, DashboardDataStatus.ready);
      expect(row.state, DashboardSavingsState.value);
      expect(row.isValue, isTrue);
      expect(row.balanceMinor, 5000);
      expect(row.currency, CurrencyCode.huf);
      expect(row.message, 'Ft 5,000');
    });
  });

  group('DashboardSetupStep', () {
    test('ranks missing opening balance before income and budgets', () {
      expect(DashboardSetupStep.priorityFor('opening'), 1);
      expect(DashboardSetupStep.priorityFor('/income_sources'), 2);
      expect(DashboardSetupStep.priorityFor('/allocations'), 3);
      expect(DashboardSetupStep.priorityFor('/add_expense'), 4);
      expect(DashboardSetupStep.priorityFor('/medical'), 5);
      expect(DashboardSetupStep.priorityFor('/spaces'), 6);
    });

    test('sorts by priority and preserves provider order for ties', () {
      final ordered = DashboardSetupStep.ordered([
        step('/add_expense'),
        step('/income_sources', title: 'First income'),
        step('opening'),
        step('/income_sources', title: 'Second income'),
      ]);

      expect(
        ordered.map((item) => item.title).toList(),
        ['opening', 'First income', 'Second income', '/add_expense'],
      );
    });
  });

  group('DashboardMonthTools', () {
    test(
        'offers convert and move only when a budget exists and editing is allowed',
        () {
      final editable = DashboardMonthTools.from(
        hasBudget: true,
        canEdit: true,
        yearMonth: '2026-11',
        now: DateTime(2026, 11, 15),
      );
      final readOnly = DashboardMonthTools.from(
        hasBudget: true,
        canEdit: false,
        yearMonth: '2026-11',
        now: DateTime(2026, 11, 15),
      );
      final noBudget = DashboardMonthTools.from(
        hasBudget: false,
        canEdit: true,
        yearMonth: '2026-11',
        now: DateTime(2026, 11, 15),
      );

      expect(editable.canConvert, isTrue);
      expect(editable.canMove, isTrue);
      expect(editable.canViewHistory, isTrue);
      expect(editable.showToday, isFalse);
      expect(readOnly.canConvert, isFalse);
      expect(readOnly.canMove, isFalse);
      expect(readOnly.canViewHistory, isTrue);
      expect(noBudget.canConvert, isFalse);
      expect(noBudget.canMove, isFalse);
    });

    test('offers Today when the selected month is not the current month', () {
      final tools = DashboardMonthTools.from(
        hasBudget: true,
        canEdit: true,
        yearMonth: '2026-10',
        now: DateTime(2026, 11, 15),
      );

      expect(tools.isCurrentMonth, isFalse);
      expect(tools.showToday, isTrue);
    });
  });

  group('DashboardCopy', () {
    test('uses the current-month caption only for the current month', () {
      final now = DateTime(2026, 11, 15);
      expect(DashboardCopy.heroCaption('2026-11', now: now), 'this month');
      expect(DashboardCopy.heroCaption('2026-10', now: now), 'in October 2026');
      expect(
        DashboardCopy.monthStatementLabel('2026-11', now: now),
        'Month breakdown',
      );
      expect(
        DashboardCopy.monthStatementLabel('2026-10', now: now),
        'October 2026 breakdown',
      );
    });

    test('describes paid out and back without repeating the kept figure', () {
      expect(
        DashboardCopy.heroSupportingLine(summary(), CurrencyCode.huf),
        'Ft 200 paid out · Ft 50 back',
      );
      expect(
        DashboardCopy.heroSupportingLine(
          summary(moneyReturned: 0),
          CurrencyCode.huf,
        ),
        'Ft 200 paid out',
      );
      expect(
        DashboardCopy.heroSupportingLine(
          summary(paymentsMade: 0, moneyReturned: 0),
          CurrencyCode.huf,
        ),
        isEmpty,
      );
    });

    test('states an over-budget amount in words', () {
      expect(
        DashboardCopy.budgetStatusLabel(
          BudgetStatus.red,
          currency: CurrencyCode.huf,
          overspendMinor: 200,
        ),
        'Over by Ft 200',
      );
    });
  });
}
