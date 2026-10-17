# Implementation Plan: Charts & Analytics (Unified)

**Branch**: `014-charts-and-analytics` | **Date**: 2026-10-15 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/014-charts-and-analytics/spec.md`

## Summary

Replace the two explicit placeholders (the `/analytics` route's "Analytics Placeholder" screen and the Dashboard's `AnalyticsPlaceholderCard`) with real charts. Seven chart types are drawn with `fl_chart` across two surfaces (Dashboard mini + Analytics full). The critical design move is **one shared chart-data layer**: no chart queries Isar or converts currency on its own. All aggregation happens in pure functions fed by Riverpod providers keyed on the existing `budgetContextProvider`, so a personal profile and a shared space are handled by the same code path and every chart shows the identical total for the same context. This is a **read-only** feature: no new persistent entity, no schema change, no migration.

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.6

**Primary Dependencies**: `fl_chart` (new — charts), `flutter_riverpod` (state/providers), `go_router` (existing navigation), `intl` (already used by `money_format.dart`), `isar` (storage, read-only)

**Storage**: Isar. **Not Drift** — the raw idea's "Drift" line is corrected (see spec FR-009). Charts only read existing collections: `expenses`, `medicalBills`, `reimbursements`, `monthlyBudgets`, `sharedMembers`, `userProfiles`, `sharedSpaces`, `categories`, `monthRateSeals`.

**Testing**: `flutter_test`. Chart data layer is pure (no DB) so it unit-tests without Isar; chart widgets test with fake series objects, mirroring the repo's existing pure-fake widget-test pattern.

**Target Platform**: Android first (device under test SM G965F), cross-platform Flutter (Constitution I).

**Project Type**: mobile-app (single Flutter project, feature-encapsulated).

**Performance Goals**: 60fps; smooth with 1000+ expense records (SC-008). Aggregation happens once in the data layer — charts never draw raw records.

**Constraints**: Offline-first (Constitution III — no network); read-only (FR-014 — no schema change, no migration); degraded-rate safety (FR-005 — never fabricate a zero or mix currencies).

**Scale/Scope**: 7 chart types, 2 surfaces, 1 new feature module (`lib/features/analytics/`). Reuses — does not rewrite — `convert`, `MonthSummary`, `resolveContextDisplayCurrency`, `rateRegistryProvider`, and `budgetContextProvider`.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Verdict | How this feature complies |
|---|---|---|
| **I. Cross-Platform & Mobile First** | ✅ PASS | Pure Dart chart widgets + data layer; no platform channel. Android-first, reusable elsewhere. |
| **II. Clean Architecture & Testability** | ✅ PASS | Pure aggregation functions (DB-free) + Riverpod providers; widgets consume typed series only. This feature **is** the anticipated "advanced analytics / richer dashboards" growth from Principle II, added without touching core financial logic. |
| **III. Offline-First & Synchronization** | ✅ PASS | All data is local Isar; charts need no network. Charts render synced data (including 012's sealed months) without special-casing. |
| **IV. Modular Financial Logic & Real-time** | ✅ PASS | Charts **reuse** the engine's money math; they never re-implement it. The planned/paid/reimbursed/cancelled distinction is preserved (planned-vs-paid chart, cancelled excluded from paid totals). Medical split reuses `MedicalBill.patientShareAmount` / `insurerPaidAmount` — consistent with the v1.2.0 medical clause. Medical appears in general totals via the single existing source, so no two screens disagree. |
| **V. Security & Privacy First** | ✅ PASS | Charts expose no new sensitive data and no new surface; the existing app-lock gate already covers the whole app. Read-only, so no data leaves local storage. |
| **VI. Playful & Modern Design** | ✅ PASS | Material 3 widgets, dark-mode aware (colors from theme/categories), and a clear visual distinction between planned, paid, and reimbursed via consistent color coding. |
| **Additional: Multi-Currency** | ✅ PASS | Every value normalized through the existing `convert` + `rateRegistryProvider`; degraded months surface a warning (FR-005). |
| **Additional: Multi-User Profiles** | ✅ PASS | Driven entirely by `budgetContextProvider`, so each profile and each shared space gets its own charts. |
| **Additional: Performance** | ✅ PASS | Aggregation is done once per context; charts are lightweight `fl_chart` renderings. |

**Gate result: PASS — no violations.** Complexity Tracking table below stays empty.

## Project Structure

### Documentation (this feature)

```text
specs/014-charts-and-analytics/
├── plan.md              # This file (/speckit-plan command output)
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
lib/features/analytics/
├── domain/                          # Pure, DB-free — unit-testable without Isar
│   ├── chart_series.dart            # ChartSeries, CategorySlice, DayBucket, MemberContribution
│   ├── chart_filters.dart           # ChartFilters value object (date range, category, currency, status, lens)
│   └── chart_query.dart             # The "One Chart Brain": pure aggregation -> ChartSeries
├── repositories/
│   └── analytics_repository.dart    # Loads rows for a ContextRef; converts via engine helpers
├── providers/
│   ├── chart_data_provider.dart     # ContextRef + ChartFilters -> ChartSeries (live, via streams)
│   └── chart_lens_provider.dart     # The single Personal/Shared lens state
└── presentation/
    ├── analytics_screen.dart        # Replaces the placeholder; lens switch + full charts
    ├── charts/                      # One widget per chart, sized mini (dashboard) or full (analytics)
    │   ├── spending_chart.dart
    │   ├── category_chart.dart
    │   ├── planned_paid_chart.dart
    │   ├── available_trend_chart.dart
    │   ├── insurance_chart.dart
    │   ├── contribution_chart.dart          # shared-only
    │   └── shared_vs_personal_chart.dart    # shared-only
    └── widgets/
        ├── chart_card.dart          # mini/full shell + empty state + degraded-rate badge
        └── lens_switch.dart         # Personal/Shared toggle

lib/features/dashboard/presentation/dashboard_screen.dart   # AnalyticsPlaceholderCard -> mini charts
lib/shared/presentation/widgets/analytics_placeholder_card.dart  # retired

test/features/analytics/
├── domain/chart_query_test.dart     # Pure aggregation: totals agree (SC-001)
├── domain/chart_filters_test.dart
├── presentation/chart_widgets_test.dart  # Fake series, mini/full, empty + degraded states
└── analytics_lens_test.dart         # Personal/Shared switching (SC-004, SC-006)
```

**Structure Decision**: Single-project Flutter app, feature-encapsulated under `lib/features/analytics/` per Constitution's *Feature Encapsulation* rule. Presentation depends on `domain` (pure) through Riverpod providers; `domain` depends on nothing but core models. The Dashboard imports only the `presentation/charts` widgets, so mini and full share one implementation (FR-002).

## Complexity Tracking

No constitution violations — this table is intentionally empty.

---

## Constitution Check (post-design re-check)

Re-evaluated after Phase 1 design (`research.md`, `data-model.md`, `contracts/`, `quickstart.md`):

| Principle | Still passing? | Evidence from the design |
|---|---|---|
| I. Cross-Platform & Mobile First | ✅ | `fl_chart` renders on every Flutter platform; chart widgets are pure Dart. |
| II. Clean Architecture & Testability | ✅ | `chart_query.dart` is pure and DB-free (research R2, R10); presentation depends on domain through providers only. |
| III. Offline-First & Sync | ✅ | Analytics is read-only over local Isar; rates come from local seals/bundled table (research R8). |
| IV. Modular Financial Logic & Real-time | ✅ | The data-layer contract **forbids** charts from re-implementing money math (contracts §1); medical split reuses the model's existing getters; planned/paid/reimbursed/cancelled stay distinct. |
| V. Security & Privacy First | ✅ | No new surface, no writes, no network; app-lock already covers the app. |
| VI. Playful & Modern Design | ✅ | `ChartCard` centralises empty/degraded states; colors from theme; single money formatter (`chart-ui.md` §6). |
| Additional constraints | ✅ | Multi-currency via reused `convert`; multi-profile via `budgetContextProvider`; performance via one-shot aggregation + bucketing (FR-015). |

**Final gate: PASS — no violations, no complexity justifications required.**
