# Feature Specification: Charts & Analytics (Unified)

**Feature Branch**: `014-charts-and-analytics`
**Created**: 2026-10-15
**Status**: Draft

## Purpose

The app already stores every number the user needs, but it does not yet *show* them as pictures. Two places are explicitly waiting for this work:

1. The **Analytics tab** (`/analytics`) currently renders only the text "Analytics Placeholder".
2. The **Dashboard** has an `AnalyticsPlaceholderCard` that says "coming soon".

This feature replaces both with real charts, and turns raw financial data into visual insights:

- Dashboard mini-charts
- A full Analytics screen
- Monthly summaries and category breakdowns
- Trend analysis over time
- Shared vs personal analytics
- Multi-currency chart normalization
- Real-time recalculation

It is a **read-only** feature: it adds no persistent entity and changes no schema. It draws on data the app already has.

> **Correction to the raw idea:** the raw brief said "must use local persistence (Drift)". This app uses **Isar**, not Drift. The requirement below is corrected to Isar.

## Clarifications

### Session 2026-10-15

- Q: Which charting approach? → A: **Path A — add the `fl_chart` package.** Rejected hand-rolled `CustomPainter` charts: 7 charts with animations and gestures would mean a large amount of bespoke, hard-to-test drawing code.
- Q: How do we guarantee charts never disagree? → A: **One shared chart-data layer (`ChartQuery`).** No chart reads the database or does currency math on its own. Every chart consumes the same typed series, so the same month and filters always produce the same total wherever it appears.
- Q: How do we honour "never forget the shared space and the personal profile"? → A: **A single Personal/Shared lens switch** on the Analytics screen that applies to *every* chart, plus the active-context provider that already knows whether the current wallet is a personal profile or a shared space. Every chart is built to render in both worlds.
- Q: What happens when a month has no reliable exchange rates? → A: Charts stay **honest**. They show a clear "rates unavailable" warning and the original currency. They never invent a zero and never mix two currencies in one total.
- Q: Are charts static images or live? → A: **Live.** Charts are providers keyed by the active context and the selected month, so switching profile/space/month or editing a record rebuilds them immediately.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The placeholders become real charts (Priority: P1)

The Dashboard shows mini versions of the monthly-spending, category-breakdown, and planned-vs-paid charts, and the Analytics tab shows full-size versions of the same widgets. All three charts are fed by one shared data layer, so their numbers agree.

**Why this priority**: It replaces the two explicit placeholders and delivers the single most valuable part of the feature — seeing where money goes.

**Independent Test**: Open the Dashboard and confirm the three mini-charts render; open the Analytics tab and confirm the full charts show the *same* totals for the same context; compare the category-breakdown total against the monthly-spending total and confirm they match.

**Acceptance Scenarios**:

1. **Given** a month with expenses, **When** the user opens the Dashboard, **Then** mini charts for monthly spending, category breakdown, and planned vs paid are rendered.
2. **Given** the Dashboard mini category chart, **When** the user opens the Analytics tab, **Then** the full category chart shows the identical total.
3. **Given** two charts covering the same records, **When** both are rendered, **Then** their totals are equal to the last decimal place.
4. **Given** a month with no expenses, **When** either screen renders, **Then** each chart shows an empty state rather than crashing or showing fabricated values.

### User Story 2 - Every chart follows my wallet, my month, and my currency (Priority: P1)

Charts always describe the *active* context: a personal profile or a shared space, for the selected month, converted into the correct display currency. Switching any of these rebuilds every visible chart instantly. When a month's rates are missing or stale, the charts say so instead of guessing.

**Why this priority**: This is the user's explicit all-caps rule — shared space **and** personal profile must both be considered everywhere — and it is what makes the charts trustworthy.

**Independent Test**: Add an expense and confirm the charts update without leaving the screen; switch from a personal profile to a shared space and confirm every chart switches with it; open a month with no rate table and confirm a "rates unavailable" warning appears instead of a mixed-currency total.

**Acceptance Scenarios**:

1. **Given** the personal profile selected, **When** the user adds an expense, **Then** the affected charts rebuild immediately.
2. **Given** a personal profile selected, **When** the user switches to a shared space, **Then** every chart re-renders from that space's data and currency.
3. **Given** the selected month changes, **When** the new month loads, **Then** every chart shows the new month's data.
4. **Given** a month with a complete rate table, **When** expenses in several currencies are charted, **Then** all values are normalized into the display currency via the existing conversion helper.
5. **Given** a month with a missing or stale rate table, **When** a chart is rendered, **Then** a clear warning is shown and the original currency is used; no total mixes two currencies and no missing value is shown as zero.
6. **Given** a shared space with no data, **When** the shared lens is selected, **Then** the charts show an empty state, not the previous personal figures.

### User Story 3 - I can look inside a chart (Priority: P2)

Tapping a chart segment (a pie slice or a bar) opens the real list of the records behind it, using the existing list screens and routes.

**Why this priority**: A chart that only looks pretty is decoration; one that opens the actual records is a tool users can act on.

**Given** the category-breakdown chart, **When** the user taps the "Groceries" slice, **Then** the app opens the expense list filtered to that category.

**Acceptance Scenarios**:

1. **Given** the category chart, **When** the user taps a slice, **Then** the expense list for that category opens.
2. **Given** the planned-vs-paid chart, **When** the user taps the "paid" bar, **Then** the expense list for paid records opens.
3. **Given** a chart segment with no underlying records, **When** the user taps it, **Then** an empty list is shown, never a crash.

### User Story 4 - Shared and medical views appear where they make sense (Priority: P2)

In a shared space, Analytics adds the member-contribution chart and the shared-vs-personal comparison chart. It also includes the medical insurance breakdown chart (insurer-paid vs the user's share).

**Why this priority**: Valuable, but depends on the shared-context plumbing and the medical data already being present; it is an addition on top of the core charts.

**Independent Test**: Select a shared space and confirm the contribution chart lists each member and their total; confirm the medical insurance chart splits each bill into insurer-paid and user-payable.

**Acceptance Scenarios**:

1. **Given** a shared space with members and shared expenses, **When** the shared lens is selected, **Then** the contribution chart shows each member's share of shared income, expenses, and reimbursements.
2. **Given** a shared space, **When** the shared-vs-personal chart renders, **Then** it shows personal spending, shared spending, and the combined total.
3. **Given** a member with zero contributions, **When** the contribution chart renders, **Then** that member still appears with a zero value.
4. **Given** medical bills, **When** the insurance breakdown chart renders, **Then** each bill is split into insurer-paid and user-payable amounts.

### Edge Cases

- A month with only planned expenses → planned-vs-paid shows a zero paid bar and does not imply money has moved.
- A currency pair with no rate → warning badge shown; that record is excluded from normalized totals and disclosed as excluded, never silently zeroed.
- A shared space with a single member → contribution chart renders with one slice; comparison chart still separates personal from shared.
- Very large datasets → charts must not jank; data is aggregated in the shared data layer, not by drawing thousands of points.
- A record with a cancelled status → appears only under the cancelled filter, never in paid totals.
- Switching lens while a chart is animating → the chart settles on the new context's data.
- Reimbursements attributed to a different month than they were recorded in → counted in their origin month, matching the app's existing month rule.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: All charts MUST be fed by a single shared chart-data layer. No chart may query the database or perform currency conversion on its own.
- **FR-002**: The Dashboard MUST show mini charts, and the Analytics tab MUST show full-size versions of the *same* chart widgets, so the two views cannot drift apart.
- **FR-003**: Every chart MUST render for both a personal profile and a shared space, driven by the app's existing active-context provider.
- **FR-004**: Every monetary value in a chart MUST be converted into the display currency (profile currency for personal, space currency for shared) using the existing conversion helper — the same function the rest of the app uses.
- **FR-005**: When a month's rate table is missing, incomplete, or stale, charts MUST show a clear warning and the original currency, and MUST NOT show fabricated zeros or mix currencies within one total.
- **FR-006**: Charts MUST rebuild immediately when the active profile, the active shared space, the selected month, or any related expense, medical bill, or reimbursement changes.
- **FR-007**: The Analytics screen MUST provide a single Personal/Shared lens switch that applies to every chart on the screen.
- **FR-008**: Tapping a chart segment MUST open the corresponding filtered list of underlying records, reusing the app's existing routes and screens.
- **FR-009**: Storage for all chart source data MUST be Isar. The app does not use Drift.
- **FR-010**: Charts MUST be rendered with the `fl_chart` package; core chart drawing MUST NOT be hand-rolled with `CustomPainter`.
- **FR-011**: The member-contribution chart MUST appear only when a shared space is active, and MUST still render members whose contribution is zero.
- **FR-012**: Every chart MUST support filtering by date range, category, currency, status (planned/paid/reimbursed/cancelled), and personal vs shared.
- **FR-013**: Charts MUST show a graceful empty state when a context, month, or filter has no data, and MUST NOT crash.
- **FR-014**: This feature MUST be read-only: it MUST NOT add a persistent entity, change the Isar schema, or require a migration.
- **FR-015**: The dashboard mini-charts and the analytics full charts MUST remain smooth with large datasets by aggregating in the shared data layer rather than drawing raw records.

### Key Entities

No new persistent entities. The shared chart-data layer introduces **read-only view models** derived from data that already exists:

- `Expense` — amount, status, category, month, currency, owner (profile or space).
- `MedicalBill` — insurer-paid vs user-payable split.
- `Reimbursement` — amount attributed to its origin month.
- `MonthlyBudget` — planned figures.
- `SharedMember` — member identity for contribution totals.
- `UserProfile` / `SharedSpace` — display currency and active context.
- Rate data (`MonthRateSeal` / `RateTable`) — normalization and the degraded-rate signal.
- Derived (not stored): `ChartSeries`, `CategorySlice`, `DayBucket`, `MemberContribution`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For the same context and filters, the category-breakdown total equals the monthly-spending total exactly.
- **SC-002**: The Dashboard mini-charts and the Analytics full charts show identical totals for the same context and month.
- **SC-003**: Adding, editing, or deleting an expense, medical bill, or reimbursement rebuilds every visible chart without leaving the screen.
- **SC-004**: Switching profile, shared space, or month updates every chart to the new context; no figure from the previous context lingers.
- **SC-005**: A month with a degraded or missing rate table displays a warning and never a mixed-currency or fabricated total.
- **SC-006**: With the shared lens active, the contribution chart lists every member (including zero contributors) and the comparison chart separates personal from shared.
- **SC-007**: Tapping a chart segment opens the corresponding filtered record list.
- **SC-008**: Charts render smoothly with 1000+ expense records without visible jank.
- **SC-009**: `flutter analyze` reports zero issues and the full test suite is green with no regressions.

## Assumptions

- The `fl_chart` package is compatible with the project's Flutter and Dart versions.
- The existing `convert` helper, `MonthSummary`, and the active-context and selected-month providers are **reused, not rewritten**.
- The `/analytics` route and `AnalyticsScreen` already exist and are replaced in place; no new navigation is required.
- Analytics is read-only; it writes nothing and never mutates the database.
- The shared/personal distinction, and the month-attribution rule for reimbursements, follow the conventions already established by the engine and shared-spaces features.
