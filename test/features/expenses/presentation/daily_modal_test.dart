import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/expenses/providers/daily_cards_provider.dart';
import 'package:budget_buddy/features/expenses/presentation/widgets/daily_expense_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'a day stays together and modal pages twenty expenses, then closes on owner change',
      (tester) async {
    final day = DateTime(2026, 10, 24);
    final rows = List.generate(
        21,
        (i) => Expense(
            id: i + 1,
            profileId: 1,
            yearMonth: '2026-10',
            title: 'Purchase ${i + 1}',
            amount: 1000,
            currency: 'HUF',
            categoryId: 'food',
            date: day,
            budgetId: 1));
    final cards = groupDailyExpenses(rows, []);
    final owner = StateProvider(
        (ref) => ContextRef.personal(profileId: 1, yearMonth: '2026-10'));
    final container = ProviderContainer(overrides: [
      budgetContextProvider.overrideWith((ref) => ref.watch(owner)),
      dailyCardsProvider.overrideWithValue(AsyncValue.data(cards))
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
            home: Scaffold(
                body: DailyExpenseCardTile(
                    day: cards.single,
                    expenseBuilder: (expense) =>
                        ListTile(title: Text(expense.title)))))));
    await tester.tap(find.byType(DailyExpenseCardTile));
    await tester.pumpAndSettle();
    expect(find.text('21 expenses · Page 1 of 2'), findsOneWidget);
    final list = tester.widget<ListView>(find.byType(ListView));
    expect(list.childrenDelegate.estimatedChildCount, 20);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Purchase 1'), findsOneWidget);
    expect(find.text('21 expenses · Page 2 of 2'), findsOneWidget);
    expect(
        tester
            .widget<ListView>(find.byType(ListView))
            .childrenDelegate
            .estimatedChildCount,
        1);
    container.read(owner.notifier).state =
        ContextRef.personal(profileId: 2, yearMonth: '2026-10');
    await tester.pumpAndSettle();
    expect(find.byTooltip('Close day'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
