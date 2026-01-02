import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self

        // Setup notification categories
        NotificationManager.shared.setupNotificationCategories()

        return true
    }

    // MARK: - UNUserNotificationCenterDelegate

    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is open
        completionHandler([.banner, .sound, .badge])
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        switch response.actionIdentifier {
        case "COMPLETE_ACTION":
            // User tapped "Mark as Done" - open reflections view
            handleOpenReflections()

        case "SNOOZE_ACTION":
            // User tapped "Remind Me Later" - schedule notification in 1 hour
            Task {
                await scheduleSnoozeNotification()
            }

        case UNNotificationDefaultActionIdentifier:
            // User tapped notification itself
            handleOpenReflections()

        default:
            break
        }

        completionHandler()
    }

    // MARK: - Helper Methods

    private func handleOpenReflections() {
        print("📱 AppDelegate: Notification tapped - handling open reflections")

        // Set a flag that will be checked when app becomes active
        UserDefaults.standard.set(true, forKey: "shouldShowReflectionSplash")
        print("✅ AppDelegate: Flag set to true")

        // Force trigger the check by posting a different notification
        // This ensures the app checks the flag immediately
        NotificationCenter.default.post(name: .checkReflectionSplashFlag, object: nil)
        print("📤 AppDelegate: Posted checkReflectionSplashFlag event")
    }

    private func scheduleSnoozeNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "Reminder: Time to Reflect 📝"
        content.body = "Don't forget to reflect on your goals!"
        content.sound = .default

        // Trigger in 1 hour
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
        let request = UNNotificationRequest(identifier: "snooze_notification", content: content, trigger: trigger)

        try? await UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let openDailyReflections = Notification.Name("openDailyReflections")
    static let checkReflectionSplashFlag = Notification.Name("checkReflectionSplashFlag")
}
