# Phase 1 Data Model: Multi-Currency System (Unified)

**Feature**: 010-multi-currency-system | **Date**: 2026-10-06
**Persistence**: Isar 3.1 (local-only) · **schemaVersion**: 7 → 10

---

## 1. Value Types (non-persisted)

### 1.1 CurrencyCode

Single source of truth for a supported currency. Replaces five divergent lists and four symbol switches.

| Attribute | Type | Rule |
|---|---|---|
| `code` | enum | exactly `huf`, `usd`, `cad`, `eur` — nothing else representable |
| `symbol` | const String | `Ft`, `$`, `C$`, `€` |
| `exponent` | const int | HUF = 0; USD/CAD/EUR = 2 (minor units per major: 1, 100) |
| `displayName` | const String | Forint / US Dollar / Canadian Dollar / Euro |

**Validation**: any stored currency string not matching a code → read-coercion path (§4.4). Adding a currency = one enum entry; all `switch` sites are exhaustive-checked by the compiler.

### 1.2 Money

| Attribute | Type | Rule |
|---|---|---|
| `minorUnits` | `int` (64-bit) | whole minor units; ceiling ≈ 9.2×10¹⁸ — no realistic overflow |
| `currency` | `CurrencyCode` | every Money carries its unit |

**Arithmetic rules**
- `+`, `−` require equal currency → exact integer results.
- Scaling (× rate): `roundHalfAwayFromZero(minorUnits × rate)` — rounding happens **only** at this boundary and at input parsing and at display. Never mid-aggregation.
- Cross-rate division (`usdRate[to] / usdRate[from]`) computes in double **once**, then rounds to the target currency's exponent.
- Display: `format(Money)` renders using `exponent` (HUF: no decimals — fixes the phantom-cents defect D10).

**Validation**: amounts ≤ 0 rejected at input (spec edge case). A persisted double that has no exact integer representation at its currency's exponent is **flagged by migration step 9**, never rounded silently (FR-021).

---

## 2. New Collections

### 2.1 MonthRateSeal — *the month seal*

One row per calendar month. The frozen rate table.

| Field | Type | Validation / Notes |
|---|---|---|
| `yearMonth` | String `"YYYY-MM"` | **unique index** — one seal per month |
| `status` | enum | `open` \| `provisional` \| `sealed` \| `approximate` (state machine §3) |
| `ratesHuf/usd/cad/eur` | double × 4 | rates **vs USD** (`usdRate[X]` = X per 1 USD); `usdRate.usd ≡ 1`; all > 0, finite |
| `asOf` | DateTime | the date the rates represent (close date, or the business day the provider returned) |
| `fetchedAt` | DateTime | when we obtained them |
| `source` | enum | `historical` \| `live` \| `lastKnown` \| `bundled` |
| `closedAt` | DateTime? | when the month was sealed (null while provisional) |
| `attemptCount` | int | seal/retry attempts — drives retry pacing, shown in settings |
| `updatedAt` | DateTime | last write |

**Derived (not stored)**: `rate(from → to)` and any cross-rate — pure functions of the four rates.

### 2.2 LiveRateSet — current-month rates

Singleton row (one per device, not per profile — currency data is not user-private).

| Field | Type | Validation / Notes |
|---|---|---|
| `ratesHuf/usd/cad/eur` | double × 4 | vs USD, same invariants as above |
| `fetchedAt` | DateTime | drives the 24h throttle and the "last updated" display |
| `source` | enum | `provider` \| `bundled` |
| `stale` | bool | true when `fetchedAt` > 24h or last fetch failed |

**Relationship**: not owned by any month; the *current* month reads it. Once a month seals, it never reads this row again.

---

## 3. Seal Lifecycle (state machine)

```
                 (calendar month rolls over; first open in a later month)
                                    │
                                    ▼
     ┌────────────┐   fetch OK    ┌────────┐   7-day grace expires /
     │  (no row)  │──────────────▶│ sealed │◀── historical fetch OK
     └────────────┘               └────────┘
            │                     ▲      │
            │ offline             │      │ success within grace
            ▼                     │      ▼
     ┌──────────────┐  retry OK   ┌───────────────┐   grace > 7d or
     │ provisional  │────────────▶│   sealed      │◀── history impossible
     │ (approximate)│             └───────────────┘        │
     └──────────────┘                                     ▼
                                                   ┌───────────────┐
                                                   │ approximate   │  (permanent;
                                                   └───────────────┘   badge forever)
```

| State | Meaning | Network | Display |
|---|---|---|---|
| `open` | current calendar month — reads `LiveRateSet` | ≤ 1 fetch/24h | normal; stale → labelled |
| `provisional` | closed offline; last-known rates; **retry every open, ≤ 7 days** | on retry | banner: "approximate — connect to correct" |
| `sealed` | final; rates fetched for its own close date | **never again** | normal, immutable |
| `approximate` | final with fallback rates (history impossible) | never (manual re-seal attempt allowed from settings) | permanent badge |

**Transitions are one-way** except `provisional → sealed`. Nothing ever reverts a seal; nothing ever rewrites rates of a sealed/approximate month (spec FR-006).

**Triggers** (research R3): cold start + `resumed`, via one idempotent coordinator pass:
1. If calendar month > last-checked month → run seal/backfill for every unsealed month in between (historical fetch; walk back ≤ 7 days on provider 404 for weekends/holidays; fall back to `lastKnown` → `approximate`).
2. Upgrade `provisional` rows: within grace, any successful fetch for that month's close date → `sealed`.
3. Refresh `LiveRateSet` if > 24h since `fetchedAt`.
4. Emit banner/badge state changes.

---

## 4. Modified Entities

### 4.1 UserProfile

| Change | From | To |
|---|---|---|
| `primaryCurrency` | enum, default ordinal 0, inconsistently seeded | **global main-currency default**; new months seed from it; settings UI is its only writer (defects D5, D7) |

### 4.2 MonthlyBudget

| Change | From | To |
|---|---|---|
| `currency` | competing "primary" (dashboard writes it, profile doesn't) | **display-only convert-to for this month**; seeded from profile at creation (`month_finance_repository.dart:94` loses its USD fallback); cleared → falls back to profile |
| *(no money fields change meaning)* | — | opening balance, net salary override unaffected by conversion (they are entered in the month's own display currency) |

### 4.3 Expense / Reimbursement / MedicalBill

| Field | Change | Validation |
|---|---|---|
| `amount` | `double` → **`int` minor units** | > 0; exact at currency exponent or flagged by migration |
| `currency` | `String` → **`CurrencyCode`-backed** | must be one of 4; legacy non-matching values coerced at read (§4.4), listed in audit |
| `exchangeRateToPrimary` (Expense, Reimbursement) | **deleted** | superseded by month seal — conversion is read-time (research R12) |
| `MedicalBill.currency` | **added** (was inherited with rate forced 1.0) | own currency + own amount; linked expense unaffected |
| `yearMonth` / `originYearMonth` | unchanged | still determines which month's seal applies |

**Insurance math (unchanged, currency-independent)**: `patientShareAmount = billedAmount × patientSharePercent / 100` operates on integer minor units **in the bill's own currency**; only display converts (spec FR-016, Constitution IV).

### 4.4 Legacy/unknown currency handling (read-coercion)

For any persisted currency string outside the four codes:
1. Record is preserved verbatim (FR-021).
2. Displayed with raw code + "unsupported" flag; **excluded from converted totals**, surfaced in Currency Settings audit list.
3. Never crashes a screen, never silently re-coded (rejects silent-GBP→USD conversion — would alter financial meaning).

---

## 5. Relationships

```
UserProfile 1 ─── * MonthlyBudget        (profile seeds convert-to at creation)
MonthlyBudget 1 ── 0..1 MonthRateSeal    (same yearMonth key)
LiveRateSet  1 ──── singleton (device-global)
Expense / Reimbursement / MedicalBill * ─ 1 month (by yearMonth string)
                └── conversion reads: MonthRateSeal(yearMonth) ── or LiveRateSet if open
```

Seals and rates are **device-global**; expenses remain **profile-scoped** (multi-profile untouched, Constitution A2).

---

## 6. Data Migration Plan (steps are immutable once shipped)

| Step | Type | Contents | Phasing |
|---|---|---|---|
| **8** | additive, reversible | create `MonthRateSeal` + `LiveRateSet`; add `MedicalBill.currency`; add CurrencyCode backing for currency fields; add convert-to metadata | ships first; zero data loss risk |
| **9** | **dry-run capable, two-phase** | (a) doubles → integer minor units at correct exponents, **flagging** lossy/fractional rows; (b) drop `exchangeRateToPrimary` semantics/column; (c) seed initial seals from whatever the old cache holds (`source: lastKnown`, status per §3) | Phase 1 emits a report: per-row before/after, >1% movement list, unresolvable rows, lossy conversions. Phase 2 commits **only after review** (FR-021, research R6) |
| **10** | reconcile | default currency → HUF everywhere (removes `usd`/`USD`/`$` divergence); profile becomes sole seed for new months; retire dead settings path; `MonthlyBudget.currency` re-labelled as display-only convert-to | idempotent |

Every step idempotent + re-runnable, consistent with `schema_migrations.dart:84-90`.

---

## 7. Validation Rules Summary (traceable to spec)

| Rule | FR |
|---|---|
| Only 4 currencies representable; GBP gone | FR-001 |
| Original amount + currency always stored and shown | FR-002 |
| One seal per month, immutable once final | FR-003/006 |
| Seal triggers are automatic and non-blocking | FR-004 |
| Live refresh ≤ 1/24h | FR-005 |
| Provisional → grace 7d → permanent freeze | FR-007 |
| Missed months: historical date fetch → last-known fallback labelled | FR-008 |
| Profile main currency is per-profile; switch = zero writes | FR-009/010 |
| Convert-to is per-month, display-only, clearable | FR-011 |
| Deterministic, no I/O on read; cross-rate consistency | FR-012/013/022 |
| Never fabricate 1.0; degraded results labelled | FR-014 |
| Whole minor units; single rounding at display | FR-015 |
| Insurance % applied in original currency | FR-016 |
| CRUD works offline with no rate lookup | FR-017 |
| One conversion/formatting path for all screens | FR-018 |
| Upgrade is lossless or flagged, never silent | FR-021 |
