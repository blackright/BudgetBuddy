# Implementation Plan: Medical Bills & Insurance

**Branch**: `007-medical-bills-insurance` | **Date**: 2026-10-04 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/007-medical-bills-insurance/spec.md`

## Summary

This feature implements a holistic Health & Insurance Tracker that models medical bills with insurance coverage and links them to the core `Expense` engine for seamless budget impact calculations and deductible tracking.

## Technical Context

**Language/Version**: Dart 3.x, Flutter 3.x

**Primary Dependencies**: Flutter, Riverpod, Isar

**Storage**: Local Isar Database

**Testing**: Flutter unit/widget tests

**Target Platform**: Cross-platform (Android-first)

**Project Type**: Mobile Application

**Performance Goals**: Instant offline calculations, fast UI rendering

**Constraints**: Offline-first, strict `safeToSpend` math

**Scale/Scope**: Local personal finance tracker

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Cross-Platform & Mobile First**: Yes, building in Flutter.
- **Clean Architecture**: Yes, using Riverpod and decoupled repositories.
- **Offline-First & Synchronization**: Yes, purely Isar-based.
- **Modular Financial Logic**: Yes, integrates with `Expense` correctly. Reimbursed logic respects `trueAvailable`.
- **Security**: N/A for this specific UI change.
- **Playful & Modern Design**: Reusing existing UI elements (Hero, Timeline).

## Project Structure

### Documentation (this feature)

```text
specs/007-medical-bills-insurance/
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
│   ├── models/
│   │   ├── medical_bill.dart
│   │   └── insurance_profile.dart
├── features/
│   ├── medical/
│   │   ├── presentation/
│   │   │   ├── medical_dashboard.dart
│   │   │   ├── medical_bill_form.dart
│   │   │   └── medical_detail_screen.dart
│   │   ├── providers/
│   │   │   └── medical_providers.dart
│   │   └── repositories/
│   │       └── medical_repository.dart
```

**Structure Decision**: A new `medical` feature folder inside `lib/features/` keeps the medical-specific logic encapsulated, while models go into `core/models/` for Isar code generation alongside `Expense`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*No violations.*
