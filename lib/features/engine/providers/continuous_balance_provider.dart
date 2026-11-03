import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/budget_profile.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/income_receipt_group.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_withholding_match.dart';
import '../../../core/models/money_receipt.dart';
import '../../../core/models/month_end_run.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/salary_cycle.dart';
import '../../../core/services/continuous_balance_service.dart';
import '../../expenses/models/reimbursement.dart';
import '../../vault/models/savings_vault.dart';
import '../../vault/models/vault_entry.dart';
import 'rate_registry_provider.dart';

/// The live continuous balance for one personal profile/month.
///
/// It re-runs whenever a fact that can change money does, without persisting a
/// second ledger. A missing collection in a legacy harness yields an error
/// AsyncValue rather than inventing a zero balance.
final continuousBalanceProvider = StreamProvider.family<ContinuousBalance,
    ({int profileId, String yearMonth})>((ref, key) async* {
  final db = IsarHelper.instance;
  final rates = ref.watch(rateRegistryProvider);
  final service = ContinuousBalanceService(db, rates: rates);
  final signals = StreamController<void>();
  var queued = false;
  var alive = true;

  void enqueue() {
    if (!queued && !signals.isClosed) {
      queued = true;
      signals.add(null);
    }
  }

  final subscriptions = [
    for (final stream in [
      db.monthlyBudgets.watchLazy(),
      db.expenses.watchLazy(),
      db.reimbursements.watchLazy(),
      db.incomeReceiptGroups.watchLazy(),
      db.moneyReceipts.watchLazy(),
      db.receiptRevisions.watchLazy(),
      db.salaryCycles.watchLazy(),
      db.budgetProfiles.watchLazy(),
      db.vaultEntrys.watchLazy(),
      db.savingsVaults.watchLazy(),
      db.monthEndRuns.watchLazy(),
      db.medicalWithholdingMatchs.watchLazy(),
      db.medicalBills.watchLazy(),
    ])
      stream.listen((_) => enqueue(),
          onError: (Object error, StackTrace stack) {
        if (!signals.isClosed) signals.addError(error, stack);
      })
  ];
  ref.onDispose(() {
    alive = false;
    for (final subscription in subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(signals.close());
  });

  enqueue();
  await for (final _ in signals.stream) {
    queued = false;
    if (!alive) return;
    yield await db.txn(() => service.balance(
        profileId: key.profileId, yearMonth: key.yearMonth));
  }
});
