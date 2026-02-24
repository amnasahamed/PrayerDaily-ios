import Foundation

// MARK: - Offline Cache
class OfflineCacheService {
    static let shared = OfflineCacheService()
    private let fileManager = FileManager.default

    private var cacheDir: URL {
        let docs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("QuranCache", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    // MARK: - Surah Verses Cache
    func cacheVerses(_ verses: [Verse], surahId: Int) {
        let items = verses.map { CachedVerse(surahId: $0.surahId, number: $0.number, arabic: $0.arabic, translation: $0.translation) }
        let file = cacheDir.appendingPathComponent("surah_\(surahId).json")
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: file)
        }
    }

    func loadCachedVerses(surahId: Int) -> [Verse]? {
        let file = cacheDir.appendingPathComponent("surah_\(surahId).json")
        guard let data = try? Data(contentsOf: file),
              let items = try? JSONDecoder().decode([CachedVerse].self, from: data) else { return nil }
        return items.map { Verse(surahId: $0.surahId, number: $0.number, arabic: $0.arabic, translation: $0.translation) }
    }

    func isSurahCached(_ surahId: Int) -> Bool {
        let file = cacheDir.appendingPathComponent("surah_\(surahId).json")
        return fileManager.fileExists(atPath: file.path)
    }

    func cachedSurahCount() -> Int {
        let files = (try? fileManager.contentsOfDirectory(atPath: cacheDir.path)) ?? []
        return files.filter { $0.hasPrefix("surah_") && $0.hasSuffix(".json") }.count
    }

    func clearCache() {
        let files = (try? fileManager.contentsOfDirectory(atPath: cacheDir.path)) ?? []
        for f in files {
            try? fileManager.removeItem(at: cacheDir.appendingPathComponent(f))
        }
    }

    func cacheSizeString() -> String {
        let files = (try? fileManager.contentsOfDirectory(atPath: cacheDir.path)) ?? []
        var total: Int64 = 0
        for f in files {
            let path = cacheDir.appendingPathComponent(f)
            if let attrs = try? fileManager.attributesOfItem(atPath: path.path),
               let size = attrs[.size] as? Int64 {
                total += size
            }
        }
        if total < 1024 { return "\(total) B" }
        if total < 1024 * 1024 { return "\(total / 1024) KB" }
        return String(format: "%.1f MB", Double(total) / (1024 * 1024))
    }
}

// MARK: - Cached Model
struct CachedVerse: Codable {
    let surahId: Int
    let number: Int
    let arabic: String
    let translation: String
}
