# Quickstart: Charts & Analytics (Unified)

**Feature**: 014-charts-and-analytics | **Date**: 2026-10-15

A runnable validation guide. It proves the feature works end-to-end. Implementation details live in `tasks.md`; this file is only how to *verify*. For what the data and widgets must do, see [`contracts/chart-data.md`](./contracts/chart-data.md) and [`contracts/chart-ui.md`](./contracts/chart-ui.md).

---

## Prerequisites

- Flutter 3.47.6 / Dart 3.13.5 (project baseline).
- `fl_chart: ^1.2.0` added to `pubspec.yaml` dependencies (R1).
- A device or emulator (project's test device: SM G965F).

> **Local note**: on this machine a hung `dart.exe`/`dartvm.exe` can hold Flutter's startup lock. If commands hang, prefix with `$env:FLUTTER_ALREADY_LOCKED='true';`.

---

## Setup

```bash
flutter pub get
```

Expected: dependencies resolve, including `fl_chart 1.2.0`.

---

## Gate commands

```bash
dart format .
flutter analyze      # expect: No issues found!
flutter test         # expect: all tests pass, 0 failed
```

Expected: `flutter analyze` reports zero issues and the new analytics tests are green. If either fails, the feature is not ready regardless of what the UI shows.

---

## Validation scenarios

Each scenario maps to a success criterion in [`spec.md`](./spec.md).

### V1 — Placeholders become real charts (SC-001, SC-002)

1. `flutter run`
2. Open the **Dashboard**. Confirm mini charts for monthly spending, category breakdown, and planned-vs-paid render where the "coming soon" card used to be.
3. Open the **Analytics** tab. Confirm full-size versions of the same charts appear (no "Analytics Placeholder" text).
4. Compare the category total on the Dashboard against the Analytics category total.

**Pass**: the totals are identical. This is the "One Chart Brain" guarantee (see `chart-data.md` §3.2).

### V2 — Charts rebuild live (SC-003)

1. On the Analytics tab, note a chart total.
2. Add an expense for the selected month without leaving the screen.

**Pass**: the affected charts update immediately, with no manual refresh.

### V3 — Personal ↔ Shared lens (SC-004, SC-006)

1. With a personal profile active, open Analytics; confirm charts show personal data.
2. Switch the lens to **Shared** (with a space active and containing shared rows).

**Pass**: every chart re-derives to the shared space's data and currency; the member-contribution and shared-vs-personal charts appear; no personal figure lingers. Switching back reverts cleanly.

### V4 — Degraded rates are honest (SC-005)

1. Select/construct a month whose rate table is missing or stale.
2. Open Analytics.

**Pass**: the chart card shows the "Rates unavailable" badge with an excluded-record count; no total mixes currencies and no missing value appears as zero.

### V5 — Drill-down (SC-007)

1. On the Analytics tab (full charts), tap a category slice.

**Pass**: the app opens the existing expense list filtered to that category. A segment with no records opens an empty list, not a crash.

### V6 — Shared member contribution (SC-006)

1. In a shared space with members, open Analytics in **Shared** lens.

**Pass**: the contribution chart lists every member (including any with zero), each with a share of shared expenses/reimbursements.

### V7 — Large dataset performance (SC-008)

1. Seed ~1000+ expense records for the context.
2. Open Analytics and swipe/switch months.

**Pass**: charts render and animate smoothly with no visible jank.

### V8 — Empty state (FR-013)

1. Select a month/context with no data.

**Pass**: each chart shows a friendly empty state, never a blank plot or a crash.

---

## Automated coverage

Tests live under `test/features/analytics/`:

| File | Proves |
|---|---|
| `domain/chart_query_test.dart` | Pure aggregation: category total == spending total (SC-001); planned/paid/cancelled separation; medical split; contribution grouping |
| `domain/chart_filters_test.dart` | Filter composition (FR-012) |
| `presentation/chart_widgets_test.dart` | Mini vs full sizing; empty state; degraded badge |
| `analytics_lens_test.dart` | Lens re-derivation and shared-only charts (SC-004, SC-006) |

Run them alone with:

```bash
flutter test test/features/analytics
```

---

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| A chart total differs from the Dashboard summary | A chart bypassed the shared data layer — violates `chart-data.md` §1 |
| A chart shows `0` where a rate was missing | Degraded record was zeroed instead of excluded — violates FR-005 |
| The contribution chart is empty in a shared space | Lens is still `personal`, or shared rows lack `sharedSpaceId` |
| Mini and full disagree | A chart was split into two widgets — violates FR-002 |
