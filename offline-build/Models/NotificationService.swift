import Foundation
import UserNotifications

// MARK: - Notification Service
final class NotificationService {

    static let shared = NotificationService()
    private init() {}

    // MARK: - Permission
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            DispatchQueue.main.async {
                if let error {
                    NSLog("[Notifications] Permission error: \(error.localizedDescription)")
                }
                NSLog("[Notifications] Permission granted: \(granted)")
                completion(granted)
            }
        }
    }

    func checkStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { completion(settings.authorizationStatus) }
        }
    }

    // MARK: - Schedule Daily Prayer Reminders
    /// Schedules a gentle reminder at a fixed offset before each prayer window.
    /// These are local, calendar-based triggers — no server needed.
    func scheduleDailyPrayerReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let prayers: [(name: String, hour: Int, minute: Int, body: String)] = [
            ("Fajr",    5,  00, "Time for Fajr — begin your day with Salah 🌙"),
            ("Dhuhr",  12,  30, "Dhuhr time — pause and pray 🕌"),
            ("Asr",    15,  30, "Asr reminder — don't let it slip by ☀️"),
            ("Maghrib", 18, 15, "Maghrib is near — prepare for prayer 🌅"),
            ("Isha",   20,  30, "Isha time — end your day with Salah ✨"),
        ]

        for prayer in prayers {
            var components = DateComponents()
            components.hour   = prayer.hour
            components.minute = prayer.minute

            let content         = UNMutableNotificationContent()
            content.title       = "\(prayer.name) Prayer"
            content.body        = prayer.body
            content.sound       = .default
            content.categoryIdentifier = "PRAYER_REMINDER"

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: true
            )

            let request = UNNotificationRequest(
                identifier: "prayer_\(prayer.name.lowercased())",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    NSLog("[Notifications] Failed to schedule \(prayer.name): \(error.localizedDescription)")
                } else {
                    NSLog("[Notifications] Scheduled \(prayer.name) at \(prayer.hour):\(String(format: "%02d", prayer.minute))")
                }
            }
        }
    }

    // MARK: - Daily Verse Notification
    func scheduleDailyVerseNotification() {
        let id = "daily_verse"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])

        let content       = UNMutableNotificationContent()
        content.title     = "Daily Verse 📖"
        content.body      = "Open Noor for today's verse from the Quran."
        content.sound     = .default

        var components    = DateComponents()
        components.hour   = 8
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                NSLog("[Notifications] Failed to schedule daily verse: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Cancel All
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        NSLog("[Notifications] All notifications cancelled")
    }
}
