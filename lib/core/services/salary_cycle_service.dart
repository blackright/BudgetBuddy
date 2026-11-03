import 'package:isar/isar.dart';

import '../models/salary_cycle.dart';

class SalaryCycleService {
  SalaryCycleService(this.db);
  final Isar db;

  /// Computes the nominal payday: 25th normally, 15th in December.
  static DateTime nominalPayday(int year, int month) {
    final day = month == 12 ? 15 : 25;
    return DateTime(year, month, day);
  }

  /// Adjusts a nominal payday forward to the next working day.
  /// [isWorkingDay] returns true if the date is a working day, false if not,
  /// null if coverage is missing (in which case the nominal date is returned).
  static DateTime adjustForward(
      DateTime nominal, bool? Function(DateTime) isWorkingDay) {
    var current = nominal;
    for (var i = 0; i < 30; i++) {
      final working = isWorkingDay(current);
      if (working == null) return nominal; // missing coverage: return nominal
      if (working) return current;
      current = current.add(const Duration(days: 1));
    }
    return nominal;
  }

  /// Creates a salary cycle for a given source and occurrence month.
  /// Snapshots the expected amount and nominal payday so later source edits
  /// do not rewrite prior cycles.
  Future<SalaryCycle> createCycle({
    required String sourceGuid,
    required int profileId,
    required String occurrenceMonth,
    required int expectedAmountMinor,
    required String currency,
  }) async {
    final parts = occurrenceMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final nominal = nominalPayday(year, month);
    final now = DateTime.now().toUtc();
    final cycle = SalaryCycle()
      ..profileId = profileId
      ..sourceGuid = sourceGuid
      ..scheduleGuid = ''
      ..expectedAmountMinor = expectedAmountMinor
      ..currency = currency
      ..occurrenceMonth = occurrenceMonth
      ..nominalPayday = nominal
      ..adjustedPayday = nominal
      ..confirmed = false
      ..state = 'unconfirmed'
      ..createdAt = now
      ..updatedAt = now;
    await db.writeTxn(() async {
      cycle.id = await db.salaryCycles.put(cycle);
    });
    return cycle;
  }
}
