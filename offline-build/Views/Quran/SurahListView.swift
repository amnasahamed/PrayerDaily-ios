import SwiftUI

struct SurahListView: View {
    @StateObject private var store = QuranStore.shared
    @State private var searchText = ""
    @State private var selectedJuz: Int? = nil

    private var filteredSurahs: [SurahInfo] {
        var list = QuranData.allSurahs
        if let juz = selectedJuz {
            list = list.filter { $0.juz == juz }
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
            ScrollView {
                LazyVStack(spacing: 0) {
                    headerCard
                    juzFilterRow
                    surahListContent
                }
            }
            .background(Color("NoorSurface").ignoresSafeArea())
            .searchable(text: $searchText, prompt: "Search surahs...")
            .navigationTitle("Quran")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("NoorPrimary"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Header
    private var headerCard: some View {
        VStack(spacing: 12) {
            lastReadBanner
        }
        .padding(.horizontal, AppTheme.screenPadding)
        .padding(.top, 12)
    }

    private var lastReadBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Label("Last Read", systemImage: "bookmark.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("NoorGold"))
                let surahName = store.lastRead.flatMap { lr in
                    QuranData.allSurahs.first { $0.id == lr.surahId }?.nameEnglish
                } ?? "Al-Fatihah"
                let verseNum = store.lastRead?.verse ?? 1
                Text("\(surahName), Ayah \(verseNum)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
            }
            Spacer()
            NavigationLink(destination: surahReaderDestination) {
                Text("Continue")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("NoorPrimary"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color("NoorPrimary"), Color("NoorSecondary")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    @ViewBuilder
    private var surahReaderDestination: some View {
        let surahId = store.lastRead?.surahId ?? 1
        if let surah = QuranData.allSurahs.first(where: { $0.id == surahId }) {
            SurahReaderView(surah: surah)
        }
    }

    // MARK: - Juz Filter
    private var juzFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                juzChip(title: "All", juz: nil)
                ForEach(1...30, id: \.self) { j in
                    juzChip(title: "Juz \(j)", juz: j)
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.vertical, 12)
        }
    }

    private func juzChip(title: String, juz: Int?) -> some View {
        let isSelected = selectedJuz == juz
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedJuz = juz }
        } label: {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isSelected ? Color("NoorPrimary") : Color("NoorCardBg"))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color("NoorPrimary").opacity(isSelected ? 0 : 0.2), lineWidth: 1))
        }
    }

    // MARK: - List
    private var surahListContent: some View {
        LazyVStack(spacing: 1) {
            ForEach(filteredSurahs) { surah in
                NavigationLink(destination: SurahReaderView(surah: surah)) {
                    SurahRowView(surah: surah)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppTheme.screenPadding)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}

// MARK: - Surah Row
struct SurahRowView: View {
    let surah: SurahInfo
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 14) {
            surahNumber
            surahInfo
            Spacer()
            arabicName
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(colorScheme == .dark ? Color(.systemGray6) : .white)
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
        VStack(alignment: .leading, spacing: 3) {
            Text(surah.nameEnglish)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            HStack(spacing: 6) {
                Text(surah.type)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(surah.type == "Meccan" ? Color("NoorGold") : Color("NoorAccent"))
                Text("•")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text("\(surah.verses) Ayahs")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var arabicName: some View {
        Text(surah.nameArabic)
            .font(.system(size: 22, design: .default))
            .foregroundStyle(Color("NoorPrimary"))
    }
}
