import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'active_profile_provider.dart';
import 'active_space_provider.dart';
import 'selected_month_provider.dart';

/// The single route every scoped query and engine provider resolves through
/// (FR-004, context-router §1–2).
///
/// Exactly one of [profileId] / [spaceId] is set; `isShared` is true exactly
/// when a space is active. Resolving elsewhere is a contract violation and the
/// app refuses to construct such a context.
class ContextRef {
  const ContextRef._({
    required this.yearMonth,
    this.profileId,
    this.spaceId,
  }) : assert(
          (profileId == null) != (spaceId == null),
          'ContextRef must resolve to exactly one profile or space',
        );

  /// A personal context: the selected personal profile.
  factory ContextRef.personal({
    required int profileId,
    required String yearMonth,
  }) =>
      ContextRef._(profileId: profileId, yearMonth: yearMonth);

  /// A shared context: the selected shared space.
  factory ContextRef.shared({
    required int spaceId,
    required String yearMonth,
  }) =>
      ContextRef._(spaceId: spaceId, yearMonth: yearMonth);

  final String yearMonth;
  final int? profileId;
  final int? spaceId;

  bool get isShared => spaceId != null;

  /// The single discriminating value scoped queries filter on.
  ///
  /// Personal rows carry a `profileId`, shared rows a `sharedSpaceId`; zero in
  /// a shared context is the profile id a personal query filters by.
  int get profileKey => profileId ?? 0;

  @override
  String toString() =>
      'ContextRef(${isShared ? 'space=$spaceId' : 'profile=$profileId'}, '
      '$yearMonth)';
}

/// The active context, derived synchronously from the selection markers and the
/// selected month (context-router §2).
///
/// A single `activeSpaceId` (or `activeProfileId`) write re-derives every
/// dependent stream in the same frame — no month reload, no stored money write
/// (FR-004, SC-002). Falls back to the lowest-id personal profile until the
/// user explicitly picks one.
final budgetContextProvider = Provider<ContextRef>((ref) {
  final yearMonth = ref.watch(selectedYearMonthProvider);
  final spaceId = ref.watch(activeSpaceIdProvider);
  if (spaceId != null) {
    return ContextRef.shared(spaceId: spaceId, yearMonth: yearMonth);
  }
  final profileId = ref.watch(activeProfileIdProvider);
  if (profileId != null) {
    return ContextRef.personal(profileId: profileId, yearMonth: yearMonth);
  }
  final fallback = ref.watch(activeProfileProvider).value;
  if (fallback == null) {
    throw StateError('budgetContextProvider has no profile to resolve to');
  }
  return ContextRef.personal(profileId: fallback.id, yearMonth: yearMonth);
});
