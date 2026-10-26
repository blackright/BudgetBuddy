import 'dart:math' as math;
import '../models/budget_profile.dart';
import '../models/currency_code.dart';
import '../models/month_end_run.dart';

String nextFinancialMonth(String month) {
  if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(month)) {
    throw ArgumentError.value(month, 'month', 'Expected YYYY-MM');
  }
  final date = DateTime(
      int.parse(month.substring(0, 4)), int.parse(month.substring(5)) + 1);
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
}

class MonthEndAmounts {
  MonthEndAmounts(
      {required this.allocation,
      required this.spent,
      required this.defaultAllocation,
      required this.rule,
      this.destinationAllocation}) {
    if (allocation < 0 ||
        spent < 0 ||
        defaultAllocation < 0 ||
        (destinationAllocation ?? 0) < 0) {
      throw ArgumentError('Month-end amounts must be nonnegative');
    }
  }
  final int allocation, spent, defaultAllocation;
  final int? destinationAllocation;
  final MonthEndRule rule;
  int get unused => math.max(0, allocation - spent);
  int get overspent => math.max(0, spent - allocation);
  int get carried => rule == MonthEndRule.carryForward ? unused : 0;
  int get released => rule == MonthEndRule.reset ? unused : 0;
  int get nextAllocation {
    final value = (destinationAllocation ?? defaultAllocation) + carried;
    if (value > 9007199254740991) {
      throw ArgumentError('Month-end allocation exceeds exact money range');
    }
    return value;
  }
}

/// A settlement is immutable, while legacy personal-month entries can still
/// change. Never release more than the unused envelope that remains, and keep
/// committed carry reserved even if later spending consumes that envelope.
class MonthEndReservation {
  const MonthEndReservation(
      {required this.unused, required this.carried, required this.released});
  final int unused, carried, released;
  int get releasedCredit => math.min(unused, released);
  int get carryShortfall => math.max(0, carried - unused);
}

/// Explicit choices supplied by the reviewer, never guessed from names.
class MonthEndChoice {
  const MonthEndChoice(
      {required this.sourceGuid,
      required this.rule,
      required this.defaultAllocation,
      this.destinationGuid});
  final String sourceGuid;
  final MonthEndRule rule;
  final int defaultAllocation;
  final String? destinationGuid;
}

class MonthEndLine {
  const MonthEndLine(
      {required this.sourceGuid,
      required this.familyGuid,
      required this.destinationGuid,
      required this.name,
      required this.amounts,
      required this.existingDestination,
      this.borrowed = 0,
      this.deficit = 0});
  final String sourceGuid, familyGuid, destinationGuid, name;
  final MonthEndAmounts amounts;
  final bool existingDestination;
  final int borrowed, deficit;
  Map<String, Object?> toJson() => {
        'sourceGuid': sourceGuid,
        'familyGuid': familyGuid,
        'destinationGuid': destinationGuid,
        'name': name,
        'allocation': amounts.allocation,
        'spent': amounts.spent,
        'defaultAllocation': amounts.defaultAllocation,
        'rule': amounts.rule.name,
        'destinationAllocation': amounts.destinationAllocation,
        'nextAllocation': amounts.nextAllocation,
        'carried': amounts.carried,
        'released': amounts.released,
        'existingDestination': existingDestination,
        'borrowed': borrowed,
        'deficit': deficit,
      };
}

class MonthEndReport {
  const MonthEndReport(
      {required this.yearMonth,
      required this.destinationMonth,
      required this.currency,
      required this.lines,
      required this.blockers,
      required this.fingerprint,
      required this.canConfirm,
      this.completed});
  final String yearMonth, destinationMonth, fingerprint;
  final CurrencyCode currency;
  final List<MonthEndLine> lines;
  final List<String> blockers;
  final bool canConfirm;
  final MonthEndRun? completed;
  bool get ready => blockers.isEmpty && completed == null && canConfirm;
  int get carried => lines.fold(0, (sum, line) => sum + line.amounts.carried);
  int get released => lines.fold(0, (sum, line) => sum + line.amounts.released);
}
