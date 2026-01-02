import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject private var storageManager = GoalStorageManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showLogoutConfirmation = false
    @State private var isLoggingOut = false
    @State private var showWelcomeScreen = false
    @State private var showPremiumUpgrade = false
    @State private var isSchedulingTest = false
    @State private var testNotificationScheduled = false
    @State private var testCountdown: Int = 0
    @State private var countdownTimer: Timer?
    @State private var showTestError = false
    @State private var testErrorMessage: String?

    var body: some View {
        ZStack {
            // Background color
            (colorScheme == .dark ?
             Color(red: 0.11, green: 0.12, blue: 0.15) :
                Color(red: 1.0, green: 0.97, blue: 0.94))
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                    }

                    Spacer()

                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                    Spacer()

                    // Invisible placeholder to balance layout
                    Image(systemName: "arrow.left")
                        .font(.system(size: 24))
                        .opacity(0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 32)

                ScrollView {
                    VStack(spacing: 24) {
                        // Account Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Account")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                .textCase(.uppercase)
                                .padding(.horizontal, 24)

                            VStack(spacing: 0) {
                                NavigationLink(destination: AccountSettingsView()) {
                                    SettingsRowView(
                                        icon: "person.circle.fill",
                                        title: "Profile",
                                        showChevron: true
                                    )
                                }

                                Divider()
                                    .background((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1))
                                    .padding(.leading, 68)

                                NavigationLink(destination: EmailPasswordSettingsView()) {
                                    SettingsRowView(
                                        icon: "envelope.fill",
                                        title: "Email & Password",
                                        showChevron: true
                                    )
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ?
                                          Color(red: 0.15, green: 0.18, blue: 0.24) :
                                            Color.white.opacity(0.5))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
                        }

                        // Notifications Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notifications")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                .textCase(.uppercase)
                                .padding(.horizontal, 24)

                            VStack(spacing: 0) {
                                NavigationLink(destination: NotificationSettingsView()) {
                                    SettingsRowView(
                                        icon: "bell.fill",
                                        title: "Notification Settings",
                                        showChevron: true
                                    )
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ?
                                          Color(red: 0.15, green: 0.18, blue: 0.24) :
                                            Color.white.opacity(0.5))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
                        }

                        // Test Notifications Section (Debug)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🧪 Developer Tools")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                .textCase(.uppercase)
                                .padding(.horizontal, 24)

                            VStack(spacing: 16) {
                                if testNotificationScheduled && testCountdown > 0 {
                                    // Countdown display
                                    VStack(spacing: 12) {
                                        Text("Test Notification Scheduled")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                                        Text("Firing in...")
                                            .font(.system(size: 13))
                                            .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))

                                        Text("\(testCountdown)s")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(colorScheme == .dark ?
                                                             Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                             Color(red: 0.83, green: 0.58, blue: 0.49))
                                            .monospacedDigit()

                                        Text("Put app in background or close it to test")
                                            .font(.system(size: 12))
                                            .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 16)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                } else {
                                    Button(action: scheduleTestNotification) {
                                        HStack(spacing: 12) {
                                            if isSchedulingTest {
                                                ProgressView()
                                                    .tint(colorScheme == .dark ?
                                                          Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                          Color(red: 0.83, green: 0.58, blue: 0.49))
                                                    .scaleEffect(0.9)
                                            } else {
                                                Image(systemName: "bell.badge.fill")
                                                    .font(.system(size: 18))
                                            }

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Test Notification (15s)")
                                                    .font(.system(size: 16, weight: .semibold))

                                                Text("Schedule a test notification")
                                                    .font(.system(size: 13))
                                                    .opacity(0.7)
                                            }

                                            Spacer()

                                            Image(systemName: "arrow.right.circle.fill")
                                                .font(.system(size: 20))
                                                .opacity(0.6)
                                        }
                                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 16)
                                    }
                                    .disabled(isSchedulingTest)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ?
                                          Color(red: 0.15, green: 0.18, blue: 0.24) :
                                            Color.white.opacity(0.5))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
                        }

                        // Premium Section
                        if storageManager.userTier == .free {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Premium")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                    .textCase(.uppercase)
                                    .padding(.horizontal, 24)

                                Button(action: {
                                    showPremiumUpgrade = true
                                }) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [
                                                            colorScheme == .dark ?
                                                                Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                                Color(red: 0.83, green: 0.58, blue: 0.49),
                                                            colorScheme == .dark ?
                                                                Color(red: 0.45, green: 0.65, blue: 1.0) :
                                                                Color(red: 0.73, green: 0.48, blue: 0.39)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 44, height: 44)

                                            Image(systemName: "crown.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(.white)
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Upgrade to Premium")
                                                .font(.system(size: 17, weight: .semibold))
                                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                                            Text("Unlock 10 goals and more")
                                                .font(.system(size: 14))
                                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.4))
                                    }
                                    .padding(.horizontal, 24)
                                    .frame(height: 56)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(colorScheme == .dark ?
                                              Color(red: 0.15, green: 0.18, blue: 0.24) :
                                                Color.white.opacity(0.5))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    colorScheme == .dark ?
                                                        Color(red: 0.35, green: 0.58, blue: 1.0).opacity(0.5) :
                                                        Color(red: 0.83, green: 0.58, blue: 0.49).opacity(0.5),
                                                    colorScheme == .dark ?
                                                        Color(red: 0.45, green: 0.65, blue: 1.0).opacity(0.5) :
                                                        Color(red: 0.73, green: 0.48, blue: 0.39).opacity(0.5)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .padding(.horizontal, 24)
                            }
                        } else {
                            // Premium badge for premium users
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Premium")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                    .textCase(.uppercase)
                                    .padding(.horizontal, 24)

                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        colorScheme == .dark ?
                                                            Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                            Color(red: 0.83, green: 0.58, blue: 0.49),
                                                        colorScheme == .dark ?
                                                            Color(red: 0.45, green: 0.65, blue: 1.0) :
                                                            Color(red: 0.73, green: 0.48, blue: 0.39)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 44, height: 44)

                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Premium Member")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                                        Text("Thank you for your support")
                                            .font(.system(size: 14))
                                            .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                    }

                                    Spacer()
                                }
                                .padding(.horizontal, 24)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(colorScheme == .dark ?
                                              Color(red: 0.15, green: 0.18, blue: 0.24) :
                                                Color.white.opacity(0.5))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    colorScheme == .dark ?
                                                        Color(red: 0.35, green: 0.58, blue: 1.0).opacity(0.5) :
                                                        Color(red: 0.83, green: 0.58, blue: 0.49).opacity(0.5),
                                                    colorScheme == .dark ?
                                                        Color(red: 0.45, green: 0.65, blue: 1.0).opacity(0.5) :
                                                        Color(red: 0.73, green: 0.48, blue: 0.39).opacity(0.5)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .padding(.horizontal, 24)
                            }
                        }

                        // Logout Button
                        Button(action: {
                            showLogoutConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)
                                    .frame(width: 44, height: 44)

                                Text("Log Out")
                                    .font(.system(size: 17))
                                    .foregroundColor(.red)

                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ?
                                          Color(red: 0.15, green: 0.18, blue: 0.24) :
                                            Color.white.opacity(0.5))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Log Out", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                logout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .fullScreenCover(isPresented: $showWelcomeScreen) {
            ContentView()
        }
        .sheet(isPresented: $showPremiumUpgrade) {
            PremiumUpgradeView()
        }
        .alert("Test Notification Error", isPresented: $showTestError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(testErrorMessage ?? "Failed to schedule test notification")
        }
        .onDisappear {
            // Clean up timer when view disappears
            countdownTimer?.invalidate()
            countdownTimer = nil
        }
    }

    // MARK: - Test Notification Functions

    private func scheduleTestNotification() {
        isSchedulingTest = true

        Task {
            let success = await notificationManager.sendTestNotification()

            await MainActor.run {
                isSchedulingTest = false

                if success {
                    // Start countdown
                    testNotificationScheduled = true
                    testCountdown = 15
                    startCountdownTimer()
                } else {
                    testErrorMessage = "Failed to schedule test notification. Please check notification permissions in Settings."
                    showTestError = true
                }
            }
        }
    }

    private func startCountdownTimer() {
        // Cancel any existing timer
        countdownTimer?.invalidate()

        // Create new timer that fires every second
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if testCountdown > 0 {
                testCountdown -= 1
            } else {
                // Countdown finished
                countdownTimer?.invalidate()
                countdownTimer = nil

                // Reset after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    testNotificationScheduled = false
                    testCountdown = 0
                }
            }
        }
    }

    // MARK: - Logout Function

    private func logout() {
        isLoggingOut = true

        Task {
            do {
                try await SupabaseManager.shared.signOut()

                await MainActor.run {
                    // Clear local data
                    storageManager.goals = []
                    storageManager.isLoadingGoals = false
                    UserDefaults.standard.set(false, forKey: "glimpse.onboarding.complete")

                    isLoggingOut = false

                    // Show welcome screen (ContentView)
                    showWelcomeScreen = true
                }
            } catch {
                await MainActor.run {
                    isLoggingOut = false
                    print("Error logging out: \(error)")
                }
            }
        }
    }
}

// MARK: - Settings Row Component

struct SettingsRowView: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let showChevron: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(colorScheme == .dark ?
                                 Color(red: 0.35, green: 0.58, blue: 1.0) :
                                    Color(red: 0.83, green: 0.58, blue: 0.49))
                .frame(width: 44, height: 44)

            Text(title)
                .font(.system(size: 17))
                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.4))
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 56)
        .contentShape(Rectangle())
    }
}

#Preview("Light Mode") {
    NavigationStack {
        SettingsView()
            .preferredColorScheme(.light)
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}
