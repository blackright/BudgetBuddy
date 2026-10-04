# Feature Specification: Create Expense

## Purpose
Allow the user to effortlessly log a new expense for the current month. This is the core action that drives BudgetBuddy's financial engine, updating the safeToSpend and trueAvailable metrics in real-time while maintaining the app's friendly, gamified, and encouraging vibe.

## User Scenarios & Testing
- **Scenario 1**: User creates a new paid expense. 
  - *Action*: User enters $10 for "Coffee", selects the Food category, leaves status as "Paid", and saves.
  - *Expected Outcome*: Expense is saved. Both trueAvailable and safeToSpend decrease by $10. The expense appears in the expense list.
- **Scenario 2**: User creates a planned expense.
  - *Action*: User enters $50 for "Groceries", selects status as "Planned", and saves.
  - *Expected Outcome*: Expense is saved. safeToSpend decreases by $50, but trueAvailable remains unchanged.
- **Scenario 3**: User creates a reimbursable expense.
  - *Action*: User enters $100 for "Dinner with Bob", checks the "Reimbursable" toggle, and saves.
  - *Expected Outcome*: Expense is saved and flagged as pending reimbursement for future tracking.
- **Scenario 4**: Error handling for invalid input.
  - *Action*: User attempts to save without entering an amount.
  - *Expected Outcome*: System shows a playful error message ("Oops! You forgot to enter an amount!") and prevents saving.

## Entities Involved
- Expense: The core transaction record.
- Category: For grouping expenses (e.g., Food, Transport).
- MonthlyBudget: The current active budget being affected.

## Inputs
- title (String): What did you buy?
- amount (Double > 0): How much was it?
- currency (Enum: HUF, USD, CAD, EUR): Defaults to the user's primary currency.
- categoryId (String): Must reference an existing category.
- status (Enum: planned, paid): Defaults to "paid".
- isReimbursable (Boolean): Is someone going to pay you back for this? Defaults to false.
- guiltLevel (Enum: Essential, Guilt-Free Splurge, Oops): Playful tagging for emotional spending awareness. Defaults to Essential.
- receiptPhotoPath (String, Optional): Local file path to an attached picture of the receipt.
- saveAsTemplate (Boolean): Should this entry be saved as a Quick-Add Template for later? Defaults to false.
- createdAt (DateTime): Auto-generated timestamp.

## Outputs
- New Expense record stored locally.
- If saveAsTemplate is true, a new ExpenseTemplate record is stored.
- Expense appears dynamically in the Expense List.
- Dashboard metrics (trueAvailable, safeToSpend) instantly recalculate.

## Rules & Financial Logic
- amount must be > 0.
- currency must be one of the supported Enums.
- categoryId must reference a valid category.
- If status = "paid":
  - paidAt date must be set.
  - Decreases both trueAvailable and safeToSpend.
- If status = "planned":
  - Decreases safeToSpend ONLY (reserving the money, but not actually spending it yet).
- If isReimbursable = true:
  - The expense is flagged as a pending reimbursement for future tracking.
- If saveAsTemplate = true:
  - The title, amount, category, currency, and guiltLevel are saved as a reusable template.

## Success Criteria
- Time to log an expense (without receipt photo) is under 10 seconds.
- The dashboard financial metrics update instantly after saving the expense.
- The UI handles validation errors without crashing and provides clear guidance.
- Offline support is 100% functional; expenses can be created without an internet connection.

## UI Requirements
Screen: Add Expense Modal/Screen
- Friendly, conversational UI (e.g., "What did we spend on today?").
- Input fields for Title and Amount.
- Dropdowns/Chips for Currency and Category selection.
- Segmented control or toggle for Status (Planned vs. Paid).
- Reimbursable Toggle ("Will you be paid back?").
- Emotion/Guilt Level selector (visual emojis: 🛡️ Essential, 🍦 Splurge, 🙈 Oops).
- Camera/Gallery button to attach a receipt photo.
- Checkbox to "Save as Quick-Add Template".
- Big, satisfying "Save Expense" button.

## Navigation
Accessible from:
- Dashboard "Quick Actions" button.
- Floating Action Button (FAB) on the Expenses Tab.
- Quick-Add Template shortcuts on the Dashboard.

## Non-Functional Requirements
- Offline-First: Must persist immediately to the local database.
- Reactive: Must use reactive state management to instantly update the Dashboard without manual refreshes.
- Validation: Must provide playful, clear error messages if fields are missing (e.g., "Oops! You forgot to enter an amount!").
