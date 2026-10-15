# Data Model: Unified Reimbursements

## Entities

### 1. Reimbursement (New Isar Collection)
Represents a single reimbursement event.

**Fields**:
- `id` (String / Isar Id): Unique identifier.
- `userId` (String): The profile ID this reimbursement belongs to.
- `sourceType` (Enum: `expense`, `medicalBill`): Identifies the origin type.
- `sourceId` (String): The ID of the parent expense/medical bill.
- `amount` (Double): The amount reimbursed (> 0).
- `currency` (String): The currency of the reimbursement (e.g. HUF, USD).
- `createdAt` (DateTime): When the reimbursement was logged.
- `note` (String, optional): User-provided note or source text.

**Indexes**:
- Index on `userId` for quick profile filtering.
- Index on `sourceId` to quickly fetch all reimbursements for a specific expense.

### 2. Expense (Existing Isar Collection, modified)
Represents the original transaction.

**Modifications**:
- Ensure `status` enum or logic supports `reimbursed` and `partially_reimbursed` states dynamically based on the sum of child Reimbursements. Alternatively, calculate this dynamically in the domain layer without persisting `partially_reimbursed`, but UI requires distinct states.
- Re-evaluate `status` when a reimbursement is added/removed.

## Validation Rules & Invariants
- **Amount Rule**: `reimbursementAmount > 0`.
- **Expense Max Rule**: Total reimbursements for `sourceId` ≤ `Expense.amount`.
- **Medical Max Rule**: Total reimbursements for `sourceId` ≤ `MedicalBill.userPayableAmount`.
- **Status Rule**: Only items with status `paid` (or already `partially_reimbursed`) can accept new reimbursements.
- **Currency Rule**: Must be a supported currency.

## State Transitions
1. Add Reimbursement → Calculate total reimbursements for `sourceId`.
2. If total == max allowed → `Expense.status` = `reimbursed`.
3. If total < max allowed → `Expense.status` = `partially_reimbursed`.
4. Trigger `availableAmount` recalculation for the affected month.
