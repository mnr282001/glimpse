import Foundation

struct Reflection: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let goalId: UUID
    let reflectionDate: Date
    var progressText: String
    var setbackText: String
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case goalId = "goal_id"
        case reflectionDate = "reflection_date"
        case progressText = "progress_text"
        case setbackText = "setback_text"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // Helper to check if reflection is complete
    var isComplete: Bool {
        return !progressText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !setbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // Initialize with defaults for creating new reflection
    init(userId: UUID, goalId: UUID, reflectionDate: Date = Date()) {
        self.id = UUID()
        self.userId = userId
        self.goalId = goalId
        self.reflectionDate = reflectionDate
        self.progressText = ""
        self.setbackText = ""
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Full initializer (for decoding from database)
    init(id: UUID, userId: UUID, goalId: UUID, reflectionDate: Date,
         progressText: String, setbackText: String,
         createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.goalId = goalId
        self.reflectionDate = reflectionDate
        self.progressText = progressText
        self.setbackText = setbackText
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// Helper for formatting dates
extension Reflection {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: reflectionDate)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(reflectionDate)
    }
}
