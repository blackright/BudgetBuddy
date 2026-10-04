# Implementation Tasks: Medical Bills & Insurance

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Create medical feature folder structure (`lib/features/medical/presentation`, `lib/features/medical/providers`, `lib/features/medical/repositories`)
- [X] T002 [P] Create `lib/core/models/medical_bill.dart` stub
- [X] T003 [P] Create `lib/core/models/insurance_profile.dart` stub

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Implement `InsuranceProfile`, `FamilyMember`, and `MedicalProvider` Isar models in `lib/core/models/insurance_profile.dart`
- [X] T005 [P] Implement `MedicalBill` Isar model in `lib/core/models/medical_bill.dart`
- [X] T006 Re-run `dart run build_runner build` to generate Isar boilerplate
- [X] T007 Implement `MedicalRepository` in `lib/features/medical/repositories/medical_repository.dart` to handle CRUD for the medical entities
- [X] T008 Setup Riverpod providers for Medical feature in `lib/features/medical/providers/medical_providers.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Add Medical Bill & Track Deductible (Priority: P1) ⭐ MVP

**Goal**: Users need to log medical bills to track their out-of-pocket expenses towards their annual deductible.

**Independent Test**: Can be fully tested by adding a medical bill and verifying the out-of-pocket amount is calculated and displayed on the dashboard deductible progress bar.

### Implementation for User Story 1

- [X] T009 [US1] Create Health Dashboard screen UI in `lib/features/medical/presentation/medical_dashboard.dart` with deductible progress bar
- [X] T010 [US1] Create Add/Edit Medical Bill form UI in `lib/features/medical/presentation/medical_bill_form.dart`
- [X] T011 [US1] Integrate `MedicalProvider` and `FamilyMember` dropdowns/selections in the form
- [X] T012 [US1] Implement attachment picking (receipts/EOBs) and display in the form UI
- [X] T013 [US1] Calculate `estimatedOutPocket` based on coverage percentage upon form save
- [X] T014 [US1] Display total deductible progress on the Health Dashboard based on saved bills
- [X] T015 [US1] Apply dark mode and muted light mode constraints (UX-001, UX-002) in `lib/features/medical/presentation/medical_dashboard.dart` and `medical_bill_form.dart`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Pay Provider & Reimbursements (Priority: P2)

**Goal**: Users need to mark a bill as paid to the provider so it correctly impacts their `trueAvailable` budget, and handle insurance claim status.

**Independent Test**: Can be fully tested by marking a bill as paid (verifying `trueAvailable` decreases), and later marking it reimbursed (verifying `trueAvailable` increases).

### Implementation for User Story 2

- [X] T016 [US2] Link MedicalBill saving to underlying `Expense` creation (status: planned/paid) in `MedicalRepository`
- [X] T017 [US2] Create Medical Bill Details screen `lib/features/medical/presentation/medical_detail_screen.dart`
- [X] T018 [US2] Add action in Details screen to mark bill as "Paid to Provider" (updates linked Expense)
- [X] T019 [US2] Add action in Details screen to update `claimStatus` (unclaimed, processing, denied, reimbursed)
- [X] T020 [US2] Implement follow-up reminder date selection for pending claims in Details screen
- [X] T021 [US2] Implement budget injection logic when `claimStatus` is set to `reimbursed`
- [X] T022 [US2] Apply dark mode constraints (UX-001, UX-002) to `medical_detail_screen.dart`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [X] T023 [P] Code cleanup and dart format
- [X] T024 Run `flutter analyze` and resolve any new linting issues
- [X] T025 Run quickstart.md validation scenarios

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed sequentially in priority order (P1 -> P2)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### Parallel Opportunities

- T002 and T003 can run in parallel
- T005 can run in parallel with T004
- UI construction tasks (T009, T010, T017) can be scaffolded in parallel by multiple devs
