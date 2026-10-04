# Phase 1: Quickstart & Validation - Create Expense

## Validation Scenarios

### Scenario 1: Creating a Paid Expense
1. Open the app and navigate to the Dashboard.
2. Observe the current `safeToSpend` and `trueAvailable` values.
3. Tap "Add Expense".
4. Enter "Lunch", Amount "$15", Status "Paid", Guilt Level "Essential".
5. Save the expense.
6. Verify that both `safeToSpend` and `trueAvailable` decreased by $15 immediately on the Dashboard.

### Scenario 2: Creating a Planned Expense
1. Tap "Add Expense".
2. Enter "New Headphones", Amount "$100", Status "Planned", Guilt Level "Splurge".
3. Save the expense.
4. Verify that `safeToSpend` decreased by $100, but `trueAvailable` remains unchanged.
