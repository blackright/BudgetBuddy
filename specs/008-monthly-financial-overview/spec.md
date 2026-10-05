# Feature Specification: Monthly Financial Overview & Medical Bills

**Feature Branch**: `008-monthly-financial-overview`

**Created**: 2026-10-04

**Status**: Draft

**Input**: User description: "Monthly Financial Overview & Medical Bills — add income tracking, a clean monthly dashboard showing what was kept, month navigation, fix lost reimbursements, and correct the medical bill model to match how the user's insurer actually works (no deductible, two payment methods)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See what I kept this month (Priority: P1)

As someone who wants to understand my finances, I open the app and immediately see one number: how much of my income I actually kept this month. I can see where that money came from and where it went, without reading a wall of figures.

**Why this priority**: The user stated plainly that "what remained to me at the end of the month" is the single number they care about. Today the app shows two abstract numbers and has no concept of income at all, so this question cannot be answered. Everything else in this feature is supporting detail for this one answer.

**Independent Test**: Can be fully tested by entering a net salary and a few expenses of different statuses, then opening the dashboard and confirming the "kept this month" figure equals income minus what was actually paid plus what came back — and that it stays correct when a planned expense is added, deleted, or marked paid.

**Acceptance Scenarios**:

1. **Given** a net salary of $4,000 and $1,200 of expenses marked paid, **When** the user opens the dashboard, **Then** "kept this month" shows $2,800.
2. **Given** the same month with an additional $800 expense marked planned, **When** the user views the dashboard, **Then** "kept this month" still shows $2,800 and the $800 appears only as planned.
3. **Given** a reimbursement of $300 recorded against a paid expense, **When** the user views the dashboard, **Then** "kept this month" shows $3,100.
4. **Given** any month, **When** the user views the dashboard, **Then** the kept figure is shown as the single largest number and every other figure on screen is smaller.

---

### User Story 2 - Medical bills that reflect what I actually paid (Priority: P2)

As someone whose insurer pays most of my medical bills, I want each medical bill to record whether the hospital billed my insurer directly or whether I paid and waited for a refund, so that my budget reflects the money that actually left my account — not the full hospital charge.

**Why this priority**: The current model assumes the user always pays the full charge upfront, which overstates medical spending by roughly the insured portion on every insurer-paid bill. This actively misleads every total in the app, so it must be correct before those totals are presented as trustworthy.

**Independent Test**: Can be fully tested by entering one insurer-paid bill and one self-paid bill, then confirming the insurer-paid bill reduces available funds by only the user's share while the self-paid bill reduces them by the full charge until a reimbursement is recorded.

**Acceptance Scenarios**:

1. **Given** a $1,000 bill where the insurer paid the hospital directly and the user's share is 20%, **When** the bill is entered, **Then** available funds decrease by $200 and not by $1,000.
2. **Given** a $1,000 bill the user paid the hospital themselves, **When** the bill is entered, **Then** available funds decrease by the full $1,000.
3. **Given** a self-paid $1,000 bill awaiting an insurer reply, **When** the user later records $800 returned, **Then** available funds increase by $800 and the bill shows as finished.
4. **Given** an insurer-paid bill whose claim is rejected, **When** the rejection is recorded, **Then** the amount owed rises to the full $1,000 charge because the hospital pursues the user directly.
5. **Given** a self-paid bill whose claim is rejected, **When** the rejection is recorded, **Then** no funds return and the full amount remains spent.
6. **Given** any medical bill, **When** the user views it, **Then** no deductible amount or deductible progress is shown anywhere.

---

### User Story 3 - Money that comes back is never lost (Priority: P3)

As someone who waits weeks for an insurer to reply, I want to record a reimbursement whenever I get round to it and have it credited to the correct month, no matter how late I enter it.

**Why this priority**: Reimbursements entered in a later month than the original payment are currently discarded entirely, so real money silently disappears from the user's available funds. This is an active data-loss defect that affects the user's most important number.

**Independent Test**: Can be fully tested by recording an expense in one month, recording its reimbursement three months later, and confirming the money is credited to the original month and that the month totals still reconcile.

**Acceptance Scenarios**:

1. **Given** a $1,000 expense paid in January, **When** the user records an $800 reimbursement in April against that expense, **Then** January's "kept this month" includes the $800.
2. **Given** the same reimbursement recorded in April, **When** the user views April, **Then** April's own figures are unaffected by the January reimbursement.
3. **Given** an expense already carrying a reimbursement, **When** the user records a different amount for the same expense, **Then** the earlier amount is replaced rather than added to.
4. **Given** any reimbursement recorded in the app, **When** the user views any month, **Then** the amount is visible and never silently omitted.

---

### User Story 4 - Any month, past or future (Priority: P4)

As someone who reviews my spending month by month, I want to move between months to check what happened last month and to plan ahead for next month, and I want to fix mistakes in months I have already reviewed.

**Why this priority**: Today only the current calendar month is reachable, so past months cannot be audited and future months cannot be planned. The user's monthly review habit cannot be served until this exists. It ranks below the money-accuracy stories because it does not by itself make any figure more correct.

**Independent Test**: Can be fully tested by navigating to a previous month, confirming its figures are shown, editing an expense in it and confirming the change is reflected, then navigating forward to a future month and confirming a planned expense can be entered.

**Acceptance Scenarios**:

1. **Given** the user is viewing the current month, **When** they move to the previous month, **Then** all figures shown belong to that previous month.
2. **Given** a past month is displayed, **When** the user changes an expense in it, **Then** the change is accepted and that month's totals update.
3. **Given** the user has moved away from the current month, **When** they use the "Today" shortcut, **Then** the current month is displayed again.
4. **Given** a future month, **When** the user enters a planned expense against it, **Then** the expense is recorded for that future month and does not affect the current month.
5. **Given** the user changes month on the dashboard, **When** they move to the expenses or medical sections, **Then** the same month remains selected throughout.

---

### User Story 5 - Know what I have in the bank right now (Priority: P5)

As someone who wants a live answer before spending, I want to know how much money I have in the bank for the month I am looking at, and I want to state that figure honestly at the start of each month rather than have the app guess it.

**Why this priority**: This answers a different and narrower question than "what did I keep" — it is a live affordability check used before buying something. It is useful but secondary to the monthly verdict, and it is deliberately kept off the dashboard's default view so the primary answer stays unobstructed.

**Independent Test**: Can be fully tested by entering an opening balance and a net salary for a month, recording payments and returns, and confirming the displayed bank figure equals opening balance plus income minus payments plus returns for that month.

**Acceptance Scenarios**:

1. **Given** an opening balance of $1,200 and income of $4,000 with $1,200 paid out and $800 returned, **When** the user views the bank figure, **Then** it shows $4,800.
2. **Given** no opening balance has been entered for a month, **When** the user views the bank figure, **Then** the app prompts for it rather than assuming a value.
3. **Given** a completed month, **When** the user opens the following month, **Then** no figure is carried forward and the new month asks for its own opening balance.
4. **Given** a planned expense, **When** the bank figure is displayed, **Then** the planned amount does not change it.

---

### Edge Cases

- A month is opened but the user has not yet entered income, an opening balance, or any expenses. The app must show a clear prompt to start rather than display a misleading zero.
- The user records a reimbursement for an expense that has since been deleted. The reimbursement must not vanish silently; the user must be told and given the choice to remove it or restore the expense.
- A reimbursement amount exceeds the original payment. The bank and kept figures must not silently produce a negative expense; the excess must be shown as a distinct amount rather than hidden.
- A medical bill's service date falls in one month but the user pays it in the next. The bill belongs to the month of the service, and the user must be able to see this rule and override it if their insurer treats it differently.
- The user's insurer pays a different percentage than expected for a service. The user must be able to correct the percentage and every affected figure must update.
- The user changes their net salary mid-month. Months already reviewed must keep the salary that applied to them unless the user explicitly changes it.
- A future month is reached that has no opening balance and no income. Planned expenses may still be entered, but the kept figure must be marked as incomplete rather than shown as a real number.
- Two medical bills for the same provider and service in one month must remain separately editable and separately settled.
- The user deletes a month entirely. Any expense or reimbursement belonging only to that month must be reported before deletion completes.

## Requirements *(mandatory)*

### Income

- **FR-001**: The system MUST allow the user to record a net salary in settings, representing take-home pay after tax and insurance deductions.
- **FR-002**: The recorded net salary MUST apply to every month that does not define its own value.
- **FR-003**: The system MUST allow any individual month to override the net salary without affecting any other month.
- **FR-004**: Changing the net salary in settings MUST NOT retroactively alter months the user has already reviewed, except where the user explicitly changes those months.
- **FR-005**: The system MUST clearly indicate when a month uses an overridden salary rather than the settings value.

### Opening balance and money in the bank

- **FR-006**: The system MUST allow the user to record, for each month, the amount of money held in the bank at the start of that month.
- **FR-007**: The system MUST NOT carry any balance forward from one month to the next; each month MUST require its own recorded figure.
- **FR-008**: The system MUST display money in the bank for the selected month as: opening balance + income − payments made + money returned.
- **FR-009**: Money in the bank MUST be scoped to the selected month only.
- **FR-010**: The system MUST prompt for an opening balance when a month has none, rather than assuming a value.
- **FR-011**: A recorded opening balance MUST remain editable after the month has passed.

### The monthly report

- **FR-012**: The system MUST calculate "kept this month" as income − payments made + money returned for the selected month.
- **FR-013**: "Kept this month" MUST NOT depend on the opening balance, so that a mistyped opening balance cannot distort it.
- **FR-014**: Planned amounts MUST NOT reduce "kept this month".
- **FR-015**: Planned amounts MUST NOT reduce money in the bank.
- **FR-016**: Every month MUST be an independent report; no figure from one month MUST influence another month's report.
- **FR-017**: The system MUST retain per-month history so that later reporting features can build on it, without building any such reporting now.

### Dashboard presentation

- **FR-018**: The dashboard MUST display, without requiring any interaction, exactly one large primary figure — "kept this month" — together with a supporting line showing income and payments, and four labelled lines: income, payments made, money returned, and planned.
- **FR-019**: The dashboard MUST display income and money returned in green, payments made in red, and planned in orange.
- **FR-020**: Colour meaning MUST be consistent everywhere in the app and MUST NOT vary by screen.
- **FR-021**: Further metrics MUST exist but MUST remain hidden behind a single expand control until the user requests them.
- **FR-022**: The dashboard MUST show how much of the payments total was medical, and MUST provide a way to reach the medical breakdown from that figure.
- **FR-023**: The dashboard MUST NOT display a bank balance that spans months, an opening-balance breakdown, a medical breakdown, a safe-to-spend figure, or any chart.
- **FR-024**: Medical spending MUST be included in the dashboard's payment totals, and both the dashboard and the medical section MUST read that figure from a single source so they cannot disagree.
- **FR-025**: Where a month is missing income or an opening balance, the dashboard MUST indicate incompleteness rather than present a figure as final.

### Month navigation

- **FR-026**: The system MUST allow the user to move to the previous and next month from the dashboard, and MUST provide a shortcut back to the current month.
- **FR-027**: The selected month MUST remain in effect when moving between the dashboard, expenses, medical bills, and reports.
- **FR-028**: Months in the past MUST remain fully editable.
- **FR-029**: The system MUST allow a future month to be opened with its own income and opening balance, and MUST allow planned expenses to be entered against it.
- **FR-030**: Planned entries made against a future month MUST NOT affect the current month's figures.

### Reimbursement correctness

- **FR-031**: The system MUST record every reimbursement against the specific expense or medical bill it belongs to.
- **FR-032**: A reimbursement MUST be reported in the month of the expense or bill it belongs to, regardless of when the user records it.
- **FR-033**: The system MUST NOT discard a reimbursement because the user recorded it in a different month than the originating expense.
- **FR-034**: Recording a replacement amount for an expense that already has a reimbursement MUST replace the earlier amount rather than add to it.
- **FR-035**: The system MUST warn the user when a reimbursement refers to an expense that no longer exists, and MUST NOT delete it without the user's action.

### Medical bills

- **FR-036**: The system MUST NOT display any deductible amount or deductible progress for medical bills.
- **FR-037**: The system MUST remove deductible values from stored medical settings and MUST NOT carry them into any calculation or display.
- **FR-038**: Every medical bill MUST be treated as if no deductible applies.
- **FR-039**: Each medical bill MUST record a service type chosen from a user-editable list, pre-populated with radiology, lab work, specialist consultation, generalist consultation, surgery, and medicine or pharmacy.
- **FR-040**: The user MUST be able to add, rename, and remove service types.
- **FR-041**: Each medical bill MUST record which of the two payment methods applied.
- **FR-042**: For a bill where the insurer paid the hospital directly, the amount leaving the user's funds MUST be only the user's share and MUST never be the full charge.
- **FR-043**: For a bill where the insurer paid the hospital directly, the user's share MUST leave the user's funds at the moment the bill is entered, without waiting for a month-end event.
- **FR-044**: For a bill where the insurer paid the hospital directly, the system MUST NOT require a reimbursement or any payout document.
- **FR-045**: For a bill the user paid themselves, the full charge MUST leave the user's funds at the moment the bill is entered.
- **FR-046**: For a bill the user paid themselves, the user MUST be able to record the amount the insurer returned, and that amount MUST return to the user's funds.
- **FR-047**: For a bill the user paid themselves, the system MUST allow the user to attach a picture of the bill and a picture of the insurer's reply.
- **FR-048**: The percentage the user is responsible for MUST be recorded per bill and MUST be correctable after entry, with all affected figures updating.
- **FR-049**: Reimbursement of a medical bill MUST be all-or-nothing; the system MUST NOT offer or accumulate partial reimbursements.
- **FR-050**: When a self-paid claim is rejected, no funds MUST return and the full amount MUST remain spent.
- **FR-051**: When an insurer-paid claim is rejected, the amount owed by the user MUST increase to the full charge.
- **FR-052**: Each medical bill MUST carry one of the following states: planned, waiting for insurance, paid, finished, or rejected.
- **FR-053**: A medical bill's state MUST determine whether it counts as planned or as paid in the monthly totals, consistently with how every other expense behaves.
- **FR-054**: The system MUST allow the user to move a medical bill between states, and MUST update affected totals immediately.
- **FR-055**: A medical bill MUST belong to the month of the service it describes, and the user MUST be able to override that month.
- **FR-056**: Medical bills MUST appear in the general monthly totals as an ordinary category rather than as a separate system.

### Key Entities

- **Net Salary Setting**: The default take-home pay for all months, owned by settings.
- **Monthly Income**: The income that applies to one specific month, either inherited from the net salary setting or overriding it.
- **Opening Balance**: The money held in the bank at the start of one month, entered by the user and never derived.
- **Month Summary**: The derived report for a single month — kept, income, payments made, money returned, planned, and bank figure. Never stored, always recalculated.
- **Expense**: An existing spending record with a state of planned, paid, or cancelled. Planned does not reduce funds; paid does; money returned increases them.
- **Reimbursement**: Money returned against a specific expense or medical bill, attributed to that record's month rather than the date it was entered.
- **Medical Bill**: A medical service the user paid or is awaiting payment for, carrying service type, provider, payment method, percentage, state, and linked expense.
- **Service Type**: A user-editable classification of medical care, used to group medical spending within a month.
- **Medical Provider**: A doctor, clinic, or hospital the user has dealt with.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can state the amount they kept this month within 5 seconds of opening the app, without scrolling or tapping.
- **SC-002**: The primary "kept this month" figure occupies the largest visual element on the dashboard, and no other figure is presented with equal or greater emphasis.
- **SC-003**: With all colour cues removed, a user can still distinguish money in, money out, and money promised but unpaid, by position or label alone.
- **SC-004**: For any month, the kept figure equals income minus payments made plus money returned, verified across 10 randomly chosen months of test data with zero discrepancies.
- **SC-005**: Entering a reimbursement up to 12 months after the original payment credits the original month in 100% of cases, with no case of the amount being dropped.
- **SC-006**: For an insurer-paid medical bill, the reduction in available funds equals the user's share and never the full charge, verified across all test bills.
- **SC-007**: No deductible value, deductible progress indicator, or deductible field appears anywhere in the running application.
- **SC-008**: A user can navigate to any previous month and any next month in 2 interactions or fewer.
- **SC-009**: The medical total shown on the dashboard and the medical total shown in the medical section match in 100% of cases for the same month.
- **SC-010**: Changing an expense in a past month updates that month's kept figure and leaves every other month unchanged.
- **SC-011**: 90% of test users, given a month with income, payments, returns, and planned items, correctly state whether they were under or over budget for that month on first attempt.
- **SC-012**: No month carries a figure forward from a previous month; each month requires its own income or opening balance entry, verified across all test months.

## Assumptions

- **Constitution conflict — RESOLVED 2026-10-04**: Core Principle IV originally stated that for medical bills the "user pays full bill (reduces available), later records reimbursement (increases available)". This specification replaces that rule with two payment methods, where insurer-paid bills reduce available funds by only the user's share. The project owner approved the amendment; it is ratified in `.specify/memory/constitution.md` as constitution v1.2.0, with the superseded text, the reason, the approval and a six-step migration plan recorded in that file's *Amendment Record*. The remainder of Principle IV — planned does not reduce available, paid reduces it, reimbursed increases it — remains unchanged and is reinforced by FR-014 and FR-031 through FR-035.
- Only one net salary applies at a time. The app is single-currency per month for this purpose, with multi-currency conversion of individual expenses continuing to behave as it does today.
- "Kept this month" is a flow measure for one month and is not intended to represent a bank balance or a savings balance.
- Existing medical bills created before this feature are treated as self-paid bills in their full amount, because the previous model recorded them that way. Their percentages and reimbursements are preserved.
- Existing deductibles stored in medical settings are discarded rather than migrated, since no deductible applies.
- The user's insurer determines the percentage per service; the app records what the user reports and does not verify it against any policy.
- A month is identified by calendar month and year. A service or payment occurring near a month boundary belongs to the month of the service date unless the user overrides it.
- Future months may be opened for planning but are not expected to be complete; any month missing income or an opening balance is marked incomplete.
- All figures are entered manually. No connection to banks, insurers, or payroll systems is attempted.
- Analytics, charts, and historical comparison are deferred to a later feature; this feature only ensures per-month data is retained so that feature can build on it.
- Family plan and dependent tracking are out of scope, as the user's insurer applies no deductible that would require per-person tracking.