import Foundation
import AVFoundation
import Combine
import UIKit

// MARK: - Full Surah Data
struct SurahInfo: Identifiable, Hashable {
    let id: Int
    let nameArabic: String
    let nameEnglish: String
    let nameTransliteration: String
    let meaning: String
    let verses: Int
    let type: String
    let juz: Int
    let nameMalayalam: String

    func localizedName(isMalayalam: Bool) -> String {
        isMalayalam ? nameMalayalam : nameEnglish
    }
}

// MARK: - Verse
struct Verse: Identifiable {
    var id: String { "\(surahId)-\(number)" }
    let surahId: Int
    let number: Int
    let arabic: String
    let translation: String
}

// MARK: - Audio State
enum AudioPlayState: Equatable {
    case idle
    case loading
    case playing(surahId: Int, verseNum: Int)
    case paused(surahId: Int, verseNum: Int)
}

// MARK: - Quran Store
@MainActor
class QuranStore: ObservableObject {
    @Published var bookmarks: Set<String> = [] // "surahId-verseNum"
    @Published var lastRead: (surahId: Int, verse: Int)? = nil
    @Published var audioState: AudioPlayState = .idle
    @Published var surahProgress: [Int: Double] = [:] // surahId -> 0.0-1.0

    private var player: AVPlayer?
    private var playerObserver: Any?

    private static let bookmarksKey   = "quran_bookmarks"
    private static let lastReadKey    = "quran_lastRead"
    private static let progressKey    = "quran_progress"

    static let shared = QuranStore()

    init() {
        // Load bookmarks
        if let arr = UserDefaults.standard.array(forKey: Self.bookmarksKey) as? [String] {
            bookmarks = Set(arr)
        }
        // Load lastRead
        if let arr = UserDefaults.standard.array(forKey: Self.lastReadKey) as? [Int], arr.count == 2 {
            lastRead = (arr[0], arr[1])
        }
        // Load progress
        if let data = UserDefaults.standard.data(forKey: Self.progressKey),
           let decoded = try? JSONDecoder().decode([Int: Double].self, from: data) {
            surahProgress = decoded
        }
    }

    private func saveBookmarks() {
        UserDefaults.standard.set(Array(bookmarks), forKey: Self.bookmarksKey)
    }

    private func saveLastRead() {
        if let lr = lastRead {
            UserDefaults.standard.set([lr.surahId, lr.verse], forKey: Self.lastReadKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.lastReadKey)
        }
    }

    private func saveProgress() {
        if let data = try? JSONEncoder().encode(surahProgress) {
            UserDefaults.standard.set(data, forKey: Self.progressKey)
        }
    }

    func updateProgress(surahId: Int, verse: Int, totalVerses: Int) {
        guard totalVerses > 0 else { return }
        let current = surahProgress[surahId] ?? 0.0
        let newProgress = Double(verse) / Double(totalVerses)
        if newProgress > current {
            surahProgress[surahId] = newProgress
            saveProgress()
        }
    }

    func progress(for surahId: Int) -> Double {
        surahProgress[surahId] ?? 0.0
    }

    var overallProgress: Double {
        let total = 114.0
        let started = Double(surahProgress.filter { $0.value >= 1.0 }.count)
        return started / total
    }

    func toggleBookmark(surahId: Int, verse: Int) {
        let key = "\(surahId)-\(verse)"
        if bookmarks.contains(key) {
            bookmarks.remove(key)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        } else {
            bookmarks.insert(key)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                generator.impactOccurred(intensity: 0.6)
            }
        }
        saveBookmarks()
    }

    func isBookmarked(surahId: Int, verse: Int) -> Bool {
        bookmarks.contains("\(surahId)-\(verse)")
    }

    func setLastRead(surahId: Int, verse: Int) {
        lastRead = (surahId, verse)
        saveLastRead()
    }

    func resetAll() {
        bookmarks = []
        lastRead = nil
        surahProgress = [:]
        stopAudio()
        UserDefaults.standard.removeObject(forKey: Self.bookmarksKey)
        UserDefaults.standard.removeObject(forKey: Self.lastReadKey)
        UserDefaults.standard.removeObject(forKey: Self.progressKey)
    }

    // MARK: - Audio
    func playVerse(surahId: Int, verseNum: Int) {
        stopAudio()
        audioState = .loading

        _ = String(format: "%03d", surahId)
        _ = String(format: "%03d", verseNum)
        let urlString = "https://cdn.islamic.network/quran/audio/128/ar.alafasy/\(computeAbsoluteVerse(surah: surahId, verse: verseNum)).mp3"

        guard let url = URL(string: urlString) else {
            audioState = .idle
            return
        }

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)

        playerObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.audioState = .idle
            }
        }

        player?.play()
        audioState = .playing(surahId: surahId, verseNum: verseNum)
    }

    func stopAudio() {
        player?.pause()
        player = nil
        if let obs = playerObserver {
            NotificationCenter.default.removeObserver(obs)
            playerObserver = nil
        }
        audioState = .idle
    }

    func togglePause(surahId: Int, verseNum: Int) {
        switch audioState {
        case .playing(let s, let v) where s == surahId && v == verseNum:
            player?.pause()
            audioState = .paused(surahId: s, verseNum: v)
        case .paused(let s, let v) where s == surahId && v == verseNum:
            player?.play()
            audioState = .playing(surahId: s, verseNum: v)
        default:
            playVerse(surahId: surahId, verseNum: verseNum)
        }
    }

    // Compute absolute verse number for audio API
    private func computeAbsoluteVerse(surah: Int, verse: Int) -> Int {
        let verseCounts = [0,7,286,200,176,120,165,206,75,129,109,123,111,43,52,99,128,111,110,98,135,112,78,118,64,77,227,93,88,69,60,34,30,73,54,45,83,182,88,75,85,54,53,89,59,37,35,38,29,18,45,60,49,62,55,78,96,29,22,24,13,14,11,11,18,12,12,30,52,52,44,28,28,20,56,40,31,50,40,46,42,29,19,36,25,22,17,19,26,30,20,15,21,11,8,8,19,5,8,8,11,11,8,3,9,5,4,7,3,6,3,5,4,5,6]
        var total = 0
        for i in 1..<surah {
            if i < verseCounts.count { total += verseCounts[i] }
        }
        return total + verse
    }
}
