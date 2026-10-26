import '../../../core/services/filter_service.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../providers/expense_search_provider.dart';
import 'widgets/expense_search_controls.dart';
import '../providers/daily_cards_provider.dart';
import 'widgets/daily_expense_card.dart';
import '../../../shared/presentation/financial_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/money.dart';
import '../../../core/providers/active_budget_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../../shared/presentation/money_conversion.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../shared/presentation/widgets/conversion_footnote.dart';
import '../../dashboard/presentation/widgets/month_convert_to_menu.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../spaces/providers/spaces_providers.dart';
import '../models/reimbursement.dart';
import '../providers/expenses_provider.dart';
import '../repositories/expense_repository.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key, this.filterCategoryId, this.filterStatus});

  final String? filterCategoryId;
  final ExpenseStatus? filterStatus;

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  bool seeded = false;
  final scroll = ScrollController();
  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!seeded) {
      seeded = true;
      if (widget.filterCategoryId != null || widget.filterStatus != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(expenseSearchStateProvider.notifier).apply(ExpenseFilters(
                category: widget.filterCategoryId,
                status: widget.filterStatus));
          }
        });
      }
    }
    final state = ref.watch(expenseSearchStateProvider);
    final ownerKey = ref
        .watch(budgetContextProvider.select((c) => (c.profileId, c.spaceId)));
    ref.listen(expenseSearchStateProvider, (_, next) {
      if (scroll.hasClients) scroll.jumpTo(0);
    });
    final expensesAsync = ref.watch(dailyCardsProvider);
    final canEdit = ref.watch(activeContextCanEditProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, toolbarHeight: 48,
        title: const Text('Expenses'),
        // FR-035: money really did come back, so the return is kept. The user
        // decides whether to move it to another expense or drop it, rather than
        // having the app silently discard it with the target.
        actions: [
          if (canEdit)
            PopupMenuButton<String>(
                tooltip: 'Expense actions',
                onSelected: (_) => context.push('/bulk_entry'),
                itemBuilder: (_) => const [
                      PopupMenuItem(value: 'bulk', child: Text('Bulk entry')),
                    ]),
          if (canEdit) const MonthConvertToMenu(),
          if (canEdit) const _OrphanBannerButton(),
        ],
      ),
      body: Column(children: [
        ExpenseSearchControls(key: ValueKey(ownerKey)),
        Expanded(
            child: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! < -300) {
                ref
                    .read(selectedYearMonthProvider.notifier)
                    .update((state) => nextMonth(state));
              } else if (details.primaryVelocity! > 300) {
                ref
                    .read(selectedYearMonthProvider.notifier)
                    .update((state) => previousMonth(state));
              }
            }
          },
          child: expensesAsync.when(
            data: (expenses) {
              final pages = (expenses.length + 19) ~/ 20;
              final page = pages == 0 ? 0 : state.page.clamp(0, pages - 1);
              if (page != state.page) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted &&
                      ref.read(expenseSearchStateProvider).page == state.page) {
                    ref.read(expenseSearchStateProvider.notifier).page(page);
                  }
                });
              }
              final visible = expenses.skip(page * 20).take(20).toList();
              return Column(children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            '${expenses.fold<int>(0, (total, day) => total + day.expenses.length)} results · ${expenses.length} days · Page ${pages == 0 ? 0 : page + 1} of $pages',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)))),
                Expanded(
                    child: RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(expenseSearchRowsProvider);
                          ref.invalidate(expenseSearchMerchantsProvider);
                        },
                        child: visible.isEmpty
                            ? ListView(controller: scroll, children: [
                                const Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Text(
                                        'No expenses match this search and filters. Try another date range or clear the filters.')),
                                TextButton(
                                    onPressed: () => ref
                                        .read(
                                            expenseSearchStateProvider.notifier)
                                        .clear(),
                                    child:
                                        const Text('Reset search and filters'))
                              ])
                            : SlidableAutoCloseBehavior(
                                child: ListView.builder(
                                    controller: scroll,
                                    itemCount: visible.length + 1,
                                    itemBuilder: (context, index) => index == 0
                                        ? const Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                16, 8, 16, 4),
                                            child: Text(
                                                'Day totals use original currencies. Tap a day to explore its expenses.'))
                                        : DailyExpenseCardTile(
                                            key: ValueKey(
                                                visible[index - 1].date),
                                            day: visible[index - 1],
                                            detailFootnote:
                                                const _MonthRateFootnote(),
                                            expenseBuilder: (expense) =>
                                                _ExpenseTile(
                                                    key: ValueKey(expense.id),
                                                    expense: expense)))))),
                if (expenses.length > 20)
                  SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Wrap(spacing: 16, children: [
                          TextButton(
                              onPressed: page > 0
                                  ? () => ref
                                      .read(expenseSearchStateProvider.notifier)
                                      .page(page - 1)
                                  : null,
                              child: const Text('Previous')),
                          TextButton(
                              onPressed: page + 1 < pages
                                  ? () => ref
                                      .read(expenseSearchStateProvider.notifier)
                                      .page(page + 1)
                                  : null,
                              child: const Text('Next'))
                        ]),
                      )),
              ]);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        )),
      ]),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              // A unique hero tag: two default-tagged FABs on one route (this
              // screen and the category list it opens) make Flutter throw
              // "There are multiple heroes that share the same tag" (T081).
              heroTag: 'expensesAddFab',
              onPressed: () => context.push('/add_expense'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

/// The month's conversion caption at the top of the list (T054).
///
/// Names the rate the month's figures convert at when the display currency
/// differs from the profile main, and the Expenses app bar gains the same
/// convert-to control as the dashboard (T055); a single-currency month renders
/// nothing.
class _MonthRateFootnote extends ConsumerWidget {
  const _MonthRateFootnote();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(expenseSearchStateProvider).filters.scope !=
        ExpenseDateScope.month) {
      return const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
              'Conversions use the owning-month rates for each expense. Amount filters use original currency.'));
    }
    final display = resolveDisplayCurrency(
      month: ref.watch(activeBudgetProvider).value,
      profile: ref.watch(activeProfileProvider).value,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: ConversionFootnote(
        main: ref.watch(mainCurrencyProvider),
        display: display,
        table: ref.watch(rateRegistryProvider).tableFor(
              ref.watch(selectedYearMonthProvider),
            ),
      ),
    );
  }
}

/// App-bar entry that appears only when reimbursements need resolving (FR-035).
class _OrphanBannerButton extends ConsumerWidget {
  const _OrphanBannerButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(expenseRepositoryProvider);
    return StreamBuilder<List<Reimbursement>>(
      stream: repository.watchOrphanedReimbursements(),
      builder: (context, snapshot) {
        final orphans = snapshot.data ?? const <Reimbursement>[];
        if (orphans.isEmpty) return const SizedBox.shrink();
        return IconButton(
          key: const ValueKey('orphan-reimbursements'),
          tooltip: '${orphans.length} reimbursement'
              '${orphans.length == 1 ? '' : 's'} need attention',
          icon: Badge(
            label: Text('${orphans.length}'),
            child: const Icon(Icons.warning_amber_rounded),
          ),
          onPressed: () => _resolveOrphans(context, ref, orphans),
        );
      },
    );
  }

  Future<void> _resolveOrphans(
    BuildContext context,
    WidgetRef ref,
    List<Reimbursement> orphans,
  ) async {
    final repository = ref.read(expenseRepositoryProvider);
    final profileId = ref.read(activeProfileProvider).value?.id;
    final yearMonth = ref.read(selectedYearMonthProvider);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reimbursement without an expense'),
        // `double.maxFinite` width inside a dialog asked for more room than the
        // dialog would grant, and `Flexible` + `shrinkWrap` inside a
        // `MainAxisSize.min` column overflowed as soon as the list outgrew the
        // space left by the keyboard. A bounded box plus one real scroll view
        // keeps the list reachable at any height (FR-035).
        content: SizedBox(
          width: 360,
          // Always a bounded height: `Expanded` inside a `MainAxisSize.min`
          // column is an error when the height is unbounded, and the count-based
          // cap keeps a short list from reserving a tall empty box.
          height: 96 + orphans.length.clamp(1, 4) * 56.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'These returns were kept, but the expense they paid for is gone. '
                'Move each one to an expense, or remove it.',
                style: Theme.of(dialogContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    for (final orphan in orphans)
                      ListTile(
                        key: ValueKey('orphan-${orphan.id}'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${formatMoney(Money(orphan.amount, orphan.currencyCode ?? CurrencyCode.huf))}'
                          ' received ${DateFormat.yMMMd().format(orphan.date)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              key: ValueKey('orphan-restore-${orphan.id}'),
                              onPressed: profileId == null
                                  ? null
                                  : () async {
                                      final target = await _pickTarget(
                                        dialogContext,
                                        profileId,
                                        yearMonth,
                                        repository,
                                      );
                                      if (target == null) return;
                                      if (!dialogContext.mounted) return;
                                      final saved = await runFinancialAction(
                                          dialogContext,
                                          action: () => repository
                                              .restoreOrphanReimbursement(
                                                  orphan.id, target),
                                          success: 'Reimbursement reassigned',
                                          failure:
                                              'Reimbursement could not be reassigned. Please retry.');
                                      if (saved && dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                      }
                                    },
                              child: const Text('Move'),
                            ),
                            TextButton(
                              key: ValueKey('orphan-discard-${orphan.id}'),
                              onPressed: () async {
                                final removed = await runFinancialAction(
                                    dialogContext,
                                    action: () => repository
                                        .discardOrphanReimbursement(orphan.id),
                                    success: 'Unassigned reimbursement removed',
                                    failure:
                                        'Reimbursement could not be removed. Please retry.');
                                if (removed && dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }
                              },
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  /// Lets the user pick which expense the return should now pay for.
  ///
  /// Scoped to the month being viewed, so the choice matches what the user can
  /// see on screen rather than reaching across the whole ledger.
  Future<int?> _pickTarget(
    BuildContext context,
    int profileId,
    String yearMonth,
    ExpenseRepository repository,
  ) async {
    final expenses = await repository.getExpenses(profileId, yearMonth);
    if (expenses.isEmpty) {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No expenses in $yearMonth to move this reimbursement to. '
            'Remove it, or switch to the month the expense belongs to.',
          ),
        ),
      );
      return null;
    }

    if (!context.mounted) return null;
    return showDialog<int>(
      context: context,
      builder: (pickerContext) => SimpleDialog(
        title: Text('Move to which $yearMonth expense?'),
        children: [
          for (final expense in expenses)
            SimpleDialogOption(
              key: ValueKey('restore-target-${expense.id}'),
              onPressed: () => Navigator.pop(pickerContext, expense.id),
              child: Text(
                '${expense.title} - ${formatMoney(Money(expense.amount, expense.currencyCode ?? CurrencyCode.huf))}',
              ),
            ),
        ],
      ),
    );
  }
}

/// An expense row with swipe actions:
/// - Swipe right (start → end): toggle Paid ↔ Planned.
/// - Swipe left (end → start): reveal Edit and Delete.
/// - Tap: open the full edit screen.
class _ExpenseTile extends ConsumerWidget {
  final Expense expense;

  const _ExpenseTile({
    super.key,
    required this.expense,
  });

  void _openEdit(BuildContext context) =>
      context.push('/edit_expense', extra: expense);

  Future<void> _openDetail(BuildContext context, WidgetRef ref) async {
    final owner = ref.read(budgetContextProvider);
    bool stillOwns() {
      final current = ref.read(budgetContextProvider);
      return owner.profileId == current.profileId &&
          owner.spaceId == current.spaceId &&
          (owner.isShared
              ? expense.sharedSpaceId == owner.spaceId
              : expense.sharedSpaceId == null &&
                  expense.profileId == owner.profileId);
    }

    if (!stillOwns()) return;
    if (expense.yearMonth != ref.read(selectedYearMonthProvider)) {
      final accepted = await showDialog<bool>(
          context: context,
          builder: (dialog) => AlertDialog(
                  title: Text('Expense from ${expense.yearMonth}'),
                  content: Text(
                      '${expense.title} belongs to ${expense.yearMonth}. Open that month before viewing or changing its financial details.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialog, false),
                        child: const Text('Cancel')),
                    FilledButton(
                        onPressed: () => Navigator.pop(dialog, true),
                        child: const Text('Open owning month'))
                  ]));
      if (accepted != true || !context.mounted) return;
      if (!stillOwns()) return;
      ref.read(selectedYearMonthProvider.notifier).state = expense.yearMonth;
      final month = await ref.read(activeBudgetProvider.future);
      if (!context.mounted) return;
      if (month == null) {
        showFinancialFeedback(context, 'The owning month is unavailable.',
            kind: FinancialFeedbackKind.warning);
        return;
      }
    }
    try {
      await ref
          .read(expenseSearchRepositoryProvider)
          .authorize(owner, ref.read(actingProfileIdProvider));
    } catch (_) {
      if (context.mounted) {
        showFinancialFeedback(context,
            'This expense is no longer available in the selected context.',
            kind: FinancialFeedbackKind.warning);
      }
      return;
    }
    if (context.mounted && stillOwns()) {
      context.push('/expense_detail', extra: expense);
    }
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final wasPaid = expense.status == ExpenseStatus.paid;
    if (!wasPaid && expense.type == ExpenseType.standard) {
      showFinancialFeedback(context,
          'Choose Paid and complete the payment evidence before saving.');
      _openEdit(context);
      return;
    }
    await runFinancialAction(context, action: () async {
      await ref.read(expensesProvider.notifier).toggleStatus(expense);
    },
        success:
            wasPaid ? 'Expense marked as Planned' : 'Expense marked as Paid',
        failure: 'Expense status could not be updated. Please retry.');
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('"${expense.title}" will be removed for good.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep it')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await runFinancialAction(context, action: () async {
      await ref.read(expensesProvider.notifier).deleteExpense(expense.id);
    },
        success: 'Expense deleted',
        failure: 'Expense could not be deleted. Please retry.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPaid = expense.status == ExpenseStatus.paid;
    final isReimbursed = expense.status == ExpenseStatus.reimbursed;
    final isPartiallyReimbursed =
        expense.status == ExpenseStatus.partiallyReimbursed;
    final canEdit = ref.watch(activeContextCanEditProvider) &&
        expense.yearMonth == ref.watch(selectedYearMonthProvider);

    // T157: the row reads in the month's display currency. The converted
    // amount is the primary figure; long-press reveals what was actually
    // recorded (FR-020). An unsupported legacy code cannot be converted, so it
    // is shown as recorded with a degraded label instead of inventing a figure
    // (FR-014, §4.4).
    final main = ref.watch(mainCurrencyProvider);
    final budget = ref.watch(activeBudgetProvider).value;
    final display = resolveContextDisplayCurrency(budget, main);
    final table = ref.watch(rateRegistryProvider).tableFor(expense.yearMonth);

    final from = expense.currencyCode;
    String primaryText;
    String? originalText;
    String? degradedLabel;
    if (from == null) {
      primaryText = '${expense.amount} ${expense.currency}';
      degradedLabel = 'Rate unavailable';
    } else {
      final formatted = formatExpenseConversion(expense, display, table);
      primaryText = formatted.text;
      originalText = formatted.originalText;
    }

    IconData statusIcon;
    Color statusColor;
    if (isReimbursed) {
      statusIcon = Icons.currency_exchange;
      statusColor = Colors.blue;
    } else if (isPartiallyReimbursed) {
      statusIcon = Icons.change_circle;
      statusColor = Colors.lightBlue;
    } else if (isPaid) {
      statusIcon = Icons.check;
      statusColor = Colors.green;
    } else {
      statusIcon = Icons.schedule;
      statusColor = Colors.orange;
    }

    return Card(
        key: ValueKey('expense-card-${expense.id}'),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Slidable(
          key: ValueKey('slidable-${expense.id}'),
          groupTag: 'expenses',
          startActionPane: canEdit
              ? ActionPane(
                  motion: const BehindMotion(),
                  extentRatio: 0.3,
                  dismissible: DismissiblePane(
                    closeOnCancel: true,
                    confirmDismiss: () async {
                      if (!isReimbursed && !isPartiallyReimbursed) {
                        await _toggle(context, ref);
                      }
                      return false; // keep the row; it just changes status
                    },
                    onDismissed: () {},
                  ),
                  children: [
                    SlidableAction(
                      onPressed: (_) {
                        if (!isReimbursed && !isPartiallyReimbursed) {
                          _toggle(context, ref);
                        }
                      },
                      backgroundColor: isPaid ? Colors.orange : Colors.green,
                      foregroundColor: Colors.white,
                      icon: isPaid ? Icons.schedule : Icons.check_circle,
                      label: isPaid ? 'Planned' : 'Paid',
                    ),
                  ],
                )
              : null,
          // T010: right-to-left → Edit / Delete.
          endActionPane: canEdit
              ? ActionPane(
                  motion: const StretchMotion(),
                  extentRatio: 0.5,
                  children: [
                    SlidableAction(
                      onPressed: (_) => _openEdit(context),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (_) => _delete(context, ref),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                )
              : null,
          child: ListTile(
            onTap: () => _openDetail(context, ref), // T017
            leading: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: CircleAvatar(
                key: ValueKey(expense.status),
                backgroundColor: statusColor.withValues(alpha: 0.2),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                ),
              ),
            ),
            title: Text(expense.title),
            subtitle: Text(
              '${expense.yearMonth} \u2022 ${expense.merchantName ?? 'Merchant not recorded'} \u2022 ${expense.status.name.toUpperCase()} • ${expense.guiltLevel.name}',
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (degradedLabel == null)
                  ConvertedAmountText(
                    text: primaryText,
                    originalText: originalText,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  )
                else
                  Text(
                    primaryText,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                if (degradedLabel != null)
                  Text(
                    degradedLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
        ));
  }
}
