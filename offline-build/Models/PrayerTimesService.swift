import Foundation
import CoreLocation
import UserNotifications

// MARK: - Calculation Methods (AlAdhan API method IDs)
enum PrayerCalculationMethod: Int, CaseIterable, Codable {
    case mwl        = 3   // Muslim World League
    case isna       = 2   // Islamic Society of North America
    case egyptian   = 5   // Egyptian General Authority
    case makkah     = 4   // Umm al-Qura, Makkah
    case karachi    = 1   // University of Islamic Sciences, Karachi
    case tehran     = 7   // Institute of Geophysics, University of Tehran
    case kemenag    = 20  // Kementerian Agama, Indonesia
    case singapore  = 11  // Majlis Ugama Islam Singapura
    case gulf       = 8   // Gulf Region
    case kuwait     = 9   // Kuwait
    case qatar      = 10  // Qatar
    case france     = 12  // Union des Organisations Islamiques de France

    var displayName: String {
        switch self {
        case .mwl:      return "Muslim World League"
        case .isna:     return "ISNA (North America)"
        case .egyptian: return "Egyptian Authority"
        case .makkah:   return "Umm Al-Qura (Makkah)"
        case .karachi:  return "Karachi University"
        case .tehran:   return "Tehran (Shia)"
        case .kemenag:  return "Indonesia (Kemenag)"
        case .singapore:return "Singapore MUIS"
        case .gulf:     return "Gulf Region"
        case .kuwait:   return "Kuwait"
        case .qatar:    return "Qatar"
        case .france:   return "France (UOIF)"
        }
    }

    var shortName: String {
        switch self {
        case .mwl:      return "MWL"
        case .isna:     return "ISNA"
        case .egyptian: return "Egyptian"
        case .makkah:   return "Makkah"
        case .karachi:  return "Karachi"
        case .tehran:   return "Tehran"
        case .kemenag:  return "Kemenag"
        case .singapore:return "Singapore"
        case .gulf:     return "Gulf"
        case .kuwait:   return "Kuwait"
        case .qatar:    return "Qatar"
        case .france:   return "France"
        }
    }

    /// Recommended method per region/madhab
    static func recommendedFor(madhab: String) -> PrayerCalculationMethod {
        switch madhab {
        case "Hanafi":    return .karachi
        case "Maliki":    return .mwl
        case "Shafi'i":   return .mwl
        case "Hanbali":   return .mwl
        default:          return .isna
        }
    }
}

// MARK: - Asr Juristic Method
enum AsrJuristicMethod: Int, Codable {
    case shafii = 0   // Standard (Shafi'i, Maliki, Hanbali)
    case hanafi = 1   // Hanafi

    var displayName: String {
        switch self {
        case .shafii: return "Standard (Shafi'i)"
        case .hanafi: return "Hanafi"
        }
    }
}

// MARK: - Adhan API Response
struct AdhanResponse: Codable {
    let data: AdhanData
}

struct AdhanData: Codable {
    let timings: AdhanTimings
    let date: AdhanDate
    let meta: AdhanMeta?
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
    let day: String
}

struct HijriMonth: Codable {
    let en: String
    let ar: String
    let number: Int
}

struct GregorianDate: Codable {
    let date: String
}

struct AdhanMeta: Codable {
    let method: AdhanMethod?
    let latitudeAdjustmentMethod: String?
}

struct AdhanMethod: Codable {
    let name: String?
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
    @Published var hijriDateShort: String = ""
    @Published var locationName: String = "Locating..."
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var notificationsEnabled = false
    @Published var activeMethodName: String = ""

    private let locationManager = CLLocationManager()
    private var lastCoordinate: CLLocationCoordinate2D?
    private var fetchTask: Task<Void, Never>?

    static let shared = PrayerTimesService()

    // User-configurable keys (synced with Profile settings)
    @Published var calculationMethod: PrayerCalculationMethod {
        didSet {
            UserDefaults.standard.set(calculationMethod.rawValue, forKey: "prayer_calc_method")
            scheduleDebouncedFetch()
        }
    }

    @Published var asrMethod: AsrJuristicMethod {
        didSet {
            UserDefaults.standard.set(asrMethod.rawValue, forKey: "prayer_asr_method")
            scheduleDebouncedFetch()
        }
    }

    private func scheduleDebouncedFetch() {
        fetchTask?.cancel()
        guard let coord = lastCoordinate else { return }
        fetchTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000) // 400ms debounce
            guard !Task.isCancelled else { return }
            await fetchPrayerTimes(lat: coord.latitude, lng: coord.longitude)
        }
    }

    override init() {
        let savedMethod = UserDefaults.standard.integer(forKey: "prayer_calc_method")
        self.calculationMethod = PrayerCalculationMethod(rawValue: savedMethod) ?? .isna

        let savedAsr = UserDefaults.standard.integer(forKey: "prayer_asr_method")
        self.asrMethod = AsrJuristicMethod(rawValue: savedAsr) ?? .shafii

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

        // Build URL with method + school (Asr juristic)
        let methodID = calculationMethod.rawValue
        let school = asrMethod.rawValue   // 0 = Shafi'i, 1 = Hanafi
        let urlStr = "https://api.aladhan.com/v1/timings/\(dateStr)?latitude=\(lat)&longitude=\(lng)&method=\(methodID)&school=\(school)&tune=0,0,0,0,0,0,0,0,0"

        guard let url = URL(string: urlStr) else {
            isLoading = false
            loadFallbackTimes()
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AdhanResponse.self, from: data)
            parseTimes(response.data.timings)
            buildHijriDate(response.data.date.hijri)
            activeMethodName = response.data.meta?.method?.name ?? calculationMethod.displayName
            isLoading = false
            if notificationsEnabled { schedulePrayerNotifications() }
        } catch {
            NSLog("[PrayerTimesService] fetch error: %@", error.localizedDescription)
            isLoading = false
            loadFallbackTimes()
        }
    }

    private func buildHijriDate(_ h: HijriDate) {
        hijriDate = "\(h.date) — \(h.month.en) \(h.year) AH"
        hijriDateShort = "\(h.day) \(h.month.en) \(h.year)"
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
        activeMethodName = "Offline (Estimated)"
    }

    // MARK: - Convenience: apply madhab from Profile
    func applyMadhab(_ madhab: String) {
        switch madhab {
        case "Hanafi": asrMethod = .hanafi
        default:       asrMethod = .shafii
        }
        let recommended = PrayerCalculationMethod.recommendedFor(madhab: madhab)
        // Only update if user hasn't manually customised
        let savedMethod = UserDefaults.standard.integer(forKey: "prayer_calc_method")
        if savedMethod == 0 {
            calculationMethod = recommended
        }
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
