import 'package:isar/isar.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/merchant.dart';
import '../../../core/providers/budget_context_provider.dart';
import '../../spaces/repositories/space_write_guard.dart';

class ExpenseSearchRepository {
  const ExpenseSearchRepository(this.db);
  final Isar db;
  Future<void> authorize(ContextRef scope, int? actor) async {
    if (actor == null) throw StateError('Select an acting profile.');
    if (scope.isShared) {
      final member = await SpaceWriteGuard(db).memberOf(scope.spaceId!, actor);
      if (member == null || member.revokedAt != null) {
        throw StateError('Search is unavailable for this space.');
      }
    } else if (actor != scope.profileId) {
      throw StateError('Select the owning personal profile.');
    }
  }

  Stream<List<Expense>> watch(ContextRef scope, int? actor) async* {
    await authorize(scope, actor);
    yield* (scope.isShared
            ? db.expenses.filter().sharedSpaceIdEqualTo(scope.spaceId)
            : db.expenses
                .filter()
                .sharedSpaceIdIsNull()
                .profileIdEqualTo(scope.profileId!))
        .watch(fireImmediately: true);
  }

  Stream<List<Merchant>> merchants(ContextRef scope, int? actor) async* {
    await authorize(scope, actor);
    yield* (scope.isShared
            ? db.merchants.filter().sharedSpaceIdEqualTo(scope.spaceId)
            : db.merchants
                .filter()
                .sharedSpaceIdIsNull()
                .profileIdEqualTo(scope.profileId))
        .watch(fireImmediately: true);
  }
}
