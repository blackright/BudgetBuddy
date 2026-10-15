import 'dart:convert';

import 'package:budget_buddy/core/models/consent_record.dart';
import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:budget_buddy/features/identity/repositories/identity_service.dart';
import 'package:budget_buddy/features/identity/repositories/secret_store.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

import '../sync/support/sync_harness.dart';
import 'support/fake_device_authenticator.dart';

/// T024 (US1, FR-001/016, SC-008): creating an identity generates a device-only
/// ed25519 keypair, persists only the **public** half in Isar, keeps the private
/// half exclusively in the secret store, and links exactly one personal profile.
/// The whole flow is local — there is no transport seam anywhere on the path.
void main() {
  late SyncTestHarness harness;
  late InMemorySecretStore store;
  late FakeDeviceAuthenticator auth;
  late IdentityService service;
  late int profileId;

  setUp(() async {
    harness = await SyncTestHarness.create();
    store = InMemorySecretStore();
    auth = FakeDeviceAuthenticator();
    service = IdentityService(harness.isar, store, deviceAuth: auth);
    profileId = await harness.isar.writeTxn(() async {
      final profile = UserProfile()
        ..name = 'Ava'
        ..primaryCurrency = PrimaryCurrency.huf
        ..monthlyAvailableAmount = 0
        ..createdAt = DateTime(2026)
        ..updatedAt = DateTime(2026);
      return harness.isar.userProfiles.put(profile);
    });
  });

  tearDown(() async => harness.close());

  test('generates an ed25519 keypair and stores only the public half in Isar',
      () async {
    final identity = await service.createIdentity(
      username: 'Ava',
      localProfileId: profileId,
      now: DateTime(2026, 1, 1),
    );

    // Public half: a 32-byte ed25519 key, base64-encoded in the row.
    expect(identity.username, 'Ava');
    expect(identity.keyAlgorithm, 'ed25519');
    expect(base64Decode(identity.publicKey), hasLength(32));

    // The row that landed in Isar carries no secret of any kind.
    final persisted = await service.current();
    expect(persisted, isNotNull);
    expect(persisted!.publicKey, identity.publicKey);
    expect(persisted.localProfileId, profileId);

    // Private half: only in the secure store, a 32-byte ed25519 seed.
    final storedSeed = await store.read(IdentityService.privateKeyStorageKey);
    expect(storedSeed, isNotNull);
    expect(base64Decode(storedSeed!), hasLength(32));
  });

  test('links exactly one profile and refuses a second identity (FR-016)',
      () async {
    final identity = await service.createIdentity(
      username: 'Ava',
      localProfileId: profileId,
    );
    expect(identity.localProfileId, profileId);
    expect(await harness.isar.identitys.count(), 1);

    // A second identity is refused; the unique localProfileId index makes even a
    // different-profile second identity a non-starter while one already exists.
    await expectLater(
      service.createIdentity(username: 'Other', localProfileId: profileId + 1),
      throwsA(isA<StateError>()),
    );
    expect(await harness.isar.identitys.count(), 1);
  });

  test('stays entirely local: one Isar row and one secret, nothing else',
      () async {
    // SC-008: no financial data leaves the device and no server is contacted.
    // The only durable effects of creating an identity are one Isar identity row
    // and one keystore entry — there is no transport on this path at all.
    expect(harness.transport.advertisements(), isEmpty);
    final rowsBefore = await harness.isar.identitys.count();

    await service.createIdentity(username: 'Ava', localProfileId: profileId);

    expect(await harness.isar.identitys.count(), rowsBefore + 1);
    expect(store.read(IdentityService.privateKeyStorageKey), completes);
    expect(await harness.isar.consentRecords.count(), 0,
        reason: 'identity creation never records consent on its own');
  });

  test('the fingerprint is the short hash of the public key (FR-004)',
      () async {
    final identity = await service.createIdentity(
      username: 'Ava',
      localProfileId: profileId,
    );

    expect(identity.fingerprint, hasLength(16));
    expect(
      identity.fingerprint,
      await service.fingerprintOfPublicKey(identity.publicKey),
    );
  });

  test(
      'unlock releases a keypair that signs verifiably with the stored key '
      '(key access, FR-002)', () async {
    final identity = await service.createIdentity(
      username: 'Ava',
      localProfileId: profileId,
    );

    final keyPair = await service.unlock();
    expect(keyPair, isNotNull);

    final message = utf8.encode('prove-it');
    final signature = await Ed25519().sign(message, keyPair: keyPair!);
    // Rebuild the signature around the *stored* public key: verifying then only
    // succeeds if the released private half truly matches what we persisted.
    final valid = await Ed25519().verify(
      message,
      signature: Signature(
        signature.bytes,
        publicKey: SimplePublicKey(
          base64Decode(identity.publicKey),
          type: KeyPairType.ed25519,
        ),
      ),
    );
    expect(valid, isTrue);

    // No stored key yet → no keypair to release.
    final emptyStore = InMemorySecretStore();
    final emptyService =
        IdentityService(harness.isar, emptyStore, deviceAuth: auth);
    expect(await emptyService.unlock(), isNull);
  });

  test(
      'device-auth gating: a decline withholds the key, a grant releases it '
      '(FR-002)', () async {
    await service.createIdentity(username: 'Ava', localProfileId: profileId);

    auth.allow = false;
    expect(
      await service.unlock(requireDeviceAuth: true),
      isNull,
      reason: 'declining device auth must not release the private key',
    );
    expect(auth.authenticateCalls, 1);

    auth.allow = true;
    expect(
      await service.unlock(requireDeviceAuth: true, reason: 'Unlock identity'),
      isNotNull,
    );
    expect(auth.authenticateCalls, 2);
    expect(auth.reasons.last, 'Unlock identity');
  });

  test('wipe deletes the identity row and the stored private key (FR-014)',
      () async {
    await service.createIdentity(username: 'Ava', localProfileId: profileId);

    await service.wipe();

    expect(await service.current(), isNull);
    expect(await harness.isar.identitys.count(), 0);
    expect(await store.read(IdentityService.privateKeyStorageKey), isNull);
  });
}
