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

  /// Emoji avatar shown next to the profile in switchers (FR-001). Empty means
  /// the default is rendered.
  String avatar = '';

  @enumerated
  late PrimaryCurrency primaryCurrency;

  late double monthlyAvailableAmount;

  /// Profile-wide take-home pay applied to any month without an override
  /// (FR-001, FR-002). Must be >= 0.
  double defaultNetSalary = 0.0;

  late DateTime createdAt;

  late DateTime updatedAt;

  /// When the profile was last used (context switch or visit). Updated on
  /// selection so a profile switcher can sort by recency (FR-001, context-router
  /// §3).
  DateTime? lastActiveAt;

  @enumerated
  AppFontFamily fontFamily = AppFontFamily.system;

  /// Follows the system by default so a fresh install matches the user's
  /// operating-system preference until they opt into one mode (T059/T061).
  @enumerated
  AppThemeMode themeMode = AppThemeMode.system;
}
