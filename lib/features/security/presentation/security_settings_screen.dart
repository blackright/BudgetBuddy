import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_helper.dart';
import '../../../core/database/money_integrity.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../identity/providers/device_key_session.dart';
import '../domain/lock_subject.dart';
import '../domain/pin_result.dart';
import '../providers/lock_providers.dart';
import '../repositories/monotonic_clock_impl.dart';
import 'pin_setup_screen.dart';

/// The deeper security flows, in one place (T066, FR-035, FR-045).
///
/// The Settings card ([SecuritySection]) is the *surface*: it shows the state
/// and flips the lock. This screen is where the flows that need their own room
/// live — changing the PIN, recovering a forgotten one through another profile,
/// and the last-resort erase-and-start-clean.
///
/// The recovery and erase logic is **deliberately not a screen-only concern**:
/// the lock screen has to be able to reach the very same path when the member
/// has forgotten the PIN. So the work sits in [SecurityRecovery], a small
/// object both surfaces call, and neither can drift from the other. That is the
/// whole reason this file exists rather than the logic being copied.
///
/// It carries no route of its own: it is opened the way Settings opens its
/// other sub-screens, with a `MaterialPageRoute`, so the app's routing table
/// stays about navigation and not about one card's internals.
class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key, required this.subject});

  final LockSubject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & security')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              key: const Key('securityChangePin'),
              leading: const Icon(Icons.password),
              title: const Text('Change PIN'),
              subtitle: const Text('Enter the current PIN, then the new one.'),
              onTap: () =>
                  SecurityRecovery.openChangePin(context, ref, subject),
            ),
          ),
          Card(
            child: ListTile(
              key: const Key('securityForgotPin'),
              leading: const Icon(Icons.help_outline),
              title: const Text('Forgot the PIN?'),
              subtitle: const Text(
                'Another profile on this phone can reset it, keeping every '
                'record.',
              ),
              onTap: () => SecurityRecovery.showForgotOptions(
                context,
                ref,
                subject,
                onErased: () {
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The recovery paths shared by Settings and the lock screen (FR-045).
///
/// Everything here is static and takes the [BuildContext] and [WidgetRef] it is
/// called with, because the two callers mount it in different trees: the lock
/// screen is a full-screen gate, Settings is a pushed route. Neither may own the
/// other's navigation, so each passes the single thing it does when the erase
/// succeeds.
class SecurityRecovery {
  const SecurityRecovery._();

  /// The PIN change flow, from the settings surface (FR-009, FR-036).
  static Future<void> openChangePin(
    BuildContext context,
    WidgetRef ref,
    LockSubject subject,
  ) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PinSetupScreen(
          subject: subject,
          mode: PinSetupMode.change,
          // The same honest countdown the lock shows, so a locked-out user is
          // not accused of a wrong PIN the app itself refused to check (FR-036).
          remainingWait: () {
            final snapshot = ref.read(lockControllerProvider);
            final nowMs = ref.read(monotonicClockProvider).nowMs();
            return snapshot.remainingWait(nowMs) ?? Duration.zero;
          },
          onSubmit: (currentPin, newPin) async {
            final result = await ref
                .read(lockControllerProvider.notifier)
                .changePin(currentPin ?? '', newPin);
            return switch (result) {
              PinResult.accepted => null,
              // Neither of these is "you typed the wrong digits" — saying so
              // would accuse the user of a mistake the app itself is refusing
              // to check (FR-013, FR-036).
              PinResult.lockedOut =>
                'Too many attempts. Wait for the countdown, then try again.',
              PinResult.notConfigured => 'No PIN is set for this subject.',
              _ => 'That is not the current PIN.',
            };
          },
        ),
      ),
    );
  }

  /// Explains what forgetting a PIN means, then offers recovery or erase.
  ///
  /// [onErased] runs after the database has been cleared: the lock screen sends
  /// the app to setup, the settings screen simply closes. Only the caller knows
  /// which, so only the caller decides.
  static Future<void> showForgotOptions(
    BuildContext context,
    WidgetRef ref,
    LockSubject subject, {
    required VoidCallback onErased,
  }) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Forgot your PIN?'),
        content: const Text(
          'To reset this PIN, another profile on this phone must be unlocked '
          'first. If nothing on this phone can unlock, the only way forward is '
          'to erase all data and start clean.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop('erase'),
            child: const Text('Erase and start over'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop('recover'),
            child: const Text('I have another profile'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (choice == 'erase') {
      await confirmErase(context, ref, onErased: onErased);
    } else if (choice == 'recover') {
      await recoverWithAnotherProfile(context, ref, subject,
          onErased: onErased);
    }
  }

  /// Lets another unlocked profile reset [lockedSubject]'s PIN (FR-045).
  static Future<void> recoverWithAnotherProfile(
    BuildContext context,
    WidgetRef ref,
    LockSubject lockedSubject, {
    required VoidCallback onErased,
  }) async {
    final profiles = ref.read(profilesProvider).valueOrNull ?? [];
    final store = ref.read(lockSettingRepositoryProvider);
    if (store == null) {
      await confirmErase(context, ref, onErased: onErased);
      return;
    }

    final candidates = profiles
        .where((p) => !(lockedSubject.kind == LockSubjectKind.profile &&
            lockedSubject.localId == p.id))
        .toList();

    if (candidates.isEmpty) {
      await confirmErase(context, ref, onErased: onErased);
      return;
    }

    final picked = await _pickProfile(context, candidates);
    if (picked == null || !context.mounted) return;

    final chosenSubject = LockSubject.profile(
      id: picked.id,
      name: picked.name,
      avatar: picked.avatar,
    );
    final setting = await store.find(chosenSubject.key);
    if (!context.mounted) return;
    final hasLock = setting?.lockEnabled ?? false;

    if (hasLock) {
      final pin = await _askForPin(context, 'Enter ${picked.name}\'s PIN');
      if (pin == null || !context.mounted) return;
      final verifiers = ref.read(pinVerifierStoreProvider);
      final ok = await verifiers.verify(chosenSubject.key, pin);
      if (!ok) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('That is not the PIN.')),
          );
        }
        return;
      }
    }

    if (!context.mounted) return;
    final newPin = await _askForNewPin(context, lockedSubject);
    if (newPin == null || !context.mounted) return;

    try {
      await ref.read(lockControllerProvider.notifier).resetPin(newPin);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN reset. You can now unlock.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not reset the PIN. ($e)')),
        );
      }
    }
  }

  /// The last resort: erase every record and start clean (FR-039).
  static Future<void> confirmErase(
    BuildContext context,
    WidgetRef ref, {
    required VoidCallback onErased,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Erase and start over?'),
        content: const Text(
          'Nothing on this phone can open this lock. The only way forward is '
          'to erase every record on this device and start clean. This cannot be '
          'undone.\n\n'
          'What will be removed: all profiles, expenses, budgets, medical '
          'bills, savings vaults, spaces, and your identity. What will be kept: '
          'nothing — there is no backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Erase everything'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    ref.read(deviceKeySessionProvider.notifier).lock();
    await resetLocalDatabase(IsarHelper.instance);
    onErased();
  }

  static Future<UserProfile?> _pickProfile(
    BuildContext context,
    List<UserProfile> candidates,
  ) {
    return showDialog<UserProfile>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose a profile'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: candidates.length,
            itemBuilder: (_, i) {
              final p = candidates[i];
              return ListTile(
                leading: Text(p.avatar.isEmpty ? '👤' : p.avatar,
                    style: const TextStyle(fontSize: 24)),
                title: Text(p.name),
                onTap: () => Navigator.of(dialogContext).pop(p),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static Future<String?> _askForPin(BuildContext context, String title) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  static Future<String?> _askForNewPin(
    BuildContext context,
    LockSubject subject,
  ) async {
    final pin1 =
        await _askForPin(context, 'Enter a new PIN for ${subject.name}');
    if (pin1 == null || pin1.isEmpty) return null;
    if (!context.mounted) return null;
    final pin2 = await _askForPin(context, 'Enter the new PIN again');
    if (pin2 == null) return null;
    if (pin1 != pin2) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The two PINs do not match.')),
        );
      }
      return null;
    }
    return pin1;
  }
}
