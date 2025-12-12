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
            if storageManager.isOnboardingComplete {
                DashboardView()
            } else {
                ContentView()
            }
        }
    }
}
