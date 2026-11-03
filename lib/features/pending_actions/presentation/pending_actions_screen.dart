import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/currency_code.dart';
import '../../../core/models/pending_action.dart';
import '../../../shared/presentation/money_format.dart';
import '../providers/pending_actions_providers.dart';
import '../services/pending_action_service.dart';

/// One place for every source that needs the user (022 US4).
class PendingActionsScreen extends ConsumerStatefulWidget {
  const PendingActionsScreen({super.key});

  @override
  ConsumerState<PendingActionsScreen> createState() =>
      _PendingActionsScreenState();
}

class _PendingActionsScreenState extends ConsumerState<PendingActionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(pendingActionsSynthesisProvider.future)
        .catchError((Object _) {}));
  }

  Future<void> _open(PendingAction action) async {
    final service = ref.read(pendingActionServiceProvider);
    // Reading is not doing the task, so navigation must not wait on the write.
    unawaited(service.markRead(action.guid));
    final link = PendingActionService.destinationFor(action);
    if (link == null || link.isEmpty) {
      _message(
          'This action has no destination. Dismiss it or resolve it in its feature.');
      return;
    }
    try {
      if (!mounted) return;
      context.push(link);
    } catch (_) {
      await service.cancel(action.guid, 'deletedTarget');
      _message('That record no longer exists. The action has been cancelled.');
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> _close(PendingAction action, {required bool dismiss}) async {
    final reason = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(dismiss ? 'Dismiss action' : 'Cancel action'),
        content: TextField(
          controller: reason,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialog).pop(false),
              child: const Text('Keep')),
          TextButton(
              onPressed: () => Navigator.of(dialog).pop(true),
              child: Text(dismiss ? 'Dismiss' : 'Cancel action')),
        ],
      ),
    );
    if (accepted == true && reason.text.trim().isNotEmpty) {
      final service = ref.read(pendingActionServiceProvider);
      if (dismiss) {
        await service.dismiss(action.guid, reason.text);
      } else {
        await service.cancel(action.guid, reason.text);
      }
    }
    reason.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final synthesis = ref.watch(pendingActionsSynthesisProvider);
    final actions = ref.watch(pendingActionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending actions'),
        actions: [
          IconButton(
            key: const Key('pendingActionsRefresh'),
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(pendingActionsSynthesisProvider);
              ref.invalidate(pendingActionsProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: synthesis.isLoading && !actions.hasValue
          ? const Center(child: CircularProgressIndicator())
          : actions.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Pending actions could not be loaded.'),
                  TextButton(
                      onPressed: () =>
                          ref.invalidate(pendingActionsSynthesisProvider),
                      child: const Text('Retry')),
                ]),
              ),
              data: (rows) {
                final needs = rows
                    .where(
                        (row) => row.status == 'due' || row.status == 'overdue')
                    .toList();
                final upcoming =
                    rows.where((row) => row.status == 'pending').toList();
                final history = rows.where((row) => row.isTerminal).toList();
                if (needs.isEmpty && upcoming.isEmpty && history.isEmpty) {
                  return const Center(
                      child: Text('Nothing needs you right now.'));
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  children: [
                    if (needs.isNotEmpty) ...[
                      _Group(title: 'Needs you now', count: needs.length),
                      for (final row in needs) _row(row),
                    ],
                    if (upcoming.isNotEmpty) ...[
                      _Group(title: 'Upcoming', count: upcoming.length),
                      for (final row in upcoming) _row(row),
                    ],
                    if (history.isNotEmpty) ...[
                      _Group(title: 'History', count: history.length),
                      for (final row in history) _row(row),
                    ],
                  ],
                );
              },
            ),
    );
  }

  Widget _row(PendingAction action) {
    final theme = Theme.of(context);
    final terminal = action.isTerminal;
    final currency = CurrencyCode.tryParse(action.currency);
    final amount = action.expectedAmountMinor != null && currency != null
        ? formatMinorUnits(action.expectedAmountMinor!, currency)
        : null;
    final timing = action.expectedAt != null
        ? _date(action.expectedAt!)
        : action.expectedMonth ?? '';
    final subtitle = [
      action.nextAction,
      if (amount != null) amount,
      if (timing.isNotEmpty) timing,
      if (action.status == 'overdue') 'Overdue',
    ].join(' · ');
    return Card(
      child: ListTile(
        key: ValueKey('pendingAction-${action.guid}'),
        isThreeLine: subtitle.length > 40,
        title: Text(action.title,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (!terminal)
            TextButton(
              onPressed: () => _open(action),
              child: const Text('Open'),
            ),
          if (!terminal)
            PopupMenuButton<String>(
              tooltip: 'More actions',
              onSelected: (value) =>
                  _close(action, dismiss: value == 'dismiss'),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'dismiss', child: Text('Dismiss')),
                PopupMenuItem(value: 'cancel', child: Text('Cancel action')),
              ],
            ),
        ]),
        onTap: terminal ? null : () => _open(action),
      ),
    );
  }

  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.count});
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
        child: Text('$title ($count)',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
      );
}
