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

    private init() {
        // Don't load goals in init - will be loaded when user is authenticated
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

    func addGoal(_ goal: Goal) {
        var updatedGoals = goals
        updatedGoals.append(goal)
        saveGoals(updatedGoals)
    }

    func updateGoal(_ goal: Goal) {
        var updatedGoals = goals
        if let index = updatedGoals.firstIndex(where: { $0.id == goal.id }) {
            updatedGoals[index] = goal
            saveGoals(updatedGoals)
        }
    }

    func deleteGoal(_ goal: Goal) {
        var updatedGoals = goals
        updatedGoals.removeAll { $0.id == goal.id }
        saveGoals(updatedGoals)
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
