import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/identity_provider.dart';
import 'identity_onboarding_screen.dart';

/// US1 (FR-002/014): the Settings card for the local identity.
///
/// Before onboarding it offers a single "Set up your identity" entry. Once an
/// identity exists it shows the username and fingerprint and a "Remove identity"
/// action that wipes the key. Nothing here is ever exchanged.
///
/// The device-authentication switch used to live here. It moved into the
/// **Privacy & security** group beside the app lock, because that is what it
/// belongs to: the phone's own PIN/biometrics are the same subject in both
/// places (FR-002 with FR-009, `security_section.dart` → `_DeviceAuthCard`).
class IdentitySection extends ConsumerWidget {
  const IdentitySection({super.key});

  Future<void> _openOnboarding(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => const IdentityOnboardingScreen(),
      ),
    );
  }

  Future<void> _wipe(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove your identity?'),
        content: const Text(
          'This deletes your identity key and local data on this phone. '
          'It cannot be undone, and without a backup the identity is gone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('confirmWipeIdentityButton'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(identityServiceProvider).wipe();
    messenger.showSnackBar(
      const SnackBar(content: Text('Your identity was removed.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identityAsync = ref.watch(identityProvider);
    final theme = Theme.of(context);

    return identityAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (identity) {
        if (identity == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Identity & privacy',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text(
                    'Set up a local identity to share a space with someone on '
                    'another device. No account, no email, no server.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    key: const Key('setupIdentityButton'),
                    onPressed: () => _openOnboarding(context),
                    child: const Text('Set up your identity'),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Identity & privacy', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(identity.username),
                  subtitle: Text(
                    'Fingerprint: ${identity.fingerprint}',
                    key: const Key('identityFingerprint'),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const Key('wipeIdentityButton'),
                    onPressed: () => _wipe(context, ref),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove identity'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
