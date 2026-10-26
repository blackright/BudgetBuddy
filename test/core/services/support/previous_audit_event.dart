import 'package:isar/isar.dart';

part 'previous_audit_event.g.dart';

@collection
@Name('AuditEvent')
class PreviousAuditEvent {
  Id id = Isar.autoIncrement;

  @Index()
  String syncGuid = 'legacy-event';

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

  late DateTime createdAt;
}
