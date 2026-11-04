import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/month_end_run.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/routing/app_router.dart';
import 'package:budget_buddy/core/services/month_end_service.dart';
import 'package:budget_buddy/features/finance/presentation/month_end_screen.dart';
import 'package:budget_buddy/features/finance/providers/month_end_providers.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

/// F1 / T071: Month-End opens on the month a deep link names, and never leaves
/// the screen on the current month when a closable month exists.
class _UnusedDb implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NavService extends MonthEndService {
  _NavService({required this.months})
      : super(_UnusedDb(),
            context: ContextRef.personal(profileId: 1, yearMonth: '2026-10'),
            actorId: 1,
            rates: RateTableRegistry(),
            clock: () => DateTime(2026, 10, 23));
  final List<String> months;

  @override
  Future<
          ({
            List<BudgetProfile> profiles,
            List<String> months,
            CurrencyCode currency
          })>
      inputs() async => (
            profiles: const <BudgetProfile>[],
            months: months,
            currency: CurrencyCode.huf
          );
}

MonthEndRun run(String month, {bool applied = true}) => MonthEndRun()
  ..syncGuid = 'run-$month'
  ..profileId = 1
  ..contextGuid = 'personal:1'
  ..yearMonth = month
  ..destinationMonth = '2026-11'
  ..currency = 'huf'
  ..reportJson = '{"lines":[]}'
  ..fingerprint = 'fingerprint'
  ..actor = 'profile:1'
  ..createdAt = DateTime(2026, 10, 23)
  ..applied = applied;

void main() {
  String? selectedMonth(WidgetTester tester) {
    return tester
        .widget<DropdownButtonFormField<String>>(
            find.byKey(const Key('sourceMonthDropdown')))
        .initialValue;
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    String? initialMonth,
    required List<String> months,
    List<MonthEndRun> runs = const [],
    String contextMonth = '2026-10',
  }) async {
    await tester.binding.setSurfaceSize(const Size(900, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        budgetContextProvider.overrideWithValue(
            ContextRef.personal(profileId: 1, yearMonth: contextMonth)),
        monthEndServiceProvider.overrideWithValue(_NavService(months: months)),
        monthEndRunsProvider.overrideWith((ref) => Stream.value(runs)),
        activeProfileProvider.overrideWith((ref) => Stream.value(null)),
        activeSpaceProvider.overrideWith((ref) => Stream.value(null)),
        mySpacesProvider.overrideWith((ref) => Stream.value([])),
      ],
      child: MaterialApp(home: MonthEndScreen(initialMonth: initialMonth)),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> pumpRoute(WidgetTester tester, String location,
      {required List<String> months, List<MonthEndRun> runs = const []}) async {
    await tester.binding.setSurfaceSize(const Size(900, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final router = createAppRouter(initialLocation: location);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        budgetContextProvider.overrideWithValue(
            ContextRef.personal(profileId: 1, yearMonth: '2026-10')),
        monthEndServiceProvider.overrideWithValue(_NavService(months: months)),
        monthEndRunsProvider.overrideWith((ref) => Stream.value(runs)),
        activeProfileProvider.overrideWith((ref) => Stream.value(null)),
        activeSpaceProvider.overrideWith((ref) => Stream.value(null)),
        mySpacesProvider.overrideWith((ref) => Stream.value([])),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('a ?month= deep link opens the requested completed month',
      (tester) async {
    await pumpRoute(tester, '/month_end?month=2026-08',
        months: ['2026-08', '2026-09', '2026-10'], runs: [run('2026-08')]);
    expect(selectedMonth(tester), '2026-08');
  });

  testWidgets('an invalid ?month= falls back to a closable month',
      (tester) async {
    await pumpRoute(tester, '/month_end?month=2026-13',
        months: ['2026-08', '2026-09', '2026-10'], runs: [run('2026-08')]);
    expect(selectedMonth(tester), '2026-09');
  });

  testWidgets('an absent initial month skips the current month',
      (tester) async {
    await pumpScreen(tester, months: ['2026-09', '2026-10']);
    expect(selectedMonth(tester), '2026-09');
  });

  testWidgets('a completed selected month is kept', (tester) async {
    await pumpScreen(tester,
        months: ['2026-08', '2026-09', '2026-10'], contextMonth: '2026-09');
    expect(selectedMonth(tester), '2026-09');
  });

  testWidgets('the earliest completed month without a run is preferred',
      (tester) async {
    await pumpScreen(tester,
        months: ['2026-07', '2026-08', '2026-10'], runs: [run('2026-07')]);
    expect(selectedMonth(tester), '2026-08');
  });

  testWidgets('the requested month is honoured even when already finished',
      (tester) async {
    await pumpScreen(tester,
        initialMonth: '2026-07',
        months: ['2026-07', '2026-08', '2026-10'],
        runs: [run('2026-07')]);
    expect(selectedMonth(tester), '2026-07');
  });
}
