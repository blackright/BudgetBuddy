# Tasks: Unified Expense Management

## Implementation Strategy
- **MVP Scope:** Phase 1 (Data Model) and Phase 2 (US3: Categories Management) form the MVP.
- **Incremental Delivery:** Deliver smart filtering next (US1), then the details screen (US2), and finish with status flows (US4).

## Dependencies & Execution Order
- **Setup & Foundational (Phases 1-2)**: BLOCKS all user stories.
- **User Story 3 (US3) - Categories UI**: Depends on Foundational.
- **User Story 1 (US1) - Smart Filters**: Depends on Foundational & US3 (needs categories).
- **User Story 2 (US2) - Expense Detail**: Independent UI, but needs Foundational.
- **User Story 4 (US4) - Status Flow**: Depends on US2.
- **Polish**: Depends on all stories.

---

## Phase 1: Setup
**Goal**: Project initialization (no new packages, skipping).

---

## Phase 2: Foundational (Data Model & Repository)
**Goal**: Establish Isar data models and repositories for Categories.

- [X] T001 Create `Category` Isar collection in `lib/core/models/category.dart`
- [X] T002 Update `Expense` model with `categoryId` fallback logic in `lib/core/models/expense.dart`
- [X] T003 Run Isar build runner to generate `.g.dart` schema files
- [X] T004 Create `CategoryRepository` in `lib/features/expenses/repositories/category_repository.dart`
- [X] T005 [P] Create Riverpod provider for `CategoryRepository` in `lib/features/expenses/providers/category_provider.dart`

---

## Phase 3: User Story 3 (Categories Management UI)
**Goal**: Allow users to view, create, and edit custom emoji categories.
**Independent Test Criteria**: User can navigate to Categories, see a list, and successfully save a new Category with an emoji and color.

- [X] T006 [US3] Create `CategoryListScreen` in `lib/features/expenses/presentation/category_list_screen.dart`
- [X] T007 [P] [US3] Create `CategoryEditScreen` in `lib/features/expenses/presentation/category_edit_screen.dart`
- [X] T008 [US3] Add `/categories` and `/categories/edit` routes to `lib/core/routing/app_router.dart`

---

## Phase 4: User Story 1 (Smart Filters & List Updates)
**Goal**: Users can quickly find expenses using natural terms and filter chips.
**Independent Test Criteria**: Typing "food" or selecting a Category chip instantly filters the Expenses list.

- [X] T009 [US1] Create Riverpod filter state providers (`searchQueryProvider`, `activeCategoryFilterProvider`) in `lib/features/expenses/providers/expense_filter_provider.dart`
- [X] T010 [US1] Update `ExpenseListProvider` to consume filter states in `lib/features/expenses/providers/expenses_provider.dart`
- [X] T011 [US1] Update `ExpensesScreen` to include a search bar in `lib/features/expenses/presentation/expenses_screen.dart`
- [X] T012 [P] [US1] Add horizontal filter chips (Categories, Guilt Level, Status) to `ExpensesScreen` in `lib/features/expenses/presentation/expenses_screen.dart`

---

## Phase 5: User Story 2 (Expense Details & Impact Screen)
**Goal**: Users can view a detailed breakdown of an expense and its impact on the month's `safeToSpend`.
**Independent Test Criteria**: Tapping an expense opens a screen showing the emoji hero, timeline, and correct % impact calculation.

- [X] T013 [US2] Create `ExpenseDetailScreen` layout in `lib/features/expenses/presentation/expense_detail_screen.dart`
- [X] T014 [P] [US2] Build "Hero Section" (emoji and amount) widget in `lib/features/expenses/presentation/expense_detail_screen.dart`
- [X] T015 [P] [US2] Build "Impact Card" calculation UI against `safeToSpend` in `lib/features/expenses/presentation/expense_detail_screen.dart`
- [X] T016 [P] [US2] Build Visual Timeline widget in `lib/features/expenses/presentation/expense_detail_screen.dart`
- [X] T017 [US2] Add `/expense_detail` route to `lib/core/routing/app_router.dart` and wire up list tap events.

---

## Phase 6: User Story 4 (Status Flow & Integration)
**Goal**: Status transitions properly update engine metrics and timelines.
**Independent Test Criteria**: Toggling an expense from Planned to Paid on the details screen updates the timeline and deducts from `trueAvailable`.

- [X] T018 [US4] Add "Action Bar" (Edit, Delete, Duplicate, Toggle Status) to `ExpenseDetailScreen` in `lib/features/expenses/presentation/expense_detail_screen.dart`
- [X] T019 [US4] Wire status toggle button to update `paidAt` and `status` in Isar via `expenses_provider.dart`

---

## Phase 7: Polish & Cross-Cutting Concerns
**Goal**: Final cleanups, tests, and documentation.

- [ ] T020 Run quickstart.md validation
