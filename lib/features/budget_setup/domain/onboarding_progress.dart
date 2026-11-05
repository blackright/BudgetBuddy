import 'onboarding_state.dart';

/// Preserve financial evidence while patching local progress. Encoding still
/// enforces stage, revision and nested-correction invariants before any write.
OnboardingState progressCopy(OnboardingState s,
        {int? revision,
        DateTime? updatedAt,
        OnboardingStage? stage,
        OnboardingStep? step,
        bool? categoriesReady,
        bool? directoryReady,
        OnboardingSecurityChoice? securityChoice,
        String? amendmentDraftJson,
        bool clearAmendment = false,
        OnboardingCommitReference? committed}) =>
    OnboardingState(
        flowId: s.flowId,
        revision: revision ?? s.revision,
        createdAt: s.createdAt,
        updatedAt: updatedAt ?? s.updatedAt,
        stage: stage ?? s.stage,
        step: step ?? s.step,
        yearMonth: s.yearMonth,
        profile: s.profile,
        opening: s.opening,
        incomeChoice: s.incomeChoice,
        sources: s.sources,
        committed: committed ?? s.committed,
        categoriesReady: categoriesReady ?? s.categoriesReady,
        directoryReady: directoryReady ?? s.directoryReady,
        securityChoice: securityChoice ?? s.securityChoice,
        completedAt: s.completedAt,
        amendmentDraftJson:
            clearAmendment ? null : amendmentDraftJson ?? s.amendmentDraftJson);

/// Review/edit projection only; this does not discard the persisted receipt.
OnboardingState financialDraftOf(OnboardingState s, {int? revision}) =>
    OnboardingState(
        flowId: s.flowId,
        revision: revision ?? s.revision,
        createdAt: s.createdAt,
        updatedAt: s.updatedAt,
        step: s.step,
        yearMonth: s.yearMonth,
        profile: s.profile,
        opening: s.opening,
        incomeChoice: s.incomeChoice,
        sources: s.sources);
