import SwiftUI

struct GoalActionSheet: View {
    let goal: Goal
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 3)
                .fill((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 24)

            // Goal preview
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(goal.category.color(for: colorScheme))
                        .frame(width: 64, height: 64)

                    Image(systemName: goal.category.icon)
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }

                Text(goal.title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 32)

                Text(goal.category.rawValue)
                    .font(.system(size: 15))
                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
            }
            .padding(.bottom, 32)

            // Action buttons
            VStack(spacing: 12) {
                // Edit button
                Button(action: {
                    dismiss()
                    // Small delay to let sheet dismiss
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onEdit()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "pencil")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(colorScheme == .dark ?
                                             Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                Color(red: 0.83, green: 0.58, blue: 0.49))
                            .frame(width: 44)

                        Text("Edit Goal")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                        Spacer()
                    }
                    .frame(height: 56)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ?
                                  Color(red: 0.15, green: 0.18, blue: 0.24) :
                                    Color.white.opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
                    )
                }

                // Delete button
                Button(action: {
                    dismiss()
                    // Small delay to let sheet dismiss
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDelete()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(width: 44)

                        Text("Delete Goal")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.red)

                        Spacer()
                    }
                    .frame(height: 56)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ?
                                  Color(red: 0.15, green: 0.18, blue: 0.24) :
                                    Color.white.opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            // Cancel button
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ?
                                     Color(red: 0.35, green: 0.58, blue: 1.0) :
                                        Color(red: 0.83, green: 0.58, blue: 0.49))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ?
                                  Color(red: 0.15, green: 0.18, blue: 0.24) :
                                    Color.white.opacity(0.5))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(
            (colorScheme == .dark ?
             Color(red: 0.11, green: 0.12, blue: 0.15) :
                Color(red: 1.0, green: 0.97, blue: 0.94))
        )
        .presentationDetents([.height(400)])
        .presentationDragIndicator(.hidden)
    }
}

#Preview("Light Mode") {
    Text("")
        .sheet(isPresented: .constant(true)) {
            GoalActionSheet(
                goal: Goal(title: "Exercise daily", category: .health),
                onEdit: {},
                onDelete: {}
            )
            .preferredColorScheme(.light)
        }
}

#Preview("Dark Mode") {
    Text("")
        .sheet(isPresented: .constant(true)) {
            GoalActionSheet(
                goal: Goal(title: "Read 12 books this year", category: .learning),
                onEdit: {},
                onDelete: {}
            )
            .preferredColorScheme(.dark)
        }
}
