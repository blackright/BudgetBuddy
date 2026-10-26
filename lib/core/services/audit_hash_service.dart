import 'dart:convert';

import 'package:crypto/crypto.dart';
import '../../features/sync/domain/sync_codec.dart';

/// Computes a hash for an [AuditEvent] chain entry.
///
/// The hash covers [previousHash] plus a canonical serialization of the event
/// fields, so any change to a stored event breaks the chain.
class AuditHashService {
  const AuditHashService();

  /// New evidence includes stable ownership, object/author/device identity and
  /// chain sequence. JSON escaping avoids legacy delimiter ambiguities.
  String canonicalEvidence(Map<String, Object?> evidence) =>
      canonicalJsonEncode(evidence);

  String computeHash({
    required String previousHash,
    required String canonical,
  }) {
    final bytes = utf8.encode('$previousHash|$canonical');
    return sha256.convert(bytes).toString();
  }

  /// Legacy serializer retained for compatibility; never used to bless older
  /// incomplete records or to author the new versioned chains.
  String canonical({
    required DateTime timestamp,
    required String userIdentity,
    required String action,
    required String objectType,
    int? objectId,
    String? previousValue,
    String? newValue,
  }) {
    return [
      timestamp.toUtc().toIso8601String(),
      userIdentity,
      action,
      objectType,
      objectId?.toString() ?? '',
      previousValue ?? '',
      newValue ?? '',
    ].join('\u001f');
  }
}
