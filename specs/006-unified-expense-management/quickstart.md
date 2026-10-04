# Quickstart Validation Guide: Unified Expense Management

## Setup
1. Launch the BudgetBuddy application (`flutter run`).
2. Navigate to the Expenses tab.

## Scenario 1: Category Management
1. Tap the "Categories" management option.
2. Create a new category: Name="Gaming", Emoji="🎮", Color=Green.
3. **Verify:** The category appears in the list.

## Scenario 2: Smart Search & Filter
1. Go to the Expense List screen.
2. Tap the "🎮" category chip to filter.
3. **Verify:** Only gaming expenses are shown.
4. Clear the chip, then type "food" in the search bar.
5. **Verify:** Only expenses with "food" in their title are shown.

## Scenario 3: Expense Impact & Detail
1. Tap any expense in the list to open the Details Screen.
2. **Verify:** The hero section shows the category emoji.
3. **Verify:** The "Impact Card" displays how much this expense affected the month's `safeToSpend`.

## Scenario 4: Status Transition
1. In the Details Screen (or via swipe action), change a Planned expense to Paid.
2. **Verify:** The timeline updates to show the `paidAt` timestamp.
3. **Verify:** The dashboard `trueAvailable` decreases by the paid amount.
