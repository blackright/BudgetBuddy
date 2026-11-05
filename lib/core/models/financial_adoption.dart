import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'financial_adoption.g.dart';

/// Append-only local review evidence. This does not confirm any old payment or
/// switch financial readers to a new policy. Later capabilities need their own
/// reviewed readiness checks, schema and compatible peer support.
@collection
class FinancialAdoption {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String guid = newSyncGuid();

  /// Stable within this installation, explicitly discriminated owner scope.
  @Index()
  late String ownerKey;
  int? profileId;
  int? sharedSpaceId;
  int policyVersion = 2;
  late String effectiveYearMonth;
  late String chosenAccountingCurrency;
  String status = 'reviewed';
  List<String> enabledCapabilities = [];

  /// A retry key never replaces a previous successful operation.
  @Index(unique: true)
  late String operationIdentity;
  late String inputFingerprint;
  late String legacySourceFingerprint;
  late String reviewedFundingJson;
  late int actorId;
  late DateTime confirmedAt;
  int revision = 1;
  String? previousRevisionGuid;
}
