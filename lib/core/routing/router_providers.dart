import 'dart:async';
import '../providers/active_space_provider.dart';
import '../providers/selected_month_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/active_profile_provider.dart';
import '../../features/budget_setup/domain/onboarding_startup.dart';
import '../../features/budget_setup/providers/onboarding_readiness_provider.dart';
import '../../features/budget_setup/providers/onboarding_rollout_provider.dart';
import '../../features/budget_setup/providers/setup_handoff_provider.dart';
import 'app_router.dart';

/// Pure route policy; authentication stays in the existing gate. Established
/// forms receive no redirect on unrelated financial updates.
String? onboardingRedirect(OnboardingStartup? startup, String path,
    {bool failed = false, int? recoveryProfileId}) {
  if (startup == null || failed) return path == '/setup' ? null : '/setup';
  if (startup.kind == StartupKind.needsReview &&
      recoveryProfileId != null &&
      startup.existingProfileIds.contains(recoveryProfileId)) {
    return path == '/setup' ? '/dashboard' : null;
  }
  final pending = startup.kind != StartupKind.establishedUser;
  if (pending) return path == '/setup' ? null : '/setup';
  return path == '/setup' ? '/dashboard' : null;
}

class _StartupRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  if (!ref.watch(unifiedOnboardingEnabledProvider)) return goRouter;
  final refresh = _StartupRefresh();
  var alive = true;
  ref.listen(onboardingStartupProvider, (_, next) {
    scheduleMicrotask(() {
      if (!alive) return;
      final current = ref.read(onboardingStartupProvider);
      if (current != next) return;
      final startup = next.valueOrNull,
          receipt = next.valueOrNull?.state?.committed;
      if (!next.hasError &&
          startup?.kind == StartupKind.resumeSetup &&
          receipt != null) {
        if (ref.read(activeSpaceIdProvider) != null) {
          ref.read(activeSpaceIdProvider.notifier).state = null;
        }
        if (ref.read(activeProfileIdProvider) != receipt.profileId) {
          ref.read(activeProfileIdProvider.notifier).state = receipt.profileId;
        }
        if (ref.read(selectedYearMonthProvider) != receipt.yearMonth) {
          ref.read(selectedYearMonthProvider.notifier).state =
              receipt.yearMonth;
        }
      }
      refresh.refresh();
    });
  }, fireImmediately: true);
  ref.listen(setupRecoveryProfileProvider, (_, __) => refresh.refresh());
  ref.listen(activeProfileIdProvider, (_, __) => refresh.refresh());
  final router = createAppRouter(
      initialLocation: '/setup',
      refreshListenable: refresh,
      redirect: (context, state) {
        final startup = ref.read(onboardingStartupProvider);
        final recovery = ref.read(setupRecoveryProfileProvider);
        return onboardingRedirect(startup.valueOrNull, state.uri.path,
            failed: startup.hasError,
            recoveryProfileId: recovery == ref.read(activeProfileIdProvider)
                ? recovery
                : null);
      });
  ref.onDispose(() {
    alive = false;
    router.dispose();
    refresh.dispose();
  });
  return router;
});
