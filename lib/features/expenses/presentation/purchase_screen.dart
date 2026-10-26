import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/expense_purchase.dart';
import '../../../core/services/purchase_draft.dart';
import '../../../core/services/bulk_entry_service.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../shared/presentation/financial_feedback.dart';
import '../../spaces/providers/spaces_providers.dart';
import '../providers/expense_search_provider.dart';
import '../providers/category_provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/purchase_provider.dart';
import 'widgets/purchase_editor.dart';
import 'widgets/expense_evidence_view.dart';

final purchaseDetailsProvider = StreamProvider.autoDispose
    .family<(ExpensePurchase, List<Expense>)?, String>((ref, guid) async* {
  final owner = ref.watch(budgetContextProvider);
  final actor = ref.watch(actingProfileIdProvider);
  if (owner.isShared) ref.watch(activeSpaceMembersProvider);
  final repository = ref.watch(expenseSearchRepositoryProvider);
  bool disposed = false;
  ref.onDispose(() => disposed = true);
  await repository.authorize(owner, actor);
  if (disposed) return;
  yield* IsarHelper.instance.expensePurchases
      .filter()
      .syncGuidEqualTo(guid)
      .watch(fireImmediately: true)
      .asyncMap((rows) async {
    final p = rows.firstOrNull;
    if (p == null ||
        p.sharedSpaceId != owner.spaceId ||
        (!owner.isShared && p.profileId != owner.profileKey) ||
        p.yearMonth != owner.yearMonth) {
      return null;
    }
    final items = await IsarHelper.instance.expenses
        .filter()
        .purchaseSyncGuidEqualTo(p.syncGuid)
        .findAll();
    final byGuid = {for (final item in items) item.syncGuid: item};
    if (p.itemGuids.any((g) => !byGuid.containsKey(g))) {
      throw StateError('Purchase items are incomplete. Sync again.');
    }
    return (p, p.itemGuids.map((g) => byGuid[g]!).toList());
  });
});

PurchaseDraft purchaseDraftFromSaved(ExpensePurchase p, List<Expense> items) {
  final result = PurchaseDraft()
    ..guid = p.syncGuid
    ..revision = p.revision;
  result.expectedToken = p.versionToken;
  final first = items.first;
  result.header = BulkExpenseDraft(source: first)
    ..merchant = first.merchantName ?? ''
    ..currency = first.currency
    ..payment = first.paymentMethod
    ..date = first.date
    ..status = first.status == ExpenseStatus.planned
        ? ExpenseStatus.planned
        : ExpenseStatus.paid;
  result.receiptTotal = p.receiptTotalMinor == 0
      ? ''
      : formatMinorUnitsInput(p.receiptTotalMinor, first.currencyCode!);
  for (final item in items) {
    result.items.add(BulkExpenseDraft(identity: item.syncGuid)
      ..title = item.title
      ..amount = formatMinorUnitsInput(item.amount, item.currencyCode!)
      ..category = item.categoryId
      ..profileChosen = true
      ..profileId = item.budgetProfileId
      ..profileType = item.financialProfileType
      ..profileGuid = item.financialProfileSyncGuid
      ..profileName = item.budgetProfileId == null ? 'Main' : 'Selected profile'
      ..notes = item.notes ?? ''
      ..tags = item.tags.join(', ')
      ..reimbursable = item.isReimbursable
      ..guilt = item.guiltLevel);
  }
  return result;
}

class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen({super.key, required this.guid});
  final String guid;
  @override
  ConsumerState<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen> {
  PurchaseDraft? draft;
  bool busy = false, dirty = false, leaving = false;
  @override
  void dispose() {
    draft?.evidence.dispose();
    super.dispose();
  }

  Future<void> back() async {
    if (busy) return;
    if (dirty) {
      final discard = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
                  title: const Text('Discard purchase changes?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text('Keep editing')),
                    FilledButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('Discard'))
                  ]));
      if (discard != true || !mounted) return;
    }
    setState(() => leaving = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> save() async {
    setState(() => busy = true);
    try {
      final confirm = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
                  title: const Text('Update the whole purchase?'),
                  content: Text(
                      'All ${draft!.items.length} linked items share these payment details. Review item amounts and receipt total before confirming.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('Confirm changes'))
                  ]));
      if (confirm != true || !mounted) return;
      await ref.read(purchaseSubmitProvider)(draft!,
          ref.read(budgetContextProvider), ref.read(actingProfileIdProvider)!);
      if (mounted) {
        setState(() {
          dirty = false;
          draft = null;
        });
        ref.invalidate(purchaseDetailsProvider(widget.guid));
        showFinancialFeedback(context, 'Purchase updated.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => draft!.error = e is StateError
            ? e.message
            : 'Purchase could not be updated. Retry.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(purchaseDetailsProvider(widget.guid));
    final canEdit = ref.watch(activeContextCanEditProvider);
    final categories = ref.watch(categoriesProvider).asData?.value;
    return PopScope(
        canPop: leaving || (!dirty && !busy),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) back();
        },
        child: Scaffold(
            appBar: AppBar(
                title: const Text('Purchase'),
                leading: IconButton(
                    onPressed: busy ? null : back,
                    icon: const Icon(Icons.arrow_back))),
            body: details.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Center(
                    child: Text(
                        'Purchase unavailable. Reopen it in its owning month.')),
                data: (data) {
                  if (data == null) {
                    return const Center(
                        child: Text('Purchase not available in this context.'));
                  }
                  final (p, items) = data;
                  final refunded = items.any((e) =>
                      e.status == ExpenseStatus.reimbursed ||
                      e.status == ExpenseStatus.partiallyReimbursed);
                  return AbsorbPointer(
                      absorbing: busy,
                      child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (draft == null) ...[
                              Card(
                                  child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.receipt_long,
                                                size: 36),
                                            Text(
                                                items.first.merchantName ??
                                                    'Purchase',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall),
                                            Text(
                                                '${items.length} items · ${items.first.currency} ${formatMinorUnits(items.fold<int>(0, (n, e) => n + e.amount), items.first.currencyCode!)}'),
                                            const Text(
                                                'One shared receipt. Item amounts count once.')
                                          ]))),
                              for (final item in items)
                                ListTile(
                                    onTap: () => context.push('/expense_detail',
                                        extra: item),
                                    title: Text(item.title),
                                    subtitle: Text(categories
                                            ?.where((c) =>
                                                c.categoryId == item.categoryId)
                                            .firstOrNull
                                            ?.name ??
                                        'Category unavailable'),
                                    trailing: Text(
                                        '${item.currency} ${formatMinorUnits(item.amount, item.currencyCode!)}')),
                              ExpenseEvidenceView(expense: items.first),
                              if (refunded)
                                const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text(
                                        'Refunds are recorded. The original purchase is preserved. Open an item for its refund history.')),
                              if (canEdit && !refunded)
                                FilledButton.icon(
                                    onPressed: () => setState(() => draft =
                                        purchaseDraftFromSaved(p, items)),
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text('Edit purchase')),
                              if (canEdit)
                                TextButton.icon(
                                    onPressed: () async {
                                      final yes = await showDialog<bool>(
                                          context: context,
                                          builder: (c) => AlertDialog(
                                                  title: const Text(
                                                      'Remove this whole purchase?'),
                                                  content: Text(
                                                      'This removes all ${items.length} expense items. Receipts remain in private history. Purchases with refunds or locked months cannot be removed.'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                c, false),
                                                        child: const Text(
                                                            'Cancel')),
                                                    FilledButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                c, true),
                                                        child: const Text(
                                                            'Remove purchase'))
                                                  ]));
                                      if (yes != true || !context.mounted) {
                                        return;
                                      }
                                      setState(() => busy = true);
                                      try {
                                        await ref
                                            .read(expensesProvider.notifier)
                                            .deletePurchase(p.syncGuid,
                                                p.revision, p.versionToken);
                                        if (context.mounted) {
                                          setState(() => leaving = true);
                                          Navigator.pop(context);
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          showFinancialFeedback(
                                              context,
                                              e is StateError
                                                  ? e.message
                                                  : 'Purchase could not be removed.',
                                              kind:
                                                  FinancialFeedbackKind.error);
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() => busy = false);
                                        }
                                      }
                                    },
                                    icon: const Icon(Icons.delete_outline),
                                    label: const Text('Remove whole purchase')),
                            ] else ...[
                              PurchaseEditor(
                                  purchase: draft!,
                                  month: p.yearMonth,
                                  canAdd: false,
                                  editing: true,
                                  onChanged: () =>
                                      setState(() => dirty = true)),
                              FilledButton(
                                  onPressed: canEdit ? save : null,
                                  child: const Text('Review purchase changes')),
                            ]
                          ]));
                })));
  }
}
