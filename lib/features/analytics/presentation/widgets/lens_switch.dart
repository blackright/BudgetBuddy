import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/presentation/widgets/spaces_dropdown.dart';
import '../../../../shared/presentation/providers/context_navigation_provider.dart';
import '../../../../shared/presentation/financial_feedback.dart';

import '../../providers/chart_lens_provider.dart';

/// The Personal / Shared lens switch that sits at the top of the Analytics
/// screen (FR-007, contract chart-ui.md §3).
///
/// Picking a side moves the app's single active context, so every chart on the
/// screen re-derives at once (SC-004). The selected pointer is read back from
/// that same context, so the switch can never show a wallet the app is not in.
class LensSwitch extends ConsumerWidget {
  const LensSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lens = ref.watch(chartLensProvider);

    return SegmentedButton<ChartLens>(
      key: const Key('chartLensSwitch'),
      segments: const [
        ButtonSegment(
          value: ChartLens.personal,
          label: Text('Personal'),
          icon: Icon(Icons.person_outline),
        ),
        ButtonSegment(
          value: ChartLens.shared,
          label: Text('Shared'),
          icon: Icon(Icons.group_outlined),
        ),
      ],
      selected: {lens},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => _select(context, ref, selection.first),
    );
  }

  /// Moves the active context to [lens], or says so nicely when there is no
  /// space to move into (contract chart-ui.md §3).
  void _select(BuildContext context, WidgetRef ref, ChartLens lens) async {
    final router = GoRouter.maybeOf(context);
    if (router != null &&
        router.routeInformationProvider.value.uri.path == '/analytics') {
      if (lens == ref.read(chartLensProvider)) return;
      if (lens == ChartLens.shared) {
        await showContextChooser(context, ref);
        return;
      }
      try {
        await ref.read(selectNavigationContextProvider)(null);
        if (context.mounted) {
          router.go('/dashboard');
          showFinancialFeedback(context, 'Switched to Personal.');
        }
      } catch (_) {
        if (context.mounted) {
          showFinancialFeedback(context, 'Could not switch. Reopen Spaces.',
              kind: FinancialFeedbackKind.error);
        }
      }
      return;
    }
    final result = ref.read(chartLensSwitcherProvider)(lens);
    if (result == ChartLensSwitchResult.noSpace) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          content: Text('Create or join a space to see shared charts.'),
        ),
      );
    }
  }
}
