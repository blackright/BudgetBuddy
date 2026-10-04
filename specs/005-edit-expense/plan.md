# Implementation Plan: Edit Expense

**Branch**: `005-edit-expense` | **Date**: 2026-10-04 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `c:\dev\MobileDev\BudgetBuddy\specs\005-edit-expense\spec.md`

## Summary

This feature adds the ability to modify existing expenses, integrating swipe gestures on the expense list for quick actions (toggle paid/planned, edit, delete), duplicate an expense, and provides a smart overspend warning based on the delta changes, instantly updating `safeToSpend` and `trueAvailable` in the engine.

## Technical Context

**Language/Version**: Dart 3.x, Flutter

**Primary Dependencies**: flutter_riverpod, isar, go_router, flutter_slidable (or similar for swipe actions)

**Storage**: Isar Local Database

**Testing**: flutter test

**Target Platform**: Android (primary), iOS

**Project Type**: Mobile App

**Performance Goals**: Instant UI updates via Riverpod. 60 fps for swipe gestures.

**Constraints**: Must work offline-first. Safe to spend delta calculations must be exact.

**Scale/Scope**: All historical and active expenses.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Cross-Platform**: Uses standard Flutter packages (like `flutter_slidable` or native `Dismissible`). Passes.
- **Clean Architecture & Testability**: Updates existing `ExpenseProvider` and Riverpod state. Passes.
- **Offline-First & Synchronization**: Relies on Isar database. Passes.
- **Modular Financial Logic**: Properly recalculates delta impacts on available amount (Planned/Paid/Reimbursed). Passes.
- **Playful & Modern Design**: Implements smart alerts and swipe gestures. Passes.

## Project Structure

### Documentation (this feature)

```text
specs/005-edit-expense/
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
│   ├── routing/
│   │   └── app_router.dart (Add edit_expense route)
│   └── models/
│       └── expense.dart (No schema changes required, but might need a copyWith method)
├── features/
│   ├── expenses/
│   │   ├── presentation/
│   │   │   ├── expenses_screen.dart (Add swipe actions)
│   │   │   └── edit_expense_screen.dart (New screen, reusing AddExpense components)
│   │   └── providers/
│   │       └── expenses_provider.dart (Add edit, delete, duplicate methods)
│   └── dashboard/
│       └── presentation/
│           └── dashboard_screen.dart
```

**Structure Decision**: Will reuse existing Clean Architecture layers. The `edit_expense_screen.dart` will be added to `features/expenses/presentation/`. Swipe gestures will be added to the existing `expenses_screen.dart`.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
