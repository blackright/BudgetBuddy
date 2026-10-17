# Phase 1 Data Model: Charts & Analytics (Unified)

**Feature**: 014-charts-and-analytics | **Date**: 2026-10-15

## 1. Overview

This feature is **read-only** (FR-014): it adds **no persistent entity**, changes **no Isar schema**, and requires **no migration**. Everything below either (a) names an existing collection that charts *read*, or (b) defines a **derived view model** — an in-memory object produced by the pure chart-data layer and discarded after rendering.

The only state this feature *owns* is transient UI state: the Personal/Shared lens and the active chart filters. Neither is persisted.

---

## 2. Source Entities (read-only)

These already exist. Charts read them; they never write them.

### 2.1 `Expense` (`lib/core/models/expense.dart`)
Fields the charts use: `id`, `profileId`, `sharedSpaceId?`, `yearMonth`, `type` (standard|medical), `title`, `amount` (whole minor units), `currency`, `categoryId`, `status` (planned|paid|cancelled|reimbursed|partiallyReimbursed), `date`, `budgetId`, `paidAt?`.

Ownership rule: exactly one of `profileId` / `sharedSpaceId` is set. Personal rows carry `profileId`; shared rows carry `sharedSpaceId`.

### 2.2 `MedicalBill` (`lib/core/models/medical_bill.dart`)
Fields used: `id`, `profileId?`, `sharedSpaceId?`, `linkedExpenseId?`, `yearMonth`, `billedAmount`, `currency`, `paymentMethod` (insurerPaid|selfPaid), `patientSharePercent`, `state`, derived `patientShareAmount`, `insurerPaidAmount`, `netOutOfPocket`, `countsAsPaid`.

> The insurer/user split is already computed on the model, so the insurance chart reuses it rather than recomputing (Constitution IV, v1.2.0 medical clause).

### 2.3 `Reimbursement` (`lib/features/expenses/models/reimbursement.dart`)
Fields used: `id`, `profileId`, `sharedSpaceId?`, `expenseId?`, `originYearMonth`, `orphaned`, `amount`, `currency`, `date`.

> Attribution is by `originYearMonth` — the month the money *belongs to*, never the month it was recorded in (FR-032).

### 2.4 `MonthlyBudget` (`lib/core/models/monthly_budget.dart`)
Fields used: `yearMonth`, `profileId?`, `sharedSpaceId?`, `baseAvailableAmount`, `openingBalanceConfirmed`, `currency?` (the month's convert-to override).

### 2.5 `SharedMember` (`lib/core/models/shared_member.dart`)
Fields used: `sharedSpaceId`, `profileId`, `role` (owner|editor|viewer), `joinedAt`, `revokedAt?`.

### 2.6 `UserProfile` / `SharedSpace`
Used for the display currency (profile main currency / space shared currency) and the member display name on the contribution chart.

### 2.7 `Category` (`lib/core/models/category.dart`)
Fields used: `categoryId`, `name`, `emoji`, `colorValue` — for the category chart's labels and colors.

### 2.8 `MonthRateSeal` / `RateTable` (`lib/core/network/rate_types.dart`)
Used for normalization and the degraded/stale signal. Read via `rateRegistryProvider.tableFor(yearMonth)`.

---

## 3. Derived View Models (in-memory, not persisted)

Defined in `lib/features/analytics/domain/chart_series.dart`.

### 3.1 `ChartSeries`
The single return type every chart consumes.

| Field | Type | Meaning |
|---|---|---|
| `kind` | `ChartKind` | spending, category, plannedPaid, availableTrend, insurance, contribution, sharedVsPersonal |
| `currency` | `CurrencyCode` | the display currency all values are already normalized into |
| `total` | `int` | headline total in **whole minor units** of `currency` |
| `isEmpty` | `bool` | true when there is nothing to draw (drives the empty state) |
| `buckets` | `List<DayBucket>` | time-series points (spending, availableTrend) |
| `slices` | `List<CategorySlice>` | proportional segments (category, insurance, contribution, sharedVsPersonal) |
| `bars` | `List<BarPair>` | planned-vs-paid pairs |
| `degraded` | `ChartDegradedState?` | non-null when rates were missing/stale |
| `excludedCount` | `int` | records dropped from the normalized total because their currency could not be converted |

### 3.2 `CategorySlice`
`categoryId`, `label`, `emoji`, `colorValue`, `minorUnits`, `fraction` (0–1), `statusFilter?`.

### 3.3 `DayBucket`
`label`, `minorUnits`, `date` (bucket start), `pointCount`.

### 3.4 `BarPair`
`label`, `plannedMinorUnits`, `paidMinorUnits`.

### 3.5 `MemberContribution`
`profileId`, `displayName`, `role`, `sharedExpenseMinorUnits`, `sharedReimbursementMinorUnits`, `netContributionMinorUnits`, `fraction`.

---

## 4. Transient UI State (owned by this feature)

### 4.1 `ChartLens` (`chart_lens_provider.dart`)
Enum `{ personal, shared }`. In `personal` mode the active context is the current profile; in `shared` mode it is the active space. The lens **must** be consistent with `budgetContextProvider.isShared` — selecting a lens resolves to the matching active context, and the contribution / shared-vs-personal charts render **only** in `shared` mode (FR-011).

### 4.2 `ChartFilters` (`chart_filters.dart`)
A value object, never persisted:

| Field | Type | Default |
|---|---|---|
| `dateRange` | `{start, end}?` | null (the selected month) |
| `categoryIds` | `Set<String>?` | null (all) |
| `currency` | `CurrencyCode?` | null (display currency) |
| `statuses` | `Set<ExpenseStatus>?` | null (all) |

**Validation rule (FR-012)**: filters compose as AND across fields and OR within a field. A null field means "no restriction".

### 4.3 `ChartDrillDown`
A typed request emitted by a segment tap, handled by the presentation layer:

| Variant | Payload | Navigates to |
|---|---|---|
| `category` | `categoryId`, optional `status` | `/expenses` filtered to that category |
| `status` | `status` | `/expenses` filtered to that status |
| `member` | `profileId` | `/expenses` filtered to that shared member |

---

## 5. State Transitions

There are no domain state transitions (the feature is read-only). The only transitions are UI:

- **Lens**: `personal ↔ shared`. On change, every visible `ChartSeries` is re-derived from the newly active context; no value from the previous lens may linger (SC-004).
- **Filters**: applied/cleared. On change, all series re-derive; totals must stay internally consistent (SC-001).
- **Selected month / active profile / active space**: any change re-derives all series (FR-006).

---

## 6. Validation Rules (from requirements)

1. Every monetary value in a `ChartSeries` is in `series.currency` — never a mix (FR-004, SC-005).
2. A record whose currency cannot be converted is **excluded** from `total` and counted in `excludedCount`, never zeroed (FR-005).
3. Cancelled expenses never appear in paid totals; planned never reduces a paid figure (Constitution IV).
4. Medical appears in general totals as an ordinary category via the single existing source, so no two charts disagree (Constitution IV).
5. Reimbursements are attributed by `originYearMonth` (FR-032).
6. The contribution chart lists **every** member of the active space, including zero contributors (FR-011).
7. `total` equals the sum of the chart's own slices/buckets for the same filters (SC-001 invariant).

---

## 7. Invariants

- **Single source of truth**: the chart-data layer is the only place aggregation happens; presentation never re-aggregates.
- **Consistency**: for a fixed (context, filters, month), the derived series are deterministic and reproducible.
- **No writes**: the feature performs zero `put`/`delete` operations on any collection.
