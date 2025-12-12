import SwiftUI

struct GoalCardView: View {
    let goal: Goal
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 16) {
            // Category icon circle
            ZStack {
                Circle()
                    .fill(goal.category.color(for: colorScheme))
                    .frame(width: 56, height: 56)

                Image(systemName: goal.category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }

            // Goal info
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                    .lineLimit(2)

                Text(goal.category.rawValue)
                    .font(.system(size: 14))
                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
            }

            Spacer()

            // Streak indicator (placeholder)
            VStack(spacing: 4) {
                Text("\(goal.currentStreak)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(colorScheme == .dark ?
                        Color(red: 0.35, green: 0.58, blue: 1.0) :
                        Color(red: 0.83, green: 0.58, blue: 0.49))

                Text("day streak")
                    .font(.system(size: 12))
                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ?
                    Color(red: 0.15, green: 0.18, blue: 0.24) :
                    Color.white.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview("Light Mode") {
    VStack(spacing: 16) {
        GoalCardView(goal: Goal(title: "Exercise daily", category: .health))
        GoalCardView(goal: Goal(title: "Read 12 books this year", category: .learning))
        GoalCardView(goal: Goal(title: "Build better relationships", category: .relationships))
    }
    .padding()
    .background(Color(red: 1.0, green: 0.97, blue: 0.94))
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    VStack(spacing: 16) {
        GoalCardView(goal: Goal(title: "Exercise daily", category: .health))
        GoalCardView(goal: Goal(title: "Read 12 books this year", category: .learning))
        GoalCardView(goal: Goal(title: "Build better relationships", category: .relationships))
    }
    .padding()
    .background(Color(red: 0.11, green: 0.12, blue: 0.15))
    .preferredColorScheme(.dark)
}
