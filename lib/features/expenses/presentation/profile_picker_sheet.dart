import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/budget_profile.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/direct_expense_profile.dart';
import '../../finance/providers/profile_providers.dart';

/// The result of the profile picker: the chosen profile id, or `null` for
/// the Main Profile.
class ProfilePickerResult {
  const ProfilePickerResult(this.profileId, {this.profileType, this.syncGuid});

  final String? profileType;
  final String? syncGuid;

  /// The chosen profile, or `null` when the expense belongs to the Main
  /// Profile.
  final int? profileId;
}

/// A searchable list of the profiles of the active context.
///
/// Both kinds of profile are offered, in two clearly separated groups
/// (T140). A search box sits on top, so the list stays quick to use even
/// with many profiles, and a **create new** action at the bottom means the
/// user never has to leave the expense screen to make a profile.
class ProfilePickerSheet extends ConsumerStatefulWidget {
  const ProfilePickerSheet(
      {super.key, this.selectedProfileId, this.selectedProfileType});

  /// The profile that is chosen right now, so it can be marked.
  final int? selectedProfileId;
  final String? selectedProfileType;

  /// Shows the sheet and returns the choice.
  ///
  /// The whole result is returned, not just the id, so that "None — Main
  /// Profile" (a real choice, with a `null` id) can be told apart from the
  /// sheet being dismissed (a `null` result).
  static Future<ProfilePickerResult?> show(
    BuildContext context, {
    int? selectedProfileId,
    String? selectedProfileType,
  }) async {
    return showModalBottomSheet<ProfilePickerResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => ProfilePickerSheet(
        selectedProfileId: selectedProfileId,
        selectedProfileType: selectedProfileType,
      ),
    );
  }

  @override
  ConsumerState<ProfilePickerSheet> createState() => _ProfilePickerSheetState();
}

class _ProfilePickerSheetState extends ConsumerState<ProfilePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(String name) {
    if (_query.isEmpty) return true;
    return name.toLowerCase().contains(_query.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budgetProfiles = ref.watch(budgetProfilesProvider).value ?? const [];
    final directProfiles =
        ref.watch(directExpenseProfilesProvider).value ?? const [];

    final budget = budgetProfiles.where((p) => _matches(p.name)).toList();
    final direct = directProfiles.where((p) => _matches(p.name)).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a profile',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search profiles',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // The Main Profile: the money that is not in a profile.
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: const Text('None — Main Profile'),
                    subtitle: const Text('This expense is not in a profile'),
                    trailing: widget.selectedProfileId == null
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () => Navigator.of(context)
                        .pop(const ProfilePickerResult(null)),
                  ),
                  if (budget.isNotEmpty) ...[
                    const Divider(),
                    const _GroupLabel(label: 'Budget Profiles'),
                    for (final profile in budget)
                      ListTile(
                        leading: const Icon(Icons.account_balance_wallet),
                        title: Text(profile.name),
                        trailing: widget.selectedProfileId == profile.id &&
                                widget.selectedProfileType ==
                                    FinancialProfileType.budget
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () => Navigator.of(context).pop(
                            ProfilePickerResult(profile.id,
                                profileType: FinancialProfileType.budget,
                                syncGuid: profile.syncGuid)),
                      ),
                  ],
                  if (direct.isNotEmpty) ...[
                    const Divider(),
                    const _GroupLabel(label: 'Direct Expense Profiles'),
                    for (final profile in direct)
                      ListTile(
                        leading: const Icon(Icons.receipt_long),
                        title: Text(profile.name),
                        trailing: widget.selectedProfileId == profile.id &&
                                widget.selectedProfileType ==
                                    FinancialProfileType.direct
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () => Navigator.of(context).pop(
                            ProfilePickerResult(profile.id,
                                profileType: FinancialProfileType.direct,
                                syncGuid: profile.syncGuid)),
                      ),
                  ],
                  if (budget.isEmpty && direct.isEmpty) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _query.isEmpty
                            ? 'You have no profiles yet.'
                            : 'No profile matches "$_query".',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                  const Divider(),
                  // Create a new profile without leaving the expense screen.
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Create new profile'),
                    onTap: () => _createProfile(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Asks for a name and a type, then creates the profile and returns it.
  Future<void> _createProfile(BuildContext context) async {
    final nameController = TextEditingController();
    var isBudget = true;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New Profile'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<bool>(
                    initialValue: isBudget,
                    items: const [
                      DropdownMenuItem(
                          value: true, child: Text('Budget Profile')),
                      DropdownMenuItem(
                          value: false, child: Text('Direct Expense Profile')),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => isBudget = v ?? isBudget),
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context)
                      .pop(nameController.text.trim().isNotEmpty),
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    if (created != true || !context.mounted) return;
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final actions = ref.read(profileActionsProvider);
    if (isBudget) {
      final profile = BudgetProfile()
        ..name = name
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
      await actions.saveBudget(profile);
      if (context.mounted) {
        Navigator.of(context).pop(ProfilePickerResult(profile.id,
            profileType: FinancialProfileType.budget,
            syncGuid: profile.syncGuid));
      }
    } else {
      final profile = DirectExpenseProfile()
        ..name = name
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
      await actions.saveDirect(profile);
      if (context.mounted) {
        Navigator.of(context).pop(ProfilePickerResult(profile.id,
            profileType: FinancialProfileType.direct,
            syncGuid: profile.syncGuid));
      }
    }
  }
}

/// The heading of a group of profiles in the sheet.
class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        label,
        style: theme.textTheme.labelMedium
            ?.copyWith(color: theme.colorScheme.primary),
      ),
    );
  }
}
