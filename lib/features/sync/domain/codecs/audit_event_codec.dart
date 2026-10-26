import '../../../../core/models/audit_event.dart';
import '../sync_codec.dart';

/// Only original signed shared evidence travels. Local IDs are not wire identity.
class AuditEventCodec extends SyncCodec<AuditEvent> {
  const AuditEventCodec();
  @override
  String get entityType => 'AuditEvent';
  @override
  Map<String, Object?> toJson(AuditEvent event) => {
        'syncGuid': event.syncGuid,
        'sharedSpaceSyncGuid': event.contextSyncGuid,
        'evidenceJson': event.evidenceJson,
        'hash': event.hash,
        'signature': event.signature,
      };
  @override
  AuditEvent fromJson(Map<String, Object?> json) {
    final evidence = json['evidenceJson'] as String;
    final data = canonicalJsonDecode(evidence);
    if (data['shared'] != true ||
        data['context'] != json['sharedSpaceSyncGuid'] ||
        data['id'] != json['syncGuid']) {
      throw const FormatException('Audit context mismatch.');
    }
    return AuditEvent()
      ..syncGuid = json['syncGuid'] as String
      ..contextSyncGuid = json['sharedSpaceSyncGuid'] as String
      ..timestamp = DateTime.parse(data['timestamp'] as String)
      ..createdAt = DateTime.parse(data['timestamp'] as String)
      ..userIdentity = data['author'] as String
      ..action = data['action'] as String
      ..objectType = data['objectType'] as String
      ..previousHash = data['previousHash'] as String
      ..previousValue = canonicalJsonEncode(data['before'])
      ..newValue = canonicalJsonEncode(data['after'])
      ..evidenceJson = evidence
      ..hash = json['hash'] as String
      ..signature = json['signature'] as String;
  }
}
