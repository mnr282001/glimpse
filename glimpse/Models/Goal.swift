import Foundation

struct Goal: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var category: GoalCategory
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        category: GoalCategory,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Placeholder for streak - will be calculated from reflections later
    var currentStreak: Int {
        return 0
    }
}
