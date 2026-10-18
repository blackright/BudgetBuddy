import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/sync/providers/sync_status_provider.dart';

/// A compact badge showing **one** shared space's sync state (FR-013).
///
/// It only reads [syncStatusProvider] for its own [spaceId]; the engine and the
/// store are what move the status. Conflicts are shown, never hidden:
/// "Up to date · 2 conflicts" tells the user the app resolved competing edits and
/// how many.
class SyncStatusChip extends ConsumerWidget {
  const SyncStatusChip({required this.spaceId, super.key});

  /// The local id of the shared space this badge speaks for (research R6).
  final int spaceId;

  /// "Up to date" green. A light and a dark tone, so the badge stays legible in
  /// both modes instead of hardcoding one (UX-001).
  static Color upToDateColor(Brightness brightness) =>
      brightness == Brightness.dark
          ? const Color(0xFF81C784) // green 300, soft on a dark surface
          : const Color(0xFF2E7D32); // green 800, readable on a light surface

  /// "In progress" amber. A true yellow is illegible as small text, so each mode
  /// gets a darker (light) or lighter (dark) gold.
  static Color inProgressColor(Brightness brightness) =>
      brightness == Brightness.dark
          ? const Color(0xFFFFD54F) // amber 300
          : const Color(0xFF9A6700); // dark gold, readable on a light surface

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncStatusProvider(spaceId));
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;

    final (IconData icon, String label, Color color) = switch (state.status) {
      SyncStatus.waitingForPeer => (
          Icons.cloud_off_outlined,
          'Waiting for peer',
          scheme.onSurfaceVariant,
        ),
      SyncStatus.syncing => (
          Icons.sync,
          'In progress',
          SyncStatusChip.inProgressColor(brightness),
        ),
      SyncStatus.converged => state.hasConflicts
          ? (
              Icons.report_problem_outlined,
              'Up to date · ${state.conflictCount} '
                  '${state.conflictCount == 1 ? 'conflict' : 'conflicts'}',
              scheme.error,
            )
          : (
              Icons.cloud_done_outlined,
              'Up to date',
              SyncStatusChip.upToDateColor(brightness),
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
          // Shrinkable so the badge can sit beside the month on a narrow phone
          // instead of overflowing the app bar.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
