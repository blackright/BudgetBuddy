import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/shared_space.dart';
import '../../../core/providers/active_space_provider.dart';
import '../providers/spaces_providers.dart';
import 'space_switcher.dart' show showCreateSpaceFlow;

/// The Spaces tab: square cards for each shared space, plus a "New space" card.
class SpacesScreen extends ConsumerWidget {
  const SpacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces =
        ref.watch(mySpacesProvider).valueOrNull ?? const <SharedSpace>[];
    final activeSpaceId = ref.watch(activeSpaceProvider).valueOrNull?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Spaces')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: spaces.length + 1, // +1 for the "New space" card
        itemBuilder: (context, index) {
          if (index == spaces.length) {
            // "New space" card
            return _NewSpaceCard(
                onTap: () => showCreateSpaceFlow(context, ref));
          }
          final space = spaces[index];
          final isActive = space.id == activeSpaceId;
          return _SpaceCard(
            space: space,
            isActive: isActive,
            onTap: () {
              ref.read(activeSpaceIdProvider.notifier).state = space.id;
            },
          );
        },
      ),
    );
  }
}

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({
    required this.space,
    required this.isActive,
    required this.onTap,
  });

  final SharedSpace space;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: isActive ? 4 : 1,
      color: isActive
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(space.avatar, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: 8),
              Text(
                space.displayName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isActive) ...[
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Active',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NewSpaceCard extends StatelessWidget {
  const _NewSpaceCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline,
                size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              'New space',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
