import 'package:isar/isar.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/models/monthly_budget.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/database/schema_migrations.dart';
import 'onboarding_state.dart';

/// Reads transaction-current local evidence. An independent per-owner marker
/// keeps corrupt progress from releasing its owner or pausing unrelated owners.
Future<bool> isPendingSetupOwner(Isar db, int profileId) async {
  final raw = (await db.appSettings.get(1))?.onboardingStateJson;
  if (raw != null) {
    try {
      final state = OnboardingState.decode(raw);
      if (state.stage == OnboardingStage.completed &&
          state.committed?.profileId == profileId) {
        return false;
      }
    } on OnboardingStateException {
      /* Independent owner guard remains authoritative. */
    }
  }
  if (await db.schemaMigrationStamps
          .filter()
          .keyEqualTo('onboarding_pending_owner:$profileId')
          .count() >
      0) {
    return true;
  }
  if (raw == null) return false;
  try {
    final state = OnboardingState.decode(raw);
    return state.stage != OnboardingStage.completed &&
        state.committed?.profileId == profileId;
  } on OnboardingStateException {
    // New commits also write an independent per-owner guard atomically. Thus
    // malformed progress cannot release that owner or suspend unrelated ones.
    return false;
  }
}

Future<bool> hasEstablishedSealBudget(Isar db, String current) async {
  var pendingOnly = false;
  for (final b in await db.monthlyBudgets.where().findAll()) {
    if (b.yearMonth.compareTo(current) > 0) continue;
    if (b.sharedSpaceId != null ||
        b.profileId == null ||
        (b.profileId != null && !await isPendingSetupOwner(db, b.profileId!))) {
      return true;
    }
    pendingOnly = true;
  }
  return !pendingOnly;
}

Future<bool> preserveAutomaticSetupMonth(Isar db,
    {required int? profileId,
    required bool isShared,
    required bool allowDraft}) async {
  if (isShared) return false;
  if (profileId != null && await isPendingSetupOwner(db, profileId)) {
    return true;
  }
  if (!allowDraft || await db.userProfiles.count() != 0) return false;
  final raw = (await db.appSettings.get(1))?.onboardingStateJson;
  if (raw == null) return false;
  try {
    return OnboardingState.decode(raw).stage == OnboardingStage.draft;
  } on OnboardingStateException {
    return false;
  }
}
