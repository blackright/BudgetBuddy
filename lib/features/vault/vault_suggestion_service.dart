import 'package:isar/isar.dart';

import '../../core/logging/app_logger.dart';
import '../../core/models/currency_code.dart';
import '../../core/models/monthly_budget.dart';
import '../../core/models/pending_action.dart';
import '../../core/models/user_profile.dart';
import '../budget_setup/domain/onboarding_automation_guard.dart';
import '../engine/providers/rate_registry_provider.dart';
import '../pending_actions/services/pending_action_service.dart';
import 'models/vault_entry.dart';
import 'personal_month_funds.dart';
import 'vault_math.dart';
import 'vault_transfer_ledger.dart';

/// Pending-action type for a finished month with money left to review.
const vaultDepositSuggestedType = 'vault.depositSuggested';

/// Pending-action type for a planned Vault withdrawal whose target month came.
const vaultWithdrawalDueType = 'vault.withdrawalDue';

/// Stable record reference for one month's deposit suggestion.
String vaultDepositSuggestedRecord(int profileId, String month) =>
    '$profileId:$month';

/// Stable dedupe key for one month's deposit suggestion.
String vaultDepositSuggestedKey(int profileId, String month) =>
    '$vaultDepositSuggestedType|${vaultDepositSuggestedRecord(profileId, month)}|$month';

/// Stable record reference for a planned withdrawal: the deposit it belongs to.
String vaultWithdrawalDueRecord(VaultEntry deposit) => deposit.operationKey;

/// The target month doubles as the per-occurrence key.
String vaultWithdrawalDueKey(VaultEntry deposit, String targetMonth) =>
    '$vaultWithdrawalDueType|${vaultWithdrawalDueRecord(deposit)}|$targetMonth';

/// Result of one read-only suggestion pass.
class VaultSuggestionResult {
  const VaultSuggestionResult({
    required this.currentMonth,
    required this.suggested,
    required this.created,
    required this.skipped,
    this.pausedReason,
  });

  final String currentMonth;

  /// Active suggestions after the pass, including ones created earlier.
  final int suggested;

  /// Suggestions created by this pass.
  final int created;

  /// Finished months that could not be valued; reviewed on the Vault screen.
  final List<String> skipped;

  /// Set when the owner is still inside personal setup.
  final String? pausedReason;

  String get message {
    final paused = pausedReason;
    if (paused != null) return paused;
    final review = skipped.isEmpty
        ? ''
        : skipped.length == 1
            ? ' 1 finished month needs review on the Vault screen.'
            : ' ${skipped.length} finished months need review on the Vault screen.';
    if (created > 0) {
      return created == 1
          ? '1 finished month has money left to review. No savings were moved.$review'
          : '$created finished months have money left to review. No savings were moved.$review';
    }
    if (suggested > 0) {
      return suggested == 1
          ? '1 finished month still has money left to review.$review'
          : '$suggested finished months still have money left to review.$review';
    }
    if (skipped.isNotEmpty) {
      return 'Some finished months could not be valued and need review on the '
          'Vault screen. No savings were moved.';
    }
    return 'No finished month has money left to review.';
  }
}

/// Replaces the automatic sweep's discovery half: it only *suggests* a deposit.
///
/// It never writes a [VaultEntry], never changes `SavingsVault.totalMinor` and
/// never advances `lastSweepYearMonth` (022 FR-005, FR-029, contract §Automatic
/// sweep removal). Existing `sweep` rows are legacy history and are not
/// re-suggested for the month they already saved.
class VaultSuggestionService {
  VaultSuggestionService(
    this.db, {
    required this.profileId,
    required this.registry,
    required this.actions,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  final Isar db;
  final int profileId;
  final RateTableRegistry registry;
  final PendingActionService actions;
  final DateTime Function() clock;

  Future<VaultSuggestionResult> check() async {
    final now = clock();
    final currentMonth = _yearMonth(now);
    if (await isPendingSetupOwner(db, profileId)) {
      return VaultSuggestionResult(
        currentMonth: currentMonth,
        suggested: 0,
        created: 0,
        skipped: const [],
        pausedReason:
            'Finish personal setup before checking savings. No savings were changed.',
      );
    }
    final budgets = await db.monthlyBudgets
        .filter()
        .profileIdEqualTo(profileId)
        .sharedSpaceIdIsNull()
        .findAll();
    final finished = budgets
        .where((budget) =>
            budget.openingBalanceConfirmed &&
            budget.yearMonth.compareTo(currentMonth) < 0)
        .toList()
      ..sort((a, b) => a.yearMonth.compareTo(b.yearMonth));

    var created = 0;
    final skipped = <String>[];
    for (final budget in finished) {
      final month = budget.yearMonth;
      if (!_validMonth(month)) {
        skipped.add(month);
        continue;
      }
      if (await _alreadySaved(month)) continue;
      try {
        final funds = await db
            .txn(() => readPersonalMonthFunds(db, profileId, month, registry));
        final available = funds['available'] ?? 0;
        if (available <= 0) continue;
        final owner = await db.userProfiles.get(profileId);
        if (owner == null) continue;
        final existing = await _actionFor(month);
        final wasActive = existing != null && existing.isActive;
        final row = await actions.upsert(PendingActionDraft(
          actionType: vaultDepositSuggestedType,
          title: 'Money left in $month',
          nextAction: 'Review and deposit to Vault',
          feature: 'vault',
          recordRef: vaultDepositSuggestedRecord(profileId, month),
          cycleOrMonth: month,
          expectedAmountMinor: available,
          currency: owner.primaryCurrency.code.code,
          expectedMonth: month,
          priority: 1,
          deepLink: '/vault',
        ));
        if (row.isActive && !wasActive) created++;
      } catch (error, stack) {
        skipped.add(month);
        // Suggestion discovery must never block startup or hide the reason a
        // month cannot be valued; the Vault screen shows the skipped months.
        AppLogger.log('Vault suggestion skipped for $month',
            name: 'Vault', error: error, stackTrace: stack, level: 700);
      }
    }

    final active = await _activeSuggestions();
    return VaultSuggestionResult(
      currentMonth: currentMonth,
      suggested: active.length,
      created: created,
      skipped: List.unmodifiable(skipped),
    );
  }

  Future<bool> _alreadySaved(String month) async {
    // A legacy automatic sweep already saved this month; do not ask again.
    final saved = await db.vaultEntrys
        .filter()
        .profileIdEqualTo(profileId)
        .kindEqualTo('sweep')
        .yearMonthEqualTo(month)
        .count();
    return saved > 0;
  }

  Future<PendingAction?> _actionFor(String month) => db.pendingActions
      .filter()
      .dedupeKeyEqualTo(vaultDepositSuggestedKey(profileId, month))
      .findFirst();

  Future<List<PendingAction>> _activeSuggestions() async {
    final rows = await db.pendingActions
        .filter()
        .profileIdEqualTo(profileId)
        .actionTypeEqualTo(vaultDepositSuggestedType)
        .findAll();
    return rows.where((row) => row.isActive).toList();
  }

  bool _validMonth(String month) =>
      RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(month);

  String _yearMonth(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
}

/// Convenience used by the Vault screen and tests: active suggestions only.
List<PendingAction> activeVaultDepositSuggestions(
  Iterable<PendingAction> actions,
) =>
    actions
        .where((action) =>
            action.actionType == vaultDepositSuggestedType && action.isActive)
        .toList()
      ..sort(
          (a, b) => (a.expectedMonth ?? '').compareTo(b.expectedMonth ?? ''));

/// Deposits that carry a target withdrawal month and have not been reversed or
/// already withdrawn. Pure derivation over immutable Vault history.
class PlannedVaultWithdrawal {
  const PlannedVaultWithdrawal({
    required this.deposit,
    required this.targetMonth,
  });

  final VaultEntry deposit;
  final String targetMonth;

  bool isDue(String currentMonth) => targetMonth.compareTo(currentMonth) <= 0;
}

List<PlannedVaultWithdrawal> plannedWithdrawalsFrom({
  required Iterable<VaultEntry> history,
  required Iterable<PendingAction> actions,
}) {
  final reversed = <String>{};
  for (final entry in history) {
    if (entry.kind != 'reversal') continue;
    final link = transferDetails(entry)?['reverses'];
    if (link is String) reversed.add(link);
  }
  final withdrawn = <String>{};
  for (final action in actions) {
    if (action.actionType != vaultWithdrawalDueType) continue;
    if (action.status != 'completed') continue;
    withdrawn.add(action.dedupeKey);
  }
  final result = <PlannedVaultWithdrawal>[];
  for (final entry in history) {
    if (entry.kind != 'deposit') continue;
    final details = transferDetails(entry);
    if (details == null) continue;
    final target = details['targetWithdrawalMonth'];
    if (target is! String || !_validMonth(target)) continue;
    if (reversed.contains(entry.operationKey) ||
        withdrawn.contains(vaultWithdrawalDueKey(entry, target))) {
      continue;
    }
    result.add(PlannedVaultWithdrawal(deposit: entry, targetMonth: target));
  }
  result.sort((a, b) => a.targetMonth.compareTo(b.targetMonth));
  return result;
}

bool _validMonth(String month) =>
    RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(month);

/// Kept for callers that only need to know whether the Vault balance is valid.
bool validVaultSuggestionAmount(int value) => validVaultAmount(value);

/// Exposed so the Vault screen can show the same month the service uses.
String vaultSuggestionCurrentMonth(DateTime now) =>
    '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
