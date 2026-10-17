import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/identity_provider.dart';
import '../providers/pairing_providers.dart';
import 'scan_identity_code_screen.dart';
import 'show_identity_code_screen.dart';

/// US7 (T062): the global **People** list.
///
/// This is the single place to see everyone this device knows and to become
/// contacts with someone new — reachable from Settings with **no active space**,
/// so pairing is no longer trapped inside a space (T063).
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
