import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/direct_expense_profile.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/expenses/presentation/bulk_entry_screen.dart';
import 'package:budget_buddy/features/expenses/presentation/widgets/purchase_editor.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';
import 'package:budget_buddy/features/expenses/providers/purchase_provider.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// US2: one bulk item card is open at a time, and the active item stays in view.
void main() {
  Future<ProviderContainer> open(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer(overrides: [
      expenseSearchMerchantsProvider.overrideWith((ref) => Stream.value([])),
      budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
      actingProfileIdProvider.overrideWithValue(1),
      activeProfileProvider.overrideWith((ref) => Stream.value(null)),
      activeContextCanEditProvider.overrideWith((ref) => true),
      activeBudgetProvider.overrideWith((ref) => Stream.value(MonthlyBudget()
        ..id = 1
        ..profileId = 1
        ..yearMonth = '2026-10'
        ..baseAvailableAmount = 0
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026))),
      categoriesProvider.overrideWith((ref) async => [
            Category(
                categoryId: 'food', name: 'Food', emoji: 'F', colorValue: 0)
          ]),
      budgetProfilesProvider
          .overrideWith((ref) => Stream.value(<BudgetProfile>[])),
      directExpenseProfilesProvider
          .overrideWith((ref) => Stream.value(<DirectExpenseProfile>[])),
      purchaseSubmitProvider
          .overrideWithValue((purchase, destination, actor) async {}),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
            theme: ThemeData(useMaterial3: true),
            home: Builder(
                builder: (context) => Scaffold(
                    body: TextButton(
                        child: const Text('Open bulk'),
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                                builder: (_) => const BulkEntryScreen()))))))));
    await tester.tap(find.text('Open bulk'));
    await tester.pumpAndSettle();
    return container;
  }

  PurchaseEditor editor(WidgetTester tester) =>
      tester.widget<PurchaseEditor>(find.byType(PurchaseEditor));

  ExpansionTile tile(WidgetTester tester, String guid) =>
      tester.widget<ExpansionTile>(find.byKey(ValueKey(guid)));

  bool expanded(WidgetTester tester, String guid) =>
      tile(tester, guid).controller!.isExpanded;

  Future<void> tap(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(finder, 300,
          scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<List<String>> addTwoItems(WidgetTester tester) async {
    await open(tester);
    await tap(tester, find.text('Add item to this purchase'));
    return editor(tester).purchase.items.map((item) => item.guid).toList();
  }

  testWidgets('the first item is expanded when the purchase opens',
      (tester) async {
    await open(tester);
    final items = editor(tester).purchase.items;
    expect(items, hasLength(1));
    expect(expanded(tester, items.single.guid), isTrue);
  });

  testWidgets('adding an item collapses the old one and reveals the new one',
      (tester) async {
    final guids = await addTwoItems(tester);

    expect(editor(tester).purchase.items, hasLength(2));
    expect(expanded(tester, guids.first), isFalse);
    expect(expanded(tester, guids.last), isTrue);

    final name = find.byKey(Key('bulkItemName-${guids.last}'));
    expect(name, findsOneWidget);
    final rect = tester.getRect(name);
    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.top, lessThan(screenHeight));
    final nameField = tester.widget<TextField>(
        find.descendant(of: name, matching: find.byType(TextField)));
    expect(nameField.focusNode?.hasFocus, isTrue);
  });

  testWidgets('tapping another item swaps which item is expanded',
      (tester) async {
    final guids = await addTwoItems(tester);

    await tap(tester, find.byKey(Key('bulkItemTitle-${guids.first}')));

    expect(expanded(tester, guids.first), isTrue);
    expect(expanded(tester, guids.last), isFalse);
  });

  testWidgets('tapping the expanded item collapses it', (tester) async {
    final guids = await addTwoItems(tester);
    await tap(tester, find.byKey(Key('bulkItemTitle-${guids.first}')));

    await tap(tester, find.byKey(Key('bulkItemTitle-${guids.first}')));

    expect(expanded(tester, guids.first), isFalse);
    expect(expanded(tester, guids.last), isFalse);
  });

  testWidgets('removing the expanded item leaves no item expanded',
      (tester) async {
    final guids = await addTwoItems(tester);
    await tap(tester, find.byKey(Key('bulkItemTitle-${guids.first}')));

    await tap(tester, find.text('Remove item'));

    final remaining = editor(tester).purchase.items;
    expect(remaining, hasLength(1));
    expect(remaining.single.guid, guids.last);
    expect(expanded(tester, guids.last), isFalse);

    await tap(tester, find.byKey(Key('bulkItemTitle-${guids.last}')));
    expect(expanded(tester, guids.last), isTrue);
  });

  testWidgets('copying a purchase starts with exactly one item expanded',
      (tester) async {
    final guids = await addTwoItems(tester);
    final original = editor(tester).purchase.guid;

    await tap(tester, find.text('Copy purchase'));

    expect(find.byType(PurchaseEditor), findsOneWidget);
    final copy = editor(tester).purchase;
    expect(copy.guid, isNot(original));
    expect(copy.items, hasLength(2));
    expect(copy.items.first.guid, isNot(guids.first));
    expect(expanded(tester, copy.items.first.guid), isTrue);
    expect(expanded(tester, copy.items.last.guid), isFalse);
  });

  testWidgets('the purchase-level accordion keeps one purchase open',
      (tester) async {
    await open(tester);
    final firstPurchase = editor(tester).purchase.guid;

    await tap(tester, find.text('Add another purchase'));
    final secondPurchase = editor(tester).purchase.guid;

    await tester.scrollUntilVisible(find.text('Purchase 1'), -300,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Purchase 1'));
    await tester.pumpAndSettle();
    expect(find.byType(PurchaseEditor), findsOneWidget);
    expect(editor(tester).purchase.guid, firstPurchase);

    await tester.scrollUntilVisible(find.text('Purchase 2'), 300,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Purchase 2'));
    await tester.pumpAndSettle();
    expect(find.byType(PurchaseEditor), findsOneWidget);
    expect(editor(tester).purchase.guid, secondPurchase);
  });
}
