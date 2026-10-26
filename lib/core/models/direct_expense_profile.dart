import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'direct_expense_profile.g.dart';

@collection
class DirectExpenseProfile {
  Id id = Isar.autoIncrement;

  @Index()
  String syncGuid = newSyncGuid();

  int? profileId;
  int? sharedSpaceId;

  late String yearMonth;

  late String name;

  /// Spent in whole minor units.
  int spent = 0;

  /// Number of expenses filed under this profile.
  int expenseCount = 0;

  late DateTime createdAt;
  late DateTime updatedAt;
}
