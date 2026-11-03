import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/direct_expense_profile.dart';
import 'package:budget_buddy/features/expenses/presentation/profile_picker_sheet.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:budget_buddy/shared/presentation/profile_identity_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BudgetProfile budget(String name, String guid) => BudgetProfile()
    ..syncGuid = guid
    ..yearMonth = '2026-10'
    ..name = name
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);

  DirectExpenseProfile direct(String name, String guid) =>
      DirectExpenseProfile()
        ..syncGuid = guid
        ..yearMonth = '2026-10'
        ..name = name
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);

  Widget host({
    required List<BudgetProfile> budgetProfiles,
    required List<DirectExpenseProfile> directProfiles,
    ThemeData? theme,
  }) =>
      ProviderScope(
        overrides: [
          budgetProfilesProvider
              .overrideWith((ref) => Stream.value(budgetProfiles)),
          directExpenseProfilesProvider
              .overrideWith((ref) => Stream.value(directProfiles)),
        ],
        child: MaterialApp(
          theme: theme,
          home: const Scaffold(body: ProfilePickerSheet()),
        ),
      );

  testWidgets('names the unbudgeted destination and colours each profile',
      (tester) async {
    await tester.pumpWidget(host(
      budgetProfiles: [budget('Food', 'b1')],
      directProfiles: [direct('Travel', 'd1')],
    ));
    await tester.pumpAndSettle();

    final scheme =
        Theme.of(tester.element(find.byType(ProfilePickerSheet))).colorScheme;
    expect(find.text('No budget — free-to-use'), findsOneWidget);
    expect(
        find.text("Paid from this month's free-to-use money"), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);

    final mainAvatar = tester.widget<CircleAvatar>(find.descendant(
        of: find.byKey(const Key('mainProfileOption')),
        matching: find.byType(CircleAvatar)));
    expect(mainAvatar.backgroundColor, scheme.errorContainer);

    final foodAvatar = tester.widget<CircleAvatar>(find.descendant(
        of: find.widgetWithText(ListTile, 'Food'),
        matching: find.byType(CircleAvatar)));
    expect(
        foodAvatar.backgroundColor,
        profileIdentityColor('b1', brightness: scheme.brightness)
            .withValues(alpha: .16));
  });

  for (final dark in [false, true]) {
    testWidgets('picker stays reachable at 320 wide and 200% text, dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(640, 1800);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(host(
        budgetProfiles: [budget('Food', 'b1')],
        directProfiles: [direct('Travel', 'd1')],
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('No budget — free-to-use'), findsOneWidget);
    });
  }
}
