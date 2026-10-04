# Phase 0: Research for Create Expense

## Overview
This feature introduces the core action of logging expenses into BudgetBuddy. Based on the technical context and project structure, all major technology choices are clear and align with the existing stack (Flutter, Riverpod, Isar).

## Decisions

### Local Storage for Expense and Templates
- **Decision**: Use Isar database.
- **Rationale**: Isar is already configured in the project and used for MonthlyBudget and Vaults. It is offline-first, extremely fast, and supports relationships and indexes perfectly.
- **Alternatives considered**: Hive or SQLite. Rejected because Isar is already in the project and is the intended persistence layer.

### State Management for Quick Adds
- **Decision**: Use Riverpod for providers managing the dashboard summary (safeToSpend, trueAvailable).
- **Rationale**: Standard project architecture. We will introduce an `expensesProvider` or update the existing budget providers to reactively listen to Isar changes via streams.
- **Alternatives considered**: StatefulWidgets or Provider. Rejected in favor of the established Riverpod pattern.
