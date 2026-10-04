import 'package:isar/isar.dart';

part 'reimbursement.g.dart';

@collection
class Reimbursement {
  Id id = Isar.autoIncrement;

  @Index()
  late int expenseId;

  late double amount;

  late DateTime date;
}
