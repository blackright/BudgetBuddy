import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/core/services/income_activation_service.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/finance/presentation/income_sources_screen.dart';
import 'package:budget_buddy/features/finance/providers/income_source_providers.dart';
import 'package:budget_buddy/features/finance/repositories/audit_repository.dart';
import 'package:budget_buddy/features/pending_actions/providers/pending_actions_providers.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/income_activation_fixture.dart';

void main() {
  testWidgets('an existing source with no lifecycle shows setup and choices',
      (tester) async {
    late IncomeActivationFixture fixture;
    late IncomeSource source;
    await tester.runAsync(() async {
      fixture = await IncomeActivationFixture.create(month: '2026-10');
      source = await fixture.addSource(name: 'Freelance');
    });
    addTearDown(() async {
      await tester.runAsync(() => fixture.close());
    });
    final profile = UserProfile()
      ..id = fixture.profileId
      ..name = 'Owner'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime.utc(2026, 10)
      ..updatedAt = DateTime.utc(2026, 10);
    final activation = IncomeActivationService(
      fixture.db,
      profileId: fixture.profileId,
      audit: AuditRepository(fixture.db, actorId: fixture.profileId),
      clock: () => DateTime.utc(2026, 10, 3),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        incomeSourcesProvider.overrideWith((ref) => Stream.value([source])),
        salaryCyclesProvider.overrideWith((ref) async => const <SalaryCycle>[]),
        actualIncomeLedgerProvider.overrideWith((ref) => Stream.value(
            const IncomeLedgerSnapshot(groups: [], corrections: []))),
        pendingActionsProvider.overrideWith((ref) => Stream.value([])),
        budgetContextProvider.overrideWithValue(ContextRef.personal(
            profileId: fixture.profileId, yearMonth: '2026-10')),
        activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
        activeSpaceProvider.overrideWith((ref) => Stream.value(null)),
        activeBudgetProvider.overrideWith((ref) => Stream.value(MonthlyBudget()
          ..id = 1
          ..profileId = fixture.profileId
          ..yearMonth = '2026-10'
          ..baseAvailableAmount = 0
          ..currency = 'huf'
          ..createdAt = DateTime.utc(2026, 10)
          ..updatedAt = DateTime.utc(2026, 10))),
        selectedYearMonthProvider.overrideWith((ref) => '2026-10'),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        activeContextCanEditProvider.overrideWithValue(true),
        incomeActivationServiceProvider.overrideWithValue(activation),
      ],
      child: const MaterialApp(home: IncomeSourcesScreen()),
    ));
    await tester.pumpAndSettle();

    expect(
        find.textContaining('Current period not configured'), findsOneWidget);
    final setup = find.byKey(Key('incomeSetup-${source.syncGuid}'));
    expect(setup, findsOneWidget);
    expect(find.text('Set up current period'), findsOneWidget);
    expect(find.text('Confirm received'), findsNothing);
  });

  testWidgets('an old unconfirmed period is shown as not configured',
      (tester) async {
    late IncomeActivationFixture fixture;
    late IncomeSource source;
    late SalaryCycle cycle;
    await tester.runAsync(() async {
      fixture = await IncomeActivationFixture.create(month: '2026-10');
      source = await fixture.addSource(name: 'Legacy');
      cycle = await fixture.addCycle(source, state: 'unconfirmed');
    });
    addTearDown(() async {
      await tester.runAsync(() => fixture.close());
    });
    final profile = UserProfile()
      ..id = fixture.profileId
      ..name = 'Owner'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime.utc(2026, 10)
      ..updatedAt = DateTime.utc(2026, 10);
    final activation = IncomeActivationService(
      fixture.db,
      profileId: fixture.profileId,
      audit: AuditRepository(fixture.db, actorId: fixture.profileId),
      clock: () => DateTime.utc(2026, 10, 3),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        incomeSourcesProvider.overrideWith((ref) => Stream.value([source])),
        salaryCyclesProvider.overrideWith((ref) async => [cycle]),
        actualIncomeLedgerProvider.overrideWith((ref) => Stream.value(
            const IncomeLedgerSnapshot(groups: [], corrections: []))),
        pendingActionsProvider.overrideWith((ref) => Stream.value([])),
        budgetContextProvider.overrideWithValue(ContextRef.personal(
            profileId: fixture.profileId, yearMonth: '2026-10')),
        activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
        activeSpaceProvider.overrideWith((ref) => Stream.value(null)),
        activeBudgetProvider.overrideWith((ref) => Stream.value(MonthlyBudget()
          ..id = 1
          ..profileId = fixture.profileId
          ..yearMonth = '2026-10'
          ..baseAvailableAmount = 0
          ..currency = 'huf'
          ..createdAt = DateTime.utc(2026, 10)
          ..updatedAt = DateTime.utc(2026, 10))),
        selectedYearMonthProvider.overrideWith((ref) => '2026-10'),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        activeContextCanEditProvider.overrideWithValue(true),
        incomeActivationServiceProvider.overrideWithValue(activation),
      ],
      child: const MaterialApp(home: IncomeSourcesScreen()),
    ));
    await tester.pumpAndSettle();

    expect(
        find.textContaining('Current period not configured'), findsOneWidget);
    expect(find.byKey(Key('incomeSetup-${source.syncGuid}')), findsOneWidget);
    expect(find.text('Confirm received'), findsNothing);
  });
}
