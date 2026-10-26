import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/purchase_draft.dart';
import '../../../shared/presentation/financial_feedback.dart';
import '../../spaces/providers/spaces_providers.dart';
import '../providers/bulk_entry_providers.dart';
import '../providers/purchase_provider.dart';
import '../providers/expense_search_provider.dart';
import 'widgets/purchase_editor.dart';

class BulkEntryScreen extends ConsumerStatefulWidget {
  const BulkEntryScreen({super.key});
  @override
  ConsumerState<BulkEntryScreen> createState() => _BulkEntryScreenState();
}

class _BulkEntryScreenState extends ConsumerState<BulkEntryScreen> {
  final purchases = <PurchaseDraft>[PurchaseDraft()..addItem()];
  final scroll = ScrollController();
  ContextRef? owner;
  int? actor;
  String? expanded;
  bool dirty = false, busy = false, leaving = false;
  int get itemCount => purchases.fold(0, (n, p) => n + p.items.length);
  @override
  void dispose() {
    scroll.dispose();
    for (final p in purchases) {
      p.evidence.dispose();
    }
    super.dispose();
  }

  Future<void> leave({bool view = false}) async {
    if (busy) return;
    if (dirty && purchases.any((p) => !p.saved)) {
      final discard = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
                  title: const Text('Discard unfinished purchases?'),
                  content: const Text(
                      'Saved purchases stay. Unsaved items and uploads will be discarded.'),
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
    if (view) {
      if (!sameBulkContext(owner!, ref.read(budgetContextProvider)) ||
          actor != ref.read(actingProfileIdProvider)) {
        return;
      }
      ref.read(expenseSearchStateProvider.notifier).showSavedBatch(purchases
          .where((p) => p.saved)
          .expand((p) => p.items.map((i) => i.guid)));
      ref.invalidate(expenseSearchRowsProvider);
    }
    setState(() => leaving = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (view) {
          context.go('/expenses');
        } else {
          Navigator.pop(context);
        }
      }
    });
  }

  Future<void> submit() async {
    final ready = <PurchaseDraft>[];
    setState(() {
      for (final p in purchases.where((p) => !p.saved)) {
        final issues = p.validate(owner!.yearMonth, showErrors: true);
        p.error = issues.isEmpty ? null : issues.join('\n');
        if (issues.isEmpty) ready.add(p);
      }
    });
    if (ready.isEmpty) {
      showFinancialFeedback(
          context, 'Complete the highlighted purchases before saving.',
          kind: FinancialFeedbackKind.error);
      return;
    }
    setState(() => busy = true);
    try {
      final confirm = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
                  title: Text('Save ${ready.length} complete purchases?'),
                  content: Text(
                      '${ready.fold<int>(0, (n, p) => n + p.items.length)} expense items\n${purchases.where((p) => !p.saved).length - ready.length} purchases need correction.\n\n${ready.map((p) => '${p.header.merchant} · ${p.items.length} items · ${p.header.status.name}\nItems total: ${purchaseMoney(p, p.totalMinor)}').join('\n')}\n\nOnly item amounts count as spending.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(c, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text('Save complete purchases'))
                  ]));
      if (confirm != true || !mounted) return;
      for (final p in ready) {
        try {
          await ref.read(purchaseSubmitProvider)(p, owner!, actor!);
        } catch (e) {
          p.error = e is StateError
              ? e.message
              : 'This purchase was not saved. Please retry.';
          break;
        }
      }
      if (mounted) {
        setState(() {
          dirty = purchases.any((p) => !p.saved);
          expanded = purchases.where((p) => !p.saved).firstOrNull?.guid;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && scroll.hasClients) {
            scroll.animateTo(0,
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic);
          }
        });
        showFinancialFeedback(context,
            '${ready.where((p) => p.saved).length} purchases saved. Unfinished purchases remain here.',
            kind: ready.every((p) => p.saved)
                ? FinancialFeedbackKind.success
                : FinancialFeedbackKind.warning);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    owner ??= ref.read(budgetContextProvider);
    actor ??= ref.read(actingProfileIdProvider);
    expanded ??= purchases.firstOrNull?.guid;
    final allowed = sameBulkContext(owner!, ref.watch(budgetContextProvider)) &&
        actor == ref.watch(actingProfileIdProvider) &&
        actor != null &&
        ref.watch(activeContextCanEditProvider);
    final colors = Theme.of(context).colorScheme;
    return PopScope(
        canPop: leaving || (!busy && !dirty),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) leave();
        },
        child: Scaffold(
            appBar: AppBar(
                title: const Text('Bulk Entry'),
                leading: IconButton(
                    tooltip: 'Back',
                    onPressed: busy ? null : leave,
                    icon: const Icon(Icons.arrow_back))),
            bottomNavigationBar: allowed
                ? SafeArea(
                    child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: FilledButton.icon(
                            onPressed: busy ||
                                    purchases.every((p) => p.saved) ||
                                    ref
                                            .watch(activeBudgetProvider)
                                            .asData
                                            ?.value ==
                                        null
                                ? null
                                : submit,
                            icon: const Icon(Icons.fact_check_outlined),
                            label: Text(busy
                                ? 'Saving purchases…'
                                : 'Review and save'))))
                : null,
            body: !allowed
                ? const Center(
                    child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                            'The context or permission changed. Reopen Bulk Entry in the intended profile or space.')))
                : AbsorbPointer(
                    absorbing: busy,
                    child: ListView(
                        controller: scroll,
                        padding: const EdgeInsets.all(16),
                        children: [
                          Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    colors.primaryContainer,
                                    colors.secondaryContainer
                                  ]),
                                  borderRadius: BorderRadius.circular(24)),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.receipt_long_outlined,
                                        size: 32),
                                    const SizedBox(height: 8),
                                    Text('One receipt. All your items.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge),
                                    Text(
                                        '${owner!.yearMonth} · $itemCount of 50 items'),
                                    const SizedBox(height: 6),
                                    const Text(
                                        'Upload once per purchase. Assign each item to its own budget.')
                                  ])),
                          if (purchases.any((p) => p.saved))
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: FilledButton.tonalIcon(
                                    onPressed: () => leave(view: true),
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('View saved expenses'))),
                          for (final (index, p) in purchases.indexed)
                            Card(
                                clipBehavior: Clip.antiAlias,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                    side: BorderSide(
                                        color: p.saved
                                            ? colors.primary
                                            : colors.outlineVariant)),
                                child: Column(children: [
                                  ListTile(
                                      onTap: () => setState(() => expanded =
                                          expanded == p.guid ? '' : p.guid),
                                      leading: CircleAvatar(
                                          child: Icon(p.saved
                                              ? Icons.check
                                              : Icons.shopping_bag_outlined)),
                                      title: Text(p.header.merchant.isEmpty
                                          ? 'Purchase ${index + 1}'
                                          : p.header.merchant),
                                      subtitle: Text(
                                          '${p.header.date == null ? 'Choose a date' : '${p.header.date!.day}/${p.header.date!.month}/${p.header.date!.year}'} · ${purchaseMoney(p, p.totalMinor)}\n${p.items.length} items · ${p.saved ? 'Saved' : p.error != null ? 'Needs correction' : p.validate(owner!.yearMonth).isEmpty ? 'Ready' : 'Draft'}'),
                                      trailing: Icon(expanded == p.guid
                                          ? Icons.expand_less
                                          : Icons.expand_more)),
                                  if (expanded == p.guid && !p.saved)
                                    Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(children: [
                                          PurchaseEditor(
                                              purchase: p,
                                              month: owner!.yearMonth,
                                              canAdd: itemCount < 50,
                                              onChanged: () =>
                                                  setState(() => dirty = true)),
                                          Wrap(spacing: 12, children: [
                                            TextButton.icon(
                                                onPressed: itemCount +
                                                            p.items.length >
                                                        50
                                                    ? null
                                                    : () => setState(() {
                                                          final copy = p.copy();
                                                          purchases.add(copy);
                                                          expanded = copy.guid;
                                                          dirty = true;
                                                        }),
                                                icon: const Icon(
                                                    Icons.copy_outlined),
                                                label: const Text(
                                                    'Copy purchase')),
                                            TextButton.icon(
                                                onPressed: () => setState(() {
                                                      p.evidence.dispose();
                                                      purchases.remove(p);
                                                      dirty = true;
                                                    }),
                                                icon: const Icon(
                                                    Icons.delete_outline),
                                                label: const Text(
                                                    'Remove purchase'))
                                          ])
                                        ]))
                                ])),
                          OutlinedButton.icon(
                              onPressed: itemCount >= 50
                                  ? null
                                  : () => setState(() {
                                        final p = PurchaseDraft()..addItem();
                                        purchases.add(p);
                                        expanded = p.guid;
                                        dirty = true;
                                      }),
                              icon: const Icon(Icons.add_shopping_cart),
                              label: const Text('Add another purchase')),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                  'Unsaved purchases are temporary. Separate receipts should use separate purchases.')),
                        ]))));
  }
}
