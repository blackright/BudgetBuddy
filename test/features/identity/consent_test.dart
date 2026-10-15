import 'package:budget_buddy/core/models/consent_record.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/providers/active_profile_provider.dart';
import 'package:budget_buddy/core/providers/identity_provider.dart';
import 'package:budget_buddy/features/identity/presentation/identity_onboarding_screen.dart';
import 'package:budget_buddy/features/identity/repositories/consent_service.dart';
import 'package:budget_buddy/features/identity/repositories/device_authenticator.dart';
import 'package:budget_buddy/features/identity/repositories/identity_service.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../sync/support/sync_harness.dart';
import 'support/fake_device_authenticator.dart';

/// T025 (US1, FR-002): consent is local and revocable; declining keeps the app
/// usable with a clear warning; the onboarding screen surfaces that warning and
/// records the user's choice. The device's own authentication is only ever a
/// gate the service asks — never a PIN the app stores.
void main() {
  group('ConsentService (local, revocable)', () {
    late SyncTestHarness harness;
    late ConsentService consent;

    setUp(() async {
      harness = await SyncTestHarness.create();
      consent = ConsentService(harness.isar);
    });

    tearDown(() async => harness.close());

    test('starts with no recorded decision', () async {
      expect(await consent.current(), isNull);
      expect(await consent.hasCurrentConsent(), isFalse);
    });

    test('records a grant against the current notice version', () async {
      final record = await consent.record(
        noticeVersion: kConsentNoticeVersion,
        deviceAuthGranted: true,
        now: DateTime(2026, 1, 1),
      );

      expect(record.deviceAuthGranted, isTrue);
      expect(record.noticeVersion, kConsentNoticeVersion);
      expect(await consent.current(), isNotNull);
      expect(await consent.hasCurrentConsent(), isTrue);
      expect(await harness.isar.consentRecords.count(), 1);
    });

    test('declining is a legitimate, kept choice (app stays usable)', () async {
      final record = await consent.record(
        noticeVersion: kConsentNoticeVersion,
        deviceAuthGranted: false,
      );

      expect(record.deviceAuthGranted, isFalse);
      expect(await consent.hasCurrentConsent(), isTrue,
          reason: 'a decline still counts as having answered the notice');
    });

    test('revoke flips the grant off and just rewrites the single row',
        () async {
      await consent.record(
        noticeVersion: kConsentNoticeVersion,
        deviceAuthGranted: true,
        now: DateTime(2026, 1, 1),
      );

      final revoked = await consent.revoke(now: DateTime(2026, 2, 1));

      expect(revoked.deviceAuthGranted, isFalse);
      expect(revoked.updatedAt, DateTime(2026, 2, 1));
      expect(await harness.isar.consentRecords.count(), 1,
          reason: 'revocation updates the one row, never adds another');
    });

    test('a newer notice version is re-asked', () async {
      await consent.record(
        noticeVersion: '0',
        deviceAuthGranted: true,
      );
      expect(await consent.hasCurrentConsent(), isFalse,
          reason: 'an old notice version is not current consent');

      await consent.record(
        noticeVersion: kConsentNoticeVersion,
        deviceAuthGranted: true,
      );
      expect(await consent.hasCurrentConsent(), isTrue);
    });
  });

  group('IdentityOnboardingScreen (US1 UI)', () {
    testWidgets('warns when device auth is off and records the choice',
        (tester) async {
      final identityService = _RecordingIdentityService();
      final consentService = _RecordingConsentService();
      final auth = FakeDeviceAuthenticator();

      final container = ProviderContainer(
        overrides: [
          identityServiceProvider.overrideWithValue(identityService),
          consentServiceProvider.overrideWithValue(consentService),
          deviceAuthenticatorProvider.overrideWithValue(auth),
          actingProfileIdProvider.overrideWithValue(42),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_Host(container: container));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // The voluntary consent notice is shown, and the warning is visible while
      // device auth is off.
      expect(find.byKey(const Key('consentNotice')), findsOneWidget);
      expect(find.byKey(const Key('deviceAuthWarning')), findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('identityUsernameField')), 'Ava');
      await tester.pumpAndSettle();

      // Turn device auth ON: the warning must disappear and the phone prompted.
      await tester.tap(find.byKey(const Key('deviceAuthToggle')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('deviceAuthWarning')), findsNothing);
      expect(auth.authenticateCalls, 1);

      await tester.tap(find.byKey(const Key('createIdentityButton')));
      await tester.pumpAndSettle();

      // The identity was created for the active profile and consent recorded.
      expect(identityService.createdUsername, 'Ava');
      expect(identityService.createdProfileId, 42);
      expect(consentService.granted, isTrue);
      expect(consentService.version, kConsentNoticeVersion);

      // The screen popped back to the host.
      expect(find.byKey(const Key('createIdentityButton')), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('declining keeps the app usable and records a decline',
        (tester) async {
      final identityService = _RecordingIdentityService();
      final consentService = _RecordingConsentService();

      final container = ProviderContainer(
        overrides: [
          identityServiceProvider.overrideWithValue(identityService),
          consentServiceProvider.overrideWithValue(consentService),
          deviceAuthenticatorProvider
              .overrideWithValue(FakeDeviceAuthenticator()),
          actingProfileIdProvider.overrideWithValue(7),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_Host(container: container));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('identityUsernameField')), 'Bea');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('createIdentityButton')));
      await tester.pumpAndSettle();

      expect(identityService.createdUsername, 'Bea');
      expect(consentService.granted, isFalse);
      expect(find.text('open'), findsOneWidget);
    });
  });
}

/// A tiny host so the onboarding screen can be pushed and popped like in-app.
class _Host extends StatelessWidget {
  const _Host({required this.container});

  final ProviderContainer container;

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const IdentityOnboardingScreen(),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Records what the onboarding screen asked for, without touching Isar — the
/// real service is exercised by the identity-creation test above.
class _RecordingIdentityService implements IdentityService {
  String? createdUsername;
  int? createdProfileId;
  bool fail = false;

  @override
  DeviceAuthenticator deviceAuth = FakeDeviceAuthenticator();

  @override
  Future<Identity?> current() async => null;

  @override
  Future<Identity> createIdentity({
    required String username,
    required int localProfileId,
    DateTime? now,
  }) async {
    if (fail) throw StateError('An identity already exists on this device');
    createdUsername = username;
    createdProfileId = localProfileId;
    return Identity()
      ..username = username
      ..localProfileId = localProfileId
      ..fingerprint = '0123456789abcdef';
  }

  @override
  Future<SimpleKeyPair?> unlock({
    bool requireDeviceAuth = false,
    String reason = 'Unlock your identity',
  }) async =>
      null;

  @override
  Future<String> fingerprintOfPublicKey(String publicKeyBase64) async => 'x';

  @override
  Future<String> fingerprintOf(List<int> publicKeyBytes) async => 'x';

  @override
  Future<void> wipe() async {}
}

class _RecordingConsentService implements ConsentService {
  bool? granted;
  String? version;

  @override
  Future<ConsentRecord?> current() async => null;

  @override
  Future<bool> hasCurrentConsent() async => false;

  @override
  Future<ConsentRecord> record({
    required String noticeVersion,
    required bool deviceAuthGranted,
    DateTime? now,
  }) async {
    version = noticeVersion;
    granted = deviceAuthGranted;
    return ConsentRecord()
      ..noticeVersion = noticeVersion
      ..deviceAuthGranted = deviceAuthGranted
      ..decidedAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
  }

  @override
  Future<ConsentRecord> revoke({DateTime? now}) async {
    granted = false;
    return ConsentRecord()
      ..deviceAuthGranted = false
      ..decidedAt = DateTime(2026)
      ..updatedAt = DateTime(2026);
  }
}
