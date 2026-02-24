import Foundation

// MARK: - API Response Models
struct QuranAPIResponse: Codable {
    let data: QuranAPIData
}

struct QuranAPIData: Codable {
    let ayahs: [APIAyah]
}

struct APIAyah: Codable {
    let number: Int
    let text: String
    let numberInSurah: Int
}

struct TranslationResponse: Codable {
    let data: TranslationData
}

struct TranslationData: Codable {
    let ayahs: [TranslationAyah]
}

struct TranslationAyah: Codable {
    let numberInSurah: Int
    let text: String
}

// MARK: - API Service
class QuranAPIService {
    static let shared = QuranAPIService()
    private let cache = NSCache<NSString, NSArray>()

    func fetchVerses(surahId: Int) async throws -> [Verse] {
        let key = NSString(string: "surah-\(surahId)")
        if let cached = cache.object(forKey: key) as? [Verse] {
            return cached
        }

        let arabicURL = URL(string: "https://api.alquran.cloud/v1/surah/\(surahId)/ar.alafasy")!
        let transURL = URL(string: "https://api.alquran.cloud/v1/surah/\(surahId)/en.sahih")!

        async let arabicData = URLSession.shared.data(from: arabicURL)
        async let transData = URLSession.shared.data(from: transURL)

        let (arabicResult, transResult) = try await (arabicData, transData)

        let arabicResponse = try JSONDecoder().decode(QuranAPIResponse.self, from: arabicResult.0)
        let transResponse = try JSONDecoder().decode(TranslationResponse.self, from: transResult.0)

        let transMap = Dictionary(uniqueKeysWithValues: transResponse.data.ayahs.map { ($0.numberInSurah, $0.text) })

        let verses = arabicResponse.data.ayahs.map { ayah in
            Verse(
                surahId: surahId,
                number: ayah.numberInSurah,
                arabic: ayah.text,
                translation: transMap[ayah.numberInSurah] ?? ""
            )
        }

        cache.setObject(verses as NSArray, forKey: key)
        return verses
    }
}
