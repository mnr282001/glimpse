import SwiftUI

struct CategoryPickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Binding var selectedCategory: GoalCategory

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

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
                        Text("Choose a category")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                        Spacer()

                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.3))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                    // Categories grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(GoalCategory.allCases, id: \.self) { category in
                                CategoryCell(
                                    category: category,
                                    isSelected: selectedCategory == category
                                )
                                .onTapGesture {
                                    selectedCategory = category
                                    dismiss()
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct CategoryCell: View {
    let category: GoalCategory
    let isSelected: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 12) {
            // Icon circle
            ZStack {
                Circle()
                    .fill(category.color(for: colorScheme))
                    .frame(width: 64, height: 64)

                Image(systemName: category.icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }

            // Category name
            Text(category.rawValue)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
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
    }
}

#Preview("Light Mode") {
    CategoryPickerView(selectedCategory: .constant(.personal))
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    CategoryPickerView(selectedCategory: .constant(.health))
        .preferredColorScheme(.dark)
}
