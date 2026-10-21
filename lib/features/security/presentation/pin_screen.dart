import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/lock_subject.dart';
import '../domain/pin_result.dart';
import 'lock_keys.dart';
import 'pin_keypad.dart';

/// The PIN challenge behind the lock screen (FR-036, `contracts/security-settings-ui.md` §4).
///
/// Presentational by design: the submit callback and the remaining-wait reader
/// are injected, so the screen can be exercised without a provider, a keystore
/// or a database. It never triggers an OS prompt of its own — the single prompt
/// belongs to `deviceKeySessionProvider` and is born inside the submit callback
/// (FR-021).
///
/// The screen deliberately holds its own error and countdown state rather than
/// reading them from the lock state machine. A wrong PIN returns the *app* to
/// `locked` (FR-026) while the challenge must stay up with the error and the
/// countdown, and a model where the challenge is a function of the state cannot
/// do both.
class PinScreen extends StatefulWidget {
  const PinScreen({
    super.key,
    required this.subject,
    required this.onSubmit,
    required this.remainingWait,
    this.onCancel,
    this.biometricsAllowed = false,
    this.onBiometric,
  });

  /// Whose lock this is; shown above the keypad.
  final LockSubject subject;

  /// Checks the entered PIN and opens the app on success.
  final Future<PinResult> Function(String pin) onSubmit;

  /// How long until the keypad unlocks again; a non-positive duration means the
  /// keypad is live.
  final Duration Function() remainingWait;

  /// Leaves the challenge without trying; `null` hides the back action (the
  /// cold-start fail-closed window has nowhere to go back to).
  final VoidCallback? onCancel;

  /// Whether the in-session biometric shortcut may be offered (FR-020).
  final bool biometricsAllowed;

  /// Prompts for the device's own authentication and, on success, opens the
  /// app. `null` when [biometricsAllowed] is false.
  final Future<void> Function()? onBiometric;

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _entered = '';
  String? _error;
  bool _busy = false;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Duration get _remaining => widget.remainingWait();

  void _onChanged(String value) => setState(() => _entered = value);

  Future<void> _submitBiometric() async {
    if (_busy || _remaining > Duration.zero) return;
    final onBiometric = widget.onBiometric;
    if (onBiometric == null) return;
    setState(() => _busy = true);
    try {
      await onBiometric();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (_busy || _remaining > Duration.zero || _entered.isEmpty) return;
    final pin = _entered;
    setState(() {
      _busy = true;
      _error = null;
    });

    final result = await widget.onSubmit(pin);
    if (!mounted) return;

    setState(() {
      _busy = false;
      _entered = '';
      _error = switch (result) {
        PinResult.accepted => null,
        PinResult.wrongPin => 'Wrong PIN. Try again.',
        PinResult.lockedOut => 'Too many attempts. Wait for the countdown.',
        PinResult.deviceRefused =>
          'Your phone could not confirm it was you. Try again.',
        PinResult.notConfigured => 'No PIN is set for this subject.',
      };
    });
  }

  /// Runs a one-second tick only while a wait is actually running, so the
  /// countdown moves on its own without leaving a timer behind on a screen that
  /// has nothing to count.
  void _syncTicker() {
    if (_remaining <= Duration.zero) {
      _ticker?.cancel();
      _ticker = null;
      return;
    }
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remaining <= Duration.zero) {
          _ticker?.cancel();
          _ticker = null;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = _remaining;
    final lockedOut = remaining > Duration.zero;
    _syncTicker();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onCancel != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Back',
                      onPressed: _busy ? null : widget.onCancel,
                    ),
                  ),
                Semantics(
                  label: '${widget.subject.name}, locked',
                  child: Text(
                    widget.subject.displayAvatar,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
                const SizedBox(height: 8),
                Text(widget.subject.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                if (lockedOut)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      key: const Key(LockKeys.lockoutCountdown),
                      'Too many attempts. Try again in '
                      '${(remaining.inMilliseconds / 1000).ceil()}s.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                else if (_error != null)
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      key: const Key(LockKeys.pinError),
                      _error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                  )
                else
                  const SizedBox(height: 20),
                const SizedBox(height: 16),
                if (widget.biometricsAllowed && widget.onBiometric != null) ...[
                  FilledButton.icon(
                    key: const Key(LockKeys.biometricUnlockButton),
                    onPressed: _busy || lockedOut ? null : _submitBiometric,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Use biometrics'),
                  ),
                  const SizedBox(height: 16),
                ],
                PinKeypad(
                  value: _entered,
                  onChanged: _onChanged,
                  enabled: !_busy && !lockedOut,
                  onSubmit: _busy || lockedOut ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
