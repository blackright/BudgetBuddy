# Research & Decisions: Dashboard Shell & Navigation

## Routing Solution
- **Decision**: Use `go_router` with `StatefulShellRoute`.
- **Rationale**: `go_router` is the official and most robust declarative routing package for Flutter. `StatefulShellRoute` specifically allows preserving the state of nested navigators (meaning if a user scrolls down a list in the Expenses tab, switches to Settings, and switches back, their scroll position and state are maintained).
- **Alternatives considered**: `auto_route` (more complex code generation overhead), standard `Navigator 2.0` (too verbose and difficult to maintain).

## App Shell Architecture
- **Decision**: Create a `Scaffold` in `app_shell.dart` that contains a `BottomNavigationBar` (or `NavigationBar` for Material 3) and accepts a `navigationShell` widget to render the active tab's content.
- **Rationale**: Keeps the visual shell decoupled from the actual route definitions. It aligns perfectly with `go_router`'s `StatefulShellRoute.indexedStack` builder paradigm.

## Metrics Integration
- **Decision**: In `dashboard_screen.dart`, use `ConsumerWidget` to watch `trueAvailableProvider` and `safeToSpendProvider` from the existing Available Amount Engine feature.
- **Rationale**: Directly integrates the core financial logic defined in previous phases into the UI without duplicating any logic or state management.
