import '../../../core/models/transfer.dart';
import '../../../core/services/fx_booking_service.dart';
import '../../spaces/repositories/space_write_guard.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/models/currency_code.dart';
import '../../../core/services/audit_financial_state.dart';
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/schema_migrations.dart';
import '../../../core/models/audit_event.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/month_end_run.dart';
import '../../../core/models/allocation.dart';
import '../../../core/models/identity.dart';
import '../../../core/models/shared_space.dart';
import '../../../core/services/audit_hash_service.dart';
import '../../../core/services/audit_verify_service.dart';
import '../../expenses/models/reimbursement.dart';
import '../../sync/domain/sync_codec.dart';
import '../../sync/repositories/sync_recorder.dart';
import '../../../core/models/context_kind.dart';

/// All writes run inside the caller's financial transaction. No edit/delete API.
class AuditRepository {
  AuditRepository(this.isar, {this.recorder, this.actorId});
  final Isar isar;
  final SyncRecorder? recorder;
  final int? actorId;

  Future<Map<String, dynamic>?> snapshot<T>(
      IsarCollection<T> collection, int id) async {
    final query = collection.buildQuery<T>(
        filter: FilterCondition.equalTo(property: 'id', value: id));
    final rows = await query.exportJson();
    return rows.firstOrNull == null
        ? null
        : (Map<String, dynamic>.of(rows.first)..remove('auditEventId'));
  }

  Future<int> put<T>(IsarCollection<T> collection, T value,
      {required int id, required String type, bool derived = true}) async {
    if (value is Expense) await FxBookingService(isar).prepareExpense(value);
    if (value is Reimbursement) {
      await FxBookingService(isar).prepareRefund(value);
    }
    final scope = derived ? AuditFinancialScope.of(value as Object) : null;
    final financialBefore =
        scope == null ? null : await auditFinancialState(isar, scope);
    final before = await snapshot(collection, id);
    final saved = await collection.put(value);
    final after = await snapshot(collection, saved);
    final event = await change(type: type, before: before, after: after);
    if (event != null && (value is Allocation || value is Transfer)) {
      if (value is Allocation) value.auditEventId = event.id;
      if (value is Transfer) value.auditEventId = event.id;
      await collection.put(value);
    }
    if (scope != null) {
      await recordDerived(
          scope, financialBefore!, await auditFinancialState(isar, scope));
    }
    return saved;
  }

  Future<bool> remove<T>(IsarCollection<T> collection, int id,
      {required String type}) async {
    final old = await collection.get(id);
    final scope = AuditFinancialScope.of(old as Object?);
    final financialBefore =
        scope == null ? null : await auditFinancialState(isar, scope);
    final before = await snapshot(collection, id);
    final deleted = await collection.delete(id);
    if (deleted) await change(type: type, before: before, after: null);
    if (scope != null) {
      await recordDerived(
          scope, financialBefore!, await auditFinancialState(isar, scope));
    }
    return deleted;
  }

  Future<void> recordDerived(AuditFinancialScope scope,
      Map<String, Object?> before, Map<String, Object?> after) async {
    Object? amounts(Object? value) {
      if (value is Map) {
        return {
          for (final entry in value.entries)
            if (entry.key != 'name') entry.key: amounts(entry.value)
        };
      }
      if (value is List) return value.map(amounts).toList();
      return value;
    }

    if (canonicalJsonEncode(amounts(before)) ==
        canonicalJsonEncode(amounts(after))) {
      return;
    }
    await append(
        profileId: scope.space == null ? scope.profile : null,
        spaceId: scope.space,
        action: 'borrowing.deficit.change',
        objectType: 'FinancialState',
        objectGuid: 'financial-state:${scope.month ?? 'all-months'}',
        before: before,
        after: after);
  }

  Future<AuditEvent?> change(
      {required String type,
      required Map<String, dynamic>? before,
      required Map<String, dynamic>? after,
      String? action}) async {
    if (canonicalJsonEncode(before) == canonicalJsonEncode(after)) return null;
    final row = after ?? before!;
    final space =
        (type == 'SharedSpace' ? row['id'] : row['sharedSpaceId']) as int?;
    final profile = space == null ? row['profileId'] as int? : null;
    if (before != null && after != null) {
      final oldSpace = (type == 'SharedSpace'
          ? before['id']
          : before['sharedSpaceId']) as int?;
      final oldProfile = oldSpace == null ? before['profileId'] as int? : null;
      if ((oldSpace != null || oldProfile != null) &&
          (oldSpace != space || oldProfile != profile)) {
        throw StateError(
            'Use the explicit month-move flow to change ownership.');
      }
    }
    if (space == null && actorId != null && actorId != profile) {
      throw StateError('This financial record belongs to another profile.');
    }
    if (space != null && actorId != null) {
      await SpaceWriteGuard(isar).assertSharedMoneyWrite(
          sharedSpaceId: space,
          actingProfileId: actorId,
          yearMonth: row['yearMonth'] as String? ??
              '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}');
    }
    if (space == null && profile == null) {
      throw StateError('Cannot audit a financial record without its owner.');
    }
    // Spending/count are derived caches. Refreshing a screen is not an action.
    if (['BudgetProfile', 'DirectExpenseProfile'].contains(type) &&
        before != null &&
        after != null) {
      Map<String, dynamic> business(Map<String, dynamic> value) => Map.of(value)
        ..remove('spent')
        ..remove('expenseCount')
        ..remove('updatedAt');
      if (canonicalJsonEncode(business(before)) ==
          canonicalJsonEncode(business(after))) {
        return null;
      }
    }
    if (['BudgetProfile', 'DirectExpenseProfile', 'MonthlyBudget']
        .contains(type)) {
      final code = space == null
          ? (await isar.userProfiles.get(profile!))?.primaryCurrency.code.code
          : (await isar.sharedSpaces.get(space))?.currency.code.code;
      if (code != null) {
        before =
            before == null ? null : {...before, 'accountingCurrency': code};
        after = after == null ? null : {...after, 'accountingCurrency': code};
      }
    }
    final prefix = type == 'IncomeSource'
        ? 'income'
        : type == 'VaultEntry'
            ? 'vault.${row['kind']}'
            : type.toLowerCase();
    final allocationChanged = type == 'BudgetProfile' &&
        before != null &&
        after != null &&
        before['allocation'] != after['allocation'];
    final reversal = type == 'Expense' &&
        before != null &&
        after != null &&
        before['status'] != after['status'] &&
        [
          ExpenseStatus.planned.index,
          ExpenseStatus.cancelled.index,
          'planned',
          'cancelled'
        ].contains(after['status']);
    return await append(
        profileId: profile,
        spaceId: space,
        action: action ??
            (reversal
                ? 'expense.reversal'
                : allocationChanged
                    ? 'allocation.update'
                    : '$prefix.${before == null ? 'create' : after == null ? 'delete' : 'update'}'),
        objectType: type,
        objectGuid:
            (row['syncGuid'] ?? row['operationKey'] ?? '$type:${row['id']}')
                .toString(),
        objectId: row['id'] as int?,
        before: before,
        after: after);
  }

  Future<AuditEvent> append(
      {int? profileId,
      int? spaceId,
      required String action,
      required String objectType,
      required String objectGuid,
      int? objectId,
      Object? before,
      Object? after,
      String? requestId}) async {
    if (action.trim().isEmpty ||
        objectType.trim().isEmpty ||
        objectGuid.trim().isEmpty) {
      throw ArgumentError('Audit action and object references are required.');
    }
    if ((profileId == null) == (spaceId == null)) {
      throw StateError('Audit requires exactly one owner.');
    }
    final signer = recorder?.signer;
    if (spaceId != null && signer == null) {
      throw StateError('Unlock your identity to record signed shared history.');
    }
    final context = spaceId == null
        ? 'personal:$profileId'
        : (await isar.sharedSpaces.get(spaceId))?.syncGuid;
    if (context == null || context.isEmpty) {
      throw StateError('Audit context is missing.');
    }
    final identities = await isar.identitys.where().findAll();
    final author = spaceId != null
        ? signer!.authorIdentityId
        : identities
                .where((i) => i.localProfileId == (actorId ?? profileId))
                .firstOrNull
                ?.fingerprint ??
            'profile:${actorId ?? profileId}';
    final deviceStamp = await isar.schemaMigrationStamps
        .filter()
        .keyEqualTo('audit:device')
        .findFirst();
    final installedDevice = recorder?.clock.deviceId;
    final device = installedDevice != null && installedDevice.isNotEmpty
        ? installedDevice
        : deviceStamp?.value ?? const Uuid().v4();
    if (deviceStamp == null) {
      await isar.schemaMigrationStamps.put(SchemaMigrationStamp()
        ..key = 'audit:device'
        ..value = device);
    }
    final chain =
        canonicalJsonEncode([spaceId != null, context, author, device]);
    final headKey = 'audit:head:$chain';
    final head = await isar.schemaMigrationStamps
        .filter()
        .keyEqualTo(headKey)
        .findFirst();
    final prior = head == null ? null : canonicalJsonDecode(head.value);
    final priorSequence = prior?['sequence'] as int? ?? 0;
    if (priorSequence < 0 || priorSequence >= 9007199254740991) {
      throw StateError('Audit sequence needs review.');
    }
    final sequence = priorSequence + 1;
    final previous = prior?['hash'] as String? ?? '';
    if (head != null) {
      final tip = await isar.auditEvents
          .filter()
          .syncGuidEqualTo(prior!['id'] as String)
          .findFirst();
      if (tip == null ||
          tip.hash != previous ||
          (await const AuditVerifyService()
                      .verify([tip], trustedKeys: const {}))
                  .status ==
              AuditStatus.failed) {
        throw StateError(
            'Audit history needs review before appending to this chain.');
      }
    }
    if (requestId != null) {
      final existing = await isar.auditEvents
          .filter()
          .syncGuidEqualTo(requestId)
          .findFirst();
      if (existing != null) {
        if (existing.contextSyncGuid != context ||
            existing.action != action ||
            existing.previousValue != canonicalJsonEncode(before) ||
            existing.newValue != canonicalJsonEncode(after)) {
          throw StateError('Conflicting audit request.');
        }
        return existing;
      }
    }
    final now = DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch,
        isUtc: true);
    var boundary = await isar.schemaMigrationStamps
        .filter()
        .keyEqualTo('audit:upgrade-boundary')
        .findFirst();
    if (boundary == null) {
      boundary = SchemaMigrationStamp()
        ..key = 'audit:upgrade-boundary'
        ..value = now.toIso8601String();
      await isar.schemaMigrationStamps.put(boundary);
    }
    final event = AuditEvent()
      ..syncGuid = requestId ?? const Uuid().v4()
      ..profileId = profileId
      ..sharedSpaceId = spaceId
      ..contextSyncGuid = context
      ..timestamp = now
      ..createdAt = now
      ..userIdentity = author
      ..action = action
      ..objectType = objectType
      ..objectId = objectId
      ..previousValue = canonicalJsonEncode(before)
      ..newValue = canonicalJsonEncode(after)
      ..previousHash = previous;
    event.evidenceJson = const AuditHashService().canonicalEvidence({
      'version': 1,
      'id': event.syncGuid,
      'context': context,
      'shared': spaceId != null,
      'author': author,
      'device': device,
      'chain': chain,
      'sequence': sequence,
      'timestamp': now.toIso8601String(),
      'action': action,
      'objectType': objectType,
      'object': objectGuid,
      'before': before,
      'after': after,
      'previousHash': previous,
      'boundary': boundary.value,
    });
    event.hash = const AuditHashService()
        .computeHash(previousHash: previous, canonical: event.evidenceJson!);
    if (spaceId != null) {
      event.signature = await signer!.sign(utf8.encode(event.hash));
    }
    await isar.auditEvents.put(event);
    await isar.schemaMigrationStamps.put((head ?? SchemaMigrationStamp())
      ..key = headKey
      ..value = canonicalJsonEncode(
          {'sequence': sequence, 'hash': event.hash, 'id': event.syncGuid}));
    if (spaceId != null) {
      await recorder!.record(
          contextKind: ContextKind.shared,
          contextLocalId: spaceId,
          entityType: 'AuditEvent',
          entitySyncGuid: event.syncGuid,
          entityLocalId: event.id,
          payload: canonicalJsonEncode({
            'syncGuid': event.syncGuid,
            'sharedSpaceSyncGuid': context,
            'evidenceJson': event.evidenceJson,
            'hash': event.hash,
            'signature': event.signature
          }));
    }
    return event;
  }

  Future<void> appendMonthEnd(MonthEndRun run) async {
    final event = await append(
        profileId: run.sharedSpaceId == null ? run.profileId : null,
        spaceId: run.sharedSpaceId,
        action: run.applied ? 'month.end' : 'month.end.conflict',
        objectType: 'MonthEndRun',
        objectGuid: run.syncGuid,
        objectId: run.id,
        requestId: 'audit:${run.syncGuid}',
        before: {
          'yearMonth': run.yearMonth,
          'processed': false
        },
        after: {
          'applied': run.applied,
          'report': jsonDecode(run.reportJson),
          'fingerprint': run.fingerprint
        });
    final allocations = await isar.allocations
        .filter()
        .syncGuidStartsWith('${run.syncGuid}:allocation:')
        .findAll();
    for (final allocation in allocations) {
      allocation.auditEventId = event.id;
    }
    await isar.allocations.putAll(allocations);
  }

  Future<void> appendRefund(
      {required Expense expense,
      required Reimbursement refund,
      required String actor,
      required Map<String, Object?> before,
      required Map<String, Object?> after,
      String? contextSyncGuid}) async {
    await append(
        profileId: expense.sharedSpaceId == null ? expense.profileId : null,
        spaceId: expense.sharedSpaceId,
        action: 'expense.refund',
        objectType: 'Expense',
        objectGuid: expense.syncGuid,
        objectId: expense.id,
        requestId: 'audit:refund:${refund.syncGuid}',
        before: before,
        after: {
          ...after,
          'refundSyncGuid': refund.syncGuid,
          'amount': refund.amount,
          'currency': refund.currency,
          'note': refund.note
        });
  }
}
