# Implementation Tasks: Dashboard Shell & Navigation

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Add `go_router` dependency to `pubspec.yaml` (if not already present)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**🚨 CRITICAL**: No user story work can begin until this phase is complete

- [x] T002 Create `lib/shared/presentation/app_shell.dart` containing a `StatefulNavigationShell` and `BottomNavigationBar`
- [x] T003 Create `lib/core/routing/app_router.dart` defining the `go_router` instance and root `StatefulShellRoute`
- [x] T004 Create `lib/core/routing/router_providers.dart` defining the Riverpod provider for the router

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Initial App Load & Routing (Priority: P1) 🚀 MVP

**Goal**: Automatically route users to the Dashboard tab after Budget Setup

**Independent Test**: Can be fully tested by simulating budget setup completion and ensuring the app correctly transitions to the `/dashboard` route inside the ShellRoute.

### Tests for User Story 1
> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**
- [x] T005 [P] [US1] Create widget test for initial routing in `test/core/routing/initial_routing_test.dart`

### Implementation for User Story 1
- [x] T006 [US1] Update `lib/main.dart` to use `routerConfig` instead of `home` parameter
- [x] T007 [US1] Modify `lib/features/budget_setup/presentation/budget_setup_screen.dart` to use `context.go('/dashboard')` upon completion instead of custom navigation logic
- [x] T008 [US1] Set initial location of `go_router` to check if a budget exists, and route to `/dashboard` or `/setup` accordingly

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Bottom Tab Navigation (Priority: P1)

**Goal**: Navigate between 5 primary tabs using a persistent bottom navigation bar

**Independent Test**: Can be fully tested by tapping all 5 tabs and verifying the content area updates while the bottom bar remains visible.

### Implementation for User Story 2
- [x] T009 [P] [US2] Create placeholder `lib/features/dashboard/presentation/dashboard_screen.dart`
- [x] T010 [P] [US2] Create placeholder `lib/features/expenses/presentation/expenses_screen.dart`
- [x] T011 [P] [US2] Create placeholder `lib/features/medical/presentation/medical_screen.dart`
- [x] T012 [P] [US2] Create placeholder `lib/features/analytics/presentation/analytics_screen.dart`
- [x] T013 [P] [US2] Create placeholder `lib/features/settings/presentation/settings_screen.dart`
- [x] T014 [US2] Add the 5 branches and their respective routes (`/dashboard`, `/expenses`, etc.) to the `StatefulShellRoute` in `app_router.dart`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Nested Navigation & Tab State (Priority: P2)

**Goal**: Retain bottom bar visibility and navigation state when routing deeper into a tab

**Independent Test**: Can be fully tested by pushing a nested route inside the Expenses tab, switching to the Dashboard, and switching back to Expenses.

### Implementation for User Story 3
- [x] T015 [P] [US3] Create a dummy nested screen `lib/features/expenses/presentation/add_expense_placeholder.dart`
- [x] T016 [US3] Add a sub-route `add` under the `/expenses` branch in `app_router.dart`
- [x] T017 [US3] Add a button in `ExpensesScreen` to `context.go('/expenses/add')` to verify state preservation

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: User Story 4 - Dashboard Overview (Priority: P2)

**Goal**: Display real-time financial status directly on the Dashboard tab

**Independent Test**: Can be fully tested by injecting mock values into the Riverpod providers (`trueAvailable`, `safeToSpend`) and verifying the UI reflects them.

### Implementation for User Story 4
- [x] T018 [US4] Update `DashboardScreen` in `lib/features/dashboard/presentation/dashboard_screen.dart` to watch `trueAvailableProvider` and `safeToSpendProvider`
- [x] T019 [US4] Implement the Dashboard Hero section UI to clearly display the available and safe-to-spend amounts
- [x] T020 [US4] Add "Quick Actions" placeholder buttons to the Dashboard UI

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [x] T021 [P] Run `dart format` on all newly created files
- [x] T022 [P] Ensure no hardcoded strings are used in the navigation bar items (use translation keys if available)
- [x] T023 Run quickstart.md validation to ensure deep linking and tab switching behaves smoothly

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed sequentially (US1 -> US2 -> US3 -> US4) or in parallel.
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2)
- **User Story 2 (P1)**: Can start after Foundational (Phase 2). Highly independent.
- **User Story 3 (P2)**: Depends on User Story 2 (needs the tab screens and branches).
- **User Story 4 (P2)**: Depends on User Story 2 (Dashboard screen).

### Within Each User Story

- Placeholder screens before router updates
- Core implementation before integration
- Story complete before moving to next priority

### Parallel Opportunities

- All placeholder screens in User Story 2 marked [P] can be created in parallel.

---

## Parallel Example: User Story 2

```bash
# Launch all placeholder screens for User Story 2 together:
Task: "Create placeholder lib/features/dashboard/presentation/dashboard_screen.dart"
Task: "Create placeholder lib/features/expenses/presentation/expenses_screen.dart"
Task: "Create placeholder lib/features/medical/presentation/medical_screen.dart"
Task: "Create placeholder lib/features/analytics/presentation/analytics_screen.dart"
Task: "Create placeholder lib/features/settings/presentation/settings_screen.dart"
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

1. Complete Setup + Foundational -> Foundation ready
2. Add User Story 1 -> Test independently -> Deploy/Demo (MVP!)
3. Add User Story 2 -> Test independently -> Deploy/Demo
4. Add User Story 3 -> Test independently -> Deploy/Demo
5. Add User Story 4 -> Test independently -> Deploy/Demo
6. Each story adds value without breaking previous stories
