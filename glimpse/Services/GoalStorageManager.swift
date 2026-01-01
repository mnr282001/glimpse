import Foundation

// MARK: - Supabase Response Models

private struct GoalResponse: Decodable {
    let id: String
    let user_id: String
    let title: String
    let category: String
    let created_at: String?
}

class GoalStorageManager: ObservableObject {
    static let shared = GoalStorageManager()

    private let goalsKey = "glimpse.user.goals"
    private let onboardingCompleteKey = "glimpse.onboarding.complete"
    private let userPersonalizationKey = "glimpse.user.personalization"
    private let notificationSettingsKey = "glimpse.notification.settings"

    @Published var goals: [Goal] = []
    @Published var isLoadingGoals: Bool = false
    @Published var userTier: UserTier = .free

    private init() {}

    // MARK: - User Tier Management

    func loadUserTier() async {
        await PremiumEntitlementManager.shared.loadTier()
        userTier = await PremiumEntitlementManager.shared.tier
    }

    var maxGoals: Int {
        userTier.maxGoals
    }

    /// General validation check (used when actually adding a goal)
    var canAddGoal: Bool {
        goals.count < maxGoals
    }

    /// Explicit helpers for UI logic
    var isFreeTier: Bool {
        userTier == .free
    }

    var isAtFreeLimit: Bool {
        userTier == .free && goals.count >= 3
    }

    var isAtPremiumLimit: Bool {
        userTier == .premium && goals.count >= 10
    }

    // MARK: - Goals Management

    func loadGoals() {
        Task {
            await MainActor.run { isLoadingGoals = true }

            do {
                let userId = try await SupabaseManager.shared.client.auth.session.user.id

                let response: [GoalResponse] = try await SupabaseManager.shared.client
                    .database
                    .from("goals")
                    .select()
                    .eq("user_id", value: userId.uuidString)
                    .execute()
                    .value

                let loadedGoals = response.map {
                    Goal(
                        id: UUID(uuidString: $0.id) ?? UUID(),
                        title: $0.title,
                        category: GoalCategory(rawValue: $0.category) ?? .personal
                    )
                }

                await MainActor.run {
                    self.goals = loadedGoals
                    self.isLoadingGoals = false
                }
            } catch {
                print("Error loading goals: \(error)")
                await MainActor.run {
                    self.goals = []
                    self.isLoadingGoals = false
                }
            }
        }
    }

    func saveGoals(_ goals: [Goal]) {
        self.goals = goals
    }

    func addGoal(_ goal: Goal) async throws {
        guard canAddGoal else {
            throw NSError(
                domain: "GoalStorageManager",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "You've reached the maximum number of goals for your plan (\(maxGoals) goals)."
                ]
            )
        }

        let userId = try await SupabaseManager.shared.client.auth.session.user.id

        struct GoalInsert: Encodable {
            let id: String
            let user_id: String
            let title: String
            let category: String
            let created_at: String
            let updated_at: String
        }

        let payload = GoalInsert(
            id: goal.id.uuidString,
            user_id: userId.uuidString,
            title: goal.title,
            category: goal.category.rawValue,
            created_at: ISO8601DateFormatter().string(from: goal.createdAt),
            updated_at: ISO8601DateFormatter().string(from: goal.updatedAt)
        )

        try await SupabaseManager.shared.client
            .database
            .from("goals")
            .insert(payload)
            .execute()

        await MainActor.run {
            goals.append(goal)
        }
    }

    func updateGoal(_ goal: Goal) async {
        let userId = try? await SupabaseManager.shared.client.auth.session.user.id

        struct GoalUpdate: Encodable {
            let title: String
            let category: String
            let updated_at: String
        }

        let payload = GoalUpdate(
            title: goal.title,
            category: goal.category.rawValue,
            updated_at: ISO8601DateFormatter().string(from: goal.updatedAt)
        )

        try? await SupabaseManager.shared.client
            .database
            .from("goals")
            .update(payload)
            .eq("id", value: goal.id.uuidString)
            .eq("user_id", value: userId?.uuidString ?? "")
            .execute()

        await MainActor.run {
            if let index = goals.firstIndex(where: { $0.id == goal.id }) {
                goals[index] = goal
            }
        }
    }

    func deleteGoal(_ goal: Goal) async {
        let userId = try? await SupabaseManager.shared.client.auth.session.user.id

        try? await SupabaseManager.shared.client
            .database
            .from("goals")
            .delete()
            .eq("id", value: goal.id.uuidString)
            .eq("user_id", value: userId?.uuidString ?? "")
            .execute()

        await MainActor.run {
            goals.removeAll { $0.id == goal.id }
        }
    }

    // MARK: - Onboarding

    var isOnboardingComplete: Bool {
        get { UserDefaults.standard.bool(forKey: onboardingCompleteKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardingCompleteKey) }
    }

    func completeOnboarding() {
        isOnboardingComplete = true
    }
}

