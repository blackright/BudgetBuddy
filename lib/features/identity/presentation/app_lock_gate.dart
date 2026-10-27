import '../../budget_setup/providers/onboarding_readiness_provider.dart';
import '../../budget_setup/domain/onboarding_startup.dart';
import '../../budget_setup/providers/onboarding_rollout_provider.dart';
import '../../budget_setup/presentation/widgets/learning_steps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../security/presentation/lock_screen.dart';
import '../../security/providers/lock_providers.dart';
import '../providers/device_auth_session.dart';
import '../providers/device_key_session.dart';

/// The single authentication gate. PIN protection has priority; the absence of
/// an app PIN/identity never disables mandatory native authentication.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

final publicSetupIntroductionDoneProvider = StateProvider<bool>((ref) => false);

class _AppLockGateState extends ConsumerState<AppLockGate> {
  bool _busy = false, _armed = false, _publicHelp = false;
  String? _error;
  Widget _shut(Widget screen) => Navigator(
      onDidRemovePage: (_) {},
      pages: <Page<void>>[MaterialPage<void>(child: screen)]);
  Future<void> _unlock() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final binding = ref.read(nativeAccessBindingProvider);
    final auth = ref.read(deviceAuthSessionProvider.notifier);
    final keySession = ref.read(deviceKeySessionProvider.notifier);
    final epoch = auth.generation, token = binding.token;
    try {
      final success = await auth.require(reason: 'Unlock BudgetBuddy');
      if (!mounted ||
          !auth.isCurrent(epoch) ||
          ref.read(nativeAccessBindingProvider).token != token) {
        return;
      }
      if (success && binding.identity != null) {
        if (await keySession.require(reason: 'Unlock BudgetBuddy') == null) {
          if (mounted && ref.read(nativeAccessBindingProvider).token == token) {
            setState(() => _error =
                'The identity key is unavailable. Your information stays locked. Retry or restore the identity using its existing recovery process.');
          }
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final binding = ref.watch(nativeAccessBindingProvider);
    final native = ref.watch(deviceAuthSessionProvider);
    final snapshot = ref.watch(lockControllerProvider);
    if (ref.watch(lockResolutionPendingProvider) || !binding.resolved) {
      return _shut(
          const Scaffold(body: Center(child: Text('Resolving protection...'))));
    }
    final introDone = ref.watch(publicSetupIntroductionDoneProvider);
    final unified = ref.watch(unifiedOnboardingEnabledProvider);
    final fresh = unified && !introDone
        ? ref.watch(onboardingStartupProvider).valueOrNull?.kind ==
            StartupKind.firstSetup
        : false;
    if (fresh && binding.identity == null && binding.key.startsWith('setup:')) {
      return _shut(PublicSetupIntroduction(
          onContinue: () => ref
              .read(publicSetupIntroductionDoneProvider.notifier)
              .state = true));
    }
    if (snapshot.isLocked || (snapshot.isProtected && !native.authenticated)) {
      if (!_armed) {
        _armed = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ref.read(deviceKeySessionProvider.notifier).lock();
        });
      }
      return _shut(LockScreen(subject: snapshot.subject));
    }
    _armed = false;
    final key = ref.watch(deviceKeySessionProvider);
    final keyRequired = binding.identity != null || binding.isShared;
    if (native.authenticated && (!keyRequired || key != null)) {
      return widget.child;
    }
    if (_publicHelp) {
      return _shut(Scaffold(
          body: SafeArea(
              child: Center(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('Welcome to BudgetBuddy',
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 16),
                        const Text(
                            'Plan your monthly budget, record purchases and build savings. Phone verification protects your personal information. No personal records are shown in this introduction.'),
                        const SizedBox(height: 24),
                        FilledButton(
                            onPressed: () =>
                                setState(() => _publicHelp = false),
                            child: const Text('Return to phone verification')),
                      ]))))));
    }
    return _shut(Scaffold(
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.lock_outline,
                              size: 56,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 20),
                          Text('BudgetBuddy is locked',
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 12),
                          const Text(
                              "Verify with your phone's biometric or device credential to view personal information.",
                              textAlign: TextAlign.center),
                          if (_error ?? native.message
                              case final String message) ...[
                            const SizedBox(height: 16),
                            Semantics(
                                liveRegion: true,
                                child:
                                    Text(message, textAlign: TextAlign.center))
                          ],
                          const SizedBox(height: 24),
                          FilledButton(
                              key: const Key('unlockButton'),
                              onPressed: _busy || native.busy ? null : _unlock,
                              child: Text(_busy || native.busy
                                  ? 'Verifying...'
                                  : 'Unlock')),
                          TextButton(
                              onPressed: () =>
                                  setState(() => _publicHelp = true),
                              child: const Text('Back to introduction')),
                        ])))))));
  }
}
