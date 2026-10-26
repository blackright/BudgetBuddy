import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/merchant.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/core/services/filter_service.dart';
import 'package:budget_buddy/features/expenses/presentation/expenses_screen.dart';
import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';
import 'package:budget_buddy/features/expenses/providers/daily_cards_provider.dart';
import 'package:budget_buddy/features/expenses/presentation/widgets/daily_expense_card.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final scope = StateProvider(
      (ref) => ContextRef.personal(profileId: 1, yearMonth: '2026-10'));
  final source = StateProvider<List<Expense>>((ref) => List.generate(
      21,
      (i) => Expense(
          id: i + 1,
          profileId: 1,
          yearMonth: '2026-10',
          title: 'Coffee $i',
          amount: 1000,
          currency: 'huf',
          categoryId: 'food',
          date: DateTime(2026, 10, i + 1),
          budgetId: 1)
        ..notes = 'Office'));
  Future<ProviderContainer> open(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer(overrides: [
      budgetContextProvider.overrideWith((ref) => ref.watch(scope)),
      selectedYearMonthProvider.overrideWith((ref) => '2026-10'),
      activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
      activeProfileProvider.overrideWith((ref) => Stream.value(null)),
      activeContextCanEditProvider.overrideWithValue(false),
      categoriesProvider.overrideWith((ref) async => <Category>[]),
      expenseSearchRowsProvider
          .overrideWith((ref) => Stream.value(ref.watch(source))),
      expenseSearchMerchantsProvider
          .overrideWith((ref) => Stream.value(<Merchant>[])),
      expenseSearchProfileNamesProvider.overrideWith((ref) async =>
          {'main': 'Main', 'unresolved': 'Needs profile review'}),
      rateRegistryProvider.overrideWithValue(RateTableRegistry()),
      mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
      dailyCardReturnsProvider.overrideWith((ref) => Stream.value([])),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ExpensesScreen())));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('live typing, twenty-row pages, filtering and context reset',
      (tester) async {
    final container = await open(tester);
    expect(find.byType(DailyExpenseCardTile), findsWidgets);
    expect(find.textContaining('21 results'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<DailyExpenseCardTile>(
                find.byType(DailyExpenseCardTile).first)
            .day
            .date
            .day,
        1);
    await tester.enterText(find.byType(TextField).first, 'OFF cof 20');
    await tester.pump(const Duration(milliseconds: 149));
    expect(container.read(expenseSearchStateProvider).query, '');
    await tester.pump(const Duration(milliseconds: 2));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<DailyExpenseCardTile>(
                find.byType(DailyExpenseCardTile).first)
            .day
            .date
            .day,
        21);
    expect(find.textContaining('1 results'), findsOneWidget);
    container.read(scope.notifier).state =
        ContextRef.personal(profileId: 2, yearMonth: '2026-10');
    await tester.pumpAndSettle();
    expect(container.read(expenseSearchStateProvider).query, '');
    expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '');
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'saved batch is visible, removable and cleared on owner or month change',
      (tester) async {
    final container = await open(tester);
    final batch = container.read(source).take(2).map((e) => e.syncGuid).toSet();
    final controller = container.read(expenseSearchStateProvider.notifier);
    controller.showSavedBatch(batch);
    await tester.pumpAndSettle();
    expect(find.text('Saved batch'), findsOneWidget);
    expect(find.textContaining('2 results'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
    controller.apply(const ExpenseFilters(status: ExpenseStatus.paid));
    await tester.pumpAndSettle();
    expect(container.read(expenseSearchStateProvider).savedBatch, batch);
    final chip = find.widgetWithText(InputChip, 'Saved batch');
    tester.widget<InputChip>(chip).onDeleted!();
    await tester.pumpAndSettle();
    expect(find.textContaining('21 results'), findsOneWidget);
    controller.showSavedBatch(batch);
    await tester.pumpAndSettle();
    container.read(scope.notifier).state =
        ContextRef.personal(profileId: 1, yearMonth: '2026-11');
    await tester.pumpAndSettle();
    expect(container.read(expenseSearchStateProvider).savedBatch, isNull);
    controller.showSavedBatch(batch);
    container.read(scope.notifier).state =
        ContextRef.personal(profileId: 2, yearMonth: '2026-11');
    await tester.pumpAndSettle();
    expect(container.read(expenseSearchStateProvider).savedBatch, isNull);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'Filters cancel is read-only; apply and chips reset page; live removal clamps',
      (tester) async {
    final container = await open(tester);
    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(container.read(expenseSearchStateProvider).filters.scope,
        ExpenseDateScope.month);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    container.read(source.notifier).state =
        container.read(source).take(2).toList();
    await tester.pumpAndSettle();
    expect(find.textContaining('Page 1 of 1'), findsOneWidget);
    expect(container.read(expenseSearchStateProvider).page, 0);
    container
        .read(expenseSearchStateProvider.notifier)
        .apply(const ExpenseFilters(currency: 'eur'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No expenses match'), findsOneWidget);
    expect(find.text('EUR'), findsOneWidget);
    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2 results'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'bottom pagination only above twenty matches and cards are separated',
      (tester) async {
    final container = await open(tester);
    final list = find.byWidgetPredicate(
        (widget) => widget is ListView && widget.controller != null);
    final listBottom = tester.getRect(list).bottom;
    expect(tester.getRect(find.text('Next')).top,
        greaterThanOrEqualTo(listBottom));
    final cards = find.byType(DailyExpenseCardTile);
    expect(cards, findsWidgets);
    // Card's outer box includes its margin; measure the painted surfaces.
    final firstSurface =
        find.descendant(of: cards.first, matching: find.byType(Material)).first;
    final nextSurface =
        find.descendant(of: cards.at(1), matching: find.byType(Material)).first;
    expect(tester.getRect(nextSurface).top,
        greaterThan(tester.getRect(firstSurface).bottom));
    await tester.scrollUntilVisible(
        find.byWidgetPredicate((widget) =>
            widget is DailyExpenseCardTile && widget.day.date.day == 2),
        300,
        scrollable:
            find.descendant(of: list, matching: find.byType(Scrollable)));
    await tester.pumpAndSettle();
    expect(
        find.byWidgetPredicate((widget) =>
            widget is DailyExpenseCardTile && widget.day.date.day == 1),
        findsNothing);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(
        find.byWidgetPredicate((widget) =>
            widget is DailyExpenseCardTile && widget.day.date.day == 1),
        findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);
    container.read(source.notifier).state =
        List.of(container.read(source).take(20));
    await tester.pumpAndSettle();
    expect(find.text('Next'), findsNothing);
    expect(find.text('Previous'), findsNothing);
    expect(find.textContaining('20 results'), findsOneWidget);
    container.read(source.notifier).state = [];
    await tester.pumpAndSettle();
    expect(find.text('Next'), findsNothing);
    expect(find.text('Previous'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
