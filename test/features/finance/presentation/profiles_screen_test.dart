import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/direct_expense_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/finance/presentation/profiles_screen.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:budget_buddy/features/finance/providers/reserve_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BudgetProfile budget({
    int id = 1,
    String name = 'Food',
    int allocation = 50000,
  }) {
    return BudgetProfile()
      ..id = id
      ..name = name
      ..yearMonth = '2026-01'
      ..allocation = allocation
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
  }

  DirectExpenseProfile direct({int id = 2, String name = 'Travel'}) {
    return DirectExpenseProfile()
      ..id = id
      ..name = name
      ..yearMonth = '2026-01'
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
  }

  Widget wrap({Brightness brightness = Brightness.light}) {
    return ProviderScope(
      overrides: [
        budgetProfilesProvider.overrideWith(
          (ref) => Stream.value([budget()]),
        ),
        directExpenseProfilesProvider.overrideWith(
          (ref) => Stream.value([direct()]),
        ),
        contextExpensesProvider.overrideWithValue(const []),
        availableReserveProvider.overrideWithValue(10000),
        monthlyReimbursementsProvider.overrideWith(
          (ref) => Stream.value(const []),
        ),
        profileSpendingSyncProvider.overrideWith((ref) async {}),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: '2026-01'),
        ),
        activeProfileProvider.overrideWith((ref) => Stream.value(null)),
        activeSpaceProvider.overrideWith((ref) => Stream.value(null)),
      ],
      child: MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: const ProfilesScreen(),
      ),
    );
  }

  Future<void> pumpProfiles(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    tester.view.physicalSize = const Size(360, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrap(brightness: brightness));
    await tester.pumpAndSettle();
  }

  RoundedRectangleBorder cardShape(WidgetTester tester, int id) {
    final material = tester.widget<Material>(
      find
          .descendant(
            of: find.byKey(Key('profileCard-$id')),
            matching: find.byType(Material),
          )
          .first,
    );
    return material.shape! as RoundedRectangleBorder;
  }

  testWidgets('renders every profile as its own bordered card', (tester) async {
    await pumpProfiles(tester);

    expect(find.byKey(const Key('profileCard-1')), findsOneWidget);
    expect(find.byKey(const Key('profileCard-2')), findsOneWidget);
    expect(find.text('Budget profiles'), findsOneWidget);
    expect(find.text('Direct profiles'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Spent'), findsOneWidget);
    expect(find.text('Left'), findsWidgets);
    expect(find.text('Spent from reserve'), findsOneWidget);
    expect(find.widgetWithText(FloatingActionButton, 'Add profile'),
        findsOneWidget);

    final context = tester.element(find.byKey(const Key('profileCard-1')));
    final outline = Theme.of(context).colorScheme.outlineVariant;
    for (final id in [1, 2]) {
      final shape = cardShape(tester, id);
      expect(shape.side.color, outline);
      expect(shape.side.width, greaterThan(0));
    }
  });

  testWidgets('card outlines stay visible in dark mode', (tester) async {
    await pumpProfiles(tester, brightness: Brightness.dark);

    final context = tester.element(find.byKey(const Key('profileCard-1')));
    final outline = Theme.of(context).colorScheme.outlineVariant;
    expect(outline.a, greaterThan(0));
    for (final id in [1, 2]) {
      final shape = cardShape(tester, id);
      expect(shape.side.color, outline);
      expect(shape.side.color.a, greaterThan(0));
    }
  });
}
