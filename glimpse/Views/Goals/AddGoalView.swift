import SwiftUI

struct AddGoalView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var onSave: (Goal) -> Void

    @State private var title: String = ""
    @State private var selectedCategory: GoalCategory = .personal
    @State private var isSaving = false

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

                    Text("Add Goal")
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
                            Text("Add")
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
                            Text("What's your goal?")
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
                            Text("Choose a category")
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

        let newGoal = Goal(
            title: title.trimmingCharacters(in: .whitespaces),
            category: selectedCategory
        )

        // Small delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSave(newGoal)
            dismiss()
        }
    }
}

#Preview("Light Mode") {
    AddGoalView(onSave: { _ in })
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    AddGoalView(onSave: { _ in })
        .preferredColorScheme(.dark)
}
