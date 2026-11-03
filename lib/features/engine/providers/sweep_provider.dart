import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../pending_actions/providers/pending_actions_providers.dart';
import '../../vault/vault_suggestion_service.dart';
import 'rate_registry_provider.dart';

final sweepServiceProvider = Provider<SweepService>((ref) => SweepService(ref));
final sweepResultProvider = StateProvider<SweepResult?>((ref) => null);

enum SweepOutcome { added, paused, unchanged, failed }

class SweepResult {
  const SweepResult(this.profileId, this.outcome, this.addedMinor,
      this.currency, this.message,
      {this.skipped = const []});
  final int? profileId;
  final SweepOutcome outcome;
  final int addedMinor;
  final String currency, message;

  /// Finished months that could not be valued in this pass.
  final List<String> skipped;
}

/// Discovery only. It no longer moves money: every finished month with a
/// positive remainder becomes a `vault.depositSuggested` Pending Action and the
/// user confirms the deposit explicitly (022 FR-005, FR-029).
///
/// The historical name and provider are kept so the cold-start/resume observer
/// and the Vault screen keep one entry point; the body delegates to
/// [VaultSuggestionService].
class SweepService {
  SweepService(this._ref, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;
  final Ref _ref;
  final DateTime Function() _clock;

  Future<SweepResult> executeSweepCheck() async {
    int? id;
    var currency = '';
    SweepResult finish(SweepOutcome outcome, String message,
        {List<String> skipped = const []}) {
      final result =
          SweepResult(id, outcome, 0, currency, message, skipped: skipped);
      _ref.read(sweepResultProvider.notifier).state = result;
      return result;
    }

    try {
      final profile = await _ref.read(activeProfileProvider.future);
      id = profile?.id;
      currency = profile?.primaryCurrency.code.code ?? '';
      final context = _ref.read(budgetContextProvider);
      if (profile == null || context.isShared) {
        return finish(SweepOutcome.unchanged, 'The vault is personal only.');
      }
      if (context.profileId != profile.id ||
          _ref.read(activeProfileProvider).valueOrNull?.id != profile.id) {
        return finish(
            SweepOutcome.unchanged, 'Select the owning personal profile.');
      }
      final result = await VaultSuggestionService(
        IsarHelper.instance,
        profileId: profile.id,
        registry: _ref.read(rateRegistryProvider),
        actions: _ref.read(pendingActionServiceProvider),
        clock: _clock,
      ).check();
      return finish(
          result.pausedReason == null
              ? SweepOutcome.unchanged
              : SweepOutcome.paused,
          result.message,
          skipped: result.skipped);
    } catch (_) {
      return finish(SweepOutcome.failed,
          'The savings check could not finish. No savings were changed; retry safely.');
    }
  }
}
