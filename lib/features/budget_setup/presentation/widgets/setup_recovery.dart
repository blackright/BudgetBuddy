import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/active_profile_provider.dart';
import '../../providers/budget_setup_provider.dart';
import 'setup_form_components.dart';

/// No destructive reset and no automatic owner reassignment. Selection is
/// explicit and goes through the application's existing authentication gate.
class SetupRecovery extends ConsumerWidget {
  const SetupRecovery(
      {super.key,
      required this.view,
      required this.retry,
      required this.openProfile});
  final FinancialSetupView view;
  final VoidCallback retry;
  final ValueChanged<int> openProfile;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles =
        view.existingProfileIds.isEmpty ? null : ref.watch(profilesProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SetupSurface(
          highlight: true,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.shield_outlined,
                size: 44, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text('Let’s review your saved setup',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            const Text(
                'Some saved setup information is unavailable or has changed. Your records have been kept. We will not create replacement money or attach this setup to another profile.'),
            const SizedBox(height: 20),
            FilledButton.icon(
                onPressed: retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry reading setup')),
          ])),
      if (view.existingProfileIds.isNotEmpty)
        SetupSurface(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Use an existing profile',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
              'Open a separate existing profile with its normal protection. This does not repair or reassign the unfinished setup.'),
          const SizedBox(height: 12),
          for (final p in profiles?.valueOrNull ?? [])
            if (view.existingProfileIds.contains(p.id))
              OutlinedButton.icon(
                  onPressed: () => openProfile(p.id),
                  icon: const Icon(Icons.person_outline),
                  label: Text('Open ${p.name}')),
          if (profiles?.isLoading == true)
            const Text('Loading available profiles...'),
          if (profiles?.hasError == true)
            TextButton(
                onPressed: () => ref.invalidate(profilesProvider),
                child: const Text('Retry loading profiles')),
        ])),
    ]);
  }
}
