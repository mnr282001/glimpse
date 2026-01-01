# Supabase Integration Changelog

## ✨ NEW FEATURE (2025-12-31) - Settings Page with Logout

**New Feature**: Added Settings page accessible from Dashboard with Account, Notifications sections, and Logout functionality.

**Features Implemented**:

1. **Settings Page** (`SettingsView.swift`):
   - Accessible via gear icon in Dashboard header
   - Organized into sections: Account and Notifications
   - Clean, iOS-style settings interface
   - Dark/light mode support

2. **Account Section**:
   - Profile settings (placeholder)
   - Email & Password management (placeholder)
   - Prepared for future implementation

3. **Notifications Section**:
   - Notification settings (placeholder)
   - Prepared for future customization

4. **Logout Functionality**:
   - Red logout button with confirmation dialog
   - Clears Supabase session
   - Clears local data (goals, onboarding status)
   - Redirects to ContentView (welcome screen)
   - Full screen transition for clean UX

**User Flow**:
1. Tap settings gear icon in Dashboard
2. Navigate to Settings page
3. Browse Account/Notifications sections (placeholders)
4. Tap "Log Out" button
5. Confirm logout in alert dialog
6. Session cleared, redirected to welcome screen
7. Can sign in/up again

**Technical Implementation**:

**SettingsView.swift**:
```swift
Button("Log Out", role: .destructive) {
    logout()
}

private func logout() {
    try await SupabaseManager.shared.signOut()
    // Clear local data
    storageManager.goals = []
    UserDefaults.standard.set(false, forKey: "glimpse.onboarding.complete")
    // Show welcome screen
    showWelcomeScreen = true
}
```

**DashboardView.swift**:
```swift
Button(action: { navigateToSettings = true }) {
    Image(systemName: "gearshape.fill")
}
.navigationDestination(isPresented: $navigateToSettings) {
    SettingsView()
}
```

**Files Created**: 3
- `/glimpse/Views/Settings/SettingsView.swift` - Main settings page
- `/glimpse/Views/Settings/AccountSettingsView.swift` - Account settings placeholder
- `/glimpse/Views/Settings/NotificationSettingsView.swift` - Notification settings placeholder

**Files Modified**: 1
- `/glimpse/Views/Dashboard/DashboardView.swift` - Added settings navigation

**Lines Added**: ~330

**Future Enhancements**:
- Implement actual profile editing
- Add email/password change functionality
- Enable notification time customization
- Add app preferences (theme, etc.)

---

## ⚠️ UPDATE (2025-12-31) - Fix Loading Screen Not Respecting Dark Mode

**Bug Fix**: Loading screen now respects system color scheme (light/dark mode).

**Problem**:
- Loading screen had hardcoded light mode colors
- Users in dark mode saw a flash of light mode before app switched to dark mode
- Jarring visual experience on app launch

**Root Cause**:
- Loading screen colors were hardcoded in `glimpseApp.swift`:
  - Background: Light beige `Color(red: 1.0, green: 0.97, blue: 0.94)`
  - Logo: Light terracotta `Color(red: 0.83, green: 0.58, blue: 0.49)`
  - Text: Dark gray `Color(red: 0.17, green: 0.17, blue: 0.17)`
- No `@Environment(\.colorScheme)` check

**Solution**:
- Created `LoadingView` component that respects color scheme
- Uses same dark/light mode colors as rest of app:
  - **Dark mode**: Dark background, blue accent
  - **Light mode**: Light background, terracotta accent
- Replaced hardcoded ZStack with `LoadingView()` component

**Code Change**:
```swift
// NEW: LoadingView component
struct LoadingView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            (colorScheme == .dark ?
                Color(red: 0.11, green: 0.12, blue: 0.15) :
                Color(red: 1.0, green: 0.97, blue: 0.94))
            // ... logo, text with color scheme checks
        }
    }
}

// BEFORE
if isCheckingSession {
    ZStack { /* hardcoded light colors */ }
}

// AFTER
if isCheckingSession {
    LoadingView()  // Respects system color scheme
}
```

**Files Modified**: 1
- `/glimpse/glimpseApp.swift` - Created LoadingView, replaced hardcoded loading screen

**Lines Added**: ~35
**Lines Removed**: ~22

---

## ⚠️ UPDATE (2025-12-31) - Fix Dashboard Flickering on App Start

**Bug Fix**: Dashboard now shows loading indicator instead of flickering between "no goals" and goals list.

**Problem**:
- On app start, Dashboard appears with empty goals array
- Shows "No goals yet" message briefly
- Then `loadGoals()` completes and goals pop in
- Visible flicker between empty state and populated state

**Root Cause**:
- DashboardView checked `goals.isEmpty` without considering loading state
- Goals array is empty until Supabase query completes
- No way to distinguish "loading" from "actually empty"

**Solution**:
1. Added `@Published var isLoadingGoals` to GoalStorageManager
2. Set to `true` when loading starts, `false` when complete
3. Updated DashboardView to show three states:
   - **Loading** (`isLoadingGoals == true`) → Shows ProgressView
   - **Empty** (`goals.isEmpty && !isLoadingGoals`) → Shows "No goals yet"
   - **Has goals** → Shows goals list

**Code Changes**:

**GoalStorageManager.swift**:
```swift
@Published var isLoadingGoals: Bool = false

func loadGoals() {
    Task {
        await MainActor.run { isLoadingGoals = true }
        // ... fetch from Supabase
        await MainActor.run {
            self.goals = loadedGoals
            isLoadingGoals = false
        }
    }
}
```

**DashboardView.swift**:
```swift
if storageManager.isLoadingGoals {
    ProgressView()  // Show loading
} else if storageManager.goals.isEmpty {
    // "No goals yet" message
} else {
    // Goals list
}
```

**User Experience**:
- **Before**: Flicker → "No goals yet" → Goals appear
- **After**: Smooth → Loading spinner → Goals appear ✨

**Files Modified**: 2
- `/glimpse/Services/GoalStorageManager.swift` - Added isLoadingGoals state
- `/glimpse/Views/Dashboard/DashboardView.swift` - Added loading state UI

**Lines Added**: ~15
**Lines Modified**: ~5

---

## ⚠️ UPDATE (2025-12-31) - Fix Goals Not Loading After Completing Onboarding

**Bug Fix**: Goals now properly load when navigating to Dashboard after completing onboarding.

**Problem**:
- User completes onboarding (adds goals in GoalsSetupView)
- Navigates to DashboardView
- Dashboard shows empty - no goals displayed
- Reloading app shows goals correctly

**Root Cause**:
- GoalsSetupView saves goals to Supabase
- Navigates to DashboardView via navigationDestination
- DashboardView didn't have `.onAppear` to load goals
- `storageManager.loadGoals()` was never called

**Solution**:
- Added `.onAppear` to DashboardView in GoalsSetupView
- Calls `storageManager.loadGoals()` when Dashboard appears
- Goals are now fetched from Supabase immediately after onboarding

**Code Change**:
```swift
// GoalsSetupView.swift
.navigationDestination(isPresented: $navigateToDashboard) {
    DashboardView()
        .onAppear {
            // Load goals when navigating from onboarding
            storageManager.loadGoals()
        }
}
```

**Note**: SignInView already had this logic (loads goals before navigating), so this only affected the onboarding completion flow.

**Files Modified**: 1
- `/glimpse/Views/Onboarding/GoalsSetupView.swift` - Added onAppear to load goals

---

## ⚠️ UPDATE (2025-12-31) - Always Start from Welcome Screen for Incomplete Onboarding

**UX Improvement**: App now always shows welcome screen when onboarding is incomplete, then resumes from correct step after sign in/up.

**Previous Behavior**:
- User exits app mid-onboarding (e.g., after PersonalizationView)
- Reopens app → Directly shows NotificationTimeView
- Confusing - user doesn't understand why they're mid-onboarding

**New Behavior**:
- User exits app mid-onboarding
- Reopens app → Shows ContentView (welcome screen)
- User signs in or signs up
- App checks Supabase to determine progress
- Navigates to the exact step they left off at
- Clear user flow: Welcome → Auth → Resume onboarding

**Implementation**:

1. **glimpseApp.swift**:
   - Always shows ContentView for any incomplete onboarding state
   - Only shows Dashboard when fully completed

```swift
switch onboardingState {
case .notStarted, .needsPersonalization, .needsNotifications, .needsGoals:
    ContentView()  // Always start here
case .completed:
    DashboardView()
}
```

2. **AuthView.swift** (Sign Up):
   - Added `checkOnboardingStatus()` function
   - After successful sign up, checks Supabase for user's progress
   - Navigates to PersonalizationView, NotificationTimeView, or GoalsSetupView as needed
   - Resumes onboarding from correct step

3. **SignInView.swift** (Sign In):
   - Already had onboarding check logic
   - Now benefits from always starting at ContentView

**User Flow Examples**:

**Example 1: New User**
1. Open app → ContentView
2. Sign up → PersonalizationView
3. Complete → NotificationTimeView
4. Complete → GoalsSetupView
5. Complete → DashboardView

**Example 2: Returning User (Incomplete Onboarding)**
1. User signed up, completed PersonalizationView, exited app
2. Reopen app → ContentView (not NotificationTimeView!)
3. Sign in → Checks Supabase → Has first_name but no notifications
4. Navigate to NotificationTimeView ✅
5. Continue from where they left off

**Example 3: Returning User (Complete Onboarding)**
1. User completed everything previously
2. Reopen app → DashboardView directly ✅
3. No need to sign in again (session persists)

**Files Modified**: 2
- `/glimpse/glimpseApp.swift` - Always show ContentView for incomplete onboarding
- `/glimpse/Views/Onboarding/AuthView.swift` - Added onboarding check after sign up

**Lines Added**: ~120
**Lines Modified**: ~10

---

## ⚠️ CRITICAL - Missing INSERT Policy on Profiles Table

**Issue**: Users get "new row violates row-level security policy for table 'profiles'" error when submitting PersonalizationView.

**Cause**: The `profiles` table was missing an INSERT policy. Only SELECT and UPDATE policies existed.

**Fix Required**: Add this SQL policy in Supabase dashboard → SQL Editor:

```sql
CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);
```

**Why This Happened**:
- PersonalizationView uses `upsert()` which tries to INSERT if record doesn't exist
- Without INSERT policy, RLS blocks the operation
- The database schema documentation has been updated to include this policy

**Updated Database Schema**: See "Database Schema Required" section below for complete profiles table setup with all three policies (SELECT, INSERT, UPDATE).

---

## ⚠️ UPDATE (2025-12-31) - Fix Stale Session Handling

**Critical Fix**: App now properly handles deleted/invalid users by clearing session and showing welcome screen.

**Problem**:
- When user was deleted from Supabase but had a stale local session token
- App would check session (token still exists locally)
- Try to query user data from database (user doesn't exist)
- Error would be caught and app would incorrectly show PersonalizationView
- User would be stuck - can't sign up (has session) or continue (no data)

**Root Cause**:
- `checkOnboardingProgress()` catch block returned `.needsPersonalization` on any error
- This included auth errors, deleted users, invalid sessions, etc.
- No distinction between "incomplete onboarding" vs "invalid session"

**Solution**:
- Changed `checkOnboardingProgress()` to return `OnboardingState?` (optional)
- Returns `nil` when there's an auth/database error (invalid session)
- Added explicit check: if profile query returns empty array → user doesn't exist → return `nil`
- `checkSession()` now detects nil state and:
  1. Signs out the user (clears stale session)
  2. Sets state to `.notStarted` (shows ContentView welcome screen)
  3. User can now create a new account

**Code Changes**:
```swift
// checkOnboardingProgress() now returns optional
private func checkOnboardingProgress() async -> OnboardingState? {
    do {
        let profileResponse = try await client.database.from("profiles")...

        // If no profile exists, user was deleted - session is invalid
        guard !profileResponse.isEmpty else {
            return nil
        }

        // Profile exists - check if first_name is populated
        guard let profile = profileResponse.first,
              let firstName = profile.first_name,
              !firstName.isEmpty else {
            return .needsPersonalization  // User exists but incomplete
        }

        // ... check notifications, goals
    } catch {
        // Return nil to indicate invalid session
        return nil
    }
}

// checkSession() handles nil state
let state = await checkOnboardingProgress()
if state == nil {
    try? await SupabaseManager.shared.signOut()
    onboardingState = .notStarted  // Show welcome screen
    return
}
```

**User Flow After Fix**:
1. User deleted from Supabase but has stale token
2. App checks session → token exists (stale)
3. App tries to check onboarding → database error (user doesn't exist)
4. Returns nil → App signs out
5. Shows ContentView (welcome screen) ✅
6. User can create new account

**Files Modified**: 1
- `/glimpse/glimpseApp.swift` - Fixed stale session handling

**Lines Modified**: ~15

---

## ⚠️ UPDATE (2025-12-31) - Fix Back Button Not Working from GoalsSetupView

**Bug Fix**: Fixed back button not working when navigating from NotificationTimeView to GoalsSetupView.

**Problem**:
- Clicking back button in GoalsSetupView did nothing
- No navigation was occurring when Continue was tapped in NotificationTimeView

**Root Cause**:
- NotificationTimeView was missing the hidden NavigationLink
- Had `.navigationDestination` modifier but no actual NavigationLink to trigger navigation
- Without proper NavigationLink, the navigation stack wasn't being built correctly

**Solution**:
- Added hidden NavigationLink in NotificationTimeView
- Removed redundant `.navigationDestination` modifier
- Now properly pushes GoalsSetupView onto navigation stack
- Back button (dismiss) now works correctly

**Code Change** (NotificationTimeView.swift):
```swift
// Added before Continue button
NavigationLink(destination: GoalsSetupView(), isActive: $navigateToGoals) {
    EmptyView()
}
.hidden()

// Removed
.navigationDestination(isPresented: $navigateToGoals) {
    GoalsSetupView()
}
```

**Files Modified**: 1
- `/glimpse/Views/Onboarding/NotificationTimeView.swift` - Added hidden NavigationLink

---

## ⚠️ UPDATE (2025-12-31) - Fix Black Screen Navigation Issue

**Critical Fix**: Fixed black screen error caused by overly complex navigation logic.

**Problem**:
- App was showing black screen with warning sign on launch
- Back button would loop back to the same error screen
- Issue was caused by attempting to build complex navigation paths programmatically

**Root Cause**:
- Previous navigation implementation tried to build an entire navigation stack path
- Started with ContentView (welcome screen) then pushed multiple onboarding views on top
- This created invalid navigation states causing SwiftUI errors

**Solution**:
- Simplified to directly show the appropriate view based on onboarding state
- Removed complex navigation path building logic
- Each view is now the root of the NavigationStack when app launches
- Forward navigation still works via NavigationLinks in each view

**Code Changes**:
```swift
// BEFORE (complex navigation path)
NavigationStack(path: $navigationPath) {
    ContentView()
        .navigationDestination(for: OnboardingDestination.self) { ... }
        .onAppear { buildNavigationPath() }
}

// AFTER (simple state-based view)
NavigationStack {
    switch onboardingState {
    case .notStarted: ContentView()
    case .needsPersonalization: PersonalizationView()
    case .needsNotifications: NotificationTimeView()
    case .needsGoals: GoalsSetupView()
    case .completed: DashboardView()
    }
}
```

**Note**: Back button functionality from mid-onboarding views will be addressed in future update.

**Files Modified**: 1
- `/glimpse/glimpseApp.swift` - Simplified navigation logic, removed navigation path building

**Lines Removed**: ~50 (complex navigation code)
**Lines Added**: ~15 (simple switch-based navigation)

---

## ⚠️ UPDATE (2025-12-31) - Fix Navigation Stack & Upsert Issues

**Bug Fixes**: Fixed navigation back button and database upsert conflicts throughout onboarding.

**Problems Fixed**:

1. **Navigation Stack Issue**:
   - Users couldn't navigate back from NotificationTimeView to PersonalizationView
   - When app launched directly into mid-onboarding (e.g., NotificationTimeView), back button had nowhere to go
   - Navigation history wasn't being built properly

2. **PersonalizationView Upsert**:
   - Using `.update()` instead of `.upsert()` could cause issues if profile doesn't exist
   - Changed to upsert for consistency with other views

3. **NotificationTimeView Upsert**:
   - Navigating back and clicking Continue again caused: `duplicate key value violates unique constraint "notification_settings_user_id_key"`
   - Upsert wasn't specifying conflict resolution column

**Solutions Implemented**:

1. **Proper Navigation Stack** (`glimpseApp.swift`):
   - Added `OnboardingDestination` enum for type-safe navigation
   - Build proper navigation path based on onboarding state
   - When resuming at NotificationTimeView, stack includes PersonalizationView so back button works
   - Users can now navigate back through all completed onboarding steps

```swift
// Navigation path is built based on state
case .needsNotifications:
    path = [.personalization, .notifications]  // Can go back to personalization
case .needsGoals:
    path = [.personalization, .notifications, .goals]  // Can go back through all
```

2. **PersonalizationView** - Changed to upsert:
```swift
// BEFORE
.update(["first_name": firstName])
.eq("id", value: userId.uuidString)

// AFTER
.upsert(profileData, onConflict: "id")
```

3. **NotificationTimeView** - Added conflict resolution:
```swift
// BEFORE
.upsert(settings)

// AFTER
.upsert(settings, onConflict: "user_id")
```

**Files Modified**: 3
- `/glimpse/glimpseApp.swift` - Fixed navigation stack building
- `/glimpse/Views/Onboarding/PersonalizationView.swift` - Changed update to upsert
- `/glimpse/Views/Onboarding/NotificationTimeView.swift` - Fixed upsert conflict resolution

**Lines Added**: ~35
**Lines Modified**: ~40

---

## ⚠️ UPDATE (2025-12-31) - Fix Incomplete Onboarding Edge Case

**Critical Fix**: App now properly handles users who create an account but don't complete onboarding.

**Problem Fixed**:
- If user signed up but closed the app before completing PersonalizationView, NotificationTimeView, or GoalsSetupView
- On app reopen, they would be sent to the welcome screen (ContentView)
- Confusing user experience - they already have an account but can't easily continue

**Solution Implemented**:
- Added `OnboardingState` enum to track where user is in onboarding flow
- App checks Supabase on launch to determine exact onboarding step
- Resumes onboarding from the first incomplete step
- No more confusion about "already have an account" errors

**Onboarding States**:
```swift
enum OnboardingState {
    case notStarted           // No account yet → ContentView (Welcome)
    case needsPersonalization // Has account → PersonalizationView
    case needsNotifications   // Has name → NotificationTimeView
    case needsGoals          // Has notifications → GoalsSetupView
    case completed           // Has everything → DashboardView
}
```

**Detection Logic** (checks Supabase in order):
1. Check if `profiles.first_name` exists → If no: PersonalizationView
2. Check if `notification_settings` exists → If no: NotificationTimeView
3. Check if `goals` exists → If no: GoalsSetupView
4. If all exist → DashboardView

**User Scenarios**:
- **Scenario 1**: User signs up, closes app immediately → Reopens to PersonalizationView
- **Scenario 2**: User completes name, closes app → Reopens to NotificationTimeView
- **Scenario 3**: User sets notifications, closes app → Reopens to GoalsSetupView
- **Scenario 4**: User completes everything → Always opens to DashboardView

**Files Modified**: 1
- `/glimpse/glimpseApp.swift` - Added onboarding state tracking and resume logic

**Lines Added**: ~70
**Lines Modified**: ~25

---

## ⚠️ UPDATE (2025-12-31) - Add Notification Permission Request

**Feature Added**: NotificationTimeView now requests iOS notification permissions when user enables reminders.

**Implementation**:
- Added `UserNotifications` framework import
- Request notification authorization when Continue is tapped with reminders enabled
- Request permissions for: alert, sound, and badge
- Shows informative error if permission is denied (but still continues to next screen)
- User can enable notifications later in iOS Settings if they decline initially

**Code Changes**:
```swift
// NEW function in NotificationTimeView.swift
private func requestNotificationPermission() async -> Bool {
    let center = UNUserNotificationCenter.current()
    let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
    return granted
}

private func handleContinue() async {
    // Request permission if reminders enabled
    // Save settings to Supabase
    // Navigate to goals setup
}
```

**User Flow**:
1. User enables "Enable daily reminders" toggle
2. User taps "Continue"
3. iOS system permission dialog appears
4. User grants or denies permission
5. Settings saved to Supabase regardless of choice
6. Navigation to GoalsSetupView

**Files Modified**: 1
- `/glimpse/Views/Onboarding/NotificationTimeView.swift` - Added permission request

**Lines Modified**: ~30
**Lines Added**: ~35

---

## ⚠️ UPDATE (2025-12-31) - Fix Onboarding Check to Use Supabase

**Critical Fix**: Sign in now checks Supabase database instead of UserDefaults to determine onboarding completion status.

**Problem Fixed**:
- Previously, SignInView checked local UserDefaults flag (`isOnboardingComplete`) to determine if user should go to Dashboard or continue onboarding
- This was unreliable because the flag might not be synced with actual data in Supabase
- Users who completed onboarding on another device would be sent back to PersonalizationView

**Solution Implemented**:
- Added `checkOnboardingStatus()` function that queries Supabase database
- Checks if user has profile with `first_name` populated
- Checks if user has at least one goal in the `goals` table
- Only navigates to Dashboard if both conditions are met
- Otherwise continues with onboarding from PersonalizationView

**Code Changes**:
```swift
// NEW function in SignInView.swift
private func checkOnboardingStatus() async -> Bool {
    // Query profiles table for first_name
    // Query goals table for user's goals
    // Return true only if both exist
}
```

**Navigation Logic**:
- ✅ **Has profile + goals** → Dashboard (loads goals from Supabase)
- ⏭️ **Missing profile or goals** → PersonalizationView (complete onboarding)

**Files Modified**: 1
- `/glimpse/Views/Onboarding/SignInView.swift` - Added Supabase onboarding check

**Lines Added**: ~45

---

## ⚠️ UPDATE (2025-12-31) - Separate Sign In/Sign Up Views

**Major Authentication Flow Changes**:
- Created separate `SignInView.swift` for existing users
- Updated `AuthView.swift` to be Sign Up only (no longer tries to sign in first)
- Added navigation link "Already have an account? Sign In" on both screens
- Sign In now properly only signs in (doesn't create new users)
- Sign Up now properly only signs up (doesn't try to sign in first)
- **Smart navigation**: Existing users with complete onboarding go directly to Dashboard

**Files Created**: 1 additional
- `/glimpse/Views/Onboarding/SignInView.swift` - Dedicated sign in page

**Files Modified**: 1 additional
- `AuthView.swift` - Changed to Sign Up only with navigation to Sign In

---

## Summary

This document tracks all changes made to integrate Supabase authentication and database functionality into the Glimpse app, replacing placeholder authentication and local UserDefaults storage with a full backend solution.

### Integration Overview
- **Date Completed**: 2025-12-31 (Updated: 2025-12-31)
- **Supabase Version**: supabase-swift 2.0.0+
- **Authentication Method**: Email/Password (Apple and Google auth marked for future implementation)
- **Database Tables Used**: `profiles`, `notification_settings`, `goals`
- **Files Created**: 3 (SupabaseConfig, SupabaseManager, SignInView)
- **Files Modified**: 6 (AuthView, PersonalizationView, NotificationTimeView, GoalsSetupView, GoalStorageManager, glimpseApp)
- **Total Lines Added**: ~400 lines
- **Total Lines Modified**: ~180 lines

---

## New Dependencies Added

### Supabase Swift Package
- **Repository**: `https://github.com/supabase/supabase-swift`
- **Version**: 2.0.0+
- **Products Added**:
  - ✅ Supabase (Core client)
  - ✅ Auth (Authentication)
  - ✅ PostgREST (Database queries)
  - ⏸️ Realtime (Optional - for future features)

### Installation Method
Manual installation via Xcode:
1. File → Add Package Dependencies
2. Enter URL: `https://github.com/supabase/supabase-swift`
3. Select products: Supabase, Auth, PostgREST

---

## New Files Created

### 1. `/glimpse/Config/SupabaseConfig.swift`

**Purpose**: Secure storage of Supabase credentials

**Content**:
```swift
struct SupabaseConfig {
    static let url = "https://snrpggjvujrepxncwfkz.supabase.co"
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Security Notes**:
- ⚠️ Credentials are currently hardcoded for development
- 🔒 Anon key is safe for client-side use with Row Level Security (RLS) enabled
- 📝 TODO: Move to environment variables or secure config for production
- 📝 TODO: Add to .gitignore if using external config file

**Lines**: 15

---

### 2. `/glimpse/Services/SupabaseManager.swift`

**Purpose**: Singleton manager for Supabase client and authentication helpers

**Key Features**:
- Singleton pattern with shared instance
- Initializes Supabase client with credentials from config
- Helper functions for common auth operations

**Functions Added**:
```swift
// Sign out current user and clear local data
func signOut() async throws

// Get current authenticated user's ID
func getCurrentUserId() async throws -> UUID

// Check if user has active session
func hasActiveSession() async -> Bool
```

**Usage Example**:
```swift
let userId = try await SupabaseManager.shared.getCurrentUserId()
```

**Lines**: 50

---

### 3. `/glimpse/Views/Onboarding/SignInView.swift`

**Purpose**: Dedicated sign in view for existing users (NEW - 2025-12-31 Update)

**Key Features**:
- Sign in only (does NOT create new users)
- Error handling for invalid credentials
- Loading states during authentication
- **Smart navigation**: Dashboard if onboarding complete, PersonalizationView if incomplete
- Links to Terms of Service and Privacy Policy

**UI Elements**:
- Title: "Welcome Back"
- Subtitle: "Sign in to continue your journey."
- Email input field
- Password input (SecureField)
- "Sign In" button with loading state
- Back button to return to Sign Up

**Authentication Flow** (UPDATED - now checks Supabase):
```swift
func signIn() {
    // Only signs in - does NOT sign up
    try await client.auth.signIn(email: email, password: password)

    // Check Supabase for onboarding status
    let hasCompletedOnboarding = await checkOnboardingStatus()

    if hasCompletedOnboarding {
        // Existing user with data in Supabase → Load goals and go to Dashboard
        storageManager.loadGoals()
        storageManager.completeOnboarding() // Sync local flag
        navigateToDashboard = true
    } else {
        // User who signed up but didn't finish → Continue onboarding
        navigateToPersonalization = true
    }
}

private func checkOnboardingStatus() async -> Bool {
    // Queries Supabase for profile with first_name
    // Queries Supabase for user's goals
    // Returns true only if both exist
}
```

**Navigation Logic** (UPDATED):
- ✅ **Has profile + goals in Supabase** → Dashboard (loads goals from Supabase)
- ⏭️ **Missing profile or goals** → PersonalizationView (finish onboarding)

**Error Messages**:
- Invalid credentials: "Invalid email or password. Please try again."
- No fallback to sign up (unlike old AuthView)

**Progress Indicator**: 2/5 (Second dot active)

**Lines**: ~300

---

## Files Modified

### 1. `/glimpse/Views/Onboarding/AuthView.swift` - UPDATED (2025-12-31)

**Major Changes**:
- ✅ Changed to Sign Up ONLY (no longer tries to sign in)
- ✅ Title changed: "Welcome to Glimpse" → "Create Your Account"
- ✅ Subtitle changed to reflect sign up purpose
- ✅ Button text changed: "Continue" → "Create Account"
- ✅ Function renamed: `signInWithEmail()` → `signUp()`
- ✅ Removed fallback sign in logic
- ✅ Added "Already have an account? Sign In" navigation link

**State Variables** (unchanged):
```swift
@State private var errorMessage: String?
@State private var showError = false
```

**Updated Authentication Flow**:
1. User enters email/password
2. Taps "Create Account"
3. Only calls `signUp()` (does NOT try sign in first)
4. Check if email confirmation required
5. Navigate to PersonalizationView on success
6. Show error alert on failure

**New Function Implementation**:
```swift
func signUp() {
    // Only signs up - does NOT sign in
    try await client.auth.signUp(email: email, password: password)
    // Check email confirmation
    // Navigate or show confirmation message
}
```

**Navigation Added**:
- "Already have an account? Sign In" link
- Navigates to new SignInView
- Shows on both initial screen and email auth form

**Apple/Google Auth** (unchanged):
- Marked as TODO for future implementation
- Show "coming soon" error message when tapped

**UI Changes**:
- Title: "Create Your Account"
- Subtitle: "Start your journey of gratitude and reflection."
- Button: "Create Account" with ProgressView loading state
- Navigation link to SignInView below button
- Error alert appears on sign up failures

**Lines Modified**: ~90
**Lines Added**: ~60

---

### 2. `/glimpse/Views/Onboarding/PersonalizationView.swift`

**Changes Made**:
- ✅ Added state variables for loading and errors
- ✅ Implemented Supabase save function
- ✅ Updated Continue button with loading state
- ✅ Added error alert dialog

**State Variables Added**:
```swift
@State private var isLoading = false
@State private var errorMessage: String?
@State private var showError = false
```

**New Function**:
```swift
private func savePersonalization() async {
    // Gets current user ID
    // Updates profiles table with first_name
    // Handles errors gracefully
}
```

**Database Operation**:
```swift
await client
    .from("profiles")
    .update(["first_name": firstName])
    .eq("id", value: userId.uuidString)
    .execute()
```

**Data Saved**:
- Table: `profiles`
- Column: `first_name`
- Value: Trimmed user input

**UI Changes**:
- Continue button shows ProgressView when saving
- Button calls save function via simultaneousGesture
- Error alert displays on save failures

**Lines Modified**: ~30
**Lines Added**: ~35

---

### 3. `/glimpse/Views/Onboarding/NotificationTimeView.swift`

**Changes Made**:
- ✅ Added state variables for loading and errors
- ✅ Implemented Supabase save function for notification settings
- ✅ Updated Continue button with loading state
- ✅ Added error alert dialog

**State Variables Added**:
```swift
@State private var isLoading = false
@State private var errorMessage: String?
@State private var showError = false
```

**New Function**:
```swift
private func saveNotificationSettings() async {
    // Extracts hour/minute from selectedTime
    // Formats as "HH:mm:ss" string
    // Upserts to notification_settings table
}
```

**Database Operation**:
```swift
let settings: [String: Any] = [
    "user_id": userId.uuidString,
    "reminder_time": timeString,  // Format: "14:30:00"
    "enabled": enableReminders
]

await client
    .from("notification_settings")
    .upsert(settings)
    .execute()
```

**Data Saved**:
- Table: `notification_settings`
- Fields:
  - `user_id`: UUID string
  - `reminder_time`: Time in "HH:mm:ss" format
  - `enabled`: Boolean

**Time Conversion**:
```swift
let hour = calendar.component(.hour, from: selectedTime)
let minute = calendar.component(.minute, from: selectedTime)
let timeString = String(format: "%02d:%02d:00", hour, minute)
```

**UI Changes**:
- Continue button shows ProgressView when saving
- Button calls save function via simultaneousGesture
- Error alert displays on save failures

**Lines Modified**: ~30
**Lines Added**: ~45

---

### 4. `/glimpse/Views/Onboarding/GoalsSetupView.swift`

**Changes Made**:
- ✅ Added state variables for loading, errors, and navigation
- ✅ Completely rewrote saveGoalsAndCompleteOnboarding function
- ✅ Replaced NavigationLink with programmatic navigation
- ✅ Updated Continue button with loading state
- ✅ Added error alert dialog

**State Variables Added**:
```swift
@State private var isLoading = false
@State private var errorMessage: String?
@State private var showError = false
@State private var navigateToDashboard = false
```

**Rewritten Function**:
```swift
private func saveGoalsAndCompleteOnboarding() {
    // Validates goals array
    // Converts goals to database format
    // Inserts all goals to Supabase
    // Marks onboarding complete
    // Triggers navigation to dashboard
}
```

**Database Operation**:
```swift
let goalsData = goals.map { goal in
    [
        "user_id": userId.uuidString,
        "title": goal.title,
        "category": goal.category.rawValue
    ]
}

await client
    .from("goals")
    .insert(goalsData)
    .execute()
```

**Data Saved**:
- Table: `goals`
- Fields per goal:
  - `user_id`: UUID string
  - `title`: Goal title (1-50 chars)
  - `category`: Category enum rawValue

**Navigation Changes**:
- Replaced direct NavigationLink with hidden NavigationLink + isActive binding
- Navigation triggered programmatically after successful save
- Prevents navigation on save failures

**UI Changes**:
- Continue button now a regular Button (not NavigationLink)
- Shows ProgressView when saving
- Button disabled when loading or no goals
- Error alert displays on save failures

**Lines Modified**: ~50
**Lines Added**: ~40

---

### 5. `/glimpse/Services/GoalStorageManager.swift`

**Changes Made**:
- ✅ Added Supabase response model
- ✅ Completely rewrote loadGoals function
- ✅ Changed initialization to not load goals immediately
- ✅ Goals now loaded from Supabase instead of UserDefaults

**New Model Added**:
```swift
private struct GoalResponse: Decodable {
    let id: String
    let user_id: String
    let title: String
    let category: String
    let created_at: String?
}
```

**Rewritten Function**:
```swift
func loadGoals() {
    Task {
        // Gets current user ID
        // Queries goals table filtered by user_id
        // Maps response to Goal objects
        // Updates published goals array on main thread
        // Handles errors gracefully
    }
}
```

**Database Query**:
```swift
let response: [GoalResponse] = try await client
    .from("goals")
    .select()
    .eq("user_id", value: userId.uuidString)
    .execute()
    .value
```

**Data Mapping**:
```swift
let loadedGoals = response.map { goalResponse in
    Goal(
        id: UUID(uuidString: goalResponse.id) ?? UUID(),
        title: goalResponse.title,
        category: GoalCategory(rawValue: goalResponse.category) ?? .personal
    )
}
```

**Initialization Change**:
- **Before**: `loadGoals()` called in init
- **After**: Goals loaded when user is authenticated (from glimpseApp)

**Error Handling**:
- Falls back to empty array if load fails
- Prints error to console for debugging

**Lines Modified**: ~35
**Lines Added**: ~30

---

### 6. `/glimpse/glimpseApp.swift`

**Changes Made**:
- ✅ Added session checking state variables
- ✅ Implemented session check on app launch
- ✅ Added loading screen during session check
- ✅ Updated navigation logic based on session state
- ✅ Added loadGoals call when dashboard appears

**State Variables Added**:
```swift
@State private var isCheckingSession = true
@State private var hasActiveSession = false
```

**New Function**:
```swift
private func checkSession() async {
    // Attempts to get current session
    // Sets hasActiveSession flag
    // Clears loading state
    // Handles no session gracefully
}
```

**App Launch Flow**:
```
1. Show loading screen (isCheckingSession = true)
2. Check for active Supabase session
3. If session exists → hasActiveSession = true
4. If no session → hasActiveSession = false
5. Hide loading screen (isCheckingSession = false)
6. Show appropriate view based on session + onboarding state
```

**Navigation Logic**:
```swift
if isCheckingSession {
    // Show loading screen
} else if hasActiveSession && storageManager.isOnboardingComplete {
    // Show dashboard + load goals
    DashboardView()
} else {
    // Show onboarding
    ContentView()
}
```

**Loading Screen**:
- Cream background matching app theme
- Glimpse logo (book icon in terracotta circle)
- App name
- ProgressView spinner
- Centered layout

**Goal Loading**:
```swift
DashboardView()
    .onAppear {
        storageManager.loadGoals()
    }
```

**Lines Modified**: ~40
**Lines Added**: ~60

---

## Database Schema Required

The integration expects the following tables to exist in Supabase:

### 1. `profiles` Table
```sql
CREATE TABLE profiles (
    id UUID REFERENCES auth.users PRIMARY KEY,
    first_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only read/insert/update their own profile
CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);
```

### 2. `notification_settings` Table
```sql
CREATE TABLE notification_settings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    reminder_time TIME NOT NULL,
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Enable Row Level Security
ALTER TABLE notification_settings ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access their own settings
CREATE POLICY "Users can view own notification settings"
    ON notification_settings FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notification settings"
    ON notification_settings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notification settings"
    ON notification_settings FOR UPDATE
    USING (auth.uid() = user_id);
```

### 3. `goals` Table
```sql
CREATE TABLE goals (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users NOT NULL,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access their own goals
CREATE POLICY "Users can view own goals"
    ON goals FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own goals"
    ON goals FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own goals"
    ON goals FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own goals"
    ON goals FOR DELETE
    USING (auth.uid() = user_id);
```

### Automatic Profile Creation

To automatically create a profile when a user signs up:

```sql
-- Function to create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call function on user creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();
```

---

## Authentication Flow - UPDATED (2025-12-31)

### Separate Sign Up and Sign In Flows

**Sign Up Flow** (AuthView):
```
User lands on AuthView (Sign Up page)
    ↓
Tap "Continue with Email" or "Continue with Apple/Google"
    ↓
Enter email + password
    ↓
Tap "Create Account"
    ↓
Call signUp() - ONLY creates new user
    ↓
    ├─ Success (no email confirmation) → Navigate to PersonalizationView
    │
    ├─ Success (needs confirmation) → Show alert "Check your email"
    │
    └─ Failure (email exists/weak password) → Show error alert

Optional: Tap "Already have an account? Sign In" → Navigate to SignInView
```

**Sign In Flow** (SignInView):
```
User taps "Sign In" link from AuthView
    ↓
Navigate to SignInView
    ↓
Enter email + password
    ↓
Tap "Sign In"
    ↓
Call signIn() - ONLY signs in existing user
    ↓
    ├─ Success → Check onboarding status
    │   ├─ Onboarding complete → Navigate to Dashboard (load goals)
    │   └─ Onboarding incomplete → Navigate to PersonalizationView
    │
    └─ Failure (invalid credentials) → Show error "Invalid email or password"

Note: Does NOT create new users if credentials are wrong
Note: Existing users skip onboarding and go straight to Dashboard
```

### Session Persistence

- Supabase SDK automatically persists session
- Session checked on app launch
- Expired sessions redirect to onboarding
- Active sessions skip to dashboard (if onboarding complete)

---

## Data Flow Summary

### Onboarding Flow with Supabase - UPDATED (2025-12-31)

```
1. ContentView (Welcome)
    ↓
2. AuthView (Sign Up)
    ├─ Email/Password → Supabase Auth signUp()
    ├─ Apple Sign In (future)
    ├─ Google Sign In (future)
    └─ "Already have account?" → Navigate to SignInView
    ↓
2a. SignInView (if existing user) ← NEW
    └─ Email/Password → Supabase Auth signIn()
    ↓
3. PersonalizationView
    └─ Save first_name → profiles table
    ↓
4. NotificationTimeView
    └─ Save reminder settings → notification_settings table
    ↓
5. GoalsSetupView
    ├─ Save goals → goals table
    └─ Mark onboarding complete (UserDefaults)
    ↓
6. DashboardView
    └─ Load goals from Supabase
```

**Key Changes**:
- AuthView now only handles sign up
- New SignInView handles sign in for existing users
- Clear separation prevents accidental user creation

### Data Storage

| Data | Storage Location | Table/Key |
|------|------------------|-----------|
| **User Session** | Supabase Auth | Managed by SDK |
| **First Name** | Supabase Database | `profiles.first_name` |
| **Notification Settings** | Supabase Database | `notification_settings.*` |
| **Goals** | Supabase Database | `goals.*` |
| **Onboarding Complete Flag** | Local (UserDefaults) | `glimpse.onboarding.complete` |

**Note**: Onboarding flag still uses UserDefaults for simplicity. Could be moved to Supabase in future.

---

## Error Handling

### All Views Now Include:

1. **Loading States**:
   - ProgressView shown during async operations
   - Buttons disabled while loading
   - Visual feedback for user

2. **Error Alerts**:
   - User-friendly error messages
   - OK button to dismiss
   - Falls back to "An unknown error occurred" if no message

3. **Graceful Degradation**:
   - Failed loads default to empty arrays
   - Errors logged to console for debugging
   - User can retry operations

### Example Error Handling Pattern:

```swift
do {
    // Supabase operation
    try await SupabaseManager.shared.client...

    await MainActor.run {
        isLoading = false
        // Success actions
    }
} catch {
    await MainActor.run {
        isLoading = false
        errorMessage = error.localizedDescription
        showError = true
    }
}
```

---

## Testing Checklist

### Functional Testing

- [x] **Authentication**:
  - [ ] Sign up with new email/password creates user
  - [ ] Sign in with existing credentials works
  - [ ] Invalid credentials show error
  - [ ] Weak passwords are rejected (if configured in Supabase)
  - [ ] Email confirmation works (if enabled)

- [ ] **Data Persistence**:
  - [ ] First name saves to profiles table
  - [ ] Notification settings save correctly
  - [ ] Goals save to database
  - [ ] All data associated with correct user_id

- [ ] **Data Retrieval**:
  - [ ] Goals load on dashboard
  - [ ] Only user's own goals are visible
  - [ ] Empty state handled gracefully

- [ ] **Session Management**:
  - [ ] Session persists after app restart
  - [ ] Expired sessions redirect to login
  - [ ] Sign out clears session

- [ ] **Error Handling**:
  - [ ] Network errors show user-friendly messages
  - [ ] Invalid data rejected gracefully
  - [ ] Offline mode handled appropriately

### UI Testing

- [ ] Loading states display correctly
- [ ] Error alerts appear and dismiss properly
- [ ] Buttons disable during operations
- [ ] ProgressView shows while loading
- [ ] Navigation flows work correctly

### Security Testing

- [ ] Row Level Security prevents accessing other users' data
- [ ] Anon key doesn't allow unauthorized operations
- [ ] SQL injection attempts are prevented (handled by Supabase)

---

## Known Limitations & Future Work

### Current Limitations:

1. **Apple Sign In**: Not implemented (shows "coming soon")
2. **Google Sign In**: Not implemented (shows "coming soon")
3. **Offline Support**: No offline queue for failed operations
4. **Data Validation**: Minimal client-side validation
5. **Email Confirmation**: Handled but not thoroughly tested
6. **Password Reset**: No UI for password reset flow
7. **Profile Updates**: No UI to edit profile after onboarding

### Future Enhancements:

#### Authentication:
- [ ] Implement Sign in with Apple
- [ ] Implement Sign in with Google
- [ ] Add password reset flow
- [ ] Add email change functionality
- [ ] Add re-authentication for sensitive operations

#### Data Persistence:
- [ ] Implement offline queue with retry logic
- [ ] Add optimistic updates
- [ ] Cache data locally for offline viewing
- [ ] Sync local changes when back online

#### User Experience:
- [ ] Add profile edit screen
- [ ] Add goal edit/delete from dashboard
- [ ] Add notification scheduling (actual push notifications)
- [ ] Add data export functionality
- [ ] Add account deletion

#### Security:
- [ ] Move credentials to environment variables
- [ ] Add certificate pinning
- [ ] Implement additional RLS policies
- [ ] Add rate limiting on sensitive operations

#### Analytics:
- [ ] Track auth method usage
- [ ] Track onboarding completion rates
- [ ] Monitor error rates
- [ ] Track feature usage

---

## Migration Notes

### From UserDefaults to Supabase

**What Changed**:
- Goals: UserDefaults → Supabase `goals` table
- Personalization: Not saved → Supabase `profiles` table
- Notifications: Not saved → Supabase `notification_settings` table

**What Stayed the Same**:
- Onboarding complete flag: Still in UserDefaults
- Debug reset flag: Still in UserDefaults

**Migration Path** (if needed):
If you had users with local data before Supabase:
1. Read goals from UserDefaults on first launch
2. Upload to Supabase if user is authenticated
3. Clear UserDefaults after successful upload
4. Set migration complete flag

---

## Debugging Tips

### Common Issues:

1. **"No active session" error**:
   - User not authenticated
   - Session expired
   - Check Supabase auth settings

2. **"Row Level Security policy violation"**:
   - RLS policies not created
   - User trying to access another user's data
   - Check database policies

3. **"Column does not exist"**:
   - Database schema doesn't match code
   - Run migration scripts
   - Check table structure

4. **App shows loading forever**:
   - Network connectivity issue
   - Supabase URL/key incorrect
   - Check SupabaseConfig credentials

### Debugging Commands:

```swift
// Print current session
Task {
    do {
        let session = try await SupabaseManager.shared.client.auth.session
        print("User ID:", session.user.id)
        print("Email:", session.user.email ?? "No email")
    } catch {
        print("No active session:", error)
    }
}

// Check if goals loaded
print("Goals count:", GoalStorageManager.shared.goals.count)
```

---

## Security Considerations

### Credentials Management:

**Current (Development)**:
- Hardcoded in SupabaseConfig.swift
- Committed to repository
- Safe for development with RLS enabled

**Production Recommendations**:
1. Move to environment variables
2. Use Xcode configuration files
3. Add Config.plist to .gitignore
4. Use different credentials for dev/staging/prod
5. Rotate keys periodically

### Row Level Security (RLS):

**Critical**: Ensure RLS policies are enabled on all tables
- Prevents users from accessing each other's data
- Anon key is safe to expose with proper RLS
- Test RLS policies thoroughly

### Best Practices:
- ✅ Never commit service_role key to repository
- ✅ Use anon/public key for client-side
- ✅ Enable RLS on all user data tables
- ✅ Validate data on server-side (Supabase functions)
- ✅ Use HTTPS only (enforced by Supabase)
- ✅ Implement rate limiting for auth endpoints

---

## Performance Considerations

### Current Implementation:
- Async/await for non-blocking operations
- Main thread updates for UI
- Loading states provide user feedback

### Optimization Opportunities:
- [ ] Cache goals locally (Core Data or SQLite)
- [ ] Implement pagination for large goal lists
- [ ] Debounce rapid saves
- [ ] Batch operations where possible
- [ ] Preload data on splash screen

---

## Summary of Changes

### What Works Now:
✅ Email/password authentication
✅ User session persistence
✅ First name saved to Supabase
✅ Notification settings saved to Supabase
✅ Goals saved to Supabase
✅ Goals loaded from Supabase
✅ Loading states on all operations
✅ Error handling throughout
✅ Session checking on app launch

### What Doesn't Work Yet:
❌ Apple Sign In (future)
❌ Google Sign In (future)
❌ Password reset UI
❌ Profile editing
❌ Offline support
❌ Goal editing from dashboard
❌ Actual push notifications

### Files Created: 2
1. Config/SupabaseConfig.swift
2. Services/SupabaseManager.swift

### Files Modified: 6
1. Views/Onboarding/AuthView.swift
2. Views/Onboarding/PersonalizationView.swift
3. Views/Onboarding/NotificationTimeView.swift
4. Views/Onboarding/GoalsSetupView.swift
5. Services/GoalStorageManager.swift
6. glimpseApp.swift

### Dependencies Added: 1
- supabase-swift (Supabase, Auth, PostgREST)

---

**Document Version**: 1.0
**Last Updated**: 2025-12-31
**Integration Status**: ✅ Complete (Email/Password Auth)
**Created By**: Claude Code
**Related Documents**:
- `ONBOARDING_WORKFLOW.md` - Complete onboarding flow documentation
- `ONBOARDING_CLEANUP_CHANGELOG.md` - Previous cleanup changes
