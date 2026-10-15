import 'package:budget_buddy/features/sync/providers/sync_status_provider.dart';
import 'package:budget_buddy/shared/presentation/widgets/sync_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncStatusNotifier transitions (FR-013)', () {
    test('starts waiting for a peer', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(syncStatusProvider);
      expect(state.status, SyncStatus.waitingForPeer);
      expect(state.conflictCount, 0);
      expect(state.hasConflicts, isFalse);
    });

    test('syncing then converged updates status and conflict count', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(syncStatusProvider.notifier);

      notifier.syncing();
      expect(container.read(syncStatusProvider).status, SyncStatus.syncing);

      notifier.converged(conflicts: 2, at: DateTime.utc(2026, 3, 1));
      final state = container.read(syncStatusProvider);
      expect(state.status, SyncStatus.converged);
      expect(state.conflictCount, 2);
      expect(state.hasConflicts, isTrue);
      expect(state.lastSyncedAt, DateTime.utc(2026, 3, 1));
    });

    test('noteConflicts accumulates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(syncStatusProvider.notifier);
      notifier.noteConflicts(1);
      notifier.noteConflicts(2);
      expect(container.read(syncStatusProvider).conflictCount, 3);
    });
  });

  group('SyncStatusChip', () {
    testWidgets('shows waiting, syncing, synced and conflicts states',
        (tester) async {
      final notifier = SyncStatusNotifier();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [syncStatusProvider.overrideWith((ref) => notifier)],
          child: const MaterialApp(
            home: Scaffold(body: Center(child: SyncStatusChip())),
          ),
        ),
      );
      expect(find.text('Waiting for peer'), findsOneWidget);

      notifier.syncing();
      await tester.pump();
      expect(find.text('Syncing…'), findsOneWidget);

      notifier.converged();
      await tester.pump();
      expect(find.text('Synced'), findsOneWidget);

      notifier.converged(conflicts: 1);
      await tester.pump();
      expect(find.text('Synced · 1 conflict'), findsOneWidget);

      notifier.converged(conflicts: 3);
      await tester.pump();
      expect(find.text('Synced · 3 conflicts'), findsOneWidget);
    });
  });
}
