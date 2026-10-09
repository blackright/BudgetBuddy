import 'package:isar/isar.dart';

part 'user_profile.g.dart';

enum PrimaryCurrency { huf, usd, cad, eur }

enum AppFontFamily { system, roboto, inter, openSans }

/// The app's theme preference: follow the operating system, or force one mode.
enum AppThemeMode { system, light, dark }

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  late String name;

  @enumerated
  late PrimaryCurrency primaryCurrency;

  late double monthlyAvailableAmount;

  /// Profile-wide take-home pay applied to any month without an override
  /// (FR-001, FR-002). Must be >= 0.
  double defaultNetSalary = 0.0;

  late DateTime createdAt;

  late DateTime updatedAt;

  @enumerated
  AppFontFamily fontFamily = AppFontFamily.system;

  /// Follows the system by default so a fresh install matches the user's
  /// operating-system preference until they opt into one mode (T059/T061).
  @enumerated
  AppThemeMode themeMode = AppThemeMode.system;
}
