import Foundation
import SwiftUI

enum GoalCategory: String, Codable, CaseIterable {
    case health = "Health & Fitness"
    case career = "Career & Work"
    case learning = "Learning & Education"
    case relationships = "Relationships"
    case creativity = "Creativity & Hobbies"
    case finance = "Finance & Money"
    case mindfulness = "Mindfulness & Wellness"
    case productivity = "Productivity"
    case personal = "Personal Growth"

    // SF Symbol icon for each category
    var icon: String {
        switch self {
        case .health: return "figure.run"
        case .career: return "briefcase.fill"
        case .learning: return "book.fill"
        case .relationships: return "heart.fill"
        case .creativity: return "paintbrush.fill"
        case .finance: return "dollarsign.circle.fill"
        case .mindfulness: return "brain.head.profile"
        case .productivity: return "checkmark.circle.fill"
        case .personal: return "star.fill"
        }
    }

    // Color for icon (alternating between app's theme colors)
    func color(for colorScheme: ColorScheme) -> Color {
        let isDark = colorScheme == .dark

        switch self {
        case .health, .learning, .creativity, .mindfulness, .personal:
            return isDark ?
                Color(red: 0.35, green: 0.58, blue: 1.0) :
                Color(red: 0.83, green: 0.58, blue: 0.49)
        case .career, .relationships, .finance, .productivity:
            return isDark ?
                Color(red: 0.45, green: 0.65, blue: 1.0) :
                Color(red: 0.73, green: 0.48, blue: 0.39)
        }
    }
}
