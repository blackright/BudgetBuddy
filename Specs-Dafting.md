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

Feature Specification: Onboarding & First-Time Setup (Unified)

## Purpose
Provide a guided first-time experience that helps users configure the application correctly before they begin tracking finances.

The onboarding process should be friendly, simple, modern, and focused on quickly bringing users to a functional dashboard while collecting only the information required for the initial setup.

## Sub-Features Included
1. Onboarding Flow
2. First-Time Setup

## Objectives
- Introduce the application
- Explain the app's core concepts
- Create the first profile
- Configure the first monthly budget
- Configure the first currency
- Configure security settings
- Guide users into the dashboard

## Entities Involved
- UserProfile
- SecurityConfig
- MonthlyBudget
- SharedSpace (optional later)
- AppSettings

## First Launch Detection

Rules:
- Detect whether application is launched for the first time.
- If no profile exists:
  - Launch onboarding immediately.
- If at least one profile exists:
  - Skip onboarding.
  - Navigate directly to authentication/dashboard.

## Onboarding Flow

### Step 1: Welcome Screen

Purpose:
- Introduce the application.

Content:
- App overview
- Main benefits
- Personal finance assistant explanation

Actions:
- Continue
- Skip (optional)

### Step 2: How Budgeting Works

Purpose:
Explain:
- Monthly budget
- Available amount
- Planned expenses
- Paid expenses
- Medical reimbursements

Visuals:
- Simple illustrations
- Example budget scenario

### Step 3: Create First Personal Profile

Inputs:
- Name
- Avatar
- Preferred currency

Rules:
- Name required
- Currency required

Output:
- UserProfile created

### Step 4: Configure Monthly Budget

Inputs:
- Monthly available amount
- Currency confirmation

Rules:
- Amount > 0

Output:
- Budget initialized

### Step 5: Security Setup

Options:
- Create PIN
- Enable biometrics
- Skip (optional)

Rules:
- PIN must meet security requirements

Output:
- Security configuration saved

### Step 6: App Overview

Explain:
- Dashboard
- Expenses
- Medical bills
- Analytics
- Shared spaces

### Step 7: Finish Setup

Actions:
- Complete onboarding
- Navigate to Dashboard

Output:
- Onboarding completion flag saved

## First-Time Setup Logic

After onboarding:

System automatically:
- Creates initial month context
- Calculates initial available amount
- Creates default categories
- Activates selected profile
- Loads dashboard

## Default Categories

Pre-created:

- Housing
- Utilities
- Food
- Transportation
- Health
- Insurance
- Subscriptions
- Entertainment
- Savings
- Miscellaneous

Users may modify these later.

## Dashboard Handoff

Upon completion:

Dashboard displays:
- Monthly budget
- Available amount
- Quick actions
- Empty-state guidance

Example:
"Add your first expense"
"Create your first medical bill"

## Returning User Flow

If onboarding previously completed:

Launch sequence:
- Authentication
- Profile load
- Dashboard

Onboarding is not shown again.

## UI Requirements

Screens:
1. Welcome
2. Budgeting Overview
3. Profile Creation
4. Budget Setup
5. Security Setup
6. App Overview
7. Completion Screen

Requirements:
- Modern animations
- Progress indicator
- Ability to go back
- Offline-first operation

## Navigation

Start:
- App launch

End:
- Dashboard Shell

Optional Access:
- Settings → Restart Onboarding

## Non-Functional Requirements

- Offline-first
- Fast onboarding (<3 minutes)
- Accessible design
- Responsive layouts
- Supports future onboarding steps

}}
[RAW INPUT SPECIFICATION END]
