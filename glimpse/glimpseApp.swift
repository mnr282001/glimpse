//
//  glimpseApp.swift
//  glimpse
//
//  Created by Nayeb Rehmat on 11/17/25.
//

import SwiftUI

@main
struct glimpseApp: App {
    @StateObject private var storageManager = GoalStorageManager.shared
    @State private var isCheckingSession = true
    @State private var hasActiveSession = false

    // MARK: - Debug Settings
    // Set to true to reset onboarding on every app launch (for testing)
    private let resetOnboardingOnLaunch = true

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
                    ZStack {
                        Color(red: 1.0, green: 0.97, blue: 0.94)
                            .ignoresSafeArea()

                        VStack(spacing: 20) {
                            // Logo
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.83, green: 0.58, blue: 0.49))
                                    .frame(width: 80, height: 80)

                                Image(systemName: "book.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }

                            Text("Glimpse")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(red: 0.17, green: 0.17, blue: 0.17))

                            ProgressView()
                                .tint(Color(red: 0.83, green: 0.58, blue: 0.49))
                        }
                    }
                } else if hasActiveSession && storageManager.isOnboardingComplete {
                    DashboardView()
                        .onAppear {
                            // Load goals when dashboard appears
                            storageManager.loadGoals()
                        }
                } else {
                    ContentView()
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
            let session = try await SupabaseManager.shared.client.auth.session
            await MainActor.run {
                hasActiveSession = true
                isCheckingSession = false
            }
        } catch {
            await MainActor.run {
                hasActiveSession = false
                isCheckingSession = false
            }
        }
    }
}
