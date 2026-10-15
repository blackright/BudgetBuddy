# Implementation Plan: Multi-Currency System (Unified)

**Branch**: `010-multi-currency-system` | **Date**: 2026-10-06 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/010-multi-currency-system/spec.md`

## Summary

Give BudgetBuddy trustworthy multi-currency support built on **per-month rate seals**: every completed calendar month freezes its own four-currency exchange-rate table (referenced to USD), so history is immutable, offline-capable, and independently viewable in any supported currency, while the current month follows live rates. The profile's **main currency** is the global display default (changed by re-render only, zero writes); each month carries a display-only **convert-to** choice. Money converts to integer minor units in a single cut, one `CurrencyCode` definition replaces five divergent lists, and all failures surface as labelled banner/badge states — never a fabricated 1:1 rate.

Technical approach: extend the existing Isar store with two collections and schema steps 8–10 behind a dry-run audit; replace the JSON rate cache with a Frankfurter-backed client (free, no key, verified live + historical for HUF/USD/EUR/CAD today); hydrate an in-memory rate registry so the synchronous Riverpod engine reads rates with zero I/O; seal months via an idempotent app-start/resume coordinator; add Currency Settings UI, banner/badge, and a `flutter test` CI step.

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.6 stable

**Primary Dependencies**: Riverpod (state), Isar 3.1.0 (local DB, codegen via build_runner), Dio (HTTP), intl (formatting). No new packages required — historical + live rates both come from Frankfurter over plain HTTPS via existing Dio.

**Storage**: Isar 3.1.0, local-only. Two new collections (`MonthRateSeal`, `LiveRateSet`) + field changes on `Expense`, `Reimbursement`, `MedicalBill`, `MonthlyBudget`, `UserProfile`; app-level migration steps in `lib/core/database/schema_migrations.dart` (schemaVersion 7 → 8..10).

**Testing**: `flutter_test` (221 existing tests, all green as of 2026-10-06); new unit tests for conversion/seal lifecycle, widget tests for banners/settings, real-Isar harness (`medical_test_harness.dart` pattern) for migration tests. CI: `.github/workflows/flutter_validation.yml` — **gains a `flutter test` step (does not run tests today)**.

**Target Platform**: Android first; iOS/web/desktop later (Constitution I).

**Project Type**: Mobile app — single Flutter project with `lib/`, `test/`, and platform directories.

**Performance Goals**: conversion O(1) per value; main-currency switch visible < 1s (SC-002) with zero writes; zero network on any read path; seal pass on app open completes without blocking first frame.

**Constraints**: offline-first (Constitution III) — sealed months never touch the network; ≤ 1 rate fetch per 24h per device; sealed months immutable; never fabricate a rate (FR-014); user data never leaves the device (only anonymous currency GETs).

**Scale/Scope**: single-device, multi-profile; 4 currencies, 12 directed pairs; monthly granularity (hundreds of rows/month); one feature spanning ~10 source areas (models, DB, engine, network, settings, dashboard, expenses, medical, shared UI, CI).

**Unknowns**: none — all Technical Context fields resolved (see research.md; rate-provider capability was verified by live API probes on 2026-10-06).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| # | Gate (Constitution) | Verdict | Evidence |
|---|---|---|---|
| I | Cross-platform & mobile-first (Flutter, Android first) | ✅ PASS | Flutter app unchanged; no platform-specific code introduced |
| II | Clean Architecture & testability (Riverpod, evolve without breaking financial logic) | ✅ PASS | Conversion is a pure, provider-injected function; seal lifecycle isolated behind a coordinator; feature ships with unit/widget/Isar tests |
| III | Offline-first & sync-ready | ✅ PASS (strengthened) | Core design goal: sealed months are immutable and network-free; FR-017 requires record CRUD with zero rate lookups; bundled baseline rates cover first launch |
| IV | Modular financial logic (planned/paid/reimbursed/cancelled; medical share rules; single source of truth) | ✅ PASS | Engine status semantics untouched; insurance % applied in original currency (FR-016) per constitutional medical clause; FR-018 forces one conversion/formatting path so screens cannot disagree |
| V | Security & privacy first | ✅ PASS | No PII or user data in rate requests; settings remain behind existing device auth; no new data leaves the device |
| VI | Playful & modern design | ✅ PASS | New banner follows existing `MonthIncompleteBanner` Material pattern; dark-mode friendly; original amounts always shown alongside converted (FR-002) |
| A1 | Multi-Currency constraint (≥ HUF/USD/CAD/EUR; primary currency; summaries in primary via fetched rates) | ✅ PASS | Directly implements this constitutional constraint |
| A2 | Multi-User Profiles | ✅ PASS | Main currency is a per-profile field; seals/rates are device-global (currency data is not user-private) |
| A3 | Performance (lightweight, fast) | ✅ PASS | O(1) conversions, in-memory rate registry, ≤ 1 fetch/24h |
| D1 | Iterative delivery & feature encapsulation | ✅ PASS | Phased delivery possible: engine+seals → UI → migration cut |

**Gate result: PASS, no violations → Complexity Tracking left empty.**

*Post-design re-check (after Phase 1):* data-model, contracts and quickstart introduce no new architectural surface beyond the table above — **still PASS**, no violations to justify.

## Project Structure

### Documentation (this feature)

```text
specs/010-multi-currency-system/
├── plan.md              # This file (/speckit-plan output)
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   ├── currency-conversion.md      # conversion + formatting contract
│   ├── month-seal-lifecycle.md     # seal state machine contract
│   └── currency-settings-ui.md     # settings screen + banner/badge contract
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── models/                  # UserProfile, MonthlyBudget, Expense + NEW: currency_code.dart, money.dart, month_rate_seal.dart, live_rate_set.dart
│   ├── database/                # schema_migrations.dart — NEW steps 8 (additive), 9 (money+rate semantics, dry-run), 10 (reconcile defaults)
│   ├── network/                 # exchange_rate_client.dart — rewritten to Frankfurter (live + historical), file cache deleted
│   └── providers/               # active profile/budget providers gain main-currency + rate-registry wiring
├── features/
│   ├── engine/                  # month_summary, true_available, safe_to_spend — re-pointed to month-seal rate tables; NEW: rate registry provider, seal coordinator
│   ├── settings/                # NEW: currency settings section (main currency, rate table, seal status list, manual refresh)
│   ├── dashboard/               # RateStatusBanner inserted alongside MonthIncompleteBanner; convert-to picker retained
│   ├── expenses/                # currency dropdowns → CurrencyCode list; write-path rate resolution deleted
│   ├── medical/                 # MedicalBill gains currency; share math stays in original currency; one shared money formatter
│   └── finance/                 # MonthlyBudget.currency repurposed as display-only convert-to; profile seeds it at month creation
└── shared/presentation/         # NEW: money formatter (single rounding point), RateStatusBanner, settings badge

test/
├── features/engine/             # conversion matrix: 12 pairs × {sealed, provisional, approximate, missing} × {main currencies}
├── core/database/               # migration step tests incl. dry-run audit + lossy-amount flagging (Isar harness)
├── features/settings/           # currency settings widget tests (states, badge, refresh)
└── .github/workflows/           # flutter_validation.yml — NEW: `flutter test` step
```

**Structure Decision**: Single-project Flutter layout (existing, unchanged in shape). The feature is encapsulated behind three new seams — `CurrencyCode`/`Money` value types (core/models), the rate registry + seal coordinator (engine), and the Currency Settings section (settings) — so the engine, UI and migration work can land in separate reviewable phases without touching the app's directory conventions.

## Complexity Tracking

No constitution violations to justify — table intentionally empty.
