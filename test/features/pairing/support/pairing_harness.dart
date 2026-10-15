import 'dart:convert';

import 'package:budget_buddy/core/models/identity.dart';
import 'package:budget_buddy/core/models/shared_member.dart';
import 'package:budget_buddy/features/identity/domain/fingerprint.dart';
import 'package:budget_buddy/features/pairing/domain/pairing_protocol.dart';
import 'package:budget_buddy/features/pairing/repositories/pairing_service.dart';
import 'package:budget_buddy/features/sync/domain/hlc.dart';
import 'package:budget_buddy/features/sync/repositories/change_signer.dart';

import '../../sync/support/change_factory.dart';
import '../../sync/support/sync_harness.dart';

/// An Isar harness with a local identity and a wired [PairingService], so a
/// pairing test can act as the presenting Owner with a real signing key.
class PairingTestHarness {
  PairingTestHarness._(this.sync, this.keys, this.identity, this.service);

  final SyncTestHarness sync;
  final DeviceKeys keys;
  final Identity identity;
  final PairingService service;

  /// Fixed wall clock so HLC/version and timestamps are reproducible.
  static DateTime get _clock => DateTime.utc(2026, 3, 5, 12);

  static Future<PairingTestHarness> create({String username = 'Alice'}) async {
    final sync = await SyncTestHarness.create();
    final keys = await DeviceKeys.generate('__presenter__');
    final fingerprint = await fingerprintOfPublicKeyBytes(keys.publicKey.bytes);
    final identity = Identity()
      ..username = username
      ..publicKey = base64Encode(keys.publicKey.bytes)
      ..keyAlgorithm = 'ed25519'
      ..localProfileId = 1
      ..fingerprint = fingerprint
      ..createdAt = _clock
      ..updatedAt = _clock;
    identity.id =
        await sync.isar.writeTxn(() => sync.isar.identitys.put(identity));

    final service = PairingService(
      sync.isar,
      identity: identity,
      signer: Ed25519ChangeSigner(
        authorIdentityId: fingerprint,
        keyPair: keys.keyPair,
      ),
      clock: HlcClock(deviceId: 'devA'),
      wallClock: () => _clock,
    );
    return PairingTestHarness._(sync, keys, identity, service);
  }

  /// Creates a space owned by this device's profile, returning its id.
  Future<int> ownSpace({SharedMemberRole role = SharedMemberRole.owner}) async {
    final spaceId = await sync.createSpace(createdByProfileId: 1);
    await sync.addMember(spaceId: spaceId, profileId: 1, role: role);
    return spaceId;
  }

  Future<void> close() => sync.close();
}

/// Builds the claim a remote scanner would send (its own fresh keypair).
Future<PairingClaim> scannerClaim(
  String token, {
  DeviceKeys? scanner,
  String username = 'Bob',
}) async {
  final keys = scanner ?? await DeviceKeys.generate('__scanner__');
  final fingerprint = await fingerprintOfPublicKeyBytes(keys.publicKey.bytes);
  return PairingClaim(
    token: token,
    scannerIdentityId: fingerprint,
    scannerPublicKey: base64Encode(keys.publicKey.bytes),
    scannerUsername: username,
  );
}

/// The fingerprint helper re-exported for tests that assert on a claim's id.
Future<String> fingerprintOfKey(DeviceKeys keys) =>
    fingerprintOfPublicKeyBytes(keys.publicKey.bytes);
