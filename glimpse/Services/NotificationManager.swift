import UserNotifications
import Foundation

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    private let notificationIdentifier = "glimpse.daily.reflection"

    private override init() {
        super.init()
    }

    // MARK: - Permission Handling

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted, error)
            }
        }
    }

    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    // MARK: - Scheduling

    func scheduleDailyNotification(at time: Date) {
        // Remove existing notifications first
        cancelDailyNotification()

        let content = UNMutableNotificationContent()
        content.title = "Time to Reflect"
        content.body = "How did today go with your goals?"
        content.sound = .default
        content.badge = 1

        // Add custom data for deep linking
        content.userInfo = ["action": "openReflection"]

        // Extract hour and minute from the selected time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        // Create trigger that repeats daily
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    func cancelDailyNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [notificationIdentifier]
        )
    }

    func updateNotificationSettings(_ settings: NotificationSettings) {
        if settings.enabled {
            scheduleDailyNotification(at: settings.time)
        } else {
            cancelDailyNotification()
        }

        // Update settings with last scheduled date
        var updatedSettings = settings
        updatedSettings.lastScheduledDate = settings.enabled ? Date() : nil
        GoalStorageManager.shared.saveNotificationSettings(updatedSettings)
    }
}
