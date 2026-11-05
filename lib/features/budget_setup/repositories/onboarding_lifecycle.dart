import 'package:isar/isar.dart';
import '../../../core/models/app_settings.dart';
import '../../../core/database/schema_migrations.dart';
import '../domain/onboarding_state.dart';

/// Caller owns the already-confirmed profile-deletion transaction. Never infer
/// ownership from malformed data or clear another owner's/global settings.
Future<void> pruneDeletedProfileSetupInTxn(Isar isar, int profileId) async {
  final settings = await isar.appSettings.get(1);
  final raw = settings?.onboardingStateJson;
  if (settings != null && raw != null) {
    OnboardingState? progress;
    try {
      progress = OnboardingState.decode(raw);
    } on OnboardingStateException {
      // Preserve unreadable evidence. Existing recovery handles it explicitly.
    }
    if (progress?.committed?.profileId == profileId) {
      settings.onboardingStateJson = null;
      settings.updatedAt = DateTime.now();
      await isar.appSettings.put(settings);
    }
  }
  final marker = await isar.schemaMigrationStamps
      .filter()
      .keyEqualTo('onboarding_pending_owner:$profileId')
      .findFirst();
  if (marker != null) await isar.schemaMigrationStamps.delete(marker.id);
}
