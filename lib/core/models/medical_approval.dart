import 'package:isar/isar.dart';
import '../../features/sync/domain/sync_guid.dart';

part 'medical_approval.g.dart';

/// Immutable decision revision. Approval is evidence, never available cash.
@collection
class MedicalApproval {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String syncGuid = newSyncGuid();
  @Index()
  late String billGuid;
  int? profileId;
  int? sharedSpaceId;
  late String yearMonth;
  late int approvedMinor;
  late String currency;
  late DateTime decisionDate;
  late DateTime recordedAt;
  late int actorId;
  int revision = 1;
  String? previousGuid;
  @Index(unique: true)
  late String operationIdentity;
  late String inputFingerprint;

  /// Expected/approved split captured at decision time. Zero on legacy rows
  /// that predate the breakdown; those rows stay readable and are not guessed.
  int approvedBillMinor = 0;
  int approvedShareMinor = 0;
  int approvedInsuranceMinor = 0;
  int expectedBillMinor = 0;
  int expectedShareMinor = 0;
  int expectedInsuranceMinor = 0;

  /// Appeal that led to this approval, when applicable.
  String? appealGuid;

  /// Exact bill/coverage basis at this decision. Null means legacy evidence
  /// was never captured; do not reconstruct it from today's bill.
  String? basisJson;
}

/// Explicit final decision, not a fabricated receipt of the shortfall.
@collection
class MedicalClaimClosure {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String syncGuid = newSyncGuid();
  @Index()
  late String billGuid;
  late String approvalGuid;
  int? profileId;
  int? sharedSpaceId;
  late String yearMonth;
  late int receivedMinor;
  late int shortfallMinor;
  late String currency;
  late String reason;
  late int actorId;
  late DateTime recordedAt;
  @Index(unique: true)
  late String operationIdentity;
}

/// Personal claim activity is append-only and does not itself create cash.
/// Corrections retain both versions; cancellation never deletes the paid bill.
@collection
class MedicalClaimActivity {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String syncGuid = newSyncGuid();
  @Index()
  late String billGuid;
  late int profileId;
  @Index()
  int? sharedSpaceId;
  late String yearMonth;
  late String kind;
  DateTime? submittedAt;
  String? approvalGuid;
  late String reason;
  String? beforeJson;
  String? afterJson;
  int beforeMinor = 0;
  int afterMinor = 0;
  late String currency;
  late DateTime recordedAt;
  late int actorId;
  @Index(unique: true)
  late String operationIdentity;
  late String inputFingerprint;

  /// Actual `YYYY-MM` for a money-affecting event; null for metadata-only rows.
  String? transactionMonth;

  /// Evidence attached to this event.
  List<String> documentPaths = [];

  /// Optional insurer/appeal reference.
  String? reference;

  /// Later correction/reversal that supersedes this row.
  String? correctedByGuid;
}
