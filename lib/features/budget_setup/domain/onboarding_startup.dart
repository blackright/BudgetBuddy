import 'onboarding_state.dart';

enum StartupKind { firstSetup, resumeSetup, establishedUser, needsReview }

/// Classification contains no authentication grant. The existing app gate must
/// protect every destination, including independently valid existing profiles.
class OnboardingStartup {
  OnboardingStartup(this.kind,
      {this.state, Set<int> existingProfileIds = const {}})
      : existingProfileIds = Set.unmodifiable(existingProfileIds);
  final StartupKind kind;
  final OnboardingState? state;
  final Set<int> existingProfileIds;
}

OnboardingStartup resolveOnboardingStartup(
    {required Set<int> profileIds,
    OnboardingState? state,
    bool invalid = false,
    bool targetsValid = true}) {
  StartupKind kind;
  if (invalid ||
      (state?.committed != null &&
          !profileIds.contains(state!.committed!.profileId)) ||
      !targetsValid ||
      (state?.committed == null && state != null && profileIds.isNotEmpty)) {
    kind = StartupKind.needsReview;
  } else if (state != null && state.stage != OnboardingStage.completed) {
    kind = StartupKind.resumeSetup;
  } else if (profileIds.isEmpty) {
    kind = state == null ? StartupKind.firstSetup : StartupKind.needsReview;
  } else {
    kind = StartupKind.establishedUser;
  }
  return OnboardingStartup(kind, state: state, existingProfileIds: profileIds);
}

bool shouldPreserveSetupMonth(
        {required int? pendingProfileId,
        required int? activeProfileId,
        required bool isShared}) =>
    !isShared &&
    pendingProfileId != null &&
    pendingProfileId == activeProfileId;
