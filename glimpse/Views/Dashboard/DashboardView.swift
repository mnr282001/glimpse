import SwiftUI

struct DashboardView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var storageManager = GoalStorageManager.shared
    @StateObject private var reflectionManager = ReflectionManager.shared
    @State private var navigateToSettings = false
    @State private var selectedGoalForSheet: Goal?
    @State private var goalToEdit: Goal?
    @State private var showEditView = false
    @State private var showDeleteConfirmation = false
    @State private var goalToDelete: Goal?
    @State private var showAddGoalView = false
    @State private var showPremiumUpgrade = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showComingSoon = false
    
    // MARK: - CTA Styling Helpers

    private var accentColor: Color {
        colorScheme == .dark
        ? Color(red: 0.35, green: 0.58, blue: 1.0)
        : Color(red: 0.83, green: 0.58, blue: 0.49)
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17)
    }

    private var secondaryTextColor: Color {
        primaryTextColor.opacity(0.6)
    }

    private var cardBackgroundColor: Color {
        colorScheme == .dark ?
            Color(red: 0.15, green: 0.18, blue: 0.24) :
            Color.white.opacity(0.7)
    }

    private var addButtonBackground: some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(colorScheme == .dark
                  ? Color(red: 0.15, green: 0.18, blue: 0.24)
                  : Color.white.opacity(0.5))
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(accentColor, lineWidth: 2)
            )
    }

    private var upgradeButtonBackground: some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(accentColor.opacity(colorScheme == .dark ? 0.25 : 0.15))
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(accentColor, lineWidth: 2)
            )
    }

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

                        // Settings button
                        Button(action: {
                            navigateToSettings = true
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
                    if storageManager.isLoadingGoals {
                        // Loading state
                        VStack {
                            Spacer()

                            ProgressView()
                                .tint(colorScheme == .dark ?
                                      Color(red: 0.35, green: 0.58, blue: 1.0) :
                                        Color(red: 0.83, green: 0.58, blue: 0.49))
                                .scaleEffect(1.5)

                            Spacer()
                        }
                    } else if storageManager.goals.isEmpty {
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
                            // Add Goal Button
                            Button(action: {
                                showAddGoalView = true // Simply show add goal view
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))

                                    Text("Add Your First Goal")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(colorScheme == .dark ?
                                              Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                Color(red: 0.83, green: 0.58, blue: 0.49))
                                )
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)

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

                                    Text("\(storageManager.goals.count)/\(storageManager.maxGoals)")
                                        .font(.system(size: 17))
                                        .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 20)

                                // Goal cards
                                VStack(spacing: 16) {
                                    ForEach(storageManager.goals) { goal in
                                        GoalCardView(
                                            goal: goal,
                                            onTap: {
                                                selectedGoalForSheet = goal
                                            },
                                            onEdit: {
                                                goalToEdit = goal
                                                showEditView = true
                                            },
                                            onDelete: {
                                                goalToDelete = goal
                                                showDeleteConfirmation = true
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 16)

                                // Today's reflection status
                                VStack(spacing: 16) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Today's Reflections")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(primaryTextColor)

                                            if reflectionManager.allGoalsCompleted(for: storageManager.goals) {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                    Text("All complete! 🎉")
                                                        .font(.system(size: 14))
                                                        .foregroundColor(secondaryTextColor)
                                                }
                                            } else {
                                                let percentage = reflectionManager.completionPercentage(for: storageManager.goals)
                                                let completed = Int(Double(storageManager.goals.count) * percentage)
                                                let total = storageManager.goals.count

                                                Text("\(completed)/\(total) goals reflected on")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(secondaryTextColor)
                                            }
                                        }

                                        Spacer()

                                        // Reflect button
                                        NavigationLink(destination: DailyReflectionsView()) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "pencil.circle.fill")
                                                Text(reflectionManager.allGoalsCompleted(for: storageManager.goals) ? "Review" : "Reflect")
                                            }
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 12)
                                            .background(accentColor)
                                            .cornerRadius(20)
                                        }
                                    }
                                    .padding(16)
                                    .background(cardBackgroundColor)
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 24)
                            }
                        }
                    }

                    // Add goal button - always show but behavior depends on tier
                    if !storageManager.goals.isEmpty {
                        Button(action: {
                            if storageManager.isAtFreeLimit {
                                showComingSoon = true
                            } else if storageManager.canAddGoal {
                                showAddGoalView = true
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: storageManager.canAddGoal ? "plus.circle.fill" : "crown.fill")
                                    .font(.system(size: 20))

                                Text(storageManager.canAddGoal ? "Add Another Goal" : "Premium Coming Soon")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(accentColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(addButtonBackground)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 50)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToSettings) {
                SettingsView()
            }
            .sheet(item: $selectedGoalForSheet) { goal in
                GoalActionSheet(
                    goal: goal,
                    onEdit: {
                        selectedGoalForSheet = nil
                        goalToEdit = goal
                        showEditView = true
                    },
                    onDelete: {
                        selectedGoalForSheet = nil
                        goalToDelete = goal
                        showDeleteConfirmation = true
                    }
                )
            }
            .sheet(isPresented: $showEditView) {
                if let goal = goalToEdit {
                    EditGoalView(goal: goal) { updatedGoal in
                        Task {
                            await storageManager.updateGoal(updatedGoal)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddGoalView) {
                AddGoalView { newGoal in
                    Task {
                        do {
                            try await storageManager.addGoal(newGoal)
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showPremiumUpgrade) {
                PremiumUpgradeView()
            }
            .sheet(isPresented: $showComingSoon) {
                PremiumComingSoonView()
            }
            .alert("Delete Goal", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    goalToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let goal = goalToDelete {
                        Task {
                            await storageManager.deleteGoal(goal)
                        }
                    }
                    goalToDelete = nil
                }
            } message: {
                if let goal = goalToDelete {
                    Text("Are you sure you want to delete \"\(goal.title)\"? This action cannot be undone.")
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An error occurred")
            }
            .task {
                // Load user tier when view appears
                await storageManager.loadUserTier()
                // Load today's reflections
                await reflectionManager.loadTodayReflections(for: storageManager.goals)
            }
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
