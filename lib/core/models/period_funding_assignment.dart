import 'package:isar/isar.dart';
import '../../features/sync/domain/sync_guid.dart';

part 'period_funding_assignment.g.dart';

/// Entitlement to existing received money, never another income/cash event.
/// Salary/Vault coordinators will create these only in their approved phases.
@collection
class PeriodFundingAssignment {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String guid = newSyncGuid();
  int? profileId;
  int? sharedSpaceId;
  @Index()
  late String ownerKey;
  late String sourceFactGuid;
  late String sourceRevision;
  late String destinationMonth;
  late int amountMinor;
  late String currency;
  late DateTime availabilityBoundary;
  late String inclusionReviewRef;
  String state = 'reserved';
  int policyRevision = 2;
}
