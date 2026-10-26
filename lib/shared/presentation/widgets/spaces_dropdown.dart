import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/services/context_navigation.dart';
import '../../../features/spaces/presentation/space_switcher.dart';
import '../providers/context_navigation_provider.dart';
import '../financial_feedback.dart';
import 'profile_avatar.dart';

class SpacesDropdown extends ConsumerWidget {
  const SpacesDropdown({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(activeProfileProvider).valueOrNull;
    final spaceId = ref.watch(activeSpaceIdProvider);
    final space = ref.watch(activeSpaceProvider).valueOrNull;
    final label = spaceId == null
        ? 'Personal · ${profile?.name ?? 'Loading…'}'
        : 'Shared · ${space?.displayName ?? 'Loading…'}';
    final dismissed = ref.watch(dismissedProfileNamePromptsProvider);
    final prompt = profile != null &&
        (profile.name.trim().isEmpty ||
            profile.name.trim().toLowerCase() == 'user') &&
        !dismissed.contains(profile.id);
    return Material(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(children: [
                PopupMenuButton<String>(
                    key: const Key('spacesNavigationMenu'),
                    tooltip: 'Open Profile, Spaces, Reports and Settings',
                    onSelected: (value) {
                      switch (value) {
                        case 'spaces':
                          showContextChooser(context, ref);
                        case 'profile':
                          context.push('/profile');
                        case 'reports':
                          context.push('/reports');
                        case 'settings':
                          context.push('/settings');
                      }
                    },
                    itemBuilder: (_) => [
                          for (final item in [
                            ('profile', Icons.person_outline, 'Profile'),
                            ('spaces', Icons.swap_horiz, 'Spaces'),
                            ('reports', Icons.summarize_outlined, 'Reports'),
                            ('settings', Icons.settings_outlined, 'Settings')
                          ])
                            PopupMenuItem(
                                value: item.$1,
                                child: Row(children: [
                                  Icon(item.$2),
                                  const SizedBox(width: 12),
                                  Text(item.$3)
                                ]))
                        ],
                    child: Semantics(
                        button: true,
                        label: 'Open navigation menu',
                        child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              ProfileAvatar(name: profile?.name ?? ''),
                              const SizedBox(width: 8),
                              const Text('Spaces',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w700)),
                              const Icon(Icons.expand_more)
                            ])))),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(label,
                        key: const Key('navigationContextLabel'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge)),
              ])),
          if (prompt)
            Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(children: [
                  Expanded(
                      child: TextButton.icon(
                          onPressed: () => context.push('/profile'),
                          icon: const Icon(Icons.person_outline, size: 18),
                          label: const Text('Personalise your profile'))),
                  IconButton(
                      tooltip: 'Dismiss name suggestion for this session',
                      onPressed: () => ref
                          .read(dismissedProfileNamePromptsProvider.notifier)
                          .state = {...dismissed, profile.id},
                      icon: const Icon(Icons.close, size: 18))
                ]))
        ]));
  }
}

Future<void> showContextChooser(BuildContext context, WidgetRef ref) async {
  ref.invalidate(contextDestinationsProvider);
  final result = await showModalBottomSheet<ContextDestination>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const _ContextChooser());
  if (result == null || !context.mounted) return;
  final same = ref.read(activeSpaceIdProvider) == result.spaceId;
  if (same) return;
  try {
    await ref.read(selectNavigationContextProvider)(result.spaceId);
    if (!context.mounted) return;
    // go replaces root detail routes; shell owner keys discard branch state.
    context.go('/dashboard');
    showFinancialFeedback(context,
        'Switched to ${result.spaceId == null ? 'Personal' : result.name}.');
  } catch (_) {
    if (context.mounted) {
      showFinancialFeedback(context,
          'Could not switch. Your profile or space access may have changed. Reopen Spaces.',
          kind: FinancialFeedbackKind.error);
    }
  }
}

class _ContextChooser extends ConsumerStatefulWidget {
  const _ContextChooser();
  @override
  ConsumerState<_ContextChooser> createState() => _ContextChooserState();
}

class _ContextChooserState extends ConsumerState<_ContextChooser> {
  String search = '';
  bool creating = false;
  @override
  Widget build(BuildContext context) {
    final choices = ref.watch(contextDestinationsProvider),
        active = ref.watch(activeSpaceIdProvider);
    return SizedBox(
        height: MediaQuery.sizeOf(context).height * .78,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your spaces',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text('Choose whose money you want to view.'),
                    const SizedBox(height: 16),
                    TextField(
                        key: const Key('contextSearchField'),
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            labelText: 'Search spaces',
                            border: OutlineInputBorder()),
                        onChanged: (v) =>
                            setState(() => search = v.trim().toLowerCase()))
                  ])),
          Expanded(
              child: choices.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                      child: TextButton(
                          onPressed: () =>
                              ref.invalidate(contextDestinationsProvider),
                          child: const Text('Could not load spaces. Retry'))),
                  data: (items) {
                    final visible = items
                        .where((i) =>
                            '${i.spaceId == null ? 'Personal ' : ''}${i.name}'
                                .toLowerCase()
                                .contains(search))
                        .toList();
                    return visible.isEmpty
                        ? const Center(child: Text('No matching spaces.'))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: visible.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = visible[index],
                                  selected = item.spaceId == active;
                              return ListTile(
                                  key: Key(
                                      'contextChoice_${item.spaceId ?? 'personal'}'),
                                  selected: selected,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  leading: Icon(item.spaceId == null
                                      ? Icons.person_outline
                                      : Icons.people_outline),
                                  title: Text(item.spaceId == null
                                      ? 'Personal · ${item.name}'
                                      : item.name),
                                  subtitle: Text(item.spaceId == null
                                      ? 'Your personal money'
                                      : 'Shared space · full shared amounts'),
                                  trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (item.locked)
                                          const Icon(Icons.lock_outline,
                                              size: 20),
                                        if (selected)
                                          const Padding(
                                              padding: EdgeInsets.only(left: 8),
                                              child: Icon(Icons.check_circle))
                                      ]),
                                  onTap: creating
                                      ? null
                                      : () => Navigator.pop(context, item));
                            });
                  })),
          const Divider(height: 1),
          Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                TextButton.icon(
                    onPressed: creating
                        ? null
                        : () {
                            Navigator.pop(context);
                            context.go('/spaces');
                          },
                    icon: const Icon(Icons.tune),
                    label: const Text('Manage spaces')),
                FilledButton.tonalIcon(
                    onPressed: creating
                        ? null
                        : () async {
                            setState(() => creating = true);
                            try {
                              final space =
                                  await showCreateSpaceFlow(context, ref);
                              if (!context.mounted) return;
                              if (space != null) {
                                Navigator.pop(context);
                                context.go('/dashboard');
                                showFinancialFeedback(
                                    context, 'Created ${space.displayName}.');
                              }
                            } catch (_) {
                              if (context.mounted) {
                                showFinancialFeedback(context,
                                    'Could not create the space. Please try again.',
                                    kind: FinancialFeedbackKind.error);
                              }
                            } finally {
                              if (mounted) setState(() => creating = false);
                            }
                          },
                    icon: const Icon(Icons.add),
                    label: Text(creating ? 'Creating…' : 'New space'))
              ]))
        ]));
  }
}
