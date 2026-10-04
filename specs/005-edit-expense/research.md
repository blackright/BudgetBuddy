# Phase 0: Research

All technical choices are clear based on the project's existing architecture.

- **Decision 1**: Use standard Flutter `Dismissible` or `flutter_slidable` package for list swipe actions.
  - **Rationale**: `flutter_slidable` provides multi-action swipe (Edit on one side, Status toggle on the other). If not already in `pubspec.yaml`, `flutter_slidable` will be added.
- **Decision 2**: Handle delta calculations inside the `ExpensesProvider` or the Engine when an expense is updated in Isar.
  - **Rationale**: Centralizing the delta logic ensures that `safeToSpend` and `trueAvailable` are updated correctly without scattering logic in the UI.
