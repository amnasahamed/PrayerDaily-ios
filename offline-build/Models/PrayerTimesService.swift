import Foundation
import CoreLocation
import UserNotifications

// MARK: - Adhan API Response
struct AdhanResponse: Codable {
    let data: AdhanData
}

struct AdhanData: Codable {
    let timings: AdhanTimings
    let date: AdhanDate
}

struct AdhanTimings: Codable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}

struct AdhanDate: Codable {
    let hijri: HijriDate
    let gregorian: GregorianDate
}

struct HijriDate: Codable {
    let date: String
    let month: HijriMonth
    let year: String
}

struct HijriMonth: Codable {
    let en: String
    let ar: String
}

struct GregorianDate: Codable {
    let date: String
}

// MARK: - Prayer Time Model
struct PrayerTime: Identifiable {
    let id = UUID()
    let prayer: Prayer
    let time: Date
    let timeString: String

    var isPast: Bool { time < Date() }
}

// MARK: - Service
@MainActor
class PrayerTimesService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var prayerTimes: [PrayerTime] = []
    @Published var nextPrayer: PrayerTime?
    @Published var hijriDate: String = ""
    @Published var locationName: String = "Locating..."
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var notificationsEnabled = false

    private let locationManager = CLLocationManager()
    private var lastCoordinate: CLLocationCoordinate2D?

    static let shared = PrayerTimesService()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        checkNotificationStatus()
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        isLoading = true
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        Task { @MainActor in
            self.lastCoordinate = loc.coordinate
            await self.fetchPrayerTimes(lat: loc.coordinate.latitude, lng: loc.coordinate.longitude)
            self.reverseGeocode(loc)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.isLoading = false
            self.errorMessage = "Unable to get location"
            self.loadFallbackTimes()
        }
    }

    private func reverseGeocode(_ location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            Task { @MainActor in
                if let p = placemarks?.first {
                    self?.locationName = [p.locality, p.country].compactMap { $0 }.joined(separator: ", ")
                }
            }
        }
    }

    func fetchPrayerTimes(lat: Double, lng: Double) async {
        isLoading = true
        errorMessage = nil

        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        let dateStr = df.string(from: Date())
        let urlStr = "https://api.aladhan.com/v1/timings/\(dateStr)?latitude=\(lat)&longitude=\(lng)&method=2"

        guard let url = URL(string: urlStr) else {
            isLoading = false
            loadFallbackTimes()
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AdhanResponse.self, from: data)
            parseTimes(response.data.timings)
            let h = response.data.date.hijri
            hijriDate = "\(h.date) — \(h.month.en) \(h.year) AH"
            isLoading = false
            if notificationsEnabled { schedulePrayerNotifications() }
        } catch {
            isLoading = false
            loadFallbackTimes()
        }
    }

    private func parseTimes(_ t: AdhanTimings) {
        let pairs: [(Prayer, String)] = [
            (.fajr, t.Fajr), (.dhuhr, t.Dhuhr), (.asr, t.Asr),
            (.maghrib, t.Maghrib), (.isha, t.Isha)
        ]
        let tf = DateFormatter()
        tf.dateFormat = "HH:mm"
        let cal = Calendar.current

        prayerTimes = pairs.compactMap { (prayer, timeStr) in
            let clean = timeStr.components(separatedBy: " ").first ?? timeStr
            guard let parsed = tf.date(from: clean) else { return nil }
            let comps = cal.dateComponents([.hour, .minute], from: parsed)
            var todayComps = cal.dateComponents([.year, .month, .day], from: Date())
            todayComps.hour = comps.hour
            todayComps.minute = comps.minute
            let fullDate = cal.date(from: todayComps) ?? Date()
            let display = DateFormatter()
            display.dateFormat = "h:mm a"
            return PrayerTime(prayer: prayer, time: fullDate, timeString: display.string(from: fullDate))
        }

        let now = Date()
        nextPrayer = prayerTimes.first { $0.time > now }
    }

    private func loadFallbackTimes() {
        let tf = DateFormatter()
        tf.dateFormat = "h:mm a"
        let cal = Calendar.current
        let fallback: [(Prayer, Int, Int)] = [
            (.fajr, 5, 15), (.dhuhr, 12, 30), (.asr, 15, 45),
            (.maghrib, 18, 30), (.isha, 20, 0)
        ]
        prayerTimes = fallback.map { (prayer, h, m) in
            var c = cal.dateComponents([.year, .month, .day], from: Date())
            c.hour = h; c.minute = m
            let d = cal.date(from: c) ?? Date()
            return PrayerTime(prayer: prayer, time: d, timeString: tf.string(from: d))
        }
        nextPrayer = prayerTimes.first { $0.time > Date() }
    }

    // MARK: - Notifications
    func toggleNotifications() {
        if notificationsEnabled {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            notificationsEnabled = false
        } else {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                Task { @MainActor in
                    self?.notificationsEnabled = granted
                    if granted { self?.schedulePrayerNotifications() }
                }
            }
        }
    }

    private func schedulePrayerNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        let cal = Calendar.current
        for pt in prayerTimes where pt.time > Date() {
            let content = UNMutableNotificationContent()
            content.title = "\(pt.prayer.rawValue) Prayer Time"
            content.body = "It's time for \(pt.prayer.rawValue) — \(pt.timeString)"
            content.sound = .default
            let comps = cal.dateComponents([.hour, .minute], from: pt.time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let req = UNNotificationRequest(identifier: "prayer-\(pt.prayer.rawValue)", content: content, trigger: trigger)
            center.add(req)
        }
    }

    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                self.notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
}
