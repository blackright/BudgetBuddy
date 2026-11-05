import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'package:budget_buddy/features/identity/presentation/app_lock_gate.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import '../identity/support/fake_device_authenticator.dart';

void main() {
  testWidgets(
      'no-PIN content stays hidden until native success, independent of consent',
      (tester) async {
    final auth = FakeDeviceAuthenticator(allow: false);
    final c = ProviderContainer(overrides: [
      nativeAccessBindingProvider
          .overrideWithValue(const NativeAccessBinding(key: 'p1')),
      deviceAuthenticatorProvider.overrideWithValue(auth),
      lockControllerProvider.overrideWith(LockController.new)
    ]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
            home: AppLockGate(child: Text('Private balance')))));
    await tester.pumpAndSettle();
    expect(find.text('Private balance'), findsNothing);
    await tester.tap(find.byKey(const Key('unlockButton')));
    await tester.pumpAndSettle();
    expect(find.text('Private balance'), findsNothing);
    auth.allow = true;
    await tester.tap(find.byKey(const Key('unlockButton')));
    await tester.pumpAndSettle();
    expect(find.text('Private balance'), findsOneWidget);
  });
}
