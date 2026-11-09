import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/transfer.dart';
import 'package:budget_buddy/features/dashboard/providers/dashboard_providers.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/finance/presentation/transfer_screen.dart';
import 'package:budget_buddy/features/finance/providers/transfer_providers.dart';
import 'package:budget_buddy/features/settings/presentation/settings_budgeting_screen.dart';
import 'package:budget_buddy/features/settings/presentation/settings_copy.dart';
import 'package:budget_buddy/features/settings/providers/app_settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/settings_test_harness.dart';

void main() {
  const rowKeys = <String>[
    'settingsIncomeRow',
    'settingsProfilesRow',
    'settingsMonthEndRow',
    'settingsTransfersRow',
    'settingsSavingsRow',
    'settingsReportsRow',
    'settingsBulkAddExpensesRow',
  ];

  const destinations = <String>[
    '/income_sources',
    '/profiles',
    '/month_end',
    '/transfers',
    '/vault',
    '/reports',
    '/bulk_entry',
  ];

  GoRouter buildRouter() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const SettingsBudgetingScreen(),
        ),
        for (final path in destinations)
          GoRoute(
            path: path,
            builder: (_, __) => Scaffold(
              appBar: AppBar(title: Text('$path destination')),
            ),
          ),
      ],
    );
    addTearDown(router.dispose);
    return router;
  }

  Future<void> pumpBudgeting(
    WidgetTester tester, {
    SettingsTestHarness? harness,
  }) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: (harness ?? SettingsTestHarness()).overrides,
        child: MaterialApp.router(routerConfig: buildRouter()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpTransfer(
    WidgetTester tester, {
    required bool toggle,
  }) async {
    final harness = SettingsTestHarness();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...harness.overrides,
          transferToggleProvider.overrideWithValue(toggle),
          transfersProvider.overrideWith(
            (ref) => Stream<List<Transfer>>.value(const <Transfer>[]),
          ),
          dashboardCurrencyProvider.overrideWithValue(CurrencyCode.huf),
          rateRegistryProvider.overrideWithValue(RateTableRegistry()),
        ],
        child: const MaterialApp(home: TransferScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows every Budgeting row with approved summaries',
      (tester) async {
    await pumpBudgeting(tester);

    expect(find.byKey(const Key('settingsBudgetingScreen')), findsOneWidget);
    expect(find.byKey(const Key('settingsBudgetingCard')), findsOneWidget);
    for (final key in rowKeys) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }

    expect(find.text(SettingsCopy.incomeSetup), findsOneWidget);
    expect(
      find.text(SettingsCopy.profilesSummary(budgets: 0, direct: 0)),
      findsOneWidget,
    );
    expect(find.text(SettingsCopy.monthEndSummary), findsOneWidget);
    expect(find.text(SettingsCopy.transfersSummary), findsOneWidget);
    expect(find.text(SettingsCopy.savingsSummary), findsOneWidget);
    expect(find.text(SettingsCopy.reportsSummary), findsOneWidget);
    expect(find.text(SettingsCopy.bulkAddExpensesSummary), findsOneWidget);

    expect(find.byType(Switch), findsNothing);
    expect(find.text(SettingsCopy.allowTransfers), findsNothing);
    expect(find.text(SettingsCopy.transfersOff), findsNothing);
  });

  testWidgets('opens every destination', (tester) async {
    await pumpBudgeting(tester);

    final rowToPath = <String, String>{
      'settingsIncomeRow': '/income_sources',
      'settingsProfilesRow': '/profiles',
      'settingsMonthEndRow': '/month_end',
      'settingsTransfersRow': '/transfers',
      'settingsSavingsRow': '/vault',
      'settingsReportsRow': '/reports',
      'settingsBulkAddExpensesRow': '/bulk_entry',
    };

    for (final entry in rowToPath.entries) {
      await tester.ensureVisible(find.byKey(Key(entry.key)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key(entry.key)));
      await tester.pumpAndSettle();
      expect(find.text('${entry.value} destination'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('hides Savings in a shared context', (tester) async {
    await pumpBudgeting(
      tester,
      harness: SettingsTestHarness(isShared: true),
    );

    expect(find.byKey(const Key('settingsSavingsRow')), findsNothing);
    expect(find.byKey(const Key('settingsTransfersRow')), findsOneWidget);
  });

  testWidgets('hides Bulk add expenses in a read-only context', (tester) async {
    await pumpBudgeting(
      tester,
      harness: SettingsTestHarness(canEdit: false),
    );

    expect(find.byKey(const Key('settingsBulkAddExpensesRow')), findsNothing);
  });

  test('income and profile summaries handle counts', () {
    expect(SettingsCopy.incomeSummary(0), SettingsCopy.incomeSetup);
    expect(SettingsCopy.incomeSummary(1), '1 source');
    expect(SettingsCopy.incomeSummary(2), '2 sources');
    expect(
      SettingsCopy.profilesSummary(budgets: 1, direct: 2),
      '1 budget · 2 direct',
    );
  });

  testWidgets('TransferScreen hosts the toggle and the off state',
      (tester) async {
    await pumpTransfer(tester, toggle: false);

    expect(find.text(SettingsCopy.allowTransfers), findsOneWidget);
    expect(find.text(SettingsCopy.transfersOff), findsWidgets);
    expect(find.byType(SwitchListTile), findsOneWidget);
    expect(find.text('Transfers are disabled in Settings.'), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);

    final switchTile = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(switchTile.value, isFalse);
    expect(switchTile.onChanged, isNotNull);
  });

  testWidgets('TransferScreen shows the list state when transfers are on',
      (tester) async {
    await pumpTransfer(tester, toggle: true);

    expect(find.text(SettingsCopy.allowTransfers), findsOneWidget);
    expect(find.text(SettingsCopy.transfersSummary), findsOneWidget);
    expect(find.text('No transfers yet.'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    final switchTile = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(switchTile.value, isTrue);
  });
}
