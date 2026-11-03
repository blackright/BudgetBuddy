import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'income_receipt_group.g.dart';

/// One logical bank-credit event: salary plus optionally selected approved
/// Medical refunds, confirmed together in a single group.
///
/// This is a classification/view of one bank credit, never an additional cash
/// event. Component receipts (salary, Medical) are referenced by GUID and
/// revision; their funding is derived, never summed as extra money.
@collection
class IncomeReceiptGroup {
  Id id = Isar.autoIncrement;

  /// Stable group/operation identity; retry targets the same group.
  @Index(unique: true)
  String guid = newSyncGuid();

  /// Owning personal profile.
  @Index()
  int? profileId;

  /// The Salary [IncomeSource.syncGuid].
  late String sourceGuid;

  /// The [SalaryCycle.guid] this group confirms.
  late String cycleGuid;

  /// Actual bank-credit date (cash timing).
  late DateTime actualDate;

  /// Confirmed IANA timezone of the actual date.
  late String timezone;

  /// Total bank credit in whole minor units of [currency].
  int totalMinor = 0;

  late String currency;

  /// The single visibly chosen destination budget month (normally next month).
  late String destinationMonth;

  /// Component receipt GUIDs (salary + selected Medical receipts).
  List<String> componentReceiptGuids = [];

  /// Component revision references for audit/replay.
  List<String> componentRevisionRefs = [];

  /// Immutable history fingerprint of this group's facts.
  late String fingerprint;

  /// Operation identity for idempotent retry.
  late String operationIdentity;

  late DateTime createdAt;
  late DateTime updatedAt;
}
