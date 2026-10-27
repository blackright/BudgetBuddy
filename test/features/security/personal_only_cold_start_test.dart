import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_key_session.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/security/domain/pin_result.dart';
import '../identity/support/fake_device_authenticator.dart';
import '../medical/repositories/medical_test_harness.dart';
import 'support/fake_pin_kdf.dart';

void main() {
  test(
      'real identity absence: enroll, fresh container, PIN plus phone without fake key',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    IsarHelper.instance = h.isar;
    final p = UserProfile()
      ..name = 'Jason'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await h.isar.writeTxn(() async {
      p.id = await h.isar.userProfiles.put(p);
    });
    final secrets = InMemorySecretStore();
    final auth = FakeDeviceAuthenticator();
    Future<ProviderContainer> start() async {
      final c = ProviderContainer(overrides: [
        activeProfileIdProvider.overrideWith((ref) => p.id),
        secretStoreProvider.overrideWithValue(secrets),
        pinKdfProvider.overrideWithValue(FakePinKdf()),
        deviceAuthenticatorProvider.overrideWithValue(auth)
      ]);
      await c.read(activeProfileProvider.future);
      await c.read(activeSpaceProvider.future);
      await c.read(identityProvider.future);
      await c.read(activeLockSettingProvider.future);
      return c;
    }

    var c = await start();
    await c.read(lockControllerProvider.notifier).enableLock('806247');
    c.dispose();
    c = await start();
    addTearDown(c.dispose);
    expect(c.read(lockControllerProvider).isLocked, isTrue);
    final before = auth.authenticateCalls;
    expect(await c.read(lockControllerProvider.notifier).submitPin('706248'),
        PinResult.wrongPin);
    expect(auth.authenticateCalls, before,
        reason: 'wrong PIN must not launch native authentication');
    auth.allow = false;
    expect(await c.read(lockControllerProvider.notifier).submitPin('806247'),
        PinResult.deviceRefused);
    expect(c.read(lockControllerProvider).isLocked, isTrue);
    auth.allow = true;
    expect(await c.read(lockControllerProvider.notifier).submitPin('806247'),
        PinResult.accepted);
    expect(c.read(deviceKeySessionProvider), isNull);
    expect(await h.isar.identitys.count(), 0);
  });
}
