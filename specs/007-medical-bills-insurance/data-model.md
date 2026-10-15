# Data Model: Medical Bills & Insurance

## Isar Collections

### 1. InsuranceProfile
Stores the user's overall health insurance settings.
```dart
@collection
class InsuranceProfile {
  Id id = Isar.autoIncrement;
  String profileId; // Links to UserProfile
  double individualDeductible; // e.g., $2000 per person
  double familyDeductible;     // e.g., $4000 for the whole family
  double defaultCoveragePercent;
  int year;
}

@collection
class FamilyMember {
  Id id = Isar.autoIncrement;
  String name;
  String relation; // e.g., "Self", "Spouse", "Child"
}

@collection
class MedicalProvider {
  Id id = Isar.autoIncrement;
  String name; // e.g., "City Hospital", "Dr. Smith"
  String? specialty;
}
```

### 2. MedicalBill
Stores the medical-specific details and links to a core Expense.
```dart
@collection
class MedicalBill {
  Id id = Isar.autoIncrement;
  
  @Index()
  int? linkedExpenseId; // Links to Expense.id

  @Index()
  int? familyMemberId; // Links to FamilyMember.id

  @Index()
  int? providerId; // Links to MedicalProvider.id

  List<String> attachmentPaths = []; // Local file paths for EOBs/Receipts
  DateTime? followUpDate; // Reminder date to check on pending claims
  
  double billedAmount;
  double insuranceCoveragePercent;
  
  @enumerated
  ClaimStatus claimStatus; // unclaimed, processing, reimbursed, denied
  
  DateTime serviceDate;
  double reimbursedAmount;

  // Computed properties
  double get insuranceCoveredAmount => billedAmount * (insuranceCoveragePercent / 100);
  double get estimatedOutPocket => billedAmount - insuranceCoveredAmount;
}

enum ClaimStatus {
  unclaimed,
  processing,
  reimbursed,
  denied
}
```

## State Transitions
1. **Creation**: User creates MedicalBill. Underlying Expense is created with status = `planned` (or `paid`). Claim status = `unclaimed`.
2. **Provider Paid**: Underlying Expense status -> `paid`. Budget `trueAvailable` decreases by `billedAmount`.
3. **Claim Filed**: Claim status -> `processing`. No budget impact.
4. **Reimbursed**: Claim status -> `reimbursed`. User enters actual `reimbursedAmount`. Budget `trueAvailable` increases by `reimbursedAmount` via a special Income/Adjustment transaction (or a direct method on the engine).
