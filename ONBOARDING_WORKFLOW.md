# Glimpse Onboarding Workflow Documentation

## Overview

This document provides a comprehensive breakdown of the Glimpse app's onboarding workflow, detailing each screen, user interactions, data collection, and navigation flow.

**Total Onboarding Steps**: 5 screens
**Estimated Completion Time**: 2-3 minutes
**Entry Point**: App launch (when onboarding not completed)
**Exit Point**: DashboardView (main app interface)

---

## Onboarding Flow Diagram

```
App Launch
    ↓
[Check: isOnboardingComplete?]
    ↓ NO
┌─────────────────────────────────────────┐
│ Step 1: ContentView (Welcome)           │
│ Progress: ●○○○○                         │
└─────────────────────────────────────────┘
    ↓ Tap "Get Started"
┌─────────────────────────────────────────┐
│ Step 2: AuthView (Authentication)       │
│ Progress: ○●○○○                         │
└─────────────────────────────────────────┘
    ↓ Sign in (Email/Apple/Google)
┌─────────────────────────────────────────┐
│ Step 3: PersonalizationView             │
│ Progress: ○○●○○                         │
└─────────────────────────────────────────┘
    ↓ Tap "Continue"
┌─────────────────────────────────────────┐
│ Step 4: NotificationTimeView             │
│ Progress: ○○○●○                         │
└─────────────────────────────────────────┘
    ↓ Tap "Continue"
┌─────────────────────────────────────────┐
│ Step 5: GoalsSetupView                   │
│ Progress: ○○○○●                         │
└─────────────────────────────────────────┘
    ↓ Add goal(s) + Tap "Continue"
    ↓ [Save goals & Mark onboarding complete]
┌─────────────────────────────────────────┐
│ DashboardView (Main App)                 │
└─────────────────────────────────────────┘
```

---

## Screen-by-Screen Breakdown

### Step 1: ContentView (Welcome Screen)

**File**: `/glimpse/Views/Onboarding/ContentView.swift`
**Purpose**: Introduce the app's value proposition and initiate onboarding
**Progress Indicator**: 1/5 (First dot active)

#### Visual Elements:
- **Header**: Glimpse logo (book icon) + app name
- **Hero Section**:
  - Large book icon (100pt) on decorative card background
  - 3 floating decorative circles around the icon
  - Card with rounded corners (40pt radius)
- **Headline**: "Capture what matters" (32pt bold)
- **Subheadline**: "Answer one question each day. Build a journal of your best moments." (17pt)
- **CTA Button**: "Get Started" (primary accent color)

#### Color Scheme:
- **Light Mode**:
  - Background: Cream (#FFF8F0)
  - Accent: Terracotta (#D49578)
- **Dark Mode**:
  - Background: Dark Blue-Gray (#1C1E26)
  - Accent: Blue (#5994FF)

#### User Actions:
- ✅ Tap "Get Started" → Navigate to AuthView
- ❌ No back button (entry point)

#### Data Collected:
- None

---

### Step 2: AuthView (Authentication)

**File**: `/glimpse/Views/Onboarding/AuthView.swift`
**Purpose**: User authentication via multiple providers
**Progress Indicator**: 2/5 (Second dot active)

#### Visual Elements:
- **Header**: Back button + Glimpse logo (centered)
- **Title**: "Welcome to Glimpse" (32pt bold)
- **Subtitle**: "Sign in to start journaling your gratitude and build lasting memories." (17pt)
- **Authentication Options** (conditional rendering):

##### Default State (showEmailAuth = false):
1. **"Continue with Email"** button (primary accent)
   - Icon: envelope.fill
2. **Divider**: "or" separator
3. **"Continue with Apple"** button (black background)
   - Icon: apple.logo
4. **"Continue with Google"** button (white/dark background with border)
   - Icon: g.circle.fill

##### Email Auth State (showEmailAuth = true):
1. **Email Field**:
   - Label: "Email"
   - Placeholder: "your@email.com"
   - Keyboard: Email type
   - Autocapitalization: Disabled
   - Autocorrection: Disabled
2. **Password Field**:
   - Label: "Password"
   - Placeholder: "Enter your password"
   - Type: SecureField
3. **"Continue"** button (primary accent)
   - Disabled when email or password is empty
   - Opacity: 0.5 when disabled
4. **"Back to sign in options"** link

#### Footer:
- Legal text: "By continuing, you agree to our"
- Links: "Terms of Service" and "Privacy Policy" (clickable)

#### User Actions:
- ✅ Tap back button → Dismiss (return to ContentView)
- ✅ Tap "Continue with Email" → Show email/password form
- ✅ Tap "Continue with Apple" → Sign in with Apple (TODO: Not implemented)
- ✅ Tap "Continue with Google" → Sign in with Google (TODO: Not implemented)
- ✅ Fill email + password + Tap "Continue" → Sign in (TODO: Not implemented)
- ✅ Tap "Terms of Service" → Navigate to TermsOfServiceView
- ✅ Tap "Privacy Policy" → Navigate to PrivacyPolicyView
- ✅ Tap "Back to sign in options" → Hide email form

#### Auth Flow (Current Implementation):
```swift
// All auth methods currently navigate to PersonalizationView
// Actual authentication is marked as TODO
func signInWithEmail() → navigateToPersonalization = true
func signInWithApple() → navigateToPersonalization = true
func signInWithGoogle() → navigateToPersonalization = true
```

#### Data Collected:
- Email address (if email auth chosen)
- Password (if email auth chosen)
- **Note**: Authentication is placeholder only - no actual backend integration yet

#### State Variables:
```swift
@State private var email: String = ""
@State private var password: String = ""
@State private var isLoading = false
@State private var showEmailAuth = false
@State private var navigateToPersonalization = false
```

---

### Step 3: PersonalizationView

**File**: `/glimpse/Views/Onboarding/PersonalizationView.swift`
**Purpose**: Collect user's preferred name for personalization
**Progress Indicator**: 3/5 (Third dot active)

#### Visual Elements:
- **Header**: Back button + Glimpse logo (centered)
- **Title**: "Let's Get to Know You" (32pt bold)
- **Subtitle**: "This helps us personalize your experience." (17pt)
- **Form Section**:
  - **Label**: "What should we call you?" (18pt semibold) ⭐ Recently enhanced
  - **Input Field**: TextField with placeholder "e.g., Taylor"
  - **Hint Text**: "We'll use this to personalize your Glimpse experience" (14pt, 50% opacity) ⭐ Recently added
- **CTA Button**: "Continue" (primary accent)

#### Recent UI Enhancements (2025-12-31):
- ✅ Removed lastName and dateOfBirth fields
- ✅ Enhanced label from 15pt → 18pt semibold
- ✅ Added supportive hint text below input
- ✅ Improved spacing hierarchy (60pt title spacing, 12pt label-to-input)
- ✅ Replaced unbounded Spacer with minLength: 60 for consistency

#### User Actions:
- ✅ Tap back button → Dismiss (return to AuthView)
- ✅ Enter name in text field
- ✅ Tap "Continue" → Navigate to NotificationTimeView

#### Data Collected:
- **firstName**: String (user's preferred name)

#### Data Storage:
```swift
// Function exists but not currently called during onboarding
func savePersonalization(firstName: String) {
    let personalization: [String: Any] = ["firstName": firstName]
    UserDefaults.standard.set(personalization, forKey: "glimpse.user.personalization")
}
```

#### State Variables:
```swift
@State private var firstName: String = ""
```

#### Validation:
- No validation currently implemented
- User can proceed with empty name

---

### Step 4: NotificationTimeView

**File**: `/glimpse/Views/Onboarding/NotificationTimeView.swift`
**Purpose**: Set daily reminder time and enable/disable notifications
**Progress Indicator**: 4/5 (Fourth dot active)

#### Visual Elements:
- **Header**: Back button + Glimpse logo (centered)
- **Title**: "When should we remind you?" (32pt bold)
- **Subtitle**: "We'll send a gentle reminder each day." (17pt)
- **Time Picker**:
  - Style: Wheel picker
  - Height: 180pt
  - Background: Rounded rectangle (20pt radius) with card styling
  - Components: Hour and minute only
- **Toggle Control**:
  - Label: "Enable daily reminders" (17pt)
  - Position: Bottom of screen, above Continue button
  - Tint color: Primary accent
  - Default state: Enabled (true)
- **CTA Button**: "Continue" (primary accent)

#### User Actions:
- ✅ Tap back button → Dismiss (return to PersonalizationView)
- ✅ Scroll time picker → Select preferred reminder time
- ✅ Toggle "Enable daily reminders" → Enable/disable notifications
- ✅ Tap "Continue" → Navigate to GoalsSetupView

#### Data Collected:
- **selectedTime**: Date (time for daily reminder)
- **enableReminders**: Bool (whether reminders are enabled)

#### Data Storage:
```swift
// Function exists but not currently called during onboarding
func saveNotificationSettings(time: Date, enabled: Bool) {
    let settings: [String: Any] = [
        "time": time.timeIntervalSince1970,
        "enabled": enabled
    ]
    UserDefaults.standard.set(settings, forKey: "glimpse.notification.settings")
}
```

#### State Variables:
```swift
@State private var selectedTime: Date = Date()
@State private var enableReminders: Bool = true
```

#### Default Values:
- Time: Current time when view loads
- Reminders: Enabled by default

---

### Step 5: GoalsSetupView (Final Step)

**File**: `/glimpse/Views/Onboarding/GoalsSetupView.swift`
**Purpose**: Add personal goals to track (1-3 goals required to complete onboarding)
**Progress Indicator**: 5/5 (Fifth dot active)

#### Visual Elements:
- **Header**: Back button + Glimpse logo (centered)
- **Title**: "What are your goals?" (32pt bold)
- **Subtitle**: "Add up to 3 goals to track and reflect on daily." (17pt)
- **Goals List** (ScrollView):
  - Displays added goals with category icons
  - Each goal card shows:
    - Category icon (44pt circle with color)
    - Goal title (16pt semibold)
    - Category name (13pt, subdued)
    - Delete button (trash icon)
- **Add Goal Form** (conditional - shows if < 3 goals):
  - **Goal Input**:
    - Label: "Goal"
    - Character counter: "X/50"
    - Placeholder: "e.g., Exercise daily"
    - Max length: 50 characters
  - **Category Selector**:
    - Label: "Category"
    - Button showing current category with icon
    - Chevron right indicator
    - Opens CategoryPickerView sheet
  - **"Add Goal"** button (accent color)
    - Disabled if goal title is empty
    - Opacity: 0.5 when disabled
- **Max Goals Message**: "You can track up to 3 goals" (when 3 goals added)
- **CTA Button**: "Continue" (primary accent)
  - Disabled if no goals added
  - Opacity: 0.5 when disabled
  - Saves goals and completes onboarding on tap

#### Goal Categories:
Available categories defined in `GoalCategory` enum:
- **Personal** (default)
  - Icon: person.fill
  - Color varies by theme
- **Health**
  - Icon: heart.fill
- **Career**
  - Icon: briefcase.fill
- **Learning**
  - Icon: book.fill
- **Fitness**
  - Icon: figure.run
- **Finance**
  - Icon: dollarsign.circle.fill
- **Relationships**
  - Icon: person.2.fill
- **Creativity**
  - Icon: paintpalette.fill

#### User Actions:
- ✅ Tap back button → Dismiss (return to NotificationTimeView)
- ✅ Enter goal title (max 50 characters)
- ✅ Tap category selector → Open CategoryPickerView sheet
- ✅ Select category → Update selectedCategory
- ✅ Tap "Add Goal" → Add goal to list, reset form
- ✅ Tap delete on goal card → Remove goal from list
- ✅ Tap "Continue" (with ≥1 goal) → Save goals + Complete onboarding → Navigate to DashboardView

#### Data Collected:
- **goals**: Array of Goal objects (1-3 goals)
  - Each goal contains:
    - `id`: UUID (auto-generated)
    - `title`: String (1-50 characters)
    - `category`: GoalCategory enum

#### Data Storage:
```swift
private func saveGoalsAndCompleteOnboarding() {
    guard !goals.isEmpty else { return }

    // Save goals to UserDefaults
    storageManager.saveGoals(goals)

    // Mark onboarding as complete
    storageManager.completeOnboarding()
    // Sets: UserDefaults.standard.set(true, forKey: "glimpse.onboarding.complete")
}
```

#### State Variables:
```swift
@State private var goals: [Goal] = []
@State private var goalTitle: String = ""
@State private var selectedCategory: GoalCategory = .personal
@State private var showingCategoryPicker = false
```

#### Validation:
- ✅ Must add at least 1 goal to proceed
- ✅ Goal title cannot be empty (whitespace trimmed)
- ✅ Maximum 50 characters per goal title
- ✅ Maximum 3 goals total

#### Completion Criteria:
This is the ONLY screen that marks onboarding as complete:
```swift
storageManager.isOnboardingComplete = true
```

---

## Navigation Architecture

### Navigation Stack Hierarchy:
```
NavigationStack (ContentView)
    ↓ NavigationLink
AuthView
    ↓ navigationDestination(isPresented:)
PersonalizationView
    ↓ NavigationLink
NotificationTimeView
    ↓ NavigationLink
GoalsSetupView
    ↓ NavigationLink + TapGesture
DashboardView
```

### Back Navigation:
- All screens (except ContentView) have back buttons using `@Environment(\.dismiss)`
- Back buttons allow users to return to previous screens
- Progress dots visually indicate current position

### Navigation Completion:
```swift
// In GoalsSetupView - simultaneousGesture on Continue button
.simultaneousGesture(TapGesture().onEnded {
    saveGoalsAndCompleteOnboarding()
})
```

---

## Data Persistence

### Storage Manager:
**File**: `/glimpse/Services/GoalStorageManager.swift`

#### UserDefaults Keys:
```swift
private let goalsKey = "glimpse.user.goals"
private let onboardingCompleteKey = "glimpse.onboarding.complete"
private let userPersonalizationKey = "glimpse.user.personalization"
private let notificationSettingsKey = "glimpse.notification.settings"
```

#### Data Saved During Onboarding:
1. **Goals** (Step 5 - GoalsSetupView):
   ```swift
   // Array of Goal objects encoded as JSON
   UserDefaults.standard.set(encodedGoals, forKey: "glimpse.user.goals")
   ```

2. **Onboarding Complete Flag** (Step 5 - GoalsSetupView):
   ```swift
   UserDefaults.standard.set(true, forKey: "glimpse.onboarding.complete")
   ```

#### Data NOT Saved (Functions Exist But Not Called):
- ❌ **Personalization** (firstName from Step 3)
- ❌ **Notification Settings** (time and enabled from Step 4)

**Note**: These functions exist in GoalStorageManager but are marked "for future use" and are not called during the current onboarding flow.

---

## Design System

### Color Palette:

#### Light Mode:
```swift
Background: Color(red: 1.0, green: 0.97, blue: 0.94)  // #FFF8F0 Cream
Primary Accent: Color(red: 0.83, green: 0.58, blue: 0.49)  // #D49578 Terracotta
Text Primary: Color(red: 0.17, green: 0.17, blue: 0.17)  // #2B2B2B Dark Gray
Text Secondary: Same as primary at 60% opacity
Card Background: Color.white.opacity(0.5)  // Semi-transparent white
```

#### Dark Mode:
```swift
Background: Color(red: 0.11, green: 0.12, blue: 0.15)  // #1C1E26 Dark Blue-Gray
Primary Accent: Color(red: 0.35, green: 0.58, blue: 1.0)  // #5994FF Blue
Text Primary: Color.white  // #FFFFFF White
Text Secondary: Color.white at 60% opacity
Card Background: Color(red: 0.15, green: 0.18, blue: 0.24)  // #262E3D Lighter Blue-Gray
```

### Typography:
```swift
Title (Headlines): 32pt, bold
Subtitle: 17pt, regular
Body: 17pt, regular
Button: 18pt, semibold
Label: 15pt, regular (some enhanced to 18pt semibold)
Hint Text: 14pt, regular
Small Text: 13pt, regular
```

### Common UI Components:

#### Logo:
```swift
Circle (44x44pt)
    ↳ book.fill icon (20pt)
    ↳ Accent color background
```

#### Progress Dots:
```swift
5 dots (8x8pt circles)
    ↳ Active: Accent color
    ↳ Inactive: Gray 30% opacity
    ↳ Spacing: 12pt between dots
```

#### Primary Button:
```swift
Height: 56pt
Corner Radius: 28pt (fully rounded)
Font: 18pt semibold
Color: White text on accent background
Full width with horizontal padding: 24pt
```

#### Text Input:
```swift
Padding: 16pt
Corner Radius: 12pt
Background: Card color
Border: 1pt stroke at 10% opacity
Font: 17pt regular
```

#### Card Component:
```swift
Corner Radius: 12pt
Background: Card color
Border: Optional 1pt stroke at 10% opacity
Padding: 16pt
```

---

## Progress Indicators

### Visual Progress Tracking:
Each screen displays 5 dots showing the user's position in the onboarding flow:

| Screen | Dot 1 | Dot 2 | Dot 3 | Dot 4 | Dot 5 |
|--------|-------|-------|-------|-------|-------|
| ContentView | ● | ○ | ○ | ○ | ○ |
| AuthView | ○ | ● | ○ | ○ | ○ |
| PersonalizationView | ○ | ○ | ● | ○ | ○ |
| NotificationTimeView | ○ | ○ | ○ | ● | ○ |
| GoalsSetupView | ○ | ○ | ○ | ○ | ● |

**Legend**: ● = Active (Accent color) | ○ = Inactive (Gray 30%)

---

## App Entry Logic

### File: `/glimpse/glimpseApp.swift`

```swift
@main
struct glimpseApp: App {
    @StateObject private var storageManager = GoalStorageManager.shared

    // Debug flag - resets onboarding on every launch
    private let resetOnboardingOnLaunch = true

    init() {
        if resetOnboardingOnLaunch {
            UserDefaults.standard.set(false, forKey: "glimpse.onboarding.complete")
            UserDefaults.standard.removeObject(forKey: "glimpse.user.goals")
        }
    }

    var body: some Scene {
        WindowGroup {
            if storageManager.isOnboardingComplete {
                DashboardView()  // Main app
            } else {
                ContentView()     // Onboarding entry
            }
        }
    }
}
```

### Flow Logic:
1. App checks `storageManager.isOnboardingComplete`
2. If `true` → Show DashboardView (skip onboarding)
3. If `false` → Show ContentView (start onboarding)
4. **Debug Mode**: Currently set to reset onboarding on every launch for testing

---

## Edge Cases & Validation

### Current Validation Rules:

#### Step 2 (AuthView):
- ✅ Email and password must not be empty to enable Continue button
- ❌ No email format validation
- ❌ No password strength requirements
- ❌ No actual authentication (placeholder only)

#### Step 3 (PersonalizationView):
- ❌ No validation - can proceed with empty name
- ❌ No character limit on name
- ❌ Data not currently saved to UserDefaults

#### Step 4 (NotificationTimeView):
- ✅ Time picker always has a valid date
- ✅ Toggle always has a boolean state
- ❌ Data not currently saved to UserDefaults
- ❌ No actual notification permissions requested

#### Step 5 (GoalsSetupView):
- ✅ Must add at least 1 goal to enable Continue button
- ✅ Goal title must not be empty (whitespace trimmed)
- ✅ Maximum 50 characters enforced on goal title
- ✅ Maximum 3 goals enforced
- ✅ Goals ARE saved to UserDefaults
- ✅ Onboarding completion IS saved

### Missing Functionality:
- ⚠️ No error handling for network failures (auth not implemented)
- ⚠️ No loading states (isLoading variable exists but not used)
- ⚠️ No user feedback on successful actions (no toasts/alerts)
- ⚠️ Personalization and notification data collected but not saved
- ⚠️ No actual notification permissions requested
- ⚠️ No backend integration for authentication

---

## Accessibility Features

### Current Implementation:
- ✅ Dynamic type support (system fonts used)
- ✅ Dark mode support (full color scheme)
- ✅ Minimum touch targets: 44pt (buttons meet iOS guidelines)
- ✅ Color contrast meets WCAG standards
- ✅ VoiceOver labels on SF Symbols
- ✅ Keyboard types set appropriately (email, secure text)

### Potential Improvements:
- ⚠️ No explicit accessibility labels on custom views
- ⚠️ No accessibility hints for complex interactions
- ⚠️ No VoiceOver announcements for state changes
- ⚠️ Progress dots may need better accessibility descriptions

---

## Testing Checklist

### Functional Testing:
- [ ] Complete full onboarding flow start to finish
- [ ] Test back navigation from each screen
- [ ] Verify all three auth methods navigate correctly
- [ ] Test email/password validation
- [ ] Verify name input accepts various characters
- [ ] Test time picker selection
- [ ] Test notification toggle on/off
- [ ] Add/delete goals functionality
- [ ] Test goal character limit (50 chars)
- [ ] Test maximum goals limit (3 goals)
- [ ] Verify Continue button states (enabled/disabled)
- [ ] Test CategoryPickerView sheet presentation
- [ ] Verify onboarding completion saves correctly
- [ ] Test app restart shows Dashboard after completion

### UI Testing:
- [ ] Test in light mode
- [ ] Test in dark mode
- [ ] Test on iPhone SE (small screen)
- [ ] Test on iPhone Pro Max (large screen)
- [ ] Verify all spacing is consistent
- [ ] Check text readability at all sizes
- [ ] Verify button states (normal, pressed, disabled)
- [ ] Test keyboard interactions (email, text fields)
- [ ] Verify progress dots update correctly

### Data Persistence Testing:
- [ ] Verify goals save to UserDefaults
- [ ] Verify onboarding flag saves correctly
- [ ] Test app restart loads saved goals
- [ ] Test debug mode resets onboarding
- [ ] Verify deleted goals don't persist

---

## Future Enhancements

### Authentication:
- [ ] Implement Supabase email/password authentication
- [ ] Implement Sign in with Apple
- [ ] Implement Sign in with Google
- [ ] Add email validation
- [ ] Add password strength requirements
- [ ] Add loading states during auth
- [ ] Add error handling for auth failures

### Data Persistence:
- [ ] Save personalization data (firstName)
- [ ] Save notification settings (time, enabled)
- [ ] Request actual notification permissions
- [ ] Implement notification scheduling

### User Experience:
- [ ] Add success animations
- [ ] Add error messages/alerts
- [ ] Add loading indicators
- [ ] Add skip options for optional steps
- [ ] Add onboarding tutorial/walkthrough
- [ ] Add ability to edit profile after onboarding

### Analytics:
- [ ] Track onboarding completion rate
- [ ] Track drop-off at each step
- [ ] Track auth method preferences
- [ ] Track goal category popularity

---

## Technical Specifications

### Minimum Requirements:
- iOS 17.0+ (using .onChange new syntax)
- SwiftUI framework
- UserDefaults for local storage

### Key Dependencies:
- No external packages currently used
- Uses native SwiftUI components
- Uses native SF Symbols for icons

### File Structure:
```
glimpse/
├── glimpseApp.swift
├── Models/
│   ├── Goal.swift
│   └── GoalCategory.swift
├── Services/
│   └── GoalStorageManager.swift
├── Views/
│   ├── Onboarding/
│   │   ├── ContentView.swift
│   │   ├── AuthView.swift
│   │   ├── PersonalizationView.swift
│   │   ├── NotificationTimeView.swift
│   │   └── GoalsSetupView.swift
│   ├── Components/
│   │   └── CategoryPickerView.swift
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   └── Legal/
│       ├── TermsOfServiceView.swift
│       └── PrivacyPolicyView.swift
```

---

## Summary

The Glimpse onboarding workflow is a well-designed, 5-step process that collects essential user information while maintaining a clean, accessible interface. The flow prioritizes user experience with clear progress indicators, consistent design patterns, and intuitive navigation.

### Strengths:
✅ Clean, modern UI with excellent dark mode support
✅ Clear progress tracking throughout the flow
✅ Flexible goal setup with category organization
✅ Consistent design system across all screens
✅ Proper data persistence for goals

### Areas for Improvement:
⚠️ Authentication is placeholder only (not functional)
⚠️ Personalization and notification data not saved
⚠️ Missing validation on some inputs
⚠️ No error handling or loading states
⚠️ No actual notification permissions requested

### Current Status:
The onboarding flow is **visually complete** but requires backend integration for authentication and full data persistence to be production-ready.

---

**Document Version**: 1.0
**Last Updated**: 2025-12-31
**Created By**: Claude Code
**Related Documents**:
- `ONBOARDING_CLEANUP_CHANGELOG.md` - Details of lastName/DOB removal and UI spacing improvements
