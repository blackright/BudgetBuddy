import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/identity_provider.dart';
import '../../spaces/repositories/space_role_guard.dart';
import '../../spaces/repositories/spaces_repository.dart';
import '../domain/pairing_protocol.dart';
import '../providers/pairing_providers.dart';
import 'scan_identity_code_screen.dart';
import 'show_identity_code_screen.dart';

/// The single action on a contact row.
enum _ContactAction { remove }

/// US7 (T062): the global **People** list.
///
/// This is the single place to see everyone this device knows and to become
/// contacts with someone new — reachable from Settings with **no active space**,
/// so pairing is no longer trapped inside a space (T063).
///
/// It is also where a person is **removed** (T077). Removal is guarded by a
/// confirmation dialog on purpose: forgetting someone stops sync with them, and
/// a single careless tap should never do that.
class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  Future<void> _showCode(BuildContext context) =>
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(builder: (_) => const ShowIdentityCodeScreen()),
      );

  Future<void> _scanCode(BuildContext context) =>
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(builder: (_) => const ScanIdentityCodeScreen()),
      );

  /// Removes [contact] from this phone, behind a confirmation dialog.
  ///
  /// Two things happen, in this order: their membership is revoked in every
  /// shared space where the acting profile is the Owner (so the other phone
  /// learns about it through the change log), then the peer row itself is
  /// forgotten so the person leaves the list and stops syncing (T077). Spaces
  /// the acting profile does not own are left alone and named in the SnackBar,
  /// so the outcome is never silently over- or under-stated.
  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    Contact contact,
    int? actingProfileId,
  ) async {
    final peer = contact.peer;
    final names = contact.sharedSpaceNames;
    final name = peer.peerUsername.isEmpty ? 'this person' : peer.peerUsername;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove this person?'),
        content: Text(
          'You will stop exchanging changes with '
          '${peer.peerUsername} (${peer.peerFingerprint}), and they leave your '
          'People list. The data you already have stays on this phone.'
          '${names.isEmpty ? '' : '\n\nWhere you are the Owner, they are also removed from: ${names.join(', ')}.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirmRemovePersonButton'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final refused = <String>[];
    final repo = ref.read(spacesRepositoryProvider);
    final memberKey = remoteProfileIdFor(peer.peerIdentityId);
    for (var i = 0; i < contact.sharedSpaceIds.length; i++) {
      final spaceName = i < names.length ? names[i] : 'a shared space';
      if (actingProfileId == null) {
        // No acting profile means no authority anywhere: forget them here, but
        // never pretend the memberships were revoked.
        refused.add(spaceName);
        continue;
      }
      try {
        await repo.removeMember(
          actingProfileId: actingProfileId,
          spaceId: contact.sharedSpaceIds[i],
          profileId: memberKey,
        );
      } on UnauthorizedSpaceAction {
        // Not the Owner (or the space's last Owner): forget them here, but
        // leave the membership where we have no authority to change it.
        refused.add(spaceName);
      } on ArgumentError {
        // Already not a member (e.g. removed from their own phone): done.
      }
    }

    await ref
        .read(pairingServiceProvider)
        ?.forgetPeer(peerIdentityId: peer.peerIdentityId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          refused.isEmpty
              ? 'Removed $name.'
              : 'Removed $name here. You are not the Owner of '
                  '${refused.join(', ')}, so they are still a member there.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = ref.watch(identityProvider).valueOrNull;
    if (identity == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('People')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Create your identity first — then you can meet people here.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final format = DateFormat.yMMMd().add_jm();
    final contacts = ref.watch(contactsProvider).value ?? const <Contact>[];
    // Watched (not read lazily) so the acting profile is already resolved by the
    // time the menu opens: a lazily-read stream provider would still be loading
    // and the revocations would silently be skipped as "not the Owner".
    final actingProfileId = ref.watch(actingProfileIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('People')),
      body: Column(
        children: [
          Expanded(
            child: contacts.isEmpty
                ? const _EmptyPeopleState()
                : ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      final peer = contact.peer;
                      final spaces = contact.sharedSpaceNames;
                      return ListTile(
                        key: Key('peopleContact_${peer.peerIdentityId}'),
                        leading: CircleAvatar(
                          child: Text(peer.peerUsername.isEmpty
                              ? '?'
                              : peer.peerUsername
                                  .substring(0, 1)
                                  .toUpperCase()),
                        ),
                        title: Text(
                            '${peer.peerUsername} (${peer.peerFingerprint})'),
                        subtitle: Text(
                          [
                            if (spaces.isNotEmpty)
                              'Shared: ${spaces.join(', ')}',
                            'Paired ${format.format(peer.pairedAt.toLocal())}'
                                '${peer.lastSeenAt == null ? '' : ' · Last seen ${format.format(peer.lastSeenAt!.toLocal())}'}',
                          ].join('\n'),
                        ),
                        trailing: PopupMenuButton<_ContactAction>(
                          key: Key('peopleContactMenu_${peer.peerIdentityId}'),
                          tooltip: 'Manage person',
                          onSelected: (action) {
                            if (action == _ContactAction.remove) {
                              _remove(context, ref, contact, actingProfileId);
                            }
                          },
                          itemBuilder: (menuContext) => [
                            PopupMenuItem<_ContactAction>(
                              key: Key('removePerson_${peer.peerIdentityId}'),
                              value: _ContactAction.remove,
                              child: const Text('Remove person'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('showMyCodeButton'),
                      onPressed: () => _showCode(context),
                      icon: const Icon(Icons.qr_code_2),
                      label: const Text('Show my code'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      key: const Key('scanCodeButton'),
                      onPressed: () => _scanCode(context),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan a code'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Friendly empty state with the security copy (US7, T065 groundwork).
class _EmptyPeopleState extends StatelessWidget {
  const _EmptyPeopleState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 56, color: theme.hintColor),
            const SizedBox(height: 16),
            Text('No people yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Share your code in person to add someone. You can then invite '
              'them into a shared space.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Codes expire quickly and only work when both of you are '
              'together.',
              style:
                  theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
