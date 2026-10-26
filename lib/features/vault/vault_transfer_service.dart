import '../finance/repositories/audit_repository.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:isar/isar.dart';
import '../../core/models/budget_profile.dart';
import '../../core/models/direct_expense_profile.dart';
import '../../core/models/currency_code.dart';
import '../../core/models/expense.dart';
import '../../core/models/income_source.dart';
import '../../core/models/month_end_run.dart';
import '../../core/models/monthly_budget.dart';
import '../../core/models/month_rate_seal.dart';
import '../../core/models/live_rate_set.dart';
import '../../core/models/user_profile.dart';
import '../expenses/models/reimbursement.dart';
import '../engine/providers/rate_registry_provider.dart';
import 'models/savings_vault.dart';
import 'models/vault_entry.dart';
import 'vault_math.dart';
import 'vault_transfer_ledger.dart';
import 'personal_month_funds.dart';

class VaultTransferException implements Exception {
  const VaultTransferException(this.message);
  final String message;
  @override
  String toString() => message;
}

class VaultTransferReadiness {
  const VaultTransferReadiness(
      {required this.month,
      required this.currency,
      required this.balance,
      required this.bank,
      required this.reserve,
      required this.maxDeposit,
      required this.fingerprint,
      this.freeFunds = 0});
  final String month, fingerprint;
  final CurrencyCode currency;
  final int balance, bank, reserve, maxDeposit, freeFunds;
  int get maxWithdrawal => math.max(
      0,
      math.min(
          balance,
          math.min(maxVaultMinor - freeFunds,
              math.min(maxVaultMinor - bank, maxVaultMinor - reserve))));
}

class VaultTransferPreview {
  const VaultTransferPreview(
      {required this.state,
      required this.requestId,
      required this.kind,
      required this.delta,
      required this.note,
      this.reverses});
  final VaultTransferReadiness state;
  final String requestId, kind, note;
  final String? reverses;
  final int delta;
  int get vaultAfter => vaultSum(state.balance, delta);
  int get bankAfter => vaultSum(state.bank, -delta);
  int get freeAfter => vaultSum(state.freeFunds, -delta);
  int get reserveAfter => vaultSum(state.reserve, -delta);
}

/// Reads financial sources under a snapshot and rechecks under the write lock.
/// The immutable VaultEntry is the paired vault/monthly ledger, not new income.
class VaultTransferService {
  VaultTransferService(this.db,
      {required this.actorId,
      required this.isStillActive,
      this.rates,
      DateTime Function()? clock,
      Future<void> Function()? beforeCommit})
      : clock = clock ?? DateTime.now,
        _beforeCommit = beforeCommit;
  final Isar db;
  final int actorId;
  final bool Function() isStillActive;

  /// Test seam. Production reloads persisted rate snapshots under the same lock.
  final RateTableRegistry Function()? rates;
  final DateTime Function() clock;
  final Future<void> Function()? _beforeCommit;

  Never _fail(String message) => throw VaultTransferException(message);
  String _month() {
    final now = clock();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
  }

  void _owner() {
    if (!isStillActive()) {
      _fail('Select the owning personal profile and reopen the transfer.');
    }
  }

  String _key(String request) => 'vault:$actorId:transfer:$request';

  Future<VaultTransferReadiness> readiness() => db.txn(_read);

  Future<VaultTransferPreview> preview(
          {required String kind,
          required int amount,
          required String requestId,
          String note = '',
          String? reverses}) =>
      db.txn(() async {
        final state = await _read();
        final delta = await _validate(state, kind, amount, note, reverses);
        if (!RegExp(r'^[a-zA-Z0-9_-]{1,80}$').hasMatch(requestId)) {
          _fail('The transfer request is invalid. Reopen the form.');
        }
        return VaultTransferPreview(
            state: state,
            requestId: requestId,
            kind: kind,
            delta: delta,
            note: note.trim(),
            reverses: reverses);
      });

  Future<int> _validate(VaultTransferReadiness state, String kind, int amount,
      String note, String? reverses) async {
    if (!validVaultAmount(amount) ||
        amount == 0 ||
        note.trim().length > 120 ||
        !vaultTransferKinds.contains(kind)) {
      _fail(
          'Enter a positive supported amount and a note of at most 120 characters.');
    }
    var delta = kind == 'withdrawal' ? -amount : amount;
    if (kind == 'reversal') {
      if (note.trim().isEmpty || reverses == null) {
        _fail('A reversal requires the original transfer and a reason.');
      }
      final original = await db.vaultEntrys
          .filter()
          .operationKeyEqualTo(reverses)
          .findFirst();
      if (original == null ||
          original.profileId != actorId ||
          !{'deposit', 'withdrawal'}.contains(original.kind) ||
          original.yearMonth != state.month ||
          original.currency != state.currency.code ||
          transferDetails(original) == null ||
          original.amountMinor.abs() != amount) {
        _fail(
            'Only a full transfer from the current unsettled month can be reversed.');
      }
      for (final entry in await db.vaultEntrys
          .filter()
          .profileIdEqualTo(actorId)
          .findAll()) {
        if (entry.kind == 'reversal' &&
            transferDetails(entry)?['reverses'] == reverses) {
          _fail('This transfer has already been reversed.');
        }
      }
      delta = -original.amountMinor;
    } else if (reverses != null) {
      _fail('Only a reversal may link an original transfer.');
    }
    if (delta > 0 && delta > state.maxDeposit) {
      _fail(
          'The amount exceeds funds available after allocations, carry and borrowing.');
    }
    if (delta < 0 && -delta > state.maxWithdrawal) {
      _fail(
          'The withdrawal exceeds savings or the supported monthly balance range.');
    }
    if (!validVaultAmount(vaultSum(state.balance, delta))) {
      _fail('The resulting savings balance is outside the supported range.');
    }
    vaultSum(state.bank, -delta);
    vaultSum(state.reserve, -delta);
    vaultSum(state.freeFunds, -delta);
    return delta;
  }

  Future<VaultEntry> confirm(VaultTransferPreview preview) =>
      db.writeTxn(() async {
        _owner();
        if (!RegExp(r'^[a-zA-Z0-9_-]{1,80}$').hasMatch(preview.requestId)) {
          _fail('Invalid transfer request.');
        }
        final key = _key(preview.requestId);
        final existing =
            await db.vaultEntrys.filter().operationKeyEqualTo(key).findFirst();
        if (existing != null) {
          final details = transferDetails(existing);
          if (existing.profileId != actorId ||
              existing.kind != preview.kind ||
              existing.amountMinor != preview.delta ||
              existing.yearMonth != preview.state.month ||
              existing.currency != preview.state.currency.code ||
              details == null ||
              details['note'] != preview.note ||
              details['reverses'] != preview.reverses) {
            _fail('This request already belongs to a different transfer.');
          }
          return existing;
        }
        final current = await _read();
        if (current.fingerprint != preview.state.fingerprint) {
          _fail(
              'The balances or records changed. Review a fresh preview before confirming.');
        }
        final delta = await _validate(current, preview.kind,
            preview.delta.abs(), preview.note, preview.reverses);
        if (delta != preview.delta) {
          _fail('The transfer direction changed. Reopen the form.');
        }
        final vault = (await db.savingsVaults
            .filter()
            .profileIdEqualTo(actorId)
            .findFirst())!;
        final entry = VaultEntry()
          ..profileId = actorId
          ..operationKey = key
          ..kind = preview.kind
          ..yearMonth = current.month
          ..currency = current.currency.code
          ..amountMinor = delta
          ..balanceAfterMinor = vaultSum(current.balance, delta)
          ..createdAt = clock()
          ..reason = preview.note.isEmpty ? null : preview.note
          ..breakdownJson = jsonEncode({
            'version': 2,
            'freeBefore': current.freeFunds,
            'freeAfter': vaultSum(current.freeFunds, -delta),
            'month': current.month,
            'currency': current.currency.code,
            'vaultDelta': delta,
            'monthDelta': -delta,
            'vaultBefore': current.balance,
            'bankBefore': current.bank,
            'bankAfter': vaultSum(current.bank, -delta),
            'reserveBefore': current.reserve,
            'reserveAfter': vaultSum(current.reserve, -delta),
            'note': preview.note,
            'reverses': preview.reverses
          });
        entry.id = await AuditRepository(db, actorId: actorId)
            .put(db.vaultEntrys, entry, id: entry.id, type: 'VaultEntry');
        await _beforeCommit?.call();
        _owner();
        if (_month() != current.month) {
          _fail('The month changed. Review a fresh preview.');
        }
        vault
          ..totalMinor = entry.balanceAfterMinor
          ..updatedAt = clock();
        await db.savingsVaults.put(vault);
        return entry;
      });

  Future<VaultTransferReadiness> _read() async {
    _owner();
    final registry = rates?.call() ??
        RateTableRegistry(
          sealedTables: {
            for (final row in await db.monthRateSeals.where().findAll())
              if (row.toRateTable() != null) row.yearMonth: row.toRateTable()!
          },
          liveTable: (await db.liveRateSets.where().findFirst())?.toRateTable(),
        );
    final month = _month();
    final owner = await db.userProfiles.get(actorId);
    final vault =
        await db.savingsVaults.filter().profileIdEqualTo(actorId).findFirst();
    if (owner == null || vault == null) {
      _fail('Open the vault and check finished months before transferring.');
    }
    final currency = owner.primaryCurrency.code;
    if (vault.currency != currency.code) {
      _fail('Personal accounting and vault currencies must match.');
    }
    final entries =
        await db.vaultEntrys.filter().profileIdEqualTo(actorId).findAll();
    final problem = vaultEntriesProblem(vault, entries);
    if (problem != null || entries.isEmpty) {
      _fail(problem ?? 'Vault opening history needs review.');
    }
    if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$')
            .hasMatch(vault.lastSweepYearMonth) ||
        vault.lastSweepYearMonth.compareTo(month) > 0 ||
        entries.any((e) => e.kind == 'sweep' && e.yearMonth == month)) {
      _fail(
          'This month was already swept or the saved month position needs review.');
    }
    final budget = await db.monthlyBudgets
        .filter()
        .profileIdEqualTo(actorId)
        .sharedSpaceIdIsNull()
        .yearMonthEqualTo(month)
        .findFirst();
    if (budget == null || !budget.openingBalanceConfirmed) {
      _fail('Confirm the current month opening funds before transferring.');
    }
    final seal =
        await db.monthRateSeals.filter().yearMonthEqualTo(month).findFirst();
    if (seal != null && seal.status != SealStatus.open) {
      _fail('The current month is sealed and cannot receive manual transfers.');
    }
    final runs = await db.monthEndRuns
        .filter()
        .profileIdEqualTo(actorId)
        .sharedSpaceIdIsNull()
        .findAll();
    if (runs.any((r) =>
        r.yearMonth == month ||
        (r.destinationMonth == month && (!r.applied || r.hasConflict)))) {
      _fail(
          'The current month has a Month-End settlement or carry needing review.');
    }
    final Map<String, int> funds;
    try {
      funds = await readPersonalMonthFunds(db, actorId, month, registry);
    } on FormatException catch (error) {
      _fail(error.message);
    }
    final bank = funds['bank']!;
    final reserve = funds['reserve']!;
    final freeFunds = funds['available']!;
    final capacity =
        math.max(0, math.min(maxVaultMinor - vault.totalMinor, freeFunds));
    // Fingerprint complete persisted source rows, not just visible totals.
    final fingerprint = sha256
        .convert(utf8.encode(jsonEncode({
          'owner':
              await db.userProfiles.filter().idEqualTo(actorId).exportJson(),
          'vault': await db.savingsVaults
              .filter()
              .profileIdEqualTo(actorId)
              .exportJson(),
          'history': await db.vaultEntrys
              .filter()
              .profileIdEqualTo(actorId)
              .exportJson(),
          'budget': await db.monthlyBudgets
              .filter()
              .profileIdEqualTo(actorId)
              .sharedSpaceIdIsNull()
              .yearMonthEqualTo(month)
              .exportJson(),
          'profiles': await db.budgetProfiles
              .filter()
              .profileIdEqualTo(actorId)
              .sharedSpaceIdIsNull()
              .yearMonthEqualTo(month)
              .exportJson(),
          'directs': await db.directExpenseProfiles
              .filter()
              .profileIdEqualTo(actorId)
              .sharedSpaceIdIsNull()
              .yearMonthEqualTo(month)
              .exportJson(),
          'expenses': await db.expenses
              .filter()
              .profileIdEqualTo(actorId)
              .sharedSpaceIdIsNull()
              .yearMonthEqualTo(month)
              .exportJson(),
          'returns': await db.reimbursements
              .filter()
              .profileIdEqualTo(actorId)
              .sharedSpaceIdIsNull()
              .originYearMonthEqualTo(month)
              .exportJson(),
          'income': await db.incomeSources
              .filter()
              .profileIdEqualTo(actorId)
              .sharedSpaceIdIsNull()
              .exportJson(),
          'runs': await db.monthEndRuns
              .filter()
              .profileIdEqualTo(actorId)
              .sharedSpaceIdIsNull()
              .exportJson(),
          'month': month,
          'bank': bank,
          'reserve': reserve,
          'capacity': capacity,
          'freeFunds': freeFunds,
          'rates': {
            for (final m in {month, ...runs.map((r) => r.yearMonth)})
              m: {
                for (final rate in registry.tableFor(m)?.usdRates.entries ??
                    <MapEntry<CurrencyCode, double>>[])
                  rate.key.code: rate.value
              }
          },
        })))
        .toString();
    _owner();
    return VaultTransferReadiness(
        month: month,
        currency: currency,
        balance: vault.totalMinor,
        bank: bank,
        reserve: reserve,
        maxDeposit: capacity,
        freeFunds: freeFunds,
        fingerprint: fingerprint);
  }
}
