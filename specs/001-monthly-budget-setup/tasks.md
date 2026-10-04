# Implementation Tasks: Monthly Budget Setup

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Create core project directory structure (lib/core/, lib/features/)
- [X] T002 Add dependencies (flutter_riverpod, isar, isar_flutter_libs, build_runner) to pubspec.yaml
- [X] T003 [P] Configure linting and formatting in analysis_options.yaml

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Setup Isar database initialization in `lib/core/database/isar_helper.dart`
- [X] T005 [P] Create `UserProfile` Isar collection schema in `lib/core/models/user_profile.dart`
- [X] T006 [P] Create `MonthlyBudget` Isar collection schema in `lib/core/models/monthly_budget.dart`
- [X] T007 Run build_runner to generate Isar boilerplate code
- [X] T008 Setup global Riverpod `ProviderScope` in `lib/main.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Initial Onboarding Setup (Priority: P1) 🚀 MVP

**Goal**: As a new user, define monthly available amount, primary currency, and select a target month to establish the baseline budget.

**Independent Test**: Launch the app for the first time, complete the setup screen with valid inputs, and verify the Isar database has the correct `UserProfile` and `MonthlyBudget` records.

### Implementation for User Story 1

- [X] T009 [US1] Create BudgetSetupState and Provider in `lib/features/budget_setup/providers/budget_setup_provider.dart`
- [X] T010 [US1] Implement input validation logic (amount > 0, currency check) in `budget_setup_provider.dart`
- [X] T011 [US1] Implement Isar save logic to initialize `UserProfile` and `MonthlyBudget` in `budget_setup_provider.dart`
- [X] T012 [US1] Create Monthly Budget Setup Screen UI in `lib/features/budget_setup/presentation/budget_setup_screen.dart`
- [X] T013 [US1] Route from app launch to `BudgetSetupScreen` (Onboarding) in `lib/main.dart`

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Monthly Reset (Priority: P2)

**Goal**: As an existing user, explicitly select a future or past month and set my available amount for it to plan ahead or backfill data.

**Independent Test**: Navigate to a budget setup flow from an existing profile, verify fields auto-fill, and ensure saving creates a new target month bucket without altering historical data.

### Implementation for User Story 2

- [X] T014 [P] [US2] Add month/year picker UI component to `lib/features/budget_setup/presentation/budget_setup_screen.dart`
- [X] T015 [US2] Implement auto-fill logic fetching the previous month's data in `lib/features/budget_setup/providers/budget_setup_provider.dart`
- [X] T016 [US2] Implement isolated saving logic (strict buckets) for new month resets in `budget_setup_provider.dart`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Adjusting Settings (Priority: P3)

**Goal**: Change primary currency midway through the month from the settings screen.

**Independent Test**: Navigate to settings, change the currency, see the warning dialog, and verify the `UserProfile` updates successfully.

### Implementation for User Story 3

- [X] T017 [P] [US3] Create Settings provider in `lib/features/settings/providers/settings_provider.dart`
- [X] T018 [US3] Create Settings Screen UI in `lib/features/settings/presentation/settings_screen.dart`
- [X] T019 [US3] Implement currency change warning confirmation dialog in `settings_screen.dart`
- [X] T020 [US3] Add update logic to modify `UserProfile` primary currency in `settings_provider.dart`

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [X] T021 [P] Run dart format and flutter analyze across the project
- [X] T022 [P] Verify robust error handling (e.g., rejecting unsupported currencies)
- [X] T023 Run end-to-end validation scenarios documented in `quickstart.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2)
- **User Story 2 (P2)**: Extends User Story 1 (needs the base screen and provider logic)
- **User Story 3 (P3)**: Can start after Foundational (Phase 2), independent of US2, but requires UserProfile existence from US1.

### Parallel Opportunities

- Isar collection schemas (`user_profile.dart` and `monthly_budget.dart`) can be written in parallel during Phase 2.
- The Settings UI (US3) can be built in parallel with the Monthly Reset logic (US2).

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently against `quickstart.md`.
5. Only once stable, proceed to User Story 2.
