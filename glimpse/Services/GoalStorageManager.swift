import Foundation

class GoalStorageManager: ObservableObject {
    static let shared = GoalStorageManager()

    private let goalsKey = "glimpse.user.goals"
    private let onboardingCompleteKey = "glimpse.onboarding.complete"
    private let userPersonalizationKey = "glimpse.user.personalization"
    private let notificationSettingsKey = "glimpse.notification.settings"
    private let reflectionsKey = "glimpse.user.reflections"

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

    // MARK: - Notification Settings

    func saveNotificationSettings(_ settings: NotificationSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(data, forKey: notificationSettingsKey)
        } catch {
            print("Error saving notification settings: \(error)")
        }
    }

    func loadNotificationSettings() -> NotificationSettings? {
        guard let data = UserDefaults.standard.data(forKey: notificationSettingsKey) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(NotificationSettings.self, from: data)
        } catch {
            print("Error loading notification settings: \(error)")
            return nil
        }
    }

    // MARK: - Reflections Management

    func saveReflections(_ reflections: [Reflection]) {
        do {
            let data = try JSONEncoder().encode(reflections)
            UserDefaults.standard.set(data, forKey: reflectionsKey)
        } catch {
            print("Error saving reflections: \(error)")
        }
    }

    func loadReflections() -> [Reflection] {
        guard let data = UserDefaults.standard.data(forKey: reflectionsKey) else {
            return []
        }

        do {
            return try JSONDecoder().decode([Reflection].self, from: data)
        } catch {
            print("Error loading reflections: \(error)")
            return []
        }
    }

    func addReflection(_ reflection: Reflection) {
        var reflections = loadReflections()
        reflections.append(reflection)
        saveReflections(reflections)
    }

    func getReflections(for goalId: UUID) -> [Reflection] {
        return loadReflections().filter { $0.goalId == goalId }
    }

    func getReflection(for goalId: UUID, on date: Date) -> Reflection? {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        return loadReflections().first {
            $0.goalId == goalId && $0.date == normalizedDate
        }
    }

    func hasCompletedReflectionToday() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let reflections = loadReflections()

        // Check if there's at least one reflection for each goal today
        let goalsWithReflectionsToday = Set(
            reflections
                .filter { $0.date == today }
                .map { $0.goalId }
        )

        let allGoalIds = Set(goals.map { $0.id })

        return goalsWithReflectionsToday == allGoalIds && !allGoalIds.isEmpty
    }

    // MARK: - Streak Calculation

    func calculateStreak(for goalId: UUID) -> Int {
        let reflections = getReflections(for: goalId)
            .sorted { $0.date > $1.date }  // Sort descending (most recent first)

        guard !reflections.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Check if most recent reflection is today or yesterday
        // If it's older, streak is broken
        guard let mostRecent = reflections.first else { return 0 }

        let daysDifference = calendar.dateComponents([.day], from: mostRecent.date, to: today).day ?? 0

        if daysDifference > 1 {
            return 0  // Missed a day, streak is broken
        }

        // Count consecutive days working backwards
        var streak = 0
        var expectedDate = mostRecent.date

        for reflection in reflections {
            if reflection.date == expectedDate {
                streak += 1
                expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate) ?? expectedDate
            } else {
                break  // Gap found, stop counting
            }
        }

        return streak
    }
}
