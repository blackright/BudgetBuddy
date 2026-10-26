import '../repositories/merchant_repository.dart';
import '../../../core/models/expense_purchase.dart';
import '../../../core/models/context_kind.dart';
import '../../../core/services/purchase_policy.dart';
import '../models/reimbursement.dart';
import '../repositories/expense_evidence_repository.dart';
import '../../../core/services/expense_evidence.dart';
import '../../finance/repositories/audit_repository.dart';
import '../../sync/repositories/sync_recorder.dart';
import '../../sync/providers/sync_recorder_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/budget_profile.dart';
import '../../../core/models/direct_expense_profile.dart';
import '../../../core/models/money.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/category.dart';
import '../../../core/models/month_end_run.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/bulk_entry_service.dart';
import '../../../core/services/profile_spending_service.dart';
import '../../../core/services/expense_profile_identity.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/expense_delta.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../spaces/repositories/space_write_guard.dart';

final expensesProvider =
    StateNotifierProvider<ExpensesNotifier, AsyncValue<List<Expense>>>((ref) {
  final activeBudgetAsync = ref.watch(activeBudgetProvider);
  final guard = ref.watch(spaceWriteGuardProvider);
  final actingProfileId = ref.watch(actingProfileIdProvider);

  // Convert an expense snapshot (its own currency, minor units) into the active
  // month's display currency (major units) through the live rate table. This
  // mirrors the engine's own conversion so the returned delta is a real money
  // movement rather than a raw minor-unit cast (T-R05).
  double toPrimary(ExpenseSnapshot snapshot) {
    final code = snapshot.currency;
    if (code == null) return 0.0;
    final budget = ref.read(activeBudgetProvider).value;
    final profile = ref.read(activeProfileProvider).value;
    final display = resolveDisplayCurrency(month: budget, profile: profile);
    final table = ref
        .read(rateRegistryProvider)
        .tableFor(ref.read(selectedYearMonthProvider));
    return toDisplay(Money(snapshot.amount, code), display, table).majorValue;
  }

  return activeBudgetAsync.when(
    data: (budget) {
      if (budget == null) {
        return ExpensesNotifier(null, toPrimary,
            initialState: const AsyncValue.data([]),
            guard: guard,
            actingProfileId: actingProfileId,
            recorder: ref.watch(syncRecorderProvider),
            rateRegistry: ref.watch(rateRegistryProvider));
      }
      return ExpensesNotifier(budget.id, toPrimary,
          guard: guard,
          actingProfileId: actingProfileId,
          recorder: ref.watch(syncRecorderProvider),
          rateRegistry: ref.watch(rateRegistryProvider));
    },
    loading: () => ExpensesNotifier(null, toPrimary,
        initialState: const AsyncValue.loading(),
        guard: guard,
        actingProfileId: actingProfileId,
        recorder: ref.watch(syncRecorderProvider),
        rateRegistry: ref.watch(rateRegistryProvider)),
    error: (e, st) => ExpensesNotifier(null, toPrimary,
        initialState: AsyncValue.error(e, st),
        guard: guard,
        actingProfileId: actingProfileId,
        recorder: ref.watch(syncRecorderProvider),
        rateRegistry: ref.watch(rateRegistryProvider)),
  );
});

class ExpensesNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final int? budgetId;
  final double Function(ExpenseSnapshot) _toPrimary;
  final SpaceWriteGuard? _guard;
  final int? _actingProfileId;
  final RateTableRegistry _rateRegistry;
  final Isar _isar = IsarHelper.instance;
  final SyncRecorder? recorder;
  AuditRepository get audit =>
      AuditRepository(_isar, recorder: recorder, actorId: _actingProfileId);

  ExpensesNotifier(
    this.budgetId,
    this._toPrimary, {
    AsyncValue<List<Expense>>? initialState,
    SpaceWriteGuard? guard,
    int? actingProfileId,
    required RateTableRegistry rateRegistry,
    this.recorder,
  })  : _guard = guard,
        _actingProfileId = actingProfileId,
        _rateRegistry = rateRegistry,
        super(initialState ?? const AsyncValue.loading()) {
    if (budgetId != null && initialState == null) {
      _loadExpenses();
    }
  }

  Future<void> _loadExpenses() async {
    try {
      if (!mounted) return;
      state = const AsyncValue.loading();
      final expenses = await _isar.expenses
          .filter()
          .budgetIdEqualTo(budgetId!)
          .sortByDateDesc()
          .findAll();
      if (mounted) state = AsyncValue.data(expenses);
    } catch (e, st) {
      if (mounted) state = AsyncValue.error(e, st);
    }
  }

  Future<void> addExpense(Expense expense) async {
    if (budgetId == null) return;

    try {
      await _guard?.assertSharedMoneyWrite(
        sharedSpaceId: expense.sharedSpaceId,
        actingProfileId: _actingProfileId,
        yearMonth: expense.yearMonth,
      );

      expense.budgetId = budgetId!;
      if (expense.status == ExpenseStatus.paid) {
        expense.paidAt ??=
            expense.type == ExpenseType.medical ? DateTime.now() : expense.date;
      }

      await _isar.writeTxn(() async {
        await MerchantRepository(_isar,
                recorder: recorder, actorId: _actingProfileId)
            .bindExpenseInTxn(expense);
        await ExpenseEvidenceRepository(_isar,
                recorder: recorder, actorId: _actingProfileId)
            .saveInTxn(expense);
        expense.id = await audit.put(_isar.expenses, expense,
            id: expense.id, type: 'Expense');
        await recorder?.recordExpense(expense);
        await _syncProfileSpending(expense.yearMonth, expense);
      });

      await _loadExpenses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Ready rows, audit, sync journal and cached spending are one atomic unit.
  /// Validation is repeated against authoritative rows inside the transaction.
  Future<Map<String, String>> addBulkExpenses(
      List<Expense> rows, ContextRef owner,
      {required void Function() assertContext,
      ExpensePurchase? purchase,
      int? expectedRevision,
      String? expectedToken}) async {
    if (rows.isEmpty ||
        rows.length > BulkEntryService.maximumRows ||
        budgetId == null) {
      throw StateError('Choose an available month and 1 to 50 ready rows.');
    }
    final errors = <String, String>{};
    await _isar.writeTxn(() async {
      assertContext();
      final month = await _isar.monthlyBudgets.get(budgetId!);
      if (month == null ||
          month.yearMonth != owner.yearMonth ||
          month.profileId != owner.profileId ||
          month.sharedSpaceId != owner.spaceId) {
        throw StateError('The destination month changed or is unavailable.');
      }
      if (!owner.isShared &&
          (_actingProfileId != owner.profileId ||
              await _isar.userProfiles.get(owner.profileId!) == null)) {
        throw StateError('The personal profile is no longer available.');
      }
      await (_guard ?? SpaceWriteGuard(_isar)).assertSharedMoneyWrite(
          sharedSpaceId: owner.spaceId,
          actingProfileId: _actingProfileId,
          yearMonth: owner.yearMonth);
      if (purchase != null) {
        // Resolve the shared merchant before comparing retries or binding cash
        // declarations. Canonical spelling must match the stored header/items.
        for (final row in rows) {
          final manifest = ExpenseEvidence.decode(row.paymentEvidenceJson);
          final declaredFingerprint = cashPaymentFingerprint(row);
          await MerchantRepository(_isar,
                  recorder: recorder, actorId: _actingProfileId)
              .bindExpenseInTxn(row);
          if (manifest?.cashAt != null &&
              manifest!.cashFingerprint == declaredFingerprint) {
            row.paymentEvidenceJson = ExpenseEvidence(
                    profileChosen: manifest.profileChosen,
                    documents: manifest.documents,
                    cashActor: manifest.cashActor,
                    cashAt: manifest.cashAt,
                    cashFingerprint: cashPaymentFingerprint(row))
                .encode();
          }
        }
        purchase
          ..merchantName = rows.first.merchantName ?? ''
          ..currency = rows.first.currency;
        final prior = await _isar.expensePurchases
            .filter()
            .syncGuidEqualTo(purchase.syncGuid)
            .findFirst();
        validatePurchaseItems(purchase, rows);
        if (prior != null) {
          if (expectedRevision == null) {
            // A lost response may be retried, but never with changed contents.
            final oldRows = await _isar.expenses
                .filter()
                .purchaseSyncGuidEqualTo(prior.syncGuid)
                .findAll();
            if (!samePurchaseContent(prior, oldRows, purchase, rows)) {
              throw StateError(
                  'This saved purchase differs from the retry. Reopen it.');
            }
            purchase
              ..id = prior.id
              ..revision = prior.revision
              ..versionToken = prior.versionToken;
            return;
          }
          if (prior.revision != expectedRevision ||
              prior.versionToken != expectedToken ||
              prior.itemGuids.join(',') != purchase.itemGuids.join(',') ||
              prior.profileId != purchase.profileId ||
              prior.sharedSpaceId != purchase.sharedSpaceId ||
              prior.yearMonth != purchase.yearMonth) {
            throw StateError(
                'This purchase changed. Reopen it before editing.');
          }
          final oldItems = await _isar.expenses
              .filter()
              .purchaseSyncGuidEqualTo(prior.syncGuid)
              .findAll();
          final byGuid = {for (final item in oldItems) item.syncGuid: item};
          final paymentChanged =
              prior.receiptTotalMinor != purchase.receiptTotalMinor ||
                  rows.any((r) =>
                      byGuid[r.syncGuid] == null ||
                      paymentDetailsChanged(r, byGuid[r.syncGuid]!));
          if (rows.first.paymentMethod == 'cash' &&
              isPaidExpenseStatus(rows.first.status) &&
              paymentChanged &&
              ExpenseEvidence.decode(rows.first.paymentEvidenceJson)?.cashAt ==
                  ExpenseEvidence.decode(
                          byGuid[rows.first.syncGuid]?.paymentEvidenceJson)
                      ?.cashAt) {
            throw StateError(
                'Confirm the corrected cash purchase again before saving.');
          }
          if (await _isar.reimbursements
                  .filter()
                  .anyOf(
                      oldRowsIds(await _isar.expenses
                          .filter()
                          .purchaseSyncGuidEqualTo(prior.syncGuid)
                          .findAll()),
                      (q, int id) => q.expenseIdEqualTo(id))
                  .count() >
              0) {
            throw StateError(
                'This purchase has refunds. Its original payment details are preserved.');
          }
          purchase.id = prior.id;
          purchase.revision = prior.revision + 1;
        } else if (expectedRevision != null) {
          throw StateError('This purchase no longer exists.');
        }
        purchase.id = await audit.put(_isar.expensePurchases, purchase,
            id: purchase.id, type: 'ExpensePurchase', derived: false);
      }
      final settlements = await _isar.monthEndRuns
          .filter()
          .yearMonthEqualTo(owner.yearMonth)
          .findAll();
      if (settlements.any((r) =>
          r.applied &&
          r.profileId == owner.profileId &&
          r.sharedSpaceId == owner.spaceId)) {
        throw StateError(
            'This month has completed Month-End. Choose an editable month.');
      }
      final seen = <String>{};
      final accounting = owner.isShared
          ? (await _isar.sharedSpaces.get(owner.spaceId!))?.currency.code
          : (await _isar.userProfiles.get(owner.profileId!))
              ?.primaryCurrency
              .code;
      if (accounting == null) {
        throw StateError('The destination currency is unavailable.');
      }
      final targets = {
        accounting,
        CurrencyCode.tryParse(month.currency) ?? accounting
      };
      final convertedTotals = <CurrencyCode, BigInt>{};
      rowLoop:
      for (final row in rows) {
        if (!seen.add(row.syncGuid) ||
            row.profileId != owner.profileKey ||
            row.sharedSpaceId != owner.spaceId ||
            row.yearMonth != owner.yearMonth ||
            row.budgetId != budgetId) {
          throw StateError(
              'A row identity or destination changed. Reopen Bulk Entry.');
        }
        if (row.type != ExpenseType.standard ||
            row.amount <= 0 ||
            row.amount > 9007199254740991 ||
            row.currencyCode == null ||
            row.title.trim().isEmpty ||
            (row.merchantName?.trim().isEmpty ?? true) ||
            !{'cash', 'card', 'bankTransfer', 'other'}
                .contains(row.paymentMethod) ||
            !{ExpenseStatus.paid, ExpenseStatus.planned}.contains(row.status) ||
            '${row.date.year.toString().padLeft(4, '0')}-${row.date.month.toString().padLeft(2, '0')}' !=
                owner.yearMonth) {
          errors[row.syncGuid] = 'This row is invalid. Review its fields.';
          continue;
        }
        final evidenceProblems = expenseEvidenceProblems(row);
        if (evidenceProblems.isNotEmpty) {
          errors[row.syncGuid] = evidenceProblems.join(' ');
          continue;
        }
        final nextTotals = <CurrencyCode, BigInt>{};
        for (final target in targets) {
          final converted = tryExpenseToDisplay(
              row, target, _rateRegistry.tableFor(owner.yearMonth));
          if (converted == null ||
              converted.minorUnits < 0 ||
              converted.minorUnits > 9007199254740991) {
            errors[row.syncGuid] =
                'This amount cannot be converted safely. Review its amount and currency.';
            continue rowLoop;
          }
          final total = (convertedTotals[target] ?? BigInt.zero) +
              BigInt.from(converted.minorUnits);
          if (total > BigInt.from(9007199254740991)) {
            errors[row.syncGuid] =
                'Including this row would exceed the supported batch total. Reduce the amount.';
            continue rowLoop;
          }
          nextTotals[target] = total;
        }
        if (await _isar.categorys
                .filter()
                .categoryIdEqualTo(row.categoryId)
                .findFirst() ==
            null) {
          errors[row.syncGuid] =
              'The selected category is no longer available. Choose it again.';
          continue;
        }
        final id = row.budgetProfileId;
        if (id != null) {
          final profile =
              row.financialProfileType == FinancialProfileType.budget
                  ? await _isar.budgetProfiles.get(id)
                  : null;
          final direct = row.financialProfileType == FinancialProfileType.direct
              ? await _isar.directExpenseProfiles.get(id)
              : null;
          if ((profile == null && direct == null) ||
              (profile?.yearMonth ?? direct!.yearMonth) != owner.yearMonth ||
              (profile?.sharedSpaceId ?? direct?.sharedSpaceId) !=
                  owner.spaceId ||
              (!owner.isShared &&
                  (profile?.profileId ?? direct?.profileId) !=
                      owner.profileId) ||
              (profile?.syncGuid ?? direct?.syncGuid) !=
                  row.financialProfileSyncGuid) {
            errors[row.syncGuid] =
                'The selected financial profile changed. Choose it again.';
            continue;
          }
        } else if (row.financialProfileType != null ||
            row.financialProfileSyncGuid != null) {
          errors[row.syncGuid] = 'Choose a valid financial profile.';
          continue;
        }
        final existing = await _isar.expenses
            .filter()
            .syncGuidEqualTo(row.syncGuid)
            .findFirst();
        if (existing != null) {
          if (purchase != null && expectedRevision != null) {
            if (existing.purchaseSyncGuid != purchase.syncGuid) {
              throw StateError('An item belongs to another purchase.');
            }
            row.id = existing.id;
            await MerchantRepository(_isar,
                    recorder: recorder, actorId: _actingProfileId)
                .bindExpenseInTxn(row);
            await ExpenseEvidenceRepository(_isar,
                    recorder: recorder, actorId: _actingProfileId)
                .saveInTxn(row, previous: existing, purchaseWrite: true);
            await audit.put(_isar.expenses, row, id: row.id, type: 'Expense');
            convertedTotals.addAll(nextTotals);
            continue;
          }
          // A committed retry is safe only for the exact same owner and content.
          if (existing.profileId != row.profileId ||
              existing.sharedSpaceId != row.sharedSpaceId ||
              existing.budgetId != row.budgetId ||
              existing.yearMonth != row.yearMonth ||
              existing.title != row.title ||
              existing.amount != row.amount ||
              existing.currency != row.currency ||
              existing.date != row.date ||
              existing.status != row.status ||
              existing.categoryId != row.categoryId ||
              existing.merchantName != row.merchantName ||
              existing.paymentMethod != row.paymentMethod ||
              existing.budgetProfileId != row.budgetProfileId ||
              existing.financialProfileType != row.financialProfileType ||
              existing.financialProfileSyncGuid !=
                  row.financialProfileSyncGuid ||
              existing.notes != row.notes ||
              existing.tags.join('\u0000') != row.tags.join('\u0000') ||
              existing.isReimbursable != row.isReimbursable ||
              existing.guiltLevel != row.guiltLevel) {
            throw StateError(
                'A saved row differs from this retry. Refresh Expenses before continuing.');
          }
          continue;
        }
        row.id = Isar.autoIncrement;
        convertedTotals.addAll(nextTotals);
        await MerchantRepository(_isar,
                recorder: recorder, actorId: _actingProfileId)
            .bindExpenseInTxn(row);
        await ExpenseEvidenceRepository(_isar,
                recorder: recorder, actorId: _actingProfileId)
            .saveInTxn(row, purchaseWrite: purchase != null);
        row.id =
            await audit.put(_isar.expenses, row, id: row.id, type: 'Expense');
        if (purchase == null) await recorder?.recordExpense(row);
      }
      if (purchase != null) {
        if (errors.isNotEmpty) throw StateError(errors.values.join(' '));
        await recorder?.recordExpense(rows.first);
      }
      if (errors.length < rows.length) {
        await _syncProfileSpending(owner.yearMonth, rows.first);
      }
      assertContext();
    });
    // Watchers refresh persisted data. A read-refresh failure must not turn a
    // successful commit into an apparent failed submission.
    if (mounted) await _loadExpenses();
    return errors;
  }

  /// Recomputes what each budget profile has spent, so borrowing and deficit
  /// stay true after an expense changes (T054, FR-011).
  ///
  /// The borrowing numbers themselves are derived on read
  /// ([`dashboardProfilesProvider`]); this only keeps the stored `spent` on
  /// each profile up to date, which is what the delete guard and the reports
  /// read.
  Future<void> _syncProfileSpending(String yearMonth, Expense owner) async {
    bool owns(int? p, int? space) => owner.sharedSpaceId != null
        ? space == owner.sharedSpaceId
        : space == null && p == owner.profileId;
    final profiles = (await _isar.budgetProfiles
            .filter()
            .yearMonthEqualTo(yearMonth)
            .findAll())
        .where((p) => owns(p.profileId, p.sharedSpaceId))
        .toList();
    final directProfiles = (await _isar.directExpenseProfiles
            .filter()
            .yearMonthEqualTo(yearMonth)
            .findAll())
        .where((p) => owns(p.profileId, p.sharedSpaceId))
        .toList();
    if (profiles.isEmpty && directProfiles.isEmpty) return;

    final expenses =
        (await _isar.expenses.filter().yearMonthEqualTo(yearMonth).findAll())
            .where((e) => owns(e.profileId, e.sharedSpaceId))
            .toList();
    final returns = (await _isar.reimbursements
            .filter()
            .originYearMonthEqualTo(yearMonth)
            .findAll())
        .where((r) => owns(r.profileId, r.sharedSpaceId))
        .toList();

    // Stored `spent` lives beside the allocation, in each profile's context
    // currency (D5). Resolve that currency and convert every row into it before
    // summing, so a profile holding an expense in another currency no longer
    // adds unlike units.
    final currencyByProfile = <(String, int), CurrencyCode>{};
    Future<void> resolveCurrency(
      int id,
      String type,
      int? sharedSpaceId,
      int? profileId,
    ) async {
      if (sharedSpaceId != null) {
        final space = await _isar.sharedSpaces.get(sharedSpaceId);
        currencyByProfile[(type, id)] =
            space?.currency.code ?? CurrencyCode.huf;
      } else if (profileId != null) {
        final user = await _isar.userProfiles.get(profileId);
        currencyByProfile[(type, id)] =
            user?.primaryCurrency.code ?? CurrencyCode.huf;
      } else {
        currencyByProfile[(type, id)] = CurrencyCode.huf;
      }
    }

    for (final profile in profiles) {
      await resolveCurrency(
        profile.id,
        FinancialProfileType.budget,
        profile.sharedSpaceId,
        profile.profileId,
      );
    }
    for (final profile in directProfiles) {
      await resolveCurrency(
        profile.id,
        FinancialProfileType.direct,
        profile.sharedSpaceId,
        profile.profileId,
      );
    }
    final table = _rateRegistry.tableFor(yearMonth);

    for (final expense in expenses) {
      resolveExpenseProfileIdentity(expense, profiles, directProfiles);
    }
    const service = ProfileSpendingService();
    {
      for (final profile in profiles) {
        final currency =
            currencyByProfile[(FinancialProfileType.budget, profile.id)] ??
                CurrencyCode.huf;
        final scoped = expenses
            .where((e) => profile.sharedSpaceId != null
                ? e.sharedSpaceId == profile.sharedSpaceId
                : e.sharedSpaceId == null && e.profileId == profile.profileId)
            .toList();
        final spent = service.spentInYearMonth(
          profileId: profile.id,
          profileType: FinancialProfileType.budget,
          yearMonth: yearMonth,
          expenses: scoped,
          reimbursements: returns,
          convertReimbursement: (r) => reimbursementToDisplay(
                  r, currency, table,
                  accountingCurrency: currency)
              .minorUnits,
          convert: (expense) => expenseToDisplay(expense, currency, table,
                  accountingCurrency: currency)
              .minorUnits,
        );
        if (profile.spent != spent) {
          profile.spent = spent;
          await _isar.budgetProfiles.put(profile);
        }
      }
      for (final profile in directProfiles) {
        final currency =
            currencyByProfile[(FinancialProfileType.direct, profile.id)] ??
                CurrencyCode.huf;
        final scoped = expenses
            .where((e) => profile.sharedSpaceId != null
                ? e.sharedSpaceId == profile.sharedSpaceId
                : e.sharedSpaceId == null && e.profileId == profile.profileId)
            .toList();
        final spent = service.spentInYearMonth(
          profileId: profile.id,
          profileType: FinancialProfileType.direct,
          yearMonth: yearMonth,
          expenses: scoped,
          reimbursements: returns,
          convertReimbursement: (r) => reimbursementToDisplay(
                  r, currency, table,
                  accountingCurrency: currency)
              .minorUnits,
          convert: (expense) => expenseToDisplay(expense, currency, table,
                  accountingCurrency: currency)
              .minorUnits,
        );
        final count = scoped
            .where((e) =>
                e.budgetProfileId == profile.id &&
                e.financialProfileType == FinancialProfileType.direct)
            .length;
        if (profile.spent != spent || profile.expenseCount != count) {
          profile.spent = spent;
          profile.expenseCount = count;
          await _isar.directExpenseProfiles.put(profile);
        }
      }
    }
  }

  /// Persists an edited [updated] expense and returns the exact engine delta
  /// (in primary currency) versus the previously stored version.
  ///
  /// Rules:
  /// - Planned â†’ Paid: `paidAt` is set to now; trueAvailable drops by amount.
  /// - Paid â†’ Planned: `paidAt` is cleared; trueAvailable is restored.
  /// - Paid â†’ Paid: trueAvailable/safeToSpend shift by the amount difference.
  /// - Currency change: exchange rate is refreshed for the new currency.
  ///
  /// The reactive engine providers (`trueAvailableProvider`,
  /// `safeToSpendProvider`) pick up the change instantly via Isar watchers.
  Future<ExpenseDelta> updateExpense(Expense updated) async {
    if (updated.amount <= 0) {
      throw ArgumentError.value(updated.amount, 'amount', 'must be > 0');
    }
    if (updated.title.trim().isEmpty) {
      throw ArgumentError.value(updated.title, 'title', 'cannot be empty');
    }

    try {
      final stored = await _isar.expenses.get(updated.id);
      if (stored == null) {
        throw StateError('Expense ${updated.id} no longer exists');
      }
      await _guard?.assertSharedMoneyWrite(
        sharedSpaceId: updated.sharedSpaceId ?? stored.sharedSpaceId,
        actingProfileId: _actingProfileId,
        yearMonth: updated.yearMonth,
      );
      final before = ExpenseSnapshot.of(stored);

      // Status transition â†’ paidAt bookkeeping.
      if (updated.status == ExpenseStatus.paid &&
          stored.status != ExpenseStatus.paid) {
        updated.paidAt ??=
            updated.type == ExpenseType.medical ? DateTime.now() : updated.date;
      } else if (updated.status != stored.status &&
          (updated.status == ExpenseStatus.planned ||
              updated.status == ExpenseStatus.cancelled)) {
        updated.paidAt = null;
      } else {
        updated.paidAt ??= stored.paidAt;
      }

      await _isar.writeTxn(() async {
        final authoritative = await _isar.expenses.get(updated.id);
        if (authoritative == null) {
          throw StateError('Expense no longer exists.');
        }
        if (updated.merchantName != authoritative.merchantName ||
            updated.merchantSyncGuid != authoritative.merchantSyncGuid) {
          await MerchantRepository(_isar,
                  recorder: recorder, actorId: _actingProfileId)
              .bindExpenseInTxn(updated);
        }
        await ExpenseEvidenceRepository(_isar,
                recorder: recorder, actorId: _actingProfileId)
            .saveInTxn(updated, previous: authoritative);
        updated.id = await audit.put(_isar.expenses, updated,
            id: updated.id, type: 'Expense');
        await recorder?.recordExpense(updated);
        await _syncProfileSpending(updated.yearMonth, updated);
        if (stored.yearMonth != updated.yearMonth) {
          await _syncProfileSpending(stored.yearMonth, stored);
        }
      });

      final delta = ExpenseDelta.between(
        before: before,
        after: ExpenseSnapshot.of(updated),
        toPrimary: _toPrimary,
      );

      await _loadExpenses();
      return delta;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Quick swipe action: flips Planned â†” Paid.
  Future<ExpenseDelta> toggleStatus(Expense expense) async {
    final stored = await _isar.expenses.get(expense.id);
    if (stored == null) return ExpenseDelta.zero;
    stored.status = stored.status == ExpenseStatus.paid
        ? ExpenseStatus.planned
        : ExpenseStatus.paid;
    return updateExpense(stored);
  }

  /// Deletes the expense and returns the engine delta (money freed up).
  Future<void> deletePurchase(
      String guid, int revision, String versionToken) async {
    await _isar.writeTxn(() async {
      final p = await _isar.expensePurchases
          .filter()
          .syncGuidEqualTo(guid)
          .findFirst();
      if (p == null) return;
      if (p.revision != revision ||
          p.versionToken != versionToken ||
          p.budgetId != budgetId ||
          (p.sharedSpaceId == null && p.profileId != _actingProfileId)) {
        throw StateError('The purchase changed or belongs to another context.');
      }
      await (_guard ?? SpaceWriteGuard(_isar)).assertSharedMoneyWrite(
          sharedSpaceId: p.sharedSpaceId,
          actingProfileId: _actingProfileId,
          yearMonth: p.yearMonth);
      final settled = await _isar.monthEndRuns
          .filter()
          .yearMonthEqualTo(p.yearMonth)
          .findAll();
      if (settled.any((r) =>
          r.applied &&
          r.profileId == (p.sharedSpaceId == null ? p.profileId : null) &&
          r.sharedSpaceId == p.sharedSpaceId)) {
        throw StateError('This month has completed Month-End.');
      }
      final rows =
          await _isar.expenses.filter().purchaseSyncGuidEqualTo(guid).findAll();
      if (await _isar.reimbursements
              .filter()
              .anyOf(rows.map((r) => r.id).toList(),
                  (q, int id) => q.expenseIdEqualTo(id))
              .count() >
          0) {
        throw StateError('This purchase has refunds and cannot be removed.');
      }
      for (final row in rows) {
        await audit.remove(_isar.expenses, row.id, type: 'Expense');
      }
      await audit.remove(_isar.expensePurchases, p.id, type: 'ExpensePurchase');
      if (p.sharedSpaceId != null) {
        await recorder?.recordDelete(
            contextKind: ContextKind.shared,
            contextLocalId: p.sharedSpaceId!,
            entityType: 'ExpensePurchase',
            entitySyncGuid: p.syncGuid,
            entityLocalId: p.id);
      }
      if (rows.isNotEmpty) await _syncProfileSpending(p.yearMonth, rows.first);
    });
    if (mounted) await _loadExpenses();
  }

  Future<ExpenseDelta> deleteExpense(int id) async {
    try {
      final stored = await _isar.expenses.get(id);
      if (stored == null) return ExpenseDelta.zero;
      await _guard?.assertSharedMoneyWrite(
        sharedSpaceId: stored.sharedSpaceId,
        actingProfileId: _actingProfileId,
        yearMonth: stored.yearMonth,
      );
      final before = ExpenseSnapshot.of(stored);

      await _isar.writeTxn(() async {
        if (stored.purchaseSyncGuid != null) {
          throw StateError(
              'Open the purchase to remove all its items together.');
        }
        await audit.remove(_isar.expenses, id, type: 'Expense');
        await recorder?.recordExpenseRemoved(stored);
        await _syncProfileSpending(stored.yearMonth, stored);
      });

      await _loadExpenses();
      return ExpenseDelta.between(
        before: before,
        toPrimary: _toPrimary,
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
