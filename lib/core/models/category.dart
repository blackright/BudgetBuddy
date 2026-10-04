import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String categoryId; // Used as the foreign key in Expense

  late String name;
  late String emoji;
  late int colorValue;
  bool isDefault = false;

  Category({
    this.id = Isar.autoIncrement,
    required this.categoryId,
    required this.name,
    required this.emoji,
    required this.colorValue,
    this.isDefault = false,
  });
}
