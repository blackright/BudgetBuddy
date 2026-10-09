import 'package:isar/isar.dart';

import '../../features/expenses/models/reimbursement.dart';
import '../models/expense.dart';
import '../models/medical_bill.dart';
import 'schema_migrations.dart';

/// The `int64` minimum, which is what Isar reads for a money property whose
/// stored type no longer matches the schema.
///
/// The step-9 cut changes `Expense.amount`, `Reimbursement.amount` and
/// `MedicalBill.billedAmount`/`reimbursedAmount` from `double` major units to
/// `int` minor units **in place**. Isar 3 does not fail on a changed property
/// type — it silently reinterprets the old bytes, and every such field comes
/// back as this value. See T-R11 in `specs/010-multi-currency-system/tasks.md`.
const int corruptedMinorSentinel = -9223372036854775807 - 1;

/// No real minor-unit amount reaches this magnitude (a year of spending is
/// ~1e12–1e15); anything larger is a reinterpreted `int64` extreme, not money.
const int _absurdMoneyMagnitude = 100000000000000000; // 1e17

/// Whether [minorUnits] cannot be a genuine stored amount.
bool isCorruptedMoney(int minorUnits) =>
    minorUnits <= -_absurdMoneyMagnitude || minorUnits >= _absurdMoneyMagnitude;

/// A single corrupted money field found in the database.
class MoneyIntegrityIssue {
  const MoneyIntegrityIssue({
    required this.collection,
    required this.rowId,
    required this.field,
    required this.value,
  });

  /// Isar collection name, e.g. `expenses`.
  final String collection;

  /// Row id within [collection].
  final int rowId;

  /// The property name, e.g. `amount`.
  final String field;

  /// The unreadable value that was stored.
  final int value;

  @override
  String toString() => '$collection#$rowId.$field = $value';
}

/// Scans every persisted money field for values that cannot be real minor units.
///
/// This is the runtime guard for the step-9 migration gap. Rendering a
/// reinterpreted `int64` min produces nonsense (`9223372036854775807`) or throws
/// (for example `MedicalBill.netOutOfPocket`'s `clamp(0, billedAmount)`), so the
/// app checks first and refuses to show corrupted money instead.
Future<List<MoneyIntegrityIssue>> findCorruptedMoney(Isar isar) async {
  final issues = <MoneyIntegrityIssue>[];

  for (final expense in await isar.expenses.where().findAll()) {
    if (isCorruptedMoney(expense.amount)) {
      issues.add(MoneyIntegrityIssue(
        collection: 'expenses',
        rowId: expense.id,
        field: 'amount',
        value: expense.amount,
      ));
    }
  }

  for (final reimbursement in await isar.reimbursements.where().findAll()) {
    if (isCorruptedMoney(reimbursement.amount)) {
      issues.add(MoneyIntegrityIssue(
        collection: 'reimbursements',
        rowId: reimbursement.id,
        field: 'amount',
        value: reimbursement.amount,
      ));
    }
  }

  for (final bill in await isar.medicalBills.where().findAll()) {
    if (isCorruptedMoney(bill.billedAmount)) {
      issues.add(MoneyIntegrityIssue(
        collection: 'medical_bills',
        rowId: bill.id,
        field: 'billedAmount',
        value: bill.billedAmount,
      ));
    }
    if (isCorruptedMoney(bill.reimbursedAmount)) {
      issues.add(MoneyIntegrityIssue(
        collection: 'medical_bills',
        rowId: bill.id,
        field: 'reimbursedAmount',
        value: bill.reimbursedAmount,
      ));
    }
  }

  return issues;
}

/// Wipes every collection and re-stamps the schema, returning the database to
/// the state of a fresh install.
///
/// Used by the corruption guard: the reinterpreted values cannot be recovered,
/// so the only correct action is to discard them rather than render or compute
/// with them. Re-running the migrations writes the version stamp so the app
/// starts as it would after a clean install.
Future<void> resetLocalDatabase(Isar isar) async {
  await isar.writeTxn(() async {
    await isar.clear();
  });
  await runSchemaMigrations(isar);
}
