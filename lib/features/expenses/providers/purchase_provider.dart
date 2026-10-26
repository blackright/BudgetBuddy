import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/expense_purchase.dart';
import '../../../core/services/purchase_draft.dart';
import '../../../core/services/bulk_entry_service.dart';
import '../../../core/services/expense_evidence.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../spaces/providers/spaces_providers.dart';
import 'bulk_entry_providers.dart';
import 'expenses_provider.dart';
import 'expense_search_provider.dart';

typedef PurchaseSubmit = Future<void> Function(
    PurchaseDraft draft, ContextRef owner, int actor);
final purchaseSubmitProvider = Provider<PurchaseSubmit>((ref) {
  bool busy = false;
  return (draft, owner, actor) async {
    if (busy) throw StateError('A purchase is already saving.');
    void check() {
      if (!sameBulkContext(owner, ref.read(budgetContextProvider)) ||
          actor != ref.read(actingProfileIdProvider) ||
          !ref.read(activeContextCanEditProvider)) {
        throw StateError(
            'The context or permission changed. Reopen this screen.');
      }
    }

    check();
    final budget = ref.read(activeBudgetProvider).asData?.value;
    if (budget == null) throw StateError('This month is not available.');
    final issues = draft.validate(owner.yearMonth);
    if (issues.isNotEmpty) throw StateError(issues.join(' '));
    busy = true;
    try {
      final rows = <Expense>[];
      for (final item in draft.items) {
        draft.inherit(item);
        final status = item.status;
        item.status = ExpenseStatus.planned;
        final expense = const BulkEntryService().expense(item,
            owner: owner.profileKey,
            space: owner.spaceId,
            month: owner.yearMonth,
            budget: budget.id,
            actor: actor);
        item.status = status;
        expense.status = status;
        expense.paidAt = status == ExpenseStatus.paid ? expense.date : null;
        expense.purchaseSyncGuid = draft.guid;
        expense.purchaseEvidenceOwnerGuid = draft.items.first.guid;
        draft.evidence.profileChosen = item.profileChosen;
        draft.evidence.changed = true;
        draft.evidence.apply(expense, actor: '$actor');
        final manifest = ExpenseEvidence.decode(expense.paymentEvidenceJson)!;
        expense.paymentEvidenceJson = ExpenseEvidence(
                profileChosen: item.profileChosen,
                documents: manifest.documents,
                cashActor: manifest.cashActor,
                cashAt: manifest.cashAt,
                cashFingerprint: manifest.cashAt == null
                    ? null
                    : cashPaymentFingerprint(expense))
            .encode();
        if (rows.isNotEmpty) {
          expense.pendingEvidenceChunks = [];
          expense.pendingEvidenceFiles = {};
        }
        rows.add(expense);
      }
      final purchase = ExpensePurchase()
        ..currency = rows.first.currency
        ..merchantName = rows.first.merchantName ?? ''
        ..syncGuid = draft.guid
        ..profileId = owner.profileKey
        ..sharedSpaceId = owner.spaceId
        ..yearMonth = owner.yearMonth
        ..budgetId = budget.id
        ..receiptTotalMinor = draft.receiptMinor ?? 0
        ..itemGuids = rows.map((r) => r.syncGuid).toList();
      await ref.read(expensesProvider.notifier).addBulkExpenses(rows, owner,
          assertContext: check,
          purchase: purchase,
          expectedRevision: draft.revision == 0 ? null : draft.revision,
          expectedToken: draft.expectedToken);
      draft.revision = purchase.revision;
      draft.expectedToken = purchase.versionToken;
      draft.saved = true;
      for (final item in draft.items) {
        item.saved = true;
      }
      await draft.evidence.dispose();
      ref.invalidate(expenseSearchRowsProvider);
      ref.invalidate(expenseSearchMerchantsProvider);
    } finally {
      busy = false;
    }
  };
});
