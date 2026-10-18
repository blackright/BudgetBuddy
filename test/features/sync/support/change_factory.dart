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
  String entitySyncGuid = '',
  int entityLocalId = 1,
  String contextSyncGuid = '',
  int contextLocalId = 1,
  ContextKind contextKind = ContextKind.shared,
}) async {
  final resolvedEntityGuid =
      entitySyncGuid.isNotEmpty ? entitySyncGuid : syncGuidOf(payload);
  final record = ChangeRecord()
    ..contextKind = contextKind
    ..contextSyncGuid = contextSyncGuid
    ..contextLocalId = contextLocalId
    ..entityType = entityType
    ..entitySyncGuid = resolvedEntityGuid
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

/// The entity `syncGuid` carried inside a codec payload.
///
/// 015 moves device-independent identity onto the wire, so a signed change's
/// `entitySyncGuid` is simply the payload's own `syncGuid`. Tests that build a
/// payload from a model can read it back with this (and [signedChange] derives
/// `entitySyncGuid` from it automatically when left blank).
String syncGuidOf(String payload) {
  if (payload.isEmpty) return '';
  try {
    final decoded = jsonDecode(payload);
    if (decoded is Map && decoded['syncGuid'] is String) {
      return decoded['syncGuid'] as String;
    }
  } on FormatException {
    return '';
  }
  return '';
}
