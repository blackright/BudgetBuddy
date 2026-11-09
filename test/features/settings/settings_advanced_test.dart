import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/finance/presentation/net_salary_section.dart';
import 'package:budget_buddy/features/finance/providers/finance_providers.dart';
import 'package:budget_buddy/features/finance/repositories/month_finance_repository.dart';
import 'package:budget_buddy/features/settings/presentation/settings_advanced_screen.dart';
import 'package:budget_buddy/features/settings/presentation/settings_copy.dart';
import 'package:budget_buddy/features/settings/presentation/settings_help_screen.dart';
import 'package:budget_buddy/features/settings/presentation/settings_legacy_salary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../medical/repositories/medical_test_harness.dart';
import 'support/settings_test_harness.dart';

/// US5 (FR-037, FR-038, FR-021): Help replays the existing introduction, and
/// Advanced keeps History, Technical details and the Legacy salary form.
void main() {
  Future<void> pumpRouted(
    WidgetTester tester,
    GoRouter router, {
    List<Override> extraOverrides = const [],
    Size size = const Size(360, 900),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final harness = SettingsTestHarness(extraOverrides: extraOverrides);
    await tester.pumpWidget(
      ProviderScope(
        overrides: harness.overrides,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  GoRouter buildRouter(Widget home) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => home),
        GoRoute(
          path: '/introduction',
          builder: (_, __) => const Scaffold(
            body: Text('Introduction destination'),
          ),
        ),
        GoRoute(
          path: '/audit_history',
          builder: (_, __) => const Scaffold(
            body: Text('Audit history destination'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    return router;
  }

  testWidgets('Help replays the introduction from the existing route',
      (tester) async {
    await pumpRouted(
      tester,
      buildRouter(const SettingsHelpScreen()),
    );

    expect(find.byKey(const Key('settingsHelpScreen')), findsOneWidget);
    expect(find.text(SettingsCopy.help), findsOneWidget);
    expect(find.byKey(const Key('replayIntroduction')), findsOneWidget);
    expect(find.text(SettingsCopy.replayIntroduction), findsOneWidget);

    await tester.tap(find.byKey(const Key('replayIntroduction')));
    await tester.pumpAndSettle();

    expect(find.text('Introduction destination'), findsOneWidget);
  });

  testWidgets('Advanced shows History, Technical details and Legacy salary',
      (tester) async {
    await pumpRouted(
      tester,
      buildRouter(const SettingsAdvancedScreen()),
    );

    expect(find.byKey(const Key('settingsAdvancedScreen')), findsOneWidget);
    expect(find.text(SettingsCopy.advanced), findsOneWidget);
    expect(find.byKey(const Key('settingsHistoryRow')), findsOneWidget);
    expect(find.byKey(const Key('audit-diagnostics-toggle')), findsOneWidget);
    expect(find.byKey(const Key('settingsLegacySalaryRow')), findsOneWidget);

    expect(find.text(SettingsCopy.history), findsOneWidget);
    expect(find.text(SettingsCopy.technicalDetails), findsOneWidget);
    expect(find.text(SettingsCopy.legacySalary), findsOneWidget);
    expect(find.text('Audit technical details'), findsNothing);

    final historyY =
        tester.getTopLeft(find.byKey(const Key('settingsHistoryRow'))).dy;
    final detailsY =
        tester.getTopLeft(find.byKey(const Key('audit-diagnostics-toggle'))).dy;
    final salaryY =
        tester.getTopLeft(find.byKey(const Key('settingsLegacySalaryRow'))).dy;
    expect(historyY, lessThan(detailsY));
    expect(detailsY, lessThan(salaryY));

    final toggle = tester.widget<SwitchListTile>(
      find.byKey(const Key('audit-diagnostics-toggle')),
    );
    expect(toggle.value, isFalse);
    expect(toggle.onChanged, isNotNull);

    await tester.tap(find.byKey(const Key('settingsHistoryRow')));
    await tester.pumpAndSettle();
    expect(find.text('Audit history destination'), findsOneWidget);
  });

  testWidgets('Legacy salary hosts the unchanged NetSalarySection',
      (tester) async {
    late MedicalTestHarness isar;
    await tester.runAsync(() async {
      isar = await MedicalTestHarness.create();
    });

    await pumpRouted(
      tester,
      buildRouter(const SettingsAdvancedScreen()),
      extraOverrides: [
        activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
        rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        monthFinanceRepositoryProvider
            .overrideWithValue(MonthFinanceRepository(isar.isar)),
        resolvedIncomeProvider
            .overrideWith((ref) => const ResolvedIncome.empty()),
      ],
    );

    await tester.tap(find.byKey(const Key('settingsLegacySalaryRow')));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsLegacySalaryScreen), findsOneWidget);
    expect(find.byKey(const Key('settingsLegacySalaryScreen')), findsOneWidget);
    expect(find.text(SettingsCopy.legacySalary), findsOneWidget);
    expect(find.byType(NetSalarySection), findsOneWidget);

    // The reviewed-transition copy, heading and write fields are preserved.
    expect(find.byKey(const Key('incomeProfileName')), findsOneWidget);
    expect(find.byKey(const Key('defaultSalaryField')), findsOneWidget);
    expect(find.byKey(const Key('monthOverrideField')), findsOneWidget);
    expect(find.text('Manage income in Income Sources'), findsOneWidget);
    expect(find.textContaining('reviewed transition'), findsOneWidget);

    await tester.runAsync(isar.close);
  });

  testWidgets('Help and Advanced stay usable at 320 dp and 200% text',
      (tester) async {
    await pumpRouted(
      tester,
      buildRouter(const SettingsHelpScreen()),
      size: const Size(320, 1600),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('replayIntroduction')), findsOneWidget);

    await pumpRouted(
      tester,
      buildRouter(const SettingsAdvancedScreen()),
      size: const Size(320, 1600),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('settingsHistoryRow')), findsOneWidget);
    expect(find.byKey(const Key('settingsLegacySalaryRow')), findsOneWidget);
  });
}
