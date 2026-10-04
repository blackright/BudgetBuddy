import 'package:isar/isar.dart';

part 'user_profile.g.dart';

enum PrimaryCurrency { huf, usd, cad, eur }

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  late String name;

  @enumerated
  late PrimaryCurrency primaryCurrency;

  late double monthlyAvailableAmount;

  late DateTime createdAt;

  late DateTime updatedAt;
}
