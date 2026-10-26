import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/features/spaces/providers/spaces_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:budget_buddy/core/models/budget_profile.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/month_end_run.dart';
import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/core/services/month_end_service.dart';
import 'package:budget_buddy/core/services/month_end_report.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/finance/providers/month_end_providers.dart';
import 'package:budget_buddy/features/finance/presentation/month_end_screen.dart';

class _UnusedDb implements Isar {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ScreenService extends MonthEndService {
  _ScreenService({this.owner = true, this.stale = false})
      : super(_UnusedDb(),
            context: ContextRef.personal(profileId: 1, yearMonth: '2026-09'),
            actorId: 1,
            rates: RateTableRegistry());
  final bool owner, stale;
  int saves = 0;
  List<MonthEndChoice> lastChoices = [];
  @override
  Future<({List<BudgetProfile> profiles, List<String> months, CurrencyCode currency})>
      inputs() async => (
            profiles: [
              BudgetProfile()
                ..syncGuid = 'food'
                ..profileId = 1
                ..yearMonth = '2026-09'
                ..name = 'Food'
                ..allocation = 100000
                ..monthEndRule = MonthEndRule.carryForward
                ..createdAt = DateTime(2026)
                ..updatedAt = DateTime(2026)
            ],
            months: ['2026-09'],
            currency: CurrencyCode.huf
          );
  @override
  Future<MonthEndReport> preview(String month,
          {List<MonthEndChoice> choices = const []}) async =>
      capturePreview(month, choices);

  MonthEndReport capturePreview(String month, List<MonthEndChoice> choices) {
    lastChoices = choices;
    return MonthEndReport(
        yearMonth: month,
        destinationMonth: '2026-10',
        currency: CurrencyCode.huf,
        lines: [
          MonthEndLine(
              sourceGuid: 'food',
              familyGuid: 'food',
              destinationGuid: 'next',
              name: 'Food',
              amounts: MonthEndAmounts(
                  allocation: 100000,
                  spent: 80000,
                  defaultAllocation: 100000,
                  rule: MonthEndRule.carryForward),
              existingDestination: false)
        ],
        blockers: const [],
        fingerprint: 'preview',
        canConfirm: owner);
  }

  @override
  Future<MonthEndRun> confirm(MonthEndReport preview,
      {List<MonthEndChoice> choices = const []}) async {
    saves++;
    if (stale) {
      throw const MonthEndException(
          'Data changed after preview. Generate a fresh preview.');
    }
    return MonthEndRun();
  }
}

void main() {
  testWidgets(
      'changing context discards the old preview and default confirmations',
      (tester) async {
    final selected = StateProvider<ContextRef>(
        (ref) => ContextRef.personal(profileId: 1, yearMonth: '2026-09'));
    final container = ProviderContainer(overrides: [
      budgetContextProvider.overrideWith((ref) => ref.watch(selected)),
      monthEndServiceProvider.overrideWithValue(_ScreenService()),
      monthEndRunsProvider.overrideWith((ref) => Stream.value([])),
      activeProfileProvider.overrideWith((ref) => Stream.value(null)),
      activeSpaceProvider.overrideWith((ref) => Stream.value(null)),
      mySpacesProvider.overrideWith((ref) => Stream.value([])),
    ]);
    addTearDown(container.dispose);
    await tester.binding.setSurfaceSize(const Size(900, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MonthEndScreen())));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm this default allocation'));
    await tester.tap(find.text('Review month-end'));
    await tester.pumpAndSettle();
    expect(find.text('Ready to finish'), findsOneWidget);
    container.read(selected.notifier).state =
        ContextRef.shared(spaceId: 2, yearMonth: '2026-09');
    await tester.pumpAndSettle();
    expect(find.text('Ready to finish'), findsNothing);
    expect(tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse);
    expect(find.text('Shared space'), findsOneWidget);
  });
  Future<_ScreenService> open(WidgetTester tester,
      {bool owner = true, bool stale = false}) async {
    tester.view.resetPhysicalSize();
    await tester.binding.setSurfaceSize(const Size(900, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final service = _ScreenService(owner: owner, stale: stale);
    await tester.pumpWidget(ProviderScope(overrides: [
      budgetContextProvider.overrideWithValue(
          ContextRef.personal(profileId: 1, yearMonth: '2026-09')),
      monthEndServiceProvider.overrideWithValue(service),
      monthEndRunsProvider.overrideWith((ref) => Stream.value([])),
    ], child: const MaterialApp(home: MonthEndScreen())));
    await tester.pumpAndSettle();
    return service;
  }

  Future<void> review(WidgetTester tester) async {
    await tester.tap(find.text('Confirm this default allocation'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Review month-end'));
    await tester.tap(find.text('Review month-end'));
    await tester.pumpAndSettle();
  }

  testWidgets('default allocation is grouped on load and while typing',
      (tester) async {
    final service = await open(tester);
    final field = find.byType(TextField);
    expect(tester.widget<TextField>(field).controller!.text, '100,000');
    await tester.enterText(field, '1000000');
    expect(tester.widget<TextField>(field).controller!.text, '1,000,000');
    await review(tester);
    expect(service.lastChoices.single.defaultAllocation, 1000000);
    expect(find.text('Ready to finish'), findsOneWidget);
  });

  testWidgets(
      'legacy default must be confirmed; preview clearly explains carry',
      (tester) async {
    final service = await open(tester);
    await tester.tap(find.text('Review month-end'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm a valid default allocation for Food.'),
        findsOneWidget);
    await review(tester);
    expect(find.text('Ready to finish'), findsOneWidget);
    expect(find.text('Financial checks passed'), findsOneWidget);
    expect(find.textContaining('120,000'), findsOneWidget);
    expect(service.saves, 0);
  });
  testWidgets('cancel confirmation makes no write', (tester) async {
    final service = await open(tester);
    await review(tester);
    await tester.ensureVisible(find.text('Finish month'));
    await tester.tap(find.text('Finish month'));
    await tester.pumpAndSettle();
    expect(find.text('Finish 2026-09?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(service.saves, 0);
  });
  testWidgets('viewer can inspect but cannot confirm', (tester) async {
    final service = await open(tester, owner: false);
    await review(tester);
    expect(find.textContaining('Only the shared-space Owner'), findsOneWidget);
    final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Finish month'));
    expect(button.onPressed, isNull);
    expect(service.saves, 0);
  });
  testWidgets('stale confirmation displays error and requires a fresh preview',
      (tester) async {
    final service = await open(tester, stale: true);
    await review(tester);
    await tester.ensureVisible(find.text('Finish month'));
    await tester.tap(find.text('Finish month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm month-end'));
    await tester.pumpAndSettle();
    expect(service.saves, 1);
    expect(find.textContaining('Data changed after preview'), findsOneWidget);
    expect(find.text('Finish month'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('review and confirmation remain reachable at phone width',
      (tester) async {
    await open(tester);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.text('Confirm this default allocation'), 150,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Confirm this default allocation'));
    await tester.scrollUntilVisible(find.text('Review month-end'), 150,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Review month-end'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Finish month'), 150,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Finish month'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
