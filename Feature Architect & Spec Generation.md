You are a friendly Product Architect and Software Designer. Your task is to look at my feature idea, check it against our existing project, make it better with smart ideas, and format it perfectly for a spec command (like `/speckit specify`). 

CRITICAL RULE: You must use incredibly simple language, short sentences, and beginner-friendly terms. Write as if you are explaining this to a child or a coding beginner. You are STRICTLY FORBIDDEN from running any commands or finishing the spec until I explicitly reply with "Approved" or "Proceed".

Follow these exact steps in your response:

### 📊 1. Codebase Check & Feasibility (In Simple Terms)
* **Can We Build It?:** Is this easy to build with what we currently have? Tell me in simple words if anything will clash.
* **Do We Already Have It?:** Did we already build parts of this somewhere else in our app? Let's make sure we don't build the same thing twice!

### 🚀 2. Cool New Ideas (Strictly 5 to 6 Ideas)
Propose exactly between 5 and 6 smart, innovative upgrades we should add to this feature. For every single idea, tell me:
* **What it is:** Give it a simple, catchy name.
* **Why it's highly recommended:** Explain the exact problem it solves using a simple real-world analogy.
* **How it improves the system:** What makes our app better because of it?

### 🏆 3. My Number One Recommendation
Pick just ONE idea from your list that is the absolute most important. Write a short, simple paragraph explaining exactly why this one matters the most for our app right now.

### 🎛️ 4. Choosing the Best Path (Comparison Table)
Show me a simple, easy-to-read table comparing 2 different ways we could code this feature. Use clear columns for the "Good Stuff" (Pros) and the "Bad Stuff" (Cons) for both options.

### 📄 5. Draft Spec Preview
Show me a clean, beautifully formatted preview of the updated feature specification (incorporating my original ideas plus the 5–6 new upgrades) so I can see exactly what will be sent to the command tool.

### 🛑 STOP! WAITING FOR YOUR GREEN LIGHT
I have stopped completely. Please look over these ideas, tell me which path from the table you like best, and reply with "Approved" when you are ready for me to run the final command!
--------------------------------------------------
[RAW INPUT SPECIFICATION START]
{{

    Feature Specification: Charts & Analytics (Unified)

## Purpose
Provide a complete analytics system for the application, including:
- Dashboard charts
- Advanced analytics charts
- Monthly summaries
- Category breakdowns
- Trend analysis
- Shared vs personal analytics
- Multi‑currency chart normalization
- Real‑time recalculation

This module transforms raw financial data into visual insights.

## Sub‑Features Included
1. Dashboard Charts
2. Advanced Analytics Charts

## Entities Involved
- Expense
- MedicalBill
- Reimbursement
- UserProfile
- SharedSpace
- CurrencyRate

## Core Chart Types

### 1. Monthly Spending Chart
- Shows total spending per day or per week
- Includes expenses + medical bills
- Supports personal and shared spaces
- Supports multi‑currency normalization

### 2. Category Breakdown Chart
- Pie chart or donut chart
- Shows spending distribution by category
- Supports filtering by:
  - personal profile
  - shared space
  - date range
  - currency

### 3. Planned vs Paid Chart
- Bar chart comparing:
  - planned expenses
  - paid expenses
- Helps users understand budgeting accuracy

### 4. Available Amount Trend Chart
- Line chart showing:
  - monthlyAvailableAmount changes
  - reimbursements
  - paid expenses
  - paid medical bills

### 5. Medical Bill Insurance Breakdown Chart
- Shows:
  - insuranceCoveredAmount
  - userPayableAmount
- Helps users understand medical cost distribution

### 6. Shared Space Contribution Chart
- Shows how much each member contributed to:
  - shared income
  - shared expenses
  - shared reimbursements

### 7. Shared vs Personal Comparison Chart
- Shows:
  - personal spending
  - shared spending
  - combined total
- Useful for couples or families

## Data Rules

### Multi‑Currency Normalization
All charts must convert values into:
- userProfile.primaryCurrency (personal)
- sharedSpace.primaryCurrency (shared)

Conversion uses Feature 8 (Multi‑Currency Engine).

### Shared Space Logic
Charts must:
- Aggregate shared expenses
- Aggregate shared medical bills
- Aggregate shared reimbursements
- Display shared availableAmount trend
- Display member contribution breakdown

### Personal Profile Logic
Charts must:
- Aggregate personal expenses
- Aggregate personal medical bills
- Aggregate personal reimbursements
- Display personal availableAmount trend

### Filtering Rules
All charts support:
- Date range
- Category
- Currency
- Status (planned, paid, reimbursed, cancelled)
- Profile vs shared space

## UI Requirements

### Dashboard Charts
Displayed on the Dashboard Shell:
- Monthly spending chart (mini)
- Category breakdown (mini)
- Planned vs paid (mini)
- Available amount summary
- Quick actions

### Analytics Screen
Full‑screen charts:
- Monthly spending (full)
- Category breakdown (full)
- Planned vs paid (full)
- Available amount trend (full)
- Medical insurance breakdown (full)
- Shared contribution chart (full)
- Shared vs personal comparison (full)

### Chart Interactions
- Tap to expand
- Tap legend to filter
- Swipe between charts
- Pinch to zoom (optional)
- Export chart data (optional future feature)

## Navigation
Accessible from:
- Dashboard tab
- Analytics tab
- Expense details (category breakdown)
- Medical bill details (insurance breakdown)

## Non‑Functional Requirements
- Must be fast and smooth
- Must work offline-first
- Must recalculate instantly when:
  - switching profiles
  - switching shared spaces
  - changing currency
  - adding/editing/deleting expenses
  - adding/editing/deleting medical bills
  - adding reimbursements
- Must support large datasets
- Must use local persistence (Drift)


YOU SHOULD NOT FORGET THE SHARED SPACE AND THE PERSON PROFILE SPACE. SO ANYWHERE WE NEED A CHAT OR ANALYTIS SHOULD BE THOUGHT ABOUT.

}}
[RAW INPUT SPECIFICATION END]
