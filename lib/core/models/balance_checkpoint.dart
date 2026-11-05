import 'package:isar/isar.dart';
import '../../features/sync/domain/sync_guid.dart';

part 'balance_checkpoint.g.dart';

/// Append-only review metadata. Does not replace the legacy opening balance.
@collection
class BalanceCheckpoint {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String guid = newSyncGuid();
  @Index()
  late String ownerMonth;
  int? profileId;
  int? sharedSpaceId;
  late String yearMonth;
  late int balanceMinor;
  late String currency;
  late DateTime balanceAsOf;
  late String localZone;
  late String cashPoolDescription;
  late String adoptionGuid;
  late String sourceFingerprint;
  late String inputFingerprint;
  @Index(unique: true)
  late String operationIdentity;
  late DateTime confirmedAt;
  late int actorId;
  int revision = 1;
  String? previousCheckpointGuid;
  String state = 'reviewed';
}

/// User's explicit cash-scope/date decision, tied to an exact source revision.
@collection
class MovementInclusion {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String identity;
  @Index()
  late String checkpointGuid;
  late String movementKey;
  late String movementRevision;
  late String role;
  DateTime? reviewedActualAt;
  late int signedMinor;
  late int confirmedBy;
  late DateTime confirmedAt;
}

class CashMovement {
  const CashMovement(
      {required this.key,
      required this.revision,
      required this.label,
      required this.kind,
      required this.signedMinor,
      this.actualAt});
  final String key, revision, label, kind;
  final int signedMinor;

  /// Null means historical date evidence is missing; the owner must review it.
  final DateTime? actualAt;
}

class MovementChoice {
  const MovementChoice(
      {required this.key,
      required this.revision,
      required this.role,
      this.actualAt});
  final String key, revision;

  /// included / later / outside. Outside never affects this cash pool.
  final String role;
  final DateTime? actualAt;
  Map<String, Object?> get json => {
        'key': key,
        'revision': revision,
        'role': role,
        'actualAt': actualAt?.toUtc().toIso8601String()
      };
}

class CashReviewResult {
  CashReviewResult(
      {required this.bankMinor,
      required this.includedCreditMinor,
      required this.includedDebitMinor,
      required this.laterCreditMinor,
      required this.laterDebitMinor,
      required Iterable<String> blockers})
      : blockers = List.unmodifiable(blockers);
  final int? bankMinor;
  final int includedCreditMinor,
      includedDebitMinor,
      laterCreditMinor,
      laterDebitMinor;
  final List<String> blockers;
}
