import Foundation

// MARK: - Supabase Response Models

/// Response model for goals from Supabase
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

    private init() {
        // Don't load goals in init - will be loaded when user is authenticated
    }

    // MARK: - User Tier Management

    func loadUserTier() async {
        do {
            let userId = try await SupabaseManager.shared.client.auth.session.user.id

            struct TierResponse: Decodable {
                let tier: String?
            }

            let response: [TierResponse] = try await SupabaseManager.shared.client
                .database
                .from("profiles")
                .select("tier")
                .eq("id", value: userId.uuidString)
                .execute()
                .value

            await MainActor.run {
                if let tierString = response.first?.tier,
                   let tier = UserTier(rawValue: tierString) {
                    self.userTier = tier
                } else {
                    self.userTier = .free
                }
            }
        } catch {
            print("Error loading user tier: \(error)")
            await MainActor.run {
                self.userTier = .free
            }
        }
    }

    var maxGoals: Int {
        return userTier.maxGoals
    }

    var canAddGoal: Bool {
        return goals.count < maxGoals
    }

    // MARK: - Goals Management

    func loadGoals() {
        Task {
            await MainActor.run {
                isLoadingGoals = true
            }

            do {
                let userId = try await SupabaseManager.shared.client.auth.session.user.id

                let response: [GoalResponse] = try await SupabaseManager.shared.client
                    .database
                    .from("goals")
                    .select()
                    .eq("user_id", value: userId.uuidString)
                    .execute()
                    .value

                let loadedGoals = response.map { goalResponse in
                    Goal(
                        id: UUID(uuidString: goalResponse.id) ?? UUID(),
                        title: goalResponse.title,
                        category: GoalCategory(rawValue: goalResponse.category) ?? .personal
                    )
                }

                await MainActor.run {
                    self.goals = loadedGoals
                    self.isLoadingGoals = false
                }
            } catch {
                print("Error loading goals from Supabase: \(error)")
                // Fallback to empty array if loading fails
                await MainActor.run {
                    self.goals = []
                    self.isLoadingGoals = false
                }
            }
        }
    }

    func saveGoals(_ goals: [Goal]) {
        self.goals = goals

        do {
            let data = try JSONEncoder().encode(goals)
            UserDefaults.standard.set(data, forKey: goalsKey)
        } catch {
            print("Error saving goals: \(error)")
        }
    }

    func addGoal(_ goal: Goal) async throws {
        guard canAddGoal else {
            throw NSError(
                domain: "GoalStorageManager",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "You've reached the maximum number of goals for your plan (\(maxGoals) goals)."]
            )
        }

        do {
            let userId = try await SupabaseManager.shared.client.auth.session.user.id

            // Insert into Supabase
            struct GoalInsert: Encodable {
                let id: String
                let user_id: String
                let title: String
                let category: String
                let created_at: String
                let updated_at: String
            }

            let goalData = GoalInsert(
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
                .insert(goalData)
                .execute()

            // Update local state
            await MainActor.run {
                var updatedGoals = goals
                updatedGoals.append(goal)
                self.goals = updatedGoals
            }
        } catch {
            print("Error adding goal: \(error)")
            throw error
        }
    }

    func updateGoal(_ goal: Goal) async {
        do {
            let userId = try await SupabaseManager.shared.client.auth.session.user.id

            // Update in Supabase
            struct GoalUpdate: Encodable {
                let title: String
                let category: String
                let updated_at: String
            }
            
            let goalData = GoalUpdate(
                title: goal.title,
                category: goal.category.rawValue,
                updated_at: ISO8601DateFormatter().string(from: goal.updatedAt)
            )

            try await SupabaseManager.shared.client
                .database
                .from("goals")
                .update(goalData)
                .eq("id", value: goal.id.uuidString)
                .eq("user_id", value: userId.uuidString)
                .execute()

            // Update local state
            await MainActor.run {
                var updatedGoals = goals
                if let index = updatedGoals.firstIndex(where: { $0.id == goal.id }) {
                    updatedGoals[index] = goal
                    self.goals = updatedGoals
                }
            }
        } catch {
            print("Error updating goal: \(error)")
        }
    }

    func deleteGoal(_ goal: Goal) async {
        do {
            let userId = try await SupabaseManager.shared.client.auth.session.user.id

            // Delete from Supabase
            try await SupabaseManager.shared.client
                .database
                .from("goals")
                .delete()
                .eq("id", value: goal.id.uuidString)
                .eq("user_id", value: userId.uuidString)
                .execute()

            // Update local state
            await MainActor.run {
                var updatedGoals = goals
                updatedGoals.removeAll { $0.id == goal.id }
                self.goals = updatedGoals
            }
        } catch {
            print("Error deleting goal: \(error)")
        }
    }

    // MARK: - Onboarding

    var isOnboardingComplete: Bool {
        get {
            UserDefaults.standard.bool(forKey: onboardingCompleteKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: onboardingCompleteKey)
        }
    }

    func completeOnboarding() {
        isOnboardingComplete = true
    }

    // MARK: - User Personalization (for future use)

    func savePersonalization(firstName: String) {
        let personalization: [String: Any] = [
            "firstName": firstName
        ]
        UserDefaults.standard.set(personalization, forKey: userPersonalizationKey)
    }

    // MARK: - Notification Settings (for future use)

    func saveNotificationSettings(time: Date, enabled: Bool) {
        let settings: [String: Any] = [
            "time": time.timeIntervalSince1970,
            "enabled": enabled
        ]
        UserDefaults.standard.set(settings, forKey: notificationSettingsKey)
    }
}
