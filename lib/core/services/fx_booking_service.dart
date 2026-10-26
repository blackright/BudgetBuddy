import 'package:isar/isar.dart';
import '../models/expense.dart';
import '../models/fx_revision.dart';
import '../models/currency_code.dart';
import '../models/user_profile.dart';
import '../models/shared_space.dart';
import '../models/month_rate_seal.dart';
import '../models/live_rate_set.dart';
import '../models/money.dart';
import '../providers/selected_month_provider.dart';
import '../../features/expenses/models/reimbursement.dart';
import '../../features/engine/providers/rate_registry_provider.dart';
import '../../features/sync/domain/sync_guid.dart';

bool fxPaid(ExpenseStatus status) =>
    status != ExpenseStatus.planned && status != ExpenseStatus.cancelled;

FxHistory? expenseFx(Expense expense) {
  final history = FxHistory.decode(expense.fxHistoryJson);
  if (history != null) {
    if (history.current.target != expense.syncGuid ||
        history.current.kind != 'expense') {
      throw const FormatException(
          'FX evidence belongs to another transaction.');
    }
    if (fxPaid(expense.status)) {
      history.matches(
          expense.syncGuid, expense.amount, expense.currency, 'expense');
    }
  }
  return history;
}

FxHistory? reimbursementFx(Reimbursement refund) {
  final history = FxHistory.decode(refund.fxHistoryJson);
  if (history != null) {
    history.matches(refund.syncGuid, refund.amount, refund.currency, 'refund');
  }
  return history;
}

Money expenseAccountingMoney(Expense e, {CurrencyCode? expectedCurrency}) {
  final booked = fxPaid(e.status) ? expenseFx(e)?.current.money : null;
  if (booked != null &&
      expectedCurrency != null &&
      booked.currency != expectedCurrency) {
    throw const FormatException(
        'Booked accounting currency changed and needs review.');
  }
  return booked ??
      Money(
          e.amount,
          e.currencyCode ??
              (throw const FormatException('Unsupported expense currency.')));
}

Money reimbursementAccountingMoney(Reimbursement r,
    {CurrencyCode? expectedCurrency}) {
  final booked = reimbursementFx(r)?.current.money;
  if (booked != null &&
      expectedCurrency != null &&
      booked.currency != expectedCurrency) {
    throw const FormatException(
        'Booked refund accounting currency changed and needs review.');
  }
  return booked ??
      Money(
          r.amount,
          r.currencyCode ??
              (throw const FormatException('Unsupported refund currency.')));
}

Future<RateTableRegistry> readFxRates(Isar db) async =>
    RateTableRegistry(sealedTables: {
      for (final seal in await db.monthRateSeals.where().findAll())
        if (seal.toRateTable() != null) seal.yearMonth: seal.toRateTable()!
    }, liveTable: (await db.liveRateSets.where().findFirst())?.toRateTable());

/// Caller holds the financial write transaction. Evidence is embedded in the
/// same signed expense/refund aggregate, so bytes cannot arrive separately.
class FxBookingService {
  const FxBookingService(this.db);
  final Isar db;
  Future<void> validateRemoteExpense(Expense value, Expense? previous,
      {required bool carriesFx}) async {
    if (!carriesFx && previous?.fxHistoryJson != null) {
      if (previous!.amount != value.amount ||
          previous.currencyCode != value.currencyCode ||
          previous.status != value.status ||
          previous.yearMonth != value.yearMonth) {
        throw StateError(
            'Update this booked transaction with an FX-compatible app.');
      }
      value.fxHistoryJson = previous.fxHistoryJson;
    }
    final incoming = expenseFx(value),
        old =
            previous == null ? null : FxHistory.decode(previous.fxHistoryJson);
    if (old != null && incoming == null) {
      throw StateError('Booked FX evidence cannot be removed.');
    }
    incoming?.extendsHistory(old);
    if (incoming != null) {
      final (base, context) =
          await _context(value.profileId, value.sharedSpaceId);
      if (incoming.current.context != context ||
          incoming.current.money.currency != base) {
        throw StateError('Remote booked FX context/currency needs review.');
      }
    }
    if (previous != null &&
        (previous.amount != value.amount ||
            previous.currencyCode != value.currencyCode) &&
        await db.reimbursements.filter().expenseIdEqualTo(previous.id).count() >
            0) {
      throw StateError('Refunded payment cannot be rewritten.');
    }
  }

  Future<void> validateRemoteRefund(
      Reimbursement value, Reimbursement? previous,
      {required bool carriesFx}) async {
    if (!carriesFx && previous?.fxHistoryJson != null) {
      if (previous!.amount != value.amount ||
          previous.currencyCode != value.currencyCode ||
          previous.originYearMonth != value.originYearMonth) {
        throw StateError('Update this refund with an FX-compatible app.');
      }
      value.fxHistoryJson = previous.fxHistoryJson;
    }
    final incoming = reimbursementFx(value),
        old =
            previous == null ? null : FxHistory.decode(previous.fxHistoryJson);
    if (old != null && incoming == null) {
      throw StateError('Booked refund evidence cannot be removed.');
    }
    incoming?.extendsHistory(old);
    if (incoming != null) {
      final (baseCurrency, context) =
          await _context(value.profileId, value.sharedSpaceId);
      final parent = value.expenseId == null
          ? null
          : await db.expenses.get(value.expenseId!);
      final history = parent == null ? null : expenseFx(parent);
      if (parent == null && value.orphaned) {
        // FR-035 retains actual returned money after its expense is deleted.
        // The signed, self-contained evidence is retained and the unresolved
        // target stays explicitly flagged; it is never reconstructed/revalued.
        if (incoming.current.context != context ||
            incoming.current.money.currency != baseCurrency ||
            (old != null && incoming.encode() != old.encode())) {
          throw StateError('Orphaned refund accounting evidence needs review.');
        }
        return;
      }
      if (incoming.current.context != context ||
          history == null ||
          history.current.id != incoming.current.expenseRevision ||
          history.current.originalMinor !=
              incoming.current.parentOriginalMinor ||
          history.current.baseMinor != incoming.current.parentBaseMinor ||
          parent!.currencyCode != value.currencyCode ||
          history.current.baseCurrency != incoming.current.baseCurrency ||
          history.current.numerator != incoming.current.numerator ||
          history.current.denominator != incoming.current.denominator ||
          parent.sharedSpaceId != value.sharedSpaceId ||
          (parent.sharedSpaceId == null &&
              parent.profileId != value.profileId) ||
          value.originYearMonth !=
              (parent.type == ExpenseType.medical
                  ? nextMonth(parent.yearMonth)
                  : parent.yearMonth)) {
        throw StateError(
            'Original booked payment is missing or differs. Retry sync after resolving its FX evidence.');
      }
      if (old != null &&
          parent.type != ExpenseType.medical &&
          incoming.encode() != old.encode()) {
        throw StateError('A recorded ordinary refund cannot be rewritten.');
      }
      final end = incoming.current.cumulativeOriginalMinor!;
      final start = end - value.amount;
      for (final other in await db.reimbursements
          .filter()
          .expenseIdEqualTo(parent.id)
          .findAll()) {
        if (other.id == previous?.id) continue;
        final booked = reimbursementFx(other)?.current;
        if (booked == null || booked.expenseRevision != history.current.id) {
          throw StateError('Existing refund FX evidence needs review.');
        }
        final otherEnd = booked.cumulativeOriginalMinor!;
        if (start < otherEnd && otherEnd - other.amount < end) {
          throw StateError(
              'Concurrent refunds overlap. Resolve the payment history before retrying sync.');
        }
      }
    }
  }

  Future<(CurrencyCode, String)> _context(int profile, int? space) async {
    if (space != null) {
      final row = await db.sharedSpaces.get(space);
      if (row == null) throw StateError('FX context no longer exists.');
      return (row.currency.code, 'space:${row.syncGuid}');
    }
    final row = await db.userProfiles.get(profile);
    if (row == null) throw StateError('FX profile no longer exists.');
    return (row.primaryCurrency.code, 'personal:$profile');
  }

  Future<void> prepareExpense(Expense expense) async {
    final previous = await db.expenses.get(expense.id);
    final old =
        previous == null ? null : FxHistory.decode(previous.fxHistoryJson);
    if (previous != null) expenseFx(previous);
    if (previous != null) {
      if (expense.fxHistoryJson != null &&
          expense.fxHistoryJson != previous.fxHistoryJson) {
        throw StateError('FX history cannot be edited.');
      }
      expense.fxHistoryJson = previous.fxHistoryJson;
      final returned = await db.reimbursements
          .filter()
          .expenseIdEqualTo(previous.id)
          .count();
      if (returned > 0 &&
          (previous.amount != expense.amount ||
              previous.currencyCode != expense.currencyCode)) {
        throw StateError(
            'Amount and currency are protected because this expense has refunds.');
      }
    } else if (expense.fxHistoryJson != null) {
      throw StateError('New local expense cannot supply its own booked FX.');
    }
    if (!fxPaid(expense.status)) return;
    if (previous != null && fxPaid(previous.status) && old == null) {
      return; // labelled legacy, never guessed/backfilled
    }
    final (base, context) =
        await _context(expense.profileId, expense.sharedSpaceId);
    if (old != null &&
        (old.current.context != context ||
            old.current.money.currency != base)) {
      throw StateError(
          'Booked accounting currency/context changed. Review the original transaction.');
    }
    final original = expense.currencyCode;
    if (original == null || expense.amount < 0) {
      throw StateError('Cannot book this amount/currency.');
    }
    if (old != null &&
        previous != null &&
        fxPaid(previous.status) &&
        expense.amount == previous.amount &&
        original == previous.currencyCode) {
      return;
    }
    String numerator, denominator, source, asOf;
    if (old != null &&
        previous != null &&
        fxPaid(previous.status) &&
        original == previous.currencyCode) {
      numerator = old.current.numerator;
      denominator = old.current.denominator;
      source = old.current.source;
      asOf = old.current.asOf;
    } else if (original == base) {
      numerator = '1';
      denominator = '1';
      source = 'Same currency';
      asOf = DateTime.now().toUtc().toIso8601String();
    } else {
      final rates = await readFxRates(db),
          table = rates.tableFor(expense.yearMonth);
      if (table == null) throw StateError('Exchange rate unavailable.');
      final from = fxDecimal(table.usdRate(original).toString()),
          to = fxDecimal(table.usdRate(base).toString());
      final n = to.$1 * from.$2, d = to.$2 * from.$1, gcd = n.gcd(d);
      numerator = (n ~/ gcd).toString();
      denominator = (d ~/ gcd).toString();
      source =
          '${table.source.name}${table.isStale ? ' (stale)' : ''}; ${expense.yearMonth}';
      asOf = table.asOf.toUtc().toIso8601String();
    }
    final row = FxRevision(
        id: newSyncGuid(),
        target: expense.syncGuid,
        context: context,
        kind: 'expense',
        originalMinor: expense.amount,
        originalCurrency: original.code.toUpperCase(),
        baseMinor: fxConvertMinor(
            expense.amount, original, base, numerator, denominator),
        baseCurrency: base.code.toUpperCase(),
        numerator: numerator,
        denominator: denominator,
        source: source,
        asOf: asOf,
        capturedAt: DateTime.now().toUtc().toIso8601String(),
        previousHash: old?.current.hash ?? '');
    expense.fxHistoryJson = FxHistory([...?old?.revisions, row]).encode();
  }

  Future<void> prepareRefund(Reimbursement refund) async {
    final previous = await db.reimbursements.get(refund.id);
    final oldHistory = previous == null ? null : reimbursementFx(previous);
    final expense = refund.expenseId == null
        ? null
        : await db.expenses.get(refund.expenseId!);
    if (previous != null) {
      if (oldHistory != null &&
          (refund.currencyCode != previous.currencyCode ||
              refund.expenseId != previous.expenseId ||
              refund.originYearMonth != previous.originYearMonth)) {
        throw StateError('Booked refund money cannot be rewritten.');
      }
      if (oldHistory != null &&
          refund.amount != previous.amount &&
          expense?.type != ExpenseType.medical) {
        throw StateError('Booked refund money cannot be rewritten.');
      }
      if (refund.fxHistoryJson != null &&
          refund.fxHistoryJson != previous.fxHistoryJson) {
        throw StateError('Refund FX history cannot be edited.');
      }
      refund.fxHistoryJson = previous.fxHistoryJson;
      if (oldHistory == null || refund.amount == previous.amount) return;
    }
    if (previous == null && refund.fxHistoryJson != null) {
      throw StateError('New local refund cannot supply booked FX.');
    }
    if (expense == null) {
      return; // existing orphan/legacy validation remains authoritative
    }
    final history = expenseFx(expense);
    if (history == null) return;
    if (expense.sharedSpaceId != refund.sharedSpaceId ||
        (expense.sharedSpaceId == null &&
            expense.profileId != refund.profileId) ||
        (expense.type == ExpenseType.medical
                ? nextMonth(expense.yearMonth)
                : expense.yearMonth) !=
            refund.originYearMonth ||
        expense.currencyCode != refund.currencyCode) {
      throw StateError('Refund differs from its booked payment context.');
    }
    final (_, context) =
        await _context(expense.profileId, expense.sharedSpaceId);
    if (context != history.current.context) {
      throw StateError('Refund FX context changed.');
    }
    final prior =
        await db.reimbursements.filter().expenseIdEqualTo(expense.id).findAll();
    var original = 0, base = 0;
    for (final old in prior.where((r) => r.id != previous?.id)) {
      final booked = reimbursementFx(old);
      if (booked == null ||
          booked.current.expenseRevision != history.current.id) {
        throw StateError('Refund history has incomplete booked FX evidence.');
      }
      original = checkedFxMinor(original + old.amount);
      base = checkedFxMinor(base + booked.current.baseMinor);
    }
    original = checkedFxMinor(original + refund.amount);
    if (refund.amount <= 0 || original > expense.amount) {
      throw StateError('Refund exceeds the original booked payment.');
    }
    final paid = history.current;
    final cumulative = fxRound(
        BigInt.from(paid.baseMinor) * BigInt.from(original),
        BigInt.from(expense.amount));
    refund.fxHistoryJson = FxHistory([
      ...?oldHistory?.revisions,
      FxRevision(
          id: newSyncGuid(),
          target: refund.syncGuid,
          context: context,
          kind: 'refund',
          originalMinor: refund.amount,
          originalCurrency: paid.originalCurrency,
          baseMinor: cumulative - base,
          baseCurrency: paid.baseCurrency,
          numerator: paid.numerator,
          denominator: paid.denominator,
          source: paid.source,
          asOf: paid.asOf,
          capturedAt: DateTime.now().toUtc().toIso8601String(),
          previousHash: oldHistory?.current.hash ?? '',
          expenseRevision: paid.id,
          parentOriginalMinor: paid.originalMinor,
          parentBaseMinor: paid.baseMinor,
          cumulativeOriginalMinor: original,
          priorRefundBaseMinor: base)
    ]).encode();
  }
}
