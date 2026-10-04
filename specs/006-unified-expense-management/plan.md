# Implementation Plan: Unified Expense Management

## Technical Context
- **State Management:** Riverpod
- **Persistence:** Isar
- **Navigation:** GoRouter

## Constitution Check
- **Performance:** Filtering operations are lightweight in Isar. Riverpod will cache the derived states.
- **Offline-First:** All data stored entirely locally in Isar.
- **UX/UI:** Retains gamified feel (Emoji categories, bold hero sections).

## Phases

### Phase 1: Data Model & Repository Updates
- **Objective:** Introduce `Category` to Isar and update `Expense` interactions.
- **Steps:**
  - Create `Category` Isar collection (id, name, emoji, colorValue, isDefault).
  - Generate Isar schema.
  - Implement `CategoryRepository` (create, update, delete, fetch all).

### Phase 2: Category Management UI
- **Objective:** Allow users to create and edit emoji categories.
- **Steps:**
  - Create `CategoryListScreen`.
  - Create `CategoryEditScreen` with form, emoji picker, and color picker.
  - Add to GoRouter.

### Phase 3: Smart Filters & Expense List Updates
- **Objective:** Add search and filtering capabilities to the Expense Hub.
- **Steps:**
  - Implement Riverpod providers for search query and active filters (category, status, guilt level).
  - Update `ExpensesScreen` to display filter chips and search bar.
  - Wire up UI to filter providers and `ExpenseList` provider.

### Phase 4: Expense Details & Impact Screen
- **Objective:** Provide a deep dive into an expense and its impact on the budget.
- **Steps:**
  - Create `ExpenseDetailScreen`.
  - Build Hero section (Emoji, amount).
  - Build Timeline visualizer.
  - Build Impact Card calculating the percentage impact on `safeToSpend`.
  - Add GoRouter navigation from list to details.

### Phase 5: Status Flow & Final Integration
- **Objective:** Ensure status transitions properly update the engine metrics.
- **Steps:**
  - Wire the details screen action bar to trigger status updates (`toggleStatus`).
  - Verify Reimbursement flows.
  - Test edge cases (deleting a category assigns expenses to "General").
