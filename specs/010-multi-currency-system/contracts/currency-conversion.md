# Contract: Currency Conversion & Money Formatting

**Feature**: 010-multi-currency-system | **Consumer surfaces**: engine (month summary, true-available, safe-to-spend, daily limit), all money display (dashboard, expense/medical/reimbursement lists & details, analytics, settings)

---

## 1. Rate source contract

| Context | Source | Status conveyed |
|---|---|---|
| Current month (`open`) | `LiveRateSet` (device singleton) | `live` or `stale` (> 24h / last fetch failed) |
| Past month, `provisional` | that month's seal (last-known rates) | `provisional` — **always labelled approximate** |
| Past month, `sealed` / `approximate` | that month's seal | final; `approximate` carries a permanent badge |
| Any lookup fails or table absent | — | `degraded` — **never a substituted number** |

**Guarantees**: no I/O on any lookup (registry is in-memory); same (yearMonth, amount, from, to) → same result, always; a sealed month's result never changes across app launches, network states, or main-currency changes.

---

## 2. Conversion function

```
convert(amount: Money, from: CurrencyCode, to: CurrencyCode, yearMonth: String)
  → ConversionResult
```

| Field | Type | Notes |
|---|---|---|
| `amount` | Money (target currency, minor units) | `roundHalfAwayFromZero(minorUnits × rate)` |
| `rate` | double | `usdRate[to] / usdRate[from]`; 1.0 when `from == to` |
| `asOf` | DateTime | seal's `asOf`, or live table's `fetchedAt` |
| `source` | enum | `historical` \| `live` \| `lastKnown` \| `bundled` |
| `isStale` | bool | live table older than 24h |
| `isDegraded` | bool | **true ⇒ caller MUST render the unavailable/reliability label** |

**Error behavior (FR-014)**: missing/invalid rate → `isDegraded = true`, amount = original unscaled value carrying its own currency, caller shows label. **A missing rate is never reported as 1.0.**

**Consistency invariant (FR-013)**: for any month, `A→B→C == A→C` within one display rounding step of C's exponent (all 12 directed pairs — verified by test matrix).

---

## 3. Aggregation contract (engine)

- Sums, `moneyReturned`, `excessReturned`, `trueAvailable`, `safeToSpend`, `dailyLimit` are computed over **integer minor units in the display currency** of the month being viewed — one conversion per contributing row, then exact integer addition (closes defect D2: no mixed-unit sums).
- Insurance math (`billedAmount × patientShare% / 100`) runs in the **bill's own currency** before any conversion (FR-016).
- An aggregate containing ≥ 1 degraded row renders with a degraded marker on the aggregate.

---

## 4. Display & formatting contract

| Rule | Behavior |
|---|---|
| Rounding point | Exactly one: when rendering a Money (conversion already rounded to target exponent) |
| Exponent | HUF → 0 decimals; USD/EUR/CAD → 2 (`Ft 1 234`, `$ 12.34`) |
| Symbol | From `CurrencyCode.symbol` only — no screen may hardcode a symbol or a decimal count |
| Original amount | Always rendered adjacent to the converted amount (FR-002): e.g. `Ft 3 850 · $10.00` |
| Display currency of a month | `MonthlyBudget.convertTo` if set, else `UserProfile.mainCurrency` (FR-011) |
| Switching main currency | re-render only; no stored value mutated (FR-010) — guaranteed by contract 1's immutability |

**Anti-patterns forbidden by this contract**: any screen-specific rate lookup, any `NumberFormat('#,##0.00')` without currency exponent, any per-screen symbol switch (all three exist today and are removed).
