import 'package:isar/isar.dart';

part 'app_settings.g.dart';

/// Local category eligibility, distinct from onboarding completion.
enum StarterCategoryPolicy { preserveExisting, unifiedPending, unifiedSeeded }

@collection
class AppSettings {
  Id id = Isar.autoIncrement;

  bool transferToggle = false;

  String? decimalPreferences;

  /// Versioned local progress. Never synced and never contains auth secrets.
  String? onboardingStateJson;

  /// Stored as a string so unsupported future values are not misread as fresh.
  String? starterCategoryPolicy;

  late DateTime createdAt;
  late DateTime updatedAt;
}
