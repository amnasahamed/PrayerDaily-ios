import SwiftUI

struct SurahReaderView: View {
    let surah: SurahInfo
    @StateObject private var store = QuranStore.shared
    @State private var verses: [Verse] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showTranslation = true
    @State private var tafsirMap: [Int: String] = [:]
    @State private var selectedVerse: Verse?
    @State private var isCached = false

    var body: some View {
        ZStack {
            Color("NoorSurface").ignoresSafeArea()
            if isLoading { loadingView }
            else if let error = errorMessage { errorView(error) }
            else { verseScrollView }
        }
        .navigationTitle(surah.nameEnglish)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarItems }
        .task { await loadVerses() }
        .onDisappear { store.stopAudio() }
        .sheet(item: $selectedVerse) { verse in
            TafsirSheetView(verse: verse, tafsirText: tafsirMap[verse.number])
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.2)
            Text("Loading Surah...")
                .font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash").font(.system(size: 40)).foregroundStyle(.secondary)
            Text(message).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button("Retry") { Task { await loadVerses() } }
                .buttonStyle(.borderedProminent).tint(Color("NoorPrimary"))
        }
        .padding()
    }

    private var verseScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                bismillahHeader
                ForEach(verses) { verse in
                    VerseRowView(
                        verse: verse,
                        showTranslation: showTranslation,
                        audioState: store.audioState,
                        onPlay: { store.togglePause(surahId: verse.surahId, verseNum: verse.number) },
                        onBookmark: { store.toggleBookmark(surahId: verse.surahId, verse: verse.number) },
                        isBookmarked: store.isBookmarked(surahId: verse.surahId, verse: verse.number),
                        onTafsir: { selectedVerse = verse },
                        surahName: surah.nameEnglish
                    )
                    .onAppear {
                        store.setLastRead(surahId: surah.id, verse: verse.number)
                        store.updateProgress(surahId: surah.id, verse: verse.number, totalVerses: surah.verses)
                    }
                }
            }
            .padding(.bottom, 60)
        }
    }

    private var bismillahHeader: some View {
        Group {
            if surah.id != 9 {
                VStack(spacing: 8) {
                    Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                        .font(.system(size: 26)).foregroundStyle(Color("NoorPrimary")).multilineTextAlignment(.center)
                    Text("In the name of Allah, the Most Gracious, the Most Merciful")
                        .font(.caption).foregroundStyle(.secondary)
                    if isCached {
                        Label("Available Offline", systemImage: "arrow.down.circle.fill")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(Color("NoorPrimary"))
                    }
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color("NoorPrimary").opacity(0.05))
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 12) {
                Button { withAnimation { showTranslation.toggle() } } label: {
                    Image(systemName: showTranslation ? "text.book.closed.fill" : "text.book.closed")
                        .foregroundStyle(Color("NoorPrimary"))
                }
                Button { Task { await loadTafsir() } } label: {
                    Image(systemName: tafsirMap.isEmpty ? "doc.text.magnifyingglass" : "doc.text.fill")
                        .foregroundStyle(Color("NoorGold"))
                }
            }
        }
    }

    private func loadVerses() async {
        isLoading = true; errorMessage = nil
        do {
            verses = try await QuranAPIService.shared.fetchVerses(surahId: surah.id)
            isCached = OfflineCacheService.shared.isSurahCached(surah.id)
            isLoading = false
        } catch {
            errorMessage = "Unable to load verses.\nPlease check your internet connection."
            isLoading = false
        }
    }

    private func loadTafsir() async {
        guard tafsirMap.isEmpty else { return }
        do {
            tafsirMap = try await QuranAPIService.shared.fetchTafsir(surahId: surah.id)
        } catch {
            // silently fail — tafsir is optional
        }
    }
}

// Make Verse Identifiable for sheet
extension Verse: Hashable {
    static func == (lhs: Verse, rhs: Verse) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
