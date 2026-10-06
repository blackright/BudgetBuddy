# Feature Specification: Multi-Currency System (Unified)

**Feature Branch**: `[010-multi-currency-system]`

**Created**: 2026-10-06

**Status**: Draft

**Input**: User description: "Feature Specification: Multi-Currency System (Unified)" — approved 2026-10-06 with Option A (per-month rate seals referenced to a single base currency).

## Purpose

Give BudgetBuddy full, trustworthy multi-currency support: users record money in whichever currency it was actually spent, choose their own main currency, and see every total — dashboard, expenses, medical bills, reimbursements, analytics — converted consistently, instantly, and with or without internet.

The system is built around one core promise: **the past never changes.** Each completed month is frozen with its own exchange rates, so historical totals are stable, reviewable, and available offline. Only the current month follows live rates.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Spend in any currency, see my month in my main currency (Priority: P1)

As a user, I record an expense in the currency I actually paid in (forints, dollars, euros…), and the dashboard shows my month's totals in my main currency, with the original amount always visible next to it.

**Why this priority**: This is the foundation. Without correct, consistent conversion on the create-and-view path, no other multi-currency behaviour matters.

**Independent Test**: Create expenses in HUF, USD and EUR with the profile's main currency set to HUF; verify every total on the dashboard, expense list and expense detail equals the original amounts converted at the displayed rate, and that each original amount is still shown.

**Acceptance Scenarios**:

1. **Given** a profile whose main currency is HUF, **When** the user adds a 10 USD expense, **Then** the dashboard shows the converted amount in HUF next to the original "10 USD".
2. **Given** expenses in three different supported currencies, **When** the user opens the dashboard, **Then** all totals are presented in one single main currency and reconcile exactly with the sum of the converted original amounts.
3. **Given** an amount entered in an unsupported currency, **When** the user submits the entry, **Then** the system rejects it and lists the four supported currencies.
4. **Given** the device is offline, **When** the user creates, edits or deletes an expense, **Then** the operation succeeds without any rate lookup and without any error.

---

### User Story 2 - Closed months never move (Priority: P1)

As a user, once a month is over, I want its totals frozen at that month's exchange rates forever — so reviewing March in July shows exactly what March actually cost, even offline, even if rates have changed since, and even if I change my main currency.

**Why this priority**: This is the correctness heart of the feature. It is what makes history deterministic and offline-first at the same time; without it, "change my main currency" would silently rewrite the past.

**Independent Test**: View a closed month's totals, then change rates (or go offline for weeks, or switch main currency), reopen the app and view the same month — the totals must be identical every time.

**Acceptance Scenarios**:

1. **Given** a completed month that has been sealed with its rates, **When** the user views that month weeks later with the device in airplane mode, **Then** all of its totals display identically to the first viewing.
2. **Given** a completed month, **When** live exchange rates change afterwards, **Then** no total belonging to that completed month changes.
3. **Given** the app is opened for the first time in a later calendar month, **When** the previous month closes, **Then** the system captures that month's rates and seals it without requiring any user action.
4. **Given** a sealed month, **When** the user switches main currency, **Then** the month re-displays in the new currency instantly and no stored amount or rate belonging to that month is modified.

---

### User Story 3 - Choose my own main currency, change it any time (Priority: P2)

As a user, I pick my main currency in my profile (default: HUF). Every month and every screen uses it as the default display currency. When I change it, all screens update immediately — nothing is rewritten, and past months keep their own rates.

**Why this priority**: High personal-value and the original spec's headline promise ("all screens must update instantly"), but it depends on US1 and US2 being correct first.

**Independent Test**: With data spread across several months, switch the main currency from HUF to EUR and verify every screen re-displays within a second while a before/after inventory of stored records shows zero modifications.

**Acceptance Scenarios**:

1. **Given** a profile with main currency HUF, **When** the user changes it to EUR in their profile, **Then** all screens display EUR immediately (within one second) with no prompt and no progress wait.
2. **Given** the main currency has been changed, **When** the user inspects any stored expense, reimbursement or bill, **Then** its original amount and original currency are unchanged.
3. **Given** multiple profiles on the device, **When** each profile sets a different main currency, **Then** each profile's screens use its own choice independently.

---

### User Story 4 - View any month in any currency, independently (Priority: P2)

As a user, I want a "convert this month to…" choice that belongs to each month on its own — so March can be reviewed in USD while April stays in forints — separate from my profile's main currency.

**Why this priority**: Makes multi-month review genuinely useful for travellers, cross-border earners and multi-currency bank users, but builds on the conversion engine already proven in US1–US3.

**Independent Test**: Set March's convert-to to USD and April's to CAD; verify both display simultaneously and correctly, that neither affects the other, and that clearing a choice falls back to the main currency.

**Acceptance Scenarios**:

1. **Given** main currency HUF, **When** the user sets March's convert-to choice to USD, **Then** March displays in USD while every other month continues to display in HUF.
2. **Given** a month with an explicit convert-to choice, **When** the user clears it, **Then** that month falls back to the profile main currency.
3. **Given** a closed month, **When** the user views it in a currency other than the main currency, **Then** the conversion uses only that month's own sealed rates and requires no network.

---

### User Story 5 - I can see and trust the rates (Priority: P3)

As a user, I want a Currency Settings screen showing my main currency, the current rate table with when it was last updated, every month with its rate status (sealed / provisional / approximate), a manual refresh, and clear banners when something needs my attention — so I always know what a number is based on.

**Why this priority**: Transparency and trust; required before release, but it reports on the machinery the earlier stories already build.

**Independent Test**: Open Currency Settings and verify every month appears with a status and date; turn off the network, reopen the app after a month boundary, and verify the "needs saving / approximate" banner and settings badge appear.

**Acceptance Scenarios**:

1. **Given** the device is offline when a month closes, **When** the app opens, **Then** the month is closed with the last known rates, visibly labelled "approximate", and a banner explains that connecting will correct it — and the app remains fully usable.
2. **Given** an approximate month within its 7-day correction window, **When** the app later opens with internet, **Then** its rates are upgraded to final automatically and the label disappears.
3. **Given** any month that is not yet finally sealed, **When** the user opens Currency Settings, **Then** the settings badge and the month list show exactly which months are provisional or approximate and why.
4. **Given** a moment when no rate is available for a needed conversion, **When** the affected value is displayed, **Then** it is clearly labelled as unavailable/unreliable — it is never silently treated as a 1:1 rate.
5. **Given** the rate table was refreshed 5 hours ago, **When** the user reopens the app with internet, **Then** no new refresh occurs until 24 hours have passed, and the settings screen shows the time of the last successful refresh.

---

### Edge Cases

- **No internet at month end**: the month still closes (never blocks the app), using the last known rates, labelled "approximate", retried on later opens.
- **User offline for weeks (several months missed)**: each missed month requests its own month-end rates for that date; if that is impossible, it seals with the last known rates and is permanently labelled "approximate" rather than using a wrong or current rate silently.
- **Rate service unreachable mid-month**: the current month continues on the last known rates, visibly marked as stale; no entry is blocked.
- **Missing or unusable rate for a conversion**: the value is shown with an explicit "unreliable/unavailable" label and a banner; a fabricated 1:1 rate is never substituted.
- **Record with an unknown/legacy currency code** (e.g. an old GBP entry): the record is preserved, excluded from converted totals, and surfaced for correction — never crashes a screen.
- **Negative or zero amounts**: rejected at entry.
- **Amounts that cannot be represented exactly in the currency's smallest unit**: flagged for user review during upgrade — never silently rounded.
- **First launch with no network**: a baseline rate set bundled with the app allows conversion to work from the first open.
- **Main currency changed while several months are open on screen**: all visible months re-display; nothing is written for any month.
- **Two conversions chained** (A → B → C): must equal the direct conversion A → C for the same month; any inconsistency is a defect, not a rounding artefact.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST support exactly four currencies — HUF (default), USD, CAD, EUR — as one single shared definition (code, symbol, decimal places, name) used by every screen and every record; unsupported currencies MUST be rejected at entry, and the legacy GBP option MUST be removed from all lists.
- **FR-002**: Every expense, reimbursement and medical bill MUST store the currency it was originally recorded in, and MUST always display that original amount and currency alongside any converted value.
- **FR-003**: Each completed calendar month MUST acquire its own exchange-rate set, captured for that month's close date, covering all four supported currencies.
- **FR-004**: Month sealing MUST happen automatically on the first app open in any later calendar month, without user action, and MUST never block app usage.
- **FR-005**: The current month MUST use the latest known rates, refreshed at most once every 24 hours when online.
- **FR-006**: Once a month is finally sealed, its rates and totals MUST be immutable: later rate changes, main-currency switches, or offline periods MUST NOT alter them, and viewing them MUST NOT require the network.
- **FR-007**: If sealing happens without internet, the month MUST close with the last known rates in a visible "provisional/approximate" state, show an explanatory banner, retry on subsequent opens, upgrade to final when a rate for that month arrives within a 7-day grace window, and freeze permanently after that window.
- **FR-008**: For months that were never sealed (user offline across month boundaries), the system MUST request the rates for each missed month's own close date; where that is impossible, it MUST fall back to the last known rates and label those months permanently as approximate.
- **FR-009**: Each profile MUST have its own main currency (default HUF), used as the default display currency for every month and every screen.
- **FR-010**: Changing the main currency MUST update every screen immediately (within one second) and MUST NOT modify, recalculate-then-persist, or invalidate any stored amount, rate, or month seal.
- **FR-011**: Each month MUST offer an independent, display-only "convert this month to…" choice that overrides the main currency for that month alone, defaults to the main currency when unset, and can be cleared at any time.
- **FR-012**: Conversion MUST be deterministic: the same month, amounts and currencies always produce the same output, computed without any network access.
- **FR-013**: Conversions MUST be mutually consistent within a month: converting through an intermediate currency must yield the same result as the direct conversion.
- **FR-014**: The system MUST NEVER fabricate a rate. When no usable rate exists, the value MUST be presented with an explicit unavailable/unreliable label; a missing rate MUST NEVER be silently treated as 1:1.
- **FR-015**: All money MUST be counted in whole minor units of its currency (HUF: no decimal places; USD, CAD, EUR: two), with rounding applied exactly once, at display time.
- **FR-016**: Insurance and patient-share percentages MUST be applied in the original currency (percentages are currency-independent); only displayed totals are converted.
- **FR-017**: Creating, editing and deleting any financial record MUST work fully offline with no rate lookup.
- **FR-018**: Dashboard, expense list/detail, medical bill list/detail, reimbursement entry, analytics and settings MUST all present converted values through one single conversion and formatting path, so no two screens can disagree.
- **FR-019**: A Currency Settings screen MUST let the user: choose the main currency, view the current rate table with last-updated timestamps, refresh rates manually, see every month with its seal status and rate date, retry sealing for anything not final, and read any active staleness/degraded banners.
- **FR-020**: The system MUST communicate rate problems in-app only (banners plus a settings badge) — triggered by: a month needing sealing while offline, a month still approximate after a retry, a missing rate for a viewed value, and stale current rates. No push/system notifications are required.
- **FR-021**: Upgrading existing data MUST leave every stored amount numerically equivalent or preserve its original value; any record that cannot be converted exactly MUST be flagged for review rather than silently altered.
- **FR-022**: The conversion of any month's data MUST be computable from stored data alone — opening, viewing and calculating a month MUST never depend on connectivity once that month's rates are known.

### Key Entities

- **UserProfile**: the app's user; key attributes include **main currency** (one of the four supported), per profile.
- **Currency**: supported money definitions — code, symbol, decimal places, display name; exactly HUF, USD, CAD, EUR; HUF is the default.
- **MonthRateSeal**: the frozen rate set for one calendar month — month key, rates for all four currencies, status (`open` for the current month, `provisional`, `sealed`, `approximate`), the date the rates represent, when they were fetched, and retry count.
- **LiveRateSet**: the latest known rates for the current month — one rate per supported currency, plus last-updated timestamp.
- **Expense**: an outbound transaction — amount, original currency, status, the month it belongs to, and its category/notes as today.
- **Reimbursement**: money returned against an expense or medical bill — amount, original currency, the month it belongs to, optional note.
- **MedicalBill**: a health transaction — amount, original currency, patient-share percentage, the month of service (with user override), linked expense where applicable.
- **MonthlyBudget**: one month's budget — its financial figures plus the display-only **convert-this-month-to** currency choice.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of displayed converted totals reconcile exactly with the sum of the underlying original amounts converted at the rate shown for that month — no screen shows a total another screen contradicts.
- **SC-002**: Changing the main currency updates every screen within 1 second, and a full inventory of stored records before and after shows **zero** modifications.
- **SC-003**: Re-opening a sealed month at any later date, online or offline, reproduces **100% identical totals** in 100% of test runs.
- **SC-004**: With the device in airplane mode, a user can view all history, and create/edit/delete records, with **zero errors and zero blocked actions**; the only visible concessions are labelled rate banners where a month is still approximate.
- **SC-005**: **Zero** displayed values are derived from an invented rate: every unavailable conversion is visibly labelled, verifiable by test across all 12 directed currency pairs.
- **SC-006**: Any two months can be displayed in two different currencies at the same time, each using only its own month's rates, with no effect on one another.
- **SC-007**: After a failed sealing attempt, the explanatory banner appears on the very next app open, and the settings badge lists every month that is not final within one navigation step.
- **SC-008**: Currency Settings shows a status and rate date for **100% of the months** the user has data for.
- **SC-009**: Round-trip conversions are consistent: for every month, all 12 directed pairs satisfy A→B→C = A→C within the display rounding tolerance of that currency.

## Assumptions

- **Decisions confirmed by the product owner (2026-10-06)**: months seal automatically on first app open in a later month; a full four-currency rate set is captured per month; all purchases in a month are valued at that month's rates; offline sealing is provisional with a 7-day correction window then permanent freeze; missed months request historical month-end rates with last-known fallback labelled approximate; convert-to is stored per month and separate from the profile main currency; user communication is in-app banners and badges only; money precision switches to whole minor units in this feature (single cut).
- "Month" means the calendar month, matching how monthly budgets and medical service months already behave.
- Main currency is a per-profile setting; multi-profile behaviour is unchanged apart from this field.
- Insurance patient-share percentages are dimensionless and never converted; only totals are.
- Historical month-end rates: assumed obtainable from the rate provider; if the provider cannot serve historical dates, the approved fallback (last known rates, permanently labelled approximate) applies, and seeking a capable provider is a follow-up, not a blocker.
- A small baseline rate set ships with the app for first-launch-without-network; it is treated as approximate until refreshed.
- Existing records keep their original currency and amounts; upgrade is lossless or flagged, never silent.
- The analytics area is currently a placeholder; it consumes the same single conversion path whenever real content arrives — no separate conversion work is scoped for it.
- The error-recovery notification is in-app only; a future system-push variant would be a separate feature.
