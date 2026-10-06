# Implementation Tasks: Unified Reimbursements

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create Reimbursement entity in `lib/core/database/collections/reimbursement_collection.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T002 Run build_runner to generate Isar schema for Reimbursement
- [x] T003 Implement `ReimbursementRepository` in `lib/features/expenses/repositories/reimbursement_repository.dart`
- [x] T004 Create providers for `ReimbursementRepository` and fetching by sourceId in `lib/features/expenses/providers/reimbursement_provider.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Log a Simple Reimbursement for an Expense (Priority: P1) 🎯 MVP

**Goal**: Record that a standard expense was reimbursed and immediately reflect it in the available amount.

**Independent Test**: Create expense, log full reimbursement, verify available budget increases by exact amount and status updates.

### Implementation for User Story 1

- [x] T005 [P] [US1] Create basic Reimbursement Entry UI component in `lib/features/expenses/presentation/widgets/reimbursement_entry_sheet.dart`
- [x] T006 [US1] Integrate the entry sheet into the `ExpenseDetailsScreen` (e.g., add "Add Reimbursement" button for paid expenses)
- [x] T007 [US1] Update `FinancialEngine` or `DashboardProvider` (e.g., in `lib/features/finance/providers/dashboard_provider.dart`) to add total reimbursements to the available amount calculation.
- [x] T008 [US1] Update Expense list/details UI to reflect `reimbursed` status visually when fully reimbursed.

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently.

---

## Phase 4: User Story 2 - Partial and Multi-Event Reimbursements (Priority: P1)

**Goal**: Log multiple partial reimbursements against a single expense with notes, tracking installments.

**Independent Test**: Log two 50 USD reimbursements against a 150 USD expense. Verify total reimbursed is 100 USD, 50 USD remains allowed, and status is partial.

### Implementation for User Story 2

- [x] T009 [P] [US2] Update `reimbursement_entry_sheet.dart` to include an optional Note field.
- [x] T010 [US2] Update `reimbursement_entry_sheet.dart` to calculate and display the maximum allowed reimbursement (Expense amount - current total reimbursed), and add validation to reject amounts over the limit.
- [x] T011 [P] [US2] Create a UI list to display historical reimbursements in `lib/features/expenses/presentation/widgets/reimbursement_history_list.dart`.
- [x] T012 [US2] Integrate the history list into the `ExpenseDetailsScreen`.
- [x] T013 [US2] Update Expense UI state to correctly display `partially_reimbursed` dynamically.

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently.

---

## Phase 5: User Story 3 - Medical Bill Reimbursement (Priority: P1)

**Goal**: Record reimbursements specifically for medical bills up to the userPayableAmount.

**Independent Test**: Log a reimbursement for a medical bill up to the userPayableAmount and verify restrictions and UI updates.

### Implementation for User Story 3

- [x] T014 [US3] Integrate `reimbursement_entry_sheet.dart` and history list into `MedicalBillDetailsScreen` in `lib/features/medical/presentation/medical_bill_details_screen.dart`.
- [x] T015 [US3] Add validation logic to the entry sheet specifically for Medical Bills to cap at `userPayableAmount`.
- [x] T016 [US3] Display insurance breakdown/limits in the entry sheet when `sourceType` is `medicalBill`.
- [x] T017 [US3] Update Medical Bill UI status to reflect `reimbursed` or `partially_reimbursed` state.

**Checkpoint**: All P1 user stories should now be independently functional.

---

## Phase 6: User Story 4 - Cross-Currency Reimbursements (Priority: P2)

**Goal**: Log reimbursements in a different currency and automatically calculate the primary currency equivalent.

**Independent Test**: Log a USD reimbursement against a EUR expense and verify primary budget updates correctly based on exchange rate.

### Implementation for User Story 4

- [x] T018 [P] [US4] Update `reimbursement_entry_sheet.dart` to include a currency selector dropdown.
- [x] T019 [US4] Update the available amount calculation provider to apply exchange rates to reimbursements logged in foreign currencies before summing them.

**Checkpoint**: All user stories should now be functional.

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [ ] T020 Run quickstart.md validation manually to ensure all acceptance criteria are met
- [ ] T021 Code cleanup and refactoring in the reimbursements domain

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies
- **Foundational (Phase 2)**: Depends on Phase 1
- **User Stories (Phase 3+)**: All depend on Phase 2
- **Polish (Final Phase)**: Depends on all user stories

### User Story Dependencies

- **US1 (P1)**: Starts after Foundational (Phase 2)
- **US2 (P1)**: Depends heavily on US1 (enhances the same UI). Should be done sequentially after US1.
- **US3 (P1)**: Depends on US2 (re-uses the enhanced UI and max logic).
- **US4 (P2)**: Modifies logic from US1 and UI from US2. Can be done last.

### Parallel Opportunities

- Isar Schema (T001) and Repository (T003) must be sequential.
- UI widget scaffolding (T005, T009, T011, T018) can be done in parallel before integration.
- Different developers could theoretically handle Expense integration (US1/US2) and Medical Bill integration (US3) if the shared UI components are built first.
