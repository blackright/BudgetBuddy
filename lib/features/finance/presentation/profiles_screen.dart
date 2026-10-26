import '../../../shared/presentation/financial_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/budget_profile.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/models/direct_expense_profile.dart';
import '../../../core/models/expense.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../../core/services/borrowing_service.dart';
import '../../../core/services/profile_spending_service.dart';
import '../../../shared/presentation/input_formatters/thousands_separator_input_formatter.dart';
import '../../../shared/presentation/money_format.dart';
import '../../dashboard/presentation/budget_status.dart';
import '../../engine/currency_resolution.dart';
import '../../engine/providers/rate_registry_provider.dart';
import '../../engine/providers/true_available_provider.dart';
import '../../expenses/models/reimbursement.dart';
import '../providers/profile_providers.dart';
import '../providers/reserve_providers.dart';

class ProfilesScreen extends ConsumerWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetProfiles = ref.watch(budgetProfilesProvider);
    final directProfiles = ref.watch(directExpenseProfilesProvider);
    final isShared = ref.watch(budgetContextProvider).isShared;
    final currency = isShared
        ? (ref.watch(activeSpaceProvider).value?.currency.code ??
            CurrencyCode.huf)
        : (ref.watch(activeProfileProvider).value?.primaryCurrency.code ??
            CurrencyCode.huf);
    final expenses = ref.watch(contextExpensesProvider);
    final yearMonth = ref.watch(budgetContextProvider).yearMonth;
    ref.watch(profileSpendingSyncProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profiles')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileGroupCard(
            title: 'Budget Profiles',
            description:
                'Profiles that receive allocations from your reserve. Spending beyond allocation borrows from reserve.',
            profiles: budgetProfiles,
            isBudget: true,
            currency: currency,
            expenses: expenses,
            yearMonth: yearMonth,
          ),
          const SizedBox(height: 16),
          _ProfileGroupCard(
            title: 'Direct Expense Profiles',
            description:
                'Profiles that spend directly from your reserve without allocations or borrowing.',
            profiles: directProfiles,
            isBudget: false,
            currency: currency,
            expenses: expenses,
            yearMonth: yearMonth,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref, currency),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDialog(
      BuildContext context, WidgetRef ref, CurrencyCode currency) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    var isBudget = true;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Profile'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  if (isBudget)
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText:
                            'Allocation (${currency.code.toUpperCase()})',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: const [
                        ThousandsSeparatorInputFormatter()
                      ],
                    ),
                  DropdownButtonFormField<bool>(
                    initialValue: isBudget,
                    items: const [
                      DropdownMenuItem(
                          value: true, child: Text('Budget Profile')),
                      DropdownMenuItem(
                          value: false, child: Text('Direct Expense Profile')),
                    ],
                    onChanged: (v) => setDialogState(() {
                      isBudget = v ?? isBudget;
                    }),
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    final saved = await runFinancialAction(context,
                        action: () async {
                      if (isBudget) {
                        final value =
                            parseMoneyInput(amountController.text) ?? 0;
                        final profile = BudgetProfile()
                          ..name = name
                          ..allocation =
                              (value * currency.minorUnitsPerMajor).round()
                          ..createdAt = DateTime.now()
                          ..updatedAt = DateTime.now();
                        await ref
                            .read(profileActionsProvider)
                            .saveBudget(profile);
                      } else {
                        final profile = DirectExpenseProfile()
                          ..name = name
                          ..createdAt = DateTime.now()
                          ..updatedAt = DateTime.now();
                        await ref
                            .read(profileActionsProvider)
                            .saveDirect(profile);
                      }
                    },
                        success: 'Profile added',
                        failure: 'Profile could not be added. Please retry.');
                    if (saved && context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ProfileGroupCard extends ConsumerWidget {
  const _ProfileGroupCard({
    required this.title,
    required this.description,
    required this.profiles,
    required this.isBudget,
    required this.currency,
    required this.expenses,
    required this.yearMonth,
  });

  final String title;
  final String description;
  final AsyncValue<List<dynamic>> profiles;
  final bool isBudget;
  final CurrencyCode currency;
  final List<Expense> expenses;
  final String yearMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final availableReserve = ref.watch(availableReserveProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(description, style: theme.textTheme.bodySmall),
            const SizedBox(height: 12),
            _SortMenu(
              onChanged: (order) =>
                  ref.read(profileSortOrderProvider.notifier).state = order,
            ),
            const SizedBox(height: 4),
            profiles.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Text('No profiles yet.');
                }
                final order = ref.watch(profileSortOrderProvider);
                final table =
                    ref.watch(rateRegistryProvider).tableFor(yearMonth);
                final sorted = _sorted(
                  items,
                  order,
                  isBudget,
                  expenses,
                  yearMonth,
                  (expense) =>
                      expenseToDisplay(expense, currency, table).minorUnits,
                  ref.watch(monthlyReimbursementsProvider).value ?? const [],
                  (r) => reimbursementToDisplay(r, currency, table).minorUnits,
                );
                return Column(
                  children: sorted.map((entry) {
                    final p = entry.profile;
                    final name = (p as dynamic).name as String;
                    final allocation = entry.allocation;
                    final spent = entry.spent;
                    final remaining = allocation - spent;
                    final state = ProfileBorrowingState(
                      allocation: allocation,
                      spent: spent,
                      availableReserve: availableReserve,
                    );
                    final subtitle = isBudget
                        ? 'Allocated: ${formatMinorUnits(allocation, currency)} • '
                            'Spent: ${formatMinorUnits(spent, currency)} • '
                            'Left: ${formatMinorUnits(remaining, currency)}'
                        : 'Spent from reserve: '
                            '${formatMinorUnits(spent, currency)}';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(subtitle),
                          if (isBudget && state.borrowed > 0)
                            Text(
                              'Borrowed from reserve: '
                              '${formatMinorUnits(state.borrowed, currency)}',
                              style: TextStyle(
                                color: state.status.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (isBudget && state.deficit > 0)
                            Text(
                              'Deficit: '
                              '${formatMinorUnits(state.deficit, currency)}',
                              style: TextStyle(
                                color: BudgetStatus.red.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      // T132: tapping a profile opens that profile's own view.
                      onTap: () => openProfileExpenses(
                          context, entry.profile.id,
                          isDirect: !isBudget),
                      leading: Icon(
                        isBudget
                            ? Icons.account_balance_wallet
                            : Icons.receipt_long,
                        color: isBudget ? state.status.color : null,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _editProfile(context, ref, p, currency),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteProfile(context, ref, p),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editProfile(BuildContext context, WidgetRef ref,
      dynamic profile, CurrencyCode currency) async {
    final nameController =
        TextEditingController(text: (profile as dynamic).name as String);
    final amountController = TextEditingController();
    if (profile is BudgetProfile) {
      amountController.text =
          formatMinorUnitsInput(profile.allocation, currency);
    }
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              if (profile is BudgetProfile)
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Allocation (${currency.code.toUpperCase()})',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: const [ThousandsSeparatorInputFormatter()],
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                (profile as dynamic).name = name;
                (profile as dynamic).updatedAt = DateTime.now();
                if (profile is BudgetProfile) {
                  final value = parseMoneyInput(amountController.text) ?? 0;
                  profile.allocation =
                      (value * currency.minorUnitsPerMajor).round();
                }
                final saved = await runFinancialAction(context,
                    action: () async {
                  if (profile is BudgetProfile) {
                    await ref.read(profileActionsProvider).saveBudget(profile);
                  } else {
                    await ref
                        .read(profileActionsProvider)
                        .saveDirect(profile as DirectExpenseProfile);
                  }
                },
                    success: 'Profile updated',
                    failure: 'Profile could not be saved. Please retry.');
                if (saved && context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProfile(
      BuildContext context, WidgetRef ref, dynamic profile) async {
    if (isBudget) {
      final bp = profile as BudgetProfile;
      if (bp.allocation != 0 || bp.spent != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Cannot delete a profile with allocation or spending.')),
        );
        return;
      }
    } else {
      final dp = profile as DirectExpenseProfile;
      if (dp.spent != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Cannot delete a profile with spending.')),
        );
        return;
      }
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: const Text('Are you sure you want to delete this profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await runFinancialAction(context, action: () async {
      if (isBudget) {
        await ref
            .read(profileActionsProvider)
            .deleteBudget((profile as BudgetProfile).id);
      } else {
        await ref
            .read(profileActionsProvider)
            .deleteDirect((profile as DirectExpenseProfile).id);
      }
    },
        success: 'Profile deleted',
        failure:
            'Profile could not be deleted. Check its allocation and spending.');
  }

  /// Sorts the profiles the way the user asked for.
  List<_ProfileEntry> _sorted(
    List<dynamic> items,
    ProfileSortOrder order,
    bool budget,
    List<Expense> expenses,
    String yearMonth,
    int Function(Expense expense) convert,
    List<Reimbursement> returns,
    int Function(Reimbursement) convertReturn,
  ) {
    final entries = items.map((p) {
      final id = (p as dynamic).id as int;
      return _ProfileEntry(
        profile: p,
        allocation: budget ? (p as dynamic).allocation as int : 0,
        spent: const ProfileSpendingService().spentInYearMonth(
          profileId: id,
          profileType: budget
              ? FinancialProfileType.budget
              : FinancialProfileType.direct,
          yearMonth: yearMonth,
          expenses: expenses,
          reimbursements: returns,
          convertReimbursement: convertReturn,
          convert: convert,
        ),
      );
    }).toList();

    switch (order) {
      case ProfileSortOrder.name:
        entries.sort((a, b) => (a.profile.name as String)
            .toLowerCase()
            .compareTo((b.profile.name as String).toLowerCase()));
      case ProfileSortOrder.allocation:
        entries.sort((a, b) => b.allocation.compareTo(a.allocation));
      case ProfileSortOrder.spent:
        entries.sort((a, b) => b.spent.compareTo(a.spent));
    }
    return entries;
  }
}

/// How the profiles in a card are ordered.
enum ProfileSortOrder {
  name,
  allocation,
  spent,
}

/// The chosen order, shared by every profile card on the screen.
final profileSortOrderProvider =
    StateProvider<ProfileSortOrder>((ref) => ProfileSortOrder.name);

/// One profile with its money numbers, ready to be shown.
class _ProfileEntry {
  const _ProfileEntry({
    required this.profile,
    required this.allocation,
    required this.spent,
  });

  final dynamic profile;
  final int allocation;
  final int spent;
}

/// A small menu that chooses how the profiles are ordered.
class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.onChanged});

  final ValueChanged<ProfileSortOrder> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: PopupMenuButton<ProfileSortOrder>(
        icon: const Icon(Icons.sort),
        tooltip: 'Sort profiles',
        onSelected: onChanged,
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: ProfileSortOrder.name,
            child: Text('Sort by name'),
          ),
          PopupMenuItem(
            value: ProfileSortOrder.allocation,
            child: Text('Sort by allocation'),
          ),
          PopupMenuItem(
            value: ProfileSortOrder.spent,
            child: Text('Sort by spending'),
          ),
        ],
      ),
    );
  }
}
