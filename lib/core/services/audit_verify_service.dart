import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import '../models/audit_event.dart';
import '../../features/sync/domain/sync_codec.dart';
import 'audit_hash_service.dart';

enum AuditStatus { verified, legacy, incomplete, failed }

class AuditVerification {
  const AuditVerification(this.status, this.message, this.checked);
  final AuditStatus status;
  final String message;
  final int checked;
}

/// Verifies a complete context snapshot, never just a filtered UI page.
class AuditVerifyService {
  const AuditVerifyService();
  Future<AuditVerification> verify(List<AuditEvent> rows,
      {Map<String, SimplePublicKey> trustedKeys = const {},
      Map<String, String> expectedHeads = const {},
      String? expectedContext}) async {
    var legacy = false, incomplete = false;
    final seen = <String>{};
    final chains = <String, List<(AuditEvent, Map<String, Object?>)>>{};
    try {
      for (final row in rows) {
        if (row.evidenceJson == null) {
          legacy = true;
          continue;
        }
        if (!seen.add(row.syncGuid)) {
          return AuditVerification(AuditStatus.failed,
              'Duplicate audit identity detected.', rows.length);
        }
        final data = canonicalJsonDecode(row.evidenceJson!);
        if ((expectedContext != null &&
                row.contextSyncGuid != expectedContext) ||
            data['shared'] != (row.sharedSpaceId != null) ||
            (row.sharedSpaceId == null &&
                row.contextSyncGuid != 'personal:${row.profileId}') ||
            data['version'] != 1 ||
            data['id'] != row.syncGuid ||
            data['context'] != row.contextSyncGuid ||
            data['timestamp'] != row.timestamp.toUtc().toIso8601String() ||
            data['author'] != row.userIdentity ||
            data['action'] != row.action ||
            data['objectType'] != row.objectType ||
            canonicalJsonEncode(data['before']) !=
                (row.previousValue ?? 'null') ||
            canonicalJsonEncode(data['after']) != (row.newValue ?? 'null') ||
            data['previousHash'] != row.previousHash ||
            data['sequence'] is! int ||
            ((data['sequence'] as int) < 1 ||
                (data['sequence'] as int) > 9007199254740991) ||
            data['chain'] is! String ||
            data['device'] is! String ||
            data['object'] is! String ||
            data['chain'] !=
                canonicalJsonEncode([
                  data['shared'],
                  data['context'],
                  data['author'],
                  data['device']
                ])) {
          return AuditVerification(AuditStatus.failed,
              'Audit fields do not match their evidence.', rows.length);
        }
        final hash = const AuditHashService().computeHash(
            previousHash: row.previousHash,
            canonical: const AuditHashService().canonicalEvidence(data));
        if (hash != row.hash) {
          return AuditVerification(
              AuditStatus.failed, 'An audit hash does not match.', rows.length);
        }
        if (data['shared'] == true) {
          final key = trustedKeys[row.userIdentity];
          if (key == null) {
            incomplete = true;
          } else if (row.signature == null ||
              !await Ed25519().verify(utf8.encode(row.hash),
                  signature: Signature(base64Decode(row.signature!),
                      publicKey: key))) {
            return AuditVerification(AuditStatus.failed,
                'An audit signature is invalid.', rows.length);
          }
        }
        chains.putIfAbsent(data['chain'] as String, () => []).add((row, data));
      }
      for (final chain in chains.entries) {
        chain.value.sort((a, b) =>
            (a.$2['sequence'] as int).compareTo(b.$2['sequence'] as int));
        var sequence = 0;
        var previous = '';
        for (final (row, data) in chain.value) {
          final next = data['sequence'] as int;
          if (next <= sequence) {
            return AuditVerification(AuditStatus.failed,
                'Conflicting audit sequence detected.', rows.length);
          }
          if (next != sequence + 1) {
            incomplete = true;
          } else if (row.previousHash != previous) {
            return AuditVerification(AuditStatus.failed,
                'An audit link does not match.', rows.length);
          }
          sequence = next;
          previous = row.hash;
        }
        if (expectedHeads[chain.key] != null &&
            expectedHeads[chain.key] != previous) {
          incomplete = true;
        }
      }
      if (expectedHeads.keys.any((key) => !chains.containsKey(key))) {
        incomplete = true;
      }
      return AuditVerification(
          incomplete
              ? AuditStatus.incomplete
              : legacy
                  ? AuditStatus.legacy
                  : AuditStatus.verified,
          incomplete
              ? 'History incomplete: missing records or trusted keys.'
              : legacy
                  ? 'Legacy records present. New records were checked.'
                  : rows.isEmpty
                      ? 'No audit records yet.'
                      : 'Verified for this snapshot.',
          rows.length);
    } catch (_) {
      return AuditVerification(
          AuditStatus.failed, 'Audit evidence is malformed.', rows.length);
    }
  }
}
