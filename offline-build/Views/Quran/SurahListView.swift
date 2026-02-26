import SwiftUI

// MARK: - Filter Type
enum SurahFilter: String, CaseIterable {
    case all = "All"
    case juz = "Juz"
    case meccan = "Meccan"
    case medinan = "Medinan"
    case completed = "Completed"

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .juz: return "list.number"
        case .meccan: return "sun.max"
        case .medinan: return "moon.stars"
        case .completed: return "checkmark.seal"
        }
    }
}

// MARK: - Main View
struct SurahListView: View {
    @StateObject private var store = QuranStore.shared
    @State private var searchText = ""
    @State private var activeFilter: SurahFilter = .all
    @State private var selectedJuz: Int = 1

    private var filteredSurahs: [SurahInfo] {
        var list = QuranData.allSurahs
        switch activeFilter {
        case .all: break
        case .juz: list = list.filter { $0.juz == selectedJuz }
        case .meccan: list = list.filter { $0.type == "Meccan" }
        case .medinan: list = list.filter { $0.type == "Medinan" }
        case .completed: list = list.filter { store.progress(for: $0.id) >= 1.0 }
        }
        if !searchText.isEmpty {
            list = list.filter {
                $0.nameEnglish.localizedCaseInsensitiveContains(searchText) ||
                $0.nameArabic.contains(searchText) ||
                $0.nameTransliteration.localizedCaseInsensitiveContains(searchText) ||
                "\($0.id)" == searchText
            }
        }
        return list
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("NoorSurface").ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        continueReadingCard
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 8)

                        Section(header: stickyFilterBar) {
                            if activeFilter == .juz { juzPickerRow }
                            surahListContent
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search surahs...")
            .navigationTitle(LocalizationManager.shared.t(.quranTitle))
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Continue Reading Card
    private var continueReadingCard: some View {
        let surahId = store.lastRead?.surahId ?? 1
        let verseNum = store.lastRead?.verse ?? 1
        let surahInfo = QuranData.allSurahs.first { $0.id == surahId }
        let surahName = surahInfo?.nameEnglish ?? "Al-Fatihah"
        let totalVerses = surahInfo?.verses ?? 7
        let pct = store.progress(for: surahId)
        let overall = store.overallProgress

        return NavigationLink(destination: surahReaderDestination) {
            HStack(spacing: 14) {
                continueIcon
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Continue Reading")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("NoorGold"))
                        Spacer()
                        Text(String(format: "%.0f%% of Quran", overall * 100))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Text("\(surahName), Ayah \(verseNum)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    HStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(.white.opacity(0.2)).frame(height: 4)
                                Capsule().fill(Color("NoorGold"))
                                    .frame(width: geo.size.width * pct, height: 4)
                            }
                        }
                        .frame(height: 4)
                        Text(String(format: "%.0f%%", pct * 100))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))
                            .frame(width: 30, alignment: .trailing)
                    }
                    Text(readingTimeEstimate(verse: verseNum, total: totalVerses))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.6))
                }
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(16)
            .background(
                LinearGradient(colors: [Color("NoorPrimary"), Color("NoorSecondary")],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private var continueIcon: some View {
        ZStack {
            Circle().fill(.white.opacity(0.15)).frame(width: 44, height: 44)
            Image(systemName: "book.fill")
                .font(.system(size: 18))
                .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private var surahReaderDestination: some View {
        let surahId = store.lastRead?.surahId ?? 1
        if let surah = QuranData.allSurahs.first(where: { $0.id == surahId }) {
            SurahReaderView(surah: surah)
        }
    }

    private func readingTimeEstimate(verse: Int, total: Int) -> String {
        let remaining = max(0, total - verse)
        let mins = max(1, remaining / 5)
        return "~\(mins) min remaining"
    }

    // MARK: - Sticky Filter Bar
    private var stickyFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SurahFilter.allCases, id: \.self) { filter in
                    filterChip(filter)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color("NoorSurface").opacity(0.98))
    }

    private func filterChip(_ filter: SurahFilter) -> some View {
        let isSelected = activeFilter == filter
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { activeFilter = filter }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: filter.icon)
                    .font(.caption2.weight(.semibold))
                Text(filter.rawValue)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .background(isSelected ? Color("NoorPrimary") : Color("NoorCardBg"))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color("NoorPrimary").opacity(isSelected ? 0 : 0.2), lineWidth: 1))
        }
    }

    // MARK: - Juz Picker
    private var juzPickerRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(1...30, id: \.self) { j in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { selectedJuz = j }
                    } label: {
                        Text("\(j)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(selectedJuz == j ? .white : Color("NoorPrimary"))
                            .frame(width: 32, height: 32)
                            .background(selectedJuz == j ? Color("NoorPrimary") : Color("NoorPrimary").opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    // MARK: - List
    private var surahListContent: some View {
        LazyVStack(spacing: 1) {
            if filteredSurahs.isEmpty { emptyState }
            else {
                ForEach(filteredSurahs) { surah in
                    NavigationLink(destination: SurahReaderView(surah: surah)) {
                        SurahRowView(surah: surah, progress: store.progress(for: surah.id))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, 16)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.bottom, 20)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color("NoorPrimary").opacity(0.3))
            Text("No Surahs Yet")
                .font(.headline).foregroundStyle(.secondary)
            Text("Start reading to track your progress")
                .font(.caption).foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Surah Row
struct SurahRowView: View {
    let surah: SurahInfo
    let progress: Double
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 14) {
            surahNumber
            surahInfo
            Spacer()
            arabicName
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(rowBg)
    }

    private var rowBg: some View {
        colorScheme == .dark ? Color(.systemGray6) : Color.white
    }

    private var surahNumber: some View {
        ZStack {
            Image(systemName: "diamond.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color("NoorPrimary").opacity(0.12))
            Text("\(surah.id)")
                .font(.caption2.weight(.bold))
                .foregroundStyle(Color("NoorPrimary"))
        }
        .frame(width: 40, height: 40)
    }

    private var surahInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(surah.nameEnglish)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            HStack(spacing: 6) {
                Text(surah.type)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(surah.type == "Meccan" ? Color("NoorGold") : Color("NoorAccent"))
                Text("•")
                    .font(.caption2).foregroundStyle(.tertiary)
                Text("\(surah.verses) Ayahs")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            if progress > 0 {
                progressBar
            }
        }
    }

    private var progressBar: some View {
        HStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color("NoorPrimary").opacity(0.12)).frame(height: 3)
                    Capsule().fill(progress >= 1.0 ? Color("NoorGold") : Color("NoorPrimary"))
                        .frame(width: geo.size.width * min(progress, 1.0), height: 3)
                }
            }
            .frame(height: 3)
            .frame(maxWidth: 80)
            Text(progress >= 1.0 ? "100%" : String(format: "%.0f%%", progress * 100))
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(progress >= 1.0 ? Color("NoorGold") : Color("NoorPrimary"))
        }
    }

    private var arabicName: some View {
        Text(surah.nameArabic)
            .font(.system(size: 22))
            .foregroundStyle(Color("NoorPrimary"))
    }
}
