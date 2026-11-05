import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/active_profile_provider.dart';
import '../../../../core/providers/active_space_provider.dart';
import '../../../../core/providers/identity_provider.dart';
import '../../../identity/providers/device_auth_session.dart';
import '../../../security/presentation/pin_setup_screen.dart';
import '../../../security/providers/lock_providers.dart';
import '../../domain/onboarding_state.dart';
import '../../providers/budget_setup_provider.dart';
import 'setup_form_components.dart';

enum SetupProtection { configured, incomplete, notConfigured }

SetupProtection classifySetupProtection(
        {required bool settingEnabled, required bool verifierPresent}) =>
    settingEnabled && verifierPresent
        ? SetupProtection.configured
        : settingEnabled || verifierPresent
            ? SetupProtection.incomplete
            : SetupProtection.notConfigured;

/// Fresh configuration read for the Finish preview; it never grants access.
final setupProtectionStatusProvider =
    FutureProvider.family<SetupProtection, String>((ref, key) async {
  final subject = ref.watch(lockSubjectProvider);
  if (subject?.key != key) throw StateError('Protection owner differs.');
  final setting = await ref.watch(activeLockSettingProvider.future);
  final verifier = await ref.watch(pinVerifierStoreProvider).isSet(key);
  return classifySetupProtection(
      settingEnabled: setting?.lockEnabled ?? false, verifierPresent: verifier);
});

class SecuritySetupStep extends ConsumerStatefulWidget {
  const SecuritySetupStep(
      {super.key, required this.ownerId, required this.flowId});
  final int ownerId;
  final String flowId;
  @override
  ConsumerState<SecuritySetupStep> createState() => _SecuritySetupStepState();
}

class _SecuritySetupStepState extends ConsumerState<SecuritySetupStep> {
  SetupProtection? _status;
  String? _error, _name;
  bool _available = false, _enrolled = false, _busy = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (ref.read(activeSpaceIdProvider) != null) {
        ref.read(activeSpaceIdProvider.notifier).state = null;
      }
      if (ref.read(activeProfileIdProvider) != widget.ownerId) {
        ref.read(activeProfileIdProvider.notifier).state = widget.ownerId;
      }
      final profile = await ref.read(activeProfileProvider.future);
      if (!mounted) return;
      final subject = ref.read(lockSubjectProvider);
      if (profile?.id != widget.ownerId ||
          subject?.key != 'p${widget.ownerId}') {
        throw StateError('The saved profile is still resolving. Retry.');
      }
      final store = ref.read(lockSettingRepositoryProvider);
      if (store == null) throw StateError('Protection storage is unavailable.');
      final row = await store.find(subject!.key);
      final hasPin =
          await ref.read(pinVerifierStoreProvider).isSet(subject.key);
      final auth = ref.read(deviceAuthenticatorProvider);
      final available = await auth.isAvailable(),
          enrolled = await auth.isEnrolled();
      if (mounted) {
        setState(() {
          _name = profile!.name;
          _available = available;
          _enrolled = enrolled;
          _status = classifySetupProtection(
              settingEnabled: row?.lockEnabled ?? false,
              verifierPresent: hasPin);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Protection could not be read for this profile. Retry before continuing.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _enroll() async {
    final subject = ref.read(lockSubjectProvider);
    if (subject?.key != 'p${widget.ownerId}') return;
    await Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (_) => PinSetupScreen(
            subject: subject!,
            onSubmit: (_, pin) async {
              if (!mounted ||
                  ref.read(lockSubjectProvider)?.key != subject.key) {
                return 'The active profile changed. Return and retry.';
              }
              try {
                await ref.read(lockControllerProvider.notifier).enableLock(pin);
                return null;
              } catch (_) {
                return 'Phone verification or saving did not finish. The protection will be checked again; retry without resetting your records.';
              }
            })));
    if (mounted) await _load();
  }

  Future<void> _saveChoice() async {
    if (_busy || _status == null || _status == SetupProtection.incomplete) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final auth = ref.read(deviceAuthSessionProvider.notifier),
        epoch = ref.read(deviceAuthSessionProvider).generation;
    try {
      final binding = ref.read(nativeAccessBindingProvider);
      if (binding.key != 'p${widget.ownerId}' ||
          !ref.read(deviceAuthSessionProvider).authenticated) {
        throw StateError('Phone verification is required.');
      }
      final verifiers = ref.read(pinVerifierStoreProvider);
      final controller = ref.read(financialSetupProvider.notifier);
      final view = ref.read(financialSetupProvider);
      if (view.draft.flowId != widget.flowId ||
          view.receipt?.profileId != widget.ownerId) {
        throw StateError('The saved setup changed.');
      }
      await controller.confirmProtection(
          _status == SetupProtection.configured
              ? OnboardingSecurityChoice.configured
              : OnboardingSecurityChoice.notNow,
          verifiers.isSet);
      if (mounted && auth.isCurrent(epoch)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Protection choice saved. Phone authentication remains required.')));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Protection changed or could not be confirmed. Reload its actual status and retry.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => SetupSurface(
      highlight: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.security_outlined,
            size: 36, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(_name == null ? 'Profile protection' : 'Protection for $_name',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        const Text(
            'Your phone verifies you before personal information appears. You can add a separate BudgetBuddy PIN for an extra check.'),
        const SizedBox(height: 12),
        Text(switch (_status) {
          SetupProtection.configured => 'App PIN is configured.',
          SetupProtection.incomplete =>
            'Saved PIN protection is incomplete. Use the existing protection recovery or change flow; it will not be replaced here.',
          SetupProtection.notConfigured => 'No extra app PIN is configured.',
          null => 'Reading actual protection...'
        }),
        if (_status != null)
          Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(!_available
                  ? 'Phone authentication is unavailable. Configure phone security, then retry.'
                  : _enrolled
                      ? 'Enrolled biometrics are available. Your phone also controls device-credential fallback.'
                      : 'No biometric is enrolled. A working phone credential can still verify you.')),
        if (_error != null)
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Semantics(liveRegion: true, child: Text(_error!))),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          if (_status == SetupProtection.notConfigured)
            FilledButton(
                style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                onPressed: _busy || !_available ? null : _enroll,
                child: const Text('Add app PIN')),
          if (_status != null && _status != SetupProtection.incomplete)
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                onPressed: _busy || !_available ? null : _saveChoice,
                child: Text(
                    _status == SetupProtection.configured
                        ? 'Keep configured protection'
                        : 'Continue with phone authentication',
                    textAlign: TextAlign.center)),
          TextButton(
              onPressed: _busy ? null : _load,
              child: const Text('Reload protection status')),
        ]),
      ]));
}
