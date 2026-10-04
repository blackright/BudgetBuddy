# Implementation Plan: Dashboard Shell & Navigation

**Branch**: `003-dashboard-shell` | **Date**: 2026-10-04 | **Spec**: [spec.md](file:///C:/dev/MobileDev/BudgetBuddy/specs/003-dashboard-shell/spec.md)

**Input**: Feature specification from `/specs/003-dashboard-shell/spec.md`

## Summary

Implement the foundational app shell and bottom tab navigation using `go_router` and `StatefulShellRoute`. This includes 5 primary tabs (Dashboard, Expenses, Medical Bills, Analytics, Settings) and connects the real-time financial metrics from the Available Amount Engine into the Dashboard placeholder.

## Technical Context

**Language/Version**: Dart 3.x, Flutter

**Primary Dependencies**: `go_router` (for routing), `flutter_riverpod` (for state/metrics access)

**Storage**: N/A for routing shell itself.

**Testing**: Flutter Widget Tests (for navigation and tab bar rendering), ProviderScope injection for mocking.

**Target Platform**: Android, iOS, Desktop, Web (Flutter multi-platform)

**Project Type**: Mobile App 

**Performance Goals**: < 100ms tab switching, 60 FPS transitions.

**Constraints**: Must be offline-first (inherent to client-side routing).

**Scale/Scope**: 5 main tabs with nested routes for the upcoming 39 features.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Cross-Platform & Mobile First**: Checked. Using Flutter's built-in `BottomNavigationBar` and `go_router` which scales across platforms.
- **Clean Architecture**: Checked. Routing logic will be isolated in a dedicated router provider.
- **Offline-First**: Checked. Routing is purely local.
- **Modular Financial Logic**: Checked. Dashboard placeholder correctly observes the existing providers (`trueAvailableProvider`, `safeToSpendProvider`).
- **Playful & Modern Design**: Checked. We will ensure the shell layout and tab bar adhere to Material 3 / Modern aesthetics.

## Project Structure

### Documentation (this feature)

```text
specs/003-dashboard-shell/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output 
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output 
```

### Source Code (repository root)

```text
lib/
├── core/
│   └── routing/
│       ├── app_router.dart          # go_router configuration & ShellRoute
│       └── router_providers.dart    # Riverpod providers for routing state
├── features/
│   ├── dashboard/
│   │   └── presentation/
│   │       ├── dashboard_screen.dart # Placeholder Dashboard showing metrics
│   │       └── widgets/
│   ├── expenses/
│   │   └── presentation/
│   │       └── expenses_screen.dart  # Placeholder
│   ├── medical/
│   │   └── presentation/
│   │       └── medical_screen.dart   # Placeholder
│   ├── analytics/
│   │   └── presentation/
│   │       └── analytics_screen.dart # Placeholder
│   └── settings/
│       └── presentation/
│           └── settings_screen.dart  # Placeholder
└── shared/
    └── presentation/
        └── app_shell.dart           # Scaffold containing the BottomNavigationBar
```

**Structure Decision**: A dedicated `core/routing` folder to centralize the `go_router` configuration, along with placeholder presentation screens in each respective feature folder, wrapped by a `shared/presentation/app_shell.dart`.
