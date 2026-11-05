import 'dart:async';

import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/merchant.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/expenses/presentation/widgets/expense_metadata_fields.dart';
import 'package:budget_buddy/features/expenses/providers/expense_search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Merchant merchant(String name, DateTime created) => Merchant()
    ..syncGuid = name
    ..canonicalName = name
    ..createdAt = created
    ..updatedAt = created;

  Widget host(ExpenseMetadataDraft draft, List<Merchant> merchants) =>
      ProviderScope(
        overrides: [
          budgetContextProvider.overrideWithValue(
              ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
          expenseSearchMerchantsProvider
              .overrideWith((ref) => Stream.value(merchants)),
          savedMerchantsProvider.overrideWith((ref) => AsyncData(merchants)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ExpenseMetadataFields(
                draft: draft,
                status: ExpenseStatus.planned,
                requiredMetadata: true,
              ),
            ),
          ),
        ),
      );

  Finder merchantField() => find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.labelText == 'Merchant *');

  String merchantText(WidgetTester tester) =>
      tester.widget<TextField>(merchantField()).controller!.text;

  testWidgets('saved merchants are offered as chips and fill the field',
      (tester) async {
    final draft = ExpenseMetadataDraft();
    addTearDown(draft.dispose);
    await tester.pumpWidget(host(draft, [
      merchant('Corner Shop', DateTime(2026, 2)),
      merchant('Beta', DateTime(2026, 1)),
    ]));
    await tester.pumpAndSettle();

    expect(find.byType(ActionChip), findsNWidgets(2));
    await tester.tap(find.text('Corner Shop'));
    await tester.pump();

    expect(merchantText(tester), 'Corner Shop');
  });

  testWidgets('the saved-merchants picker fills the field', (tester) async {
    final draft = ExpenseMetadataDraft();
    addTearDown(draft.dispose);
    await tester.pumpWidget(host(draft, [
      merchant('Corner Shop', DateTime(2026, 2)),
      merchant('Beta', DateTime(2026, 1)),
    ]));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Saved merchants'), findsOneWidget);
    await tester.tap(find.byTooltip('Saved merchants'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Beta').last);
    await tester.pumpAndSettle();

    expect(merchantText(tester), 'Beta');
  });

  testWidgets('a merchant arriving after the form opens is offered immediately',
      (tester) async {
    final controller = StreamController<List<Merchant>>();
    addTearDown(controller.close);
    final draft = ExpenseMetadataDraft();
    addTearDown(draft.dispose);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        budgetContextProvider.overrideWithValue(
            ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
        expenseSearchMerchantsProvider.overrideWith((ref) => controller.stream),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ExpenseMetadataFields(
              draft: draft,
              status: ExpenseStatus.planned,
              requiredMetadata: true,
            ),
          ),
        ),
      ),
    ));
    controller.add(const <Merchant>[]);
    await tester.pump();
    expect(find.byType(ActionChip), findsNothing);

    // A save in another flow makes the merchant stream emit; the open form
    // must pick it up without being reopened.
    controller.add([merchant('Corner Shop', DateTime(2026))]);
    await tester.pumpAndSettle();

    expect(find.text('Corner Shop'), findsOneWidget);
    expect(find.byType(ActionChip), findsOneWidget);
  });
}
