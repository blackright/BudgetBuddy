import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'allocation.g.dart';

@collection
class Allocation {
  Id id = Isar.autoIncrement;

  @Index()
  String syncGuid = newSyncGuid();

  int? profileId;
  int? sharedSpaceId;

  late String yearMonth;

  late int budgetProfileId;

  /// Amount in whole minor units.
  int amount = 0;

  /// Currency code of [amount] (raw string, resolved through `CurrencyCode`).
  late String currency;

  late DateTime date;

  int? auditEventId;

  late DateTime createdAt;
}
