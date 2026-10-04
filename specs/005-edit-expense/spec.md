# Feature Specification: Edit Expense

## Purpose
Allow the user to effortlessly modify existing expenses, correct mistakes, and quickly manage their ongoing budget. Editing an expense must correctly and instantly trigger the financial engine to recalculate `safeToSpend` and `trueAvailable` in real-time. This feature also introduces fast-action gestures to minimize friction when managing daily transactions.

## User Scenarios & Testing
- **Scenario 1**: User corrects a typo in the amount of a paid expense.
  - *Action*: User changes a $50 expense to $60 and saves.
  - *Expected Outcome*: `trueAvailable` and `safeToSpend` decrease by an additional $10.
- **Scenario 2**: User marks a planned expense as paid via swipe.
  - *Action*: User swipes an expense card from left to right.
  - *Expected Outcome*: The expense status changes to "Paid" immediately, `paidAt` is set, and `trueAvailable` drops by the amount.
- **Scenario 3**: User hits the "Duplicate" button on a past expense.
  - *Action*: User taps "Duplicate" while viewing a coffee expense from last week.
  - *Expected Outcome*: A new expense is created identical to the original but with today's date, and metrics adjust accordingly.
- **Scenario 4**: Smart overspend warning.
  - *Action*: User edits a planned expense, changing the amount from $100 to $500, but `safeToSpend` is only $300.
  - *Expected Outcome*: A UI warning appears dynamically indicating that saving this change will exceed the safe to spend limit.

## Entities Involved
- **Expense**: The target record being modified.
- **MonthlyBudget**: The active budget being affected.
- **Category**: For grouping the expense.

## Inputs (Editable Fields)
- `title` (String): What did you buy?
- `amount` (Double > 0): How much was it?
- `categoryId` (String): Must reference an existing category.
- `status` (Enum: planned, paid): Has the money actually left the account?
- `isReimbursable` (Boolean): Are you getting paid back?
- `guiltLevel` (Enum: Essential, Guilt-Free Splurge, Oops): Can be adjusted upon reflection.
- `receiptPath` (String, optional): Update or add a receipt photo.

## Outputs
- Updated Expense record stored locally.
- Dashboard metrics (`trueAvailable`, `safeToSpend`) instantly recalculate.
- If duplicated, a new Expense record is created.

## Rules & Financial Logic
Editing an expense alters the historical ledger. When an expense is saved, the Engine must recalculate based on the *deltas* (the difference between the old expense state and the new expense state):
- **Amount changes**: `trueAvailable` and `safeToSpend` adjust by the exact difference.
- **Status changes (Planned ↔ Paid)**:
  - *Planned → Paid*: `paidAt` is set to now. `trueAvailable` decreases (the cash has actually left the account).
  - *Paid → Planned*: `paidAt` is cleared. `trueAvailable` increases (the cash is back in the account, but still reserved).
- **Reimbursable changes**: If toggled ON, the impact on `trueAvailable` is reversed (since it's no longer a sunk cost).

## Invariants & Validation
- `amount` must remain > 0.
- `title` cannot be empty.
- Modifying a past month's expense is allowed, but must strictly recalculate *that specific month's* budget.

## Success Criteria
- Editing an expense completes and updates the UI instantly.
- Swipe gestures register quickly without interfering with normal scroll behavior.
- The Engine calculates the exact delta rather than completely recreating the entire ledger for minor edits.

## UI & UX Requirements
### A. The Edit Screen
- **Form Layout**: Reuses the friendly, gamified UI components from the `AddExpenseScreen`.
- **Smart Overspend Warning (Delta Alert)**: If the user increases the expense amount such that it drops their `safeToSpend` below zero, a dynamic, animated warning appears at the top of the screen.
- **Duplicate Action**: A "Duplicate" button sits at the bottom of the screen. Tapping it instantly creates a clone of the expense set to today's date and navigates back to the dashboard.

### B. List View (Swipe Actions)
- **Swipe Right (Quick Toggle)**: Swiping an expense from left to right instantly toggles its status between `planned` and `paid` without opening the edit screen.
- **Swipe Left (Quick Edit/Delete)**: Swiping right to left reveals a quick "Edit" icon and a "Delete" icon.

## Navigation
- **Entry Points**: 
  - Tapping an expense card on the `ExpensesScreen` (opens Full Edit).
  - Swiping on an expense card (triggers Quick Actions).
- **Exit Points**: 
  - Saving or Duplicating returns the user to the `ExpensesScreen`.

## Non-Functional Requirements
- **Offline-First**: Must persist immediately using Isar.
- **Real-time Reactive**: Using Riverpod, the dashboard must update instantly the millisecond an edit or swipe is performed.
