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

// MARK: - Custom Errors
enum QuranFetchError: LocalizedError {
    case networkUnavailable
    case serverError(Int)
    case decodingFailed
    case timeout

    var errorDescription: String? {
        switch self {
        case .networkUnavailable: return "No internet connection. Showing cached content."
        case .serverError(let code): return "Server error (\(code)). Please try again."
        case .decodingFailed: return "Unable to read Quran data. Please retry."
        case .timeout: return "Request timed out. Check your connection."
        }
    }
}

// MARK: - API Service
class QuranAPIService {
    static let shared = QuranAPIService()
    private let memoryCache = NSCache<NSString, NSArray>()

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = 15
        config.timeoutIntervalForResource = 30
        config.waitsForConnectivity = true
        return URLSession(configuration: config)
    }()

    func fetchVerses(surahId: Int) async throws -> [Verse] {
        let key = NSString(string: "surah-\(surahId)")

        // 1. Memory cache hit
        if let cached = memoryCache.object(forKey: key) as? [Verse] {
            NSLog("[QuranAPI] Memory cache hit for surah \(surahId)")
            return cached
        }

        // 2. Disk cache hit
        if let diskCached = OfflineCacheService.shared.loadCachedVerses(surahId: surahId) {
            NSLog("[QuranAPI] Disk cache hit for surah \(surahId)")
            memoryCache.setObject(diskCached as NSArray, forKey: key)
            return diskCached
        }

        // 3. Network fetch with retry
        NSLog("[QuranAPI] Fetching surah \(surahId) from network…")
        return try await fetchWithRetry(surahId: surahId, attempts: 2)
    }

    private func fetchWithRetry(surahId: Int, attempts: Int) async throws -> [Verse] {
        var lastError: Error?
        for attempt in 1...max(1, attempts) {
            do {
                let verses = try await fetchFromNetwork(surahId: surahId)
                return verses
            } catch {
                lastError = error
                NSLog("[QuranAPI] Attempt \(attempt) failed: %@", error.localizedDescription)
                if attempt < attempts {
                    try? await Task.sleep(nanoseconds: 800_000_000) // 0.8s back-off
                }
            }
        }
        throw lastError ?? QuranFetchError.networkUnavailable
    }

    private func fetchFromNetwork(surahId: Int) async throws -> [Verse] {
        guard let arabicURL = URL(string: "https://api.alquran.cloud/v1/surah/\(surahId)/ar.alafasy"),
              let transURL  = URL(string: "https://api.alquran.cloud/v1/surah/\(surahId)/en.sahih") else {
            throw QuranFetchError.networkUnavailable
        }

        async let arabicFetch = fetchData(from: arabicURL)
        async let transFetch  = fetchData(from: transURL)

        let (arabicData, transData) = try await (arabicFetch, transFetch)

        let arabicResponse: QuranAPIResponse
        let transResponse: TranslationResponse
        do {
            arabicResponse = try JSONDecoder().decode(QuranAPIResponse.self, from: arabicData)
            transResponse  = try JSONDecoder().decode(TranslationResponse.self, from: transData)
        } catch {
            throw QuranFetchError.decodingFailed
        }

        let transMap = Dictionary(uniqueKeysWithValues: transResponse.data.ayahs.map { ($0.numberInSurah, $0.text) })

        let verses = arabicResponse.data.ayahs.map { ayah in
            Verse(
                surahId: surahId,
                number: ayah.numberInSurah,
                arabic: ayah.text,
                translation: transMap[ayah.numberInSurah] ?? ""
            )
        }

        let key = NSString(string: "surah-\(surahId)")
        memoryCache.setObject(verses as NSArray, forKey: key)
        OfflineCacheService.shared.cacheVerses(verses, surahId: surahId)
        NSLog("[QuranAPI] Fetched and cached \(verses.count) verses for surah \(surahId)")
        return verses
    }

    private func fetchData(from url: URL) async throws -> Data {
        do {
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                throw QuranFetchError.serverError(http.statusCode)
            }
            return data
        } catch let error as QuranFetchError {
            throw error
        } catch let urlError as URLError {
            NSLog("[QuranAPI] URLError: %@ (code: %d)", urlError.localizedDescription, urlError.code.rawValue)
            switch urlError.code {
            case .timedOut: throw QuranFetchError.timeout
            case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost,
                 .cannotConnectToHost, .dnsLookupFailed: throw QuranFetchError.networkUnavailable
            default: throw QuranFetchError.networkUnavailable
            }
        }
    }

    func fetchTafsir(surahId: Int) async throws -> [Int: String] {
        guard let url = URL(string: "https://api.alquran.cloud/v1/surah/\(surahId)/en.ibn-kathir") else {
            throw QuranFetchError.networkUnavailable
        }
        let data = try await fetchData(from: url)
        let response = try JSONDecoder().decode(TafsirResponse.self, from: data)
        return Dictionary(uniqueKeysWithValues: response.data.ayahs.map { ($0.numberInSurah, $0.text) })
    }

    func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
}
