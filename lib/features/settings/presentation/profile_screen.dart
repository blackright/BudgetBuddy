import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/services/profile_name.dart';
import '../../../shared/presentation/widgets/profile_avatar.dart';
import '../../../shared/presentation/financial_feedback.dart';
import '../../../shared/presentation/providers/context_navigation_provider.dart';
import '../../security/providers/lock_providers.dart';
import '../../identity/presentation/identity_section.dart';
import 'profile_switcher_section.dart';
import '../repositories/profile_name_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(activeProfileProvider);
    return Scaffold(
        appBar: AppBar(
            title: const Text('Profile'),
            leading: BackButton(onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            })),
        body: profile.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const Center(child: Text('Could not load your profile.')),
            data: (value) {
              if (value == null) {
                return const Center(
                    child: Text('No personal profile is available.'));
              }
              final shared = ref.watch(activeSpaceIdProvider) != null;
              return ListView(padding: const EdgeInsets.all(20), children: [
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                  child: ProfileAvatar(
                                      name: value.name, radius: 36)),
                              const SizedBox(height: 12),
                              Text(
                                  value.name.trim().isEmpty
                                      ? 'Your profile'
                                      : value.name,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              const SizedBox(height: 8),
                              const Text('Your local display name',
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              if (shared)
                                FilledButton.tonal(
                                    onPressed: () async {
                                      try {
                                        await ref.read(
                                                selectNavigationContextProvider)(
                                            null);
                                        if (context.mounted) {
                                          context.go('/dashboard');
                                        }
                                      } catch (_) {
                                        if (context.mounted) {
                                          showFinancialFeedback(context,
                                              'Could not open Personal. Please try again.',
                                              kind:
                                                  FinancialFeedbackKind.error);
                                        }
                                      }
                                    },
                                    child: const Text(
                                        'Open Personal to edit your name'))
                              else
                                OutlinedButton.icon(
                                    key: const Key('editProfileNameButton'),
                                    onPressed: () => showDialog<void>(
                                        context: context,
                                        builder: (_) => _EditName(
                                            profileId: value.id,
                                            name: value.name)),
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text('Edit name')),
                            ]))),
                const SizedBox(height: 16),
                Text('Personal profiles',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ProfileSwitcherSection(onSelected: () {
                  showFinancialFeedback(context, 'Personal profile selected.');
                  context.go('/dashboard');
                }),
                const SizedBox(height: 24),
                Text('Sharing identity',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                    'Your pairing username is separate. Changing your profile name does not change your identity or past audit records.'),
                const SizedBox(height: 8),
                const IdentitySection(),
              ]);
            }));
  }
}

class _EditName extends ConsumerStatefulWidget {
  const _EditName({required this.profileId, required this.name});
  final int profileId;
  final String name;
  @override
  ConsumerState<_EditName> createState() => _EditNameState();
}

class _EditNameState extends ConsumerState<_EditName> {
  late final text = TextEditingController(text: widget.name);
  String? error;
  bool busy = false;
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (busy) return;
    final problem = profileNameProblem(text.text);
    if (problem != null) {
      setState(() => error = problem);
      return;
    }
    if (ref.read(actingProfileIdProvider) != widget.profileId ||
        ref.read(activeSpaceIdProvider) != null ||
        ref.read(lockResolutionPendingProvider) ||
        ref.read(lockControllerProvider).isLocked) {
      setState(() => error =
          'Your context changed. Close this dialog and reopen Profile.');
      return;
    }
    setState(() => busy = true);
    try {
      await ref
          .read(profileNameRepositoryProvider)
          .rename(widget.profileId, text.text, assertCanRename: () {
        if (!mounted ||
            ref.read(actingProfileIdProvider) != widget.profileId ||
            ref.read(activeSpaceIdProvider) != null ||
            ref.read(lockResolutionPendingProvider) ||
            ref.read(lockControllerProvider).isLocked) {
          throw StateError('Context changed.');
        }
      });
      if (!mounted) return;
      ref.read(dismissedProfileNamePromptsProvider.notifier).state = {
        ...ref.read(dismissedProfileNamePromptsProvider),
        widget.profileId
      };
      showFinancialFeedback(context, 'Profile name updated.');
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Could not save your name. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !busy,
      child: AlertDialog(
          title: const Text('Edit your name'),
          content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            ProfileAvatar(name: text.text, radius: 32),
            const SizedBox(height: 20),
            TextField(
                key: const Key('editProfileNameField'),
                controller: text,
                enabled: !busy,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                    labelText: 'Preferred name',
                    errorText: error,
                    errorMaxLines: 3),
                onChanged: (_) => setState(() => error = null),
                onSubmitted: (_) => save())
          ])),
          actions: [
            TextButton(
                onPressed: busy ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                key: const Key('saveProfileNameButton'),
                onPressed: busy ? null : save,
                child: Text(busy ? 'Saving…' : 'Save'))
          ]));
}
