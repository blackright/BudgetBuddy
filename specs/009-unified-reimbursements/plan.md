# Implementation Plan: Unified Reimbursements

**Branch**: `009-unified-reimbursements` | **Date**: 2026-10-05 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/009-unified-reimbursements/spec.md`

## Summary

Provide a complete system for recording reimbursements for both expenses and medical bills, ensuring correct financial adjustments, enforcing validation rules, and integrating tightly with availableAmount calculation, while supporting multi-event history, note/source tracking, and cross-currency conversions. 
Technical approach involves a standalone Isar `Reimbursement` collection tied to expenses via `sourceId`.

## Technical Context

**Language/Version**: Dart 3.x, Flutter

**Primary Dependencies**: flutter_riverpod, isar

**Storage**: Isar local database

**Testing**: flutter_test

**Target Platform**: Android (primary), iOS, Web

**Project Type**: Mobile App

**Performance Goals**: Instant recalculation of `availableAmount`

**Constraints**: Offline-first, deterministic validation rules

**Scale/Scope**: Dozens of reimbursements per month, seamless integration with existing expense streams

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Uses Clean Architecture & testability (Riverpod, Repositories).
- [x] Offline-first & local storage (Isar).
- [x] Real-time availability: Reimbursed increases available amount (complies with Principle IV).
- [x] Medical Bills logic: Reimbursement respects the updated `userPayableAmount` rule (Principle IV amended 1.2.0).
- [x] Multi-Currency: Supported in the feature spec.

## Project Structure

### Documentation (this feature)

```text
specs/009-unified-reimbursements/
├── plan.md              
├── research.md          
├── data-model.md        
├── quickstart.md        
└── tasks.md             # (to be created in next phase)
```

### Source Code (repository root)

```text
lib/
├── features/
│   ├── expenses/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── repositories/
│   ├── medical/
│   │   ├── presentation/
│   │   └── repositories/
│   └── finance/
│       └── providers/
└── core/
    └── database/
        └── collections/
```

**Structure Decision**: Single Flutter project structure following standard feature-sliced domains (expenses, medical, finance). `Reimbursement` entity will likely reside in `core/database/collections` or `features/expenses/domain` depending on existing architecture, with repositories interacting with it.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*No violations detected.*
