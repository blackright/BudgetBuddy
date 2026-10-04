# Data Model: Available Amount Calculation Engine

## Overview
This feature introduces the core financial entities and the SavingsVault. We use **Isar** for offline-first, fast local storage.

## Entities

### Expense
- `id` (Id, auto-increment)
- `profileId` (int, index)
- `title` (String)
- `amount` (double)
- `currency` (String, e.g., 'USD', 'EUR')
- `exchangeRateToPrimary` (double, default 1.0)
- `status` (Enum: `Planned`, `Paid`, `Cancelled`)
- `type` (Enum: `Standard`, `Medical`)
- `date` (DateTime)
- `yearMonth` (String, e.g., "2026-10", index)

### Reimbursement
- `id` (Id, auto-increment)
- `expenseId` (int, index)
- `amount` (double)
- `date` (DateTime)

### SavingsVault
- `id` (Id, auto-increment)
- `profileId` (int, index, unique)
- `totalAmount` (double)
- `lastSweepYearMonth` (String, e.g., "2026-09")

## Rules & Constraints
- `Expense.exchangeRateToPrimary` is locked in at the time of the transaction to prevent historical budgets from shifting when rates change.
- `Reimbursement.amount` must be `<= Expense.amount`.
- A sweep operation updates `SavingsVault.totalAmount` by adding the leftover True Available and setting `lastSweepYearMonth` to the swept month.
