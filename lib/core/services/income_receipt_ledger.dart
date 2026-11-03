import '../models/salary_cycle.dart';
import '../models/income_source.dart';
import 'income_aggregation_service.dart';
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:timezone/data/latest.dart' as zones;
import 'package:timezone/timezone.dart' as tz;
import '../models/income_receipt_group.dart';
import '../models/money_receipt.dart';
import '../models/currency_code.dart';
import 'medical_receipt_booking_service.dart';
import '../models/fx_revision.dart';
import '../../features/expenses/models/reimbursement.dart';

/// One validated bank credit. Component rows classify its money; never add them
/// to this total again. Invalid legacy groups remain review issues.
class IncomeReceiptLedger {
  IncomeReceiptLedger(
      this.group, this.salaryMinor, this.medicalMinor, this.cycleMonth,
      [this.incomeMinor = 0]);
  final String cycleMonth;
  final IncomeReceiptGroup group;
  final int salaryMinor, medicalMinor, incomeMinor;
  static String key(IncomeReceiptGroup g) => 'income-group:${g.guid}';
  static String cashMonth(IncomeReceiptGroup group) {
    if (!tz.timeZoneDatabase.isInitialized) zones.initializeTimeZones();
    final zone = (group.timezone == 'UTC' || group.timezone == 'Etc/UTC')
        ? tz.UTC
        : tz.getLocation(group.timezone);
    return tz.TZDateTime.from(group.actualDate, zone)
        .toIso8601String()
        .substring(0, 7);
  }

  static Future<IncomeReceiptLedger> read(
      Isar db, IncomeReceiptGroup group) async {
    if (group.profileId == null ||
        CurrencyCode.tryParse(group.currency) == null ||
        group.totalMinor <= 0 ||
        group.componentReceiptGuids.isEmpty ||
        group.componentReceiptGuids.length !=
            group.componentReceiptGuids.toSet().length ||
        group.componentReceiptGuids.length !=
            group.componentRevisionRefs.length) {
      throw const MedicalReceiptException('groupNeedsReview');
    }
    final cycle =
        await db.salaryCycles.filter().guidEqualTo(group.cycleGuid).findFirst();
    if (cycle == null ||
        cycle.profileId != group.profileId ||
        cycle.sourceGuid != group.sourceGuid ||
        !cycle.confirmed ||
        cycle.receiptGroupGuid != group.guid) {
      throw const MedicalReceiptException('groupNeedsReview');
    }
    var salary = 0, medical = 0, income = 0, salaryCount = 0, incomeCount = 0;
    for (var i = 0; i < group.componentReceiptGuids.length; i++) {
      final receipt = await db.moneyReceipts
          .filter()
          .syncGuidEqualTo(group.componentReceiptGuids[i])
          .findFirst();
      final revision = await db.receiptRevisions
          .filter()
          .syncGuidEqualTo(group.componentRevisionRefs[i])
          .findFirst();
      if (receipt == null ||
          revision == null ||
          receipt.profileId != group.profileId ||
          receipt.sharedSpaceId != null ||
          revision.profileId != group.profileId ||
          revision.sharedSpaceId != null ||
          revision.receiptGuid != receipt.syncGuid) {
        throw const MedicalReceiptException('groupNeedsReview');
      }
      final latest = await db.receiptRevisions
          .filter()
          .receiptGuidEqualTo(receipt.syncGuid)
          .sortByRevisionDesc()
          .findFirst();
      if (latest?.syncGuid != revision.syncGuid) {
        throw const MedicalReceiptException('groupNeedsReview');
      }
      final evidence =
          Map<String, Object?>.from(jsonDecode(revision.evidenceJson) as Map);
      if (evidence['groupGuid'] != group.guid ||
          (evidence['currency'] as String?)?.toLowerCase() !=
              group.currency.toLowerCase()) {
        throw const MedicalReceiptException('groupNeedsReview');
      }
      if (receipt.kind == 'salary') {
        if (evidence['sourceGuid'] != group.sourceGuid ||
            evidence['cycleGuid'] != group.cycleGuid ||
            evidence['destinationMonth'] != group.destinationMonth ||
            DateTime.tryParse(evidence['actualDate'] as String? ?? '')
                    ?.toUtc() !=
                group.actualDate.toUtc()) {
          throw const MedicalReceiptException('groupNeedsReview');
        }
        salary = checkedFxMinor(salary + (evidence['amountMinor'] as int));
        salaryCount++;
      } else if (receipt.kind == 'income') {
        if (evidence['sourceGuid'] != group.sourceGuid ||
            evidence['cycleGuid'] != group.cycleGuid ||
            evidence['destinationMonth'] != group.destinationMonth ||
            DateTime.tryParse(evidence['actualDate'] as String? ?? '')
                    ?.toUtc() !=
                group.actualDate.toUtc()) {
          throw const MedicalReceiptException('groupNeedsReview');
        }
        final amount = evidence['amountMinor'];
        if (amount is! int || amount <= 0) {
          throw const MedicalReceiptException('groupNeedsReview');
        }
        income = checkedFxMinor(income + amount);
        incomeCount++;
      } else if (receipt.kind == 'medical') {
        final row = await db.reimbursements
            .filter()
            .syncGuidEqualTo(receipt.syncGuid)
            .findFirst();
        if (row == null ||
            row.profileId != group.profileId ||
            row.sharedSpaceId != null) {
          throw const MedicalReceiptException('groupNeedsReview');
        }
        final value = MedicalReceiptEvidence.of(row);
        if (value == null ||
            value.encode() != revision.evidenceJson ||
            value.fundingMonth != group.destinationMonth ||
            value.receivedAt != group.actualDate.toUtc()) {
          throw const MedicalReceiptException('groupNeedsReview');
        }
        medical = checkedFxMinor(medical + row.amount);
      } else {
        throw const MedicalReceiptException('groupNeedsReview');
      }
    }
    final principal = salary > 0 ? salary : income;
    if (salaryCount + incomeCount != 1 ||
        principal <= 0 ||
        checkedFxMinor(principal + medical) != group.totalMinor) {
      throw const MedicalReceiptException('groupNeedsReview');
    }
    return IncomeReceiptLedger(
        group, salary, medical, cycle.occurrenceMonth, income);
  }

  /// Replace only the source estimates represented by confirmed salary components.
  /// Medical components are classified separately as recoveries, never salary.
  static int? incomeForMonth(List<IncomeReceiptLedger> groups,
      List<IncomeSource> sources, String month, CurrencyCode currency,
      {List<SalaryCorrection> corrections = const []}) {
    final selected =
        groups.where((g) => g.group.destinationMonth == month).toList();
    final consumed = groups.where((g) => g.cycleMonth == month).toList();
    final monthCorrections =
        corrections.where((c) => c.cashMonth == month).toList();
    if (selected.isEmpty && consumed.isEmpty && monthCorrections.isEmpty) {
      return null;
    }
    if (selected
        .any((g) => CurrencyCode.tryParse(g.group.currency) != currency)) {
      throw const FormatException('Confirmed income currency needs review');
    }
    if (monthCorrections.any((c) => c.currency != currency.code)) {
      throw const FormatException('Salary correction currency needs review');
    }
    final confirmedSources = [...selected, ...consumed]
        .map((g) => g.group.sourceGuid)
        .toSet()
      ..addAll(monthCorrections.map((c) => c.sourceGuid));
    final correctionTotal = monthCorrections.fold<int>(
        0, (sum, c) => checkedFxMinor(sum + c.amountMinor));
    return checkedFxMinor(selected.fold<int>(0,
            (sum, g) => checkedFxMinor(sum + g.salaryMinor + g.incomeMinor)) +
        correctionTotal +
        const IncomeAggregationService().monthlyTotal(
            sources
                .where((s) => !confirmedSources.contains(s.syncGuid))
                .toList(),
            month,
            currency: currency));
  }

  static Future<List<IncomeReceiptLedger>> forOwner(Isar db, int owner) async =>
      [
        for (final group in await db.incomeReceiptGroups
            .filter()
            .profileIdEqualTo(owner)
            .findAll())
          await read(db, group)
      ];
}

/// One append-only salary correction. Its cash month is the month in which the
/// correction was recorded, never the original salary month.
class SalaryCorrection {
  const SalaryCorrection(
      {required this.receiptGuid,
      required this.groupGuid,
      required this.sourceGuid,
      required this.cashMonth,
      required this.amountMinor,
      required this.currency,
      required this.reason});
  final String receiptGuid, groupGuid, sourceGuid, cashMonth, currency, reason;
  final int amountMinor;

  static Future<List<SalaryCorrection>> forOwner(Isar db, int owner) async {
    final List<MoneyReceipt> receipts;
    try {
      receipts = await db.moneyReceipts
          .filter()
          .profileIdEqualTo(owner)
          .kindEqualTo('salary-correction')
          .findAll();
    } on IsarError {
      // A legacy test harness may open a reduced schema without this
      // collection; that database cannot contain a correction yet.
      return const [];
    }
    final rows = <SalaryCorrection>[];
    for (final receipt in receipts) {
      if (receipt.profileId != owner || receipt.sharedSpaceId != null) {
        throw const MedicalReceiptException('groupNeedsReview');
      }
      final revision = await db.receiptRevisions
          .filter()
          .receiptGuidEqualTo(receipt.syncGuid)
          .sortByRevisionDesc()
          .findFirst();
      if (revision == null ||
          revision.profileId != owner ||
          revision.sharedSpaceId != null) {
        throw const MedicalReceiptException('groupNeedsReview');
      }
      final Map<String, Object?> evidence;
      try {
        evidence =
            Map<String, Object?>.from(jsonDecode(revision.evidenceJson) as Map);
      } catch (_) {
        throw const MedicalReceiptException('groupNeedsReview');
      }
      final groupGuid = evidence['correctsGroupGuid'];
      final sourceGuid = evidence['sourceGuid'];
      final original = evidence['originalMinor'];
      final correction = evidence['correctionMinor'];
      final currency = (evidence['currency'] as String?)?.toLowerCase();
      final cashMonth = evidence['cashMonth'];
      final reason = evidence['reason'];
      if (evidence['kind'] != 'salary-correction' ||
          groupGuid is! String ||
          sourceGuid is! String ||
          original is! int ||
          correction is! int ||
          correction == 0 ||
          cashMonth is! String ||
          !RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(cashMonth) ||
          reason is! String ||
          reason.trim().isEmpty ||
          currency == null ||
          CurrencyCode.tryParse(currency) == null ||
          revision.yearMonth != cashMonth) {
        throw const MedicalReceiptException('groupNeedsReview');
      }
      checkedFxMinor(original);
      checkedFxMinor(correction);
      final group = await db.incomeReceiptGroups
          .filter()
          .guidEqualTo(groupGuid)
          .findFirst();
      if (group == null ||
          group.profileId != owner ||
          group.sourceGuid != sourceGuid ||
          group.currency.toLowerCase() != currency) {
        throw const MedicalReceiptException('groupNeedsReview');
      }
      final ledger = await IncomeReceiptLedger.read(db, group);
      if (ledger.salaryMinor != original ||
          checkedFxMinor(original + correction) <= 0) {
        throw const MedicalReceiptException('groupNeedsReview');
      }
      rows.add(SalaryCorrection(
          receiptGuid: receipt.syncGuid,
          groupGuid: groupGuid,
          sourceGuid: sourceGuid,
          cashMonth: cashMonth,
          amountMinor: correction,
          currency: currency,
          reason: reason));
    }
    return rows;
  }
}
