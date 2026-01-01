import Foundation

enum UserTier: String, Codable {
    case free = "free"
    case premium = "premium"

    var maxGoals: Int {
        switch self {
        case .free:
            return 3
        case .premium:
            return 10
        }
    }

    var displayName: String {
        switch self {
        case .free:
            return "Free"
        case .premium:
            return "Premium"
        }
    }
}
