# Contract: Chart UI (widgets, lens, drill-down, states)

**Feature**: 014-charts-and-analytics | **Version**: 1.0 | **Type**: UI contract

This is the contract for how charts are rendered and interacted with on the two surfaces (Dashboard and the Analytics tab). It enforces "build once, show twice" (FR-002) and the drill-down / state rules.

---

## 1. The chart widget contract (FR-002)

Every chart is **one** widget. It MUST NOT be split into separate mini and full implementations.

| Prop | Type | Meaning |
|---|---|---|
| `series` | `ChartSeries` | The data (from the data-layer contract). |
| `size` | `ChartSize` (`mini` \| `full`) | Density/interaction mode. |
| `onDrillDown` | `void Function(ChartDrillDown)?` | Segment-tap callback; only wired at `full` size. |

### `ChartSize` behaviour

| Aspect | `mini` (Dashboard) | `full` (Analytics) |
|---|---|---|
| Axis / category labels | Abbreviated or hidden | Full labels |
| Legend | Hidden | Visible |
| Animation | Short or none | Normal |
| Touch / drill-down | Disabled | Enabled |
| Height | ~120–160dp | ~220–280dp |

This single-widget rule is what guarantees the Dashboard and the Analytics tab cannot drift apart (SC-002).

---

## 2. Surfaces

### 2.1 Dashboard (`dashboard_screen.dart`)
- The existing `AnalyticsPlaceholderCard` is retired and replaced by a row/grid of **mini** charts: monthly spending, category breakdown, planned-vs-paid, plus the existing summary and quick actions.
- Mini charts are informational; they do not navigate.

### 2.2 Analytics tab (`/analytics`, `analytics_screen.dart`)
- Replaces the "Analytics Placeholder" body with a scrollable column of **full** charts.
- Renders, in order: monthly spending, category breakdown, planned-vs-paid, available-amount trend, medical insurance split.
- In `shared` lens additionally: shared-vs-personal comparison and member contribution.
- The `/analytics` route already exists; no new route is introduced for the screen itself.

---

## 3. The lens switch (FR-007, FR-011)

A single **Personal / Shared** switch sits at the top of the Analytics screen and applies to **every** chart on it.

| Rule | Requirement |
|---|---|
| Consistency | The lens resolves to the matching entry in `budgetContextProvider`; it never shows a context the app is not in. |
| Shared-only charts | Contribution and shared-vs-personal charts render **only** in `shared` lens. |
| No lingering | Changing the lens re-derives every visible series; no figure from the previous lens may remain (SC-004). |
| Shared with no space | If `shared` is selected but no space is active, show a friendly prompt to create/pair a space — not a crash. |

---

## 4. Chart card shell (states)

Every chart renders inside a `ChartCard` that owns two mandatory states:

### 4.1 Empty state (FR-013, SC-005)
When `series.isEmpty`, show a friendly illustration plus a short hint (e.g. "No expenses this month"). Never render an empty plot with fabricated axes, and never crash.

### 4.2 Degraded-rate badge (FR-005, SC-005)
When `series.degraded != null`, show a visible badge on the card, e.g.:

> ⚠️ Rates unavailable for some records — N excluded

The badge must state the display currency and make clear the total is partial. It must never silently show a lower number as if it were complete.

---

## 5. Drill-down (FR-008, SC-007)

| Rule | Requirement |
|---|---|
| Trigger | Tapping a pie slice or bar at `full` size emits a typed `ChartDrillDown`. |
| Handling | The Analytics screen handles the request by pushing the existing `/expenses` route with a filter payload. |
| Reuse | Drill-down reuses the existing expense list screen; it MUST NOT build a second list UI. |
| Empty segment | A segment with no underlying records opens an empty filtered list — never a crash. |
| Mini | Mini charts do not navigate. |

---

## 6. Accessibility and design (Constitution VI)

- Colors come from the theme / `Category.colorValue`, so dark mode works automatically.
- Planned, paid and reimbursed are visually distinct (consistent colour coding), per Constitution VI.
- All money labels use the single formatter `formatMoney` / `formatMinorUnits` — no chart hardcodes a symbol or rounding.
- Legends and axis text must meet contrast requirements in both themes.

---

## 7. Violations

A violation is: splitting a chart into two widgets; a mini chart that navigates; a lens that does not re-derive all series; a shared-only chart rendering in personal lens; an empty or degraded series rendered without its state; any chart formatting money without `money_format.dart`.
