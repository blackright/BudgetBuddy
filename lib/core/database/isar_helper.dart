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
import '../models/category.dart';
import '../models/medical_bill.dart';
import '../models/insurance_profile.dart';
import '../models/medical_service_type.dart';
import '../models/month_rate_seal.dart';
import '../models/live_rate_set.dart';
import '../models/identity.dart';
import '../models/consent_record.dart';
import '../models/paired_peer.dart';
import '../models/paired_context.dart';
import '../models/pairing_token.dart';
import '../models/change_record.dart';
import '../models/sync_cursor.dart';
import 'schema_migrations.dart';

class IsarHelper {
  static late Isar _isar;

  static Isar get instance => _isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        UserProfileSchema,
        MonthlyBudgetSchema,
        ExpenseSchema,
        ExpenseTemplateSchema,
        ReimbursementSchema,
        SavingsVaultSchema,
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
      ],
      directory: dir.path,
    );

    await runSchemaMigrations(_isar);
  }
}
