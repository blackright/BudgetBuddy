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

Feature Specification: Multi‑User Profiles & Shared Financial Spaces (Unified)

## Purpose
Provide a complete multi‑user system that supports:
- Multiple personal profiles on one device
- Shared financial spaces where multiple users collaborate
- Shared income + shared expenses
- Personal income + personal expenses
- Full data isolation between personal and shared contexts
- Instant switching between profiles and shared spaces

This module enables couples, families, roommates, or business partners to manage finances together while still keeping personal finances separate.

## Sub‑Features Included
1. Create Personal Profile
2. Create Shared Financial Space
3. Switch Between Personal Profile and Shared Space
4. User‑Scoped Data Isolation
5. Shared Data Synchronization

## Entities Involved
- UserProfile (personal)
- SharedSpace (group)
- SharedMember (link table)
- Expense
- MedicalBill
- Reimbursement
- CurrencyRate
- Settings

## Personal Profile Fields
- id (string)
- name (string)
- avatar (string or emoji)
- primaryCurrency (enum)
- monthlyAvailableAmount (decimal)
- createdAt (datetime)
- lastActiveAt (datetime)

## SharedSpace Fields
- id (string)
- name (string)
- avatar (emoji or icon)
- primaryCurrency (enum)
- sharedMonthlyIncome (decimal)
- createdAt (datetime)

## SharedMember Fields
- id (string)
- sharedSpaceId (string)
- userProfileId (string)
- role (enum: owner, member)
- joinedAt (datetime)

## Core Rules

### Personal Profiles
- Fully isolated data
- Personal expenses, medical bills, reimbursements belong only to that user
- Personal monthlyAvailableAmount is independent

### Shared Spaces
- All members see the same shared expenses, shared medical bills, shared reimbursements
- Shared monthly income is used to compute shared availableAmount
- Shared expenses reduce shared availableAmount
- Shared reimbursements increase shared availableAmount
- Shared currency settings apply to all members

### Switching Context
- User can switch between:
  - Personal Profile
  - Any Shared Space they belong to
- Switching context reloads:
  - expenses
  - medical bills
  - reimbursements
  - dashboard values
  - analytics
  - currency settings

### Data Isolation Rules
- Personal data is visible only in personal profile
- Shared data is visible only inside shared space
- No cross‑contamination
- All queries must filter by:
  - userId (personal)
  - sharedSpaceId (shared)

### Shared Expense Logic
- Shared expenses behave exactly like personal expenses
- But they belong to sharedSpaceId instead of userId
- Status flow identical:
  - planned → paid → reimbursed → cancelled
- Reimbursements increase shared availableAmount

### Shared Medical Bill Logic
- Same as personal medical bills
- Insurance logic applies normally
- Reimbursements increase shared availableAmount

## UI Requirements

### Profile & Shared Space Switcher
User can:
- View personal profile
- View all shared spaces they belong to
- Switch between them instantly
- Create new shared space
- Invite members (local-only for now)
- Edit shared space name/avatar
- Leave shared space (unless owner)

### Shared Space Dashboard
Shows:
- shared availableAmount
- shared expenses
- shared medical bills
- shared reimbursements
- shared analytics

### Personal Dashboard
Shows:
- personal availableAmount
- personal expenses
- personal medical bills
- personal reimbursements
- personal analytics

### Shared Expense Screens
- identical to personal expense screens
- but scoped to sharedSpaceId

### Shared Medical Bill Screens
- identical to personal medical bill screens
- but scoped to sharedSpaceId

## Navigation
Accessible from:
- Settings → Profiles & Shared Spaces
- Dashboard (profile/shared avatar button)
- Onboarding (first profile creation)

## Non‑Functional Requirements
- Offline‑first
- Instant context switching
- Deterministic data isolation
- Local persistence (Drift)
- Shared data consistency


}}
[RAW INPUT SPECIFICATION END]
