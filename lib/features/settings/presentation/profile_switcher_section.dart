import '../../budget_setup/repositories/onboarding_lifecycle.dart';
import '../../../core/models/merchant.dart';
import '../../../core/services/profile_name.dart';
import '../../../core/models/expense_evidence_chunk.dart';
import '../../../core/models/expense_purchase.dart';
import '../../../core/models/income_source.dart';
import '../../../core/models/budget_profile.dart';
import '../../../core/models/direct_expense_profile.dart';
import '../../../core/models/allocation.dart';
import '../../../core/models/transfer.dart';
import '../../../core/models/audit_event.dart';
import '../../../core/database/schema_migrations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/insurance_profile.dart';
import '../../../core/models/medical_bill.dart';
import '../../../core/models/medical_service_type.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/month_end_run.dart';
import '../../../core/models/shared_member.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../shared/presentation/widgets/money_field.dart';
import '../../expenses/models/reimbursement.dart';
import '../../medical/repositories/medical_repository.dart';
import '../../security/domain/lock_subject.dart';
import '../../security/repositories/lock_setting_janitor.dart';
import '../../spaces/presentation/delete_space_sheet.dart';
import '../../vault/models/savings_vault.dart';
import '../../vault/models/vault_entry.dart';

/// Thrown when a profile cannot be deleted because doing so would leave the app
/// in an invalid state: no profiles left, or a shared space with no Owner
/// (FR-019). Carries a user-facing [message], like `UnauthorizedSpaceAction`.
class ProfileDeletionBlocked implements Exception {
  const ProfileDeletionBlocked(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A count of the personal data deleting a profile would remove, shown in the
/// confirmation summary so the user knows exactly what is at stake (FR-019).
class ProfileDataSummary {
  const ProfileDataSummary({
    this.expenses = 0,
    this.medicalBills = 0,
    this.reimbursements = 0,
    this.hasVault = false,
  });

  final int expenses;
  final int medicalBills;
  final int reimbursements;
  final bool hasVault;

  bool get isEmpty =>
      expenses == 0 && medicalBills == 0 && reimbursements == 0 && !hasVault;

  /// "5 expenses, 2 medical bills and a savings vault", or "nothing".
  String describe() {
    final parts = <String>[
      if (expenses > 0) '$expenses expense${expenses == 1 ? '' : 's'}',
      if (medicalBills > 0)
        '$medicalBills medical bill${medicalBills == 1 ? '' : 's'}',
      if (reimbursements > 0)
        '$reimbursements reimbursement${reimbursements == 1 ? '' : 's'}',
      if (hasVault) 'a savings vault',
    ];
    if (parts.isEmpty) return 'nothing';
    if (parts.length == 1) return parts.first;
    return '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
  }
}

/// The outcome of a profile deletion (FR-019): whether the deleted profile was
/// the active one, and the profile id the app should fall back to.
class ProfileDeletionResult {
  const ProfileDeletionResult({
    required this.wasActive,
    required this.fallbackProfileId,
  });

  final bool wasActive;
  final int? fallbackProfileId;
}

/// The single write path for profile lifecycle: creating a profile and touching
/// its `lastActiveAt` on every selection (US1, FR-001, context-router §3).
class ProfileSwitcherController {
  ProfileSwitcherController(this._isar, {LockSettingJanitor? lockJanitor})
      : _lockJanitor = lockJanitor;

  final Isar _isar;

  /// Removes a deleted profile's security setting with it (FR-034). Optional and
  /// inert when not attached, so 011's behaviour and its tests are unchanged.
  final LockSettingJanitor? _lockJanitor;

  /// Puts a brand-new profile with sensible defaults and seeds its medical
  /// service types (FR-039), mirroring what onboarding seeds for id 1.
  ///
  /// [startingSalary] is optional (FR-006): it becomes the profile's
  /// `defaultNetSalary` so a fresh profile can start with a real take-home
  /// figure; leaving it out (or blank in the dialog) keeps the `0` default.
  ///
  /// The insert and the seed run as **sequential** transactions: seeding opens
  /// its own writeTxn (see [MedicalRepository.ensureDefaultServiceTypes]), and
  /// Isar forbids nested transactions, so putting them inside one txn would
  /// blow up on-device.
  Future<int> createProfile(String name, {double startingSalary = 0}) async {
    final validatedName = checkedProfileName(name);
    final now = DateTime.now();
    final profile = UserProfile()
      ..name = validatedName
      ..avatar = '👤'
      ..primaryCurrency = PrimaryCurrency.huf
      ..monthlyAvailableAmount = 0
      ..defaultNetSalary = startingSalary < 0 ? 0 : startingSalary
      ..createdAt = now
      ..updatedAt = now
      ..lastActiveAt = now;
    profile.id = await _isar.writeTxn(() => _isar.userProfiles.put(profile));
    await MedicalRepository(_isar).ensureDefaultServiceTypes(profile.id);
    return profile.id;
  }

  /// Marks [profileId] as the one used last, so the switcher sorts recency
  /// (FR-001). Fire-and-forget from the UI: the DB write never gates a switch.
  Future<void> touchLastActiveAt(int profileId) => _isar.writeTxn(() async {
        final profile = await _isar.userProfiles.get(profileId);
        if (profile == null) return;
        profile.lastActiveAt = DateTime.now();
        profile.updatedAt = DateTime.now();
        await _isar.userProfiles.put(profile);
      });

  /// Counts the personal rows that deleting [profileId] would remove, for the
  /// confirmation summary (FR-019).
  Future<ProfileDataSummary> summarizeProfile(int profileId) async {
    final expenses =
        await _isar.expenses.filter().profileIdEqualTo(profileId).count();
    final medicalBills =
        await _isar.medicalBills.filter().profileIdEqualTo(profileId).count();
    final reimbursements =
        await _isar.reimbursements.filter().profileIdEqualTo(profileId).count();
    final vault = await _isar.savingsVaults
        .filter()
        .profileIdEqualTo(profileId)
        .findFirst();
    return ProfileDataSummary(
      expenses: expenses,
      medicalBills: medicalBills,
      reimbursements: reimbursements,
      hasVault: vault != null,
    );
  }

  /// Permanently deletes a personal profile and everything it owns, in one
  /// transaction (FR-019).
  ///
  /// Removes the profile's personal rows — budgets, expenses, reimbursements,
  /// medical bills and directory rows, the savings vault — and its space
  /// memberships. Shared rows and other profiles are never touched (shared
  /// money belongs to the space, not the member).
  ///
  /// Refuses to leave the app with zero profiles, and refuses to strip a shared
  /// space of its last Owner. Throws [ProfileDeletionBlocked] in both cases,
  /// writing nothing.
  Future<ProfileDeletionResult> deleteProfile(
    int profileId, {
    required int? activeProfileId,
  }) async {
    final wasActive = profileId == activeProfileId;
    final result = await _isar.writeTxn(() async {
      final profile = await _isar.userProfiles.get(profileId);
      if (profile == null) {
        return ProfileDeletionResult(
          wasActive: wasActive,
          fallbackProfileId: await _lowestProfileId(),
        );
      }

      if (await _isar.userProfiles.count() <= 1) {
        throw const ProfileDeletionBlocked(
          'This is your only profile, so it cannot be deleted.',
        );
      }

      final blockingSpaces = await _blockingSoleOwnership(profileId);
      if (blockingSpaces.isNotEmpty) {
        throw ProfileDeletionBlocked(
          'Transfer ownership of ${blockingSpaces.join(', ')} first, '
          'or delete that space.',
        );
      }

      await _isar.monthlyBudgets
          .filter()
          .profileIdEqualTo(profileId)
          .deleteAll();
      await _isar.expenseEvidenceChunks
          .filter()
          .profileIdEqualTo(profileId)
          .and()
          .sharedSpaceIdIsNull()
          .deleteAll();
      await _isar.expenses.filter().profileIdEqualTo(profileId).deleteAll();
      await _isar.reimbursements
          .filter()
          .profileIdEqualTo(profileId)
          .deleteAll();
      await _isar.savingsVaults
          .filter()
          .profileIdEqualTo(profileId)
          .deleteAll();
      await _isar.vaultEntrys.filter().profileIdEqualTo(profileId).deleteAll();
      await _isar.medicalBills.filter().profileIdEqualTo(profileId).deleteAll();
      await _isar.insuranceProfiles
          .filter()
          .profileIdEqualTo(profileId)
          .deleteAll();
      await _isar.familyMembers
          .filter()
          .profileIdEqualTo(profileId)
          .deleteAll();
      await _isar.medicalProviders
          .filter()
          .profileIdEqualTo(profileId)
          .deleteAll();
      await _isar.medicalServiceTypes
          .filter()
          .profileIdEqualTo(profileId)
          .deleteAll();
      await _isar.sharedMembers
          .filter()
          .profileIdEqualTo(profileId)
          .deleteAll();
      await _isar.expensePurchases
          .filter()
          .profileIdEqualTo(profileId)
          .sharedSpaceIdIsNull()
          .deleteAll();
      await _isar.monthEndRuns
          .filter()
          .profileIdEqualTo(profileId)
          .sharedSpaceIdIsNull()
          .deleteAll();
      await _isar.incomeSources
          .filter()
          .sharedSpaceIdIsNull()
          .profileIdEqualTo(profileId)
          .deleteAll();
      await _isar.budgetProfiles
          .filter()
          .sharedSpaceIdIsNull()
          .profileIdEqualTo(profileId)
          .deleteAll();
      await _isar.directExpenseProfiles
          .filter()
          .sharedSpaceIdIsNull()
          .profileIdEqualTo(profileId)
          .deleteAll();
      await _isar.allocations
          .filter()
          .sharedSpaceIdIsNull()
          .profileIdEqualTo(profileId)
          .deleteAll();
      await _isar.transfers
          .filter()
          .sharedSpaceIdIsNull()
          .profileIdEqualTo(profileId)
          .deleteAll();
      await _isar.merchants
          .filter()
          .sharedSpaceIdIsNull()
          .profileIdEqualTo(profileId)
          .deleteAll();
      await _isar.auditEvents
          .filter()
          .sharedSpaceIdIsNull()
          .profileIdEqualTo(profileId)
          .deleteAll();
      for (final stamp in await _isar.schemaMigrationStamps
          .filter()
          .keyStartsWith('audit:head:')
          .findAll()) {
        if (stamp.key.startsWith('audit:head:[false,"personal:$profileId",')) {
          await _isar.schemaMigrationStamps.delete(stamp.id);
        }
      }
      await pruneDeletedProfileSetupInTxn(_isar, profileId);
      await _isar.userProfiles.delete(profileId);

      // FR-034: the profile's security setting is removed with the profile. The
      // row goes inside this transaction; its verifier and lockout records live
      // in secure storage (not Isar), so they are erased just below, once the
      // removal is committed.
      await _lockJanitor?.deleteRowInTxn(LockSubject.profileKey(profileId));

      return ProfileDeletionResult(
        wasActive: wasActive,
        fallbackProfileId: await _lowestProfileId(),
      );
    });

    await _lockJanitor?.forgetSecrets(LockSubject.profileKey(profileId));
    return result;
  }

  /// Names of the spaces where [profileId] is the **only** Owner — deleting the
  /// profile would leave those spaces ownerless, so deletion is refused
  /// (FR-006/019).
  Future<List<String>> _blockingSoleOwnership(int profileId) async {
    final memberships = await _isar.sharedMembers
        .filter()
        .profileIdEqualTo(profileId)
        .findAll();
    final names = <String>[];
    for (final membership in memberships) {
      if (membership.role != SharedMemberRole.owner) continue;
      final owners = await _isar.sharedMembers
          .filter()
          .sharedSpaceIdEqualTo(membership.sharedSpaceId)
          .and()
          .roleEqualTo(SharedMemberRole.owner)
          .count();
      if (owners <= 1) {
        final space = await _isar.sharedSpaces.get(membership.sharedSpaceId);
        names.add(space?.name ?? 'a shared space');
      }
    }
    return names;
  }

  /// The id of the lowest-numbered surviving profile, or `null` when none exist
  /// (only reachable on the "already deleted" no-op path).
  Future<int?> _lowestProfileId() async {
    final rows = await _isar.userProfiles.where().findAll();
    if (rows.isEmpty) return null;
    var lowest = rows.first.id;
    for (final row in rows) {
      if (row.id < lowest) lowest = row.id;
    }
    return lowest;
  }
}

final profileSwitcherControllerProvider = Provider<ProfileSwitcherController>(
  (ref) => ProfileSwitcherController(
    IsarHelper.instance,
    lockJanitor: LockSettingJanitor.forApp(IsarHelper.instance),
  ),
);

/// US1: the list of personal profiles with add/switch controls.
///
/// Displays every profile as a tappable tile (key `profileTile_<id>`), marks
/// the active one with `Icons.radio_button_checked`, and offers an add tile
/// (key `addProfileButton`) that opens the "New profile" dialog containing a
/// `profileNameField` and a `saveProfileButton`.
class ProfileSwitcherSection extends ConsumerWidget {
  const ProfileSwitcherSection({super.key, this.onSelected});
  final VoidCallback? onSelected;

  void _switchTo(WidgetRef ref, UserProfile profile) {
    // Marker writes are synchronous; every dependent provider re-derives within
    // this same frame (context-router §1).
    ref.read(activeProfileIdProvider.notifier).state = profile.id;
    ref.read(activeSpaceIdProvider.notifier).state = null;
    // FR-001: the DB touch is fire-and-forget, it never blocks the switch.
    ref
        .read(profileSwitcherControllerProvider)
        .touchLastActiveAt(profile.id)
        .ignore();
    onSelected?.call();
  }

  // The dialog owns the text controllers and disposes them only when its own
  // element unmounts — that is, once the route's exit transition has fully
  // closed. Disposing it here instead (right after `showDialog` resolves)
  // races the exit animation and blows up with "used after being disposed".
  Future<void> _createProfile(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_NewProfileDraft>(
      context: context,
      builder: (_) => const _NewProfileDialog(),
    );
    if (result == null) return;
    final trimmed = result.name.trim();
    if (trimmed.isEmpty) return;
    final id = await ref.read(profileSwitcherControllerProvider).createProfile(
          trimmed,
          startingSalary: result.startingSalary,
        );
    ref.read(activeProfileIdProvider.notifier).state = id;
    ref.read(activeSpaceIdProvider.notifier).state = null;
    onSelected?.call();
  }

  /// US1/FR-019: delete a personal profile after a counted, typed-name
  /// confirmation. Refusals (last profile, sole Owner) surface as a SnackBar.
  Future<void> _deleteProfile(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    final controller = ref.read(profileSwitcherControllerProvider);
    final summary = await controller.summarizeProfile(profile.id);
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => TypedNameConfirmDialog(
        spaceName: profile.name,
        title: 'Delete this profile?',
        message: summary.isEmpty
            ? 'This profile has no saved money.'
            : 'This permanently deletes ${summary.describe()} for '
                '"${profile.name}". This cannot be undone.',
        fieldKey: const Key('deleteProfileNameField'),
        buttonKey: const Key('confirmDeleteProfileButton'),
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final activeId = ref.read(activeProfileProvider).value?.id;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result =
          await controller.deleteProfile(profile.id, activeProfileId: activeId);
      if (result.wasActive) {
        ref.read(activeProfileIdProvider.notifier).state =
            result.fallbackProfileId;
        ref.read(activeSpaceIdProvider.notifier).state = null;
        onSelected?.call();
      }
      messenger.showSnackBar(
        SnackBar(content: Text('Profile "${profile.name}" deleted.')),
      );
    } on ProfileDeletionBlocked catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(profilesProvider);
    final activeId = ref.watch(activeProfileProvider).valueOrNull?.id;

    return profilesAsync.when(
      data: (profiles) {
        if (profiles.isEmpty) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profiles',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final profile in profiles)
                      _ProfileTile(
                        key: Key('profileTile_${profile.id}'),
                        profile: profile,
                        active: profile.id == activeId,
                        onTap: () => _switchTo(ref, profile),
                        // The last profile cannot be deleted, so its tile shows
                        // no delete affordance (FR-019).
                        onDelete: profiles.length > 1
                            ? () => _deleteProfile(context, ref, profile)
                            : null,
                      ),
                    _AddProfileTile(
                      key: const Key('addProfileButton'),
                      onTap: () => _createProfile(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    super.key,
    required this.profile,
    required this.active,
    required this.onTap,
    this.onDelete,
  });

  final UserProfile profile;
  final bool active;
  final VoidCallback onTap;

  /// When non-null, the tile offers a delete action (FR-019). `null` on the
  /// last remaining profile, which can never be deleted.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 88,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 26,
                  child: Text(profile.avatar.isEmpty ? '👤' : profile.avatar,
                      style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                active
                    ? Icon(Icons.radio_button_checked,
                        size: 16, color: theme.colorScheme.primary)
                    : const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        if (onDelete != null)
          Positioned(
            top: -8,
            right: -4,
            child: PopupMenuButton<String>(
              key: Key('profileMenuButton_${profile.id}'),
              tooltip: 'Profile options',
              padding: EdgeInsets.zero,
              iconSize: 16,
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'delete') onDelete!();
              },
              itemBuilder: (_) => [
                PopupMenuItem<String>(
                  value: 'delete',
                  key: Key('deleteProfileOption_${profile.id}'),
                  child: const Text('Delete profile'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AddProfileTile extends StatelessWidget {
  const _AddProfileTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 88,
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Icon(Icons.add, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 4),
            Text(
              'Add',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

/// The "New profile" dialog's result: the chosen name plus an optional starting
/// salary (0 when the user leaves it blank).
class _NewProfileDraft {
  const _NewProfileDraft({required this.name, required this.startingSalary});

  final String name;
  final double startingSalary;
}

/// The "New profile" dialog. Owns its [TextEditingController]s: disposal happens
/// in `State.dispose()`, which runs only when the dialog's element is unmounted
/// — after the route's exit transition finishes — so the animating `TextField`
/// never builds against a disposed controller.
class _NewProfileDialog extends StatefulWidget {
  const _NewProfileDialog();

  @override
  State<_NewProfileDialog> createState() => _NewProfileDialogState();
}

class _NewProfileDialogState extends State<_NewProfileDialog> {
  String? error;
  final _name = TextEditingController();
  final _salary = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _salary.dispose();
    super.dispose();
  }

  void _save() {
    final problem = profileNameProblem(_name.text);
    if (problem != null) {
      setState(() => error = problem);
      return;
    }
    // Blank salary means "start at 0" (FR-006) — not an error.
    final salary = parseMoneyInput(_salary.text) ?? 0.0;
    Navigator.of(context).pop(
      _NewProfileDraft(name: _name.text.trim(), startingSalary: salary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('profileNameField'),
            controller: _name,
            autofocus: true,
            decoration:
                InputDecoration(labelText: 'Profile name', errorText: error),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          MoneyField(
            key: const Key('startingSalaryField'),
            controller: _salary,
            label: 'Starting salary (optional)',
            helperText: 'You can change this any time in Settings.',
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('saveProfileButton'),
          onPressed: _save,
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
