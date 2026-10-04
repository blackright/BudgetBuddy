# Implementation Plan: Available Amount Engine

**Branch**: `feature/002-available-amount-engine` | **Date**: 2026-10-04 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-available-amount-engine/spec.md`

## Summary

Implement the core calculation engine that determines the user's True Available amount, Safe-to-Spend amount, and Daily Pacing. The engine handles planned vs. paid states, multi-currency normalization, and end-of-month sweeps into a Savings Vault, utilizing Riverpod for real-time reactivity and Isar for offline-first persistence.

## Technical Context

**Language/Version**: Dart 3.x, Flutter 3.x

**Primary Dependencies**: flutter_riverpod, isar, isar_flutter_libs, dio (for exchange rates)

**Storage**: Isar Local Database

**Testing**: flutter_test, mockito

**Target Platform**: Android (primary), iOS, Web, Desktop

**Project Type**: mobile-app

**Performance Goals**: 60 fps, instant recalculations using Riverpod caches

**Constraints**: Fully functional offline

**Scale/Scope**: Mobile personal finance app

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Cross-Platform**: Uses Flutter and cross-platform Isar. (PASS)
- **Clean Architecture & Testability**: Business logic isolated in Riverpod providers, decoupled from UI. (PASS)
- **Offline-First**: Isar database acts as single source of truth; foreign exchange rates have offline manual fallback. (PASS)
- **Modular Financial Logic**: Strictly adheres to the Planned/Paid/Reimbursed rules dictated by the constitution. (PASS)
- **Security & Privacy First**: All data is local. (PASS)

## Project Structure

### Documentation (this feature)

```text
specs/002-available-amount-engine/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── database/        # Isar initialization and schemas
│   └── network/         # HTTP client (dio) for exchange rates
├── features/
│   ├── engine/          # Provider logic for Safe-to-Spend, True Available
│   ├── expenses/        # Models, Repositories, UI for adding expenses
│   └── vault/           # Sweep logic and Savings Vault UI
└── tests/
    └── features/
        └── engine/      # Unit tests for calculation math
```

**Structure Decision**: A standard feature-based Flutter structure. The calculation logic sits in a central `engine/` feature that acts as a downstream consumer of `expenses/` and `budget_setup/` data.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*(No violations. The offline fallback and caching align perfectly with the Offline-First mandate.)*
