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
import '../../../shared/presentation/modals/app_confirm.dart';
import '../../../shared/presentation/modals/app_dialog.dart';
import '../../dashboard/presentation/budget_status.dart';
import '../../medical/presentation/medical_theme.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _ProfileGroupCard(
            title: 'Budget profiles',
            description:
                'Money set aside for each budget. Overspending borrows from your reserve.',
            profiles: budgetProfiles,
            isBudget: true,
            currency: currency,
            expenses: expenses,
            yearMonth: yearMonth,
            onAdd: () => _showAddDialog(
              context,
              ref,
              currency,
              initialIsBudget: true,
            ),
          ),
          const SizedBox(height: 20),
          _ProfileGroupCard(
            title: 'Direct profiles',
            description:
                'Spend straight from your reserve without an allocation.',
            profiles: directProfiles,
            isBudget: false,
            currency: currency,
            expenses: expenses,
            yearMonth: yearMonth,
            onAdd: () => _showAddDialog(
              context,
              ref,
              currency,
              initialIsBudget: false,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref, currency),
        icon: const Icon(Icons.add),
        label: const Text('Add profile'),
      ),
    );
  }

  Future<void> _showAddDialog(
    BuildContext context,
    WidgetRef ref,
    CurrencyCode currency, {
    bool initialIsBudget = true,
  }) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    var isBudget = initialIsBudget;
    await showAppDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AppDialog(
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
    required this.onAdd,
  });

  final String title;
  final String description;
  final AsyncValue<List<dynamic>> profiles;
  final bool isBudget;
  final CurrencyCode currency;
  final List<Expense> expenses;
  final String yearMonth;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final availableReserve = ref.watch(availableReserveProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _SortMenu(
              onChanged: (order) =>
                  ref.read(profileSortOrderProvider.notifier).state = order,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 10),
        profiles.when(
          data: (items) {
            if (items.isEmpty) {
              return _EmptyProfilesCard(
                key: Key(
                  isBudget ? 'budgetProfilesEmpty' : 'directProfilesEmpty',
                ),
                label: isBudget
                    ? 'Create your first budget'
                    : 'Create your first direct profile',
                onTap: onAdd,
              );
            }
            final order = ref.watch(profileSortOrderProvider);
            final table = ref.watch(rateRegistryProvider).tableFor(yearMonth);
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
              children: [
                for (final entry in sorted)
                  _ProfileCard(
                    key: Key('profileCard-${entry.profile.id}'),
                    entry: entry,
                    isBudget: isBudget,
                    currency: currency,
                    state: ProfileBorrowingState(
                      allocation: entry.allocation,
                      spent: entry.spent,
                      availableReserve: availableReserve,
                    ),
                    onTap: () => openProfileExpenses(
                      context,
                      entry.profile.id,
                      isDirect: !isBudget,
                    ),
                    onEdit: () =>
                        _editProfile(context, ref, entry.profile, currency),
                    onDelete: () => _deleteProfile(context, ref, entry.profile),
                  ),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => const _EmptyProfilesCard(
            label: 'Could not load profiles.',
            icon: Icons.error_outline,
          ),
        ),
      ],
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
    await showAppDialog<void>(
      context: context,
      builder: (context) {
        return AppDialog(
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
    final confirmed = await showAppConfirm(
      context,
      title: 'Delete Profile',
      message: 'Are you sure you want to delete this profile?',
      confirmLabel: 'Delete',
      destructive: true,
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

/// One profile as a standalone, bordered card.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    super.key,
    required this.entry,
    required this.isBudget,
    required this.currency,
    required this.state,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final _ProfileEntry entry;
  final bool isBudget;
  final CurrencyCode currency;
  final ProfileBorrowingState state;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = entry.profile.name as String;
    final remaining = state.remaining;
    final over = isBudget && remaining < 0;
    final statusColor = isBudget
        ? MedicalTheme.semantic(context, state.status.color)
        : scheme.primary;
    final headlineAmount = isBudget
        ? formatMinorUnits(remaining.abs(), currency)
        : formatMinorUnits(entry.spent, currency);
    final headlineLabel = isBudget ? (over ? 'Over by' : 'Left') : 'spent';
    final statusLabel = isBudget
        ? state.status.dashboardLabel(
            currency: currency,
            overspendMinor: state.overspend,
          )
        : 'No budget';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isBudget
                            ? statusColor.withValues(alpha: 0.14)
                            : scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isBudget
                            ? Icons.account_balance_wallet_outlined
                            : Icons.bolt_outlined,
                        size: 20,
                        color:
                            isBudget ? statusColor : scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        headlineAmount,
                                        maxLines: 1,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: over
                                              ? MedicalTheme.semantic(
                                                  context,
                                                  MedicalTheme.moneyOut,
                                                )
                                              : scheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      headlineLabel,
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            statusLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<_ProfileAction>(
                      iconSize: 20,
                      tooltip: 'Profile actions',
                      onSelected: (action) {
                        switch (action) {
                          case _ProfileAction.edit:
                            onEdit();
                          case _ProfileAction.delete:
                            onDelete();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _ProfileAction.edit,
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: _ProfileAction.delete,
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isBudget) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: (state.usagePercent / 100).clamp(0.0, 1.0),
                        minHeight: 4,
                        color: statusColor,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Wrap(
                    spacing: 18,
                    runSpacing: 8,
                    children: [
                      if (isBudget) ...[
                        _ProfileMetric(
                          label: 'Budget',
                          amount: entry.allocation,
                          currency: currency,
                        ),
                        _ProfileMetric(
                          label: 'Spent',
                          amount: entry.spent,
                          currency: currency,
                        ),
                        _ProfileMetric(
                          label: 'Left',
                          amount: remaining,
                          currency: currency,
                          color: over
                              ? MedicalTheme.semantic(
                                  context,
                                  MedicalTheme.moneyOut,
                                )
                              : null,
                        ),
                      ] else
                        _ProfileMetric(
                          label: 'Spent from reserve',
                          amount: entry.spent,
                          currency: currency,
                        ),
                    ],
                  ),
                ),
                if (isBudget && state.borrowed > 0) ...[
                  const SizedBox(height: 8),
                  _ProfileNote(
                    label: 'Borrowed',
                    amountMinor: state.borrowed,
                    currency: currency,
                    color: MedicalTheme.semantic(context, MedicalTheme.planned),
                  ),
                ],
                if (isBudget && state.deficit > 0) ...[
                  const SizedBox(height: 4),
                  _ProfileNote(
                    label: 'Deficit',
                    amountMinor: state.deficit,
                    currency: currency,
                    color: MedicalTheme.semantic(
                      context,
                      MedicalTheme.moneyOut,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({
    required this.label,
    required this.amount,
    required this.currency,
    this.color,
  });

  final String label;
  final int amount;
  final CurrencyCode currency;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formatMinorUnits(amount.abs(), currency),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color ?? scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ProfileNote extends StatelessWidget {
  const _ProfileNote({
    required this.label,
    required this.amountMinor,
    required this.currency,
    required this.color,
  });

  final String label;
  final int amountMinor;
  final CurrencyCode currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: formatMinorUnits(amountMinor, currency),
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
      style: theme.textTheme.bodySmall?.copyWith(color: color),
    );
  }
}

class _EmptyProfilesCard extends StatelessWidget {
  const _EmptyProfilesCard({
    super.key,
    required this.label,
    this.icon = Icons.add_circle_outline,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          if (onTap != null)
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        ],
      ),
    );
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

enum _ProfileAction { edit, delete }

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
    return PopupMenuButton<ProfileSortOrder>(
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
    );
  }
}
