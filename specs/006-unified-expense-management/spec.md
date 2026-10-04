# Feature Specification: Unified Expense Management

## Purpose
Provide a cohesive, playful, and powerful system for managing the entire lifecycle of an expense. This unifies creation, editing, deletion, status flows, categorizations, and deep analytics. It forms the core engine of the user's daily financial tracking.

## Sub-Features Included
1. **Expense List + Smart Filters**: A highly responsive list with natural language search and gamified filter chips.
2. **Expense Details & Impact**: A deep-dive screen showing expense metadata and a visual "Impact Analysis" on the monthly budget.
3. **Gamified Category Management**: Create and manage categories with emoji avatars, colors, and optional soft-limits.
4. **Unified Status & Reimbursement Flow**: Seamless transitions between Planned ↔ Paid, and linking to Reimbursed amounts.

## Entities Involved
- **Expense** (Existing Isar Model)
- **Category** (New Isar Model)
- **Reimbursement** (Existing Isar Model)
- **MonthlyBudget** (Existing Isar Model)

## Core Rules & Logic
- **Status Flow**:
  - `planned`: Does not affect `trueAvailable` (only `safeToSpend`). Can transition to `paid` or `cancelled`.
  - `paid`: Deducts from `trueAvailable`. Triggers `paidAt` timestamp. 
  - `cancelled`: Nullifies the expense impact. Restores available amounts.
- **Reimbursement Flow**:
  - Controlled by the `isReimbursable` flag. 
  - Actual cash returned is handled by linking `Reimbursement` records to the `Expense`.
- **Category Links**: Every expense must link to a valid Category ID. If a category is deleted, its expenses fallback to a "General" category.

## UI / UX Requirements

### 1. Expense List Screen (The Hub)
- **Smart Search Bar**: Filters by title, or natural terms.
- **Filter Chips**: Horizontal scrollable chips for Guilt Levels (Essential, Splurge, Oops), Status (Planned, Paid), and Categories.
- **Swipe Actions**: Retain the existing swipe to edit/delete from feature 005.

### 2. Expense Details Screen (New)
- **Hero Section**: Massive emoji of the category, bold amount, and title.
- **Timeline**: Visual timeline of Created → Paid → Reimbursed.
- **Impact Card**: A mini-chart or visual indicator showing how much this expense ate into the monthly `safeToSpend`.
- **Action Bar**: Edit, Delete, Duplicate, Add Reimbursement.

### 3. Categories Management Screen (New)
- **List View**: Grid or list of categories showing their emoji and name.
- **Create/Edit Category**: 
  - Name input.
  - Emoji picker (acts as the icon).
  - Color picker.

## User Scenarios & Testing
- **Scenario 1:** User searches for "food" in the list screen and sees all food expenses regardless of currency.
- **Scenario 2:** User views an expense detail and sees its direct percentage impact on the monthly safeToSpend budget.
- **Scenario 3:** User creates a new category with a custom emoji and assigns an expense to it.
- **Scenario 4:** User toggles an expense from Planned to Paid, and observes the list and safeToSpend automatically updating.

## Functional Requirements
- **FR1:** The system shall provide a search bar on the list screen that filters expenses by matching title text.
- **FR2:** The system shall display filter chips for guilt levels, status, and categories to instantly filter the list view.
- **FR3:** The details screen shall render a visual timeline based on `createdAt`, `paidAt`, and reimbursement timestamps.
- **FR4:** The system shall compute and display the expense's percentage impact on the current month's `safeToSpend`.
- **FR5:** The system shall allow creating custom categories with an emoji, color, and name, persisted in Isar.
- **FR6:** The system shall properly adjust all budget totals when expenses transition between statuses (Planned, Paid, Cancelled).

## Success Criteria
- **User Satisfaction:** Users can find an expense in less than 3 seconds using search and filters.
- **Performance:** Filtering the list of up to 1,000 expenses takes less than 200 milliseconds.
- **Task Completion:** A user can assign an emoji-based category and view its impact in a single flow.

## Non-Functional Requirements
- **Offline-First**: 100% Isar backed.
- **Performance**: Instant filtering of lists using Riverpod derived state.
- **Animations**: Playful Hero transitions between the List and Details screen.
