import '../../finance/repositories/audit_repository.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/models/budget_profile.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/month_end_run.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/money.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/month_end_report.dart';
import '../../vault/models/savings_vault.dart';
import '../../vault/models/vault_entry.dart';
import '../../vault/vault_math.dart';
import '../../vault/personal_month_funds.dart';
import '../../../core/services/free_funds.dart';
import '../currency_resolution.dart';
import 'rate_registry_provider.dart';
import '../../budget_setup/domain/onboarding_automation_guard.dart';

final sweepServiceProvider = Provider<SweepService>((ref) => SweepService(ref));
final sweepResultProvider = StateProvider<SweepResult?>((ref) => null);

enum SweepOutcome { added, paused, unchanged, failed }

class SweepResult {
  const SweepResult(this.profileId, this.outcome, this.addedMinor,
      this.currency, this.message);
  final int? profileId;
  final SweepOutcome outcome;
  final int addedMinor;
  final String currency, message;
}

class _Step {
  const _Step({this.added = 0, this.done = false, this.pause});
  final int added;
  final bool done;
  final String? pause;
}

/// Each month's inputs, balance, history and NEXT-month cursor share one write
/// transaction. Isar serialization protects checks across service instances.
/// No network work occurs here. A later pause preserves earlier monthly commits.
class SweepService {
  SweepService(this._ref,
      {DateTime Function()? clock, Future<void> Function()? beforeCommit})
      : _clock = clock ?? DateTime.now,
        _beforeCommit = beforeCommit;
  final Ref _ref;
  final DateTime Function() _clock;
  // Fault injection for transaction rollback tests; production leaves this null.
  final Future<void> Function()? _beforeCommit;

  Future<SweepResult> executeSweepCheck() async {
    int? id;
    var added = 0;
    var currency = '';
    SweepResult finish(SweepOutcome outcome, String message) {
      final result = SweepResult(id, outcome, added, currency, message);
      _ref.read(sweepResultProvider.notifier).state = result;
      return result;
    }

    try {
      final profile = await _ref.read(activeProfileProvider.future);
      id = profile?.id;
      currency = profile?.primaryCurrency.code.code ?? '';
      if (profile == null || _ref.read(budgetContextProvider).isShared) {
        return finish(SweepOutcome.unchanged, 'The vault is personal only.');
      }
      final isar = IsarHelper.instance;
      if (await isPendingSetupOwner(isar, id!)) {
        return finish(SweepOutcome.paused,
            'Finish personal setup before checking savings. No savings were changed.');
      }
      final now = _clock();
      final currentMonth = _yearMonth(now);
      while (true) {
        final step = await isar.writeTxn(() async {
          if (await isPendingSetupOwner(isar, id!)) {
            return const _Step(
                done: true,
                pause:
                    'Finish personal setup before checking savings. No savings were changed.');
          }
          if (_ref.read(budgetContextProvider).isShared ||
              _ref.read(budgetContextProvider).profileId != id ||
              _ref.read(activeProfileProvider).valueOrNull?.id != id) {
            return const _Step(done: true);
          }
          final owner = await isar.userProfiles.get(id!);
          if (owner == null) return const _Step(done: true);
          var vault = await isar.savingsVaults
              .filter()
              .profileIdEqualTo(id!)
              .findFirst();
          if (vault == null) {
            vault = SavingsVault()
              ..profileId = id!
              ..currency = owner.primaryCurrency.code.code
              ..lastSweepYearMonth = currentMonth
              ..updatedAt = now;
            await isar.savingsVaults.put(vault);
            await seedVaultOpeningInTxn(isar, vault, now);
            currency = vault.currency;
            return const _Step(done: true);
          }
          currency = vault.currency;
          final integrityProblem = await vaultHistoryProblem(isar, vault);
          if (integrityProblem != null) {
            return await _pause(isar, vault, integrityProblem, now);
          }
          await seedVaultOpeningInTxn(isar, vault, now);
          final month = vault.lastSweepYearMonth;
          if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(month) ||
              month.compareTo(currentMonth) > 0) {
            return await _pause(
                isar, vault, 'The saved month position needs review.', now);
          }
          if (month == currentMonth) {
            vault
              ..sweepPaused = false
              ..pauseReason = null
              ..updatedAt = now;
            await isar.savingsVaults.put(vault);
            return const _Step(done: true);
          }
          final code = vault.currencyCode;
          if (code == null) {
            return await _pause(
                isar,
                vault,
                'The saved vault currency is unsupported. Review the existing vault; changing the profile currency does not convert savings.',
                now);
          }
          final budget = await isar.monthlyBudgets
              .filter()
              .profileIdEqualTo(id!)
              .sharedSpaceIdIsNull()
              .yearMonthEqualTo(month)
              .findFirst();
          if (budget == null) {
            vault
              ..lastSweepYearMonth = nextFinancialMonth(month)
              ..sweepPaused = false
              ..pauseReason = null
              ..updatedAt = now;
            await isar.savingsVaults.put(vault);
            return const _Step();
          }
          if (!budget.openingBalanceConfirmed) {
            return await _pause(
                isar,
                vault,
                'Set the opening balance for $month before it can be swept.',
                now);
          }
          final settlement = await isar.monthEndRuns
              .filter()
              .profileIdEqualTo(id!)
              .sharedSpaceIdIsNull()
              .yearMonthEqualTo(month)
              .findFirst();
          final hasProfiles = await isar.budgetProfiles
                  .filter()
                  .profileIdEqualTo(id!)
                  .sharedSpaceIdIsNull()
                  .yearMonthEqualTo(month)
                  .count() >
              0;
          if ((hasProfiles && settlement == null) ||
              settlement?.hasConflict == true ||
              settlement?.applied == false) {
            return await _pause(
                isar,
                vault,
                'Review Month-End for $month before sweeping it into the vault.',
                now);
          }
          var financialWriteStarted = false;
          try {
            final display =
                resolveDisplayCurrency(month: budget, profile: owner);
            final table = _ref.read(rateRegistryProvider).tableFor(month);
            final conversions = <Map<String, dynamic>>[];
            void explain(String label, Money from, Money to) {
              if (from.currency == to.currency) return;
              conversions.add({
                'label': label,
                'from': from.currency.code,
                'original': from.minorUnits,
                'to': to.currency.code,
                'converted': to.minorUnits,
                'rate': table?.crossRate(from.currency, to.currency)
              });
            }

            final funds = await readPersonalMonthFunds(
                isar, id!, month, _ref.read(rateRegistryProvider));
            final sourceOpening = vaultOpening(
                budget.baseAvailableAmount, owner.primaryCurrency.code)!;
            final opening = vaultConvert(sourceOpening, display, table);
            if (opening == null) {
              throw const FormatException('Opening funds cannot be valued.');
            }
            final parts = <String, int>{};
            for (final key in [
              'income',
              'spent',
              'returned',
              'unused',
              'carry',
              'incoming',
              'released',
              'vaultTransfers'
            ]) {
              final original = Money(funds[key]!, owner.primaryCurrency.code);
              final value = vaultConvert(original, display, table);
              if (value == null) {
                throw const FormatException('Monthly funds cannot be valued.');
              }
              parts[key] = value.minorUnits;
              explain(key, original, value);
            }
            final spent = parts['spent']!,
                returned = parts['returned']!,
                carry = parts['carry']!;
            final available = freeToSpend(
                    income: parts['income']!,
                    paid: spent,
                    returned: returned,
                    unused: parts['unused']!,
                    carry: carry,
                    incoming: parts['incoming']!,
                    released: parts['released']!,
                    transfers: parts['vaultTransfers']!)
                .toInt();
            final positive = available > 0 ? available : 0;
            final converted =
                vaultConvert(Money(positive, display), code, table);
            if (converted == null) {
              return await _pause(
                  isar,
                  vault,
                  'No exchange rate is available to move $month into the vault.',
                  now);
            }
            final amount = converted.minorUnits;
            explain('Saved to vault', Money(positive, display), converted);
            final nextTotal = vaultSum(vault.totalMinor, amount);
            if (vault.totalMinor < 0 ||
                nextTotal > 9007199254740991 ||
                amount < 0) {
              return await _pause(
                  isar,
                  vault,
                  'The savings balance is outside the supported amount range.',
                  now);
            }
            final key = 'vault:$id:month:$month';
            if (await isar.vaultEntrys
                    .filter()
                    .operationKeyEqualTo(key)
                    .count() >
                0) {
              return await _pause(
                  isar,
                  vault,
                  'Saved history and the month position disagree. Review $month.',
                  now);
            }
            financialWriteStarted = true;
            await isar.vaultEntrys.put(VaultEntry()
              ..operationKey = key
              ..profileId = id!
              ..kind = 'sweep'
              ..yearMonth = month
              ..amountMinor = amount
              ..currency = code.code
              ..balanceAfterMinor = nextTotal
              ..createdAt = now
              ..reason = available <= 0
                  ? 'No positive funds remained after spending, returns and reserved carry.'
                  : (amount == 0
                      ? 'The positive remainder rounded below one vault currency minor unit.'
                      : null)
              ..breakdownJson = jsonEncode({
                'formulaVersion': 2,
                'income': parts['income'],
                'unused': parts['unused'],
                'incoming': parts['incoming'],
                'released': parts['released'],
                'currency': display.code,
                'opening': opening.minorUnits,
                'spent': spent,
                'returned': returned,
                'carry': carry,
                'vaultTransfers': parts['vaultTransfers'],
                'available': available,
                'beforeConversion': positive,
                'vaultCurrency': code.code,
                'rate': table?.crossRate(display, code),
                'rateSource': table?.source.name,
                'rateAsOf': table?.asOf.toIso8601String(),
                'usdRates': table?.usdRates.map((k, v) => MapEntry(k.code, v)),
                'openingCurrency': owner.primaryCurrency.code.code,
                'openingMajor': budget.baseAvailableAmount,
                'conversions': conversions,
              }));
            final committedEntry = await isar.vaultEntrys
                .filter()
                .operationKeyEqualTo(key)
                .findFirst();
            await AuditRepository(isar, actorId: id).change(
                type: 'VaultEntry',
                before: null,
                after: await AuditRepository(isar)
                    .snapshot(isar.vaultEntrys, committedEntry!.id),
                action: 'vault.sweep');
            await _beforeCommit?.call();
            vault
              ..totalMinor = nextTotal
              ..lastSweepYearMonth = nextFinancialMonth(month)
              ..sweepPaused = false
              ..pauseReason = null
              ..updatedAt = now;
            await isar.savingsVaults.put(vault);
            return _Step(added: amount);
          } on FormatException catch (error) {
            if (financialWriteStarted) rethrow;
            return await _pause(isar, vault, error.message, now);
          }
        });
        added += step.added;
        if (step.pause != null) return finish(SweepOutcome.paused, step.pause!);
        if (step.done) {
          return finish(
              added > 0 ? SweepOutcome.added : SweepOutcome.unchanged,
              added > 0
                  ? 'Savings added from finished months.'
                  : 'No new savings were added.');
        }
      }
    } catch (_) {
      // Current month rolls back; previously committed months remain safe.
      return finish(SweepOutcome.failed,
          'The check could not finish. Completed contributions are saved; retry safely.');
    }
  }

  Future<_Step> _pause(
      Isar isar, SavingsVault vault, String reason, DateTime now) async {
    vault
      ..sweepPaused = true
      ..pauseReason = reason
      ..updatedAt = now;
    await isar.savingsVaults.put(vault);
    return _Step(pause: reason);
  }

  String _yearMonth(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';
}
