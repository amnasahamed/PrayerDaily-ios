import Foundation

// MARK: - Tab Model
enum AppTab: String, CaseIterable {
    case home = "Home"
    case quran = "Quran"
    case salah = "Salah"
    case library = "Library"
    case more = "More"

    var icon: String {
        switch self {
        case .home: return "moon.stars.fill"
        case .quran: return "book.fill"
        case .salah: return "clock.fill"
        case .library: return "books.vertical.fill"
        case .more: return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Prayer
enum Prayer: String, CaseIterable, Identifiable, Codable {
    case fajr = "Fajr"
    case dhuhr = "Dhuhr"
    case asr = "Asr"
    case maghrib = "Maghrib"
    case isha = "Isha"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .fajr: return "sunrise.fill"
        case .dhuhr: return "sun.max.fill"
        case .asr: return "sun.haze.fill"
        case .maghrib: return "sunset.fill"
        case .isha: return "moon.fill"
        }
    }
}

// MARK: - Surah
struct Surah: Identifiable {
    let id: Int
    let nameArabic: String
    let nameEnglish: String
    let verses: Int
    let type: String
}

// MARK: - Hadith
struct Hadith: Identifiable {
    let id: Int
    let narrator: String
    let textEnglish: String
    let source: String
}

// MARK: - Dua
struct Dua: Identifiable {
    let id: Int
    let title: String
    let arabic: String
    let transliteration: String
    let translation: String
    let category: String
}

// MARK: - Reading Streak
struct ReadingStreak {
    var currentDays: Int
    var bestDays: Int
    var todayRead: Bool
    var pagesReadToday: Int
}

// MARK: - Salah Log Entry
struct SalahLogEntry: Identifiable {
    let id = UUID()
    let prayer: Prayer
    var completed: Bool
    let date: Date
}

// MARK: - Knowledge Category
struct KnowledgeCategory: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let count: Int
    let color: String
}
