import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/app_settings.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/models/category.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/expense.dart';
import 'package:budget_buddy/core/models/audit_event.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/shared_space.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/selected_month_provider.dart';
import 'package:budget_buddy/core/routing/app_router.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/budget_setup/providers/onboarding_readiness_provider.dart';
import 'package:budget_buddy/features/budget_setup/providers/budget_setup_provider.dart';
import 'package:budget_buddy/features/identity/presentation/app_lock_gate.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import '../medical/repositories/medical_test_harness.dart';
import '../identity/support/fake_device_authenticator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/features/budget_setup/presentation/introduction_screen.dart';

void main() {
  for (final shared in [false, true]) {
    testWidgets(
        'replay shared=$shared preserves database and selected context with rollout off',
        (tester) async {
      late MedicalTestHarness h;
      late String before;
      Future<String> snapshot() async {
        final result = <String, Object?>{};
        for (final collection in <IsarCollection<dynamic>>[
          h.isar.userProfiles,
          h.isar.monthlyBudgets,
          h.isar.incomeSources,
          h.isar.categorys,
          h.isar.appSettings,
          h.isar.auditEvents,
          h.isar.expenses,
          h.isar.identitys,
          h.isar.lockSettings,
          h.isar.changeRecords,
          h.isar.sharedSpaces,
          h.isar.schemaMigrationStamps
        ]) {
          result[collection.name] =
              await collection.buildQuery<dynamic>().exportJson();
        }
        return jsonEncode(result);
      }

      await tester.runAsync(() async {
        h = await MedicalTestHarness.create();
        IsarHelper.instance = h.isar;
        await h.isar.writeTxn(() async {
          await h.isar.userProfiles.put(UserProfile()
            ..id = 7
            ..name = 'Jason'
            ..primaryCurrency = PrimaryCurrency.huf
            ..monthlyAvailableAmount = 100000
            ..createdAt = DateTime(2026)
            ..updatedAt = DateTime(2026));
          await h.isar.appSettings.put(AppSettings()
            ..id = 1
            ..transferToggle = true
            ..onboardingStateJson = '{retained unreadable evidence'
            ..createdAt = DateTime(2026)
            ..updatedAt = DateTime(2026));
        });
        before = await snapshot();
      });
      final c = ProviderContainer(overrides: [
        activeProfileIdProvider.overrideWith((ref) => 7),
        activeSpaceIdProvider.overrideWith((ref) => shared ? 44 : null),
        selectedYearMonthProvider.overrideWith((ref) => '2025-01'),
        onboardingRepositoryProvider.overrideWith((ref) =>
            throw StateError('Replay must not construct its repository')),
        financialSetupProvider.overrideWith((ref) =>
            throw StateError('Replay must not construct financial setup')),
      ]);
      final router = createAppRouter(
          initialLocation: '/setup',
          setupBuilder: (context) => TextButton(
              onPressed: () => context.push('/introduction'),
              child: const Text('Caller')));
      await tester.pumpWidget(UncontrolledProviderScope(
          container: c, child: MaterialApp.router(routerConfig: router)));
      await tester.pumpAndSettle();
      for (var visit = 0; visit < 2; visit++) {
        await tester.tap(find.text('Caller'));
        await tester.pumpAndSettle();
        expect(find.text('Read-only introduction'), findsOneWidget);
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Opening money and income'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Close introduction'));
        await tester.pumpAndSettle();
        expect(find.text('Caller'), findsOneWidget);
      }
      expect(c.read(activeProfileIdProvider), 7);
      expect(c.read(activeSpaceIdProvider), shared ? 44 : null);
      expect(c.read(selectedYearMonthProvider), '2025-01');
      await tester.runAsync(() async {
        expect(await snapshot(), before);
      });
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      c.dispose();
      await tester.runAsync(h.close);
    });
  }
  testWidgets('existing gate requires native success before replay',
      (tester) async {
    final auth = FakeDeviceAuthenticator(allow: false);
    final c = ProviderContainer(overrides: [
      nativeAccessBindingProvider
          .overrideWithValue(const NativeAccessBinding(key: 'p7')),
      deviceAuthenticatorProvider.overrideWithValue(auth),
      lockResolutionPendingProvider.overrideWithValue(false),
      lockSubjectProvider.overrideWithValue(null)
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child:
            const MaterialApp(home: AppLockGate(child: IntroductionScreen()))));
    await tester.pumpAndSettle();
    expect(find.text('Read-only introduction'), findsNothing);
    await tester.tap(find.byKey(const Key('unlockButton')));
    await tester.pumpAndSettle();
    expect(find.text('Read-only introduction'), findsNothing);
    auth.allow = true;
    await tester.tap(find.byKey(const Key('unlockButton')));
    await tester.pumpAndSettle();
    expect(find.text('Read-only introduction'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    c.dispose();
  });
  testWidgets(
      'direct replay link returns to Settings without changing its owner',
      (tester) async {
    final router = GoRouter(initialLocation: '/introduction', routes: [
      GoRoute(
          path: '/introduction',
          builder: (_, __) => const IntroductionScreen()),
      GoRoute(
          path: '/settings',
          builder: (_, __) => const Text('Settings destination'))
    ]);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Close introduction'));
    await tester.pumpAndSettle();
    expect(find.text('Settings destination'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });

  testWidgets(
      'three replay chapters have no setup forms and Done returns to caller',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                            builder: (_) => const IntroductionScreen())),
                    child: const Text('Open replay'))))));
    await tester.tap(find.text('Open replay'));
    await tester.pumpAndSettle();
    expect(find.text('Chapter 1 of 3'), findsOneWidget);
    expect(find.text('Read-only introduction'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Chapter 2 of 3'), findsOneWidget);
    await tester.tap(find.text('Opening money and income'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Example'), findsWidgets);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Chapter 3 of 3'), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Chapter 2 of 3'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Open replay'), findsOneWidget);
  });
}
