You are an elite Product Architect and Principal Systems Engineer with full contextual access to our current codebase. Your task is to analyze the user's provided feature specification, evaluate it against our existing repository architecture, improve it with strict constraints, and prepare it perfectly for a spec generation command (like `/speckit specify`).

CRITICAL PROTOCOL: You must present your analysis, architectural options, and the draft spec preview to the user first. You are STRICTLY FORBIDDEN from running any commands, modifying files, or finalizing the specification until the user explicitly responds with "Approved" or "Proceed".

Follow this exact multi-step execution lifecycle:

### 📊 1. Codebase Alignment & Feasibility Analysis
Compare the user's provided specification against the current project codebase and determine:
* **Feasibility:** Is this feature technically viable within our current stack, data models, and architectural patterns? Highlight any breaking structural conflicts.
* **Duplication Audit:** Have parts of this feature (or its underlying logic/entities) already been implemented in the codebase? Identify what already exists so we do not reinvent the wheel.

### 🚀 2. Proposed Innovations & Rationales (Strictly 5 to 6 Items)
Propose exactly between 5 and 6 innovative, production-grade feature enhancements or engineering best practices to add to the specification. For each proposed innovation, you must provide:
* **The Innovation:** The name and crisp definition of the requirement.
* **Why It Is Recommended:** The exact technical, performance, or user-experience problem it solves.
* **System Improvement:** The measurable architectural benefit (e.g., fault tolerance, zero-precision loss, scale readiness).

### 🏆 3. Highest Recommended Innovation
Explicitly select one innovation from your list as the absolute highest priority recommendation. Provide a detailed paragraph explaining exactly why this specific feature takes precedence over the others based on our current codebase maturity.

### 🎛️ 4. Architectural Implementation Options
Provide a markdown comparison table offering 2 alternative implementation patterns for how this entire feature should be structurally handled in our codebase. List the Pros and Cons of each approach, explicitly factoring in our existing technical debt and patterns.

### 📄 5. Draft Spec Preview
Show a preview of the fully rewritten, improved, and structured specification incorporating the verified baseline requirements along with your 5–6 new innovations, ready to be passed to the command tool.

### 🛑 CONTROL GATE: AWAITING AUTHORIZATION
Halt immediately. Present your full analysis and the draft spec preview. Do not run any commands. Ask the user for their preferred architecture option and explicit authorization to execute.

--------------------------------------------------
[RAW INPUT SPECIFICATION START]
{{

Feature Specification: Shared Financial Spaces

## Purpose

Allow multiple BudgetBuddy users to collaboratively manage a shared monthly budget while continuing to manage their personal finances separately.

A shared financial space represents a collaborative financial context for couples, families, roommates, or other trusted groups. Members can contribute income, record expenses, manage medical bills and reimbursements, and view the same shared financial position.

Personal financial records must never become visible inside a shared space unless the user explicitly adds or transfers an item to that shared space.

## Scope

This feature includes:

1. Create a shared financial space
2. Invite users to a shared space
3. Accept or decline invitations
4. Join and leave a shared space
5. Switch between personal and shared financial contexts
6. Manage shared members and roles
7. Record shared income contributions
8. Manage a shared monthly budget
9. Create and manage shared expenses
10. Create and manage shared medical bills
11. Record shared reimbursements
12. Calculate the shared available amount
13. Record member activity
14. Synchronise shared data between members
15. Preserve complete separation between personal and shared finances

## Core User Scenario

A user manages a personal monthly income and personal expenses privately.

The same user also belongs to a shared household space with another BudgetBuddy user.

Inside the shared space:

- Both members can contribute money to the shared monthly budget.
- Both members can add and manage shared expenses.
- Both members see the same shared available amount.
- Shared reimbursements increase the shared available amount.
- Personal income and expenses remain private.
- Shared financial activity does not modify either member’s personal available amount.

## Entities

### SharedSpace

Fields:

- id
- name
- description, optional
- avatar
- primaryCurrency
- createdByUserId
- createdAt
- updatedAt
- archivedAt, optional
- syncVersion
- syncStatus

Rules:

- A shared space must have at least one owner.
- The creator becomes the first owner.
- The name must not be empty.
- All shared records must reference the sharedSpaceId.
- Archiving a shared space must preserve its historical data.

### SharedMember

Fields:

- id
- sharedSpaceId
- userId
- displayName
- role
- status
- joinedAt
- invitedAt
- lastActiveAt
- invitedByUserId

Role values:

- owner
- administrator
- contributor
- viewer

Status values:

- invited
- active
- declined
- left
- removed

Rules:

- Membership must be unique for each user and shared space.
- Only active members may access shared financial data.
- A shared space must always retain at least one owner.
- A user may belong to multiple shared spaces.
- Removing a member must not delete financial records created by that member.

### SharedInvitation

Fields:

- id
- sharedSpaceId
- invitedByUserId
- invitedUserIdentifier
- assignedRole
- invitationToken
- status
- expiresAt
- createdAt
- respondedAt, optional

Status values:

- pending
- accepted
- declined
- expired
- revoked

Rules:

- Only authorised members may send invitations.
- An invitation may be accepted only once.
- Expired or revoked invitations cannot be accepted.
- Accepting an invitation creates an active SharedMember record.

### SharedMonthlyBudget

Fields:

- id
- sharedSpaceId
- year
- month
- primaryCurrency
- targetAmount
- createdAt
- updatedAt

Rules:

- A shared space may have only one budget record for each month.
- Previous monthly budgets must remain available as historical records.
- Changing the shared budget must not modify members’ personal budgets.

### SharedContribution

Fields:

- id
- sharedSpaceId
- monthlyBudgetId
- contributedByUserId
- amount
- currency
- convertedAmount
- exchangeRateSnapshot, optional
- contributionDate
- note, optional
- createdAt
- updatedAt

Rules:

- Contribution amount must be greater than zero.
- The contribution must belong to an active member.
- Contributions increase the funds available in the shared space.
- Contributions must not increase the contributor’s personal available amount.
- The original amount and currency must be preserved.

### SharedExpense

Fields:

- id
- sharedSpaceId
- createdByUserId
- paidByUserId, optional
- title
- description, optional
- amount
- currency
- convertedAmount
- exchangeRateSnapshot, optional
- categoryId
- status
- expenseDate
- paidAt, optional
- createdAt
- updatedAt

Status values:

- planned
- paid
- reimbursed
- cancelled

Rules:

- Planned expenses do not reduce the shared available amount.
- Paid expenses reduce the shared available amount.
- Reimbursements increase the shared available amount.
- Cancelled expenses do not affect the shared available amount.
- A shared expense must never affect a member’s personal available amount.

### SharedMedicalBill

Fields:

- id
- sharedSpaceId
- createdByUserId
- paidByUserId, optional
- title
- provider
- billedAmount
- currency
- insuranceCoveragePercent
- expectedReimbursementAmount
- actualReimbursementAmount
- status
- billDate
- paidAt, optional
- createdAt
- updatedAt

Rules:

- A paid medical bill reduces the shared available amount by the amount actually paid.
- An insurance percentage provides an estimate only.
- The actual recorded reimbursement increases the shared available amount.
- Actual reimbursement may differ from the estimated insurance reimbursement.
- Shared medical bills remain separate from members’ personal medical bills.

### SharedReimbursement

Fields:

- id
- sharedSpaceId
- sourceType
- sourceId
- recordedByUserId
- amount
- currency
- convertedAmount
- exchangeRateSnapshot, optional
- receivedAt
- note, optional
- createdAt

Source types:

- sharedExpense
- sharedMedicalBill

Rules:

- The source must belong to the same shared space.
- The source must have been paid before a reimbursement can be recorded.
- The reimbursement amount must be greater than zero.
- Total reimbursements must not exceed the amount eligible for reimbursement.
- Reimbursements increase only the shared available amount.

### SharedActivity

Fields:

- id
- sharedSpaceId
- performedByUserId
- actionType
- entityType
- entityId
- summary
- occurredAt
- syncStatus

Activity examples:

- Member added an expense
- Member marked an expense as paid
- Owner changed the monthly budget
- Member recorded a reimbursement
- Administrator invited a new member

Rules:

- Important financial and membership changes must create activity entries.
- Activity entries are read-only.
- Deleting or editing the source record must not silently remove its activity history.

## Shared Available Amount

The shared available amount must be calculated dynamically.

Formula:

sharedAvailableAmount =
    sharedMonthlyBudget.targetAmount
    + sum(sharedContributions)
    - sum(sharedPaidExpenses)
    - sum(sharedPaidMedicalBills)
    + sum(sharedReimbursements)

Rules:

- Planned items do not reduce the shared available amount.
- Cancelled items do not affect the shared available amount.
- Reimbursements increase the balance only after being recorded as received.
- All values must be converted to the shared space’s primary currency.
- The calculated value must not be stored as an independently editable balance.

## Personal and Shared Data Separation

The application must maintain two distinct contexts:

### Personal Context

Contains:

- Personal monthly budget
- Personal income
- Personal expenses
- Personal medical bills
- Personal reimbursements
- Personal analytics

### Shared Context

Contains:

- Shared monthly budget
- Member contributions
- Shared expenses
- Shared medical bills
- Shared reimbursements
- Shared analytics
- Shared membership and activity

Rules:

- Personal records must not appear in shared spaces automatically.
- Shared records must not affect personal calculations.
- Switching context must update all visible financial information.
- Every financial record must have exactly one ownership context.
- A record belongs either to a personal profile or to a shared space, never both simultaneously.

## Roles and Permissions

### Owner

Can:

- Edit shared-space settings
- Invite, remove, and manage members
- Change member roles
- Manage the monthly budget
- Create and manage financial records
- Archive the shared space
- Transfer ownership

### Administrator

Can:

- Invite and manage contributors and viewers
- Manage the monthly budget
- Create and manage financial records
- View activity history

Cannot:

- Remove the final owner
- Transfer ownership
- Permanently delete the shared space

### Contributor

Can:

- Add contributions
- Create shared expenses
- Create shared medical bills
- Mark permitted items as paid
- Record reimbursements
- View shared financial information

Cannot:

- Manage owners or administrators
- Archive the shared space
- change member roles

### Viewer

Can:

- View the shared dashboard
- View shared records
- View shared analytics

Cannot:

- Create, edit, delete, or change financial records
- Invite or remove members

## Main Workflows

### Create Shared Space

1. User enters a name and optional avatar.
2. User selects the primary currency.
3. System creates the shared space.
4. System assigns the creator as owner.
5. System creates the first monthly budget context.
6. Application opens the shared dashboard.

### Invite Member

1. Authorised member selects Invite Member.
2. Authorised member enters the recipient identifier.
3. Authorised member assigns an initial role.
4. System creates an invitation.
5. Recipient accepts or declines.
6. On acceptance, the recipient becomes an active member.

### Switch Financial Context

1. User opens the context switcher.
2. User selects Personal or a Shared Space.
3. Application updates the active context.
4. Dashboard, expenses, medical bills, reimbursements, and analytics reload for the selected context.
5. Navigation returns to the dashboard.

### Add Shared Contribution

1. Member enters an amount and currency.
2. Member optionally adds a note.
3. System stores the contribution.
4. System recalculates the shared available amount.
5. Other members receive the update through synchronisation.

### Add Shared Expense

1. Member creates a planned or paid expense.
2. Expense is assigned to the active shared space.
3. If planned, the shared available amount remains unchanged.
4. If paid, the shared available amount is recalculated.
5. The activity feed records the change.

### Record Shared Reimbursement

1. Member selects a paid shared expense or medical bill.
2. Member enters the amount actually received.
3. System validates the amount.
4. System creates the reimbursement.
5. Shared available amount increases.
6. Activity history records the reimbursement.

### Leave Shared Space

1. Member requests to leave.
2. System verifies that the user is not the final owner.
3. Membership status changes to left.
4. Historical records remain attributed to that member.
5. The shared space disappears from the former member’s active context list.

## UI Requirements

### Context Switcher

Displays:

- Personal profile
- Shared spaces
- Active context
- Create Shared Space action

### Shared Spaces Screen

Users can:

- View spaces they belong to
- Create a shared space
- Open a shared space
- View pending invitations
- Leave or archive a space where permitted

### Shared Dashboard

Displays:

- Shared available amount
- Monthly target
- Total member contributions
- Paid expenses
- Planned expenses
- Medical costs
- Reimbursements
- Recent member activity
- Quick actions

### Shared Members Screen

Displays:

- Member list
- Member roles
- Invitation status
- Invite action
- Role-management actions
- Remove or leave actions where permitted

### Shared Activity Screen

Displays chronological activity for:

- Membership changes
- Budget changes
- Contributions
- Expenses
- Medical bills
- Reimbursements

## Navigation

Routes:

- /shared
- /shared/create
- /shared/invitations
- /shared/:spaceId
- /shared/:spaceId/members
- /shared/:spaceId/activity
- /shared/:spaceId/contributions
- /shared/:spaceId/expenses
- /shared/:spaceId/medical
- /shared/:spaceId/reimbursements
- /shared/:spaceId/settings

The active personal or shared context must remain accessible through the dashboard header.

## Synchronisation Requirements

Shared financial spaces require synchronisation between different devices and users.

Rules:

- Shared changes must be saved locally first.
- Local changes must be queued when offline.
- Queued changes must synchronise when connectivity returns.
- Every synchronised record must include a version or updated timestamp.
- Conflicting changes must not silently overwrite financial records.
- Synchronisation failures must be visible to the user.
- Personal records must not be uploaded as shared records.
- Membership permissions must be validated before accepting remote changes.

## Offline Behaviour

While offline, active members can:

- View previously synchronised data
- Create shared expenses
- Create shared medical bills
- Record contributions
- Record reimbursements

Offline changes must display a pending synchronisation indicator.

Actions requiring remote validation may be unavailable offline, including:

- Accepting invitations
- Inviting or removing members
- Changing ownership
- Permanently deleting a shared space

## Validation and Error Conditions

Reject an operation when:

- Shared space does not exist
- User is not an active member
- User lacks the required permission
- Financial amount is zero or negative
- Currency is unsupported
- Related records belong to another shared space
- Invitation is invalid, expired, revoked, or already used
- Removal would leave the shared space without an owner
- Reimbursement exceeds the permitted amount
- Remote membership validation fails

## Privacy and Security

- Shared financial data is visible only to active members.
- Personal financial data remains private by default.
- Invitations must use secure, expiring tokens.
- Permission checks must occur in both the application and backend.
- Sensitive shared data must be encrypted in transit and at rest.
- Members must be clearly warned that information added to a shared space is visible to other active members.

## Non-Functional Requirements

- Offline-first financial entry
- Reliable multi-device synchronisation
- Deterministic currency calculations
- Clear personal/shared context distinction
- Role-based access control
- Auditable member activity
- Responsive Android-first interface
- Architecture compatible with future iOS, web, and desktop support

## Dependencies

Feature 20 depends on:

- Monthly Budget Setup
- Available Amount Calculation
- Dashboard Shell and Navigation
- Expenses Management
- Medical Bills and Insurance
- Reimbursements
- Multi-Currency System
- User Authentication
- Cloud synchronisation and backend membership validation

## Out of Scope

The initial version does not include:

- Bank account linking
- Automatic splitting or debt settlement between members
- Direct money transfers
- Chat or messaging
- Public shared spaces
- Anonymous membership
- Business accounting or payroll

}}
[RAW INPUT SPECIFICATION END]
