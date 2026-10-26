import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = Isar.autoIncrement;

  bool transferToggle = false;

  String? decimalPreferences;

  late DateTime createdAt;
  late DateTime updatedAt;
}
