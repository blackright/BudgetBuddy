import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/shared_member.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../shared/presentation/money_format.dart';
import '../../../shared/presentation/widgets/money_field.dart';
import '../../../shared/presentation/widgets/sync_status_chip.dart';
import '../../pairing/presentation/pair_device_screen.dart';
import '../providers/spaces_providers.dart';
import '../repositories/space_role_guard.dart';
import '../repositories/spaces_repository.dart';
import 'delete_space_sheet.dart';
import 'invite_sheet.dart';

String _roleLabel(SharedMemberRole role) => switch (role) {
      SharedMemberRole.owner => 'Owner',
      SharedMemberRole.editor => 'Editor',
      SharedMemberRole.viewer => 'Viewer',
    };

/// The Owner-only actions on a member row (T079).
///
/// Honoured in `onSelected` rather than `PopupMenuItem.onTap`: `onSelected`
/// runs after the menu route has settled, so a dialog opened from it is not
/// racing the popup's own dismissal, and it keeps every member action in one
/// switch that a test can reason about.
enum _MemberAction { remove, makeOwner }

/// Owner-only rename dialog. Stateful: owns its controller (profile-dialog
/// discipline, T026 regression).
class _RenameSpaceDialog extends StatefulWidget {
  const _RenameSpaceDialog({required this.initialName});

  final String initialName;

  @override
  State<_RenameSpaceDialog> createState() => _RenameSpaceDialogState();
}

class _RenameSpaceDialogState extends State<_RenameSpaceDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename space'),
      content: TextField(
        key: const Key('spaceNameEditField'),
        controller: _name,
        autofocus: true,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('saveEditSpaceNameButton'),
          onPressed: () {
            final name = _name.text.trim();
            if (name.isEmpty) return;
            Navigator.of(context).pop(name);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Owner-only "Our income" edit dialog (whole minor units → major field).
class _IncomeDialog extends StatefulWidget {
  const _IncomeDialog({required this.currency, required this.defaultIncome});

  final PrimaryCurrency currency;
  final int defaultIncome;

  @override
  State<_IncomeDialog> createState() => _IncomeDialogState();
}

class _IncomeDialogState extends State<_IncomeDialog> {
  late final TextEditingController _income = TextEditingController(
    text: NumberFormat('#,##0.00').format(
      widget.defaultIncome / widget.currency.code.minorUnitsPerMajor,
    ),
  );

  @override
  void dispose() {
    _income.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Our income'),
      content: MoneyField(
        key: const Key('ourIncomeField'),
        controller: _income,
        autofocus: true,
        prefixText: '${widget.currency.code.symbol} ',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('saveOurIncomeButton'),
          onPressed: () {
            final major = parseMoneyInput(_income.text);
            if (major == null || major < 0) return;
            Navigator.of(context).pop(
              (major * widget.currency.code.minorUnitsPerMajor).round(),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Owner-only transfer — pick the next Owner among members (last-Owner rule).
class _TransferDialog extends StatefulWidget {
  const _TransferDialog({
    required this.members,
    required this.currentOwnerId,
    required this.names,
  });

  final List<SharedMember> members;
  final int currentOwnerId;
  final Map<int, String> names;

  @override
  State<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<_TransferDialog> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Make someone else the Owner'),
      content: SizedBox(
        width: double.maxFinite,
        child: RadioGroup<int>(
          groupValue: _selected,
          onChanged: (value) => setState(() => _selected = value),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final member in widget.members)
                if (member.profileId != widget.currentOwnerId)
                  ListTile(
                    key: Key('transferOwnership_${member.profileId}'),
                    dense: true,
                    title: Text(
                      widget.names[member.profileId] ?? 'Profile',
                    ),
                    trailing: Radio<int>(value: member.profileId),
                    onTap: () => setState(() => _selected = member.profileId),
                  ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('confirmTransferButton'),
          onPressed: _selected == null
              ? null
              : () => Navigator.of(context).pop(_selected),
          child: const Text('Transfer'),
        ),
      ],
    );
  }
}

/// US2: the shared-space management section shown in Settings when a space is
/// active.
///
/// Everyone sees the space identity and the member/role list (they act as the
/// record of the space); only the Owner sees the manage controls. Every manage
/// action calls `SpacesRepository`, which re-checks ownership at the data
/// layer, so a stale UI can never mutate beyond its role (space-roles §4).
///
/// Returns `SizedBox.shrink()` in personal context.
class SpaceSettingsSection extends ConsumerWidget {
  const SpaceSettingsSection({super.key});

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final space = ref.read(activeSpaceProvider).value;
    final profileId = ref.read(activeProfileProvider).value?.id;
    if (space == null || profileId == null) return;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameSpaceDialog(initialName: space.name),
    );
    if (name == null) return;
    await ref.read(spacesRepositoryProvider).updateSpace(
          actingProfileId: profileId,
          spaceId: space.id,
          name: name,
        );
  }

  Future<void> _editIncome(BuildContext context, WidgetRef ref) async {
    final space = ref.read(activeSpaceProvider).value;
    final profileId = ref.read(activeProfileProvider).value?.id;
    if (space == null || profileId == null) return;
    final income = await showDialog<int>(
      context: context,
      builder: (_) => _IncomeDialog(
          currency: space.currency, defaultIncome: space.defaultIncome),
    );
    if (income == null) return;
    await ref.read(spacesRepositoryProvider).updateSpace(
          actingProfileId: profileId,
          spaceId: space.id,
          defaultIncome: income,
        );
  }

  Future<void> _transfer(BuildContext context, WidgetRef ref) async {
    final space = ref.read(activeSpaceProvider).value;
    final profileId = ref.read(activeProfileProvider).value?.id;
    final members =
        ref.read(activeSpaceMembersProvider).value ?? const <SharedMember>[];
    if (space == null || profileId == null) return;
    final target = await showDialog<int>(
      context: context,
      builder: (_) {
        return _TransferDialog(
          members: members,
          currentOwnerId: profileId,
          names: ref.read(memberDisplayNamesProvider),
        );
      },
    );
    if (target == null) return;
    await ref.read(spacesRepositoryProvider).transferOwnership(
          actingProfileId: profileId,
          spaceId: space.id,
          newOwnerProfileId: target,
        );
  }

  /// Owner-only member removal, behind a confirmation (T079).
  ///
  /// The dialog exists so a stray tap can never drop somebody from a shared
  /// space: the money they put in stays in the space's months, and only their
  /// access goes away.
  Future<void> _removeMember(
    BuildContext context,
    WidgetRef ref,
    SharedMember member,
  ) async {
    final space = ref.read(activeSpaceProvider).value;
    final myRole = ref.read(activeSpaceMyRoleProvider);
    if (space == null || myRole == null) return;

    final names = ref.read(memberDisplayNamesProvider);
    final name = names[member.profileId] ?? 'This member';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove this member?'),
        content: Text(
          '$name loses access to ${space.name} on their phone. Money already '
          'in the space stays there, and you can invite them again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirmRemoveMemberButton'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(spacesRepositoryProvider).removeMember(
            actingProfileId: myRole.profileId,
            spaceId: space.id,
            profileId: member.profileId,
          );
    } on UnauthorizedSpaceAction catch (error) {
      // Show the rule that actually fired (e.g. the last-Owner guard) instead
      // of guessing at one reason for every refusal (T062).
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final space = ref.read(activeSpaceProvider).value;
    final profileId = ref.read(activeProfileProvider).value?.id;
    if (space == null || profileId == null) return;

    // History is never silently destroyed: a space that owns months opens the
    // per-month resolution flow, which ends with the typed-name confirmation.
    // An empty space goes straight to the typed-name confirmation.
    final hasMonths =
        (ref.read(spaceMonthsProvider(space.id)).value ?? const []).isNotEmpty;
    if (hasMonths) {
      await DeleteSpaceSheet.show(context);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => TypedNameConfirmDialog(spaceName: space.name),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(spacesRepositoryProvider).deleteSpace(
            actingProfileId: profileId,
            spaceId: space.id,
          );
      ref.read(activeSpaceIdProvider.notifier).state = null;
    } on UnauthorizedSpaceAction {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This space has money in it. Move or delete its months first.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaceAsync = ref.watch(activeSpaceProvider);
    final space = spaceAsync.value;
    if (space == null) return const SizedBox.shrink();

    final myRole = ref.watch(activeSpaceMyRoleProvider);
    final isOwner = myRole?.role == SharedMemberRole.owner;
    final members =
        ref.watch(activeSpaceMembersProvider).value ?? const <SharedMember>[];
    final memberNames = ref.watch(memberDisplayNamesProvider);

    final membersCard = Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title:
                Text('Members', style: Theme.of(context).textTheme.titleMedium),
            trailing: Text('${members.length}'),
          ),
          for (final member in members)
            ListTile(
              key: Key('memberTile_${member.profileId}'),
              dense: true,
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(memberNames[member.profileId] ?? 'Profile'),
              subtitle: Text(_roleLabel(member.role)),
              trailing: isOwner && member.profileId != myRole?.profileId
                  ? PopupMenuButton<_MemberAction>(
                      tooltip: 'Manage member',
                      onSelected: (action) {
                        switch (action) {
                          case _MemberAction.remove:
                            _removeMember(context, ref, member);
                          case _MemberAction.makeOwner:
                            _transfer(context, ref);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<_MemberAction>(
                          key: Key('removeMember_${member.profileId}'),
                          value: _MemberAction.remove,
                          child: const Text('Remove'),
                        ),
                        PopupMenuItem<_MemberAction>(
                          key: Key('makeOwner_${member.profileId}'),
                          value: _MemberAction.makeOwner,
                          child: const Text('Make this member the Owner'),
                        ),
                      ],
                    )
                  : null,
            ),
          if (isOwner)
            ListTile(
              dense: true,
              leading: const Icon(Icons.person_add_alt_1_outlined),
              title: TextButton(
                key: const Key('inviteMemberButton'),
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const InviteSheet(),
                  );
                },
                child: const Text('Invite'),
              ),
            ),
        ],
      ),
    );

    final manageCard = isOwner
        ? Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text('Manage',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        key: const Key('editSpaceNameButton'),
                        onPressed: () => _rename(context, ref),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Rename'),
                      ),
                      FilledButton.tonalIcon(
                        key: const Key('editIncomeButton'),
                        onPressed: () => _editIncome(context, ref),
                        icon: const Icon(Icons.payments_outlined, size: 18),
                        label: const Text('Our income'),
                      ),
                      FilledButton.tonalIcon(
                        key: const Key('transferOwnershipButton'),
                        onPressed: () => _transfer(context, ref),
                        icon: const Icon(Icons.swap_horiz, size: 18),
                        label: const Text('Make someone else the Owner'),
                      ),
                      FilledButton.tonalIcon(
                        key: const Key('pairDeviceFromSpaceButton'),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  PairDeviceScreen(spaceId: space.id),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code_2, size: 18),
                        label: const Text('Pair a device'),
                      ),
                      OutlinedButton.icon(
                        key: const Key('deleteSpaceButton'),
                        onPressed: () => _delete(context, ref),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete space'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shared space', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Text(space.avatar, style: const TextStyle(fontSize: 28)),
            title: Text(space.displayName),
            subtitle: Text(
              '${space.currency.code.displayName} · Our income '
              '${space.currency.code.symbol}'
              '${NumberFormat('#,##0.00').format(space.defaultIncome / space.currency.code.minorUnitsPerMajor)}',
            ),
            trailing: SyncStatusChip(spaceId: space.id),
          ),
        ),
        const SizedBox(height: 8),
        membersCard,
        manageCard,
      ],
    );
  }
}
