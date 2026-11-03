import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/presentation/add_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';

/// US6 (T051/T055): a save into a shared space is confirmed first, naming the
/// space. The dialog is dismissed here (barrier tap) so the test never reaches
/// the real database write.
void main() {
  UserProfile profile({bool confirmSharedSave = true}) => UserProfile()
    ..id = 1
    ..name = 'Ava'
    ..primaryCurrency = PrimaryCurrency.huf
    ..monthlyAvailableAmount = 0
    ..confirmSharedSave = confirmSharedSave
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);

  SharedSpace space() => SharedSpace()
    ..id = 7
    ..name = 'Home'
    ..avatar = '🏠'
    ..currency = PrimaryCurrency.huf
    ..createdByProfileId = 1
    ..createdAt = DateTime(2026);

  MonthlyBudget budget() => MonthlyBudget()
    ..id = 1
    ..yearMonth = '2026-10'
    ..baseAvailableAmount = 1000
    ..currency = 'huf'
    ..sharedSpaceId = 7
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);

  Finder amountField() => find.byWidgetPredicate(
        (w) => w is TextField && (w.decoration?.labelText) == 'Amount',
      );

  Future<void> fillForm(WidgetTester tester) async {
    final title = find.byWidgetPredicate((w) =>
        w is TextField && w.decoration?.labelText == 'What did you buy?');
    await tester.enterText(title, 'Groceries');
    await tester.enterText(amountField(), '100');
    await tester.pump();
    await tester.ensureVisible(find.text('Planned'));
    await tester.tap(find.text('Planned'));
    await tester.pumpAndSettle();
    final merchant = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Merchant *');
    await tester.ensureVisible(merchant);
    await tester.enterText(merchant, 'Corner shop');
    final payment = find.byWidgetPredicate((w) =>
        w is DropdownButtonFormField<String> &&
        (w.decoration.labelText?.startsWith('Payment method') ?? false));
    await tester.ensureVisible(payment);
    await tester.tap(payment);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cash').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byIcon(Icons.calendar_month_outlined));
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    final today = DateTime.now();
    await tester.tap(find.text('${today.day}').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  testWidgets('shared save shows the confirmation naming the space',
      (tester) async {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const AddExpenseScreen())
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeProfileProvider.overrideWith((ref) => Stream.value(profile())),
          activeBudgetProvider.overrideWith((ref) => Stream.value(budget())),
          activeSpaceIdProvider.overrideWith((ref) => 7),
          activeSpaceProvider.overrideWith((ref) => Stream.value(space())),
          rateRegistryProvider.overrideWithValue(RateTableRegistry()),
          categoriesProvider.overrideWith((ref) async => [
                Category(
                    categoryId: 'general',
                    name: 'General',
                    emoji: '',
                    colorValue: 0xff000000)
              ]),
          expenseSearchMerchantsProvider
              .overrideWith((ref) => Stream.value([])),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await fillForm(tester);
    await tester.ensureVisible(find.text('Save expense'));
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();

    // Main + shared space is one combined review, not two dialogs.
    expect(find.byKey(const Key('destinationGuardDialog')), findsOneWidget);
    expect(find.textContaining('Add "Groceries" (Ft 100) to "Home"?'),
        findsOneWidget);
    expect(find.text('Choose a profile'), findsOneWidget);
    expect(find.text('Save to free-to-use'), findsOneWidget);

    // Dismiss via the barrier: nothing is saved.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
