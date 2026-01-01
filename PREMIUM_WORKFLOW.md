# Glimpse Premium Workflow Documentation

## Overview

Glimpse uses a two-tier subscription model to monetize the application while providing value to both free and premium users. The tier system is integrated throughout the app, from goal limits to feature access.

---

## Tier System

### Free Tier
- **Goal Limit**: 3 goals maximum
- **Price**: Free
- **Features**:
  - Basic goal tracking
  - Daily reflections
  - Streak tracking
  - Profile management
  - Basic notifications

### Premium Tier
- **Goal Limit**: 10 goals maximum
- **Price**: $4.99/month
- **Features**:
  - All Free features
  - 10 goals (vs 3)
  - Advanced Analytics (coming soon)
  - Custom Reminders (coming soon)
  - Custom Themes (coming soon)
  - Priority Support (coming soon)

---

## Database Schema

### Profiles Table Update

```sql
-- Add tier column to profiles table
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS tier TEXT DEFAULT 'free';

-- Add validation constraint
ALTER TABLE profiles
ADD CONSTRAINT valid_tier_values CHECK (tier IN ('free', 'premium'));

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_profiles_tier
ON profiles(tier);

-- Set default tier for existing users
UPDATE profiles
SET tier = 'free'
WHERE tier IS NULL;
```

**Column Details:**
- `tier`: TEXT field that stores either 'free' or 'premium'
- Default value: 'free' for all new users
- Constraint ensures only valid tier values

---

## User Flow

### 1. New User Journey

```
User Signs Up
    ↓
Profile Created (tier = 'free')
    ↓
Onboarding Flow
    ↓
Dashboard (can add up to 3 goals)
    ↓
[User reaches 3 goals]
    ↓
"Upgrade to Add More" button appears
```

### 2. Upgrade Flow

```
User clicks "Upgrade to Add More" or "Upgrade to Premium"
    ↓
PremiumUpgradeView presents as modal
    ↓
User reviews features and pricing
    ↓
User clicks "Upgrade to Premium"
    ↓
Loading state (isPurchasing = true)
    ↓
Update tier in Supabase: profiles.tier = 'premium'
    ↓
Reload user tier in app
    ↓
Success alert shown
    ↓
Modal dismisses
    ↓
User can now add up to 10 goals
```

### 3. Premium User Experience

```
Premium User logs in
    ↓
Tier loaded from Supabase (tier = 'premium')
    ↓
Dashboard shows "X/10" goal counter
    ↓
Can add up to 10 goals
    ↓
Settings shows "Premium Member" badge
```

---

## Implementation Details

### 1. User Tier Model (`UserTier.swift`)

```swift
enum UserTier: String, Codable {
    case free = "free"
    case premium = "premium"

    var maxGoals: Int {
        switch self {
        case .free: return 3
        case .premium: return 10
        }
    }
}
```

**Key Methods:**
- `maxGoals`: Returns goal limit for the tier
- `displayName`: Returns user-friendly tier name

### 2. Goal Storage Manager

**Properties:**
```swift
@Published var userTier: UserTier = .free
var maxGoals: Int { userTier.maxGoals }
var canAddGoal: Bool { goals.count < maxGoals }
```

**Methods:**

**Load User Tier:**
```swift
func loadUserTier() async {
    // Fetches tier from profiles table
    // Updates @Published userTier property
    // Defaults to .free on error
}
```

**Add Goal with Limit Check:**
```swift
func addGoal(_ goal: Goal) async throws {
    guard canAddGoal else {
        throw NSError(
            domain: "GoalStorageManager",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "You've reached the maximum number of goals for your plan (\(maxGoals) goals)."]
        )
    }
    // Insert to Supabase
    // Update local state
}
```

### 3. Premium Upgrade View

**State Management:**
```swift
@State private var isPurchasing = false
@State private var showSuccess = false
@State private var showError = false
```

**Upgrade Function:**
```swift
private func upgradeToPremium() {
    // 1. Get user ID from Supabase auth
    // 2. Update profiles.tier = 'premium'
    // 3. Reload tier in GoalStorageManager
    // 4. Show success message
    // 5. Dismiss modal
}
```

---

## UI/UX Integration Points

### 1. Dashboard View

**Goal Counter:**
- Shows current/max goals: "3/3" (free) or "5/10" (premium)
- Dynamic based on `storageManager.maxGoals`

**Add Goal Button:**
```swift
// Free tier at limit
"Upgrade to Add More" with crown icon
    ↓ taps
Opens PremiumUpgradeView

// Free tier under limit OR Premium tier
"Add Another Goal" with plus icon
    ↓ taps
Opens AddGoalView
```

**Empty State:**
- Always shows "Add Your First Goal" button
- Even at limit, clicking checks tier and shows appropriate view

### 2. Settings View

**Free Users:**
```
Premium Section
├── Crown icon with gradient
├── "Upgrade to Premium"
├── "Unlock 10 goals and more"
└── Chevron (tappable)
```

**Premium Users:**
```
Premium Section
├── Crown icon with gradient
├── "Premium Member"
└── "Thank you for your support"
```

### 3. Premium Upgrade Screen

**Layout:**
```
Header (Close button)
    ↓
Crown Icon (gradient circle)
    ↓
Title: "Upgrade to Premium"
Subtitle: "Unlock your full potential"
    ↓
Feature List (5 items):
- 10 Goals
- Advanced Analytics
- Custom Reminders
- Custom Themes
- Priority Support
    ↓
Pricing: $4.99/month
    ↓
Upgrade Button (gradient)
    ↓
Terms footnote
```

---

## Code Structure

### File Organization

```
glimpse/
├── Models/
│   ├── UserTier.swift                    # Tier enum definition
│   └── Goal.swift                        # Goal model
├── Services/
│   └── GoalStorageManager.swift          # Tier management & goal CRUD
├── Views/
│   ├── Dashboard/
│   │   └── DashboardView.swift           # Shows tier-based UI
│   ├── Goals/
│   │   ├── AddGoalView.swift            # Add new goal
│   │   └── EditGoalView.swift           # Edit existing goal
│   ├── Premium/
│   │   └── PremiumUpgradeView.swift      # Upgrade screen
│   └── Settings/
│       └── SettingsView.swift            # Premium section
```

### Key Components

**1. GoalStorageManager.swift**
- Manages user tier state
- Enforces goal limits
- Loads/saves tier from Supabase

**2. PremiumUpgradeView.swift**
- Premium sales page
- Handles upgrade transaction
- Updates Supabase tier

**3. DashboardView.swift**
- Shows tier-aware UI
- Routes to upgrade screen when at limit

**4. SettingsView.swift**
- Displays tier status
- Provides upgrade entry point

---

## State Flow

### App Launch

```
glimpseApp.swift
    ↓
DashboardView appears
    ↓
.task { await storageManager.loadUserTier() }
    ↓
Fetches tier from Supabase
    ↓
Updates @Published userTier
    ↓
UI reactively updates based on tier
```

### Adding a Goal

```
User taps "Add Another Goal"
    ↓
Check: storageManager.canAddGoal
    ↓
If true: Show AddGoalView
If false: Show PremiumUpgradeView
    ↓
[In AddGoalView]
User completes form → taps "Add"
    ↓
storageManager.addGoal(goal)
    ↓
Check: canAddGoal (enforced again server-side style)
    ↓
If at limit: throw error
If under limit: Insert to Supabase
    ↓
Update local @Published goals array
    ↓
UI updates reactively
```

### Upgrading to Premium

```
User taps "Upgrade to Premium"
    ↓
PremiumUpgradeView presents
    ↓
User reviews features
    ↓
User taps "Upgrade to Premium" button
    ↓
isPurchasing = true (show loading)
    ↓
Supabase UPDATE: profiles.tier = 'premium'
    ↓
storageManager.loadUserTier()
    ↓
userTier updates to .premium
    ↓
isPurchasing = false
showSuccess = true
    ↓
Success alert shows
    ↓
User taps "OK"
    ↓
Modal dismisses
    ↓
Dashboard now shows "X/10" and allows more goals
```

---

## Error Handling

### Goal Limit Exceeded

**Scenario:** User tries to add goal when at limit

```swift
do {
    try await storageManager.addGoal(newGoal)
} catch {
    errorMessage = error.localizedDescription
    // Shows: "You've reached the maximum number of goals for your plan (3 goals)."
    showError = true
}
```

### Upgrade Failure

**Scenario:** Network error during upgrade

```swift
catch {
    isPurchasing = false
    errorMessage = "Failed to upgrade: \(error.localizedDescription)"
    showError = true
}
```

### Tier Loading Failure

**Scenario:** Can't load tier from Supabase

```swift
catch {
    // Defaults to free tier for safety
    userTier = .free
}
```

---

## Design Patterns

### 1. Reactive State Management
- Uses `@Published` properties in ObservableObject
- UI automatically updates when tier changes
- Single source of truth: `GoalStorageManager.shared`

### 2. Defensive Programming
- Always validates tier before allowing operations
- Client-side validation + ready for server-side enforcement
- Graceful degradation (defaults to free tier on error)

### 3. User-Friendly Constraints
- Don't just block users - offer upgrade path
- Replace "disabled" with "upgrade to unlock"
- Clear messaging about limits

### 4. Optimistic UI Updates
- Local state updates immediately
- Supabase sync happens async
- Errors trigger state rollback

---

## Testing Checklist

### Free User Testing

- [ ] New user defaults to free tier
- [ ] Can add up to 3 goals
- [ ] "3/3" shows when at limit
- [ ] Add button becomes "Upgrade to Add More" at limit
- [ ] Clicking upgrade button shows PremiumUpgradeView
- [ ] Settings shows "Upgrade to Premium" section

### Premium User Testing

- [ ] Premium user loads with tier = 'premium'
- [ ] Can add up to 10 goals
- [ ] "X/10" shows correctly
- [ ] Settings shows "Premium Member" badge
- [ ] Can still add goals after upgrading

### Upgrade Flow Testing

- [ ] Upgrade screen displays all features correctly
- [ ] "Upgrade to Premium" button works
- [ ] Loading state shows during upgrade
- [ ] Success message appears on completion
- [ ] Tier updates immediately after upgrade
- [ ] Goal limit increases to 10
- [ ] Settings updates to show premium badge

### Edge Cases

- [ ] No internet during tier load → defaults to free
- [ ] No internet during upgrade → error message shown
- [ ] User at 3 goals upgrades → can immediately add more
- [ ] Multiple rapid upgrade clicks → prevented by loading state

---

## Future Enhancements

### 1. Payment Integration
**Current:** Direct tier update (testing/demo)
**Future:** Integrate with:
- Apple StoreKit for iOS in-app purchases
- RevenueCat for cross-platform subscription management
- Webhook handlers for subscription events

### 2. Subscription Management
- View subscription status
- Cancellation flow
- Renewal reminders
- Payment history

### 3. Feature Flags
```swift
enum PremiumFeature {
    case advancedAnalytics
    case customThemes
    case multipleReminders
    case prioritySupport

    var isAvailable: Bool {
        // Check tier and feature rollout
    }
}
```

### 4. Analytics
- Track upgrade conversion rate
- Monitor feature usage by tier
- A/B test pricing and messaging

### 5. Promotional Offers
- Free trial period (7-14 days)
- Discount codes
- Limited-time pricing
- Referral bonuses

---

## Security Considerations

### 1. Server-Side Validation
**Current:** Client-side tier checks
**Future:** Add server-side Supabase RLS policies:

```sql
-- Ensure users can only have goals within their tier limit
CREATE POLICY "Users cannot exceed tier goal limit"
ON goals
FOR INSERT
WITH CHECK (
    (
        SELECT COUNT(*)
        FROM goals
        WHERE user_id = auth.uid()
    ) < (
        SELECT CASE
            WHEN tier = 'premium' THEN 10
            ELSE 3
        END
        FROM profiles
        WHERE id = auth.uid()
    )
);
```

### 2. Tier Verification
- Always load tier from Supabase, never trust client
- Re-verify on critical operations
- Log tier changes for audit trail

### 3. Payment Verification
When integrating real payments:
- Verify receipt with Apple/Google
- Update tier only after payment confirmed
- Handle failed payments (grace period, then downgrade)

---

## Troubleshooting

### Issue: Tier not updating after upgrade

**Solution:**
1. Check network connection
2. Verify Supabase UPDATE query succeeded
3. Check `loadUserTier()` is called after update
4. Verify `@Published` property triggers UI update

### Issue: User can add more goals than limit

**Solution:**
1. Check tier is loaded correctly
2. Verify `canAddGoal` computation
3. Check for race conditions in async operations
4. Add server-side validation

### Issue: Premium section not showing in Settings

**Solution:**
1. Verify tier is loaded: `print(storageManager.userTier)`
2. Check conditional rendering logic
3. Ensure `loadUserTier()` completes before view renders

---

## Metrics to Track

### Conversion Metrics
- Free users who view upgrade screen
- Upgrade button click rate
- Successful upgrade rate
- Time from signup to upgrade

### Engagement Metrics
- Average goals per free user
- Average goals per premium user
- How quickly free users hit 3-goal limit
- Feature usage by tier

### Revenue Metrics
- Monthly Recurring Revenue (MRR)
- Churn rate by tier
- Average Revenue Per User (ARPU)
- Lifetime Value (LTV) by cohort

---

## Summary

The Glimpse premium workflow is designed to be:
1. **Simple**: Clear free vs premium distinction
2. **Valuable**: Premium unlocks meaningful features
3. **Non-intrusive**: Upgrade prompts appear naturally
4. **Scalable**: Easy to add more tiers or features
5. **Maintainable**: Clean code structure with single source of truth

The system uses SwiftUI's reactive patterns and Supabase's flexible database to create a seamless upgrade experience that respects free users while incentivizing premium subscriptions.
