import SwiftUI

struct GoalCardView: View {
    let goal: Goal
    @Environment(\.colorScheme) var colorScheme

    // Interaction callbacks
    var onTap: (() -> Void)?
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?

    @State private var offset: CGFloat = 0
    @State private var showDeleteBackground = false
    @State private var showEditBackground = false

    var body: some View {
        ZStack {
            // Swipe action backgrounds
            HStack {
                // Edit action (right side, revealed when swiping right)
                if showEditBackground {
                    HStack {
                        Image(systemName: "pencil")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 60)
                        Spacer()
                    }
                    .frame(maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ?
                                  Color(red: 0.35, green: 0.58, blue: 1.0) :
                                    Color(red: 0.83, green: 0.58, blue: 0.49))
                    )
                }

                Spacer()

                // Delete action (left side, revealed when swiping left)
                if showDeleteBackground {
                    HStack {
                        Spacer()
                        Image(systemName: "trash.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 60)
                    }
                    .frame(maxHeight: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.red)
                    )
                }
            }

            // Main card content
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

//                // Streak indicator (placeholder)
//                VStack(spacing: 4) {
//                    Text("\(goal.currentStreak)")
//                        .font(.system(size: 24, weight: .bold))
//                        .foregroundColor(colorScheme == .dark ?
//                            Color(red: 0.35, green: 0.58, blue: 1.0) :
//                            Color(red: 0.83, green: 0.58, blue: 0.49))
//
//                    Text("day streak")
//                        .font(.system(size: 12))
//                        .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
//                }
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
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let translation = gesture.translation.width

                        // Limit swipe distance
                        if translation > 0 {
                            // Swiping right (edit)
                            offset = min(translation, 100)
                            showEditBackground = offset > 20
                            showDeleteBackground = false
                        } else {
                            // Swiping left (delete)
                            offset = max(translation, -100)
                            showDeleteBackground = offset < -20
                            showEditBackground = false
                        }
                    }
                    .onEnded { gesture in
                        let translation = gesture.translation.width

                        if translation > 80 {
                            // Swipe right confirmed - Edit
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                offset = 0
                                showEditBackground = false
                            }
                            // Haptic feedback
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            onEdit?()
                        } else if translation < -80 {
                            // Swipe left confirmed - Delete
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                offset = 0
                                showDeleteBackground = false
                            }
                            // Haptic feedback
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            onDelete?()
                        } else {
                            // Return to center
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                offset = 0
                                showEditBackground = false
                                showDeleteBackground = false
                            }
                        }
                    }
            )
            .onTapGesture {
                // Haptic feedback
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                onTap?()
            }
        }
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
