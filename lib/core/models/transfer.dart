import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'transfer.g.dart';

@collection
class Transfer {
  Id id = Isar.autoIncrement;

  @Index()
  String syncGuid = newSyncGuid();

  int? profileId;
  int? sharedSpaceId;

  late String yearMonth;

  late int sourceProfileId;
  late int destinationProfileId;

  /// Amount in whole minor units.
  int amount = 0;

  /// Currency code of [amount] (raw string, resolved through `CurrencyCode`).
  late String currency;

  String? reason;

  late DateTime date;

  int? auditEventId;

  late DateTime createdAt;
}
