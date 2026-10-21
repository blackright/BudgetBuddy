import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/shared_space.dart';
import '../../../core/providers/active_space_provider.dart';
import '../providers/spaces_providers.dart';
import 'space_switcher.dart' show showCreateSpaceFlow;

/// Settings card listing the shared spaces the active profile belongs to, with a
/// "New space" entry (US2).
class SpacesListSection extends ConsumerWidget {
  const SpacesListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces =
        ref.watch(mySpacesProvider).valueOrNull ?? const <SharedSpace>[];
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spaces', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (spaces.isEmpty)
              Text(
                'No shared spaces yet. Create one to share with someone on '
                'another device.',
                style: theme.textTheme.bodyMedium,
              )
            else
              for (final space in spaces)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      Text(space.avatar, style: const TextStyle(fontSize: 24)),
                  title: Text(space.displayName),
                  subtitle: Text(
                    space.id == ref.watch(activeSpaceProvider).valueOrNull?.id
                        ? 'Active'
                        : 'Tap to switch',
                  ),
                  onTap: () {
                    ref.read(activeSpaceIdProvider.notifier).state = space.id;
                  },
                ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => showCreateSpaceFlow(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New space'),
            ),
          ],
        ),
      ),
    );
  }
}
