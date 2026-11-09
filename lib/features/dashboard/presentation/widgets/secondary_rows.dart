import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/budget_context_provider.dart';
import '../../../vault/providers/vault_providers.dart';
import '../dashboard_copy.dart';
import '../dashboard_view_state.dart';
import 'next_steps_sheet.dart';
import 'onboarding_guidance_card.dart';

/// Two square action cards followed by the full-width Next step card.
class SecondaryRows extends ConsumerWidget {
  const SecondaryRows({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShared = ref.watch(budgetContextProvider).isShared;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        const cardHeight = 108.0;
        final cardWidth = (constraints.maxWidth - gap) / 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isShared) ...[
                  _SavingsCard(width: cardWidth, height: cardHeight),
                  const SizedBox(width: gap),
                ],
                _AnalyticsCard(width: cardWidth, height: cardHeight),
              ],
            ),
            const _NextStepCard(),
          ],
        );
      },
    );
  }
}

class _SavingsCard extends ConsumerWidget {
  const _SavingsCard({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vault = ref.watch(vaultProvider);
    final review = ref.watch(vaultReviewMessageProvider);
    final row = DashboardSavingsRow.from(
      vault: vault,
      reviewMessage: review,
    );
    final scheme = Theme.of(context).colorScheme;

    return _ActionCard(
      key: const Key('savingsCard'),
      width: width,
      height: height,
      icon: Icons.savings_outlined,
      label: DashboardCopy.savings,
      value: row.message,
      valueColor: row.isValue ? scheme.onSurface : scheme.onSurfaceVariant,
      trailing: row.showRetry
          ? IconButton(
              key: const Key('savingsRetry'),
              tooltip: DashboardCopy.retry,
              onPressed: () => ref.invalidate(vaultProvider),
              icon: const Icon(Icons.refresh, size: 18),
            )
          : null,
      onTap: () => context.push('/vault'),
      semanticLabel: 'Savings, ${row.message}, open vault',
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _ActionCard(
      key: const Key('analyticsCard'),
      width: width,
      height: height,
      icon: Icons.insights_outlined,
      label: DashboardCopy.analytics,
      onTap: () => context.go('/analytics'),
      semanticLabel: 'Analytics, open analytics',
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    super.key,
    required this.width,
    required this.height,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.semanticLabel,
    this.value,
    this.valueColor,
    this.trailing,
  });

  final double width;
  final double height;
  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;
  final Widget? trailing;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        width: width,
        height: height,
        child: Material(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 19, color: scheme.primary),
                      ),
                      const Spacer(),
                      if (trailing != null) trailing!,
                    ],
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            if (value != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                value!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          valueColor ?? scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NextStepCard extends ConsumerWidget {
  const _NextStepCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingGuidanceProvider);
    if (state.hasError) {
      return _RectangleActionCard(
        key: const Key('nextStepCard'),
        icon: Icons.warning_amber_outlined,
        eyebrow: DashboardCopy.nextStep,
        title: DashboardCopy.couldNotLoad,
        trailing: IconButton(
          key: const Key('nextStepRetry'),
          tooltip: DashboardCopy.retry,
          onPressed: () => retryOnboardingGuidance(ref),
          icon: const Icon(Icons.refresh, size: 18),
        ),
        onTap: () => retryOnboardingGuidance(ref),
      );
    }
    if (state.isLoading && !state.hasValue) {
      return const SizedBox.shrink();
    }

    final suggestions = state.valueOrNull ?? const <SetupSuggestion>[];
    final actionable = suggestions
        .where((suggestion) => !_isOptionalExploration(suggestion.route))
        .toList();
    if (actionable.isEmpty) return const SizedBox.shrink();
    final ordered = orderedSetupSuggestions(actionable);
    final primary = ordered.first;
    final more = ordered.length - 1;

    return _RectangleActionCard(
      key: const Key('nextStepCard'),
      icon: primary.icon,
      eyebrow: DashboardCopy.nextStep,
      title: primary.title,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (more > 0)
            TextButton(
              key: const Key('nextStepMore'),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => NextStepsSheet.show(
                context,
                suggestions: ordered,
                onSelected: (suggestion) =>
                    openSetupSuggestion(context, ref, suggestion),
              ),
              child: Text(
                '+$more more',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      onTap: () => openSetupSuggestion(context, ref, primary),
    );
  }
}

class _RectangleActionCard extends StatelessWidget {
  const _RectangleActionCard({
    super.key,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 19, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eyebrow,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

bool _isOptionalExploration(String route) =>
    route == '/medical' || route == '/spaces';

/// Stable ordering shared by the row and the full-list sheet.
List<SetupSuggestion> orderedSetupSuggestions(
  Iterable<SetupSuggestion> suggestions,
) {
  final list = suggestions.toList();
  final indexed = <({int index, SetupSuggestion suggestion})>[
    for (var index = 0; index < list.length; index++)
      (index: index, suggestion: list[index]),
  ]..sort((a, b) {
      final byPriority = DashboardSetupStep.priorityFor(
        a.suggestion.route,
      ).compareTo(DashboardSetupStep.priorityFor(b.suggestion.route));
      return byPriority != 0 ? byPriority : a.index.compareTo(b.index);
    });
  return [for (final entry in indexed) entry.suggestion];
}
