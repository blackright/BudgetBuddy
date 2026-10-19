# BudgetBuddy

BudgetBuddy is a Flutter app that tells you one honest thing about your money
every month: **how much you kept**. It tracks budgets, expenses and medical
bills, keeps every figure inside the month it truly belongs to, and works in
multiple currencies and shared spaces.

## Features

- **Monthly budget & opening balance** — one opening balance per month, resolved
  income (default salary or a per-month override), and a month that is either
  *complete* or clearly flagged *incomplete*.
- **Bring in past months** — when creating a space, move this month, this year,
  or every eligible month from your personal budget into it in one step (a move,
  never a copy).
- **Expenses** — create, edit, search, filter and cancel expenses; planned vs
  paid; per-category tracking; receipt attachments.
- **Medical bills & insurance** — self-paid vs insurer-paid bills, patient and
  insurer share, and a finished bill that is unmistakably locked. A payout is
  credited to the **month after** its bill (FR-032).
- **Reimbursements** — money really did come back, so a return is never silently
  dropped: one expense can never accrue two payouts, and a return whose target
  was deleted (an *orphan*) is kept and surfaced for you to resolve.
- **Returned money, split** — the Dashboard's "Returned" total is broken down
  into an **Insurance return** (paid back on a medical bill) and **Expense
  returns** (paid back on ordinary reimbursable expenses). The two always sum to
  the total.
- **Multi-currency** — expenses carry their own currency; a month displays in one
  currency through a single per-month rate table, so no screen can disagree about
  a rate. A converted figure carries a footnote, and when a rate is missing the
  original amount is shown beside the converted one rather than a wrong number.
- **Sealed (frozen) months** — once a month is sealed it is immutable for every
  role, including the Owner, so history cannot be rewritten after the fact.
- **Money input** — a dedicated money field that groups digits as you type and
  reports the exact value, so an amount is never misread while entering it.
- **Time-picker safety** — the time picker degrades gracefully at small text
  scales instead of throwing.
- **Shared spaces** — create a space, give people a role (Owner can manage
  people and settings, Editor can change money, Viewer is read-only) and share
  months. People are global and pair once via QR; the same contact can join any
  space. Edits then travel directly to every paired phone on the same local
  network — no server, no background service (see **Status**).
- **Profiles** — switch between personal profiles, create new ones, and delete a
  profile along with its personal data.
- **App theme** — follow the system, or pick light/dark, saved per profile.
- **Charts & analytics** — pure aggregation over the existing rows (no chart
  reads the database or converts currency itself): spending by category, medical
  patient-vs-insurer split, a contribution breakdown per member, and shared vs
  personal comparison.
- **Opening on the current month** — if the app comes back after the calendar
  month rolled over, it shows the current month rather than the one it was left
  on (a future month you chose on purpose is kept).

## Architecture

- **Flutter** UI with **Riverpod** for state. The selected month lives in a single
  provider, so every screen is scoped to it without per-screen plumbing (FR-027).
- **Isar** for on-device storage. Collections are the source of truth; schema
  changes ship as numbered migrations.
- **Feature-based modules** under `lib/features/` — each feature owns its data,
  domain and presentation layers:

  | Feature | Responsibility |
  | --- | --- |
  | `budget_setup` | First-run budget and opening balance |
  | `finance` | Net salary and the monthly finance row |
  | `engine` | Pure derivations: month summary, True Available, Safe to Spend |
  | `expenses` | Expenses, categories, reimbursements |
  | `medical` | Medical bills, insurance profiles, payment lifecycle |
  | `analytics` | Chart data aggregation and chart widgets |
  | `dashboard` | The monthly verdict and its navigator |
  | `spaces` | Shared spaces and membership |
  | `pairing` | Identity pairing and the People list |
  | `sync` | Cross-device synchronisation |
  | `vault` | Savings vault |
  | `identity` | Local identity and app lock |
  | `settings` | Preferences (currency, theme, confirmations) |

- Cross-cutting code lives under `lib/core/` (models, database, providers,
  routing, presentation).

### Design rules worth knowing

- **Month isolation**: a figure never blends two months. A reimbursement is
  attributed by its `originYearMonth`, not by when it was recorded (FR-032).
- **No silent clamping**: an over-reimbursement is surfaced as its own figure
  rather than quietly flooring a balance at zero.
- **One rate governs**: a single per-month `RateTable` is the only rate source the
  runtime reads.
- **Pure aggregation**: the chart layer computes from rows already in memory; no
  chart queries Isar or converts currency (FR-001).

## Status

Specs `011`–`015` and where they stand:

| Spec | Feature | State |
| --- | --- | --- |
| `011` | Shared financial spaces | **Shipped** — spaces, Owner/Editor/Viewer roles, invites, months in a space |
| `012` | Cross-device shared spaces | **Delivered via 015** — signed change log, sync engine, codecs and appliers |
| `013` | Money input & profile clarity | **Shipped** — money field, conversion footnotes, profile switcher/deletion, app theme, time-picker safety |
| `014` | Charts & analytics | **Shipped** |
| `015` | Wire device sync | **Code complete — manual sign-off pending** — peer-to-peer delivery between two paired phones is wired into the app and covered by the hermetic `test/features/sync/` suite; the two-phone checklist on real devices is the remaining sign-off |

Cross-device sync (`012`/`015`) is **local-network only**: two paired phones
exchange changes directly — no server, no background service. Delivery is wired
and covered by the hermetic sync suite; until the two-phone checklist is run on
real devices, treat cross-device sharing as not yet signed off (see
`specs/015-wire-device-sync`).

## Getting Started

Install Flutter 3.47.6 (Dart 3.13.5), then:

```bash
flutter pub get
flutter run
```

After changing an Isar collection, regenerate the codecs:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Testing

```bash
dart format .
flutter analyze
flutter test
```

Physically verified on an Android device (Samsung SM G965F).

## Specifications

The features are specified and planned under `specs/` (one numbered folder per
feature, e.g. `specs/014-charts-and-analytics`), each holding its `spec.md`,
`plan.md`, `tasks.md` and design artefacts.
