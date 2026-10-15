import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:isar/isar.dart';

import '../../../core/models/identity.dart';
import '../domain/fingerprint.dart';
import 'device_authenticator.dart';
import 'secret_store.dart';

/// Creates the local identity and releases its private key on demand
/// (data-model §2.1, research R1, FR-001/016).
///
/// A keypair is generated on-device with ed25519; only the **public** half is
/// persisted in Isar, the private half is written to the [SecretStore] (keystore)
/// under [privateKeyStorageKey]. The username is a label bound to the key only by
/// pairing, and exactly one profile is linked via `localProfileId` (FR-016).
class IdentityService {
  IdentityService(
    this._isar,
    this._secrets, {
    required this.deviceAuth,
    Ed25519? algorithm,
  }) : _ed25519 = algorithm ?? Ed25519();

  /// Storage key the private key seed lives under (keystore only).
  static const String privateKeyStorageKey = 'identity_private_key';

  final Isar _isar;
  final SecretStore _secrets;
  final DeviceAuthenticator deviceAuth;
  final Ed25519 _ed25519;

  /// The single identity for this install, or `null` before onboarding.
  Future<Identity?> current() => _isar.identitys.where().findFirst();

  /// Generates a keypair and persists the identity (public key only).
  ///
  /// Throws [ArgumentError] for a blank username and [StateError] when an
  /// identity already exists (the one-profile invariant, FR-016).
  Future<Identity> createIdentity({
    required String username,
    required int localProfileId,
    DateTime? now,
  }) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(username, 'username', 'A username is required');
    }
    final existing = await current();
    if (existing != null) {
      throw StateError('An identity already exists on this device');
    }

    final keyPair = await _ed25519.newKeyPair();
    final privateSeed = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKey();
    await _secrets.write(privateKeyStorageKey, base64Encode(privateSeed));

    final clock = now ?? DateTime.now();
    final identity = Identity()
      ..username = trimmed
      ..publicKey = base64Encode(publicKey.bytes)
      ..keyAlgorithm = 'ed25519'
      ..localProfileId = localProfileId
      ..fingerprint = await fingerprintOf(publicKey.bytes)
      ..createdAt = clock
      ..updatedAt = clock;

    await _isar.writeTxn(() async {
      identity.id = await _isar.identitys.put(identity);
    });
    return identity;
  }

  /// Releases the private key, optionally behind a device-auth prompt.
  ///
  /// Returns `null` when device auth is required but declined, or when no key has
  /// been stored yet. The keypair is never persisted in memory beyond the caller.
  Future<SimpleKeyPair?> unlock({
    bool requireDeviceAuth = false,
    String reason = 'Unlock your identity',
  }) async {
    if (requireDeviceAuth) {
      final ok = await deviceAuth.authenticate(reason: reason);
      if (!ok) return null;
    }
    final stored = await _secrets.read(privateKeyStorageKey);
    if (stored == null) return null;
    return _ed25519.newKeyPairFromSeed(base64Decode(stored));
  }

  /// The short human-comparable fingerprint of a base64 public key (FR-004).
  Future<String> fingerprintOfPublicKey(String publicKeyBase64) =>
      fingerprintOf(base64Decode(publicKeyBase64));

  /// The short human-comparable fingerprint of raw public-key bytes.
  ///
  /// Delegates to [fingerprintOfPublicKeyBytes] so the pairing handshake and the
  /// identity service can never disagree about a peer's fingerprint (FR-004).
  Future<String> fingerprintOf(List<int> publicKeyBytes) =>
      fingerprintOfPublicKeyBytes(publicKeyBytes);

  /// Deletes the identity row and the stored private key (wipe, FR-014).
  Future<void> wipe() async {
    await _secrets.delete(privateKeyStorageKey);
    await _isar.writeTxn(() async {
      await _isar.identitys.clear();
    });
  }
}
