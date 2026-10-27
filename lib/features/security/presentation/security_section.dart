import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/shared_space.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/identity_provider.dart';
import '../../identity/repositories/consent_service.dart';
import '../domain/away_time.dart';
import '../domain/lock_subject.dart';
import '../domain/pin_result.dart';
import '../providers/lock_providers.dart';
import '../repositories/monotonic_clock_impl.dart';
import 'lock_keys.dart';
import 'pin_setup_screen.dart';
import 'security_settings_screen.dart';

/// The Settings card that turns the lock on and manages its PIN (FR-035).
///
/// Pulled forward for US1 as the feature's entry point: without a surface that
/// can write `lockEnabled` and a verifier there is no way to configure a lock on
/// the device at all, so the lock spine would be untestable outside a test.
///
/// This is deliberately the **minimal** card. The full surface — biometrics
/// (FR-020, US2), the away-time and the read-only lockout row (FR-033, FR-035,
/// US5) — lands in its own story; the keys exist so it slots in without moving
/// anything.
///
/// It carries **no heading of its own**: the "Privacy & security" heading above
/// it names it, and a second title saying the same thing in different words was
/// two things to read for one setting. The one line that does change with the
/// state is the switch's own subtitle, and it speaks the user's words — profile
/// or shared space — never the internal word "subject".
///
/// **The app lock is the lock; the device switch is a preference.** They used to
/// read as two equal locks in two different cards, which they are not: the app
/// PIN *contains* the phone's factor (`LockController.submitPin` releases the key
/// through `DeviceKeySession`), so the device switch has nothing left to add once
/// a subject has a PIN — it is hidden then, and its words are about sync and
/// pairing rather than about a second unlock.
class SecuritySection extends ConsumerWidget {
  const SecuritySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subject = ref.watch(lockSubjectProvider);
    if (subject == null) return const SizedBox.shrink();

    final setting = ref.watch(activeLockSettingProvider).valueOrNull;
    final locked = setting?.lockEnabled ?? false;

    // The lock is only the user's choice when nobody else demands it: a shared
    // space's Owner requiring a PIN makes it mandatory for every member (FR-028),
    // and a switch that offers a Turn-off the Owner will not honour is a lie.
    final requiredByOwner =
        ref.watch(activeSpaceProvider).valueOrNull?.requirePin ?? false;

    // Only meaningful next to an identity — it unlocks that identity's key, and
    // there is nothing to unlock without one. Hidden under an app PIN for the
    // same reason the words changed: the PIN already asks for the phone's factor.
    final hasIdentity = ref.watch(identityProvider).valueOrNull != null;
    final showDeviceAuth = hasIdentity && !locked;

    return Card(
      key: const Key(LockKeys.securitySection),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            key: const Key(LockKeys.lockSwitch),
            secondary: const Icon(Icons.lock_outline),
            title: const Text('App lock'),
            subtitle: Text(
              switch ((locked, requiredByOwner)) {
                (true, true) =>
                  'Required for this ${_noun(subject)} — the Owner turned '
                      'this on.',
                (true, false) =>
                  'On: app PIN and phone verification protect this ${_noun(subject)}.',
                (false, _) =>
                  'Extra app PIN is off. Phone verification still protects this '
                      '${_noun(subject)}.',
              },
            ),
            value: locked,
            // Read-only while the Owner requires it: tapping could only offer a
            // Turn-off that the composed lock would immediately undo.
            onChanged: requiredByOwner
                ? null
                : (on) => on
                    ? _startSetup(context, ref, subject)
                    : _confirmDisable(context, subject),
          ),
          if (locked)
            ListTile(
              key: const Key(LockKeys.changePinButton),
              leading: const Icon(Icons.password),
              title: const Text('Change PIN'),
              onTap: () => _changePin(context, ref, subject),
            ),
          if (locked) ...[
            const Divider(height: 1),
            _AwayTimeTile(subject: subject),
          ],
          if (locked) ...[
            const Divider(height: 1),
            const _LockoutRow(),
          ],
          if (locked) ...[
            const Divider(height: 1),
            SwitchListTile(
              key: const Key(LockKeys.biometricSwitch),
              secondary: const Icon(Icons.fingerprint),
              value:
                  (ref.watch(deviceBiometricsAvailableProvider).valueOrNull ??
                          false) &&
                      !(ref
                              .watch(activeSpaceProvider)
                              .valueOrNull
                              ?.forbidBiometrics ??
                          false),
              onChanged: null,
              title: const Text('Use biometrics for re-unlock'),
              subtitle: Text(
                (ref.watch(activeSpaceProvider).valueOrNull?.forbidBiometrics ??
                        false)
                    ? 'Forbidden by the space Owner.'
                    : (ref
                                .watch(deviceBiometricsAvailableProvider)
                                .valueOrNull ??
                            false)
                        ? 'Your phone\'s biometrics are used for re-unlock.'
                        : 'Biometrics are more secure. Set up fingerprint or face '
                            'unlock in your phone\'s settings.',
              ),
            ),
          ],
          if (locked) ...[
            const Divider(height: 1),
            ListTile(
              key: const Key('securityMoreButton'),
              leading: const Icon(Icons.shield_outlined),
              title: const Text('Privacy & security'),
              subtitle: const Text(
                'Change the PIN, or recover a forgotten one.',
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SecuritySettingsScreen(subject: subject),
                ),
              ),
            ),
          ],
          if (showDeviceAuth) const _DeviceAuthCard(),
        ],
      ),
    );
  }

  static String _noun(LockSubject subject) => switch (subject.kind) {
        LockSubjectKind.profile => 'profile',
        LockSubjectKind.space => 'shared space',
      };

  /// Turning the lock on starts with a PIN (FR-009): an enabled lock with no
  /// verifier would be a lock nobody can open, so the two are written together.
  Future<void> _startSetup(
    BuildContext context,
    WidgetRef ref,
    LockSubject subject,
  ) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PinSetupScreen(
          subject: subject,
          onSubmit: (_, newPin) async {
            try {
              await ref
                  .read(lockControllerProvider.notifier)
                  .enableLock(newPin);
              return null;
            } on Object catch (error) {
              return 'Could not save the PIN. Please try again. ($error)';
            }
          },
        ),
      ),
    );
  }

  Future<void> _changePin(
    BuildContext context,
    WidgetRef ref,
    LockSubject subject,
  ) =>
      SecurityRecovery.openChangePin(context, ref, subject);

  /// Turning the lock off demands the current PIN (FR-009): a locked phone left
  /// on a table must not lose its lock to a tap.
  Future<void> _confirmDisable(BuildContext context, LockSubject subject) {
    return showDialog<void>(
      context: context,
      // The dialog owns its own controller (see [_DisableLockDialog]): disposing
      // it from here would race the dialog's exit transition, which keeps
      // rendering the field for a few frames after `showDialog`'s future
      // completes.
      builder: (_) => _DisableLockDialog(subject: subject),
    );
  }
}

/// The five-choice away-time control (FR-033, T068).
///
/// It writes the **member's own** window. In a shared space the Owner's window
/// composes with this one by "the shorter wins" (FR-028), so the subtitle is
/// careful to promise only what the control can do: lock *sooner* than the
/// app already would, never later. A control that implied it could loosen the
/// Owner's requirement would be the same lie as a live lock switch.
class _AwayTimeTile extends ConsumerWidget {
  const _AwayTimeTile({required this.subject});

  final LockSubject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setting = ref.watch(activeLockSettingProvider).valueOrNull;
    final effective = ref.watch(effectiveLockProvider);
    final own = setting?.awayTime ?? AwayTime.twoMinutes;
    final applied = effective?.awayTime ?? own;
    final ownerTightens =
        ref.watch(activeSpaceProvider).valueOrNull?.awayTime != null;

    return ListTile(
      leading: const Icon(Icons.timer_outlined),
      title: const Text('Lock after leaving'),
      subtitle: Text(
        ownerTightens && applied != own
            ? 'Your choice: ${own.label}. The space Owner asks for '
                '${applied.label}, so that is what applies.'
            : 'The app locks this ${_noun(subject)} after this long away.',
      ),
      trailing: DropdownButton<AwayTime>(
        key: const Key(LockKeys.awayTimeDropdown),
        value: own,
        onChanged: (choice) {
          if (choice == null) return;
          ref.read(lockControllerProvider.notifier).setAwayTime(choice);
        },
        items: [
          for (final choice in AwayTime.values)
            DropdownMenuItem(value: choice, child: Text(choice.label)),
        ],
      ),
    );
  }

  static String _noun(LockSubject subject) => switch (subject.kind) {
        LockSubjectKind.profile => 'profile',
        LockSubjectKind.space => 'shared space',
      };
}

/// The read-only "a wait is running" row (FR-035).
///
/// The countdown belongs on the lock, but a wait that survives a force-quit
/// (FR-014) must also be visible where the lock is configured — otherwise the
/// user cannot tell an enforced wait from a broken PIN. It shows the countdown
/// only, never the failure count, and offers nothing to tap.
///
/// It asks the controller to re-read the persisted lockout once, after the first
/// frame: the wait lives in the OS keystore, so without that read the row would
/// be blank on a cold start even while a wait was genuinely running.
class _LockoutRow extends ConsumerStatefulWidget {
  const _LockoutRow();

  @override
  ConsumerState<_LockoutRow> createState() => _LockoutRowState();
}

class _LockoutRowState extends ConsumerState<_LockoutRow> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(lockControllerProvider.notifier).refreshLockout();
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(lockControllerProvider);
    final remaining =
        snapshot.remainingWait(ref.read(monotonicClockProvider).nowMs());

    if (remaining == null || remaining <= Duration.zero) {
      return const SizedBox.shrink();
    }

    final seconds = remaining.inSeconds;
    return ListTile(
      key: const Key(LockKeys.lockoutStatus),
      leading: const Icon(Icons.hourglass_top),
      title: const Text('Too many attempts'),
      subtitle: Text('Try again in ${seconds}s.'),
      enabled: false,
    );
  }
}

/// The device-authentication preference (FR-002, US1).
///
/// It lives here, beside the app lock, because the two are the same subject:
/// what the phone's own PIN or biometrics are for. Its words say what it
/// actually does — release the identity key for sync and pairing — instead of
/// "use my phone's PIN", which sounded like a second app lock it never was.
class _DeviceAuthCard extends ConsumerWidget {
  const _DeviceAuthCard();

  Future<void> _set(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final consent = ref.read(consentServiceProvider);
    if (!value) {
      await consent.revoke();
      return;
    }
    final ok = await ref.read(deviceAuthenticatorProvider).authenticate(
          reason: 'Turn on device authentication for BudgetBuddy',
        );
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Device authentication was not set up.'),
        ),
      );
      return;
    }
    await consent.record(
      noticeVersion: kConsentNoticeVersion,
      deviceAuthGranted: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final enabled = ref.watch(deviceAuthEnabledProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1),
        SwitchListTile(
          key: const Key('deviceAuthSwitch'),
          secondary: const Icon(Icons.fingerprint),
          value: enabled,
          onChanged: (value) => _set(context, ref, value),
          title: const Text('Protect my identity key'),
          subtitle: const Text(
            'Additional identity-key consent. Phone verification remains required to open personal information.',
          ),
        ),
        if (!enabled)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 18, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This optional identity-key setting is off. Mandatory phone verification still applies.',
                    key: const Key('deviceAuthWarning'),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The "turn the app lock off?" confirm dialog.
///
/// A `ConsumerStatefulWidget` rather than a `StatefulBuilder` purely so the PIN
/// field's [TextEditingController] lives exactly as long as the widget does
/// (FR-009). A controller disposed by the caller is disposed *before* the exit
/// animation has finished rebuilding the field, which Flutter reports as
/// "A TextEditingController was used after being disposed".
class _DisableLockDialog extends ConsumerStatefulWidget {
  const _DisableLockDialog({required this.subject});

  final LockSubject subject;

  @override
  ConsumerState<_DisableLockDialog> createState() => _DisableLockDialogState();
}

class _DisableLockDialogState extends ConsumerState<_DisableLockDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final result = await ref
        .read(lockControllerProvider.notifier)
        .disableLock(_controller.text);
    if (!mounted) return;
    if (result == PinResult.accepted) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _error = switch (result) {
          PinResult.lockedOut =>
            'Too many attempts. Wait for the countdown, then try again.',
          PinResult.notConfigured => 'No PIN is set for this subject.',
          _ => 'That is not the PIN.',
        });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Turn off the app lock?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter the current PIN to turn the lock off.'),
          const SizedBox(height: 12),
          TextField(
            key: const Key(LockKeys.pinConfirmField),
            controller: _controller,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Current PIN',
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key(LockKeys.pinConfirmSubmit),
          onPressed: _submit,
          child: const Text('Turn off'),
        ),
      ],
    );
  }
}
