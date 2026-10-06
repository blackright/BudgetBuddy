# Phase 0 Research: Multi-Currency System (Unified)

**Feature**: 010-multi-currency-system | **Date**: 2026-10-06
**Status**: All unknowns resolved. No NEEDS CLARIFICATION remain.

---

## R1. Rate provider: live + historical from one source

**Decision**: Use **Frankfurter** (`https://api.frankfurter.dev/v1/...`) for both live and historical rates — free, no API key, ECB reference data, base-currency switch supported. One provider for both keeps current-month and sealed-month rates methodologically identical.

**Rationale** (verified by live probes on 2026-10-06, not assumptions):
- `GET /v1/latest?base=USD` → 200, includes `HUF 328.28`, `CAD 1.4253`, `EUR 0.89254` — all four supported currencies present.
- `GET /v1/2026-09-30?base=USD` → 200 with a full historical table — **the exact capability FR-008 needs for missed months**.
- Non-business days return **404** (verified with 2026-09-26 and 2026-10-04, both Sundays) → seal logic must walk back day-by-day (≤ 7 days) to the most recent business day. Weekend/holiday month-ends therefore seal with the nearest prior ECB publication, which is the correct real-world answer.
- ECB publishes once per working day (~16:00 CET) — matches the "refresh at most once per 24h" requirement with massive quota headroom (a device makes ≤ 31 calls/month).

**Alternatives considered**:
- `open.er-api.com/v6/latest/USD` (provider's current free endpoint, probed OK, has `time_last_update_unix` — good provenance): **rejected for dual-source inconsistency**, but documented as the fallback provider if Frankfurter ever goes down; response shape is compatible.
- `api.exchangerate-api.com/v4` (current client): deprecated (`WARNING_UPGRADE_TO_V6`) and **history is Pro-only ($10/mo)** per official docs — cannot serve FR-008 on the free tier.
- Open Exchange Rates / Fixer / CurrencyLayer: historical locked behind paid tiers.
- nimbus-api: free historical claims, unproven provenance — rejected.
- Bundled static rates: only as the first-launch baseline (R6).

---

## R2. Architecture: numeraire monthly seal (Option A)

**Decision**: Store **one four-currency rate table per month, referenced to USD** (`usdRate[X]` = X per 1 USD). Cross-rates are derived: `rate(from→to) = usdRate[to] / usdRate[from]`. Owner of this decision: product owner, approved 2026-10-06 ("Approved + Option A").

**Rationale**: The engine is synchronous (`MonthSummary.from`, `trueAvailableProvider`, `safeToSpendProvider` all fold inline) while rate acquisition is async — irreconcilable unless rates live in memory. A per-month USD table makes (a) main-currency switching a zero-write re-render, (b) independent per-month conversion free, (c) inconsistent cross-rate triangles structurally impossible, (d) offline viewing total for sealed months.

**Alternatives considered**: Option B (store one rate per month locked to the then-main currency) — rejected in plan §4: cannot convert a month to a third currency offline once the main currency changes; reintroduces network on the read path. Per-pair tables (12 rows/month) — redundant, drift-prone. Per-expense locked rates (`Expense.exchangeRateToPrimary`) — **removed**: superseded by month seals; keeping both would create two competing sources of truth for the same number.

---

## R3. Seal trigger: no lifecycle hook exists today

**Decision**: Introduce a **seal coordinator** (idempotent, cheap) invoked from two points: app cold start and `AppLifecycleState.resumed` via a single `WidgetsBindingObserver` registered in the app shell. It performs: seal-eligible check (has the calendar month changed since the last check?), the seal/backfill pass, and the live-rate refresh (throttled 24h). It never blocks first frame (runs post-frame) and is safe to call repeatedly.

**Rationale**: Verified by search — the codebase has **zero** `WidgetsBindingObserver`/`AppLifecycleState` usage; no resume hook exists to build on. "First app open in a later month" (FR-004) maps directly to cold start + resume. Idempotency is required anyway for the provisional-retry path (FR-007).

**Alternatives considered**: Sealing inside `selectedYearMonthProvider` changes — rejected (only covers month *navigation*, not calendar rollover while parked on today). Pure background isolate — overkill for a pass that touches ≤ 12 rows. Workmanager-style background job — no such dependency exists; unnecessary for a check that runs on every open.

---

## R4. Sync read path: in-memory rate registry

**Decision**: A `RateTableRegistry` holding `yearMonth → RateTable` (+ live table + status), hydrated asynchronously at startup from Isar, exposed through Riverpod. Engine providers **watch** the registry provider and fold synchronously over its in-memory snapshot — no I/O inside any reduce.

**Rationale**: Isar reads are async; the engine cannot await (Constitution II/III: current month must render offline, immediately). Watching the registry gives the correct reactivity: when a seal completes or a fetch lands, the registry emits and every dependent screen rebuilds — the same mechanism that already makes a main-currency change update instantly.

**Alternatives considered**: Making the engine async — cascades through every provider, test and consumer (largest possible blast radius). Per-call `await getRate()` inside `MonthSummary.from` — impossible (it's sync). Passing rates as function arguments everywhere — threading 3+ rates through ~10 call sites by hand, error-prone.

---

## R5. Money: integer minor units, one cut

**Decision**: `Money { int minorUnits }` with per-currency exponent (HUF 0, USD/EUR/CAD 2). Dart native `int` is 64-bit → ceiling ≈ 9.2×10¹⁸ minor units (≈ 9.2×10¹⁶ dollars, ≈ 9.2×10¹⁸ forints) — far beyond any realistic budget value. Stored as Isar `int`. Rounding policy: **half away from zero**, applied (a) once when parsing user input into minor units, (b) once when converting (multiply then round to target minor units), (c) once at display — never during intermediate aggregation. Integer addition/subtraction for all sums is exact.

**Rationale**: Product owner chose "do it all in one cut" (2026-10-06). Removes the `closeTo(..., 1e-9)` fudge from tests, eliminates float drift in `MonthSummary.kept`/`trueAvailable`, and kills the HUF phantom-cents rendering (two-decimal US formatter on a zero-exponent currency).

**Alternatives considered**: Staged rollout (type only at the conversion boundary first) — proposed and explicitly declined by product owner. Decimal package — new dependency for what integer minor units already solve; rejected under Constitution A3 (lightweight).

---

## R6. Storage & migration: follow the established step registry

**Decision**: Two new collections (`MonthRateSeal`, `LiveRateSet` — additive, Isar creates them on open) + app-level steps in `schema_migrations.dart`: **step 8** additive fields (currency columns on `MedicalBill`, convert-to metadata), **step 9** dry-run-capable double→int conversion and rate-column semantics (two-phase: report first, commit after review; flags lossy/fractional rows instead of rounding), **step 10** reconcile defaults (HUF everywhere, retire dead settings path, repurpose `MonthlyBudget.currency` semantics). `schemaVersion` 7 → 10. Seals for existing history are seeded from whatever the rate cache holds, labelled `approximate`, and upgraded by historical fetch on demand.

**Rationale**: Matches the repo's immutable, idempotent step convention (`schema_migrations.dart:84-90` — shipped steps are never reordered). The real-Isar test harness already has a pre/post-migration switch, giving us a ready-made test vehicle for step 9's audit output.

**Alternatives considered**: Rerun-all-from-scratch rebuild — no rollback story. Hand-written SQL-style migrations — no SQL in this stack. Doing the money conversion silently during step 9 — rejected by FR-021 (flag, never silently alter).

---

## R7. Currency unification: one `CurrencyCode`, coerce legacy strings

**Decision**: A single const `CurrencyCode` type (code, symbol, exponent, displayName) as the only definition the app reads; stored `String` currency columns migrate to this enum. Legacy/unknown values (e.g. an old `GBP` row) are **coerced at read**: record kept, value displayed as its raw code with an "unsupported currency" flag, excluded from converted totals (edge case in spec), listed in the migration audit.

**Rationale**: Five divergent lists exist today (`add_expense_screen.dart:122`, `edit_expense_screen.dart:27`, `reimbursement_entry_sheet.dart:189`, enum, symbol switches); GBP is storable but unconvertible. Enum storage makes GBP unrepresentable going forward; read-coercion keeps legacy data from crashing anything.

**Alternatives considered**: Keeping `String` + validation — leaves five lists and exhaustiveness unchecked. Silently converting GBP rows to USD at migration — violates FR-021 (never silently alter financial data).

---

## R8. UI precedent: banner, badge, settings registration

**Decision**: Persistent rate banners follow the existing `MonthIncompleteBanner` widget pattern, mounted beside it on the dashboard and at the top of Currency Settings. The settings badge is a small status indicator on the Currency Settings row. Transient feedback (manual refresh success/failure) uses `ScaffoldMessenger` SnackBar, the app's universal pattern. The settings section registers by appending to the children list in `settings_screen.dart` (same as `font_setting_section`).

**Rationale**: Every mechanism already exists and is used consistently (46 SnackBar call sites; one persistent-banner precedent); zero new UI primitives, zero new dependencies, dark-mode support inherited.

**Alternatives considered**: OS push notifications — explicitly declined by product owner (in-app only, 2026-10-06); would require permission/channel/scheduling infrastructure that doesn't exist here. Material 3 `Banner` widget — the app's own banner pattern is already the house style.

---

## R9. Main currency vs convert-to: clarify the two existing write paths

**Decision**: `UserProfile.primaryCurrency` = global default (seed for new months, fallback for months without a choice, per-profile). `MonthlyBudget.currency` = display-only **convert-to** for that month (kept field, repurposed semantics — it is *already* what most screens render with, see `dashboard_screen.dart:127`, `expenses_screen.dart:29`, `medical_providers.dart:95`). Profile edits happen only in Currency Settings/profile UI; the dashboard popup edits only the viewed month's convert-to. The default-USD seed (`month_finance_repository.dart:94`) becomes profile-seeded.

**Rationale**: Resolves defect D5 structurally — the two fields stop competing for the same job. Screens already read `budget.currency`, so convert-to needs no new plumbing; the previously dead `SettingsNotifier.updateCurrency` path becomes the live, watched profile control.

**Alternatives considered**: Deleting `MonthlyBudget.currency` (original option in the earlier round) — declined by product owner's per-month-independence requirement (2026-10-06). A separate new convert-to field — redundant with a field that already carries exactly this value.

---

## R10. CI: run the test suite

**Decision**: Add `flutter test` to `.github/workflows/flutter_validation.yml` after `flutter analyze`.

**Rationale**: The workflow currently runs pub get → build_runner → format → analyze, **never tests** (verified: only 5 `run:` lines). This feature is the most arithmetic-dense change in the repo; D8 already shows the test harness disagreeing with production. A conversion matrix that never runs in CI protects nothing.

**Alternatives considered**: Separate test workflow — same cost, worse discoverability. Skipping (status quo) — rejected; it is listed as defect D11.

---

## R11. Offline & quota envelope

**Decision**: ≤ 1 live fetch per 24h + 1 historical fetch per unsealed month (≤ a handful per device lifetime, retried at most once per open while eligible). All fetches are anonymous GETs; no user data transmitted (Constitution V). Bundled baseline table ships in-app for first-launch-offline, labelled `approximate` until the first real fetch.

**Rationale**: Free-tier quotas (Frankfurter: keyless; er-api: 1,500 req/mo) are exceeded by two orders of magnitude. Once a month is sealed it is never fetched again — the network footprint is bounded by the number of *unsealed* months, not by usage.

**Alternatives considered**: Per-view fetches — violates FR-012/FR-022. Higher-frequency refresh — unnecessary for budgeting; violates the 24h rule.

---

## R12. Defect-driven re-pointing inventory (what the engine changes)

**Decision**: The four multiply-by-rate sites (`month_summary.dart:58`, `true_available_provider.dart:49,55`, `safe_to_spend_provider.dart:12`, `month_summary_provider.dart:38-46`) plus `expense_delta.dart` re-point to the registry lookup; write-path rate resolution in `expense_repository.dart:22,31` and `reimbursement_repository.dart:14,25` is **deleted** (conversion is read-time only — this closes D1 structurally rather than patching it); `exchange_rate_cache.dart` (silent `1.0` at line 71) is deleted and replaced by the registry with degraded-result semantics (D3).

**Rationale**: Consolidates every defect fix into one seam instead of spreading fixes across repositories.

**Alternatives considered**: Patching `getRate` to return null on failure and handling nulls at 10 call sites — treats the symptom; the write-path rate would still be the wrong concept post-seal.
