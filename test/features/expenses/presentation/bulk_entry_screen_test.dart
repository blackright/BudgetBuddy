import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/direct_expense_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/expenses/presentation/bulk_entry_screen.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';
import 'package:budget_buddy/features/expenses/providers/purchase_provider.dart';
import 'package:budget_buddy/features/expenses/presentation/widgets/purchase_editor.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';

void main() {
  final owner = StateProvider(
      (ref) => ContextRef.personal(profileId: 1, yearMonth: '2026-10'));
  final editable = StateProvider((ref) => true);
  Future<ProviderContainer> open(WidgetTester tester, PurchaseSubmit submit,
      {Brightness brightness = Brightness.light}) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer(overrides: [
      expenseSearchMerchantsProvider.overrideWith((ref) => Stream.value([])),
      budgetContextProvider.overrideWith((ref) => ref.watch(owner)),
      actingProfileIdProvider.overrideWithValue(1),
      activeProfileProvider.overrideWith((ref) => Stream.value(null)),
      activeContextCanEditProvider.overrideWith((ref) => ref.watch(editable)),
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
      purchaseSubmitProvider.overrideWithValue(submit),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
            theme: ThemeData(useMaterial3: true, brightness: brightness),
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

  Future<void> fill(WidgetTester tester) async {
    final editor = tester.widget<PurchaseEditor>(find.byType(PurchaseEditor));
    editor.purchase.header
      ..merchant = 'Cafe'
      ..currency = 'HUF'
      ..payment = 'cash'
      ..date = DateTime(2026, 10, 26);
    editor.purchase.items.first
      ..title = 'Lunch'
      ..amount = '1,000'
      ..category = 'food'
      ..profileChosen = true;
    editor.onChanged();
    await tester.pumpAndSettle();
  }

  testWidgets('saves complete purchases and keeps an incomplete group editable',
      (tester) async {
    var calls = 0;
    await open(tester, (p, destination, actor) async {
      calls++;
      expect(p.items.single.amount, '1,000');
      p.saved = true;
      for (final item in p.items) {
        item.saved = true;
      }
    });
    await fill(tester);
    await tap(tester, find.text('Add another purchase'));
    await tap(tester, find.text('Review and save'));
    expect(find.text('Save 1 complete purchases?'), findsOneWidget);
    expect(find.textContaining('1 purchases need correction.'), findsOneWidget);
    await tester.tap(find.text('Save complete purchases'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    final editor = tester.widget<PurchaseEditor>(find.byType(PurchaseEditor));
    expect(editor.purchase.error, isNotNull);
    expect(editor.purchase.saved, isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('copy is Planned with new identity and leaving warns',
      (tester) async {
    await open(tester, (p, d, a) async {});
    await fill(tester);
    final original =
        tester.widget<PurchaseEditor>(find.byType(PurchaseEditor)).purchase;
    original.evidence.cashConfirmed = true;
    await tap(tester, find.text('Copy purchase'));
    final copy =
        tester.widget<PurchaseEditor>(find.byType(PurchaseEditor)).purchase;
    expect(copy.guid, isNot(original.guid));
    expect(copy.items.first.amount, isEmpty);
    expect(copy.evidence.cashConfirmed, isFalse);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Discard unfinished purchases?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.byType(BulkEntryScreen), findsOneWidget);
  });
  testWidgets('context switch or lost permission prevents saving',
      (tester) async {
    final container = await open(tester, (p, d, a) async {
      fail('Must not save');
    });
    container.read(editable.notifier).state = false;
    await tester.pumpAndSettle();
    expect(
        find.textContaining('context or permission changed'), findsOneWidget);
    expect(find.text('Review and save'), findsNothing);
    container.read(editable.notifier).state = true;
    container.read(owner.notifier).state =
        ContextRef.personal(profileId: 2, yearMonth: '2026-10');
    await tester.pumpAndSettle();
    expect(
        find.textContaining('context or permission changed'), findsOneWidget);
  });
  testWidgets(
      'write failure keeps the purchase and retry uses the same identity',
      (tester) async {
    var calls = 0;
    String? identity;
    await open(tester, (p, d, a) async {
      identity ??= p.guid;
      expect(p.guid, identity);
      if (++calls == 1) throw StateError('Injected failure');
      p.saved = true;
    });
    await fill(tester);
    await tap(tester, find.text('Review and save'));
    await tester.tap(find.text('Save complete purchases'));
    await tester.pumpAndSettle();
    await tap(tester, find.text('Review and save'));
    await tester.tap(find.text('Save complete purchases'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('View saved expenses'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final brightness in Brightness.values) {
    testWidgets(
        'narrow purchase cards support large text in ${brightness.name}',
        (tester) async {
      await open(tester, (p, d, a) async {}, brightness: brightness);
      await tester.binding.setSurfaceSize(const Size(320, 760));
      tester.platformDispatcher.textScaleFactorTestValue = 1.8;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await fill(tester);
      await tap(tester, find.text('Add item to this purchase'));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<PurchaseEditor>(find.byType(PurchaseEditor))
              .purchase
              .items
              .length,
          2);
      expect(tester.takeException(), isNull);
    });
  }
}
