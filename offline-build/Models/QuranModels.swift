import Foundation

// MARK: - Quran Models
struct QuranSurah: Identifiable, Hashable {
    let id: Int
    let nameArabic: String
    let nameEnglish: String
    let nameTransliteration: String
    let verses: Int
    let type: RevelationType
    let meaning: String
    let juz: Int

    enum RevelationType: String {
        case meccan = "Meccan"
        case medinan = "Medinan"

        var color: String {
            switch self {
            case .meccan: return "NoorGold"
            case .medinan: return "NoorAccent"
            }
        }
    }
}

struct QuranVerse: Identifiable {
    let id: Int          // verse number in surah
    let arabic: String
    let translation: String
    let words: [QuranWord]
}

struct QuranWord: Identifiable {
    let id: Int
    let arabic: String
    let transliteration: String
    let meaning: String
}

struct QuranBookmark: Identifiable, Codable {
    let id: UUID
    let surahId: Int
    let verseId: Int
    let note: String
    let date: Date

    init(surahId: Int, verseId: Int, note: String = "") {
        self.id = UUID()
        self.surahId = surahId
        self.verseId = verseId
        self.note = note
        self.date = Date()
    }
}
