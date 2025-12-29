import SwiftUI

struct ReflectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject private var storageManager = GoalStorageManager.shared

    @State private var currentIndex: Int = 0
    @State private var answers: [UUID: (closer: String, further: String)] = [:]
    @State private var isSubmitting: Bool = false

    private let reflectionDate: Date
    private var goals: [Goal] { storageManager.goals }

    init(reflectionDate: Date = Date()) {
        self.reflectionDate = reflectionDate
    }

    var body: some View {
        ZStack {
            // Background
            (colorScheme == .dark ?
             Color(red: 0.11, green: 0.12, blue: 0.15) :
                Color(red: 1.0, green: 0.97, blue: 0.94))
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                    }

                    Spacer()

                    Text("Daily Reflection")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                    Spacer()

                    // Invisible placeholder
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .opacity(0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)

                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<goals.count, id: \.self) { index in
                        Capsule()
                            .fill(index <= currentIndex ?
                                  (colorScheme == .dark ?
                                   Color(red: 0.35, green: 0.58, blue: 1.0) :
                                    Color(red: 0.83, green: 0.58, blue: 0.49)) :
                                    Color.gray.opacity(0.3))
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                // Card pager
                TabView(selection: $currentIndex) {
                    ForEach(Array(goals.enumerated()), id: \.element.id) { index, goal in
                        ReflectionCardView(
                            goal: goal,
                            closerAnswer: Binding(
                                get: { answers[goal.id]?.closer ?? "" },
                                set: { newValue in
                                    if answers[goal.id] == nil {
                                        answers[goal.id] = ("", "")
                                    }
                                    answers[goal.id]?.closer = newValue
                                }
                            ),
                            furtherAnswer: Binding(
                                get: { answers[goal.id]?.further ?? "" },
                                set: { newValue in
                                    if answers[goal.id] == nil {
                                        answers[goal.id] = ("", "")
                                    }
                                    answers[goal.id]?.further = newValue
                                }
                            ),
                            colorScheme: colorScheme
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Navigation buttons
                HStack(spacing: 16) {
                    if currentIndex > 0 {
                        Button(action: { withAnimation { currentIndex -= 1 } }) {
                            Text("Previous")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(colorScheme == .dark ?
                                                 Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                    Color(red: 0.83, green: 0.58, blue: 0.49))
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 26)
                                        .stroke(colorScheme == .dark ?
                                                Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                    Color(red: 0.83, green: 0.58, blue: 0.49), lineWidth: 2)
                                )
                        }
                    }

                    if currentIndex < goals.count - 1 {
                        Button(action: {
                            withAnimation { currentIndex += 1 }
                        }) {
                            Text("Next")
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
                        .disabled(!currentAnswersValid)
                        .opacity(currentAnswersValid ? 1.0 : 0.5)
                    } else {
                        Button(action: submitReflections) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                            } else {
                                Text("Submit")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 26)
                                .fill(colorScheme == .dark ?
                                      Color(red: 0.35, green: 0.58, blue: 1.0) :
                                        Color(red: 0.83, green: 0.58, blue: 0.49))
                        )
                        .disabled(!allAnswersValid || isSubmitting)
                        .opacity(allAnswersValid && !isSubmitting ? 1.0 : 0.5)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Validation

    private var currentAnswersValid: Bool {
        guard currentIndex < goals.count else { return false }
        let goal = goals[currentIndex]
        guard let answers = answers[goal.id] else { return false }
        return !answers.closer.trimmingCharacters(in: .whitespaces).isEmpty &&
               !answers.further.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var allAnswersValid: Bool {
        return goals.allSatisfy { goal in
            guard let answers = answers[goal.id] else { return false }
            return !answers.closer.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !answers.further.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    // MARK: - Actions

    private func submitReflections() {
        isSubmitting = true

        // Create reflections for each goal
        for goal in goals {
            guard let answers = answers[goal.id] else { continue }

            let reflection = Reflection(
                goalId: goal.id,
                date: reflectionDate,
                closerAnswer: answers.closer.trimmingCharacters(in: .whitespaces),
                furtherAnswer: answers.further.trimmingCharacters(in: .whitespaces)
            )

            storageManager.addReflection(reflection)
        }

        // Small delay for UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSubmitting = false
            dismiss()
        }
    }
}

#Preview("Light Mode") {
    ReflectionView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ReflectionView()
        .preferredColorScheme(.dark)
}
