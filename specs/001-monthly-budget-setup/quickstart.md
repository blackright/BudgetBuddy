# Quickstart & Validation Guide

This guide describes how to validate the Monthly Budget Setup feature end-to-end once implemented.

## Prerequisites
- Flutter SDK installed.
- iOS Simulator or Android Emulator running.

## Setup Commands
```bash
flutter pub get
flutter run
```

## Validation Scenarios

### Scenario 1: Initial Setup
1. Launch the app for the first time.
2. The "Welcome / Setup" screen should appear.
3. Attempt to enter an amount of `0`. The system must reject the input.
4. Enter `2500`, select `USD`, and choose the target month `October 2026`.
5. Tap **Confirm**.
6. **Expected Outcome**: The dashboard loads, displaying a starting available balance of `2500 USD` for October 2026.

### Scenario 2: Auto-fill & Monthly Reset
1. Once setup is complete, trigger a "New Month Setup" (e.g., from a budget selector or month-end prompt).
2. **Expected Outcome**: The form automatically pre-fills with `2500` and `USD`.
3. Change the target month to `November 2026` and the amount to `3000`.
4. Tap **Confirm**.
5. **Expected Outcome**: The dashboard now shows November 2026 with `3000 USD`. Historical October 2026 data remains unchanged.

### Scenario 3: Changing Primary Currency (Mid-Month)
1. Go to Settings.
2. Change the Primary Currency from `USD` to `EUR`.
3. **Expected Outcome**: A warning dialog appears stating: *"Historical dashboards will be recalculated into EUR."*
4. Confirm the prompt.
5. **Expected Outcome**: The app updates the UserProfile and immediately reflects EUR across all aggregated dashboard views.
