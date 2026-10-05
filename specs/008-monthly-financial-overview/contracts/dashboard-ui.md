# Contract: Dashboard Layout & Colour Semantics

**Feature**: `008-monthly-financial-overview` | **Requirements**: FR-018 – FR-030 | **Data model**: [../data-model.md](../data-model.md)

Defines what the dashboard shows, in what order, at what emphasis, and in what colour. This contract is the oracle for the dashboard widget tests listed in [../quickstart.md](../quickstart.md) §5.

---

## 1. Default view — the only thing visible without interaction

Rendered top to bottom, with no scrolling and no tapping (SC-001).

| Order | Element | Content | Emphasis | Requirement |
|---|---|---|---|---|
| 1 | **Hero figure** | `kept` — labelled "Kept this month" | Largest element on screen. No other figure may match or exceed it | FR-018, SC-002 |
| 2 | Supporting line | `income` and `paymentsMade` in one short line beneath the hero | Small, muted | FR-018 |
| 3 | Line 1 | **Income** — `income`, labelled "In" | Small label + value | FR-018 |
| 4 | Line 2 | **Payments made** — `paymentsMade`, labelled "Out" | Small label + value | FR-018 |
| 5 | Line 3 | **Money returned** — `moneyReturned`, labelled "Back" | Small label + value | FR-018 |
| 6 | Line 4 | **Planned** — `planned`, labelled "Planned" | Small label + value | FR-018 |
| 7 | Expand control | A single control revealing the hidden detail group | Small, unobtrusive | FR-021 |
| 8 | Month navigator | Previous / month label / next, plus a Today shortcut | Compact, in the app bar | FR-026 |

**L1** — exactly one primary figure is displayed without interaction (FR-018).
**L2** — the hero is the single largest visual element; the four lines are strictly smaller (SC-002).
**L3** — with all colour removed, in / out / planned are still distinguishable by label and by fixed vertical position (SC-003).

---

## 2. Colour semantics

Fixed, global, identical on every screen (FR-019, FR-020).

| Meaning | Colour role | Applies to |
|---|---|---|
| Money in | **green** | `income`, `moneyReturned` |
| Money out | **red** | `paymentsMade` |
| Promised, unpaid | **orange** | `planned` |
| Money in the bank | neutral / primary | `moneyInBank` — deliberately **not** green, to avoid implying it is income |

**C1** — colour meaning MUST NOT vary by screen (FR-020).
**C2** — no figure may be coloured green unless money came in (FR-019).
**C3** — planned amounts MUST be visually distinct from paid amounts at a glance (Constitution VI).
**C4** — dark mode derives from the existing Material theme; the semantic mapping is identical in both modes.

Tokens are defined once in `lib/features/medical/presentation/medical_theme.dart` and consumed everywhere (R15). Screen-local colour literals are not permitted.

---

## 3. Hidden detail group

Collapsed by default; revealed by the single expand control (FR-021).

| Item | Requirement |
|---|---|
| Money in the bank for the selected month, or a prompt to enter it | FR-008, FR-010 |
| Medical portion of `paymentsMade`, with a route into the Medical tab | FR-022 |
| Cancelled total | Constitution IV |
| Whether the month uses an overridden income | FR-005 |
| Excess returned, when non-zero | R14 |

**H1** — nothing outside §1 requires interaction; the entire §1 set is visible on open (FR-018).
**H2** — the group MUST be the only collapsed content on the dashboard (FR-021).

---

## 4. Prohibited on the default view

None of the following may appear without first expanding (FR-023):

- a bank balance spanning months
- an opening-balance breakdown
- a medical breakdown
- a safe-to-spend figure
- any chart

**P1** — the safe-to-spend figure is removed from the dashboard's default view only. The underlying provider is retained, because six expense-screen call sites depend on it (R04 / plan Technical Context). This is a presentation change, not a deletion.
**P2** — the bank figure, when shown, is scoped to the selected month only (FR-009).

---

## 5. Medical integration

| Rule | Behaviour | Requirement |
|---|---|---|
| **MD1** | Medical spending is included in `paymentsMade` | FR-024, FR-056 |
| **MD2** | The medical figure shown on the dashboard is read from the same `MonthSummary.medicalPaid` the Medical tab uses | FR-024, SC-009 |
| **MD3** | The medical figure links to the Medical tab for the same selected month | FR-022, FR-027 |
| **MD4** | No deductible value or progress appears anywhere, including this screen | FR-036, SC-007 |

---

## 6. Incomplete months

When the month is missing an opening balance or income (FR-025):

| Condition | Behaviour |
|---|---|
| `openingBalance` absent | The bank line prompts for entry instead of showing a value |
| `income == 0` | The hero figure is marked **Incomplete**; it is not presented as a real number |
| `planned` present, month incomplete | Planned still shows; the hero stays marked incomplete |
| Future month, fully empty | A prompt to start, not a misleading zero (spec edge case) |

**I1** — an incomplete figure MUST be visually distinguishable from a computed one (FR-025).
**I2** — the app MUST never present an assumed value as a recorded one (FR-010).

---

## 7. Month navigation

| Control | Behaviour | Requirement |
|---|---|---|
| Previous | Moves to the previous calendar month | FR-026 |
| Next | Moves to the next calendar month | FR-026 |
| Month label | Shows the selected month | FR-026 |
| Today | Returns to the current calendar month; hidden or disabled when already current | FR-026 |

**N1** — both moves complete in two interactions or fewer (SC-008).
**N2** — the selected month persists across Dashboard, Expenses, Medical and Reports (FR-027).
**N3** — past months remain fully editable; the dashboard shows no read-only state (FR-028).
**N4** — a future month may be opened with its own income and opening balance, and accepts planned entries (FR-029).
**N5** — planned entries in a future month never affect the current month (FR-030).
**N6** — moving months provisions the target month's record on demand if absent (R16); no error state is shown to the user.

---

## 8. Worked acceptance checks

| Scenario | Expected dashboard state |
|---|---|
| US1.1 — income 4000, paid 1200 | Hero 2800 · In 4000 · Out 1200 · Back 0 · Planned 0 |
| US1.2 — plus planned 800 | Hero **still 2800** · Planned 800 · In/Out/Back unchanged |
| US1.3 — plus reimbursement 300 | Hero 3100 · Back 300 |
| US2.1 — insurer-paid 1000 @ 20% | Hero and Out reflect −200, not −1000; Medical tab shows the same 200 |
| US5.2 — no opening balance | Hero unaffected; hidden group prompts for the balance; no bank value shown |
| US4.3 — moved to a past month, then Today | Label returns to the current month; all figures recompute |

---

## 9. Out of contract

Charts and trends, category breakdowns other than the medical total, historical comparison, and any reporting surface beyond the lines listed above (spec Assumptions).