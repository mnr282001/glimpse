import Foundation

class GoalStorageManager: ObservableObject {
    static let shared = GoalStorageManager()

    private let goalsKey = "glimpse.user.goals"
    private let onboardingCompleteKey = "glimpse.onboarding.complete"
    private let userPersonalizationKey = "glimpse.user.personalization"
    private let notificationSettingsKey = "glimpse.notification.settings"

    @Published var goals: [Goal] = []

    private init() {
        loadGoals()
    }

    // MARK: - Goals Management

    func loadGoals() {
        guard let data = UserDefaults.standard.data(forKey: goalsKey) else {
            goals = []
            return
        }

        do {
            goals = try JSONDecoder().decode([Goal].self, from: data)
        } catch {
            print("Error loading goals: \(error)")
            goals = []
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

    func savePersonalization(firstName: String, lastName: String, dateOfBirth: Date) {
        let personalization: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "dateOfBirth": dateOfBirth.timeIntervalSince1970
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
