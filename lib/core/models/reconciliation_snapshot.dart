import 'currency_code.dart';
import '../providers/budget_context_provider.dart';

enum ReconciliationReadiness { ready, needsReview }

enum ReceiptBlocker {
  missingMonth,
  missingOpeningReview,
  sealedMonth,
  settledMonth,
  sweptMonth,
  settlementNeedsReview,
}

/// Immutable current-store preview token, NOT proof that new receipt policy has
/// been adopted. Full private source rows are hashed inside the repository and
/// never exposed here or serialised to a collaborator.
class ReceiptSourceSnapshot {
  ReceiptSourceSnapshot({
    required this.context,
    required this.actorId,
    required this.currency,
    required this.fingerprint,
    required this.capturedAt,
    required Iterable<ReceiptBlocker> blockers,
    required Map<String, int> sourceCounts,
  })  : blockers = List.unmodifiable(blockers),
        sourceCounts = Map.unmodifiable(sourceCounts);

  final ContextRef context;
  final int actorId;
  final CurrencyCode currency;
  final String fingerprint;
  final DateTime capturedAt;
  final List<ReceiptBlocker> blockers;
  final Map<String, int> sourceCounts;
  bool get canReviewWrite => blockers.isEmpty;
}

/// Caller-reviewed minor-unit facts, not a second stored balance. Cash deltas
/// exclude movements already reflected in the checkpoint; eligible income
/// excludes expected/scheduled funding. Ownership/date/currency normalisation
/// belongs to the eventual adopted-policy coordinator, not silent defaults.
class ReconciliationInputs {
  const ReconciliationInputs({
    required this.currency,
    required this.checkpointMinor,
    required this.eligibleIncomeMinor,
    required this.paidMinor,
    required this.returnedMinor,
    required this.unusedAllocationMinor,
    required this.allocatedMinor,
    required this.netDirectSpendingMinor,
    this.cashCreditsAfterCheckpointMinor = 0,
    this.cashDebitsAfterCheckpointMinor = 0,
    this.carriedOutMinor = 0,
    this.carriedInMinor = 0,
    this.releasedMinor = 0,
    this.vaultPeriodCreditMinor = 0,
    this.expectedIncomeMinor = 0,
    this.scheduledFundingMinor = 0,
    this.expenseCostMinor = 0,
  });

  final CurrencyCode currency;
  final int? checkpointMinor;
  final int eligibleIncomeMinor, paidMinor, returnedMinor;
  final int unusedAllocationMinor, allocatedMinor, netDirectSpendingMinor;
  final int cashCreditsAfterCheckpointMinor, cashDebitsAfterCheckpointMinor;
  final int carriedOutMinor,
      carriedInMinor,
      releasedMinor,
      vaultPeriodCreditMinor;
  final int expectedIncomeMinor, scheduledFundingMinor, expenseCostMinor;
}

/// Bank cash, period funding and expense cost describe different views of the
/// same facts. Expected/scheduled fields are informational, never extra cash.
class ReconciliationSnapshot {
  const ReconciliationSnapshot({
    required this.currency,
    required this.readiness,
    required this.bankMinor,
    required this.freeToSpendMinor,
    required this.reserveMinor,
    required this.expectedIncomeMinor,
    required this.scheduledFundingMinor,
    required this.expenseCostMinor,
  });

  final CurrencyCode currency;
  final ReconciliationReadiness readiness;
  final int? bankMinor, freeToSpendMinor, reserveMinor;
  final int expectedIncomeMinor, scheduledFundingMinor, expenseCostMinor;
}
