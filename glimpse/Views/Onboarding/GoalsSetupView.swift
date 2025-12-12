import SwiftUI

struct GoalsSetupView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject private var storageManager = GoalStorageManager.shared

    @State private var goals: [Goal] = []
    @State private var goalTitle: String = ""
    @State private var selectedCategory: GoalCategory = .personal
    @State private var showingCategoryPicker = false

    private let maxGoals = 3
    private let maxTitleLength = 50

    var body: some View {
        ZStack {
            // Background color
            (colorScheme == .dark ?
             Color(red: 0.11, green: 0.12, blue: 0.15) :
                Color(red: 1.0, green: 0.97, blue: 0.94))
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with back button and logo
                HStack {
                    // Back button
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                    }

                    Spacer()

                    // App name with logo (centered)
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

                    // Invisible placeholder to balance layout
                    Image(systemName: "arrow.left")
                        .font(.system(size: 24))
                        .opacity(0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // Progress dots (5 dots, 4th active)
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(colorScheme == .dark ?
                              Color(red: 0.35, green: 0.58, blue: 1.0) :
                                Color(red: 0.83, green: 0.58, blue: 0.49))
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
                .padding(.bottom, 40)

                // Title and subtitle
                VStack(spacing: 12) {
                    Text("What are your goals?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                        .multilineTextAlignment(.center)

                    Text("Add up to 3 goals to track and reflect on daily.")
                        .font(.system(size: 17))
                        .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 32)

                ScrollView {
                    VStack(spacing: 16) {
                        // Display added goals
                        ForEach(goals) { goal in
                            HStack(spacing: 12) {
                                // Category icon
                                ZStack {
                                    Circle()
                                        .fill(goal.category.color(for: colorScheme))
                                        .frame(width: 44, height: 44)

                                    Image(systemName: goal.category.icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }

                                // Goal info
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(goal.title)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                                    Text(goal.category.rawValue)
                                        .font(.system(size: 13))
                                        .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                }

                                Spacer()

                                // Delete button
                                Button(action: {
                                    withAnimation {
                                        goals.removeAll { $0.id == goal.id }
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16))
                                        .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.4))
                                }
                            }
                            .padding(16)
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

                        // Add goal form (show if less than max goals)
                        if goals.count < maxGoals {
                            VStack(spacing: 16) {
                                // Goal title input
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Goal")
                                            .font(.system(size: 15))
                                            .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))

                                        Spacer()

                                        Text("\(goalTitle.count)/\(maxTitleLength)")
                                            .font(.system(size: 13))
                                            .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.4))
                                    }

                                    TextField("e.g., Exercise daily", text: $goalTitle)
                                        .font(.system(size: 17))
                                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(colorScheme == .dark ?
                                                      Color(red: 0.15, green: 0.18, blue: 0.24) :
                                                        Color.white.opacity(0.5))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
                                                )
                                        )
                                        .onChange(of: goalTitle) { oldValue, newValue in
                                            if newValue.count > maxTitleLength {
                                                goalTitle = String(newValue.prefix(maxTitleLength))
                                            }
                                        }
                                }

                                // Category selection
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Category")
                                        .font(.system(size: 15))
                                        .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))

                                    Button(action: {
                                        showingCategoryPicker = true
                                    }) {
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .fill(selectedCategory.color(for: colorScheme))
                                                    .frame(width: 32, height: 32)

                                                Image(systemName: selectedCategory.icon)
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.white)
                                            }

                                            Text(selectedCategory.rawValue)
                                                .font(.system(size: 17))
                                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14))
                                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.4))
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(colorScheme == .dark ?
                                                      Color(red: 0.15, green: 0.18, blue: 0.24) :
                                                        Color.white.opacity(0.5))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
                                                )
                                        )
                                    }
                                }

                                // Add Goal button
                                Button(action: addGoal) {
                                    Text("Add Goal")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 52)
                                        .background(
                                            RoundedRectangle(cornerRadius: 26)
                                                .fill(colorScheme == .dark ?
                                                      Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                        Color(red: 0.83, green: 0.58, blue: 0.49))
                                        )
                                }
                                .disabled(goalTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                                .opacity(goalTitle.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
                            }
                            .padding(.top, 8)
                        } else {
                            // Max goals message
                            Text("You can track up to 3 goals")
                                .font(.system(size: 15))
                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 16)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                // Continue button
                ZStack {
                    NavigationLink(destination: DashboardView()) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold))
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
                    .disabled(goals.isEmpty)
                    .opacity(goals.isEmpty ? 0.5 : 1.0)
                    .simultaneousGesture(TapGesture().onEnded {
                        saveGoalsAndCompleteOnboarding()
                    })
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingCategoryPicker) {
            CategoryPickerView(selectedCategory: $selectedCategory)
        }
    }

    // MARK: - Actions

    private func addGoal() {
        let trimmedTitle = goalTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty, goals.count < maxGoals else { return }

        let newGoal = Goal(
            title: trimmedTitle,
            category: selectedCategory
        )

        withAnimation {
            goals.append(newGoal)
        }

        // Reset form
        goalTitle = ""
        selectedCategory = .personal
    }

    private func saveGoalsAndCompleteOnboarding() {
        guard !goals.isEmpty else { return }

        storageManager.saveGoals(goals)
        storageManager.completeOnboarding()
    }
}

#Preview("Light Mode") {
    GoalsSetupView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    GoalsSetupView()
        .preferredColorScheme(.dark)
}
