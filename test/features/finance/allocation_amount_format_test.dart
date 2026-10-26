import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/engine/providers/true_available_provider.dart';
import 'package:budget_buddy/features/finance/presentation/allocations_screen.dart';
import 'package:budget_buddy/features/finance/providers/month_end_providers.dart';
import 'package:budget_buddy/features/finance/providers/profile_providers.dart';
import 'package:budget_buddy/features/finance/providers/reserve_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'allocation dialog has clean title and grouped loaded and typed amounts',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final profile = BudgetProfile()
      ..id = 1
      ..syncGuid = 'food'
      ..name = 'Food'
      ..yearMonth = '2026-09'
      ..allocation = 1000000
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await tester.pumpWidget(ProviderScope(overrides: [
      budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: '2026-09')),
      activeProfileProvider.overrideWith((ref) => Stream.value(null)),
      selectedYearMonthProvider.overrideWith((ref) => '2026-09'),
      dashboardCurrencyProvider.overrideWithValue(CurrencyCode.huf),
      rateRegistryProvider.overrideWithValue(RateTableRegistry()),
      budgetProfilesProvider.overrideWith((ref) => Stream.value([profile])),
      directExpenseProfilesProvider.overrideWith((ref) => Stream.value([])),
      availableReserveProvider.overrideWithValue(0),
      contextExpensesProvider.overrideWithValue([]),
      monthlyReimbursementsProvider.overrideWith((ref) => Stream.value([])),
      monthEndPolicyHistoryProvider.overrideWithValue({}),
    ], child: const MaterialApp(home: AllocationsScreen())));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Edit'));
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit allocation: Food'), findsOneWidget);
    final field = find.byType(TextField);
    expect(tester.widget<TextField>(field).controller!.text, '1,000,000');
    await tester.enterText(field, '2345678');
    expect(tester.widget<TextField>(field).controller!.text, '2,345,678');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(profile.allocation, 1000000);
    expect(tester.takeException(), isNull);
  });
}
