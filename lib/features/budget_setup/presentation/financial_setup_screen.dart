import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/budget_setup_provider.dart';
import 'widgets/profile_setup_step.dart';
import 'widgets/month_income_step.dart';
import 'widgets/setup_review.dart';
import 'widgets/setup_form_components.dart';
import 'widgets/setup_recovery.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/database/isar_helper.dart';
import '../providers/onboarding_readiness_provider.dart';
import '../repositories/onboarding_repository.dart';
import 'widgets/security_setup_step.dart';

final _showSetupSecurityProvider =
    StateProvider.family<bool, int>((ref, owner) => false);

/// Financial-slice host. Only the shared inactive rollout gate selects this;
/// it does not add a route, bypass authentication or activate a new owner.
class FinancialSetupScreen extends ConsumerWidget {
  const FinancialSetupScreen({super.key});
  Future<void> _reviewSaved(
      BuildContext context, FinancialSetupController controller) async {
    final confirmed = await confirmDraftRemoval(context,
        title: 'Review the saved version?',
        message:
            'This reloads saved setup and replaces the unsaved entries on this screen. Keep entries if you want to copy or review them first.');
    if (confirmed) {
      await controller.restore();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(financialSetupProvider);
    final controller = ref.read(financialSetupProvider.notifier);
    const labels = ['Profile', 'Month & income', 'Review'];
    return Scaffold(
        appBar: AppBar(
            title: const Text('Personal setup'),
            automaticallyImplyLeading: false),
        body: AbsorbPointer(
            absorbing: view.isSaving || view.loading,
            child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Center(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (view.loading)
                                const SetupSurface(
                                    child: Text('Loading saved setup...')),
                              if (view.needsReview)
                                SetupRecovery(
                                    view: view,
                                    retry: () => controller.restore(),
                                    openProfile: (id) async {
                                      final available = await ref
                                          .read(onboardingRepositoryProvider)
                                          .readStartupState();
                                      if (!available.existingProfileIds
                                              .contains(id) ||
                                          !context.mounted) {
                                        return;
                                      }
                                      final profile = await IsarHelper
                                          .instance.userProfiles
                                          .get(id);
                                      if (profile == null || !context.mounted) {
                                        return;
                                      }
                                      ref
                                          .read(activeSpaceIdProvider.notifier)
                                          .state = null;
                                      ref
                                          .read(
                                              activeProfileIdProvider.notifier)
                                          .state = id;
                                      context.go('/dashboard');
                                    }),
                              if (!view.loading && !view.needsReview) ...[
                                Semantics(
                                    liveRegion: true,
                                    child: Row(children: [
                                      Icon(
                                          view.saveStatus ==
                                                  'Saved on this device'
                                              ? Icons.check_circle_outline
                                              : Icons.save_outlined,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(view.saveStatus)),
                                      if (view.saveStatus
                                          .startsWith('Could not save'))
                                        TextButton(
                                            onPressed: () => controller.flush(),
                                            child: const Text('Retry')),
                                    ])),
                                if (view.saveStatus
                                        .contains('changed elsewhere') ||
                                    view.saveStatus
                                        .contains('records need review'))
                                  TextButton(
                                      onPressed: () =>
                                          _reviewSaved(context, controller),
                                      child:
                                          const Text('Review saved version')),
                                const SizedBox(height: 12),
                                Semantics(
                                    label:
                                        'Financial details, step ${view.page + 1} of 3',
                                    child: Wrap(
                                        spacing: 8,
                                        runSpacing: 6,
                                        children: List.generate(
                                            3,
                                            (i) => Chip(
                                                avatar: Icon(
                                                    i < view.page
                                                        ? Icons.check_rounded
                                                        : Icons.circle,
                                                    size: 16,
                                                    color: i == view.page
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                        : null),
                                                label: Text(labels[i]),
                                                backgroundColor: i == view.page
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer
                                                    : null)))),
                                const SizedBox(height: 20),
                                if (view.error != null)
                                  SetupSurface(
                                      child: Semantics(
                                          liveRegion: true,
                                          child: Text(view.error!,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error)))),
                                if (view.error != null && view.receipt == null)
                                  TextButton(
                                      onPressed: () =>
                                          _reviewSaved(context, controller),
                                      child: const Text('Review saved setup')),
                                if (view.errors['setup'] != null)
                                  Text(view.errors['setup']!,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error)),
                                if (view.receipt != null)
                                  SetupSurface(
                                      highlight: true,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.check_circle_outline,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                size: 40),
                                            const SizedBox(height: 12),
                                            Text('Financial details saved',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall),
                                            const SizedBox(height: 10),
                                            const Text(
                                                'Your profile, month and income are recorded. The rest of setup still needs to finish.'),
                                            const SizedBox(height: 16),
                                            Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  OutlinedButton.icon(
                                                      onPressed: controller
                                                          .beginCorrection,
                                                      icon: const Icon(
                                                          Icons.edit_outlined),
                                                      label: const Text(
                                                          'Review or correct details')),
                                                  FilledButton.tonalIcon(
                                                      onPressed: controller
                                                              .preparationReady
                                                          ? null
                                                          : () => controller
                                                              .prepare(),
                                                      icon: const Icon(
                                                          Icons.refresh),
                                                      label: Text(controller
                                                              .preparationReady
                                                          ? 'Required records prepared'
                                                          : 'Prepare remaining setup')),
                                                ])
                                          ])),
                                if (view.receipt != null) ...[
                                  TextButton.icon(
                                      onPressed: () => ref
                                          .read(_showSetupSecurityProvider(
                                                  view.receipt!.profileId)
                                              .notifier)
                                          .state = true,
                                      icon: const Icon(Icons.security_outlined),
                                      label: const Text('Protection options')),
                                  if (ref.watch(_showSetupSecurityProvider(
                                      view.receipt!.profileId)))
                                    SecuritySetupStep(
                                        ownerId: view.receipt!.profileId,
                                        flowId: view.draft.flowId),
                                ],
                                if (view.receipt == null && view.page == 0)
                                  ProfileSetupStep(
                                      view: view, controller: controller),
                                if (view.receipt == null && view.page == 1)
                                  MonthIncomeStep(
                                      view: view, controller: controller),
                                if (view.receipt == null &&
                                    view.page == 2 &&
                                    view.review != null)
                                  SetupReview(
                                      review: view.review!,
                                      editProfile: () => controller.goTo(0),
                                      editMonthIncome: () =>
                                          controller.goTo(1)),
                              ],
                            ]))))),
        bottomNavigationBar: view.receipt != null ||
                view.loading ||
                view.needsReview
            ? null
            : SafeArea(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: Row(children: [
                      if (view.page > 0) ...[
                        IconButton(
                            tooltip: 'Back',
                            onPressed: view.isSaving
                                ? null
                                : () => controller.goTo(view.page - 1),
                            icon: const Icon(Icons.arrow_back)),
                        const SizedBox(width: 12)
                      ],
                      Expanded(
                          child: FilledButton(
                              key: const Key('financialContinue'),
                              onPressed: view.isSaving
                                  ? null
                                  : view.page == 2
                                      ? (controller.canSave
                                          ? controller.save
                                          : null)
                                      : controller.next,
                              child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  child: view.isSaving
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                              if (!MediaQuery
                                                  .disableAnimationsOf(context))
                                                const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2)),
                                              if (!MediaQuery
                                                  .disableAnimationsOf(context))
                                                const SizedBox(width: 12),
                                              const Flexible(
                                                  child:
                                                      Text('Saving setup...'))
                                            ])
                                      : Text(view.page == 2
                                          ? 'Save financial details'
                                          : 'Continue'))))
                    ]))));
  }
}
