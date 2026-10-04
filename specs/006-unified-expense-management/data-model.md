# Data Model: Unified Expense Management

## Entities

### `Category` (New Isar Collection)
Represents a gamified category for expenses.
- **Fields:**
  - `id`: `Id` (Isar auto-increment) or String hash
  - `name`: `String` (e.g., "Food")
  - `emoji`: `String` (e.g., "🍔")
  - `colorValue`: `int` (ARGB representation of the color)
  - `isDefault`: `bool` (Used for fallback if a category is deleted)
- **Relationships:**
  - `Expense` has a `categoryId`.

### `Expense` (Existing Isar Collection, Requires Updates)
Represents an individual expense.
- **Updates Needed:**
  - Needs a clear linkage to `Category` via `categoryId`.

### `Reimbursement` (Existing Isar Collection)
Represents money returned to the user.
- **Relationships:**
  - Links to `Expense` (via `expenseId`).

## State Transitions (Expense Status)
1. **Planned** -> **Paid**: Deducts from `trueAvailable`, sets `paidAt`.
2. **Paid** -> **Planned**: Restores `trueAvailable`, nullifies `paidAt`.
3. **Planned** / **Paid** -> **Cancelled**: Nullifies impact completely.
