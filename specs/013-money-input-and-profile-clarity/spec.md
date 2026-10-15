# Feature Specification: Money Input & Profile Income Clarity

**Feature Branch**: `013-money-input-and-profile-clarity`
**Created**: 2026-10-14
**Status**: Draft

## Purpose

Two everyday usability problems, plus one clarity gap, are bundled into a single UI-only feature:

1. **Amount fields do not group digits.** There is no `TextInputFormatter` anywhere in `lib/`. Typing `1000000` stays `1000000`, while every read-only value in the app is shown as `1,000,000`. This makes entering money harder to read and to proof-read.
2. **Prefilled amounts do not clear when the user starts typing.** Fields that already hold a value (e.g. `0.00` for the default salary, or the previous amount when editing an expense) place the caret *inside* the value, so typing inserts digits into the wrong place and forces a manual select-all-and-delete first.
3. **The Settings income card does not name the profile it edits.** Income is per-profile, but the card never says which profile it belongs to, so it is easy to think the salary is global.

This feature fixes all three with one shared, consistent behaviour across every amount field. It changes **no data model and no database** — it is presentation-only.

## Clarifications

### Session 2026-10-14

- Q: On focus, should a prefilled value be wiped or selected? → A: **Select all** the text on focus. The first keystroke replaces it (satisfies "it should disappear"), but the value is still visible and editable if the user only wants to nudge it — this avoids accidental data loss on edit screens.
- Q: Grouping style — commas, spaces, or locale? → A: **Comma grouping (`1,000,000`)**, matching the app's existing display formatter (`money_format.dart` uses `NumberFormat('#,##0', 'en_US')`). Space grouping was rejected to avoid mixing styles.
- Q: Apply the fix to every amount field or just the salary field? → A: **Every amount field**, via one shared widget, so behaviour is identical app-wide.
- Q: Should the income card re-sync when the profile, month, or context changes? → A: **Yes.** Every income field re-syncs to the new context — including rendering empty or `0.00` when the new context has no value — and never keeps the previous context's text. Applies to **profile switch**, **month switch**, and **personal↔shared-space switch**.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Big amounts are easy to read while typing (Priority: P1)

When a user types a large amount into any amount field, the field inserts thousands separators as they type (`1000000` → `1,000,000`) and keeps the caret in a sensible place. The stored value is exactly the digits entered, with no separators.

**Why this priority**: The most frequent and visible annoyance; it affects every money entry in the app.

**Independent Test**: Open any amount field, type `1000000`, confirm the field reads `1,000,000`, save, and confirm the saved value is `1000000`.

**Acceptance Scenarios**:

1. **Given** an empty amount field, **When** the user types `1000000`, **Then** the field displays `1,000,000`.
2. **Given** a field showing `1,000,000`, **When** the user saves, **Then** the persisted amount equals `1000000` (minor units `100000000` for a 2-decimal currency).
3. **Given** a field showing `1,234.5`, **When** the user taps between digits and types, **Then** the caret stays logically next to the digit typed and the grouping remains correct.

### User Story 2 - Tapping a prefilled field and typing just works (Priority: P1)

When a user taps an amount field that already holds a value (a default `0.00` or a previously saved amount), the existing text is selected, so the first keystroke replaces it instead of being inserted into the middle of it.

**Why this priority**: Directly removes the reported "0.00 does not disappear" behaviour and prevents mis-entered amounts.

**Independent Test**: Open the Settings income card (value `0.00`), tap the field, type `5`, and confirm the field reads `5` (not `50.00` or `0.005`).

**Acceptance Scenarios**:

1. **Given** a field prefilled with `0.00`, **When** the user focuses it and types `5`, **Then** the field shows `5`.
2. **Given** a field prefilled with a real value (editing an expense), **When** the user focuses it and presses a digit, **Then** the old value is replaced by that digit (first keystroke), and the old value was still visible before typing.
3. **Given** a focused prefilled field, **When** the user does not type and moves away, **Then** the original value is unchanged.

### User Story 3 - It is clear whose income I am editing (Priority: P2)

In Settings, the income card names the active profile it edits, always shows the **current** context's values (never the previous profile's/month's/space's), and the new-profile flow offers an optional starting salary (defaulting to 0 if skipped).

**Why this priority**: Clarifies and corrects an existing per-profile behaviour; lower risk and less frequent than the input issues.

**Independent Test**: Switch profiles and confirm the income card header shows the active profile's name AND the amount field re-syncs to that profile's value; create a new profile, provide a starting salary, and confirm it appears on that profile's income card.

**Acceptance Scenarios**:

1. **Given** multiple profiles, **When** the user opens Settings, **Then** the income card shows the active profile's name.
2. **Given** the create-profile flow, **When** the user leaves the starting salary blank, **Then** the new profile is created with salary `0`.
3. **Given** the create-profile flow, **When** the user enters a starting salary, **Then** the new profile's income card shows that value.
4. **Given** profile A with salary `50000` and profile B with no salary set, **When** the user switches from A to B, **Then** the amount field shows B's value (`0.00`/blank), never A's `50000`.
5. **Given** the income card on a personal profile, **When** the user switches to a shared space and back, **Then** the fields and the summary line follow the newly active context.
6. **Given** a month with a salary override, **When** the user changes the selected month, **Then** the "<Month> only" field re-syncs to that month's override (or clears when it has none).

### Edge Cases

- Typing leading zeros (`007`) → displayed/parsed as `7`, not `00,7`.
- Pasting a value with separators (`1,234.56`) → normalised and parsed correctly, caret placed at the end.
- Empty field → validation still reports "Required" where the screen already required a value; parsers do not throw.
- A single decimal separator typed while grouping is active → at most one decimal point is accepted.
- Negative numbers → only where the underlying screen already allowed them; grouping must not swallow the minus sign.
- Percentage fields (insurance patient share, e.g. `20`) are **not** money: they get select-all-on-focus but **no** grouping.
- Currency with no fraction (e.g. HUF) entered as `1000000` → grouped as `1,000,000` and parsed as `1000000`.
- Switching to a profile/space that has no income set → the field shows empty or `0.00`, never the value left over from the previous context.
- Switching context while an unsaved edit is in the box → the context change wins; the stale text is discarded (no accidental carry-over between profiles).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Every money amount input field MUST display thousands separators (comma grouping) as the user types.
- **FR-002**: Grouping MUST NOT change the value: every amount parser MUST ignore grouping separators and whitespace, so a saved amount equals the digits the user entered.
- **FR-003**: When an amount field holds a prefilled/default value, focusing it MUST select the existing text so the first keystroke replaces it.
- **FR-004**: A prefilled zero placeholder (e.g. `0.00`) MUST NOT require manual deletion before typing.
- **FR-005**: The Settings "My income" card MUST display the name of the active profile it edits.
- **FR-006**: Creating a new profile MUST offer an optional starting salary that defaults to `0` when omitted.
- **FR-007**: All amount inputs MUST share one implementation (one widget + one formatter + one parser) so behaviour is identical across screens.
- **FR-008**: This feature MUST NOT change the data model, the Isar schema, or require a migration.
- **FR-009**: Percentage fields MUST receive select-all-on-focus but MUST NOT be comma-grouped.
- **FR-010**: When the active profile, the selected month, or the active context (personal profile vs shared space) changes, every income amount field MUST re-sync to the new context's value — including rendering empty or `0.00` when the new context has no value — and MUST NOT retain the previous context's text.

### Key Entities

- No new entities. Existing fields read/written unchanged: `UserProfile.defaultNetSalary`, `SharedSpace.defaultIncome`, and the per-month overrides.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Typing `1000000` into any amount field displays `1,000,000`; typing `1234.5` displays `1,234.5`.
- **SC-002**: Saving grouped input stores the exact value in every affected screen (verified by tests over add/edit expense, salary, opening balance, medical bill, space income).
- **SC-003**: Tapping a field prefilled with `0.00` and typing `5` yields `5`; the old value is never concatenated.
- **SC-004**: The Settings income card shows the active profile's name, updating when the active profile changes.
- **SC-005**: The full test suite is green with no regressions, and `flutter analyze` reports zero issues.
- **SC-006**: Switching the active profile, the selected month, or the personal↔shared-space context shows the new context's income in the field; if the new context has none, the field is blank/`0.00`; the previous context's number never lingers.

## Assumptions

- The app's money display style is comma grouping (`1,000,000`), per the existing `money_format.dart`.
- Flutter's built-in `TextInputFormatter` / `TextEditingController` selection APIs are sufficient; no new package is needed.
- Select-all-on-focus is an acceptable substitute for "clear on focus" and is preferred to avoid data loss on edit screens.
- The affected screens already validate/parse amounts; only the shared helper and widget wiring change.
