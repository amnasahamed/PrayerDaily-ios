import SwiftUI

struct SurahReaderView: View {
    let surah: SurahInfo
    @StateObject private var store = QuranStore.shared
    @State private var verses: [Verse] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showTranslation = true

    var body: some View {
        ZStack {
            Color("NoorSurface").ignoresSafeArea()
            if isLoading {
                loadingView
            } else if let error = errorMessage {
                errorView(error)
            } else {
                verseScrollView
            }
        }
        .navigationTitle(surah.nameEnglish)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarItems }
        .task { await loadVerses() }
        .onDisappear { store.stopAudio() }
    }

    // MARK: - Loading
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading Surah...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Error
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") { Task { await loadVerses() } }
                .buttonStyle(.borderedProminent)
                .tint(Color("NoorPrimary"))
        }
        .padding()
    }

    // MARK: - Verse List
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
                        isBookmarked: store.isBookmarked(surahId: verse.surahId, verse: verse.number)
                    )
                    .onAppear {
                        store.setLastRead(surahId: surah.id, verse: verse.number)
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
                        .font(.system(size: 26))
                        .foregroundStyle(Color("NoorPrimary"))
                        .multilineTextAlignment(.center)
                    Text("In the name of Allah, the Most Gracious, the Most Merciful")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color("NoorPrimary").opacity(0.05))
            }
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                withAnimation { showTranslation.toggle() }
            } label: {
                Image(systemName: showTranslation ? "text.book.closed.fill" : "text.book.closed")
                    .foregroundStyle(Color("NoorPrimary"))
            }
        }
    }

    // MARK: - Data
    private func loadVerses() async {
        isLoading = true
        errorMessage = nil
        do {
            verses = try await QuranAPIService.shared.fetchVerses(surahId: surah.id)
            isLoading = false
        } catch {
            errorMessage = "Unable to load verses.\nPlease check your internet connection."
            isLoading = false
        }
    }
}
