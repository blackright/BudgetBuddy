import 'package:isar/isar.dart';

import '../models/desired_salary_reminder.dart';
import 'reminder_notification_service.dart';

class SalaryReminderService {
  SalaryReminderService(this.db,
      {ReminderNotificationService? notifications, DateTime Function()? clock})
      : notifications = notifications ?? ReminderNotificationService(),
        clock = clock ?? DateTime.now;
  final Isar db;
  final ReminderNotificationService notifications;
  final DateTime Function() clock;

  /// Creates desired reminder slots for a cycle occurrence.
  /// Two reminders per eligible working day: 10:00 and 20:00, from adjusted
  /// payday through the end of the adjusted payday's calendar month. Stops
  /// earlier on confirmation. Stable IDs; 7-day/128-slot initial ceiling.
  Future<List<DesiredSalaryReminder>> createDesiredSlots({
    required String cycleGuid,
    required String sourceGuid,
    required int profileId,
    required DateTime adjustedPayday,
    required String timezone,
    required bool Function() isAccessCurrent,
  }) async {
    if (!isAccessCurrent()) return const [];
    // Check for existing slots (idempotent).
    final existing = await db.desiredSalaryReminders
        .filter()
        .cycleGuidEqualTo(cycleGuid)
        .findAll();
    if (existing.isNotEmpty) return existing;

    final slots = <DesiredSalaryReminder>[];
    final monthEnd = DateTime(adjustedPayday.year, adjustedPayday.month + 1, 0);
    var current = adjustedPayday;
    while (!current.isAfter(monthEnd)) {
      // Skip weekends.
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday) {
        for (final kind in ['morning', 'evening']) {
          final hour = kind == 'morning' ? 10 : 20;
          final scheduled =
              DateTime(current.year, current.month, current.day, hour);
          final slot = DesiredSalaryReminder()
            ..profileId = profileId
            ..cycleGuid = cycleGuid
            ..sourceGuid = sourceGuid
            ..scheduledAt = scheduled
            ..timezone = timezone
            ..kind = kind
            ..status = 'pending'
            ..createdAt = clock().toUtc()
            ..updatedAt = clock().toUtc();
          slots.add(slot);
        }
      }
      current = current.add(const Duration(days: 1));
    }

    await db.writeTxn(() async {
      for (final slot in slots) {
        slot.id = await db.desiredSalaryReminders.put(slot);
      }
    });
    return slots;
  }

  /// Cancels all pending reminders for a cycle (on confirmation).
  Future<void> cancelForCycle(String cycleGuid) async {
    final slots = await db.desiredSalaryReminders
        .filter()
        .cycleGuidEqualTo(cycleGuid)
        .findAll();
    await db.writeTxn(() async {
      for (final slot in slots) {
        if (slot.status == 'pending' || slot.status == 'scheduled') {
          slot.status = 'cancelled';
          slot.updatedAt = DateTime.now().toUtc();
          await db.desiredSalaryReminders.put(slot);
          if (slot.nativeId != null) {
            await notifications.cancelReminder(slot.nativeId!);
          }
        }
      }
    });
  }
}
