import 'package:flutter/material.dart';
import 'package:budget_buddy/features/budget_setup/presentation/budget_setup_screen.dart';
import 'package:budget_buddy/features/budget_setup/providers/budget_setup_provider.dart';
import 'package:budget_buddy/features/budget_setup/providers/onboarding_rollout_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'package:budget_buddy/features/identity/presentation/app_lock_gate.dart';
import '../identity/support/fake_device_authenticator.dart';

void main() {
  testWidgets(
      'actual setup entry does not construct or restore a draft before native success',
      (tester) async {
    var reads = 0;
    final auth = FakeDeviceAuthenticator(allow: false);
    await tester.pumpWidget(ProviderScope(overrides: [
      unifiedOnboardingEnabledProvider.overrideWithValue(true),
      nativeAccessBindingProvider
          .overrideWithValue(const NativeAccessBinding(key: 'setup:flow')),
      deviceAuthenticatorProvider.overrideWithValue(auth),
      financialSetupProvider.overrideWith((ref) {
        reads++;
        return FinancialSetupController();
      }),
    ], child: const MaterialApp(home: BudgetSetupScreen())));
    await tester.pumpAndSettle();
    expect(reads, 0);
    await tester.tap(find.byKey(const Key('unlockButton')));
    await tester.pumpAndSettle();
    expect(reads, 0);
    auth.allow = true;
    await tester.tap(find.byKey(const Key('unlockButton')));
    await tester.pumpAndSettle();
    expect(reads, 1);
    expect(find.text('Personal setup'), findsOneWidget);
  });

  testWidgets(
      'pre-profile sensitive draft is never built before authentication',
      (tester) async {
    var built = 0;
    final auth = FakeDeviceAuthenticator();
    await tester.pumpWidget(ProviderScope(
        overrides: [
          nativeAccessBindingProvider
              .overrideWithValue(const NativeAccessBinding(key: 'setup:flow1')),
          deviceAuthenticatorProvider.overrideWithValue(auth)
        ],
        child: MaterialApp(home: AppLockGate(child: Builder(builder: (context) {
          built++;
          return const Text('Saved income draft');
        })))));
    await tester.pumpAndSettle();
    expect(built, 0);
    await tester.tap(find.byKey(const Key('unlockButton')));
    await tester.pumpAndSettle();
    expect(built, 1);
  });
}
