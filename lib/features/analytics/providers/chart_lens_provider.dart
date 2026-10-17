import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/active_space_provider.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../spaces/providers/spaces_providers.dart';

/// Which wallet the Analytics charts are describing (data-model §4.1).
///
/// `personal` means the active profile, `shared` means the active space. This is
/// transient UI state — it is never persisted (FR-014).
enum ChartLens { personal, shared }

/// The active lens (FR-007).
///
/// It is *derived* from the one active context the whole app already shares, so
/// the lens can never disagree with `budgetContextProvider` (contract
/// chart-ui.md §3): you can only ever be looking at the wallet the app is in.
final chartLensProvider = Provider<ChartLens>((ref) {
  return ref.watch(budgetContextProvider).isShared
      ? ChartLens.shared
      : ChartLens.personal;
});

/// What happened when a lens switch was requested.
enum ChartLensSwitchResult {
  /// The active context now matches the requested lens.
  switched,

  /// `shared` was requested but the profile belongs to no space — the caller
  /// should show a friendly "create or join a space" prompt (contract §3).
  noSpace,
}

/// Switches the active context to match [lens], returning the outcome.
typedef ChartLensSwitcher = ChartLensSwitchResult Function(ChartLens lens);

/// The action behind the lens switch, exposed as a provider so both the widget
/// and its tests drive one implementation.
///
/// It reuses the same router marker the [SpaceSwitcher] already writes
/// (`activeSpaceIdProvider`), so a lens change re-derives every dependent series
/// in the same frame and no value from the previous lens can linger (SC-004).
final chartLensSwitcherProvider = Provider<ChartLensSwitcher>((ref) {
  return (lens) {
    switch (lens) {
      case ChartLens.personal:
        ref.read(activeSpaceIdProvider.notifier).state = null;
        return ChartLensSwitchResult.switched;
      case ChartLens.shared:
        if (ref.read(activeSpaceIdProvider) != null) {
          return ChartLensSwitchResult.switched;
        }
        final spaces = ref.read(mySpacesProvider).value ?? const [];
        if (spaces.isEmpty) return ChartLensSwitchResult.noSpace;
        ref.read(activeSpaceIdProvider.notifier).state = spaces.first.id;
        return ChartLensSwitchResult.switched;
    }
  };
});
