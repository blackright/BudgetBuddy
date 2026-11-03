import 'package:budget_buddy/core/models/merchant.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/expenses/presentation/saved_merchants_sheet.dart';
import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Merchant merchant(String name) => Merchant()
    ..syncGuid = name
    ..canonicalName = name
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);

  Widget host({
    required List<Merchant> merchants,
    required void Function(String?) onResult,
  }) =>
      ProviderScope(
        overrides: [
          budgetContextProvider.overrideWithValue(
              ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
          savedMerchantsProvider.overrideWith((ref) => AsyncData(merchants)),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async {
                    final result = await SavedMerchantsSheet.show(context);
                    onResult(result);
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

  testWidgets('shows the context and returns the chosen canonical name',
      (tester) async {
    String? chosen;
    await tester.pumpWidget(host(
      merchants: [merchant('Corner Shop'), merchant('Beta')],
      onResult: (value) => chosen = value,
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Saved merchants'), findsOneWidget);
    expect(find.text('Saved for this profile'), findsOneWidget);
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();

    expect(chosen, 'Beta');
  });

  testWidgets('searches the saved merchants', (tester) async {
    await tester.pumpWidget(host(
      merchants: [merchant('Corner Shop'), merchant('Beta')],
      onResult: (_) {},
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'beta');
    await tester.pumpAndSettle();

    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Corner Shop'), findsNothing);
  });

  testWidgets('explains an empty history', (tester) async {
    await tester.pumpWidget(host(merchants: [], onResult: (_) {}));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No saved merchants yet'), findsOneWidget);
  });

  for (final dark in [false, true]) {
    testWidgets('sheet stays reachable at 320 wide and 200% text, dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(640, 1800);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(ProviderScope(
        overrides: [
          budgetContextProvider.overrideWithValue(
              ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
          savedMerchantsProvider.overrideWith((ref) => AsyncData([
                merchant('Corner Shop'),
                merchant('Beta'),
              ])),
        ],
        child: MaterialApp(
          theme:
              ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => SavedMerchantsSheet.show(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Saved merchants'), findsOneWidget);
    });
  }
}
