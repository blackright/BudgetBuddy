import 'package:isar/isar.dart';

part 'previous_onboarding_settings.g.dart';

/// Exact pre-onboarding field shape for a real native schema reopen.
@collection
@Name('AppSettings')
class PreviousOnboardingSettings {
  Id id = Isar.autoIncrement;
  bool transferToggle = false;
  String? decimalPreferences;
  late DateTime createdAt;
  late DateTime updatedAt;
}
