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
    await tester.enterText(find.byType(TextFormField).first, 'Groceries');
    await tester.enterText(amountField(), '100');
    await tester.pump();
  }

  testWidgets('shared save shows the confirmation naming the space',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeProfileProvider.overrideWith((ref) => Stream.value(profile())),
          activeBudgetProvider.overrideWith((ref) => Stream.value(budget())),
          activeSpaceIdProvider.overrideWith((ref) => 7),
          activeSpaceProvider.overrideWith((ref) => Stream.value(space())),
          rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        ],
        child: const MaterialApp(home: AddExpenseScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await fillForm(tester);
    await tester.tap(find.text('Save Expense'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('confirmSpaceOnSaveMessage')), findsOneWidget);
    expect(find.text('Add "Groceries" (Ft 100) to "Home"?'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Change context'), findsOneWidget);

    // Dismiss via the barrier: the guard returns without saving.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
