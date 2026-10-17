import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pairing_providers.dart';
import 'people_screen.dart';

/// US7 (T063): the Settings entry to the global People list.
///
/// Needs an identity but **no active space**, so pairing and contact management
/// are reachable from anywhere — the in-space invite stays available too.
class PeopleSection extends ConsumerWidget {
  const PeopleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(pairingServiceProvider) == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: ListTile(
        key: const Key('peopleButton'),
        leading: const Icon(Icons.people),
        title: const Text('People'),
        subtitle: const Text('Everyone you can add to a space'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(builder: (_) => const PeopleScreen()),
        ),
      ),
    );
  }
}
