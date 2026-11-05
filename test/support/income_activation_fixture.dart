import 'dart:io';

import 'package:budget_buddy/core/database/schema_migrations.dart';
import 'package:budget_buddy/core/models/currency_code.dart';
import 'package:budget_buddy/core/models/income_source.dart';
import 'package:budget_buddy/core/models/monthly_budget.dart';
import 'package:budget_buddy/core/models/pending_action.dart';
import 'package:budget_buddy/core/models/salary_cycle.dart';
import 'package:budget_buddy/core/models/salary_schedule.dart';
import 'package:budget_buddy/core/models/user_profile.dart';
import 'package:isar/isar.dart';

import '../features/medical/repositories/medical_test_harness.dart';

/// A small current-schema Isar fixture for income activation tests.
///
/// It seeds one personal profile and one confirmed month, then lets a test add
/// sources, schedules, lifecycle rows and Pending Actions. It deliberately does
/// not use the app database or run migrations.
class IncomeActivationFixture {
  IncomeActivationFixture._(
      this.db, this.directory, this.profileId, this.month, this.currency);

  final Isar db;
  final Directory directory;
  final int profileId;
  final String month;
  final PrimaryCurrency currency;

  static int _serial = 0;
  static bool _coreReady = false;

  static List<CollectionSchema> get schemas {
    final base = MedicalTestHarness.schemas;
    final names = base.map((schema) => schema.name).toSet();
    return [
      ...base,
      if (!names.contains('SalarySchedule')) SalaryScheduleSchema,
    ];
  }

  static Future<IncomeActivationFixture> create({
    String month = '2026-11',
    PrimaryCurrency currency = PrimaryCurrency.huf,
    double opening = 1000000,
  }) async {
    if (!_coreReady) {
      await Isar.initializeIsarCore(download: true);
      _coreReady = true;
    }
    final directory =
        Directory.systemTemp.createTempSync('bb_income_activation_');
    final db = await Isar.open(
      schemas,
      directory: directory.path,
      name: 'income_activation_${_serial++}',
    );
    await writeSchemaVersion(db, schemaVersion);
    final now = DateTime.utc(2026, 11, 1);
    final profile = UserProfile()
      ..name = 'Income fixture'
      ..primaryCurrency = currency
      ..monthlyAvailableAmount = opening
      ..createdAt = now
      ..updatedAt = now;
    late int profileId;
    await db.writeTxn(() async {
      profileId = await db.userProfiles.put(profile);
      await db.monthlyBudgets.put(MonthlyBudget()
        ..profileId = profileId
        ..yearMonth = month
        ..baseAvailableAmount = opening
        ..openingBalanceConfirmed = true
        ..currency = currency.code.code
        ..createdAt = now
        ..updatedAt = now);
    });
    return IncomeActivationFixture._(db, directory, profileId, month, currency);
  }

  Future<IncomeSource> addSource({
    String name = 'Salary',
    IncomeSourceType type = IncomeSourceType.salary,
    int amount = 500000,
    PrimaryCurrency? currency,
    IncomeFrequency frequency = IncomeFrequency.monthly,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    final source = IncomeSource()
      ..profileId = profileId
      ..name = name
      ..type = type
      ..amount = amount
      ..currency = (currency ?? this.currency).code.code
      ..frequency = frequency
      ..startDate = startDate ?? _monthStart(month)
      ..endDate = endDate
      ..notes = notes
      ..createdAt = DateTime.utc(2026, 11, 1)
      ..updatedAt = DateTime.utc(2026, 11, 1);
    await db.writeTxn(() async {
      source.id = await db.incomeSources.put(source);
    });
    return source;
  }

  Future<SalarySchedule> addSchedule(
    IncomeSource source, {
    int nominalDay = 25,
    String timezone = 'UTC',
  }) async {
    final schedule = SalarySchedule()
      ..profileId = profileId
      ..sourceGuid = source.syncGuid
      ..nominalDay = nominalDay
      ..countryCode = ''
      ..timezone = timezone
      ..createdAt = DateTime.utc(2026, 11, 1)
      ..updatedAt = DateTime.utc(2026, 11, 1);
    await db.writeTxn(() async {
      schedule.id = await db.salarySchedules.put(schedule);
    });
    return schedule;
  }

  Future<SalaryCycle> addCycle(
    IncomeSource source, {
    String? occurrenceMonth,
    int? expectedAmountMinor,
    String state = 'needsActivation',
    bool? confirmed,
    String? receiptGroupGuid,
    DateTime? payday,
    String? scheduleGuid,
  }) async {
    final period = occurrenceMonth ?? month;
    final isConfirmed = confirmed ?? state == 'confirmed';
    final cycle = SalaryCycle()
      ..guid = 'salary-cycle:${source.syncGuid}:$period'
      ..profileId = profileId
      ..sourceGuid = source.syncGuid
      ..scheduleGuid = scheduleGuid ?? 'manual:${source.syncGuid}'
      ..expectedAmountMinor = expectedAmountMinor ?? source.amount
      ..currency = source.currency
      ..occurrenceMonth = period
      ..nominalPayday = payday ?? _dateFor(period)
      ..adjustedPayday = payday ?? _dateFor(period)
      ..confirmed = isConfirmed
      ..receiptGroupGuid = receiptGroupGuid
      ..state = isConfirmed ? 'confirmed' : state
      ..createdAt = DateTime.utc(2026, 11, 1)
      ..updatedAt = DateTime.utc(2026, 11, 1);
    await db.writeTxn(() async {
      cycle.id = await db.salaryCycles.put(cycle);
    });
    return cycle;
  }

  Future<PendingAction> addAction({
    required String actionType,
    required String recordRef,
    String? cycleOrMonth,
    String title = 'Income action',
    String nextAction = 'Review income',
    String feature = 'income',
    String status = 'pending',
    int? expectedAmountMinor,
    String? currency,
    DateTime? expectedAt,
    String? expectedMonth,
    int priority = 0,
    String? deepLink,
    String? dismissedReason,
  }) async {
    final period = cycleOrMonth ?? month;
    final action = PendingAction()
      ..profileId = profileId
      ..actionType = actionType
      ..title = title
      ..nextAction = nextAction
      ..feature = feature
      ..recordRef = recordRef
      ..status = status
      ..priority = priority
      ..expectedAmountMinor = expectedAmountMinor
      ..currency = currency
      ..expectedAt = expectedAt
      ..expectedMonth = expectedMonth ?? period
      ..deepLink = deepLink
      ..dismissedReason = dismissedReason
      ..dedupeKey = '$actionType|$recordRef|$period'
      ..createdAt = DateTime.utc(2026, 11, 1)
      ..updatedAt = DateTime.utc(2026, 11, 1);
    await db.writeTxn(() async {
      action.id = await db.pendingActions.put(action);
    });
    return action;
  }

  Future<List<SalaryCycle>> cyclesFor(String sourceGuid) =>
      db.salaryCycles.filter().sourceGuidEqualTo(sourceGuid).findAll();

  Future<List<PendingAction>> actionsFor(String actionType) =>
      db.pendingActions.filter().actionTypeEqualTo(actionType).findAll();

  Future<SalaryCycle?> lifecycle(IncomeSource source) =>
      db.salaryCycles.filter().sourceGuidEqualTo(source.syncGuid).findFirst();

  Future<void> close() async {
    await db.close(deleteFromDisk: true);
    if (directory.parent.absolute.path != Directory.systemTemp.absolute.path ||
        !directory.uri.pathSegments
            .where((part) => part.isNotEmpty)
            .last
            .startsWith('bb_income_activation_')) {
      throw StateError('Refusing unexpected fixture cleanup path.');
    }
    await directory.delete(recursive: true);
  }

  DateTime _dateFor(String period) {
    final parts = period.split('-').map(int.parse).toList();
    return DateTime.utc(parts[0], parts[1], 25);
  }

  DateTime _monthStart(String period) {
    final parts = period.split('-').map(int.parse).toList();
    return DateTime.utc(parts[0], parts[1], 1);
  }
}
