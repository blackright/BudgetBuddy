import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'income_source.g.dart';

enum IncomeSourceType {
  salary,
  freelance,
  bonus,
  rental,
  investment,
  cashDeposit,
  other,
}

enum IncomeFrequency {
  oneTime,
  weekly,
  monthly,
  quarterly,
  yearly,
}

@collection
class IncomeSource {
  Id id = Isar.autoIncrement;

  @Index()
  String syncGuid = newSyncGuid();

  int? profileId;
  int? sharedSpaceId;

  late String name;

  @enumerated
  IncomeSourceType type = IncomeSourceType.other;

  /// Amount in whole minor units of [currency].
  int amount = 0;

  late String currency;

  @enumerated
  IncomeFrequency frequency = IncomeFrequency.monthly;

  DateTime? startDate;
  DateTime? endDate;

  String? notes;

  late DateTime createdAt;
  late DateTime updatedAt;
}
