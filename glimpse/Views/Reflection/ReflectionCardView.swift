import SwiftUI

struct ReflectionCardView: View {
    let goal: Goal
    @Binding var closerAnswer: String
    @Binding var furtherAnswer: String
    let colorScheme: ColorScheme

    @FocusState private var focusedField: Field?

    enum Field {
        case closer, further
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Goal header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(goal.category.color(for: colorScheme))
                            .frame(width: 72, height: 72)

                        Image(systemName: goal.category.icon)
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }

                    Text(goal.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 24)

                // Question 1
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 20))

                        Text("What got you closer?")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                    }

                    Text("What did you do today that got you closer to this goal?")
                        .font(.system(size: 15))
                        .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))

                    TextEditor(text: $closerAnswer)
                        .font(.system(size: 16))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                        .frame(minHeight: 120)
                        .padding(12)
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
                        .focused($focusedField, equals: .closer)
                }

                // Question 2
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 20))

                        Text("What led you further away?")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                    }

                    Text("What did you do today that led you further away from this goal?")
                        .font(.system(size: 15))
                        .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))

                    TextEditor(text: $furtherAnswer)
                        .font(.system(size: 16))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                        .frame(minHeight: 120)
                        .padding(12)
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
                        .focused($focusedField, equals: .further)
                }
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview("Light Mode") {
    ReflectionCardView(
        goal: Goal(title: "Exercise daily", category: .health),
        closerAnswer: .constant(""),
        furtherAnswer: .constant(""),
        colorScheme: .light
    )
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ReflectionCardView(
        goal: Goal(title: "Read 12 books", category: .learning),
        closerAnswer: .constant(""),
        furtherAnswer: .constant(""),
        colorScheme: .dark
    )
    .preferredColorScheme(.dark)
}
