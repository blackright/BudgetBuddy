# Phase 1: Quickstart Validation Guide

This guide provides steps to manually validate the Edit Expense feature once implemented.

## Prerequisites
- App running via `flutter run`
- At least one existing Expense in the dashboard

## Validation Scenario 1: Quick Toggle Status (Swipe)
1. Open the app to the Dashboard.
2. Scroll to the "Expenses" list.
3. Find an expense marked as "Planned".
4. Swipe the expense card from left to right.
5. **Expected Outcome**: The status badge changes to "Paid" and the dashboard's `trueAvailable` amount decreases immediately.

## Validation Scenario 2: Edit Amount
1. Swipe right to left on a "Paid" expense and tap the "Edit" icon.
2. The `EditExpenseScreen` should open with all fields pre-populated.
3. Increase the amount by $50.
4. Tap "Save".
5. **Expected Outcome**: You are returned to the Dashboard, and both `safeToSpend` and `trueAvailable` decrease by exactly $50.

## Validation Scenario 3: Smart Warning
1. Find a "Planned" expense and edit it.
2. Increase the amount significantly so that it would exceed the current `safeToSpend` limit.
3. **Expected Outcome**: A warning should appear in the UI informing you that this change will put you over budget.

## Validation Scenario 4: Duplicate Expense
1. Edit any existing expense.
2. Tap the "Duplicate" button.
3. **Expected Outcome**: A new expense with the exact same details (except `createdAt` which is now) is added to the list, and the budget is correctly reduced twice (once for the original, once for the duplicate).
