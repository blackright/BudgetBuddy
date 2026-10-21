import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/lock_subject.dart';
import '../domain/pin_policy.dart';
import 'lock_keys.dart';
import 'pin_keypad.dart';

/// Whether the screen is setting a PIN for the first time or replacing one.
enum PinSetupMode { create, change }

/// The steps a setup walks through, in order.
enum _Step { current, newPin, confirm }

/// Sets or changes the PIN for [subject] (FR-009, FR-039,
/// `contracts/security-settings-ui.md` §2-§3).
///
/// The screen never accepts a first PIN before showing what forgetting it means
/// (FR-039): the warning sits above the keypad from the first frame, so there is
/// no path to a stored PIN that skipped it.
///
/// A change walks through the same verifier gate as the lock screen, so it can
/// come back locked out. [remainingWait] lets the same honest countdown the lock
/// screen shows appear here too (FR-036) — without it the surface would have to
/// blame the user's typing for a wait the app is enforcing.
///
/// The submit callback receives the current PIN (only in [PinSetupMode.change])
/// and the new one, and returns an error message or `null`. The screen does not
/// know about the verifier store or the lock controller — the card wires those.
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({
    super.key,
    required this.subject,
    this.mode = PinSetupMode.create,
    required this.onSubmit,
    this.remainingWait,
  });

  final LockSubject subject;
  final PinSetupMode mode;

  /// How long until the verifier will answer again; a non-positive duration
  /// means the gate is live. `null` when the caller has no lockout to report
  /// (the create path never checks a current PIN, so it never waits).
  final Duration Function()? remainingWait;

  /// Returns `null` on success, or a plain message to show and stay open.
  final Future<String?> Function(String? currentPin, String newPin) onSubmit;

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  late _Step _step =
      widget.mode == PinSetupMode.change ? _Step.current : _Step.newPin;
  String _entered = '';
  String? _currentPin;
  String? _newPin;
  String? _error;
  bool _busy = false;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Duration get _remaining => widget.remainingWait?.call() ?? Duration.zero;

  void _onChanged(String value) => setState(() => _entered = value);

  Future<void> _submit() async {
    if (_busy || _remaining > Duration.zero || _entered.isEmpty) return;

    switch (_step) {
      case _Step.current:
        setState(() {
          _currentPin = _entered;
          _entered = '';
          _error = null;
          _step = _Step.newPin;
        });
      case _Step.newPin:
        // FR-007 and FR-010: shape and guessability are checked before the PIN
        // is ever carried forward, so a refused PIN never reaches the confirm
        // step.
        final problem = PinPolicy.errorFor(_entered);
        if (problem != null) {
          setState(() {
            _error = problem;
            _entered = '';
          });
          return;
        }
        setState(() {
          _newPin = _entered;
          _entered = '';
          _error = null;
          _step = _Step.confirm;
        });
      case _Step.confirm:
        if (_entered != _newPin) {
          setState(() {
            _error = 'The two PINs do not match.';
            _entered = '';
            _step = _Step.newPin;
          });
          return;
        }
        setState(() {
          _busy = true;
          _error = null;
        });
        final error = await widget.onSubmit(_currentPin, _newPin!);
        if (!mounted) return;
        if (error != null) {
          setState(() {
            _busy = false;
            _error = error;
            _entered = '';
            _step = _Step.newPin;
          });
          return;
        }
        Navigator.of(context).maybePop(true);
    }
  }

  String get _heading => switch (widget.mode) {
        PinSetupMode.create => 'Set a PIN',
        PinSetupMode.change => 'Change PIN',
      };

  String get _hint => switch (_step) {
        _Step.current => 'Enter the current PIN',
        _Step.newPin => 'Enter a new PIN, ${PinPolicy.minLength}-'
            '${PinPolicy.maxLength} digits',
        _Step.confirm => 'Enter the new PIN again',
      };

  /// Runs a one-second tick only while a wait is actually running, so the
  /// countdown moves on its own without leaving a timer behind on a screen that
  /// has nothing to count (the same discipline as `PinScreen`).
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
      key: const Key(LockKeys.pinSetupScreen),
      appBar: AppBar(
        title: Text(_heading),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: _busy ? null : () => Navigator.of(context).maybePop(false),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.mode == PinSetupMode.create) ...[
                  Card(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Your PIN cannot be recovered. If you forget it, another '
                        'profile on this phone can unlock and reset it, and every '
                        'record is kept. If nothing on this phone can unlock, the '
                        'only way back is a clean start, which removes everything '
                        '- you will be told exactly what will be removed first.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(_hint, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
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
                  ),
                const SizedBox(height: 8),
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
