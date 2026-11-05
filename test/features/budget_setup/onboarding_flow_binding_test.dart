import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/app_settings.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/features/budget_setup/providers/setup_flow_provider.dart';
import 'package:budget_buddy/features/budget_setup/repositories/onboarding_repository.dart';
import '../medical/repositories/medical_test_harness.dart';
import 'support/financial_drafts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import '../identity/support/fake_device_authenticator.dart';

void main() {
  test(
      'established no-PIN native access leaves profile, settings and identity unchanged',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    IsarHelper.instance = h.isar;
    final profile = UserProfile()
      ..name = 'Jason'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 500000
      ..createdAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
    await h.isar.writeTxn(() => h.isar.userProfiles.put(profile));
    final c = ProviderContainer(overrides: [
      deviceAuthenticatorProvider.overrideWithValue(FakeDeviceAuthenticator())
    ]);
    addTearDown(c.dispose);
    await c.read(activeProfileProvider.future);
    await c.read(activeSpaceProvider.future);
    await c.read(identityProvider.future);
    expect(c.read(nativeAccessBindingProvider).key, 'p${profile.id}');
    expect(c.read(deviceAuthSessionProvider).authenticated, isFalse);
    expect(
        await c
            .read(deviceAuthSessionProvider.notifier)
            .require(reason: 'Verify'),
        isTrue);
    final after = (await h.isar.userProfiles.get(profile.id))!;
    expect(after.monthlyAvailableAmount, 500000);
    expect(after.name, 'Jason');
    expect(after.updatedAt, profile.updatedAt);
    expect(await h.isar.appSettings.get(1), isNull);
    expect(await h.isar.lockSettings.count(), 0);
    expect(await h.isar.identitys.count(), 0);
  });

  test('real draft flow is stable on first save and closes on replacement',
      () async {
    final h = await MedicalTestHarness.create();
    addTearDown(h.close);
    IsarHelper.instance = h.isar;
    final auth = FakeDeviceAuthenticator();
    final c = ProviderContainer(
        overrides: [deviceAuthenticatorProvider.overrideWithValue(auth)]);
    addTearDown(c.dispose);
    await c.read(activeProfileProvider.future);
    await c.read(activeSpaceProvider.future);
    await c.read(identityProvider.future);
    final flow = c.read(setupFlowProvider);
    final session = c.read(deviceAuthSessionProvider.notifier);
    expect(c.read(nativeAccessBindingProvider).key, 'setup:$flow');
    expect(await session.require(reason: 'Verify'), isTrue);
    final repo = OnboardingRepository(h.isar);
    await repo.saveDraft(financialDraft(flow: flow), expectedRevision: null);
    await pumpEventQueue();
    expect(c.read(deviceAuthSessionProvider).authenticated, isTrue);
    await h.isar.writeTxn(() async {
      final settings = (await h.isar.appSettings.get(1))!;
      settings.onboardingStateJson =
          financialDraft(flow: 'replacement').encode();
      await h.isar.appSettings.put(settings);
    });
    await pumpEventQueue();
    expect(c.read(nativeAccessBindingProvider).key, 'setup:replacement');
    expect(c.read(deviceAuthSessionProvider).authenticated, isFalse);
    expect(await h.isar.identitys.count(), 0);
    expect(await h.isar.lockSettings.count(), 0);
    expect(auth.authenticateCalls, 1);
  });
}
