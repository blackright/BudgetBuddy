import 'package:isar/isar.dart';

import '../../features/sync/domain/sync_guid.dart';

part 'desired_salary_reminder.g.dart';

/// A desired reminder slot for a salary cycle occurrence.
///
/// Persisted desired slots; post-commit bounded native reconciliation.
/// Stable IDs; 7-day/128-slot initial ceiling with app/platform headroom.
@collection
class DesiredSalaryReminder {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String guid = newSyncGuid();

  /// Owning personal profile.
  @Index()
  int? profileId;

  /// The SalaryCycle.guid this reminder belongs to.
  @Index()
  late String cycleGuid;

  /// The Salary source syncGuid.
  late String sourceGuid;

  /// Requested reminder time (in source timezone).
  late DateTime scheduledAt;

  /// Confirmed IANA timezone.
  late String timezone;

  /// Reminder kind: 'morning' (10:00) or 'evening' (20:00).
  String kind = 'morning';

  /// Status: 'pending', 'scheduled', 'cancelled', 'failed', 'overdue'.
  String status = 'pending';

  /// Native notification ID (if scheduled).
  int? nativeId;

  /// Error message if scheduling failed.
  String errorMessage = '';

  late DateTime createdAt;
  late DateTime updatedAt;
}
