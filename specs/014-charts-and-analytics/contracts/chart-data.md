# Contract: Chart Data Layer (the "One Chart Brain")

**Feature**: 014-charts-and-analytics | **Version**: 1.0 | **Type**: internal module interface

This is the contract between the chart **presentation** layer and the chart **data** layer. It exists to guarantee the feature's central promise: **no chart queries the database or converts currency on its own** (FR-001), so every chart shows the same total for the same context and filters.

---

## 1. Scope and ownership

- The data layer owns all aggregation and all currency normalization.
- The presentation layer owns rendering and interaction only; it MUST NOT re-aggregate or convert.
- The layer is **pure**: the aggregation functions take plain inputs and return plain outputs. No Isar, no clock, no globals — so they unit-test without a database.

---

## 2. Inputs

Every aggregation is a function of exactly three things:

| Input | Source | Notes |
|---|---|---|
| `ContextRef` | `budgetContextProvider` | Exactly one of `profileId` / `spaceId`; carries `yearMonth`. |
| `ChartFilters` | `chart_lens_provider` / `chart_filters.dart` | Date range, categories, currency, statuses. Null field = no restriction. |
| Source rows | `analytics_repository.dart` | Expenses, medical bills, reimbursements, budgets, members — already scoped to the context. |

Currency normalization inputs (never chosen by a chart): display currency via `resolveContextDisplayCurrency(month, main)` and the rate table via `rateRegistryProvider.tableFor(yearMonth)`.

---

## 3. Output

All functions return `ChartSeries` (see `data-model.md` §3). The contract guarantees:

1. **Currency integrity** — every monetary field in the returned series is denominated in `series.currency`. Mixing currencies within a series is a contract violation.
2. **Total consistency** — `series.total` equals the sum of that series' own buckets/slices/bars for the same filters (SC-001).
3. **Degraded honesty** — when conversion for any record is degraded (`ConversionResult.isDegraded`), the record is **excluded** from `total`, `series.degraded` is populated, and `series.excludedCount` reflects the number excluded. A degraded record is never counted as zero (FR-005).
4. **Empty honesty** — when there is nothing to draw, `series.isEmpty` is true and totals are zero. The layer never invents a value.
5. **Determinism** — for identical `(context, filters, rows, rateTable)` inputs, the output is identical.

---

## 4. Aggregation functions

Located in `lib/features/analytics/domain/chart_query.dart`. All pure.

| Function | Returns | Chart |
|---|---|---|
| `spendingSeries(...)` | `ChartSeries` (buckets) | Monthly spending (per-day/week/month auto-bucketed) |
| `categorySeries(...)` | `ChartSeries` (slices) | Category breakdown |
| `plannedPaidSeries(...)` | `ChartSeries` (bars) | Planned vs paid |
| `availableTrendSeries(...)` | `ChartSeries` (buckets) | Available-amount trend |
| `insuranceSeries(...)` | `ChartSeries` (slices) | Medical insurer vs user split |
| `contributionSeries(...)` | `ChartSeries` (slices) | Shared member contribution |
| `sharedVsPersonalSeries(...)` | `ChartSeries` (slices) | Shared vs personal vs combined |

### 4.1 Bucketing rule (performance, FR-015)
The time-series functions auto-bucket so point count stays bounded:

| Range span | Bucket |
|---|---|
| ≤ 1 month | per day |
| ≤ 6 months | per week |
| > 6 months | per month |

### 4.2 Contribution rule (FR-011)
`contributionSeries` groups shared rows by `profileId`, joins `SharedMember` for role/identity, and **includes members with zero** contributions, ordered by `netContributionMinorUnits` descending. Members whose profile is absent locally (a synced remote member) fall back to the membership identity for the display label only; totals are unaffected.

---

## 5. Consumer obligations

The presentation layer MUST:

- Feed a chart only the series for the **active** context (never a cached series from a previous context).
- Render `degraded` and `excludedCount` when present.
- Render the empty state when `isEmpty` is true.
- Not perform its own arithmetic on monetary values.

---

## 6. Violations

A violation is any of: a chart querying Isar directly; a chart calling `convert` itself; a series containing two currencies; a degraded record counted as zero; an `isEmpty` series rendered with fabricated data. All break SC-001/SC-005 and must fail review.
