# Phase 0 Research: Charts & Analytics (Unified)

**Feature**: 014-charts-and-analytics | **Date**: 2026-10-15

All Technical Context unknowns are resolved below. No item is left as NEEDS CLARIFICATION.

---

## R1 — Chart rendering library

**Decision**: Add `fl_chart: ^1.2.0`.

**Rationale**: Verified on pub.dev — latest `1.2.0`, MIT licence, depends only on `equatable`, `flutter`, `vector_math`. It ships exactly the three chart forms this feature needs (`LineChart` for trends, `BarChart` for planned-vs-paid, `PieChart` for category/contribution) plus built-in animation, touch callbacks (for drill-down), and legend support. It runs on every Flutter platform, so it does not violate Constitution I. The repo already adopts focused packages (`isar`, `go_router`, `qr_flutter`), so one more well-chosen dependency is consistent.

**Alternatives considered**:
- *Hand-rolled `CustomPainter` charts* — rejected (spec Clarification 2026-10-15): 7 charts with animation, touch and legends would be a large amount of bespoke, hard-to-test drawing code.
- *`charts_flutter`* — rejected: effectively archived and does not meet the animation/gesture needs.
- *Syncfusion / paid suites* — rejected: commercial licence and far more surface than needed.

**Compatibility note**: `fl_chart` 1.x targets recent Flutter; the project is Flutter 3.47.6 / Dart 3.13.5, which is comfortably newer.

---

## R2 — Aggregation architecture (the "One Chart Brain")

**Decision**: One pure, DB-free aggregation module (`lib/features/analytics/domain/chart_query.dart`) plus Riverpod providers keyed on the existing `budgetContextProvider`. **No chart reads Isar or converts currency on its own** (FR-001).

**Rationale**: This is the exact pattern the app already uses for the month verdict. `month_summary_provider.dart` watches `budgetContextProvider` and a repository stream, then calls the pure `MonthSummary.from(...)`. Chart providers mirror it: watch the context + a chart-filter provider, load rows through `analytics_repository.dart`, and pass them to pure `chart_query` functions that return typed `ChartSeries`. Because every chart for a given context and filter set runs the same pure function, the same total is guaranteed everywhere (SC-001) — two charts can never disagree.

**Alternatives considered**:
- *Each chart queries Isar itself* — rejected: 7 charts × 2 contexts × 4 currencies = many parallel math paths that will drift and disagree.
- *One giant stream holding raw rows, computed in the widget* — rejected: pushes aggregation into the UI, breaking testability and the performance budget.

---

## R3 — Multi-currency normalization and degraded-rate safety

**Decision**: Reuse the engine helpers unchanged — `expenseToDisplay(...)`, `reimbursementToDisplay(...)`, `resolveContextDisplayCurrency(month, main)`, and `rateRegistryProvider.tableFor(yearMonth)`. Charts never write their own conversion.

**Rationale**: The `currency_resolution.dart` doc states these are "the one conversion path" the app inherits. Reusing them guarantees a chart total matches the Dashboard summary for the same records. The existing `ConversionResult` already carries `isDegraded` and `isStale`, which is precisely the signal FR-005 needs.

**Degraded handling (FR-005, SC-005)**: When `convert` reports `isDegraded`, the chart (a) shows a "Rates unavailable" badge on the chart card, (b) keeps the value in its original currency for display labels, and (c) **excludes** that record from the normalized total rather than counting it as zero, reporting the exclusion count on the card. This is stricter than `toDisplay` (which returns `Money.zero`), because a chart that silently zeroes a row would misrepresent the picture — surfacing beats hiding, matching the existing "never invent a 1.0" rule in `rate_types.dart`.

**Alternatives considered**:
- *Show `0` for degraded rows* — rejected: violates FR-005 and the constitution's "never fabricate" spirit.
- *Block the whole chart when any row degrades* — rejected: too coarse; a mostly-good month should still render.

---

## R4 — Shared-member contribution attribution

**Decision**: In a shared context, group shared rows by `profileId` and join `SharedMember` for the member's role and display identity, ordering by contribution descending and **including members with zero** (FR-011).

**Rationale**: Shared rows (`Expense`, `MedicalBill`, `Reimbursement`) carry `sharedSpaceId` plus the recording profile's `profileId`. `SharedMember` is the unique (space, profile) membership row, so the join is unambiguous and gives the role for display. A member with no rows still has a `SharedMember` row, so they appear at zero.

**Open point carried forward**: A member's *display name* comes from their `UserProfile`; when that profile is not on this device (a synced remote member from feature 012), the contribution chart falls back to the membership's identity fingerprint rather than showing a blank. This is a display fallback only and does not affect totals.

---

## R5 — Mini vs full sizing (build once, show twice)

**Decision**: Each chart is one widget taking a `ChartSize { mini, full }` enum. Dashboard passes `mini`; the Analytics tab passes `full` (FR-002).

**Rationale**: A single widget means the Dashboard and the Analytics tab cannot drift. The enum controls only presentation density: axis labels, legend visibility, animation duration, and touch interaction (drill-down is enabled at full size only, to keep the dashboard glanceable).

**Alternatives considered**:
- *Separate mini and full widgets* — rejected: doubles the code and invites the two versions to disagree.

---

## R6 — Drill-down navigation (tap a segment → real records)

**Decision**: Segment taps emit a typed `ChartDrillDown` request (category, status, or member). `analytics_screen.dart` handles it by pushing the existing `/expenses` route with an optional filter argument. The expense list applies the filter.

**Rationale**: Reuses the existing list screen and route rather than building a second list (spec FR-008). The `/expenses` route already exists in `app_router.dart`; this adds an optional filter payload.

**Alternatives considered**:
- *A brand-new analytics-only list screen* — rejected: duplicate UI, violates DRY and the "reuse existing routes" requirement.
- *Only a tooltip, no navigation* — rejected: makes charts decorative (spec US3).

---

## R7 — Performance with large datasets

**Decision**: Aggregate once per context in the provider; never hand raw records to `fl_chart`. Auto-bucket the time series by range (per-day for ≤ 1 month, per-week for ≤ 6 months, per-month beyond) so the line chart has a bounded number of points.

**Rationale**: Satisfies FR-015 and SC-008 (smooth at 1000+ records). Because aggregation is pure and runs over rows already held in memory by the existing streams, recomputation is microseconds — the same reasoning `month_summary_provider.dart` documents.

**Alternatives considered**:
- *Draw one point per record* — rejected: unbounded point count, jank, unreadable axis.
- *Background isolate aggregation* — rejected: premature; the in-memory arithmetic is already microsecond-scale.

---

## R8 — Offline-first

**Decision**: Charts are fully local. Rates come from `rateRegistryProvider`, which reads local seals and a bundled fallback table; no network call is introduced.

**Rationale**: Constitution III requires every core feature to work without internet. Analytics is read-only over local Isar, so it is offline by construction.

---

## R9 — Empty and error states

**Decision**: Every chart renders through a `ChartCard` shell that owns two states: an **empty state** (context/month/filter has no data — a friendly illustration plus a hint, never a crash, FR-013) and the **degraded-rate badge** from R3.

**Rationale**: Centralising both states in one shell keeps every chart consistent and prevents any chart from inventing a value when there is none (SC-005).

---

## R10 — Testing strategy

**Decision**:
- *Pure unit tests* for `chart_query` (no Isar): assert the category total equals the spending total (SC-001), planned/paid/cancelled separation, medical split, and contribution grouping.
- *Widget tests* with fake `ChartSeries` objects (the repo's established pure-fake pattern): mini vs full, empty state, degraded badge.
- *Provider tests* for the lens switch: personal → shared re-derives every series, and the contribution chart appears only in shared (SC-004, SC-006).

**Rationale**: Keeps the expensive logic testable without a database and matches how the rest of the repo tests providers and widgets.

---

## Summary of resolved unknowns

| Unknown | Resolution |
|---|---|
| Chart library | `fl_chart: ^1.2.0` |
| Aggregation architecture | Pure `chart_query` + context-keyed Riverpod providers (mirrors `monthSummaryProvider`) |
| Currency normalization | Reuse `convert` + `expenseToDisplay`/`reimbursementToDisplay` + `rateRegistryProvider` |
| Degraded rates | Badge + exclude-from-total + exclusion count; never zero |
| Shared contribution | Group shared rows by `profileId`, join `SharedMember`, include zeros |
| Mini vs full | One widget, `ChartSize` enum |
| Drill-down | Typed request → existing `/expenses` route with filter |
| Performance | Aggregate once; auto-bucket the time series |
| Offline | Fully local; rates from local seals/bundled table |
| Empty/error | Centralised `ChartCard` shell states |
