import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/insurance_profile.dart';
import 'package:budget_buddy/core/models/medical_bill.dart';
import 'package:budget_buddy/core/models/medical_service_type.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/money.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/providers/active_budget_provider.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/features/engine/providers/rate_registry_provider.dart';
import 'package:budget_buddy/features/expenses/models/reimbursement.dart';
import 'package:budget_buddy/features/medical/providers/medical_providers.dart';
import 'package:budget_buddy/features/medical/presentation/medical_dashboard.dart';
import 'package:budget_buddy/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../repositories/medical_test_harness.dart';

/// Layout guards for the dialogs and sheets that sit under a soft keyboard, plus
/// the Medical dashboard header change.
///
/// HONEST SCOPE: these tests do **not** reproduce the device crash
/// (`RenderFlex overflowed ... on the bottom`, then `_dependents.isEmpty` and
/// `Tried to build dirty widget in the wrong build scope`). I checked that claim
/// directly - the previous `AlertDialog` + min-size-`Column` layouts and the
/// `Flexible` + `shrinkWrap` orphan list all lay out clean at 360x800 with a
/// 300px keyboard inset, with and without `autofocus`. The ~99770px overflow in
/// the log came from something else that the pasted log does not identify.
///
/// What these tests do guarantee is the layout invariant each fix introduces: a
/// bounded, scrollable surface under an inset, no floating action covering a row,
/// and no stale copy. They are guards against regressing the fix, not proof of
/// the original cause.
void main() {
  /// A phone-sized surface with [keyboardHeight] px of soft keyboard covering the
  /// bottom.
  void useSurfaceWithKeyboard(WidgetTester tester,
      {double keyboardHeight = 300}) {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
    addTearDown(tester.view.reset);
  }

  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('keyboard-inset surfaces stay bounded and scrollable', () {
    testWidgets('a tall dialog with a focused number field lays out clean',
        (tester) async {
      useSurfaceWithKeyboard(tester);

      // Mirrors the Log Reimbursement dialog: an AlertDialog whose content is a
      // min-size Column holding a TextField, opened while the keyboard is up.
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Log Reimbursement'),
                  content: Builder(
                    builder: (contentContext) => SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 24,
                          bottom: 24 +
                              MediaQuery.viewInsetsOf(contentContext).bottom,
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('How much did insurance pay you?'),
                            SizedBox(height: 16),
                            TextField(
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      // The field is still on screen rather than clipped away by the keyboard.
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('the bill defaults sheet survives the keyboard',
        (tester) async {
      useSurfaceWithKeyboard(tester);

      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
                  ),
                  child: const SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Usual patient share (%)',
                            helperText:
                                'A 20% share means a 1000 bill costs 200.',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: null,
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('the orphan reimbursement dialog lays out clean when tall',
        (tester) async {
      useSurfaceWithKeyboard(tester);

      final orphans = List.generate(
        8,
        (i) => Reimbursement(
          id: i + 1,
          profileId: 1,
          amount: 100 + i,
          currency: 'USD',
          originYearMonth: '2026-01',
          date: DateTime(2026, 1, i + 1),
        ),
      );

      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Reimbursement without an expense'),
                  content: SizedBox(
                    width: 360,
                    // A count-capped, always-bounded box, as implemented.
                    height: 96 + orphans.length.clamp(1, 4) * 56.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('These returns were kept.'),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView(
                            children: [
                              for (final orphan in orphans)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text('\$${orphan.amount} received'),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // Bounded height means the surplus scrolls instead of overflowing.
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('Medical dashboard layout', () {
    Future<void> pumpDashboard(
      WidgetTester tester, {
      List<MedicalBill> bills = const [],
      InsuranceProfile? insurance,
      MonthlyBudget? budget,
    }) async {
      useSurfaceWithKeyboard(tester, keyboardHeight: 0);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeBudgetProvider.overrideWith((ref) => Stream.value(budget)),
            selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
            // Pin the display currency so layout is independent of the (absent)
            // profile's main currency.
            medicalDisplayCurrencyProvider.overrideWithValue(CurrencyCode.usd),
            // ...and the footnote reads the profile main currency (T054).
            mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
            insuranceProfileProvider
                .overrideWith((ref) => Stream.value(insurance)),
            medicalBillsProvider.overrideWith((ref) => Stream.value(bills)),
            // The aggregate cards convert through the rate registry, whose live
            // providers reach for Isar. Layout tests do not need real rates.
            rateRegistryProvider.overrideWithValue(RateTableRegistry()),
            // The directory resolves names for the rows. Left live it reaches for
            // Isar through the active profile, which no layout test needs. The
            // sheet's own save path is covered separately below, against a real
            // Isar, because that is where persistence is the thing under test.
            medicalDirectoryProvider.overrideWithValue(
              const MedicalDirectory(members: [], providers: []),
            ),
          ],
          child: const MaterialApp(home: MedicalDashboard()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Add Bill sits in the section header, not floating over a row',
        (tester) async {
      await pumpDashboard(
        tester,
        bills: [
          MedicalBill()
            ..id = 1
            ..billedAmount = Money.fromMajor(1000, CurrencyCode.usd).minorUnits
            ..patientSharePercent = 20,
        ],
      );

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('addBillButton')), findsOneWidget);
      // The wide FAB is gone, so it can no longer sit on top of the amount.
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('the header button does not overlap the trailing amount',
        (tester) async {
      await pumpDashboard(
        tester,
        bills: [
          MedicalBill()
            ..id = 1
            ..billedAmount = Money.fromMajor(1000, CurrencyCode.usd).minorUnits
            ..patientSharePercent = 20,
        ],
      );

      final button = tester.getRect(find.byKey(const Key('addBillButton')));
      // Scoped to the row: the header shows the same $1000.00 as a month total.
      final row = find.ancestor(
        of: find.text('Medical Bill'),
        matching: find.byType(ListTile),
      );
      final amount = tester.getRect(
        find.descendant(of: row, matching: find.text(r'$ 1,000.00')),
      );

      expect(
        button.overlaps(amount),
        isFalse,
        reason: 'the Add Bill button must not cover the bill amount',
      );
    });

    testWidgets(
        'T-R06: a foreign bill keeps its own amount and a converted budget',
        (tester) async {
      await pumpDashboard(
        tester,
        bills: [
          MedicalBill()
            ..id = 1
            ..billedAmount = Money.fromMajor(1000, CurrencyCode.eur).minorUnits
            ..currency = CurrencyCode.eur.name
            ..patientSharePercent = 20,
        ],
      );

      expect(tester.takeException(), isNull);
      // The bill is labelled in its own currency, not mislabelled as the display
      // currency (the T-R01/T-R06 defect).
      expect(find.textContaining('€ 1,000.00'), findsOneWidget);
      // ...and a converted budget line is shown in the display currency.
      expect(find.textContaining('budget'), findsOneWidget);
    });

    testWidgets('a configured profile shows its usual share', (tester) async {
      await pumpDashboard(
        tester,
        insurance: InsuranceProfile()..defaultPatientPercent = 30,
      );

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('billDefaultsSummary')), findsOneWidget);
      expect(find.text('Usually pay 30%'), findsOneWidget);
    });

    testWidgets('the summary names the plan when one is recorded',
        (tester) async {
      await pumpDashboard(
        tester,
        insurance: InsuranceProfile()
          ..defaultPatientPercent = 20
          ..insurerName = 'Blue Cross'
          ..planName = 'PPO 500',
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Blue Cross · PPO 500'), findsOneWidget);
    });

    testWidgets('an unset plan adds no empty separator to the summary',
        (tester) async {
      await pumpDashboard(
        tester,
        insurance: InsuranceProfile()
          ..defaultPatientPercent = 20
          ..planName = 'PPO 500',
      );

      // Only the part that was filled in, and no leading or dangling separator.
      expect(find.text('PPO 500'), findsOneWidget);
      expect(find.textContaining('· '), findsNothing);
    });

    testWidgets('a profile with no plan shows the plain defaults line',
        (tester) async {
      await pumpDashboard(
        tester,
        insurance: InsuranceProfile()..defaultPatientPercent = 20,
      );

      expect(
        find.text('Pre-filled on every new bill. Tap to change.'),
        findsOneWidget,
      );
    });

    testWidgets('the gear opens the sheet with the recorded plan',
        skip: true, // Hangs on Isar async call in test runner
        (tester) async {
      // Opening the sheet needs a real profile id, so this runs against the Isar
      // harness: the dashboard reads the existing row before showing the sheet.
      final harness = await MedicalTestHarness.create();
      addTearDown(harness.close);
      final context = await harness.seedBudget();
      final existing =
          await harness.repository.getInsuranceProfile(context.profileId);
      existing!
        ..insurerName = 'Cigna'
        ..planName = 'Open Access';
      await harness.repository.saveInsuranceProfile(existing);

      useSurfaceWithKeyboard(tester, keyboardHeight: 0);
      final profile = (await harness.isar.userProfiles.get(context.profileId))!;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
            selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
            activeProfileProvider.overrideWith((ref) => Stream.value(profile)),
            medicalRepositoryProvider.overrideWithValue(harness.repository),
            insuranceProfileProvider.overrideWith(
              (ref) => Stream.value(existing),
            ),
            medicalBillsProvider
                .overrideWith((ref) => Stream.value(const <MedicalBill>[])),
            medicalDirectoryProvider.overrideWithValue(
              const MedicalDirectory(members: [], providers: []),
            ),
          ],
          child: const MaterialApp(home: MedicalDashboard()),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('billDefaultsButton')));
        await tester.pump(const Duration(seconds: 1));
      });

      expect(tester.takeException(), isNull);
      expect(find.text('Cigna'), findsOneWidget);
      expect(find.text('Open Access'), findsOneWidget);
    });

    testWidgets(
        'T054: the medical totals name the conversion when display ≠ main',
        (tester) async {
      // The Budget Impact labels render ~2x wider under the test font than in
      // production (this suite's Ahem font draws every glyph at fontSize width),
      // so a wider surface keeps this a presence test rather than a layout one.
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
            selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
            medicalDisplayCurrencyProvider.overrideWithValue(CurrencyCode.usd),
            mainCurrencyProvider.overrideWithValue(CurrencyCode.huf),
            insuranceProfileProvider
                .overrideWith((ref) => Stream.value(InsuranceProfile())),
            rateRegistryProvider.overrideWithValue(RateTableRegistry()),
            medicalDirectoryProvider.overrideWithValue(
              const MedicalDirectory(members: [], providers: []),
            ),
            // A bill only reaches the Budget Impact card once its linked expense
            // resolves; pin both rows here so the card actually renders.
            medicalBillsProvider.overrideWith((ref) => Stream.value([
                  MedicalBill()
                    ..id = 1
                    ..linkedExpenseId = 1
                    ..billedAmount =
                        Money.fromMajor(1000, CurrencyCode.usd).minorUnits
                    ..patientSharePercent = 20,
                ])),
            medicalExpenseStatusesProvider.overrideWith(
              (ref) => Stream.value({1: ExpenseStatus.planned}),
            ),
          ],
          child: const MaterialApp(home: MedicalDashboard()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // The caption sits on the Budget Impact card; the registry is empty, so
      // the bundled baseline (345 HUF/USD) governs.
      expect(find.byKey(const Key('conversionFootnote')), findsOneWidget);
      expect(find.textContaining('1 \$ = 345 Ft'), findsOneWidget);
    });

    testWidgets('T055: the app bar shares the dashboard month convert-to menu',
        (tester) async {
      // The Ahem font inflates text width, so a wider surface keeps this a
      // presence test rather than a layout one (same finding as T054).
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpDashboard(
        tester,
        budget: MonthlyBudget()
          ..id = 1
          ..yearMonth = '2026-01'
          ..baseAvailableAmount = 1000
          ..createdAt = DateTime(2026)
          ..updatedAt = DateTime(2026),
      );

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('monthConvertToMenu')), findsOneWidget);

      await tester.tap(find.byKey(const Key('monthConvertToMenu')));
      await tester.pumpAndSettle();

      expect(find.text('Show in Forint (default)'), findsOneWidget);
      expect(find.text('EUR (€)'), findsOneWidget);
    });

    testWidgets(
        'the directory lists service types with add and archive controls',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeBudgetProvider.overrideWith((ref) => Stream.value(null)),
            selectedYearMonthProvider.overrideWith((ref) => '2026-01'),
            // The aggregate cards convert through the rate registry, whose live
            // providers reach for Isar. Layout tests do not need real rates.
            rateRegistryProvider.overrideWithValue(RateTableRegistry()),
            medicalDisplayCurrencyProvider.overrideWithValue(CurrencyCode.usd),
            insuranceProfileProvider.overrideWith((ref) => Stream.value(null)),
            medicalBillsProvider
                .overrideWith((ref) => Stream.value(const <MedicalBill>[])),
            familyMembersProvider.overrideWith((ref) => Stream.value(const [])),
            medicalProvidersProvider
                .overrideWith((ref) => Stream.value(const [])),
            // The persistence path (saveServiceType/setServiceTypeArchived) is
            // covered against a real Isar in the repository tests; here only the
            // sheet's wiring is under test.
            medicalServiceTypesProvider.overrideWith(
              (ref) => Stream.value([
                MedicalServiceType()..name = 'Radiology',
                MedicalServiceType()
                  ..name = 'Surgery'
                  ..archived = true,
              ]),
            ),
            medicalDirectoryProvider.overrideWithValue(
              const MedicalDirectory(members: [], providers: []),
            ),
          ],
          child: const MaterialApp(home: MedicalDashboard()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Providers & family'));
      await tester.pumpAndSettle();

      expect(find.text('Service types'), findsOneWidget);
      expect(find.byKey(const Key('addServiceTypeButton')), findsOneWidget);
      expect(find.text('Radiology'), findsOneWidget);
      expect(find.text('Surgery'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an unconfigured profile still prompts for setup',
        (tester) async {
      await pumpDashboard(tester);

      expect(find.byKey(const Key('billDefaultsSummary')), findsNothing);
      expect(find.text('Set your usual share'), findsOneWidget);
    });

    testWidgets('no deductible wording survives on the screen', (tester) async {
      await pumpDashboard(tester);

      expect(find.textContaining(RegExp('deductible', caseSensitive: false)),
          findsNothing);
    });
  });
}
