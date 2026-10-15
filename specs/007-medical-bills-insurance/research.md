# Research: Medical Bills & Insurance

## Design Decisions

### 1. Linking Medical Bills to Expenses
- **Decision**: `MedicalBill` will store an `expenseId` to link 1:1 with an `Expense` record.
- **Rationale**: Reusing the existing `Expense` engine prevents us from duplicating the math for budget deductions. The `Expense` will handle the actual "payment" to the provider, while the `MedicalBill` handles the insurance state.
- **Alternatives considered**: Subclassing `Expense` (Isar doesn't easily support polymorphic collections in the same way), or copying fields (violates DRY and fragments budget math).

### 2. Status Mapping
- **Decision**: The Medical Bill's `claimStatus` (unclaimed, processing, reimbursed, denied) will be fully independent of the underlying Expense's `status` (planned, paid, cancelled).
- **Rationale**: A user can "pay" the provider (Expense = Paid, budget reduced) but still be waiting for the insurance claim (MedicalBill = processing). These are two different life cycles.

### 3. Deductible Tracking
- **Decision**: We will compute the deductible progress on-the-fly by summing the `estimatedOutPocket` for all bills in the current year.
- **Rationale**: Avoids storing a separate running total, making it simpler to recalculate if a bill is edited or deleted.
