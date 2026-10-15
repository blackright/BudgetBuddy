import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/shared_member.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../settings/presentation/profile_switcher_section.dart';
import '../providers/spaces_providers.dart';
import '../repositories/spaces_repository.dart';

/// Whether the sheet's main action invites an existing local profile or first
/// creates a brand-new one on the device (spec: invites are local-only, FR-002).
enum _InviteMode { existing, newProfile }

/// US2: the Owner-only "Invite" bottom sheet.
///
/// Lists every local profile that is not yet a member so the Owner can invite
/// it with a role (Owner / Editor / Viewer), or creates a brand-new profile and
/// invites it in one step. The underlying `SpacesRepository.invite` enforces
/// the Owner-only rule at the data layer (contracts/space-roles §3).
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
  final _newName = TextEditingController();
  SharedMemberRole _role = SharedMemberRole.viewer;

  @override
  void dispose() {
    _newName.dispose();
    super.dispose();
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
              else
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
