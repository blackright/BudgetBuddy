import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/features/dashboard/presentation/widgets/month_convert_to_menu.dart';
import 'package:budget_buddy/features/finance/repositories/month_finance_repository.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../medical/repositories/medical_test_harness.dart';

/// Records every `saveConvertTo` instead of writing to Isar, so the clear
/// path can be asserted deterministically even though a fire-and-forget
/// Isar write cannot finish under the widget-test fake clock.
class RecordingRepo extends MonthFinanceRepository {
  RecordingRepo(super.isar) : calls = <List<Object?>>[];

  late List<List<Object?>> calls;

  @override
  Future<void> saveConvertTo(String yearMonth, CurrencyCode? currency) async {
    calls.add([yearMonth, currency]);
  }
}

/// T055: the shared `MonthConvertToMenu` — one convert-to control for every
/// screen, doing exactly what the dashboard's private `_ConvertToMenu` did:
/// pin the viewed month's display-only convert-to, or clear it back to the
/// profile main currency (FR-011, SC-006).
void main() {
  Widget wrap({
    required MonthlyBudget? budget,
    CurrencyCode main = CurrencyCode.huf,
    MonthFinanceRepository? finance,
  }) {
    return ProviderScope(
      overrides: [
        activeBudgetProvider.overrideWith((ref) => Stream.value(budget)),
        mainCurrencyProvider.overrideWithValue(main),
        if (finance != null)
          monthFinanceRepositoryProvider.overrideWithValue(finance),
      ],
      child: const MaterialApp(home: Scaffold(body: MonthConvertToMenu())),
    );
  }

  /// Isar must not open beneath the fake clock (the reason the only
  /// harness-driven widget test in the medical suite is skipped); open it in
  /// the real-async window instead.
  Future<MedicalTestHarness> openHarness(WidgetTester tester) async {
    late MedicalTestHarness harness;
    await tester.runAsync(() async {
      harness = await MedicalTestHarness.create();
    });
    return harness;
  }

  MonthlyBudget inMemoryBudget() => MonthlyBudget()
    ..id = 1
    ..yearMonth = '2026-01'
    ..baseAvailableAmount = 0
    ..currency = 'usd'
    ..createdAt = DateTime(2026)
    ..updatedAt = DateTime(2026);

  testWidgets('hides until the month has a budget row', (tester) async {
    await tester.pumpWidget(wrap(budget: null));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('monthConvertToMenu')), findsNothing);
  });

  testWidgets('shows the default-option and every currency on open',
      (tester) async {
    await tester.pumpWidget(wrap(budget: inMemoryBudget()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('monthConvertToMenu')), findsOneWidget);
    expect(find.byTooltip('Convert this month to'), findsOneWidget);

    await tester.tap(find.byKey(const Key('monthConvertToMenu')));
    await tester.pumpAndSettle();

    expect(find.text('Show in Forint (default)'), findsOneWidget);
    for (final code in CurrencyCode.values) {
      expect(
        find.text('${code.name.toUpperCase()} (${code.symbol})'),
        findsOneWidget,
      );
    }
  });

  testWidgets('selecting a currency persists the month in the real database',
      (tester) async {
    final harness = await openHarness(tester);
    const yearMonth = '2026-01';
    late MonthlyBudget budget;
    await tester.runAsync(() async {
      await harness.seedBudget();
      budget = (await harness.budgetFor(yearMonth))!;
    });

    await tester.pumpWidget(
      wrap(
        budget: budget,
        finance: MonthFinanceRepository(harness.isar),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('monthConvertToMenu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EUR (€)'));
    await tester.pumpAndSettle();

    // The popup fires `saveConvertTo` fire-and-forget inside the fake-async
    // zone, so its Isar reply only drains once the real event loop turns and a
    // pump runs the queued microtask. Poll until the first write lands.
    String? currency;
    for (var i = 0; i < 60 && currency != 'eur'; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
      await tester.runAsync(() async {
        currency = (await harness.budgetFor(yearMonth))?.currency;
      });
    }
    expect(currency, 'eur',
        reason: 'the shared control saves the viewed month like the dashboard');

    await tester.runAsync(harness.close);
  });

  testWidgets('the clear option works on a later open of the same menu',
      (tester) async {
    final harness = await openHarness(tester);
    final repo = RecordingRepo(harness.isar);

    await tester.pumpWidget(wrap(budget: inMemoryBudget(), finance: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('monthConvertToMenu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EUR (€)'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('monthConvertToMenu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show in Forint (default)'));
    await tester.pumpAndSettle();

    expect(repo.calls, [
      ['2026-01', CurrencyCode.eur],
      ['2026-01', null],
    ]);

    await tester.runAsync(harness.close);
  });
}
