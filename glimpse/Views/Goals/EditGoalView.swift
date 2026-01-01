import SwiftUI

struct EditGoalView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    let goal: Goal
    var onSave: (Goal) -> Void

    @State private var title: String
    @State private var selectedCategory: GoalCategory
    @State private var isSaving = false

    init(goal: Goal, onSave: @escaping (Goal) -> Void) {
        self.goal = goal
        self.onSave = onSave
        _title = State(initialValue: goal.title)
        _selectedCategory = State(initialValue: goal.category)
    }

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
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            .frame(width: 32, height: 32)
                    }

                    Spacer()

                    Text("Edit Goal")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                    Spacer()

                    Button(action: {
                        saveGoal()
                    }) {
                        if isSaving {
                            ProgressView()
                                .tint(colorScheme == .dark ?
                                      Color(red: 0.35, green: 0.58, blue: 1.0) :
                                        Color(red: 0.83, green: 0.58, blue: 0.49))
                        } else {
                            Text("Save")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ?
                                                 Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                    Color(red: 0.83, green: 0.58, blue: 0.49))
                        }
                    }
                    .disabled(isSaving || title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity((isSaving || title.trimmingCharacters(in: .whitespaces).isEmpty) ? 0.5 : 1.0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 32)

                ScrollView {
                    VStack(spacing: 32) {
                        // Category icon preview
                        ZStack {
                            Circle()
                                .fill(selectedCategory.color(for: colorScheme))
                                .frame(width: 100, height: 100)

                            Image(systemName: selectedCategory.icon)
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 16)

                        // Goal title input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Goal Title")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                .padding(.horizontal, 24)

                            TextField("Enter your goal", text: $title, axis: .vertical)
                                .font(.system(size: 17))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineLimit(3, reservesSpace: false)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(colorScheme == .dark ?
                                              Color(red: 0.15, green: 0.18, blue: 0.24) :
                                                Color.white.opacity(0.5))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 24)
                        }

                        // Category selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                .padding(.horizontal, 24)

                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(GoalCategory.allCases, id: \.self) { category in
                                    CategoryButton(
                                        category: category,
                                        isSelected: selectedCategory == category,
                                        colorScheme: colorScheme
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedCategory = category
                                        }
                                        // Haptic feedback
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func saveGoal() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isSaving = true

        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        var updatedGoal = goal
        updatedGoal.title = title.trimmingCharacters(in: .whitespaces)
        updatedGoal.category = selectedCategory
        updatedGoal.updatedAt = Date()

        // Small delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSave(updatedGoal)
            dismiss()
        }
    }
}

// Category button component
struct CategoryButton: View {
    let category: GoalCategory
    let isSelected: Bool
    let colorScheme: ColorScheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(category.color(for: colorScheme))
                        .frame(width: 48, height: 48)

                    Image(systemName: category.icon)
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }

                Text(category.rawValue)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ?
                          Color(red: 0.15, green: 0.18, blue: 0.24) :
                            Color.white.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ?
                            (colorScheme == .dark ?
                             Color(red: 0.35, green: 0.58, blue: 1.0) :
                                Color(red: 0.83, green: 0.58, blue: 0.49)) :
                            (colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isSelected ? 1.0 : 0.98)
        }
    }
}

#Preview("Light Mode") {
    EditGoalView(
        goal: Goal(title: "Exercise daily", category: .health),
        onSave: { _ in }
    )
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    EditGoalView(
        goal: Goal(title: "Read 12 books this year", category: .learning),
        onSave: { _ in }
    )
    .preferredColorScheme(.dark)
}
