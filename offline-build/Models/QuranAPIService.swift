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

// MARK: - Tafsir Response
struct TafsirResponse: Codable {
    let data: TafsirData
}

struct TafsirData: Codable {
    let ayahs: [TafsirAyah]
}

struct TafsirAyah: Codable {
    let numberInSurah: Int
    let text: String
}

// MARK: - API Service
class QuranAPIService {
    static let shared = QuranAPIService()
    private let memoryCache = NSCache<NSString, NSArray>()

    func fetchVerses(surahId: Int) async throws -> [Verse] {
        let key = NSString(string: "surah-\(surahId)")
        if let cached = memoryCache.object(forKey: key) as? [Verse] {
            return cached
        }

        // Check disk cache
        if let diskCached = OfflineCacheService.shared.loadCachedVerses(surahId: surahId) {
            memoryCache.setObject(diskCached as NSArray, forKey: key)
            return diskCached
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

        memoryCache.setObject(verses as NSArray, forKey: key)
        OfflineCacheService.shared.cacheVerses(verses, surahId: surahId)
        return verses
    }

    func fetchTafsir(surahId: Int) async throws -> [Int: String] {
        let url = URL(string: "https://api.alquran.cloud/v1/surah/\(surahId)/en.ibn-kathir")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TafsirResponse.self, from: data)
        return Dictionary(uniqueKeysWithValues: response.data.ayahs.map { ($0.numberInSurah, $0.text) })
    }
}
