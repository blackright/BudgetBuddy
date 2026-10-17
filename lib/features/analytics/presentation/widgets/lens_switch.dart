import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  void _select(BuildContext context, WidgetRef ref, ChartLens lens) {
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
