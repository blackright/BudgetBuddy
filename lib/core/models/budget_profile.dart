import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'budget_profile.g.dart';

enum MonthEndRule {
  reset,
  carryForward,
}

@collection
class BudgetProfile {
  Id id = Isar.autoIncrement;

  @Index()
  String syncGuid = newSyncGuid();

  /// Stable identity shared by monthly copies. Empty legacy values require an
  /// explicit month-end link; names are never used as identity.
  @Index()
  String familyGuid = '';

  /// Confirmed recurring base, excluding prior carry and temporary transfers.
  /// Null means the user has not chosen a default yet.
  int? defaultAllocationMinor;

  /// Settlement already included in this row's allocation. Prevents bootstrap
  /// or out-of-order sync from adding the same carry a second time.
  String? monthEndOriginGuid;
  String? monthEndFingerprint;

  int? profileId;
  int? sharedSpaceId;

  late String yearMonth;

  late String name;

  /// Allocation in whole minor units of the context currency.
  int allocation = 0;

  /// Spent in whole minor units.
  int spent = 0;

  @enumerated
  MonthEndRule monthEndRule = MonthEndRule.reset;

  late DateTime createdAt;
  late DateTime updatedAt;
}
