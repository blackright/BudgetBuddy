import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/active_profile_provider.dart';
import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';

/// A visible, context-aware Analytics placeholder (US6, FR-015, SC-008).
///
/// Analytics ships as its own feature later; this card reserves the dashboard
/// slot in both contexts and always follows the active context. It deliberately
/// computes nothing: it reads the active [ContextRef] and the context's display
/// name, and shows no financial figure, so no number can linger after a switch.
class AnalyticsPlaceholderCard extends ConsumerWidget {
  const AnalyticsPlaceholderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctx = ref.watch(budgetContextProvider);
    final scope = ctx.isShared ? 'Shared' : 'Personal';
    final contextId =
        ctx.isShared ? 'shared-${ctx.spaceId}' : 'personal-${ctx.profileId}';

    final name = ctx.isShared
        ? ref.watch(activeSpaceProvider).valueOrNull?.name
        : ref.watch(activeProfileProvider).valueOrNull?.name;
    final where = (name == null || name.isEmpty)
        ? (ctx.isShared ? 'this space' : 'this profile')
        : name;

    return Card(
      key: const Key('analyticsPlaceholder'),
      elevation: 1,
      child: ListTile(
        key: ValueKey('analytics-$contextId'),
        leading: const Icon(Icons.insights_outlined),
        title: const Text('Analytics'),
        subtitle: Text(
          '$scope insights for $where — coming soon',
          key: const Key('analyticsContextLabel'),
        ),
      ),
    );
  }
}
