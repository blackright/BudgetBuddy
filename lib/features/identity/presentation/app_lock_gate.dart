import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/identity_provider.dart';

/// US1 (FR-002 AC2): gates the app behind the phone's own authentication when
/// the user has an identity **and** has granted device auth.
///
/// The decision is made once, when the identity and consent streams first
/// settle (a cold start). Turning the switch on mid-session does not slam the
/// lock in the user's face — it takes effect the next time the app opens. When
/// there is no identity, or device auth was declined, the gate is completely
/// inert and 011 behaviour is unchanged.
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

  Future<void> _unlock() async {
    setState(() => _busy = true);
    final ok = await ref
        .read(deviceAuthenticatorProvider)
        .authenticate(reason: 'Unlock BudgetBuddy');
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) _locked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final identityAsync = ref.watch(identityProvider);
    final consentAsync = ref.watch(consentProvider);

    if (!_initialised && identityAsync.hasValue && consentAsync.hasValue) {
      _initialised = true;
      _locked = identityAsync.value != null &&
          (consentAsync.value?.deviceAuthGranted ?? false);
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
