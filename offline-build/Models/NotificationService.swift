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

    // MARK: - Schedule Prayer Reminders from Real Prayer Times
    /// Schedules notifications using actual calculated prayer times.
    func schedulePrayerReminders(from prayerTimes: [PrayerTime]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let bodies: [String: String] = [
            "Fajr":    "Time for Fajr — begin your day with Salah 🌙",
            "Dhuhr":   "Dhuhr time — pause and pray 🕌",
            "Asr":     "Asr reminder — don't let it slip by ☀️",
            "Maghrib": "Maghrib is near — prepare for prayer 🌅",
            "Isha":    "Isha time — end your day with Salah ✨"
        ]

        let cal = Calendar.current
        for pt in prayerTimes {
            let name = pt.prayer.rawValue
            let comps = cal.dateComponents([.hour, .minute], from: pt.time)

            let content = UNMutableNotificationContent()
            content.title = "\(name) Prayer"
            content.body = bodies[name] ?? "Time for \(name) — don't miss it 🕌"
            content.sound = .default
            content.categoryIdentifier = "PRAYER_REMINDER"

            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
            let request = UNNotificationRequest(
                identifier: "prayer_\(name.lowercased())",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    NSLog("[Notifications] Failed to schedule \(name): \(error.localizedDescription)")
                } else {
                    NSLog("[Notifications] Scheduled \(name) at \(comps.hour ?? 0):\(String(format: "%02d", comps.minute ?? 0))")
                }
            }
        }
    }

    // MARK: - Schedule Daily Prayer Reminders (fallback with hardcoded times)
    /// Legacy stub — calls schedulePrayerReminders with fallback fixed times.
    /// Prefer calling schedulePrayerReminders(from:) with real PrayerTime objects.
    func scheduleDailyPrayerReminders() {
        let cal = Calendar.current
        let fallback: [(name: String, hour: Int, minute: Int)] = [
            ("Fajr",     5,  0),
            ("Dhuhr",   12, 30),
            ("Asr",     15, 30),
            ("Maghrib", 18, 15),
            ("Isha",    20, 30),
        ]
        let fakeTimes: [PrayerTime] = fallback.compactMap { item in
            var comps = DateComponents()
            comps.hour = item.hour
            comps.minute = item.minute
            guard let date = cal.date(from: comps) else { return nil }
            let f = DateFormatter(); f.timeStyle = .short
            return PrayerTime(prayer: Prayer(rawValue: item.name) ?? .fajr,
                              time: date, timeString: f.string(from: date))
        }
        schedulePrayerReminders(from: fakeTimes)
    }

    // MARK: - Daily Verse Notification
    func scheduleDailyVerseNotification() {
        let id = "daily_verse"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])

        let content       = UNMutableNotificationContent()
        content.title     = "Daily Verse 📖"
        content.body      = "Open Muslim Pro for today's verse from the Quran."
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
