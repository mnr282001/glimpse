import Foundation
import Supabase

class ReflectionManager: ObservableObject {
    static let shared = ReflectionManager()

    @Published var todayReflections: [UUID: Reflection] = [:] // Key: goalId
    @Published var isLoading = false
    @Published var errorMessage: String?

    private init() {}

    // MARK: - Fetch Today's Reflections

    /// Load all reflections for today for the current user
    func loadTodayReflections(for goals: [Goal]) async {
        await MainActor.run { isLoading = true }

        do {
            let userId = try await SupabaseManager.shared.client.auth.session.user.id
            let today = Calendar.current.startOfDay(for: Date())

            let response: [ReflectionDTO] = try await SupabaseManager.shared.client
                .database
                .from("reflections")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("reflection_date", value: ISO8601DateFormatter().string(from: today))
                .execute()
                .value

            let reflections = response.map { dto -> Reflection in
                Reflection(
                    id: UUID(uuidString: dto.id) ?? UUID(),
                    userId: UUID(uuidString: dto.user_id) ?? userId,
                    goalId: UUID(uuidString: dto.goal_id) ?? UUID(),
                    reflectionDate: ISO8601DateFormatter().date(from: dto.reflection_date) ?? Date(),
                    progressText: dto.progress_text,
                    setbackText: dto.setback_text,
                    createdAt: ISO8601DateFormatter().date(from: dto.created_at) ?? Date(),
                    updatedAt: ISO8601DateFormatter().date(from: dto.updated_at) ?? Date()
                )
            }

            await MainActor.run {
                // Map reflections by goal ID for easy lookup
                todayReflections = Dictionary(uniqueKeysWithValues: reflections.map { ($0.goalId, $0) })

                // Add empty reflections for goals without one
                for goal in goals {
                    if todayReflections[goal.id] == nil {
                        todayReflections[goal.id] = Reflection(userId: userId, goalId: goal.id)
                    }
                }

                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = "Failed to load reflections: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Save Reflection

    /// Save or update a reflection
    func saveReflection(_ reflection: Reflection) async throws {
        let today = Calendar.current.startOfDay(for: Date())
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]

        let reflectionData = ReflectionUpsertData(
            user_id: reflection.userId.uuidString,
            goal_id: reflection.goalId.uuidString,
            reflection_date: dateFormatter.string(from: today),
            progress_text: reflection.progressText,
            setback_text: reflection.setbackText
        )

        // Upsert (insert or update if exists)
        try await SupabaseManager.shared.client
            .database
            .from("reflections")
            .upsert(reflectionData, onConflict: "user_id,goal_id,reflection_date")
            .execute()

        // Update local state
        await MainActor.run {
            todayReflections[reflection.goalId] = reflection
        }
    }

    // MARK: - Check Completion Status

    /// Check if all goals have been reflected on today
    func allGoalsCompleted(for goals: [Goal]) -> Bool {
        for goal in goals {
            if let reflection = todayReflections[goal.id] {
                if !reflection.isComplete {
                    return false
                }
            } else {
                return false // Missing reflection
            }
        }
        return goals.count > 0 // Only true if there are goals
    }

    /// Get completion percentage for today (0.0 to 1.0)
    func completionPercentage(for goals: [Goal]) -> Double {
        guard !goals.isEmpty else { return 0.0 }

        let completedCount = goals.filter { goal in
            todayReflections[goal.id]?.isComplete ?? false
        }.count

        return Double(completedCount) / Double(goals.count)
    }

    // MARK: - Helper Methods

    /// Get reflection for a specific goal
    func reflection(for goalId: UUID) -> Reflection? {
        return todayReflections[goalId]
    }

    /// Clear all cached reflections (e.g., on logout)
    func clearCache() {
        todayReflections.removeAll()
    }
}

// MARK: - Data Transfer Object

private struct ReflectionDTO: Decodable {
    let id: String
    let user_id: String
    let goal_id: String
    let reflection_date: String
    let progress_text: String
    let setback_text: String
    let created_at: String
    let updated_at: String
}
private struct ReflectionUpsertData: Encodable {
    let user_id: String
    let goal_id: String
    let reflection_date: String
    let progress_text: String
    let setback_text: String
}

