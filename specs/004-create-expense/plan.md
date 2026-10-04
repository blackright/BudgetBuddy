# Implementation Plan: Create Expense

**Branch**: `feature/004-create-expense` | **Date**: 2026-10-04 | **Spec**: [spec.md](file:///c:/dev/MobileDev/BudgetBuddy/specs/004-create-expense/spec.md)

**Input**: Feature specification from `/specs/004-create-expense/spec.md`

## Summary

Implement the core "Create Expense" flow using Flutter, Riverpod, and Isar. The user can create expenses (planned or paid) with gamified emotional tags ("Guilt Level"), photo attachments, and a reimbursable flag. These immediately update the dashboard's `safeToSpend` and `trueAvailable` metrics via Riverpod.

## Technical Context

**Language/Version**: Dart 3.3+, Flutter 3.19+
**Primary Dependencies**: flutter_riverpod, isar, go_router
**Storage**: Isar local database
**Testing**: flutter_test (Widget and Unit tests)
**Target Platform**: Android / iOS / Web
**Project Type**: Mobile App
**Performance Goals**: Instant UI updates (< 16ms), DB writes under 50ms
**Constraints**: Offline-first, must work without internet.
**Scale/Scope**: Local personal finance tracking, typically < 10,000 expense records per user.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Project favors local-first architecture (Isar fits perfectly).
- Project uses Riverpod for reactive state.
- Vibe is playful and gamified (Guilt Levels, Reimbursable toggle).
- Feature is well-scoped and doesn't introduce external network dependencies.
- **Result: PASS**

## Project Structure

### Documentation (this feature)

```text
specs/004-create-expense/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (to be generated)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── models/
│   │   ├── expense.dart
│   │   └── expense_template.dart
│   └── routing/
│       └── app_router.dart (update routes)
├── features/
│   ├── expenses/
│   │   ├── presentation/
│   │   │   ├── add_expense_screen.dart
│   │   │   └── widgets/ (receipt picker, emotion selector)
│   │   └── providers/
│   │       └── expenses_provider.dart
└── tests/
    ├── unit/
    │   └── expenses_provider_test.dart
    └── widget/
        └── add_expense_screen_test.dart
```

**Structure Decision**: Standard feature-based architecture utilizing Riverpod providers and Isar models within `lib/core/models` and `lib/features/expenses`.
