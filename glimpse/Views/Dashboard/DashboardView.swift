import SwiftUI

struct DashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var storageManager = GoalStorageManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                (colorScheme == .dark ?
                 Color(red: 0.11, green: 0.12, blue: 0.15) :
                    Color(red: 1.0, green: 0.97, blue: 0.94))
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        // App name with logo
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ?
                                          Color(red: 0.35, green: 0.58, blue: 1.0) :
                                            Color(red: 0.83, green: 0.58, blue: 0.49))
                                    .frame(width: 44, height: 44)

                                Image(systemName: "book.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }

                            Text("Glimpse")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                        }

                        Spacer()

                        // Settings button (placeholder for future)
                        Button(action: {
                            // Future: Navigate to settings
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 32)

                    // Goals section
                    if storageManager.goals.isEmpty {
                        // Empty state
                        VStack(spacing: 24) {
                            Spacer()

                            // Illustration
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .dark ?
                                          Color(red: 0.15, green: 0.18, blue: 0.24) :
                                            Color.white.opacity(0.5))
                                    .frame(width: 120, height: 120)

                                Image(systemName: "target")
                                    .font(.system(size: 60))
                                    .foregroundColor(colorScheme == .dark ?
                                                     Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                        Color(red: 0.83, green: 0.58, blue: 0.49))
                            }

                            VStack(spacing: 12) {
                                Text("No goals yet")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                                Text("Add your first goal to start tracking your progress")
                                    .font(.system(size: 17))
                                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }

                            Spacer()
                        }
                    } else {
                        // Goals list
                        ScrollView {
                            VStack(spacing: 0) {
                                // Section header
                                HStack {
                                    Text("Your Goals")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                                    Spacer()

                                    Text("\(storageManager.goals.count)/3")
                                        .font(.system(size: 17))
                                        .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 20)

                                // Goal cards
                                VStack(spacing: 16) {
                                    ForEach(storageManager.goals) { goal in
                                        GoalCardView(goal: goal)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 24)
                            }
                        }
                    }

                    // Add goal button (if less than 3 goals) - placeholder for future
                    if storageManager.goals.count < 3 && !storageManager.goals.isEmpty {
                        Button(action: {
                            // Future: Navigate to add goal screen
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))

                                Text("Add Another Goal")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(colorScheme == .dark ?
                                             Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                Color(red: 0.83, green: 0.58, blue: 0.49))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 26)
                                    .fill(colorScheme == .dark ?
                                          Color(red: 0.15, green: 0.18, blue: 0.24) :
                                            Color.white.opacity(0.5))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 26)
                                            .stroke(colorScheme == .dark ?
                                                    Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                        Color(red: 0.83, green: 0.58, blue: 0.49), lineWidth: 2)
                                    )
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 50)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview("Light Mode - With Goals") {
    let storageManager = GoalStorageManager.shared
    storageManager.saveGoals([
        Goal(title: "Exercise daily", category: .health),
        Goal(title: "Read 12 books this year", category: .learning),
        Goal(title: "Build better relationships", category: .relationships)
    ])

    return DashboardView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode - With Goals") {
    let storageManager = GoalStorageManager.shared
    storageManager.saveGoals([
        Goal(title: "Exercise daily", category: .health),
        Goal(title: "Read 12 books this year", category: .learning)
    ])

    return DashboardView()
        .preferredColorScheme(.dark)
}

#Preview("Empty State") {
    let storageManager = GoalStorageManager.shared
    storageManager.saveGoals([])

    return DashboardView()
        .preferredColorScheme(.light)
}
