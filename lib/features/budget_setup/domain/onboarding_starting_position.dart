import 'package:isar/isar.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/income_source.dart';
import '../../../core/models/salary_cycle.dart';
import '../../../core/services/income_activation_period.dart';
import '../../../core/services/income_activation_service.dart';
import '../../../core/services/income_receipt_ledger.dart';
import 'onboarding_state.dart';

class StartingPositionLine {
  const StartingPositionLine(this.name, this.minor, {this.note});
  final String name;
  final int minor;
  final String? note;
}

/// The first-month money picture after activation choices have been made.
///
/// Confirmed income uses actual receipt groups for [month]. Pending, skipped,
/// cancelled and not-configured amounts are expected amounts and never count as
/// available money.
class OnboardingStartingPosition {
  const OnboardingStartingPosition({
    required this.month,
    required this.currency,
    required this.openingMinor,
    required this.confirmedMinor,
    required this.pendingMinor,
    required this.skippedMinor,
    required this.unconfiguredMinor,
    required this.cancelledMinor,
    required this.confirmed,
    required this.pending,
    required this.skipped,
    required this.unconfigured,
    required this.future,
    required this.cancelled,
  });

  final String month;
  final CurrencyCode currency;
  final int? openingMinor;
  final int confirmedMinor, pendingMinor, skippedMinor, unconfiguredMinor;
  final int cancelledMinor;
  final List<StartingPositionLine> confirmed, pending, skipped, unconfigured;
  final List<StartingPositionLine> future, cancelled;

  int? get freeToUseMinor =>
      openingMinor == null ? null : openingMinor! + confirmedMinor;

  static Future<OnboardingStartingPosition> load(
    Isar db, {
    required int profileId,
    required String month,
    required OnboardingOpeningDraft opening,
    required CurrencyCode currency,
  }) async {
    final monthDate = DateTime.parse('$month-01');
    final sources =
        await db.incomeSources.filter().profileIdEqualTo(profileId).findAll();
    final cycles =
        await db.salaryCycles.filter().profileIdEqualTo(profileId).findAll();
    final ledger = await IncomeReceiptLedger.forOwner(db, profileId);
    final corrections = await SalaryCorrection.forOwner(db, profileId);
    final sourceByGuid = {
      for (final source in sources) source.syncGuid: source
    };

    final confirmed = <StartingPositionLine>[];
    var confirmedMinor = 0;
    for (final row in ledger) {
      if (row.group.destinationMonth != month) continue;
      final amount = row.salaryMinor + row.incomeMinor;
      if (amount == 0) continue;
      confirmed.add(StartingPositionLine(
          sourceByGuid[row.group.sourceGuid]?.name ?? 'Income', amount,
          note: 'Received'));
      confirmedMinor += amount;
    }
    for (final correction in corrections) {
      if (correction.cashMonth != month) continue;
      confirmed.add(StartingPositionLine(
          sourceByGuid[correction.sourceGuid]?.name ?? 'Salary correction',
          correction.amountMinor,
          note: 'Correction'));
      confirmedMinor += correction.amountMinor;
    }

    final pending = <StartingPositionLine>[];
    final skipped = <StartingPositionLine>[];
    final unconfigured = <StartingPositionLine>[];
    final future = <StartingPositionLine>[];
    final cancelled = <StartingPositionLine>[];
    var pendingMinor = 0, skippedMinor = 0, unconfiguredMinor = 0;
    var cancelledMinor = 0;

    for (final source in sources) {
      final period = periodKeyFor(source, monthDate);
      if (!isPeriodActive(source, period)) {
        future.add(StartingPositionLine(source.name, source.amount,
            note: 'Starts later'));
        continue;
      }
      final cycle = _cycleFor(cycles, source, period);
      final state = cycle == null
          ? IncomePeriodState.needsActivation
          : cycle.confirmed
              ? IncomePeriodState.confirmed
              : incomePeriodStateFromStored(cycle.state);
      final amount = cycle?.expectedAmountMinor ?? source.amount;
      switch (state) {
        case IncomePeriodState.confirmed:
          // The actual receipt lines above are the source of truth.
          break;
        case IncomePeriodState.pending:
          pending.add(StartingPositionLine(source.name, amount,
              note: 'Expected later'));
          pendingMinor += amount;
        case IncomePeriodState.skipped:
          skipped.add(StartingPositionLine(source.name, amount,
              note: 'Starts next period'));
          skippedMinor += amount;
        case IncomePeriodState.cancelled:
          cancelled.add(
              StartingPositionLine(source.name, amount, note: 'Cancelled'));
          cancelledMinor += amount;
        case IncomePeriodState.needsActivation:
          unconfigured.add(StartingPositionLine(source.name, amount,
              note: 'Not configured'));
          unconfiguredMinor += amount;
      }
    }

    return OnboardingStartingPosition(
      month: month,
      currency: currency,
      openingMinor: opening.choice == OnboardingOpeningChoice.known
          ? opening.minorUnits
          : null,
      confirmedMinor: confirmedMinor,
      pendingMinor: pendingMinor,
      skippedMinor: skippedMinor,
      unconfiguredMinor: unconfiguredMinor,
      cancelledMinor: cancelledMinor,
      confirmed: List.unmodifiable(confirmed),
      pending: List.unmodifiable(pending),
      skipped: List.unmodifiable(skipped),
      unconfigured: List.unmodifiable(unconfigured),
      future: List.unmodifiable(future),
      cancelled: List.unmodifiable(cancelled),
    );
  }

  static SalaryCycle? _cycleFor(
      List<SalaryCycle> cycles, IncomeSource source, String period) {
    for (final cycle in cycles) {
      if (cycle.sourceGuid == source.syncGuid &&
          cycle.occurrenceMonth == period) {
        return cycle;
      }
    }
    return null;
  }
}
