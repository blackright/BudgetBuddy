# Quickstart & Validation Guide: Dashboard Shell

## Prerequisites
- The app must be compiled and running.
- Budget Setup (Feature 1) must be complete, or bypassed for development, so the app lands on the main shell.

## Validation Scenarios

### 1. Tab Navigation Validation
1. Launch the app.
2. Verify you land on the **Dashboard** tab.
3. Tap the **Expenses** icon in the bottom bar. Verify the screen content changes to the Expenses placeholder.
4. Tap the remaining tabs (Medical, Analytics, Settings) and verify immediate switching without the bottom bar disappearing.

### 2. Dashboard Metrics Integration
1. On the **Dashboard** tab, look at the Hero section.
2. Verify it displays values for "Available to Spend" (`trueAvailable`) and "Safe to Spend".
3. To test reactiveness, if you manually add a test expense or update the budget configuration, verify that the Dashboard values update immediately.

### 3. Deep Linking & Fallback
1. Restart the app using a specific deep link (e.g., `flutter run -a "--route=/analytics"` or equivalent platform intent).
2. Verify the app opens directly to the Analytics tab, and the bottom bar correctly highlights the Analytics icon.
3. Attempt to navigate to an unknown route. Verify the app falls back to the Dashboard.
