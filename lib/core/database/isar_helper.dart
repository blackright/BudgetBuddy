import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user_profile.dart';
import '../models/monthly_budget.dart';
import '../../core/models/expense.dart';
import '../../core/models/expense_template.dart';
import '../../core/models/shared_member.dart';
import '../../core/models/shared_space.dart';
import '../../features/expenses/models/reimbursement.dart';
import '../../features/vault/models/savings_vault.dart';
import '../../features/vault/models/vault_entry.dart';
import '../models/category.dart';
import '../models/medical_bill.dart';
import '../models/insurance_profile.dart';
import '../models/medical_service_type.dart';
import '../models/month_rate_seal.dart';
import '../models/live_rate_set.dart';
import '../models/identity.dart';
import '../models/consent_record.dart';
import '../models/lock_setting.dart';
import '../models/paired_peer.dart';
import '../models/paired_context.dart';
import '../models/pairing_token.dart';
import '../models/change_record.dart';
import '../models/sync_cursor.dart';
import '../models/income_source.dart';
import '../models/budget_profile.dart';
import '../models/month_end_run.dart';
import '../models/direct_expense_profile.dart';
import '../models/allocation.dart';
import '../models/transfer.dart';
import '../models/merchant.dart';
import '../models/expense_evidence_chunk.dart';
import '../models/expense_purchase.dart';
import '../services/evidence_staging.dart';
import 'dart:developer' as developer;
import '../models/audit_event.dart';
import '../models/app_settings.dart';
import 'schema_migrations.dart';

class IsarHelper {
  static Isar? _isarValue;

  static Isar get instance =>
      _isarValue ??
      (throw StateError(
          'IsarHelper.init() has not run before IsarHelper.instance'));

  /// Test-only injection of the singleton so provider-level tests can point the
  /// app's providers at a temporary Isar. The running app never calls this
  /// (`instance` is otherwise only ever set by [init]).
  @visibleForTesting
  static set instance(Isar isar) => _isarValue = isar;

  /// The open database, or `null` before [init] has run.
  ///
  /// Read-only surfaces that must stay **inert** rather than crash when there is
  /// no database — the app-lock gate in a widget test, for one — ask this
  /// instead of [instance]. Having one nullable source of truth is also what
  /// lets [instance] fail loudly with a plain `StateError`.
  static Isar? get maybeInstance => _isarValue;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isarValue = await Isar.open(
      [
        UserProfileSchema,
        MonthlyBudgetSchema,
        ExpenseSchema,
        ExpenseTemplateSchema,
        ReimbursementSchema,
        SavingsVaultSchema,
        VaultEntrySchema,
        CategorySchema,
        MedicalBillSchema,
        InsuranceProfileSchema,
        FamilyMemberSchema,
        MedicalProviderSchema,
        MedicalServiceTypeSchema,
        SchemaMigrationStampSchema,
        MonthRateSealSchema,
        LiveRateSetSchema,
        SharedSpaceSchema,
        SharedMemberSchema,
        IdentitySchema,
        ConsentRecordSchema,
        PairedPeerSchema,
        PairedContextSchema,
        PairingTokenSchema,
        ChangeRecordSchema,
        SyncCursorSchema,
        LockSettingSchema,
        IncomeSourceSchema,
        BudgetProfileSchema,
        MonthEndRunSchema,
        DirectExpenseProfileSchema,
        AllocationSchema,
        TransferSchema,
        MerchantSchema,
        ExpenseEvidenceChunkSchema,
        ExpensePurchaseSchema,
        AuditEventSchema,
        AppSettingsSchema,
      ],
      directory: dir.path,
    );

    await runSchemaMigrations(_isarValue!);
    try {
      await EvidenceStaging.root();
    } catch (_) {
      // Temporary-storage failure must not stop access to existing finances.
      // Attachment selection retries cleanup and reports any storage failure.
      developer.log(
          'Temporary evidence cleanup unavailable; attachment selection will retry.',
          name: 'ExpenseEvidence');
    }
  }
}
