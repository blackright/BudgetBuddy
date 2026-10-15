import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/sync/providers/sync_status_provider.dart';

/// A compact badge showing a shared space's sync state (FR-013).
///
/// It only reads [syncStatusProvider]; the engine is what changes the status.
/// Conflicts are shown, never hidden: "Synced · 2 conflicts" tells the user the
/// app resolved competing edits and how many.
class SyncStatusChip extends ConsumerWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncStatusProvider);
    final scheme = Theme.of(context).colorScheme;

    final (IconData icon, String label, Color color) = switch (state.status) {
      SyncStatus.waitingForPeer => (
          Icons.cloud_off_outlined,
          'Waiting for peer',
          scheme.onSurfaceVariant,
        ),
      SyncStatus.syncing => (
          Icons.sync,
          'Syncing…',
          scheme.primary,
        ),
      SyncStatus.converged => state.hasConflicts
          ? (
              Icons.report_problem_outlined,
              'Synced · ${state.conflictCount} '
                  '${state.conflictCount == 1 ? 'conflict' : 'conflicts'}',
              scheme.error,
            )
          : (
              Icons.cloud_done_outlined,
              'Synced',
              scheme.primary,
            ),
    };

    return Container(
      key: const Key('syncStatusChip'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style:
                Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
