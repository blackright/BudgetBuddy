# Feature Specification: Dashboard Shell & Navigation

**Feature Branch**: `[003-dashboard-shell]`

**Created**: 2026-10-04

**Status**: Draft

**Input**: User description: "Dashboard Shell & Navigation..."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Initial App Load & Routing (Priority: P1)

After the user successfully completes the Budget Setup, they should be automatically routed to the Dashboard tab within the App Shell. 

**Why this priority**: It connects the previous feature (Budget Setup) to the new layout and ensures users can enter the main app.

**Independent Test**: Can be fully tested by simulating budget setup completion and ensuring the app correctly transitions to the `/dashboard` route inside the ShellRoute.

**Acceptance Scenarios**:

1. **Given** a user completes budget setup, **When** they submit, **Then** they are routed to `/dashboard`.
2. **Given** a returning user with a budget, **When** they launch the app, **Then** they are immediately routed to `/dashboard`.

---

### User Story 2 - Bottom Tab Navigation (Priority: P1)

The user can freely navigate between 5 primary tabs (Dashboard, Expenses, Medical Bills, Analytics, Settings) using a persistent bottom navigation bar.

**Why this priority**: Core navigation paradigm for the entire app.

**Independent Test**: Can be fully tested by tapping all 5 tabs and verifying the content area updates while the bottom bar remains visible.

**Acceptance Scenarios**:

1. **Given** the user is on Dashboard, **When** they tap 'Expenses', **Then** the URL updates to `/expenses` and the content changes to the Expenses placeholder.
2. **Given** the user navigates between tabs, **When** they tap repeatedly, **Then** navigation must be instant without lag.

---

### User Story 3 - Nested Navigation & Tab State (Priority: P2)

When a user navigates deeper into a feature (e.g., adding an expense), the bottom navigation bar should remain visible. If they switch tabs and return, their nested state is preserved.

**Why this priority**: Essential for a modern, stateful tabbed experience.

**Independent Test**: Can be fully tested by pushing a nested route inside the Expenses tab, switching to the Dashboard, and switching back to Expenses.

**Acceptance Scenarios**:

1. **Given** the user is at `/expenses`, **When** they navigate to `/expenses/add`, **Then** the bottom bar remains visible.
2. **Given** the user is at `/expenses/add`, **When** they switch to Dashboard and then back to Expenses, **Then** they should still see the `/expenses/add` screen (state preservation).

---

### User Story 4 - Dashboard Overview (Priority: P2)

The user can view their real-time financial status directly on the Dashboard tab, powered by the Available Amount Engine.

**Why this priority**: Provides immediate value and context to the user based on previous features.

**Independent Test**: Can be fully tested by injecting mock values into the Riverpod providers (`trueAvailable`, `safeToSpend`) and verifying the UI reflects them.

**Acceptance Scenarios**:

1. **Given** the dashboard is loaded, **When** the providers emit new values, **Then** the UI updates to show `trueAvailable` and `safeToSpend`.
2. **Given** the dashboard is active, **When** the user taps Quick Actions, **Then** it navigates to the respective Add Expense/Medical Bill routes.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST use `go_router` with a `ShellRoute` (or `StatefulShellRoute`) to implement the root navigation structure.
- **FR-002**: System MUST define top-level route branches for `/dashboard`, `/expenses`, `/medical`, `/analytics`, and `/settings`.
- **FR-003**: System MUST display a `BottomNavigationBar` (or equivalent) containing icons for the 5 primary routes.
- **FR-004**: System MUST handle invalid routes by redirecting to `/dashboard`.
- **FR-005**: System MUST display a dashboard UI consuming `trueAvailableProvider` and `safeToSpendProvider`.
- **FR-006**: System MUST provide placeholder screens for all non-dashboard tabs to prevent crashes.

### Key Entities

*(No specific database entities; relies on routing state and existing engine providers)*

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Tab switching occurs in under 100ms with no visual jank (measured in Flutter profile mode).
- **SC-002**: Bottom navigation bar is visible 100% of the time on top-level routes and standard nested routes.
- **SC-003**: The app gracefully handles deep links to all 5 primary tabs without crashing.
- **SC-004**: Dashboard UI correctly formats and displays currency values from the engine providers.

## Assumptions

- We will use `StatefulShellRoute` in `go_router` to preserve navigation state across tabs (standard practice for Flutter apps).
- The "Quick Actions" on the dashboard will just be placeholder buttons that navigate to dummy routes for now, until the specific features are implemented.
- Offline support is inherent since `go_router` routes entirely client-side.
