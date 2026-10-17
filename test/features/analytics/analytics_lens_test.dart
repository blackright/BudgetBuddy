import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/analytics/providers/chart_data_provider.dart';
import 'package:budget_buddy/features/analytics/providers/chart_lens_provider.dart';
import 'package:budget_buddy/features/analytics/presentation/widgets/lens_switch.dart';
import 'package:budget_buddy/features/engine/providers/month_summary_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/expenses/providers/category_provider.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// US2 lens contract (T017): one Personal/Shared switch re-derives *every*
/// chart, and no figure from the previous lens lingers (SC-004, §3).
void main() {
  Expense expense(int amount, String categoryId) => Expense(
        profileId: 1,
        yearMonth: '2026-01',
        title: categoryId,
        amount: amount,
        currency: 'huf',
        categoryId: categoryId,
        status: ExpenseStatus.paid,
        date: DateTime(2026, 1, 5),
        budgetId: 1,
      );

  final personalExpenses = [expense(1000, 'food')];
  final sharedExpenses = [expense(2500, 'transport')];

  SharedSpace space(int id) => SharedSpace()
    ..id = id
    ..name = 'Home'
    ..currency = PrimaryCurrency.huf
    ..createdByProfileId = 1
    ..createdAt = DateTime(2026);

  /// Overrides every Isar-backed source so the chart providers run without a
  /// database, with the expense stream following whichever context is active.
  List<Override> dataOverrides({List<SharedSpace> spaces = const []}) => [
        activeProfileProvider.overrideWith((ref) => Stream.value(null)),
        monthlyExpensesProvider.overrideWith((ref) {
          final context = ref.watch(budgetContextProvider);
          return Stream.value(
            context.isShared ? sharedExpenses : personalExpenses,
          );
        }),
        monthlyOriginReimbursementsProvider
            .overrideWith((ref) => Stream.value(const [])),
        medicalBillsProvider.overrideWith((ref) => Stream.value(const [])),
        monthFinanceProvider.overrideWith((ref) => Stream.value(null)),
        activeSpaceMembersProvider
            .overrideWith((ref) => Stream.value(const [])),
        categoriesProvider.overrideWith((ref) async => const []),
        mySpacesProvider.overrideWith((ref) => Stream.value(spaces)),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
      ];

  ProviderContainer makeContainer({List<SharedSpace> spaces = const []}) {
    final container = ProviderContainer(
      overrides: dataOverrides(spaces: spaces),
    );
    container.read(activeProfileIdProvider.notifier).state = 1;
    return container;
  }

  group('the lens follows the active context (FR-007, §3)', () {
    test('starts personal and every series reads the personal wallet',
        () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      await container.read(monthlyExpensesProvider.future);

      expect(container.read(chartLensProvider), ChartLens.personal);
      expect(container.read(spendingSeriesProvider).total, 1000);
      expect(container.read(categorySeriesProvider).total, 1000);
      expect(container.read(plannedPaidSeriesProvider).total, 1000);
    });

    test('switching to shared re-derives every series at once', () async {
      final container = makeContainer();
      addTearDown(container.dispose);
      await container.read(monthlyExpensesProvider.future);

      container.read(activeSpaceIdProvider.notifier).state = 7;
      await container.read(monthlyExpensesProvider.future);

      expect(container.read(chartLensProvider), ChartLens.shared);
      // No personal figure (1000) may remain anywhere.
      expect(container.read(spendingSeriesProvider).total, 2500);
      expect(container.read(categorySeriesProvider).total, 2500);
      expect(container.read(plannedPaidSeriesProvider).total, 2500);
      expect(container.read(availableTrendSeriesProvider).total, -2500);
    });
  });

  group('the switch widget drives the active context (§3)', () {
    testWidgets('tapping Shared moves into a space', (tester) async {
      final container = makeContainer(spaces: [space(7)]);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: LensSwitch())),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(chartLensProvider), ChartLens.personal);
      await container.read(mySpacesProvider.future);

      await tester.tap(find.text('Shared'));
      await tester.pumpAndSettle();

      expect(container.read(activeSpaceIdProvider), 7);
      expect(container.read(chartLensProvider), ChartLens.shared);
    });

    testWidgets('Shared with no space prompts instead of crashing',
        (tester) async {
      final container = makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: LensSwitch())),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Shared'));
      await tester.pumpAndSettle();

      expect(container.read(activeSpaceIdProvider), isNull);
      expect(container.read(chartLensProvider), ChartLens.personal);
      expect(
        find.textContaining('Create or join a space'),
        findsOneWidget,
      );
    });
  });
}
