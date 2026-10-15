# Quickstart: Money Input & Profile Income Clarity

**Feature**: 013-money-input-and-profile-clarity
**Purpose**: validate the three UI fixes end-to-end — thousands grouping while typing, select-all-on-focus for prefilled amounts, and per-profile income clarity. Presentation-only: no schema change, no `build_runner`, no migration (FR-008).

---

## 0. Prerequisites

| Need | When |
|---|---|
| Nothing new | this feature adds no packages and no collections |
| Emulator or device | for the manual walkthrough below |

Build/verify commands:
```
flutter analyze
dart format --set-exit-if-changed .
flutter test
```

---

## 1. Money input (the shared pieces)

Three files under `lib/shared/presentation/` own all amount-entry behaviour, so
every screen is identical (FR-007):

| Piece | Path | Responsibility |
|---|---|---|
| `ThousandsSeparatorInputFormatter` | `input_formatters/thousands_separator_input_formatter.dart` | Groups digits with commas as the user types (`1000000` → `1,000,000`); keeps the caret sensible; tolerates at most one decimal point and a leading minus (FR-001, edge cases). |
| `parseMoneyInput` | `money_format.dart` | The one parser: strips `,` and whitespace then parses, so a grouped field saves the exact digits entered (FR-002). `tryParseMoneyInput` is the non-throwing form. |
| `MoneyField` | `widgets/money_field.dart` | Wraps a `TextFormField`: applies the formatter, selects all text on focus, re-syncs on `syncKey` change, and reports a parsed `double?` from `onChanged`/`onSubmitted`. |

### Adding a new amount field

```dart
MoneyField(
  key: const Key('myAmountField'),
  initialValue: currentValue,      // double?, null renders empty
  fractionDigits: 2,               // or null to trim trailing zeros
  syncKey: (profileId, month, spaceId), // omit if the field never changes context
  prefixText: '${currency.symbol} ',
  onSubmitted: (amount) => save(amount ?? 0.0),
)
```

Rules:
- **Never** hand-roll a number parser — call `parseMoneyInput` (FR-007).
- Give every field a stable `key` so tests can locate it.
- **Percentage** fields are *not* money: use a plain `TextFormField` with a
  `selectAllOnFocus(controller)` focus node — select-all but **no** grouping
  (FR-009).

### The `syncKey` re-sync rule (FR-010)

`syncKey` names the *identity* of the data behind the field — typically
`(activeProfileId, selectedYearMonth, activeSpaceId)`. When it changes between
rebuilds, `MoneyField` refreshes its text from `initialValue`; when it does not
change (e.g. the user is mid-edit), the text is left alone. This is what stops a
switched profile, month, or personal↔shared space from showing the previous
context's number. A new context with no value renders empty (or `0.00` where a
zero is meaningful).

Both income fields in `NetSalarySection`
(`lib/features/finance/presentation/net_salary_section.dart`) carry this key, and
the card header names the active profile (FR-005). Creating a profile offers an
optional starting salary that becomes `defaultNetSalary`, defaulting to `0`
(FR-006).

---

## 2. Manual Acceptance Walkthrough (single device)

1. **Grouping**: in any amount field (e.g. add an expense), type `1000000` →
   reads `1,000,000`; save → the stored amount is `1000000` (SC-001, SC-002).
2. **Decimal**: type `1234.5` → reads `1,234.5` (SC-001).
3. **Select-all**: open **Settings → My income** showing `0.00`, tap the field,
   type `5` → reads `5` (not `50.00` or `0.005`) (SC-003).
4. **Edit screen**: open an existing expense, focus the amount → the old value is
   selected; the first digit replaces it (SC-003).
5. **Profile name**: the income card shows the active profile's name; switch
   profiles → the name changes (SC-004).
6. **Starting salary**: add a profile with a salary (e.g. `4200`) → its income
   card shows `4,200.00`; add one with a blank salary → `0.00` (FR-006, US3).
7. **Re-sync**: switch profile, change the selected month, and switch into/out of
   a shared space → the income fields always show the new context's value, never
   the previous one's (FR-010, SC-006).
8. **Percentage**: in the medical patient-share field, focusing selects all, but
   digits are **not** comma-grouped (FR-009).

---

## 3. Done / Acceptance

| Check | Source |
|---|---|
| Typing `1000000` shows `1,000,000`; saving stores `1000000` | SC-001, SC-002 |
| Focusing `0.00` and typing `5` yields `5` | SC-003 |
| Income card shows the active profile's name, updating on switch | SC-004 |
| New profile with salary → shows it; blank → `0` | US3, FR-006 |
| Profile/month/context switch re-syncs every income field | SC-006, FR-010 |
| Percentage fields select-all without grouping | FR-009 |
| `flutter analyze` clean; full suite green; format unchanged | SC-005 |
| No schema change, no migration | FR-008 |
