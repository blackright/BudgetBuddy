import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_buddy/core/database/isar_helper.dart';
import 'package:budget_buddy/core/models/app_settings.dart';
import 'package:budget_buddy/core/models/lock_setting.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/active_space_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/providers/device_auth_session.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:budget_buddy/features/security/providers/lock_providers.dart';
import 'package:budget_buddy/features/security/domain/lock_subject.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_finance.dart';
import 'package:budget_buddy/features/budget_setup/domain/onboarding_state.dart';
import 'package:budget_buddy/features/budget_setup/providers/budget_setup_provider.dart';
import 'package:budget_buddy/features/budget_setup/repositories/onboarding_repository.dart';
import '../medical/repositories/medical_test_harness.dart';
import '../identity/support/fake_device_authenticator.dart';
import '../security/support/fake_pin_kdf.dart';
import 'support/financial_drafts.dart';
import '../security/support/in_memory_lock_settings_store.dart';

import 'package:budget_buddy/features/budget_setup/presentation/widgets/security_setup_step.dart';

class _RejectEnableStore extends InMemoryLockSettingsStore {
  @override
  Future<void> upsert(LockSetting setting, {DateTime? at}) async =>
      throw StateError('simulated setting write failure');
}

final _enrollmentOwner = StateProvider<int>((ref) => 1);

class _HeldEnrollment extends FakeDeviceAuthenticator {
  final result = Completer<bool>();
  @override
  Future<bool> authenticate({required String reason}) => result.future;
}

void main() {
  test('owner switch during enrollment never saves a PIN for either owner',
      () async {
    final auth = _HeldEnrollment();
    final settings = InMemoryLockSettingsStore();
    addTearDown(settings.dispose);
    final c = ProviderContainer(overrides: [
      lockSubjectProvider.overrideWith((ref) => LockSubject.profile(
          id: ref.watch(_enrollmentOwner), name: 'Profile')),
      nativeAccessBindingProvider.overrideWith(
          (ref) => NativeAccessBinding(key: 'p${ref.watch(_enrollmentOwner)}')),
      lockSettingRepositoryProvider.overrideWithValue(settings),
      secretStoreProvider.overrideWithValue(InMemorySecretStore()),
      pinKdfProvider.overrideWithValue(FakePinKdf()),
      deviceAuthenticatorProvider.overrideWithValue(auth),
    ]);
    addTearDown(c.dispose);
    final pending =
        c.read(lockControllerProvider.notifier).enableLock('806247');
    final assertion = expectLater(pending, throwsStateError);
    await pumpEventQueue();
    c.read(_enrollmentOwner.notifier).state = 2;
    c.read(lockControllerProvider);
    c.read(deviceAuthSessionProvider);
    auth.result.complete(true);
    await assertion;
    expect(await settings.all(), isEmpty);
    expect(await c.read(pinVerifierStoreProvider).isSet('p1'), isFalse);
    expect(await c.read(pinVerifierStoreProvider).isSet('p2'), isFalse);
  });

  for (final condition in ['cancel', 'unavailable', 'interrupted']) {
    test(
        'enrollment $condition preserves actual protection and never replaces a partial PIN',
        () async {
      final settings = condition == 'interrupted'
          ? _RejectEnableStore()
          : InMemoryLockSettingsStore();
      addTearDown(settings.dispose);
      final auth = FakeDeviceAuthenticator(
          available: condition != 'unavailable', allow: condition != 'cancel');
      final c = ProviderContainer(overrides: [
        lockSubjectProvider
            .overrideWithValue(LockSubject.profile(id: 1, name: 'Jason')),
        nativeAccessBindingProvider
            .overrideWithValue(const NativeAccessBinding(key: 'p1')),
        lockSettingRepositoryProvider.overrideWithValue(settings),
        secretStoreProvider.overrideWithValue(InMemorySecretStore()),
        pinKdfProvider.overrideWithValue(FakePinKdf()),
        deviceAuthenticatorProvider.overrideWithValue(auth),
      ]);
      addTearDown(c.dispose);
      final controller = c.read(lockControllerProvider.notifier);
      await expectLater(controller.enableLock('806247'), throwsStateError);
      expect((await settings.find('p1'))?.lockEnabled ?? false, isFalse);
      final verifiers = c.read(pinVerifierStoreProvider);
      expect(await verifiers.isSet('p1'), condition == 'interrupted');
      if (condition == 'interrupted') {
        final before = auth.authenticateCalls;
        await expectLater(controller.enableLock('706248'), throwsStateError);
        expect(auth.authenticateCalls, before,
            reason: 'incomplete protection must not be silently overwritten');
        expect(await verifiers.verify('p1', '806247'), isTrue);
      }
    });
  }

  for (final mode in [
    'absent',
    'configured',
    'verifier-only',
    'setting-only',
    'unavailable'
  ]) {
    testWidgets('actual security card reconciles $mode with responsive layout',
        (tester) async {
      tester.view.physicalSize = Size(mode == 'absent' ? 780 : 640, 1800);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final previewKey = GlobalKey();
      late MedicalTestHarness h;
      late ProviderContainer c;
      late OnboardingRepository repo;
      late int owner;
      late InMemoryLockSettingsStore uiSettings;
      final auth = FakeDeviceAuthenticator(available: mode != 'unavailable')
        ..enrolled = false;
      await tester.runAsync(() async {
        final font = FontLoader('OnboardingPreview')
          ..addFont(
              rootBundle.load('assets/fonts/reports/NotoSans-Regular.ttf'));
        await font.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
        h = await MedicalTestHarness.create();
        IsarHelper.instance = h.isar;
        repo = OnboardingRepository(h.isar);
        final d =
            await repo.saveDraft(financialDraft(), expectedRevision: null);
        final review = OnboardingFinance.review(d);
        final receipt = await repo.commitCore(d,
            reviewedDigest: review.digest, expectedRevision: d.revision);
        owner = receipt.profileId;
        await repo.prepareCommittedSetup(d.flowId);
        uiSettings = InMemoryLockSettingsStore();
        final controller = FinancialSetupController(repository: repo);
        await controller.restore();
        final p = await h.isar.userProfiles.get(owner);
        c = ProviderContainer(overrides: [
          activeProfileIdProvider.overrideWith((ref) => owner),
          activeProfileProvider.overrideWith((ref) => Stream.value(p)),
          activeSpaceProvider.overrideWith((ref) => Stream.value(null)),
          nativeAccessBindingProvider
              .overrideWithValue(NativeAccessBinding(key: 'p$owner')),
          lockSettingRepositoryProvider.overrideWithValue(uiSettings),
          secretStoreProvider.overrideWithValue(InMemorySecretStore()),
          pinKdfProvider.overrideWithValue(FakePinKdf()),
          deviceAuthenticatorProvider.overrideWithValue(auth),
          financialSetupProvider.overrideWith((ref) => controller),
        ]);
        await c.read(activeProfileProvider.future);
        await c.read(activeSpaceProvider.future);
        await c.read(activeLockSettingProvider.future);
        if (mode == 'configured' || mode == 'verifier-only') {
          await c.read(pinVerifierStoreProvider).setPin('p$owner', '806247');
        }
        if (mode == 'configured' || mode == 'setting-only') {
          final row = LockSetting.forSubject(
              LockSubject.profile(id: owner, name: 'Jason'))
            ..lockEnabled = true;
          await uiSettings.upsert(row);
          await h.isar.writeTxn(() => h.isar.lockSettings.put(row));
        }
        if (mode != 'unavailable') {
          await c
              .read(deviceAuthSessionProvider.notifier)
              .require(reason: 'Verify');
        }
      });
      addTearDown(() async {
        c.dispose();
        await uiSettings.dispose();
        await h.close();
      });
      await tester.pumpWidget(UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  fontFamily: 'OnboardingPreview',
                  brightness: mode == 'configured'
                      ? Brightness.dark
                      : Brightness.light),
              home: MediaQuery(
                  data: MediaQueryData(
                      textScaler: TextScaler.linear(mode == 'absent' ? 1 : 2)),
                  child: Scaffold(
                      body: SingleChildScrollView(
                          child: RepaintBoundary(
                              key: previewKey,
                              child: SecuritySetupStep(
                                  ownerId: owner, flowId: 'flow-1'))))))));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Protection for Jason'), findsOneWidget);
      if (const bool.fromEnvironment('CAPTURE_PHASE5_PREVIEWS') &&
          (mode == 'absent' || mode == 'configured')) {
        await tester.runAsync(() async {
          final boundary = previewKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          try {
            final bytes =
                (await image.toByteData(format: ui.ImageByteFormat.png))!;
            final dir =
                Directory('specs/019-unified-onboarding/previews/phase-05');
            await dir.create(recursive: true);
            await File('${dir.path}/protection-$mode.png')
                .writeAsBytes(bytes.buffer.asUint8List());
          } finally {
            image.dispose();
          }
        });
      }

      if (mode == 'verifier-only' || mode == 'setting-only') {
        expect(find.textContaining('incomplete'), findsOneWidget);
        expect(find.text('Add app PIN'), findsNothing);
        await tester.runAsync(() async {
          expect(
              repo.recordSecurityChoice(
                  'flow-1',
                  owner,
                  OnboardingSecurityChoice.notNow,
                  c.read(pinVerifierStoreProvider).isSet),
              throwsA(isA<OnboardingCommitException>()));
        });
      } else if (mode == 'unavailable') {
        expect(find.textContaining('unavailable'), findsOneWidget);
        expect(
            tester
                .widget<FilledButton>(
                    find.widgetWithText(FilledButton, 'Add app PIN'))
                .onPressed,
            isNull);
      } else {
        expect(
            find.text(mode == 'configured'
                ? 'App PIN is configured.'
                : 'No extra app PIN is configured.'),
            findsOneWidget);
        final label = mode == 'configured'
            ? 'Keep configured protection'
            : 'Continue with phone authentication';
        await tester.ensureVisible(find.text(label));
        await tester.runAsync(() => tester.tap(find.text(label)));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final saved = (await repo.readStartupState()).state!;
          expect(
              saved.securityChoice,
              mode == 'configured'
                  ? OnboardingSecurityChoice.configured
                  : OnboardingSecurityChoice.notNow);
          final raw = (await h.isar.appSettings.get(1))!.onboardingStateJson!;
          for (final secret in [
            '806247',
            'sec_pin_',
            'test-public-key',
            'authenticated'
          ]) {
            expect(raw, isNot(contains(secret)));
          }
        });
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  test('security status distinguishes usable, partial and absent protection',
      () {
    expect(classifySetupProtection(settingEnabled: true, verifierPresent: true),
        SetupProtection.configured);
    expect(
        classifySetupProtection(settingEnabled: true, verifierPresent: false),
        SetupProtection.incomplete);
    expect(
        classifySetupProtection(settingEnabled: false, verifierPresent: true),
        SetupProtection.incomplete);
    expect(
        classifySetupProtection(settingEnabled: false, verifierPresent: false),
        SetupProtection.notConfigured);
  });
}
