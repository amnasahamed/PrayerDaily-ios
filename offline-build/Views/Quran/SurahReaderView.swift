import SwiftUI

struct SurahReaderView: View {
    let surah: SurahInfo
    @StateObject private var store = QuranStore.shared
    @State private var verses: [Verse] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var readingMode: ReadingMode = .both
    @State private var tafsirMap: [Int: String] = [:]
    @State private var selectedVerse: Verse?
    @State private var isCached = false
    @State private var appeared = false

    @Environment(\.arabicFontSize) private var arabicFontSize
    @Environment(\.translationEnabled) private var translationEnabled
    @Environment(\.transliterationEnabled) private var transliterationEnabled

    private var showArabic: Bool { readingMode != .translationOnly }
    private var showTranslation: Bool {
        translationEnabled && (readingMode == .both || readingMode == .translationOnly)
    }
    private var isFocusMode: Bool { readingMode == .focus }

    var body: some View {
        ZStack {
            focusBackground
            VStack(spacing: 0) {
                ReadingModeBar(mode: $readingMode)
                Divider().opacity(0.3)
                if isLoading { loadingView }
                else if let error = errorMessage { errorView(error) }
                else { verseScrollView }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarItems }
        .task { await loadVerses() }
        .onDisappear { store.stopAudio() }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82).delay(0.05)) { appeared = true }
        }
        .sheet(item: $selectedVerse) { verse in
            TafsirSheetView(verse: verse, tafsirText: tafsirMap[verse.number])
        }
    }

    // MARK: - Focus background
    @ViewBuilder
    private var focusBackground: some View {
        if isFocusMode {
            Color.black.ignoresSafeArea()
        } else {
            Color("NoorSurface").ignoresSafeArea()
        }
    }

    // MARK: - Loading / Error
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView().scaleEffect(1.2)
            Text("Loading Surah…").font(.subheadline).foregroundStyle(.secondary)
            Spacer()
        }
    }

    private func errorView(_ msg: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "wifi.slash").font(.system(size: 40)).foregroundStyle(.secondary)
            Text(msg).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button("Retry") { Task { await loadVerses() } }
                .buttonStyle(.borderedProminent).tint(Color("NoorPrimary"))
            Spacer()
        }.padding()
    }

    // MARK: - Verses
    private var verseScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                compactBismillah
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.spring(response: 0.5, dampingFraction: 0.82).delay(0.1), value: appeared)
                ForEach(Array(verses.enumerated()), id: \.element.id) { index, verse in
                    verseItem(verse: verse, index: index)
                }
            }
            .padding(.bottom, 80)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    @ViewBuilder
    private func verseItem(verse: Verse, index: Int) -> some View {
        VerseRowView(
            verse: verse,
            showTranslation: showTranslation,
            showArabic: showArabic,
            isFocusMode: isFocusMode,
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

        // Reflection prompt every 5 ayahs
        if (index + 1) % 5 == 0 && readingMode != .arabicOnly {
            ReflectionPromptView(verseNumber: index + 1, surahId: surah.id)
                .padding(.vertical, 4)
        }
    }

    // MARK: - Bismillah header (compact)
    private var compactBismillah: some View {
        Group {
            if surah.id != 9 {
                VStack(spacing: 6) {
                    Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                        .font(.system(size: isFocusMode ? 22 : 24))
                        .foregroundStyle(isFocusMode ? .white : Color("NoorPrimary"))
                        .multilineTextAlignment(.center)

                    if readingMode == .both || readingMode == .translationOnly {
                        Text("In the name of Allah, the Most Gracious, the Most Merciful")
                            .font(.caption)
                            .foregroundStyle(isFocusMode ? .white.opacity(0.6) : .secondary)
                    }

                    HStack(spacing: 12) {
                        if isCached {
                            Label("Offline", systemImage: "arrow.down.circle.fill")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(Color("NoorPrimary"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color("NoorPrimary").opacity(0.1))
                                .clipShape(Capsule())
                        }
                        surahTypeBadge
                    }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .background(bismillahBg)
            }
        }
    }

    private var surahTypeBadge: some View {
        Text("\(surah.type) • \(surah.verses) Ayahs")
            .font(.caption2.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color("NoorSurface"))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.secondary.opacity(0.2), lineWidth: 1))
    }

    @ViewBuilder
    private var bismillahBg: some View {
        if isFocusMode {
            Color.white.opacity(0.05)
        } else {
            Color("NoorPrimary").opacity(0.05)
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack(spacing: 1) {
                Text(surah.nameEnglish)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(isFocusMode ? .white : .primary)
                Text(surah.nameArabic)
                    .font(.caption)
                    .foregroundStyle(isFocusMode ? .white.opacity(0.6) : Color("NoorPrimary"))
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button { Task { await loadTafsir() } } label: {
                Image(systemName: tafsirMap.isEmpty ? "doc.text.magnifyingglass" : "doc.text.fill")
                    .foregroundStyle(Color("NoorGold"))
            }
        }
    }

    // MARK: - Data
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
        do { tafsirMap = try await QuranAPIService.shared.fetchTafsir(surahId: surah.id) } catch {}
    }
}

extension Verse: Hashable {
    static func == (lhs: Verse, rhs: Verse) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
