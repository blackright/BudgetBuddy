import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:budget_buddy/core/presentation/app_themes.dart';
import 'package:budget_buddy/features/budget_setup/repositories/onboarding_repository.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import '../medical/repositories/medical_test_harness.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/features/budget_setup/presentation/financial_setup_screen.dart';
import 'package:budget_buddy/features/budget_setup/providers/budget_setup_provider.dart';
import 'package:budget_buddy/features/budget_setup/providers/onboarding_rollout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/financial_drafts.dart';

void main() {
  test('new financial rollout is off by default', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(unifiedOnboardingEnabledProvider), isFalse);
  });
  testWidgets('profile, separate funds, one expanded income and exact review',
      (tester) async {
    final controller = FinancialSetupController(initial: financialDraft());
    await tester.pumpWidget(ProviderScope(overrides: [
      unifiedOnboardingEnabledProvider.overrideWithValue(true),
      financialSetupProvider.overrideWith((ref) => controller)
    ], child: const MaterialApp(home: FinancialSetupScreen())));
    await tester.pumpAndSettle();
    expect(find.text('Your profile'), findsOneWidget);
    expect(find.text('J'), findsOneWidget);
    await tester.tap(find.byKey(const Key('financialContinue')));
    await tester.pumpAndSettle();
    expect(find.text('Set up your income'), findsOneWidget);
    expect(find.text('Opening money'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('financialContinue')));
    await tester.tap(find.byKey(const Key('financialContinue')));
    await tester.pumpAndSettle();
    expect(find.text('Review your first month'), findsOneWidget);
    expect(find.textContaining('600,000'), findsWidgets);
    expect(find.textContaining('500,000'), findsWidgets);
    await tester.ensureVisible(find.byKey(const Key('editMonthIncome')));
    await tester.tap(find.byKey(const Key('editMonthIncome')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('addIncomeSource')));
    await tester.tap(find.byKey(const Key('addIncomeSource')));
    await tester.pumpAndSettle();
    expect(controller.state.draft.sources, hasLength(2));
    expect(find.byKey(const Key('sourceAmount-salary-1')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('financialContinue')));
    await tester.tap(find.byKey(const Key('financialContinue')));
    await tester.pumpAndSettle();
    expect(controller.state.errors, isNotEmpty);
    expect(controller.state.page, 1);
  });
  test(
      'changing currency cannot silently relabel amounts; explicit reset retains source identity',
      () {
    final controller = FinancialSetupController(initial: financialDraft());
    addTearDown(controller.dispose);
    expect(controller.changeCurrency(CurrencyCode.eur), isFalse);
    expect(controller.state.draft.profile.currency, CurrencyCode.huf);
    expect(
        controller.changeCurrency(CurrencyCode.eur,
            discardAmountsConfirmed: true),
        isTrue);
    expect(controller.state.draft.opening.amountText, isEmpty);
    expect(controller.state.draft.sources.single.amountText, isEmpty);
    expect(controller.state.draft.sources.single.sourceGuid, 'salary-1');
  });
  test('No income requires confirmation before removing entered rows', () {
    final controller = FinancialSetupController(initial: financialDraft());
    addTearDown(controller.dispose);
    expect(controller.chooseNoIncome(), isFalse);
    expect(controller.state.draft.sources, hasLength(1));
    expect(controller.chooseNoIncome(discardSourcesConfirmed: true), isTrue);
    expect(controller.state.draft.sources, isEmpty);
  });

  testWidgets(
      'grouped entry reaches exact review and cancelling removal keeps income',
      (tester) async {
    final controller = FinancialSetupController(initial: financialDraft());
    await tester.pumpWidget(ProviderScope(overrides: [
      unifiedOnboardingEnabledProvider.overrideWithValue(true),
      financialSetupProvider.overrideWith((ref) => controller)
    ], child: const MaterialApp(home: FinancialSetupScreen())));
    await tester.tap(find.byKey(const Key('financialContinue')));
    await tester.pumpAndSettle();
    final opening = find.descendant(
        of: find.byKey(const Key('openingAmount')),
        matching: find.byType(TextField));
    await tester.ensureVisible(opening);
    await tester.enterText(opening, '1000000');
    await tester.pumpAndSettle();
    expect(controller.state.draft.opening.amountText, '1,000,000');
    await tester.ensureVisible(find.byKey(const Key('noIncomeYet')));
    await tester.tap(find.byKey(const Key('noIncomeYet')));
    await tester.pumpAndSettle();
    expect(find.text('Choose No income yet?'), findsOneWidget);
    await tester.tap(find.text('Keep entries'));
    await tester.pumpAndSettle();
    expect(controller.state.draft.sources, hasLength(1));
    await tester.tap(find.byKey(const Key('financialContinue')));
    await tester.pumpAndSettle();
    expect(controller.state.review!.bankMinor, 1500000);
  });

  for (final dark in [false, true]) {
    for (final large in [false, true]) {
      testWidgets(
          'financial forms remain reachable in ${dark ? 'dark' : 'light'} at ${large ? '320 / 200%' : '390 / 100%'}',
          (tester) async {
        tester.view.physicalSize = Size(large ? 320 : 390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final harness =
            await tester.runAsync(() => MedicalTestHarness.create());
        expect(harness, isNotNull);
        await tester.runAsync(() async {
          final loader = FontLoader('OnboardingPreview')
            ..addFont(
                rootBundle.load('assets/fonts/reports/NotoSans-Regular.ttf'));
          await loader.load();
          final icons = FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
          await icons.load();
        });
        final controller = FinancialSetupController(
            initial: financialDraft(),
            repository: OnboardingRepository(harness!.isar));
        final boundaryKey = GlobalKey();
        try {
          await tester.pumpWidget(ProviderScope(
              overrides: [
                unifiedOnboardingEnabledProvider.overrideWithValue(true),
                financialSetupProvider.overrideWith((ref) => controller)
              ],
              child: RepaintBoundary(
                  key: boundaryKey,
                  child: MaterialApp(
                      debugShowCheckedModeBanner: false,
                      theme: buildAppTheme(
                          brightness: dark ? Brightness.dark : Brightness.light,
                          fontFamily: 'OnboardingPreview'),
                      builder: (context, child) => MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                              textScaler: TextScaler.linear(large ? 2 : 1),
                              disableAnimations: true),
                          child: child!),
                      home: const FinancialSetupScreen()))));
          await tester.pumpAndSettle();
          for (var page = 0; page < 3; page++) {
            expect(controller.state.page, page);
            expect(tester.takeException(), isNull);
            expect(find.byKey(const Key('financialContinue')), findsOneWidget);
            if (const bool.fromEnvironment('CAPTURE_ONBOARDING_PREVIEWS')) {
              if (!large) {
                await tester.runAsync(() async {
                  final boundary = boundaryKey.currentContext!
                      .findRenderObject()! as RenderRepaintBoundary;
                  final image = await boundary.toImage(pixelRatio: 2);
                  try {
                    final bytes = (await image.toByteData(
                        format: ui.ImageByteFormat.png))!;
                    final directory = Directory(
                        'specs/019-unified-onboarding/previews/phase-03');
                    await directory.create(recursive: true);
                    await File('${directory.path}/${[
                      'profile',
                      'income',
                      'review'
                    ][page]}-${dark ? 'dark' : 'light'}.png')
                        .writeAsBytes(bytes.buffer.asUint8List());
                  } finally {
                    image.dispose();
                  }
                });
              }
            }
            if (page < 2) {
              await tester.tap(find.byKey(const Key('financialContinue')));
              await tester.pumpAndSettle();
            }
          }
          // Real save is explicitly awaited outside fake async; this is a
          // disposable native DB, not a stubbed success or a phone action.
          await tester.runAsync(() => controller.save());
          await tester.pumpAndSettle();
          expect(controller.state.receipt, isNotNull);
          expect(find.text('Financial details saved'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.runAsync(() async {
            expect(await harness.isar.userProfiles.count(), 1);
            expect(await harness.isar.incomeSources.count(), 1);
          });
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.runAsync(harness.close);
        }
      });
    }
  }
}
