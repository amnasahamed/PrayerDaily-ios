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
}

// MARK: - Store
@MainActor
class SalahStore: ObservableObject {
    @Published var logs: [String: PrayerDayLog] = [:]
    @Published var qadaEntries: [QadaEntry]
    @Published var dhikrPresets: [DhikrPreset]
    @Published var selectedDate: Date = Date()

    private static let logsKey = "salah_logs"
    private static let qadaKey = "salah_qada"
    private static let dhikrKey = "salah_dhikr"

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

        // Seed sample data if empty
        if logs.isEmpty {
            seedSampleData()
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
        var date = Date()
        let cal = Calendar.current
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
            save()
        }
    }

    func resetDhikr(_ id: UUID) {
        if let idx = dhikrPresets.firstIndex(where: { $0.id == id }) {
            dhikrPresets[idx].currentCount = 0
            save()
        }
    }

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
