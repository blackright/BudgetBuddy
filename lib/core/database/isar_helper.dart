import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user_profile.dart';
import '../models/monthly_budget.dart';
import '../../core/models/expense.dart';
import '../../core/models/expense_template.dart';
import '../../features/expenses/models/reimbursement.dart';
import '../../features/vault/models/savings_vault.dart';
import '../models/category.dart';
import '../models/medical_bill.dart';
import '../models/insurance_profile.dart';

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
      ],
      directory: dir.path,
    );
  }
}
