import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/shared_space.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../identity/providers/device_key_session.dart';
import '../domain/lock_state.dart';
import '../domain/lock_subject.dart';
import '../providers/lock_providers.dart';
import '../repositories/monotonic_clock_impl.dart';
import 'lock_keys.dart';
import 'pin_screen.dart';
import 'pin_setup_screen.dart';
import 'security_settings_screen.dart';

/// What the app shows while a subject is locked (FR-023, FR-037,
/// `contracts/lock-state-machine.md` §2).
///
/// In the `locked` state exactly three things are allowed here: the subject's
/// avatar, its name, and one Unlock action. No figure, no list, no notification
/// content, no deep-link target — a lock screen that leaks "how much is left" is
/// not a lock (FR-023).
///
/// When [subject] is `null`, the app knows a *lock* exists but not yet whose it
/// is — the fail-closed window at cold start, closed by
/// `lockResolutionPendingProvider`. Nothing is named then, because there is no
/// one to name and no one to offer an unlock to, so the screen deliberately
/// offers **no** way in.
///
/// The screen keeps its own "the PIN challenge is up" flag rather than deriving
/// it from [LockController]'s state. A wrong PIN returns the app to `locked`
/// (FR-026) while the challenge must stay up with the error and the countdown
/// (FR-036); a view that was a pure function of the state could not do both.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key, this.subject});

  /// The locked subject, or `null` while it is still being resolved.
  final LockSubject? subject;

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

extension on _LockScreenState {
  /// Whether the lock is required by a space Owner (not the member's own PIN).
  ///
  /// The caller reads the space with `ref.watch` and passes the value in rather
  /// than this reading it itself: the space arrives on a stream a frame or two
  /// after the screen first paints, and a `ref.read` here would freeze the
  /// first, not-yet-emitted answer — showing the member an Unlock button for a
  /// lock they never set (FR-027, FR-028).
  bool _ownerRequiresPin(SharedSpace? space) => space?.requirePin ?? false;

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
}

class _LockScreenState extends ConsumerState<LockScreen> {
  /// Whether the PIN screen is currently up. Local on purpose (see the class
  /// doc): an accepted PIN unmounts this whole screen through the gate, while a
  /// wrong one must leave the challenge standing.
  bool _showPin = false;

  @override
  void initState() {
    super.initState();
    // A cold start rebuilds the controller with no memory, so the wait that
    // survived a force-quit would otherwise be invisible until the first failed
    // attempt. Deferred to after the frame so the controller's own build has
    // settled the subject first (FR-014, FR-036).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(lockControllerProvider.notifier).refreshLockout();
    });
  }

  @override
  void didUpdateWidget(LockScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Switching subject must not carry a half-entered PIN across (FR-032).
    if (oldWidget.subject?.key != widget.subject?.key) {
      _showPin = false;
    }
  }

  Future<void> _showRecoveryOptions() async {
    await SecurityRecovery.showForgotOptions(
      context,
      ref,
      widget.subject!,
      onErased: () {
        if (mounted) GoRouter.of(context).go('/setup');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;

    if (_showPin && subject != null) {
      return PinScreen(
        subject: subject,
        onSubmit: (pin) =>
            ref.read(lockControllerProvider.notifier).submitPin(pin),
        remainingWait: () {
          final snapshot = ref.read(lockControllerProvider);
          final nowMs = ref.read(monotonicClockProvider).nowMs();
          return snapshot.remainingWait(nowMs) ?? Duration.zero;
        },
        biometricsAllowed: ref.watch(lockControllerProvider).biometricsAllowed,
        onBiometric: () async {
          final keyPair = await ref
              .read(deviceKeySessionProvider.notifier)
              .require(reason: 'Unlock BudgetBuddy');
          if (keyPair == null) return;
          ref
              .read(lockControllerProvider.notifier)
              .markUnlocked(LockEvent.biometricAccepted);
        },
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // One spoken unit for the avatar and the name, so a screen reader
              // says "Ann, locked" rather than reading a lone emoji. The name
              // itself is not announced twice (contract §5).
              Semantics(
                label: subject == null
                    ? 'BudgetBuddy is locked'
                    : '${subject.name}, locked',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ExcludeSemantics(
                      child: Text(
                        subject?.displayAvatar ?? '🔒',
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ExcludeSemantics(
                      child: Text(
                        subject?.name ?? 'BudgetBuddy is locked',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
              // The one way in. Without a resolved subject there is no one to
              // unlock, so the button is not offered at all (FR-023).
              if (subject != null) ...[
                // When the lock is required by a space Owner but the member has
                // not set their own PIN yet, explain why and offer to set one up
                // (FR-027, FR-028, T061).
                if (_ownerRequiresPin(
                    ref.watch(activeSpaceProvider).valueOrNull)) ...[
                  const SizedBox(height: 16),
                  Text(
                    'The Owner of this space requires a PIN. Set one up to '
                    'continue.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    button: true,
                    label: 'Set up PIN',
                    child: ExcludeSemantics(
                      child: FilledButton(
                        onPressed: () => _startSetup(context, ref, subject),
                        child: const Text('Set up PIN'),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 24),
                  Semantics(
                    button: true,
                    label: 'Unlock',
                    child: ExcludeSemantics(
                      child: FilledButton(
                        key: const Key(LockKeys.unlockButton),
                        onPressed: () {
                          ref
                              .read(lockControllerProvider.notifier)
                              .beginUnlock();
                          setState(() => _showPin = true);
                        },
                        child: const Text('Unlock'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      ref.read(lockControllerProvider.notifier).lockNow();
                    },
                    child: const Text('Lock now'),
                  ),
                ],
                const SizedBox(height: 16),
                TextButton(
                  key: const Key('forgotPinButton'),
                  onPressed: _showRecoveryOptions,
                  child: const Text('Forgot your PIN?'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
