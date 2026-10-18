import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/shared_member.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../pairing/domain/pairing_protocol.dart';
import '../../pairing/providers/pairing_providers.dart';
import '../../settings/presentation/profile_switcher_section.dart';
import '../providers/spaces_providers.dart';
import '../repositories/spaces_repository.dart';
import 'scan_contact_into_space_screen.dart';

/// Whether the sheet's main action invites an existing local profile, first
/// creates a brand-new one on the device (spec: invites are local-only, FR-002),
/// or adds an already-paired **person** from the global People list (US7, T064).
enum _InviteMode { existing, newProfile, contact }

/// US2 + US7 (T064): the Owner-only "Invite" bottom sheet.
///
/// Lists every local profile that is not yet a member so the Owner can invite
/// it with a role (Owner / Editor / Viewer), creates a brand-new profile and
/// invites it in one step, or — in the **Add a person** mode — picks someone
/// from the global People list (or scans their identity code) and grants them
/// membership. The underlying `SpacesRepository.invite` enforces the Owner-only
/// rule at the data layer (contracts/space-roles §3).
///
/// Stateful on purpose: it owns its controllers (same discipline as the profile
/// dialog and create-space sheet).
class InviteSheet extends ConsumerStatefulWidget {
  const InviteSheet({super.key});

  @override
  ConsumerState<InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<InviteSheet> {
  _InviteMode _mode = _InviteMode.existing;
  int? _selectedProfileId;
  String? _selectedPeerIdentityId;
  final _newName = TextEditingController();
  SharedMemberRole _role = SharedMemberRole.viewer;

  @override
  void dispose() {
    _newName.dispose();
    super.dispose();
  }

  void _warn(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _invite() async {
    final spaceId = ref.read(activeSpaceIdProvider);
    if (spaceId == null) return;
    final repo = ref.read(spacesRepositoryProvider);

    late int targetId;
    if (_mode == _InviteMode.newProfile) {
      final name = _newName.text.trim();
      if (name.isEmpty) return;
      final controller = ref.read(profileSwitcherControllerProvider);
      targetId = await controller.createProfile(name);
    } else {
      final selected = _selectedProfileId;
      if (selected == null) return;
      targetId = selected;
    }

    await repo.invite(
      actingProfileId: ref.read(activeProfileProvider).value?.id ?? 0,
      spaceId: spaceId,
      profileId: targetId,
      role: _role,
    );
    if (mounted) Navigator.of(context).pop();
  }

  /// Adds a paired person (US7, T064): the membership is signed by this
  /// device's identity, so the phone must unlock first.
  ///
  /// A declined prompt leaves the unlock session retryable (T073), so the very
  /// next tap asks again instead of reporting a permanently locked identity.
  Future<void> _addContact() async {
    final spaceId = ref.read(activeSpaceIdProvider);
    final peerIdentityId = _selectedPeerIdentityId;
    if (spaceId == null || peerIdentityId == null) return;

    final service = await ref.read(signingPairingServiceProvider)(
      reason: 'Confirm it is you',
    );
    if (service == null) {
      _warn('Your identity stayed locked, so nothing was shared.');
      return;
    }
    try {
      await service.addContactToSpace(
        spaceId: spaceId,
        peerIdentityId: peerIdentityId,
        role: _role,
      );
      if (!mounted) return;
      var name = 'them';
      for (final item
          in ref.read(contactsProvider).value ?? const <Contact>[]) {
        if (item.peer.peerIdentityId == peerIdentityId &&
            item.peer.peerUsername.isNotEmpty) {
          name = item.peer.peerUsername;
          break;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $name to this space.')),
      );
      Navigator.of(context).pop();
    } on PairingException catch (error) {
      _warn(error.message);
    }
  }

  /// The scan shortcut: adds the contact **and** the membership in one step.
  Future<void> _scanContact() async {
    final spaceId = ref.read(activeSpaceIdProvider);
    if (spaceId == null) return;
    final spaceName =
        ref.read(activeSpaceProvider).valueOrNull?.name ?? 'this space';
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => ScanContactIntoSpaceScreen(
          spaceId: spaceId,
          spaceName: spaceName,
          role: _role,
        ),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  /// The "Add a person" body (US7, T064): paired contacts who are not members
  /// yet, plus the scan shortcut. The scan button stays visible even when there
  /// is nobody to pick, so the mode is never a dead end (T065).
  Widget _contactModeBody(BuildContext context) {
    final theme = Theme.of(context);
    final memberIds = {
      for (final member in ref.watch(activeSpaceMembersProvider).value ??
          const <SharedMember>[])
        member.profileId,
    };
    final contacts = ref.watch(contactsProvider).value ?? const <Contact>[];
    final pending = [
      for (final contact in contacts)
        if (!memberIds
            .contains(remoteProfileIdFor(contact.peer.peerIdentityId)))
          contact,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Already paired? Give them a role, or scan their code to add them '
          'in one step.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        if (contacts.isEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('No people paired yet.'),
              const SizedBox(height: 4),
              Text(
                'Open Settings → People and share your code in person. You can '
                'come back here afterwards.',
                style:
                    theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              ),
            ],
          )
        else if (pending.isEmpty)
          const Text('Everyone you have paired is already in this space.')
        else ...[
          RadioGroup<String>(
            groupValue: _selectedPeerIdentityId,
            onChanged: (value) =>
                setState(() => _selectedPeerIdentityId = value),
            child: Column(
              children: [
                for (final contact in pending)
                  ListTile(
                    key: Key('addContact_${contact.peer.peerIdentityId}'),
                    dense: true,
                    leading: CircleAvatar(
                      child: Text(contact.peer.peerUsername.isEmpty
                          ? '?'
                          : contact.peer.peerUsername
                              .substring(0, 1)
                              .toUpperCase()),
                    ),
                    title: Text(
                        '${contact.peer.peerUsername} (${contact.peer.peerFingerprint})'),
                    subtitle: contact.sharedSpaceNames.isEmpty
                        ? null
                        : Text(
                            'Shared: ${contact.sharedSpaceNames.join(', ')}'),
                    trailing: Radio<String>(
                      value: contact.peer.peerIdentityId,
                    ),
                    onTap: () => setState(() =>
                        _selectedPeerIdentityId = contact.peer.peerIdentityId),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const Key('confirmAddPersonButton'),
              onPressed: _selectedPeerIdentityId == null ? null : _addContact,
              child: const Text('Add person'),
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('scanPersonButton'),
            onPressed: _scanContact,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan their code'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(activeSpaceMembersProvider);
    final profilesAsync = ref.watch(profilesProvider);
    final allProfiles = profilesAsync.value ?? const <UserProfile>[];
    final memberIds = {
      for (final member in membersAsync.value ?? const <SharedMember>[])
        member.profileId,
    };
    final inviteable = [
      for (final profile in allProfiles)
        if (!memberIds.contains(profile.id)) profile,
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invite to this space',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Only the Owner can invite (FR-002).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              SegmentedButton<_InviteMode>(
                segments: const [
                  ButtonSegment(
                    value: _InviteMode.existing,
                    label: Text('Invite a profile'),
                  ),
                  ButtonSegment(
                    value: _InviteMode.newProfile,
                    label: Text('Create new'),
                  ),
                  ButtonSegment(
                    value: _InviteMode.contact,
                    label: Text('Add a person'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) =>
                    setState(() => _mode = selection.first),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SharedMemberRole>(
                key: const Key('inviteRoleDropdown'),
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: SharedMemberRole.viewer,
                    child: Text('Viewer (read only)'),
                  ),
                  DropdownMenuItem(
                    value: SharedMemberRole.editor,
                    child: Text('Editor (view + edit money)'),
                  ),
                  DropdownMenuItem(
                    value: SharedMemberRole.owner,
                    child: Text('Owner (manage people + space)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _role = value);
                },
              ),
              const SizedBox(height: 16),
              if (_mode == _InviteMode.existing)
                _mode == _InviteMode.existing && inviteable.isEmpty
                    ? const Text('Every profile is already a member.')
                    : Column(
                        children: [
                          RadioGroup<int>(
                            groupValue: _selectedProfileId,
                            onChanged: (value) =>
                                setState(() => _selectedProfileId = value),
                            child: Column(
                              children: [
                                for (final profile in inviteable)
                                  ListTile(
                                    key: Key('inviteProfile_${profile.id}'),
                                    dense: true,
                                    leading: CircleAvatar(
                                      child: Text(
                                        profile.avatar.isEmpty
                                            ? '👤'
                                            : profile.avatar,
                                      ),
                                    ),
                                    title: Text(profile.name),
                                    trailing: Radio<int>(
                                      value: profile.id,
                                    ),
                                    onTap: () => setState(
                                        () => _selectedProfileId = profile.id),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              key: const Key('confirmInviteButton'),
                              onPressed: _selectedProfileId == null
                                  ? null
                                  : () => _invite(),
                              child: const Text('Invite'),
                            ),
                          ),
                        ],
                      )
              else if (_mode == _InviteMode.newProfile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      key: const Key('newMemberNameField'),
                      controller: _newName,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'New profile name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Creates a personal profile on this device, then invites '
                      'it with the role above.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const Key('createAndInviteButton'),
                        onPressed: _invite,
                        child: const Text('Create & invite'),
                      ),
                    ),
                  ],
                )
              else
                _contactModeBody(context),
            ],
          ),
        ),
      ),
    );
  }
}
