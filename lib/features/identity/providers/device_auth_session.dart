import '../../budget_setup/providers/onboarding_rollout_provider.dart';
import '../../budget_setup/providers/onboarding_readiness_provider.dart';
import '../../budget_setup/domain/onboarding_startup.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/isar_helper.dart';
import '../../../core/models/identity.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/identity_provider.dart';
import '../../budget_setup/providers/setup_flow_provider.dart';
import '../../security/providers/lock_providers.dart';
import '../../security/domain/lock_subject.dart';
import '../../security/repositories/monotonic_clock_impl.dart';

/// A principal, not authentication proof. Unknown identity is never absence.
class NativeAccessBinding {
  const NativeAccessBinding(
      {required this.key,
      this.identity,
      this.isShared = false,
      this.resolved = true});
  final String key;
  final Identity? identity;
  final bool isShared, resolved;
  String get token =>
      '$key|$resolved|$isShared|${identity?.id}|${identity?.localProfileId}|${identity?.publicKey}|${identity?.keyAlgorithm}';
}

final nativeAccessBindingProvider = Provider<NativeAccessBinding>((ref) {
  final subject = ref.watch(lockSubjectProvider);
  final identity = ref.watch(identityProvider);
  final space = ref.watch(activeSpaceProvider);
  final db = IsarHelper.maybeInstance;
  if (db != null) {
    final profile = ref.watch(activeProfileProvider);
    final selected = ref.watch(activeProfileIdProvider),
        selectedSpace = ref.watch(activeSpaceIdProvider);
    if (!profile.hasValue ||
        profile.hasError ||
        profile.isLoading ||
        space.isLoading ||
        (selectedSpace != null && space.valueOrNull?.id != selectedSpace) ||
        (selectedSpace == null && space.valueOrNull != null) ||
        (selected != null && profile.valueOrNull?.id != selected)) {
      return const NativeAccessBinding(key: 'resolving', resolved: false);
    }
  }
  if (!identity.hasValue ||
      identity.hasError ||
      identity.isLoading ||
      !space.hasValue ||
      space.hasError) {
    return const NativeAccessBinding(key: 'resolving', resolved: false);
  }
  if (ref.watch(unifiedOnboardingEnabledProvider)) {
    final startup = ref.watch(onboardingStartupProvider);
    final pending = startup.valueOrNull;
    final owner = pending?.state?.committed?.profileId;
    if (startup.hasError ||
        (pending?.kind == StartupKind.resumeSetup &&
            owner != null &&
            (space.valueOrNull != null ||
                ref.watch(activeSpaceIdProvider) != null ||
                ref.watch(activeProfileProvider).valueOrNull?.id != owner))) {
      return const NativeAccessBinding(key: 'resolving', resolved: false);
    }
  }
  if (subject != null) {
    return NativeAccessBinding(
        key: subject.key,
        identity: identity.valueOrNull,
        isShared: subject.kind == LockSubjectKind.space);
  }
  if (db != null && db.userProfiles.countSync() > 0) {
    return const NativeAccessBinding(key: 'resolving', resolved: false);
  }
  final flow = ref.watch(setupFlowProvider);
  return NativeAccessBinding(
      key: 'setup:$flow', identity: identity.valueOrNull);
});

class NativeAuthSnapshot {
  const NativeAuthSnapshot(
      {required this.generation,
      required this.binding,
      this.authenticated = false,
      this.busy = false,
      this.message});
  final int generation;
  final NativeAccessBinding binding;
  final bool authenticated, busy;
  final String? message;
}

final deviceAuthSessionProvider =
    NotifierProvider<DeviceAuthSession, NativeAuthSnapshot>(
        DeviceAuthSession.new);

/// One physical prompt at a time. Invalidating a pending flight does not start
/// another OS prompt; every waiter gets refusal and can retry when it finishes.
class DeviceAuthSession extends Notifier<NativeAuthSnapshot> {
  int _generation = 0;
  bool _alive = false;
  String _contextToken = '';
  NativeAccessBinding _binding =
      const NativeAccessBinding(key: 'resolving', resolved: false);
  Future<bool>? _flight;
  int? _awaySince;
  bool _phoneLocked = false;
  @override
  NativeAuthSnapshot build() {
    _binding = ref.read(nativeAccessBindingProvider);
    ref.listen(nativeAccessBindingProvider, (previous, next) {
      if (_contextToken == next.token) return;
      _binding = next;
      _contextToken = next.token;
      _awaySince = null;
      _phoneLocked = false;
      lock();
    });
    _contextToken = _binding.token;
    _generation++;
    _alive = true;
    ref.onDispose(() {
      _alive = false;
      _generation++;
    });
    return NativeAuthSnapshot(
        generation: _generation, binding: _binding, busy: _flight != null);
  }

  int get generation => _generation;
  bool isCurrent(int generation) {
    if (!_alive || _generation != generation) return false;
    try {
      return ref.read(nativeAccessBindingProvider).token == _contextToken;
    } catch (_) {
      return false;
    }
  }

  void lock() {
    _generation++;
    if (_alive) {
      state = NativeAuthSnapshot(
          generation: _generation, binding: _binding, busy: _flight != null);
    }
  }

  Future<bool> require({required String reason, bool force = false}) {
    if (force) lock();
    if (!isCurrent(_generation)) return Future.value(false);
    if (!_binding.resolved ||
        (_binding.isShared && _binding.identity == null)) {
      return Future.value(false);
    }
    if (state.authenticated) return Future.value(true);
    return _flight ??= _authenticate(reason);
  }

  Future<bool> _authenticate(String reason) async {
    final auth = ref.read(deviceAuthenticatorProvider);
    final epoch = _generation;
    state =
        NativeAuthSnapshot(generation: epoch, binding: _binding, busy: true);
    var success = false;
    String message =
        'Phone verification was cancelled or could not finish. Retry to continue.';
    try {
      final available = await auth.isAvailable();
      if (!available) {
        message =
            'Phone authentication is unavailable. Configure phone security, then retry.';
      } else if (isCurrent(epoch)) {
        success = await auth.authenticate(reason: reason);
      }
      success = success && isCurrent(epoch);
      return success;
    } catch (_) {
      message = 'Phone verification could not finish. Retry safely.';
      return false;
    } finally {
      _flight = null;
      if (_alive) {
        state = NativeAuthSnapshot(
            generation: _generation,
            binding: _binding,
            authenticated: success && isCurrent(epoch),
            message: success ? null : message);
      }
    }
  }

  void noteLeftForeground() {
    _awaySince ??= ref.read(monotonicClockProvider).nowMs();
  }

  void notePhoneLocked() {
    _phoneLocked = true;
    lock();
    noteLeftForeground();
  }

  void noteResumed() {
    final since = _awaySince;
    _awaySince = null;
    final window = ref.read(effectiveLockProvider)?.awayTime.window ??
        const Duration(minutes: 2);
    if (_phoneLocked ||
        (since != null &&
            ref.read(monotonicClockProvider).nowMs() - since >=
                window.inMilliseconds)) {
      lock();
    }
    _phoneLocked = false;
  }
}
