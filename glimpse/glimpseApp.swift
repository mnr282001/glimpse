//
//  glimpseApp.swift
//  glimpse
//
//  Created by Nayeb Rehmat on 11/17/25.
//

import SwiftUI

// Onboarding state enum
enum OnboardingState {
    case notStarted           // No account yet
    case needsPersonalization // Has account, needs to complete personalization
    case needsNotifications   // Has personalization, needs notification settings
    case needsGoals          // Has notifications, needs to set goals
    case completed           // Fully onboarded
}

// Loading view that respects color scheme
struct LoadingView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            (colorScheme == .dark ?
             Color(red: 0.11, green: 0.12, blue: 0.15) :
                Color(red: 1.0, green: 0.97, blue: 0.94))
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Logo
                ZStack {
                    Circle()
                        .fill(colorScheme == .dark ?
                              Color(red: 0.35, green: 0.58, blue: 1.0) :
                                Color(red: 0.83, green: 0.58, blue: 0.49))
                        .frame(width: 80, height: 80)

                    Image(systemName: "book.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }

                Text("Glimpse")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                ProgressView()
                    .tint(colorScheme == .dark ?
                          Color(red: 0.35, green: 0.58, blue: 1.0) :
                            Color(red: 0.83, green: 0.58, blue: 0.49))
            }
        }
    }
}

@main
struct glimpseApp: App {
    @StateObject private var storageManager = GoalStorageManager.shared
    @State private var isCheckingSession = true
    @State private var hasActiveSession = false
    @State private var onboardingState: OnboardingState = .notStarted

    // MARK: - Debug Settings
    // Set to true to reset onboarding on every app launch (for testing)
    private let resetOnboardingOnLaunch = false

    init() {
        // Reset onboarding for testing if flag is enabled
        if resetOnboardingOnLaunch {
            UserDefaults.standard.set(false, forKey: "glimpse.onboarding.complete")
            UserDefaults.standard.removeObject(forKey: "glimpse.user.goals")
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isCheckingSession {
                    // Show loading screen while checking session
                    LoadingView()
                } else {
                    // Show appropriate view based on onboarding state
                    NavigationStack {
                        Group {
                            switch onboardingState {
                            case .notStarted, .needsPersonalization, .needsNotifications, .needsGoals:
                                // Always show ContentView for incomplete onboarding
                                // User will sign in/up and resume from their last step
                                ContentView()
                            case .completed:
                                DashboardView()
                                    .onAppear {
                                        storageManager.loadGoals()
                                    }
                            }
                        }
                    }
                }
            }
            .task {
                await checkSession()
            }
        }
    }

    // MARK: - Session Management

    private func checkSession() async {
        do {
            _ = try await SupabaseManager.shared.client.auth.session

            // User has active session, check their onboarding progress
            let state = await checkOnboardingProgress()

            // If state is nil, session is invalid - sign out
            if state == nil {
                try? await SupabaseManager.shared.signOut()
                await MainActor.run {
                    hasActiveSession = false
                    onboardingState = .notStarted
                    isCheckingSession = false
                }
                return
            }

            await MainActor.run {
                hasActiveSession = true
                onboardingState = state!
                isCheckingSession = false
            }
        } catch {
            // No active session
            await MainActor.run {
                hasActiveSession = false
                onboardingState = .notStarted
                isCheckingSession = false
            }
        }
    }

    private func checkOnboardingProgress() async -> OnboardingState? {
        do {
            let userId = try await SupabaseManager.shared.client.auth.session.user.id

            // 1. Check if user has profile with first_name
            struct ProfileResponse: Decodable {
                let first_name: String?
            }

            let profileResponse: [ProfileResponse] = try await SupabaseManager.shared.client
                .database
                .from("profiles")
                .select("first_name")
                .eq("id", value: userId.uuidString)
                .execute()
                .value

            // If no profile record exists at all, the user was deleted or doesn't exist
            // This means the session is invalid
            guard !profileResponse.isEmpty else {
                print("No profile found for user - session is invalid")
                return nil
            }

            // Profile exists - check if first_name is populated
            guard let profile = profileResponse.first,
                  let firstName = profile.first_name,
                  !firstName.isEmpty else {
                print("Profile exists but first_name is missing - needs personalization")
                return .needsPersonalization
            }

            // 2. Check if user has notification settings
            struct NotificationResponse: Decodable {
                let id: String
            }

            let notificationResponse: [NotificationResponse] = try await SupabaseManager.shared.client
                .database
                .from("notification_settings")
                .select("id")
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value

            guard !notificationResponse.isEmpty else {
                return .needsNotifications
            }

            // 3. Check if user has goals
            struct GoalResponse: Decodable {
                let id: String
            }

            let goalsResponse: [GoalResponse] = try await SupabaseManager.shared.client
                .database
                .from("goals")
                .select("id")
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value

            guard !goalsResponse.isEmpty else {
                return .needsGoals
            }

            // User has completed all onboarding steps
            await MainActor.run {
                storageManager.completeOnboarding() // Sync local flag
            }
            return .completed

        } catch {
            print("Error checking onboarding progress: \(error)")
            // Return nil to indicate session is invalid (user deleted, auth error, etc.)
            return nil
        }
    }
}
