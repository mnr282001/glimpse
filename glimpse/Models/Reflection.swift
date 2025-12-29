import Foundation

struct Reflection: Identifiable, Codable, Equatable {
    let id: UUID
    let goalId: UUID
    let date: Date  // Normalized to start of day
    let closerAnswer: String
    let furtherAnswer: String
    let createdAt: Date  // Actual timestamp when created

    init(
        id: UUID = UUID(),
        goalId: UUID,
        date: Date,
        closerAnswer: String,
        furtherAnswer: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.goalId = goalId
        // Normalize date to start of day for consistency
        self.date = Calendar.current.startOfDay(for: date)
        self.closerAnswer = closerAnswer
        self.furtherAnswer = furtherAnswer
        self.createdAt = createdAt
    }
}
