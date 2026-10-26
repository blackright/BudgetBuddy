import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/presentation/bulk_entry_screen.dart';
import 'package:budget_buddy/features/expenses/presentation/expenses_screen.dart';
import 'package:budget_buddy/features/expenses/presentation/widgets/purchase_editor.dart';
import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import '../../medical/repositories/medical_test_harness.dart';
import '../bulk_entry_service_test.dart' show addBulkTestProof;
import 'package:budget_buddy/features/expenses/presentation/widgets/daily_expense_card.dart';

void main() {
  late MedicalTestHarness h;
  bool databaseClosed = false;
  setUp(() async {
    h = await MedicalTestHarness.create();
    IsarHelper.instance = h.isar;
    await h.seedBudget(yearMonth: '2026-10');
    await h.isar.writeTxn(() async {
      final month = (await h.isar.monthlyBudgets.get(h.budgetId))!
        ..profileId = h.profileId;
      await h.isar.monthlyBudgets.put(month);
      await h.isar.categorys.put(Category(
          categoryId: 'food', name: 'Food', emoji: 'F', colorValue: 0));
      await h.isar.expenses.put(Expense(
          profileId: h.profileId,
          yearMonth: '2026-10',
          title: 'Existing expense',
          amount: 300,
          currency: 'HUF',
          categoryId: 'food',
          date: DateTime(2026, 10, 24, 18),
          budgetId: h.budgetId));
    });
  });
  tearDown(() async {
    if (!databaseClosed) await h.close();
  });
  testWidgets(
      'real bulk save opens its saved batch in the actual Expenses screen',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer(overrides: [
      budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: h.profileId, yearMonth: '2026-10')),
      actingProfileIdProvider.overrideWithValue(h.profileId),
      selectedYearMonthProvider.overrideWith((ref) => '2026-10'),
      activeContextCanEditProvider.overrideWithValue(true),
      mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
      rateRegistryProvider.overrideWithValue(RateTableRegistry()),
    ]);
    bool disposed = false;
    await tester.runAsync(() async {
      await container.read(activeProfileProvider.future);
      await container.read(activeBudgetProvider.future);
      await container.read(categoriesProvider.future);
    });
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const BulkEntryScreen()),
      GoRoute(path: '/expenses', builder: (_, __) => const ExpensesScreen()),
    ]);
    addTearDown(() async {
      if (!disposed) {
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
        container.dispose();
        for (var index = 0; index < 10; index++) {
          await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 20)));
          await tester.pump();
        }
      }
    });
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
            routerConfig: router,
            theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.deepPurple,
                    brightness: Brightness.dark)))));
    await tester.pumpAndSettle();
    // Fixture represents a filled form; field entry is covered separately.
    final editor = tester.widget<PurchaseEditor>(find.byType(PurchaseEditor));
    editor.purchase.header
      ..title = 'Bulk Farine'
      ..merchant = 'Spar'
      ..amount = '2,000'
      ..currency = 'HUF'
      ..category = 'food'
      ..payment = 'card'
      ..profileChosen = true
      ..date = DateTime(2026, 10, 24)
      ..status = ExpenseStatus.paid;
    editor.purchase.receiptTotal = '2,000';
    editor.purchase.items.first
      ..title = 'Bulk Farine'
      ..amount = '2,000'
      ..category = 'food'
      ..profileChosen = true;
    addBulkTestProof(editor.purchase.header);
    editor.onChanged();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Add another purchase'), 300,
        scrollable: find.byType(Scrollable).first);
    await Scrollable.ensureVisible(
        tester.element(find.text('Add another purchase')),
        alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add another purchase'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review and save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save complete purchases'));
    // Native work can finish after a transient quiet frame.
    for (var i = 0;
        i < 100 && find.text('View saved expenses').evaluate().isEmpty;
        i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    expect(find.text('View saved expenses'), findsOneWidget);
    expect(await tester.runAsync(() => h.isar.expenses.count()), 2);
    await tester.ensureVisible(find.text('View saved expenses'));
    await tester.tap(find.text('View saved expenses'));
    await tester.pumpAndSettle();
    expect(find.text('Discard unfinished purchases?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('View saved expenses'), findsOneWidget);
    await tester.tap(find.text('View saved expenses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pump();
    for (var i = 0;
        i < 100 &&
            (find.byType(ExpensesScreen).evaluate().isEmpty ||
                container
                        .read(expenseSearchResultsProvider)
                        .asData
                        ?.value
                        .length !=
                    1 ||
                find.byType(DailyExpenseCardTile).evaluate().isEmpty);
        i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    expect(find.byType(ExpensesScreen), findsOneWidget);
    await tester.tap(find.byType(DailyExpenseCardTile).first);
    await tester.pumpAndSettle();
    expect(find.text('Bulk Farine'), findsOneWidget);
    expect(find.text('Existing expense'), findsNothing);
    expect(container.read(expenseSearchStateProvider).savedBatch,
        {editor.purchase.items.first.guid});
    await tester.tap(find.byTooltip('Close day'));
    await tester.pumpAndSettle();
    expect(find.text('Saved batch'), findsOneWidget);
    expect(find.textContaining('1 results'), findsOneWidget);
    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DailyExpenseCardTile).first);
    await tester.pumpAndSettle();
    expect(find.text('Existing expense'), findsOneWidget);
    await tester.tap(find.byTooltip('Close day'));
    await tester.pumpAndSettle();
    expect(find.textContaining('2 results'), findsOneWidget);
    expect(await tester.runAsync(() => h.isar.expenses.count()), 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    container.dispose();
    disposed = true;
    // Drain native watcher reads and their fake-clock continuations before
    // closing Isar; close waits synchronously for outstanding native reads.
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.runAsync(h.close);
    databaseClosed = true;
  });
}
