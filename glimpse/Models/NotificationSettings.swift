import Foundation

struct NotificationSettings: Codable {
    var time: Date
    var enabled: Bool
    var lastScheduledDate: Date?  // Track when we last scheduled notifications

    init(time: Date = Date(), enabled: Bool = true) {
        self.time = time
        self.enabled = enabled
        self.lastScheduledDate = nil
    }
}
