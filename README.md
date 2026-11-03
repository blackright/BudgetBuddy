# BudgetBuddy

BudgetBuddy is an offline-first personal finance app for people who want one
honest answer: **how much money is actually available this month?**

It keeps budgets, income, expenses, savings and medical reimbursements in the
month where the money really moved, while preserving the period each event
belongs to for reporting. It works with multiple currencies, personal profiles
and shared spaces.

## Why BudgetBuddy

Most money apps blur three different things together: what you expect to
receive, what you have confirmed, and what is still free to spend. BudgetBuddy
keeps them separate.

- **Expected money is not spendable money.** A salary expectation or a planned
  refund never changes a balance until you confirm the actual event.
- **Every figure has one month.** A late salary is counted in the month it
  arrived, not the month it was expected. Its salary period stays visible.
- **Nothing moves silently.** Savings, allocations and corrections require an
  explicit confirmation and leave a visible history.
- **History is append-only.** Corrections create a new record; they never
  rewrite the original.
- **Your data stays on your device.** There is no account server and no cloud
  sync service.

## Features

### Monthly money

- Opening balance and continuous month-to-month balance
- Free-to-use money, allocated money and savings shown separately
- Month isolation with clear incomplete or review states
- Multi-currency amounts with a single per-month rate table

### Income and salary

- Recurring or one-time income sources
- Expected income that becomes available only after confirmation
- Salary confirmation with actual amount, receipt date and salary period
- Corrections that keep the original receipt and its history

### Expenses and allocations

- Planned, paid and past-dated expenses
- Categories, merchants, receipts and search
- Purpose-based allocations with carry-forward
- Release, correct or move allocation money to savings

### Savings Vault

- Explicit deposits and withdrawals
- Continuous Vault balance across months
- Planned withdrawal reminders that never transfer money automatically
- Reversals that retain the original entry

### Pending Actions

One centre for everything that needs attention:

- Salary and income confirmations
- Overspent allocations
- Planned Vault withdrawals
- Medical bills that need review
- Month-end close and conflicts
- Incomplete setup
- Shared-space sync conflicts

Reading a notification or opening an action never completes it or changes a
balance.

### Medical bills and insurance

- Self-paid and insurer-paid bills
- Patient and insurer shares
- Refund and deduction tracking
- Finished bills that stay locked

### Shared spaces

- Personal profiles with independent data
- Shared spaces with Owner, Editor and Viewer roles
- Pairing by QR code
- Direct device-to-device sync on the same local network

### Security and privacy

- On-device Isar database
- Encrypted local storage
- App lock with device authentication
- No server, no background sync service, no advertising SDK

## Architecture

BudgetBuddy is built with:

- **Flutter** for the UI
- **Riverpod** for state and dependency wiring
- **Isar** for on-device storage
- **GoRouter** for navigation

The code is organised by feature:

```text
lib/
  core/          models, database, providers, routing, shared services
  features/      budget setup, finance, expenses, medical, vault,
                 pending actions, spaces, sync, analytics, settings
  shared/        reusable presentation components
test/            unit, widget and integration-style tests
assets/          production branding and report fonts
```

Financial calculations live in pure or well-scoped services, with the database
as the source of truth. Schema changes are shipped as numbered migrations.

## Getting Started

Install Flutter 3.47.6 or newer with Dart 3.13.5 or newer, then run:

```bash
flutter pub get
flutter run
```

After changing an Isar collection, regenerate the generated codecs:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Testing

```bash
dart format .
flutter analyze
flutter test
```

The project also includes a CI workflow that checks formatting, analysis and the
test suite.

Some database upgrade tests require a complete Isar schema fixture and are kept
separate from the normal unit and widget suites.

## Privacy

BudgetBuddy stores financial data locally. Shared-space changes are exchanged
directly between paired devices on the same local network; no third-party
service receives the data. Backups and exports are created only when the user
asks for them.

## Project Status

BudgetBuddy is under active development. The current release includes salary and
income confirmation, continuous balances, allocation carry-forward, the Vault,
Pending Actions, medical reimbursements and shared spaces. Final device
verification is ongoing for the latest release.

## License

See [LICENSE](LICENSE).
