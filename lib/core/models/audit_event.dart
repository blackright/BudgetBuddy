import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'audit_event.g.dart';

@collection
class AuditEvent {
  Id id = Isar.autoIncrement;

  @Index()
  String syncGuid = newSyncGuid();

  int? profileId;
  int? sharedSpaceId;

  String? contextSyncGuid;

  late DateTime timestamp;

  late String userIdentity;

  late String action;
  late String objectType;
  int? objectId;

  String? previousValue;
  String? newValue;

  late String hash;
  late String previousHash;

  String? signature;

  /// Canonical versioned evidence. Null means legacy, never retroactively signed.
  String? evidenceJson;

  late DateTime createdAt;
}
