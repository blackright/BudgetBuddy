import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/identity_provider.dart';
import '../../security/presentation/lock_screen.dart';
import '../../security/providers/lock_providers.dart';
import '../providers/device_key_session.dart';

/// US1 (FR-002 AC2) and 016 (FR-022, FR-023): the app's single gate.
///
/// Two gates live here, in order of precedence:
///
/// 1. **016's per-subject lock.** If a lock is configured anywhere on the device
///    but the active subject has not resolved yet, nothing is painted — the
///    synchronous [lockResolutionPendingProvider] closes the cold-start window
///    (FR-023). Once the subject is known, a protected one **owns the gate**:
///    it shows its own lock screen, and opening it costs the device prompt that
///    `submitPin` runs (FR-048). For the rest of the session 015 is skipped, so
///    one unlock is one prompt rather than two (FR-021). An unprotected subject
///    falls through to gate 2.
/// 2. **015's device-auth gate** (below, unchanged): when the user has an
///    identity **and** has granted device auth, *and* 016 did not already open
///    the app for this subject. The decision is made once, when the identity and
///    consent streams first settle (a cold start). Turning the switch on
///    mid-session does not slam the lock in the user's face — it takes effect the
///    next time the app opens. When there is no identity, or device auth was
///    declined, the gate is completely inert and 011 behaviour is unchanged.
///
/// This is the **only** place 015's unlock prompt is born (T074); 016's own one
/// lives in `LockController.submitPin`, beside the PIN it guards. Everything
/// downstream — sync, pairing, adding a person — reads the key this gate
/// released from [deviceKeySessionProvider] and never prompts on its own, so a
/// cold start costs exactly one fingerprint scan instead of two or three.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  bool _initialised = false;
  bool _locked = false;
  bool _busy = false;

  /// Whether the 016 lock has already dropped the session key for the lock it is
  /// currently showing. The write is scheduled once per shut, not once per frame.
  bool _lockArmed = false;

  /// Whether the previous build saw a protected subject, so a transition into
  /// an unprotected one can drop the key the departed subject released (T049).
  bool _wasProtected = false;

  /// Whether 016 has opened the app on this subject in this session.
  ///
  /// Reaching an open 016 lock screen always cost a device prompt — the one
  /// inside `submitPin` (FR-048), or the in-session biometric itself — so the
  /// device factor has already been paid. 015 is then skipped for the rest of
  /// the session, including after the lock is turned off: asking a second time
  /// for something the user just did is the ceremony FR-021 forbids.
  bool _openedBy016 = false;

  Future<void> _unlock() async {
    setState(() => _busy = true);
    // One prompt, owned here. The session remembers a *success* for the rest of
    // the session but never a failure, so cancelling simply leaves the button
    // available for a second try (T073) instead of sticking on "locked".
    final keyPair = await ref
        .read(deviceKeySessionProvider.notifier)
        .require(reason: 'Unlock BudgetBuddy');
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (keyPair != null) _locked = false;
    });
  }

  /// Enforces "while the gate is shut the key is not out", **after** this frame.
  ///
  /// The write cannot happen during `build`: Riverpod throws "Tried to modify a
  /// provider while the widget tree was building" for any `state = …` there
  /// (even assigning the value it already holds), because a mid-build change
  /// lets two widgets see two different versions of the same state.
  ///
  /// Deferring costs nothing. The decision itself stays synchronous in [build],
  /// so the lock screen paints in the very frame the decision lands (never a
  /// frame of the app behind it), and at cold start the session is born locked
  /// anyway — this is the safety belt for the key ever being out while the gate
  /// is shut.
  void _lockWhenShut() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(deviceKeySessionProvider.notifier).lock();
    });
  }

  /// Frames the lock screen in an [Overlay] of its own.
  ///
  /// This gate is mounted through `MaterialApp.builder`, which sits *above* the
  /// app's Navigator — the widget that owns the tree's only [Overlay]. Replacing
  /// the child with the lock screen (FR-023: nothing of the app behind it may
  /// show) therefore takes that Overlay away with it, and the first widget that
  /// needs one throws "No Overlay widget found" — as the PIN keypad's [Tooltip]
  /// did. A one-page [Navigator] hands the lock screen an Overlay again, and a
  /// place to hang a dialog or a SnackBar, while still painting nothing else.
  ///
  /// The declarative page API is used on purpose: when a cold start resolves the
  /// subject, the same screen is rebuilt with the new [LockSubject] and the route
  /// follows it, where `onGenerateRoute` would have frozen the first child it
  /// ever saw.
  Widget _shut(Widget screen) => Navigator(
        onDidRemovePage: (_) {},
        pages: <Page<void>>[MaterialPage<void>(child: screen)],
      );

  @override
  Widget build(BuildContext context) {
    // 016 first: a configured lock outranks the device-auth gate, and outranks
    // even knowing whose it is (FR-023).
    if (ref.watch(lockResolutionPendingProvider)) {
      return _shut(const LockScreen());
    }

    final snapshot = ref.watch(lockControllerProvider);
    if (snapshot.isLocked) {
      if (!_lockArmed) {
        _lockArmed = true;
        _lockWhenShut();
      }
      _wasProtected = snapshot.isProtected;
      return _shut(LockScreen(subject: snapshot.subject));
    }
    _lockArmed = false;

    // A protected subject that is left for an unprotected one has locked behind
    // us: drop the key it released so it cannot leak into the next subject
    // (FR-022, FR-024, T049).
    if (_wasProtected && !snapshot.isProtected) {
      _lockWhenShut();
    }
    _wasProtected = snapshot.isProtected;

    // 016 owns the gate for a protected subject — its lock screen *and* its
    // unlock. Opening it already cost the device prompt (FR-048), so 015 has
    // nothing left to ask for this session: stacking its screen here was what
    // charged a single PIN unlock a second system prompt (FR-021).
    if (snapshot.isProtected) {
      _openedBy016 = true;
      return widget.child;
    }

    final identityAsync = ref.watch(identityProvider);
    final consentAsync = ref.watch(consentProvider);

    if (!_initialised && identityAsync.hasValue && consentAsync.hasValue) {
      _initialised = true;
      _locked = !_openedBy016 &&
          identityAsync.value != null &&
          (consentAsync.value?.deviceAuthGranted ?? false);
      if (_locked) _lockWhenShut();
    }

    if (!_locked) return widget.child;

    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline,
                  size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('BudgetBuddy is locked', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Unlock with your phone\'s PIN or biometrics.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('unlockButton'),
                onPressed: _busy ? null : _unlock,
                child: const Text('Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
