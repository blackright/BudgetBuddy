# Contract: Currency Settings UI, Banners & Badge

**Feature**: 010-multi-currency-system | **Entry points**: Settings → Currency Settings; dashboard banner; settings-row badge

---

## 1. Currency Settings screen

Registered by appending a section to the settings children list (same pattern as the font settings section).

| Section | Content | Interaction |
|---|---|---|
| **Main currency** | Current profile main currency; four options (HUF default, USD, CAD, EUR) | Change → profile updated → **all screens re-render < 1 s, zero data writes** (FR-010); confirmation SnackBar |
| **Current rates** | Live table: rate for each of 4 currencies vs USD, `fetchedAt` timestamp, stale marker | **Refresh now** button → fetch → success SnackBar / failure SnackBar; respects 24h throttle (manual refresh bypasses throttle but is still one call) |
| **Month seals** | Every month with data: `yearMonth`, status chip (`sealed` ✓ / `provisional` / `approximate` / `open`), `asOf` date, `attemptCount` if > 0 | Rows not final show **Retry seal** action (manual, also allowed for `approximate`); rows final show read-only |
| **Unsupported data** | Any legacy record whose stored currency isn't one of the four (audit list) | Read-only flag list; record kept, excluded from converted totals |
| **Status banner** | Same banner as dashboard (below) | — |

## 2. Banner (persistent, in-app only — FR-020)

Follows the existing `MonthIncompleteBanner` widget pattern; mounted on the dashboard and atop Currency Settings.

| Trigger | Copy (intent) | Dismissable? |
|---|---|---|
| Month sealed offline (`provisional`) | "March closed with approximate rates — connect to correct them" | No while condition persists |
| `approximate` after grace/history failure | "March uses approximate rates (no history available)" | No; permanent while state holds |
| Live rates stale / fetch failing | "Rates last updated {time}" | No while stale |
| Degraded value on screen | "Some values can't be converted right now" | No while degraded |
| Seal needed while offline at rollover | "Connect once to seal {Month}'s rates" | No while pending |

**Rules**: banners are informational only — they never block the app; banner state is derived purely from seal/live-table state (contract §1 of month-seal-lifecycle), so a banner can never disagree with the numbers; SnackBars are reserved for *transient action results* (refresh ok/failed, main currency changed) — never for standing rate conditions.

## 3. Settings badge

- A small status indicator rendered on the Settings entry row (and the Currency Settings row) whenever **any** month is `provisional`/`approximate` **or** the live table is stale/degraded.
- Clears automatically when all months are final and rates are fresh — no user action required.

## 4. Convert-to control (per month, not on this screen)

- Lives with the month view (dashboard month header popup — existing control, repurposed semantics).
- Options: "Show in {mainCurrency} (default)" + other three currencies; per month; clearing restores main-currency default.
- Writes only that month's display choice — never touches money data (FR-011).

## 5. Accessibility & design

- Material 3, dark-mode aware (inherited from theme), no new color tokens.
- Status chips carry text labels, not color alone (playful-but-serious tone, Constitution VI).
- Money rendering delegated to the single formatter contract (currency-conversion §4) — this screen may not format numbers itself.
