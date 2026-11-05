import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/security/domain/lock_state.dart'
    as security;
import 'package:budget_buddy/features/security/presentation/lock_screen.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:budget_buddy/main.dart';
import 'package:budget_buddy/core/database/money_integrity.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/database_integrity_provider.dart';
import 'package:budget_buddy/core/routing/router_providers.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_startup.dart';
import 'package:budget_buddy/features/budget_setup/presentation/introduction_screen.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/shared/presentation/branding/branded_startup.dart';
import '../../features/identity/support/fake_device_authenticator.dart';

class _HeldPin extends LockController {
  @override
  LockSnapshot build() => LockSnapshot(
      subject: LockSubject.profile(id: 7, name: 'Jason'),
      state: security.LockState.locked);
}

void main() {
  testWidgets(
      'configured app PIN still gates an otherwise native-authenticated destination',
      (tester) async {
    final auth = FakeDeviceAuthenticator();
    final router = GoRouter(routes: [
      GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('Private Dashboard')))
    ]);
    final c = ProviderContainer(overrides: [
      moneyIntegrityIssuesProvider.overrideWith((ref) async => []),
      routerProvider.overrideWithValue(router),
      activeProfileProvider
          .overrideWith((ref) => Stream<UserProfile?>.value(null)),
      nativeAccessBindingProvider
          .overrideWithValue(const NativeAccessBinding(key: 'p7')),
      deviceAuthenticatorProvider.overrideWithValue(auth),
      lockResolutionPendingProvider.overrideWithValue(false),
      lockSubjectProvider.overrideWithValue(null),
      lockControllerProvider.overrideWith(_HeldPin.new),
    ]);
    await c
        .read(deviceAuthSessionProvider.notifier)
        .require(reason: 'Test native factor');
    await tester.pumpWidget(UncontrolledProviderScope(
        container: c, child: MyApp(startupSession: StartupBrandSession())));
    await tester.pumpAndSettle();
    expect(find.byType(LockScreen), findsOneWidget);
    expect(find.text('Private Dashboard'), findsNothing);
    expect(find.byType(BrandedStartup), findsNothing);
    await tester.pumpWidget(const SizedBox());
    c.dispose();
    router.dispose();
  });

  for (final kind in StartupKind.values) {
    testWidgets(
        'actual app safety gate hands off immediately to guarded $kind; replay stays static',
        (tester) async {
      final pending = Completer<List<MoneyIntegrityIssue>>();
      final auth = FakeDeviceAuthenticator(allow: false);
      final startup = OnboardingStartup(kind);
      final router = GoRouter(
          initialLocation: '/dashboard',
          redirect: (_, state) => onboardingRedirect(startup, state.uri.path),
          routes: [
            GoRoute(
                path: '/dashboard',
                builder: (_, __) =>
                    const Scaffold(body: Text('Private Dashboard'))),
            GoRoute(
                path: '/setup',
                builder: (_, __) =>
                    const Scaffold(body: Text('Safe setup destination'))),
            GoRoute(
                path: '/introduction',
                builder: (_, __) => const IntroductionScreen()),
          ]);
      final c = ProviderContainer(overrides: [
        moneyIntegrityIssuesProvider.overrideWith((ref) => pending.future),
        routerProvider.overrideWithValue(router),
        activeProfileProvider
            .overrideWith((ref) => Stream<UserProfile?>.value(null)),
        nativeAccessBindingProvider
            .overrideWithValue(const NativeAccessBinding(key: 'p7')),
        deviceAuthenticatorProvider.overrideWithValue(auth),
        lockResolutionPendingProvider.overrideWithValue(false),
        lockSubjectProvider.overrideWithValue(null),
      ]);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: c, child: MyApp(startupSession: StartupBrandSession())));
      await tester.pump();
      expect(find.byType(BrandedStartup), findsOneWidget);
      expect(find.text('Private Dashboard'), findsNothing);
      pending.complete([]);
      await tester.pumpAndSettle();
      expect(find.byType(BrandedStartup), findsNothing);
      expect(find.text('Private Dashboard'), findsNothing);
      expect(find.text('Safe setup destination'), findsNothing);
      await tester.tap(find.byKey(const Key('unlockButton')));
      await tester.pumpAndSettle();
      expect(find.text('Private Dashboard'), findsNothing);
      expect(find.text('Safe setup destination'), findsNothing);
      auth.allow = true;
      await tester.tap(find.byKey(const Key('unlockButton')));
      await tester.pumpAndSettle();
      expect(
          find.text(kind == StartupKind.establishedUser
              ? 'Private Dashboard'
              : 'Safe setup destination'),
          findsOneWidget);
      // Read-only replay uses its ordinary route, never the startup decorator.
      if (kind == StartupKind.establishedUser) {
        router.push('/introduction');
        await tester.pumpAndSettle();
        expect(find.text('Read-only introduction'), findsOneWidget);
        expect(find.byType(BrandedStartup), findsNothing);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        tester.binding
            .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        await tester.pumpAndSettle();
        expect(find.byType(BrandedStartup), findsNothing);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      c.dispose();
      router.dispose();
    });
  }
  testWidgets(
      'integrity failure bypasses decoration and never builds private content',
      (tester) async {
    final c = ProviderContainer(overrides: [
      moneyIntegrityIssuesProvider.overrideWith((ref) async => [
            const MoneyIntegrityIssue(
                collection: 'expenses',
                rowId: 1,
                field: 'amount',
                value: corruptedMinorSentinel)
          ])
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: c, child: MyApp(startupSession: StartupBrandSession())));
    await tester.pumpAndSettle();
    expect(find.text('Your saved data needs a reset'), findsOneWidget);
    expect(find.byType(BrandedStartup), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    c.dispose();
  });
  testWidgets('safety-read error shows static branding and actionable retry',
      (tester) async {
    final c = ProviderContainer(overrides: [
      moneyIntegrityIssuesProvider
          .overrideWith((ref) async => throw StateError('injected safety read'))
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: c, child: MyApp(startupSession: StartupBrandSession())));
    await tester.pumpAndSettle();
    expect(find.text('Unable to check saved data'), findsOneWidget);
    await tester.ensureVisible(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Retry').hitTestable(), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('Private Dashboard'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    c.dispose();
  });
}
