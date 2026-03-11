import SwiftUI
import Foundation

// MARK: - Prayer Status
enum PrayerStatus: String, Codable, CaseIterable {
    case prayed = "Prayed"
    case late = "Late"
    case qada = "Qada"
    case missed = "Missed"
    case none = "Not Logged"

    var color: Color {
        switch self {
        case .prayed: return Color("NoorPrimary")
        case .late: return .orange
        case .qada: return Color("NoorAccent")
        case .missed: return .red.opacity(0.7)
        case .none: return Color(.systemGray4)
        }
    }

    var icon: String {
        switch self {
        case .prayed: return "checkmark.circle.fill"
        case .late: return "clock.badge.checkmark.fill"
        case .qada: return "arrow.uturn.backward.circle.fill"
        case .missed: return "xmark.circle.fill"
        case .none: return "circle"
        }
    }

    func localizedName(isMalayalam: Bool) -> String {
        guard isMalayalam else { return rawValue }
        switch self {
        case .prayed: return "നിർവ്വഹിച്ചു"
        case .late: return "വൈകി"
        case .qada: return "ഖദ"
        case .missed: return "വിട്ടുപോയി"
        case .none: return "രേഖപ്പെടുത്തിയിട്ടില്ല"
        }
    }
}

// MARK: - Prayer Day Log
struct PrayerDayLog: Codable, Identifiable {
    var id: String { dateKey }
    let dateKey: String // "yyyy-MM-dd"
    var fajr: PrayerStatus
    var dhuhr: PrayerStatus
    var asr: PrayerStatus
    var maghrib: PrayerStatus
    var isha: PrayerStatus

    func status(for prayer: Prayer) -> PrayerStatus {
        switch prayer {
        case .fajr: return fajr
        case .dhuhr: return dhuhr
        case .asr: return asr
        case .maghrib: return maghrib
        case .isha: return isha
        }
    }

    mutating func setStatus(_ status: PrayerStatus, for prayer: Prayer) {
        switch prayer {
        case .fajr: fajr = status
        case .dhuhr: dhuhr = status
        case .asr: asr = status
        case .maghrib: maghrib = status
        case .isha: isha = status
        }
    }

    var completedCount: Int {
        let all: [PrayerStatus] = [fajr, dhuhr, asr, maghrib, isha]
        return all.filter { s in s == .prayed || s == .late }.count
    }

    var allStatuses: [PrayerStatus] {
        [fajr, dhuhr, asr, maghrib, isha]
    }
}

// MARK: - Qada Entry
struct QadaEntry: Codable, Identifiable {
    var id: String { prayer.rawValue }
    let prayer: Prayer
    var count: Int
}

// MARK: - Dhikr Preset
struct DhikrPreset: Codable, Identifiable {
    var id: UUID
    var name: String
    var arabic: String
    var target: Int
    var currentCount: Int
    var color: String

    var completionText: String { "ماشاء الله" }
}

// MARK: - Store
@MainActor
class SalahStore: ObservableObject {
    @Published var logs: [String: PrayerDayLog] = [:]
    @Published var qadaEntries: [QadaEntry]
    @Published var dhikrPresets: [DhikrPreset]
    @Published var selectedDate: Date = Date()
    @Published var dhikrLifetimeCounts: [UUID: Int] = [:]

    private static let logsKey = "salah_logs"
    private static let qadaKey = "salah_qada"
    private static let dhikrKey = "salah_dhikr"
    private static let dhikrLifetimeKey = "salah_dhikr_lifetime"

    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    init() {
        // Load logs
        if let data = UserDefaults.standard.data(forKey: Self.logsKey),
           let decoded = try? JSONDecoder().decode([String: PrayerDayLog].self, from: data) {
            self.logs = decoded
        }

        // Load qada
        if let data = UserDefaults.standard.data(forKey: Self.qadaKey),
           let decoded = try? JSONDecoder().decode([QadaEntry].self, from: data) {
            self.qadaEntries = decoded
        } else {
            self.qadaEntries = Prayer.allCases.map { QadaEntry(prayer: $0, count: 0) }
        }

        // Load dhikr
        if let data = UserDefaults.standard.data(forKey: Self.dhikrKey),
           let decoded = try? JSONDecoder().decode([DhikrPreset].self, from: data) {
            self.dhikrPresets = decoded
        } else {
            self.dhikrPresets = Self.defaultDhikr()
        }

        // Load lifetime dhikr
        if let data = UserDefaults.standard.data(forKey: Self.dhikrLifetimeKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            var mapped: [UUID: Int] = [:]
            for (k, v) in decoded {
                if let uid = UUID(uuidString: k) { mapped[uid] = v }
            }
            self.dhikrLifetimeCounts = mapped
        }

    }

    // MARK: - Persistence
    func save() {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: Self.logsKey)
        }
        if let data = try? JSONEncoder().encode(qadaEntries) {
            UserDefaults.standard.set(data, forKey: Self.qadaKey)
        }
        if let data = try? JSONEncoder().encode(dhikrPresets) {
            UserDefaults.standard.set(data, forKey: Self.dhikrKey)
        }
        let stringKeyed = Dictionary(uniqueKeysWithValues: dhikrLifetimeCounts.map { (k, v) in (k.uuidString, v) })
        if let data = try? JSONEncoder().encode(stringKeyed) {
            UserDefaults.standard.set(data, forKey: Self.dhikrLifetimeKey)
        }
    }

    // MARK: - Log Access
    func key(for date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    func log(for date: Date) -> PrayerDayLog {
        let k = key(for: date)
        return logs[k] ?? PrayerDayLog(dateKey: k, fajr: .none, dhuhr: .none, asr: .none, maghrib: .none, isha: .none)
    }

    var todayLog: PrayerDayLog {
        log(for: Date())
    }

    func setStatus(_ status: PrayerStatus, prayer: Prayer, date: Date) {
        let k = key(for: date)
        var entry = logs[k] ?? PrayerDayLog(dateKey: k, fajr: .none, dhuhr: .none, asr: .none, maghrib: .none, isha: .none)
        entry.setStatus(status, for: prayer)
        logs[k] = entry
        save()
    }

    // MARK: - Stats
    var currentStreak: Int {
        var count = 0
        let cal = Calendar.current
        let today = Date()
        // If today is incomplete, start counting from yesterday to preserve streak mid-day
        let todayLog = log(for: today)
        var date = todayLog.completedCount == 5 ? today : (cal.date(byAdding: .day, value: -1, to: today) ?? today)
        while true {
            let dayLog = log(for: date)
            if dayLog.completedCount == 5 {
                count += 1
                guard let prev = cal.date(byAdding: .day, value: -1, to: date) else { break }
                date = prev
            } else {
                break
            }
        }
        return count
    }

    var weekCompletion: [Double] {
        let cal = Calendar.current
        let today = Date()
        return (0..<7).reversed().map { offset in
            guard let d = cal.date(byAdding: .day, value: -offset, to: today) else { return 0 }
            return Double(log(for: d).completedCount) / 5.0
        }
    }

    // MARK: - Qada
    func incrementQada(for prayer: Prayer) {
        if let idx = qadaEntries.firstIndex(where: { $0.prayer == prayer }) {
            qadaEntries[idx].count += 1
            save()
        }
    }

    func decrementQada(for prayer: Prayer) {
        if let idx = qadaEntries.firstIndex(where: { $0.prayer == prayer }), qadaEntries[idx].count > 0 {
            qadaEntries[idx].count -= 1
            save()
        }
    }

    // MARK: - Dhikr
    func incrementDhikr(_ id: UUID) {
        if let idx = dhikrPresets.firstIndex(where: { $0.id == id }) {
            dhikrPresets[idx].currentCount += 1
            dhikrLifetimeCounts[id, default: 0] += 1
            save()
        }
    }

    func resetDhikr(_ id: UUID) {
        if let idx = dhikrPresets.firstIndex(where: { $0.id == id }) {
            dhikrPresets[idx].currentCount = 0
            save()
        }
    }

    // MARK: - Weekly Consistency
    var weeklyConsistency: Int {
        let cal = Calendar.current
        let today = Date()
        var total = 0
        var logged = 0
        for offset in 0..<7 {
            guard let d = cal.date(byAdding: .day, value: -offset, to: today) else { continue }
            total += 5
            logged += log(for: d).completedCount
        }
        guard total > 0 else { return 0 }
        return Int(Double(logged) / Double(total) * 100)
    }

    // MARK: - Monthly Summary
    func monthlySummary(for month: Date) -> (logged: Int, bestStreak: Int) {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: month),
              let firstDay = cal.date(from: cal.dateComponents([.year, .month], from: month)) else {
            return (0, 0)
        }
        var totalLogged = 0
        var best = 0
        var current = 0
        for day in range {
            guard let date = cal.date(byAdding: .day, value: day - 1, to: firstDay) else { continue }
            let dayLog = log(for: date)
            totalLogged += dayLog.completedCount
            if dayLog.completedCount == 5 {
                current += 1
                best = max(best, current)
            } else {
                current = 0
            }
        }
        return (totalLogged, best)
    }

    // MARK: - Estimated missed (auto-suggest for Qada)
    var estimatedMissedPrayers: Int {
        let cal = Calendar.current
        let today = Date()
        var missed = 0
        for offset in 0..<30 {
            guard let d = cal.date(byAdding: .day, value: -offset, to: today) else { continue }
            let dayLog = log(for: d)
            for status in dayLog.allStatuses {
                if status == .missed { missed += 1 }
            }
        }
        return missed
    }

    // MARK: - Dhikr totals
    var dhikrSessionTotal: Int {
        dhikrPresets.reduce(0) { $0 + $1.currentCount }
    }

    var dhikrTodayTotal: Int {
        dhikrPresets.reduce(0) { $0 + $1.currentCount }
    }

    var dhikrLifetimeTotal: Int {
        dhikrLifetimeCounts.values.reduce(0, +)
    }

    // MARK: - Reset All
    func resetAll() {
        // Reset in-memory state
        logs = [:]
        qadaEntries = Prayer.allCases.map { QadaEntry(prayer: $0, count: 0) }
        dhikrPresets = Self.defaultDhikr()
        dhikrLifetimeCounts = [:]

        // Preserve language before wiping domain
        let lang = UserDefaults.standard.string(forKey: "appLanguage")

        // Wipe entire domain so @AppStorage bindings update reactively
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        } else {
            // Fallback: remove keys individually when bundle ID is unavailable
            UserDefaults.standard.removeObject(forKey: Self.logsKey)
            UserDefaults.standard.removeObject(forKey: Self.qadaKey)
            UserDefaults.standard.removeObject(forKey: Self.dhikrKey)
            UserDefaults.standard.removeObject(forKey: Self.dhikrLifetimeKey)
        }

        // Restore language
        if let lang { UserDefaults.standard.set(lang, forKey: "appLanguage") }

        // Explicitly write back store keys so observers fire
        UserDefaults.standard.removeObject(forKey: Self.logsKey)
        UserDefaults.standard.removeObject(forKey: Self.qadaKey)
        UserDefaults.standard.removeObject(forKey: Self.dhikrKey)
        UserDefaults.standard.removeObject(forKey: Self.dhikrLifetimeKey)

        // Restore AppStorage defaults so views update immediately
        UserDefaults.standard.set("system",  forKey: "appearanceMode")
        UserDefaults.standard.set(28.0,      forKey: "arabicFontSize")
        UserDefaults.standard.set(true,      forKey: "translationEnabled")
        UserDefaults.standard.set(true,      forKey: "transliterationEnabled")
        UserDefaults.standard.set("Muslim",  forKey: "profileName")
        UserDefaults.standard.set("",        forKey: "profileLocation")
        UserDefaults.standard.set("Hanafi",  forKey: "profileMadhab")

        // Also reset QuranStore shared state
        QuranStore.shared.resetAll()

        resetTrigger += 1
    }

    /// Incrementing this triggers UI refresh via .id(store.resetTrigger) on root views
    @Published var resetTrigger: Int = 0

    // MARK: - Defaults
    private static func defaultDhikr() -> [DhikrPreset] {
        [
            DhikrPreset(id: UUID(), name: "SubhanAllah", arabic: "سُبْحَانَ ٱللَّٰهِ", target: 33, currentCount: 0, color: "NoorPrimary"),
            DhikrPreset(id: UUID(), name: "Alhamdulillah", arabic: "ٱلْحَمْدُ لِلَّٰهِ", target: 33, currentCount: 0, color: "NoorGold"),
            DhikrPreset(id: UUID(), name: "Allahu Akbar", arabic: "ٱللَّٰهُ أَكْبَرُ", target: 34, currentCount: 0, color: "NoorAccent"),
            DhikrPreset(id: UUID(), name: "Astaghfirullah", arabic: "أَسْتَغْفِرُ ٱللَّٰهَ", target: 100, currentCount: 0, color: "NoorSecondary"),
        ]
    }

    private func seedSampleData() {
        let cal = Calendar.current
        let today = Date()
        let statuses: [PrayerStatus] = [.prayed, .prayed, .prayed, .late, .missed, .prayed]
        for dayOffset in 1...14 {
            guard let date = cal.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let k = key(for: date)
            let pick: () -> PrayerStatus = { statuses[Int.random(in: 0..<statuses.count)] }
            logs[k] = PrayerDayLog(dateKey: k, fajr: pick(), dhuhr: pick(), asr: pick(), maghrib: pick(), isha: pick())
        }
        // Today partial
        let tk = key(for: today)
        logs[tk] = PrayerDayLog(dateKey: tk, fajr: .prayed, dhuhr: .prayed, asr: .prayed, maghrib: .none, isha: .none)
        save()
    }
}
