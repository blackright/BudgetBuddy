import 'package:budget_buddy/core/providers/budget_context_provider.dart';
import 'package:budget_buddy/features/dashboard/presentation/widgets/onboarding_guidance_card.dart';
import 'package:budget_buddy/features/dashboard/presentation/widgets/secondary_rows.dart';
import 'package:budget_buddy/features/vault/models/savings_vault.dart';
import 'package:budget_buddy/features/vault/providers/vault_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  SavingsVault vault({
    int totalMinor = 5000,
    String currency = 'huf',
    bool paused = false,
  }) {
    return SavingsVault()
      ..profileId = 1
      ..totalMinor = totalMinor
      ..currency = currency
      ..sweepPaused = paused
      ..lastSweepYearMonth = '2026-01'
      ..updatedAt = DateTime(2026);
  }

  SetupSuggestion suggestion(
    String title,
    String route, {
    IconData icon = Icons.auto_awesome_outlined,
  }) {
    return SetupSuggestion(title, 'Explain $title', route, icon);
  }

  Widget wrap({
    bool shared = false,
    SavingsVault? savings,
    bool vaultError = false,
    String? reviewMessage,
    List<SetupSuggestion>? suggestions,
    Size size = const Size(1000, 2400),
    double textScale = 1,
  }) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: SecondaryRows(),
            ),
          ),
        ),
        for (final path in [
          '/vault',
          '/analytics',
          '/income_sources',
          '/allocations',
          '/add_expense',
        ])
          GoRoute(
            path: path,
            builder: (context, state) => Scaffold(
              body: Text('$path destination'),
            ),
          ),
      ],
    );
    addTearDown(router.dispose);

    return ProviderScope(
      overrides: [
        budgetContextProvider.overrideWithValue(shared
            ? ContextRef.shared(spaceId: 2, yearMonth: '2026-01')
            : ContextRef.personal(profileId: 1, yearMonth: '2026-01')),
        vaultProvider.overrideWith((ref) {
          if (vaultError) {
            return Stream.error(StateError('vault failed'));
          }
          return Stream.value(savings);
        }),
        vaultReviewMessageProvider.overrideWithValue(reviewMessage),
        onboardingGuidanceProvider.overrideWithValue(
          AsyncData(suggestions ?? const <SetupSuggestion>[]),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> pumpRows(
    WidgetTester tester, {
    bool shared = false,
    SavingsVault? savings,
    bool vaultError = false,
    String? reviewMessage,
    List<SetupSuggestion>? suggestions,
    Size size = const Size(1000, 2400),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      wrap(
        shared: shared,
        savings: savings,
        vaultError: vaultError,
        reviewMessage: reviewMessage,
        suggestions: suggestions,
        size: size,
        textScale: textScale,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the savings balance and opens the vault', (tester) async {
    await pumpRows(tester, savings: vault());

    expect(find.byKey(const Key('savingsCard')), findsOneWidget);
    expect(find.text('Savings'), findsOneWidget);
    expect(find.text('Ft 5,000'), findsOneWidget);

    await tester.tap(find.byKey(const Key('savingsCard')));
    await tester.pumpAndSettle();
    expect(find.text('/vault destination'), findsOneWidget);
  });

  testWidgets('maps an empty savings state', (tester) async {
    await pumpRows(tester);
    expect(find.text('Start saving'), findsOneWidget);
  });

  testWidgets('maps a savings review state', (tester) async {
    await pumpRows(tester, savings: vault(), reviewMessage: 'review');
    expect(find.text('Needs review'), findsOneWidget);
  });

  testWidgets('maps a paused savings state', (tester) async {
    await pumpRows(tester, savings: vault(paused: true));
    expect(find.text('Savings paused'), findsOneWidget);
  });

  testWidgets('shows a savings error with retry while keeping the row',
      (tester) async {
    await pumpRows(tester, vaultError: true);

    expect(find.byKey(const Key('savingsCard')), findsOneWidget);
    expect(find.text("Couldn't load"), findsOneWidget);
    expect(find.byKey(const Key('savingsRetry')), findsOneWidget);

    await tester.tap(find.byKey(const Key('savingsRetry')));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides Savings in a shared context', (tester) async {
    await pumpRows(tester, shared: true, savings: vault());

    expect(find.byKey(const Key('savingsCard')), findsNothing);
    expect(find.byKey(const Key('analyticsCard')), findsOneWidget);
  });

  testWidgets('shows the highest-priority next step and +N more',
      (tester) async {
    final items = [
      suggestion('Plan budgets', '/allocations', icon: Icons.pie_chart_outline),
      suggestion('Review income', '/income_sources',
          icon: Icons.add_card_outlined),
      suggestion('Add expense', '/add_expense',
          icon: Icons.receipt_long_outlined),
    ];
    await pumpRows(tester, suggestions: items);

    expect(find.byKey(const Key('nextStepCard')), findsOneWidget);
    expect(find.text('Review income'), findsOneWidget);
    expect(find.byKey(const Key('nextStepMore')), findsOneWidget);
    expect(find.text('+2 more'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nextStepCard')));
    await tester.pumpAndSettle();
    expect(find.text('/income_sources destination'), findsOneWidget);
  });

  testWidgets('opens the full next-steps sheet from +N more', (tester) async {
    final items = [
      suggestion('Review income', '/income_sources'),
      suggestion('Plan budgets', '/allocations'),
      suggestion('Add expense', '/add_expense'),
    ];
    await pumpRows(tester, suggestions: items);

    await tester.tap(find.byKey(const Key('nextStepMore')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('nextStepsSheet')), findsOneWidget);
    expect(find.text('Plan budgets'), findsOneWidget);

    await tester
        .tap(find.byKey(const ValueKey('nextStep-/allocations-Plan budgets')));
    await tester.pumpAndSettle();
    expect(find.text('/allocations destination'), findsOneWidget);
  });

  testWidgets('hides Next step when there is no suggestion', (tester) async {
    await pumpRows(tester, suggestions: const []);

    expect(find.byKey(const Key('nextStepCard')), findsNothing);
    expect(find.byKey(const Key('analyticsCard')), findsOneWidget);
  });

  testWidgets('hides Next step when only optional exploration remains',
      (tester) async {
    await pumpRows(
      tester,
      suggestions: [
        suggestion('Explore Medical', '/medical'),
        suggestion('Explore Spaces', '/spaces'),
      ],
    );

    expect(find.byKey(const Key('nextStepCard')), findsNothing);
  });

  testWidgets('opens Analytics', (tester) async {
    await pumpRows(tester);

    await tester.tap(find.byKey(const Key('analyticsCard')));
    await tester.pumpAndSettle();
    expect(find.text('/analytics destination'), findsOneWidget);
  });

  testWidgets('stays usable at 320 dp and 200% text', (tester) async {
    await pumpRows(
      tester,
      savings: vault(),
      suggestions: [
        suggestion('Review income sources', '/income_sources'),
        suggestion('Plan budgets', '/allocations'),
      ],
      size: const Size(320, 1600),
      textScale: 2,
    );

    expect(find.byKey(const Key('savingsCard')), findsOneWidget);
    expect(find.byKey(const Key('nextStepCard')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
