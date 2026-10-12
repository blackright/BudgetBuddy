import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/shared_space.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../providers/spaces_providers.dart';
import '../repositories/month_move_operations.dart';
import '../repositories/space_role_guard.dart';
import '../repositories/spaces_repository.dart';

/// US2/FR-014: the Owner's per-month resolution flow for deleting a space.
///
/// History is never silently destroyed. Every month the space owns must be
/// decided — moved back to a personal profile (whoever's slot it fits), or
/// deleted — before the final typed-name confirmation removes the space itself.
/// Each decision commits on its own, so an interrupted flow is resumable: the
/// space stays deletable and the remaining months reappear next time.
class DeleteSpaceSheet extends ConsumerStatefulWidget {
  const DeleteSpaceSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const DeleteSpaceSheet(),
      );

  @override
  ConsumerState<DeleteSpaceSheet> createState() => _DeleteSpaceSheetState();
}

class _DeleteSpaceSheetState extends ConsumerState<DeleteSpaceSheet> {
  bool _busy = false;

  Future<void> _resolve(
    Future<void> Function(int actingProfileId) action,
  ) async {
    final actingProfileId = ref.read(activeProfileProvider).value?.id;
    if (actingProfileId == null) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await action(actingProfileId);
    } on UnauthorizedSpaceAction catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      messenger
          .showSnackBar(SnackBar(content: Text('Could not resolve: $error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _moveMonth(String yearMonth, int targetProfileId) {
    final spaceId = ref.read(activeSpaceIdProvider);
    return _resolve((actingProfileId) {
      if (spaceId == null) return Future.value();
      return ref.read(monthMoveOperationsProvider).moveMonth(
            ContextRef.shared(spaceId: spaceId, yearMonth: yearMonth),
            ContextRef.personal(
                profileId: targetProfileId, yearMonth: yearMonth),
            yearMonth,
            actingProfileId: actingProfileId,
          );
    });
  }

  Future<void> _deleteMonth(String yearMonth) {
    final spaceId = ref.read(activeSpaceIdProvider);
    return _resolve((actingProfileId) {
      if (spaceId == null) return Future.value();
      return ref.read(monthMoveOperationsProvider).deleteMonth(
            ContextRef.shared(spaceId: spaceId, yearMonth: yearMonth),
            yearMonth,
            actingProfileId: actingProfileId,
          );
    });
  }

  Future<void> _pickDestination(SharedSpace space, String yearMonth) async {
    final profiles = ref.read(profilesProvider).value ?? const <UserProfile>[];
    final choice = await showModalBottomSheet<_Disposition>(
      context: context,
      builder: (_) => _DestinationSheet(profiles: profiles),
    );
    if (choice == null) return;
    if (choice.profileId == null) {
      await _deleteMonth(yearMonth);
    } else {
      await _moveMonth(yearMonth, choice.profileId!);
    }
  }

  Future<void> _finish(SharedSpace space) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => TypedNameConfirmDialog(spaceName: space.name),
    );
    if (confirmed != true) return;
    final actingProfileId = ref.read(activeProfileProvider).value?.id;
    if (actingProfileId == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(spacesRepositoryProvider).deleteSpace(
            actingProfileId: actingProfileId,
            spaceId: space.id,
          );
      ref.read(activeSpaceIdProvider.notifier).state = null;
      if (mounted) Navigator.of(context).pop();
    } on UnauthorizedSpaceAction catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final space = ref.watch(activeSpaceProvider).value;
    if (space == null) return const SizedBox.shrink();
    final months = ref.watch(spaceMonthsProvider(space.id)).value ?? const [];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete ${space.name}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text(
              'Decide what happens to each month before the space is removed. '
              'Move a month back to a personal profile, or delete it.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (_busy)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (months.isEmpty)
              const Padding(
                key: Key('deleteSpaceEmptyNote'),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('This space owns no months.'),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final month in months)
                      ListTile(
                        key: Key('resolveMonth_${month.yearMonth}'),
                        dense: true,
                        leading: const Icon(Icons.calendar_month_outlined),
                        title: Text(month.yearMonth),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _pickDestination(space, month.yearMonth),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('continueDeleteSpaceButton'),
                onPressed: months.isEmpty ? () => _finish(space) : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The per-month disposition: a target profile id, or `null` to delete.
class _Disposition {
  const _Disposition(this.profileId);

  final int? profileId;
}

class _DestinationSheet extends StatelessWidget {
  const _DestinationSheet({required this.profiles});

  final List<UserProfile> profiles;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Move this month to…'),
            dense: true,
          ),
          for (final profile in profiles)
            ListTile(
              key: Key('moveMonthToProfile_${profile.id}'),
              leading: CircleAvatar(
                child: Text(profile.avatar.isEmpty ? '👤' : profile.avatar),
              ),
              title: Text(profile.name),
              onTap: () => Navigator.of(context).pop(_Disposition(profile.id)),
            ),
          const Divider(height: 1),
          ListTile(
            key: const Key('deleteThisMonthOption'),
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete this month'),
            onTap: () => Navigator.of(context).pop(const _Disposition(null)),
          ),
        ],
      ),
    );
  }
}

/// GitHub-style typed-name confirmation: confirm is enabled only when the input
/// exactly equals the target name (FR-014/FR-019, anti-accident).
///
/// Shared by space deletion and profile deletion. The optional [title],
/// [message], [fieldKey], [buttonKey] and [confirmLabel] let each context label
/// itself without duplicating the gate; the defaults preserve the space wording.
class TypedNameConfirmDialog extends StatefulWidget {
  const TypedNameConfirmDialog({
    super.key,
    required this.spaceName,
    this.title = 'Delete this space?',
    this.message,
    this.fieldKey = const Key('deleteSpaceNameField'),
    this.buttonKey = const Key('confirmDeleteSpaceButton'),
    this.confirmLabel = 'Delete',
  });

  final String spaceName;
  final String title;

  /// Extra warning text shown above the field, e.g. what will be deleted.
  final String? message;
  final Key fieldKey;
  final Key buttonKey;
  final String confirmLabel;

  @override
  State<TypedNameConfirmDialog> createState() => _TypedNameConfirmDialogState();
}

class _TypedNameConfirmDialogState extends State<TypedNameConfirmDialog> {
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = _confirm.text.trim() == widget.spaceName;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message != null) ...[
            Text(widget.message!),
            const SizedBox(height: 12),
          ],
          Text('Type "${widget.spaceName}" to confirm.'),
          const SizedBox(height: 12),
          TextField(
            key: widget.fieldKey,
            controller: _confirm,
            autofocus: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: widget.buttonKey,
          onPressed: matches ? () => Navigator.of(context).pop(true) : null,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
