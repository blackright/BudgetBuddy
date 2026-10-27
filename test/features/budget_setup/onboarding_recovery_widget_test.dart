import 'package:budget_buddy/features/budget_setup/presentation/financial_setup_screen.dart';
import 'package:budget_buddy/features/budget_setup/providers/onboarding_rollout_provider.dart';
import 'package:budget_buddy/features/budget_setup/repositories/onboarding_repository.dart';
import '../medical/repositories/medical_test_harness.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/presentation/app_themes.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/features/budget_setup/providers/budget_setup_provider.dart';
import 'package:budget_buddy/features/budget_setup/presentation/widgets/setup_recovery.dart';
import 'support/financial_drafts.dart';

void main() {
  for (final dark in [false, true]) {
    for (final large in [false, true]) {
      testWidgets(
          'recovery explains retained data and explicit profile access ${dark ? "dark" : "light"} ${large ? "large" : "normal"}',
          (tester) async {
        tester.view.physicalSize = Size(large ? 320 : 390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.runAsync(() async {
          final font = FontLoader('OnboardingPreview')
            ..addFont(
                rootBundle.load('assets/fonts/reports/NotoSans-Regular.ttf'));
          await font.load();
          final icons = FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
          await icons.load();
        });
        final profile = UserProfile()
          ..id = 8
          ..name = 'Jason';
        int? selected;
        var retries = 0;
        final key = GlobalKey();
        await tester.pumpWidget(ProviderScope(
            overrides: [
              profilesProvider.overrideWith((ref) => Stream.value([profile]))
            ],
            child: RepaintBoundary(
                key: key,
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
                    home: Scaffold(
                        appBar: AppBar(title: const Text('Personal setup')),
                        body: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: SetupRecovery(
                                view: FinancialSetupView(
                                    draft: financialDraft(),
                                    needsReview: true,
                                    existingProfileIds: {8}),
                                retry: () => retries++,
                                openProfile: (id) => selected = id)))))));
        await tester.pumpAndSettle();
        expect(find.text('Let\u2019s review your saved setup'), findsOneWidget);
        expect(find.textContaining('records have been kept'), findsOneWidget);
        expect(find.text('Open Jason'), findsOneWidget);
        expect(find.textContaining('profile 8'), findsNothing);
        expect(find.textContaining('Reset'), findsNothing);
        if (const bool.fromEnvironment('CAPTURE_ONBOARDING_PREVIEWS')) {
          if (!large) {
            await tester.runAsync(() async {
              final boundary = key.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
              final img = await boundary.toImage(pixelRatio: 2);
              try {
                final bytes =
                    (await img.toByteData(format: ui.ImageByteFormat.png))!;
                final dir =
                    Directory('specs/019-unified-onboarding/previews/phase-04');
                await dir.create(recursive: true);
                await File(
                        '${dir.path}/recovery-${dark ? "dark" : "light"}.png')
                    .writeAsBytes(bytes.buffer.asUint8List());
              } finally {
                img.dispose();
              }
            });
          }
        }
        await tester.ensureVisible(find.text('Retry reading setup'));
        await tester.tap(find.text('Retry reading setup'));
        expect(retries, 1);
        await tester.ensureVisible(find.text('Open Jason'));
        await tester.tap(find.text('Open Jason'));
        expect(selected, 8);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets(
      'a failed save offers confirmed reload and cancel retains current entries',
      (tester) async {
    final h = await tester.runAsync(() => MedicalTestHarness.create());
    final repo = OnboardingRepository(h!.isar);
    await tester.runAsync(() => repo
        .saveDraft(financialDraft(flow: 'other-flow'), expectedRevision: null));
    final controller =
        FinancialSetupController(initial: financialDraft(), repository: repo);
    await controller.next();
    await controller.next();
    await tester.runAsync(controller.save);
    expect(controller.state.error, isNotNull);
    try {
      await tester.pumpWidget(ProviderScope(overrides: [
        unifiedOnboardingEnabledProvider.overrideWithValue(true),
        financialSetupProvider.overrideWith((ref) => controller)
      ], child: const MaterialApp(home: FinancialSetupScreen())));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Review saved setup'));
      await tester.tap(find.text('Review saved setup'));
      await tester.pumpAndSettle();
      expect(find.text('Review the saved version?'), findsOneWidget);
      await tester.tap(find.text('Keep entries'));
      await tester.pumpAndSettle();
      expect(controller.state.draft.flowId, 'flow-1');
      expect(controller.state.draft.sources.single.amountText, '500,000');
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(h.close);
    }
  });
}
