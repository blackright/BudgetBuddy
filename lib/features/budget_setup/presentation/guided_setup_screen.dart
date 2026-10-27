import '../repositories/onboarding_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/selected_month_provider.dart';
import '../../identity/providers/device_auth_session.dart';
import '../../security/providers/lock_providers.dart';
import '../domain/onboarding_state.dart';
import '../providers/budget_setup_provider.dart';
import '../providers/setup_handoff_provider.dart';
import '../providers/onboarding_readiness_provider.dart';
import 'widgets/learning_steps.dart';
import '../../../shared/presentation/financial_feedback.dart';
import 'widgets/profile_setup_step.dart';
import 'widgets/month_income_step.dart';
import 'widgets/setup_review.dart';
import 'widgets/setup_recovery.dart';
import 'widgets/setup_form_components.dart';
import 'widgets/security_setup_step.dart';

class GuidedSetupScreen extends ConsumerStatefulWidget {
  const GuidedSetupScreen({super.key});
  @override
  ConsumerState<GuidedSetupScreen> createState() => _GuidedSetupScreenState();
}

class _GuidedSetupScreenState extends ConsumerState<GuidedSetupScreen> {
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  int _stage = 2;
  bool _initialized = false, _busy = false;
  String? _error;
  Future<void> Function()? _failedAction;
  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      _failedAction = null;
    } catch (_) {
      _failedAction = action;
      if (mounted) {
        setState(() => _error =
            'This step could not finish. Your saved information is retained. Retry or review the saved setup.');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        if (ref.read(financialSetupProvider).errors.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) focusFirstSetupError(context);
          });
        } else if (_scroll.hasClients) {
          _scroll.jumpTo(0);
        }
      }
    }
  }

  Future<void> _move(int stage) async {
    final c = ref.read(financialSetupProvider.notifier);
    if (stage <= 2 && ref.read(financialSetupProvider).receipt == null) {
      await c.goTo(0);
    }
    await c.checkpoint(OnboardingStep.values[stage]);
    if (mounted) {
      if (stage == 6 && ref.read(financialSetupProvider).receipt != null) {
        ref.invalidate(setupProtectionStatusProvider(
            'p${ref.read(financialSetupProvider).receipt!.profileId}'));
      }
      setState(() => _stage = stage);
    }
  }

  Future<void> _continue() async {
    final c = ref.read(financialSetupProvider.notifier),
        view = ref.read(financialSetupProvider);
    if (_stage < 2) {
      await _move(_stage + 1);
      return;
    }
    if (_stage == 2) {
      if (view.receipt != null) {
        await _move(3);
        return;
      }
      await c.next();
      if (mounted && ref.read(financialSetupProvider).page == 1) await _move(3);
      return;
    }
    if (_stage == 3) {
      if (view.receipt != null) {
        await _move(4);
        return;
      }
      if (view.page == 1) {
        await c.next();
        return;
      }
      final auth = ref.read(deviceAuthSessionProvider.notifier),
          epoch = auth.generation;
      final binding = ref.read(nativeAccessBindingProvider).token;
      bool valid() =>
          mounted &&
          auth.isCurrent(epoch) &&
          ref.read(nativeAccessBindingProvider).token == binding &&
          ref.read(deviceAuthSessionProvider).authenticated &&
          !ref.read(lockControllerProvider).isLocked;
      await c.save(isAuthorized: valid);
      if (mounted && ref.read(financialSetupProvider).receipt != null) {
        showFinancialFeedback(context, 'Financial details saved.');
        await _move(4);
      }
      return;
    }
    if (_stage == 4) {
      final saved = c.savedProgress;
      if (saved == null ||
          saved.securityChoice == OnboardingSecurityChoice.pending ||
          !c.preparationReady) {
        throw StateError('Confirm protection and preparation.');
      }
      await _move(5);
      return;
    }
    if (_stage == 5) {
      await _move(6);
      return;
    }
    final receipt = view.receipt;
    if (receipt == null) throw StateError('The saved owner is unavailable.');
    final native = ref.read(deviceAuthSessionProvider.notifier),
        epoch = ref.read(deviceAuthSessionProvider).generation;
    bool authorized() {
      if (!mounted || !native.isCurrent(epoch)) return false;
      return ref.read(nativeAccessBindingProvider).key ==
              'p${receipt.profileId}' &&
          ref.read(deviceAuthSessionProvider).authenticated &&
          !ref.read(lockControllerProvider).isLocked &&
          ref.read(activeSpaceIdProvider) == null &&
          ref.read(activeProfileProvider).valueOrNull?.id == receipt.profileId;
    }

    if (!authorized()) throw StateError('Verify the exact profile.');
    ref.read(selectedYearMonthProvider.notifier).state = receipt.yearMonth;
    ref.read(setupHandoffProvider.notifier).state = receipt;
    final verifiers = ref.read(pinVerifierStoreProvider);
    try {
      await c.finish(verifierIsSet: verifiers.isSet, isAuthorized: authorized);
      if (mounted && authorized()) context.go('/dashboard');
    } catch (_) {
      if (mounted) ref.read(setupHandoffProvider.notifier).state = null;
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = ref.watch(financialSetupProvider),
        c = ref.read(financialSetupProvider.notifier);
    if (!_initialized && !view.loading) {
      _initialized = true;
      final saved = c.savedProgress;
      _stage = saved == null
          ? 2
          : saved.amendmentDraftJson != null
              ? 2
              : saved.committed != null
                  ? saved.step.index.clamp(4, 6)
                  : saved.step.index.clamp(0, 3);
    }
    final ready = c.savedProgress;
    final securityReady = ready != null &&
        ready.securityChoice != OnboardingSecurityChoice.pending &&
        c.preparationReady;
    final protection = _stage == 6 && view.receipt != null
        ? ref
            .watch(setupProtectionStatusProvider('p${view.receipt!.profileId}'))
        : null;
    final blocked = _busy || view.loading || view.isSaving || view.needsReview;
    return SetupPresentation(
        child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop && !blocked && _stage > 0) {
                _run(() => _move(_stage - 1));
              }
            },
            child: Scaffold(
              appBar: AppBar(
                  title: const Text('Personal setup'),
                  automaticallyImplyLeading: false),
              body: SafeArea(
                  child: SingleChildScrollView(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                      child: Center(
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 640),
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SetupProgress(stage: _stage),
                                    if (view.loading)
                                      const SetupSurface(
                                          child: Text('Loading saved setup...'))
                                    else if (view.needsReview)
                                      SetupRecovery(
                                          view: view,
                                          retry: () => _run(c.restore),
                                          openProfile: (id) => _run(() async {
                                                final startup = await ref
                                                    .read(
                                                        onboardingRepositoryProvider)
                                                    .readStartupState();
                                                if (!mounted ||
                                                    !startup.existingProfileIds
                                                        .contains(id)) {
                                                  throw StateError(
                                                      'Profile unavailable.');
                                                }
                                                ref
                                                    .read(
                                                        setupRecoveryProfileProvider
                                                            .notifier)
                                                    .state = id;
                                                ref
                                                    .read(activeSpaceIdProvider
                                                        .notifier)
                                                    .state = null;
                                                ref
                                                    .read(
                                                        activeProfileIdProvider
                                                            .notifier)
                                                    .state = id;
                                                if (context.mounted) {
                                                  context.go('/dashboard');
                                                }
                                              }))
                                    else ...[
                                      if (_stage == 0)
                                        const SetupWelcomeContent(),
                                      if (_stage == 1) const LearningSteps(),
                                      if (_stage == 2 && view.receipt == null)
                                        ProfileSetupStep(
                                            view: view, controller: c),
                                      if (_stage == 3 &&
                                          view.receipt == null &&
                                          view.page != 2)
                                        MonthIncomeStep(
                                            view: view, controller: c),
                                      if (_stage == 3 &&
                                          view.receipt == null &&
                                          view.page == 2 &&
                                          view.review != null)
                                        SetupReview(
                                            review: view.review!,
                                            editProfile: () {
                                              c.goTo(0);
                                              setState(() => _stage = 2);
                                            },
                                            editMonthIncome: () => c.goTo(1)),
                                      if ((_stage == 2 || _stage == 3) &&
                                          view.receipt != null)
                                        SetupSurface(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              Text(
                                                  'Your financial details are saved',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge),
                                              Text(
                                                  '${view.draft.profile.name} ? ${monthLabel(view.receipt!.yearMonth)}'),
                                              const SizedBox(height: 12),
                                              const Text(
                                                  'Corrections keep the saved owner and require a new financial review.'),
                                              TextButton(
                                                  onPressed: () {
                                                    c.beginCorrection();
                                                    setState(() => _stage = 2);
                                                  },
                                                  child: const Text(
                                                      'Review or correct details'))
                                            ])),
                                      if (_stage == 4 &&
                                          view.receipt != null) ...[
                                        if (!c.preparationReady)
                                          SetupSurface(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                const Text(
                                                    'Prepare your categories and Medical directory before continuing. Saved finances will be reused.'),
                                                FilledButton(
                                                    onPressed: blocked
                                                        ? null
                                                        : () => _run(c.prepare),
                                                    child: const Text(
                                                        'Prepare required records'))
                                              ])),
                                        SecuritySetupStep(
                                            ownerId: view.receipt!.profileId,
                                            flowId: view.draft.flowId),
                                      ],
                                      if (_stage == 5)
                                        const LearningSteps(overview: true),
                                      if (_stage == 6 && view.receipt != null)
                                        SetupSurface(
                                            highlight: true,
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      size: 48,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                      'Ready for your first month',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineMedium),
                                                  const SizedBox(height: 16),
                                                  Text(view.draft.profile.name,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge),
                                                  Text(
                                                      'Accounting currency: ${view.draft.profile.currency?.name.toUpperCase()}'),
                                                  Text(
                                                      'Your month: ${monthLabel(view.receipt!.yearMonth)}'),
                                                  Text(view.draft
                                                              .incomeChoice ==
                                                          OnboardingIncomeChoice
                                                              .none
                                                      ? 'No income yet - you can add it later.'
                                                      : '${view.receipt!.sourceIds.length} real income source(s) saved.'),
                                                  Text(protection == null ||
                                                          protection.isLoading
                                                      ? 'Checking actual protection...'
                                                      : protection.hasError
                                                          ? 'Protection could not be checked. Return to Security and retry.'
                                                          : switch (protection
                                                              .requireValue) {
                                                              SetupProtection
                                                                    .configured =>
                                                                'App PIN configured; phone verification required.',
                                                              SetupProtection
                                                                    .notConfigured =>
                                                                'Phone verification required; no extra app PIN.',
                                                              SetupProtection
                                                                    .incomplete =>
                                                                'Protection needs review. Return to Security.'
                                                            }),
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                      'Open your personal Dashboard to complete setup. Viewing this page does not move money or create a shared space.')
                                                ])),
                                      const SizedBox(height: 8),
                                      Semantics(
                                          liveRegion: true,
                                          child: Text(
                                              _busy
                                                  ? 'Working...'
                                                  : view.saveStatus,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall)),
                                      if (view.saveStatus
                                          .startsWith('Could not save'))
                                        TextButton(
                                            onPressed: blocked
                                                ? null
                                                : () => _run(() async {
                                                      await c.flush();
                                                    }),
                                            child: const Text('Retry saving')),
                                      if (_error ?? view.error
                                          case final String error)
                                        SetupSurface(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              Semantics(
                                                  liveRegion: true,
                                                  child: Text(error)),
                                              TextButton(
                                                  onPressed: blocked
                                                      ? null
                                                      : () => _run(
                                                          _failedAction ??
                                                              _continue),
                                                  child: const Text(
                                                      'Retry this step')),
                                              TextButton(
                                                  onPressed: _busy
                                                      ? null
                                                      : () => _run(() async {
                                                            final confirmed =
                                                                await confirmDraftRemoval(
                                                                    context,
                                                                    title:
                                                                        'Review the saved setup?',
                                                                    message:
                                                                        'Replace unsaved screen entries with the saved version? Your saved financial records will be retained.');
                                                            if (confirmed) {
                                                              await c.restore();
                                                              if (mounted) {
                                                                setState(() =>
                                                                    _initialized =
                                                                        false);
                                                              }
                                                            }
                                                          }),
                                                  child: const Text(
                                                      'Review saved setup'))
                                            ])),
                                      const SizedBox(height: 20),
                                      FilledButton(
                                          key: const Key('guidedContinue'),
                                          onPressed: blocked ||
                                                  (_stage == 4 &&
                                                      !securityReady) ||
                                                  (_stage == 6 &&
                                                      (protection == null ||
                                                          protection
                                                              .isLoading ||
                                                          protection.hasError ||
                                                          protection
                                                                  .valueOrNull ==
                                                              SetupProtection
                                                                  .incomplete))
                                              ? null
                                              : () => _run(_continue),
                                          style: FilledButton.styleFrom(
                                              padding: const EdgeInsets.all(16),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16))),
                                          child: Text(
                                              _stage == 6
                                                  ? 'Open my Dashboard'
                                                  : _stage == 3 &&
                                                          view.page == 2 &&
                                                          view.receipt == null
                                                      ? 'Confirm financial details'
                                                      : 'Continue',
                                              textAlign: TextAlign.center)),
                                      if (_stage == 1 || _stage == 5)
                                        TextButton(
                                            onPressed: blocked
                                                ? null
                                                : () => _run(() =>
                                                    _move(_stage == 1 ? 2 : 6)),
                                            child: const Text(
                                                'Skip explanations')),
                                      if (_stage > 0)
                                        TextButton(
                                            onPressed: blocked
                                                ? null
                                                : () => _run(() async {
                                                      if (_stage == 3 &&
                                                          view.page == 2 &&
                                                          view.receipt ==
                                                              null) {
                                                        c.goTo(1);
                                                        return;
                                                      }
                                                      await _move(_stage - 1);
                                                    }),
                                            child: const Text('Back')),
                                    ],
                                  ]))))),
            )));
  }
}
