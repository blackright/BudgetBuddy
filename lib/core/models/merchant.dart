import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'merchant.g.dart';

@collection
class Merchant {
  Id id = Isar.autoIncrement;

  @Index()
  String syncGuid = newSyncGuid();

  int? profileId;
  int? sharedSpaceId;

  late String canonicalName;

  List<String> aliases = [];

  late DateTime createdAt;
  late DateTime updatedAt;
}
