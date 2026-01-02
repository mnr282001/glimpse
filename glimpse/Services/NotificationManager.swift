import Foundation
import UIKit
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var notificationsEnabled = true

    private let notificationCenter = UNUserNotificationCenter.current()
    private let notificationIdentifier = "dailyReflectionReminder"

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    /// Request notification permissions
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                isAuthorized = granted
                notificationsEnabled = granted
            }
            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }

    /// Check current authorization status
    func checkAuthorizationStatus() {
        Task {
            let settings = await notificationCenter.notificationSettings()
            await MainActor.run {
                isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Schedule Daily Notification

    /// Schedule daily reflection reminder at specified time
    func scheduleDailyNotification(at time: Date, enabled: Bool) async {
        // Cancel existing notifications
        await cancelAllNotifications()

        guard enabled, isAuthorized else {
            print("Notifications not enabled or not authorized")
            return
        }

        // Extract hour and minute from time
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to Reflect 📝"
        content.body = "Take a moment to reflect on your goals today."
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "REFLECTION_REMINDER"

        // Create date components for trigger
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        // Create trigger (repeats daily at specified time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create request
        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        // Schedule notification
        do {
            try await notificationCenter.add(request)
            print("✅ Daily notification scheduled for \(hour):\(String(format: "%02d", minute))")

            await MainActor.run {
                notificationsEnabled = true
            }
        } catch {
            print("❌ Failed to schedule notification: \(error)")
        }
    }

    // MARK: - Advanced Notification with Goal Info

    /// Schedule notification with goal-specific information
    func scheduleSmartNotification(at time: Date, goals: [Goal], enabled: Bool) async {
        await cancelAllNotifications()

        guard enabled, isAuthorized, !goals.isEmpty else { return }

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)

        // Load today's reflections to personalize notification
        let reflectionManager = ReflectionManager.shared
        let completionPercentage = reflectionManager.completionPercentage(for: goals)

        // Create personalized content
        let content = UNMutableNotificationContent()
        content.title = "Time to Reflect 📝"

        // Personalized body based on completion
        if completionPercentage == 0 {
            content.body = "Reflect on your \(goals.count) goal\(goals.count == 1 ? "" : "s") for today."
        } else if completionPercentage < 1.0 {
            let remaining = goals.count - Int(Double(goals.count) * completionPercentage)
            content.body = "\(remaining) goal\(remaining == 1 ? "" : "s") left to reflect on today!"
        } else {
            content.body = "Great job! All reflections complete 🎉"
        }

        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "REFLECTION_REMINDER"

        // Add user info for deep linking
        content.userInfo = [
            "action": "openReflections",
            "timestamp": Date().timeIntervalSince1970
        ]

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
            await MainActor.run {
                notificationsEnabled = true
            }
        } catch {
            print("Failed to schedule smart notification: \(error)")
        }
    }

    // MARK: - Cancel Notifications

    /// Cancel all scheduled notifications
    func cancelAllNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        await setBadgeCount(0)
        print("🔕 All notifications cancelled")
    }

    /// Cancel specific notification
    func cancelNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    // MARK: - Badge Management

    /// Set app badge count
    func setBadgeCount(_ count: Int) async {
        if #available(iOS 16.0, *) {
            try? await notificationCenter.setBadgeCount(count)
        } else {
            await MainActor.run {
                UIApplication.shared.applicationIconBadgeNumber = count
            }
        }
    }

    // MARK: - Notification Actions

    /// Setup notification action categories
    func setupNotificationCategories() {
        // Create "Mark as Done" action
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: "Mark as Done",
            options: [.foreground]
        )

        // Create "Remind Me Later" action
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Remind Me in 1 Hour",
            options: []
        )

        // Create category
        let category = UNNotificationCategory(
            identifier: "REFLECTION_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        notificationCenter.setNotificationCategories([category])
    }

    // MARK: - Test Notification (For Debugging)

    /// Send a test notification in 15 seconds (for testing purposes)
    /// Works whether app is in foreground, background, or completely closed
    func sendTestNotification() async -> Bool {
        guard isAuthorized else {
            print("❌ Not authorized to send notifications")
            return false
        }

        let content = UNMutableNotificationContent()
        content.title = "Test Notification 📝"
        content.body = "This test notification was scheduled 15 seconds ago. Tap to open reflections!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "REFLECTION_REMINDER"

        // Add user info for deep linking
        content.userInfo = [
            "action": "openReflections",
            "isTest": true
        ]

        // Trigger in exactly 15 seconds
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification_15s", content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
            print("✅ Test notification scheduled for 15 seconds from now")
            print("⏰ Will fire at: \(Date().addingTimeInterval(15))")
            return true
        } catch {
            print("❌ Failed to send test notification: \(error)")
            return false
        }
    }

    // MARK: - Get Scheduled Notifications

    /// Get list of all pending notifications (for debugging)
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
}
