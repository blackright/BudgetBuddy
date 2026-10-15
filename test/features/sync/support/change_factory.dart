import 'dart:convert';

import 'package:budget_buddy/core/models/change_record.dart';
import 'package:budget_buddy/core/models/context_kind.dart';
import 'package:budget_buddy/features/sync/domain/change_signing.dart';
import 'package:cryptography/cryptography.dart';

/// A device identity plus its ed25519 keypair, for signing test changes.
class DeviceKeys {
  DeviceKeys(this.identityId, this.keyPair, this.publicKey);

  final String identityId;
  final SimpleKeyPair keyPair;
  final SimplePublicKey publicKey;

  static Future<DeviceKeys> generate(String identityId) async {
    final keyPair = await Ed25519().newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    return DeviceKeys(identityId, keyPair, publicKey);
  }
}

/// Builds a validly signed [ChangeRecord] with an explicit HLC, so a test can
/// pin ordering and prove the merge is arrival-order independent (FR-007).
Future<ChangeRecord> signedChange({
  required DeviceKeys keys,
  required String deviceId,
  required int hlcMillis,
  int hlcCounter = 0,
  String op = 'upsert',
  String payload = '',
  String entityType = 'Expense',
  int entityLocalId = 1,
  int contextLocalId = 1,
  ContextKind contextKind = ContextKind.shared,
}) async {
  final record = ChangeRecord()
    ..contextKind = contextKind
    ..contextLocalId = contextLocalId
    ..entityType = entityType
    ..entityLocalId = entityLocalId
    ..op = op
    ..payload = payload
    ..hlcMillis = hlcMillis
    ..hlcCounter = hlcCounter
    ..deviceId = deviceId
    ..authorIdentityId = keys.identityId
    ..createdAt = DateTime.fromMillisecondsSinceEpoch(hlcMillis, isUtc: true);
  final signature =
      await Ed25519().sign(changeCanonicalBytes(record), keyPair: keys.keyPair);
  record.signature = base64Encode(signature.bytes);
  return record;
}
