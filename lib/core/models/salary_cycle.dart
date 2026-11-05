import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'salary_cycle.g.dart';

/// One expected occurrence of a Salary source.
///
/// A cycle is created from a [SalarySchedule] + [IncomeSource] and snapshots
/// the expected amount and nominal payday so later source edits do not rewrite
/// prior cycles.
@collection
class SalaryCycle {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String guid = newSyncGuid();

  /// Owning personal profile.
  @Index()
  int? profileId;

  /// The Salary [IncomeSource.syncGuid].
  @Index()
  late String sourceGuid;

  /// The [SalarySchedule.guid] that produced this cycle.
  late String scheduleGuid;

  /// Expected amount in whole minor units of [currency].
  int expectedAmountMinor = 0;

  late String currency;

  /// Nominal occurrence month (YYYY-MM) this cycle represents.
  @Index()
  late String occurrenceMonth;

  /// Nominal payday date (before forward adjustment).
  late DateTime nominalPayday;

  /// Adjusted payday (next working/banking day if nominal is non-working).
  late DateTime adjustedPayday;

  /// Whether this cycle has been confirmed (actual receipt recorded).
  bool confirmed = false;

  /// When confirmed, the [IncomeReceiptGroup.guid] that records it.
  String? receiptGroupGuid;

  /// Confirmation/overdue state label.
  String state = 'unconfirmed';

  late DateTime createdAt;
  late DateTime updatedAt;
}
