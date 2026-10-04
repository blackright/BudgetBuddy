# Phase 1: Data Model

## Existing Models Used

### `Expense` (Isar Collection)
No schema changes required. The edit feature will modify existing properties of this collection.
- `id`: Isar Id
- `title`: String
- `amount`: Double
- `currency`: PrimaryCurrency enum
- `categoryId`: String
- `status`: ExpenseStatus enum (`planned`, `paid`)
- `isReimbursable`: Boolean
- `guiltLevel`: GuiltLevel enum
- `receiptPath`: String?
- `createdAt`: DateTime
- `paidAt`: DateTime?

### `MonthlyBudget` (Isar Collection)
Used for determining delta impact. 
No schema changes required.

## Application State Models

### Delta Impact (Internal Logic)
When an expense is edited, the `ExpensesProvider` must calculate the impact on the engine:
```dart
double oldAmount = oldExpense.amount;
double newAmount = newExpense.amount;
double delta = newAmount - oldAmount;

// Logic rules:
// If status changed from Planned -> Paid:
//   Apply full newAmount to True Available deduction.
// If status changed from Paid -> Planned:
//   Restore oldAmount to True Available.
// If status remained Paid:
//   Apply delta to True Available deduction.
// Similar logic for Reimbursable changes.
```
