# Implementation Tasks: Available Amount Engine

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create feature folder structure in lib/features/engine and lib/features/vault
- [x] T002 Add `dio` dependency for currency exchange in pubspec.yaml

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Update Isar database configuration to include the new schemas in lib/core/database/database.dart

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - View Daily Pacing & Safe to Spend (Priority: P1) ⭐ MVP

**Goal**: Compute and display the core true available, safe-to-spend, and daily limit metrics.

**Independent Test**: Can be fully tested by creating planned and paid expenses, and observing the updated Daily Pacing and Safe-to-Spend amounts.

### Tests for User Story 1 (OPTIONAL - only if tests requested) 🧪

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [ ] T004 [P] [US1] Write unit tests for calculation math in test/features/engine/calculation_test.dart

### Implementation for User Story 1

- [x] T005 [P] [US1] Create Expense model in lib/features/expenses/models/expense.dart
- [x] T006 [P] [US1] Create MedicalBill model in lib/features/expenses/models/medical_bill.dart
- [x] T007 [P] [US1] Create Reimbursement model in lib/features/expenses/models/reimbursement.dart
- [x] T008 [US1] Implement Expense Repository in lib/features/expenses/repositories/expense_repository.dart
- [x] T009 [US1] Implement True Available Riverpod provider in lib/features/engine/providers/true_available_provider.dart
- [x] T010 [US1] Implement Safe-to-Spend Riverpod provider in lib/features/engine/providers/safe_to_spend_provider.dart
- [x] T011 [US1] Implement Daily Limit Riverpod provider in lib/features/engine/providers/daily_limit_provider.dart

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Multi-Currency Smart Normalization (Priority: P2)

**Goal**: Fetch exchange rates offline-first for accurate true available conversion.

**Independent Test**: Can be fully tested by adding a foreign expense and verifying it converts properly into the primary currency limit.

### Implementation for User Story 2

- [x] T012 [P] [US2] Implement Exchange Rate HTTP client (Dio) in lib/core/network/exchange_rate_client.dart
- [x] T013 [P] [US2] Implement Exchange Rate caching logic in lib/core/network/exchange_rate_cache.dart
- [x] T014 [US2] Integrate exchange rate fetching in Expense Repository in lib/features/expenses/repositories/expense_repository.dart

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - End of Month Savings Vault Sweep (Priority: P3)

**Goal**: Sweep unspent past-month funds into a lifetime savings vault.

**Independent Test**: Fast-forwarding the system time to a new month should trigger the sweep and populate the Vault.

### Implementation for User Story 3

- [x] T015 [P] [US3] Create SavingsVault model in lib/features/vault/models/savings_vault.dart
- [x] T016 [US3] Implement Vault Repository in lib/features/vault/repositories/vault_repository.dart
- [x] T017 [US3] Implement End of Month Sweep logic provider in lib/features/engine/providers/sweep_provider.dart
- [x] T018 [US3] Add startup check to execute sweep logic in lib/main.dart

**Checkpoint**: All user stories should now be independently functional

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T019 Check and fix any formatting or linting issues
- [x] T020 Run quickstart.md validation locally

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story

- Tests (if included) MUST be written and FAIL before implementation
- Models before services
- Services before endpoints
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all models for User Story 1 together:
Task: "Create Expense model in lib/features/expenses/models/expense.dart"
Task: "Create MedicalBill model in lib/features/expenses/models/medical_bill.dart"
Task: "Create Reimbursement model in lib/features/expenses/models/reimbursement.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories
