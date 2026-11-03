import 'package:isar/isar.dart';
import '../../features/sync/domain/sync_guid.dart';

part 'money_receipt.g.dart';

/// Stable logical payment identity. Actual values live in immutable revisions.
@collection
class MoneyReceipt {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String syncGuid = newSyncGuid();
  @Index()
  late String billGuid;
  int? profileId;
  int? sharedSpaceId;
  String kind = 'medical';
  late DateTime createdAt;
  late int actorId;
  @Index(unique: true)
  late String operationIdentity;
  late String inputFingerprint;
}

@collection
class ReceiptRevision {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String syncGuid = newSyncGuid();
  @Index()
  late String receiptGuid;
  late String billGuid;
  int? profileId;
  int? sharedSpaceId;
  late String yearMonth;
  int revision = 1;
  String? previousGuid;
  late String evidenceJson;
  late DateTime recordedAt;
  late int actorId;
  @Index(unique: true)
  late String operationIdentity;
  late String inputFingerprint;
}
