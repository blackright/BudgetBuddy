# Contract: Month Seal Lifecycle

**Feature**: 010-multi-currency-system | **Owner**: seal coordinator (app start + resume) | **Storage**: `MonthRateSeal`

---

## 1. Participants

| Participant | Role |
|---|---|
| **Seal coordinator** | Idempotent pass on cold start and `resumed`; never blocks first frame |
| **Rate provider client** | Live: latest table (base USD). Historical: table for a specific date; walks back ≤ 7 days on 404 (weekends/holidays) |
| **Rate registry** | In-memory `yearMonth → RateTable`; the only thing readers touch |
| **Banner/badge state** | Derived projection of coordinator output (see currency-settings-ui contract) |

## 2. Operations

### `runSealPass(now: DateTime)` — must be safe to call any number of times

1. **Seal eligible months**: for every calendar month < current month with no seal row (or non-final row): request historical rates for that month's close date.
   - success → write seal `status: sealed`, `source: historical`, `asOf` = returned date.
   - provider unreachable → use last known rates → `status: provisional` (within 7-day grace of close) or `approximate` (grace already expired / history impossible).
2. **Upgrade provisional rows**: within 7 days of `closedAt`, any success → `sealed`. After 7 days → freeze as `approximate` (never retried automatically again; manual retry allowed from settings).
3. **Refresh live table**: only if `now − fetchedAt > 24h` or table absent; on failure mark `stale`, keep old table, do not escalate.
4. **Emit** updated registry snapshot → all watching providers rebuild.

### `closeCurrentMonth()` — invoked by (1) when the calendar rolls

Creates the seal row for the month that just ended, seeded with the best available rates at that moment (historical preferred; else last-known → provisional). **Must never block**: no awaited network before the app is interactive.

## 3. State machine (normative)

States: `open` (implicit, current month, no row yet) → `provisional` → `sealed` | `approximate`.

| Transition | Trigger | Guard |
|---|---|---|
| *(none) → provisional* | month ends while offline | last known rates exist |
| *(none) → sealed* | month ends with successful fetch | rates valid (> 0, finite, all 4 currencies) |
| `provisional → sealed` | retry success | `now − closedAt ≤ 7 days` |
| `provisional → approximate` | grace expiry or history impossible | after 7 days |
| `sealed → *` | **no transition exists** | immutable (FR-006) |
| `approximate → sealed` | manual retry from settings only | user-initiated |

## 4. Invariants

- **I1** — A seal row is written at most once per month; subsequent passes update `status`/rates only via the transitions above.
- **I2** — No sealed/approximate row is ever modified by an automatic pass.
- **I3** — The coordinator never awaits network before first frame; UI is interactive throughout.
- **I4** — Every fetch failure downgrades labels, never data: banner shows, numbers stay.
- **I5** — Rate rows are device-global: seals are independent of which profile is active.
- **I6** — Attempt counters increment per failed seal attempt and are surfaced in settings (`attemptCount`).

## 5. Failure matrix

| Failure | Resulting state | User-visible effect |
|---|---|---|
| Offline at month end | `provisional` | banner: month approximate, connect to correct; badge on settings |
| Offline for weeks (multiple months) | each attempted; success→`sealed`, else `approximate` | list in settings shows per-month status |
| Historical endpoint 404 (weekend) | walk back ≤ 7d; success → `sealed`, `asOf` = actual business day | none (silent, correct) |
| Historical data impossible entirely | `approximate` | permanent badge; manual retry offered |
| Provider down mid-month | live table kept, `stale = true` | stale label on current month only |
| Never-seeded first launch offline | bundled table, `source: bundled`, `approximate` until first fetch | approximate banner |
