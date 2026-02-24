import SwiftUI

struct ReadingProgressCard: View {
    @StateObject private var store = QuranStore.shared
    @Environment(\.colorScheme) var cs

    private var lastSurahName: String {
        guard let lr = store.lastRead,
              let s = QuranData.allSurahs.first(where: { $0.id == lr.surahId }) else { return "Al-Fatihah" }
        return s.nameEnglish
    }
    private var lastVerse: Int { store.lastRead?.verse ?? 1 }
    private var cachedCount: Int { OfflineCacheService.shared.cachedSurahCount() }
    private var progressFraction: Double { Double(cachedCount) / 114.0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerRow
            progressBar
            statsRow
        }
        .noorCard()
    }

    private var headerRow: some View {
        HStack {
            Label("Quran Progress", systemImage: "book.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("NoorPrimary"))
            Spacer()
            Text("\(cachedCount)/114")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("NoorGold"))
        }
    }

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color("NoorPrimary").opacity(0.12)).frame(height: 8)
                    Capsule().fill(Color("NoorPrimary")).frame(width: geo.size.width * progressFraction, height: 8)
                }
            }
            .frame(height: 8)
            Text("Surahs read & cached offline")
                .font(.caption2).foregroundStyle(.tertiary)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 16) {
            StatPill(icon: "bookmark.fill", label: "Last Read", value: lastSurahName, color: "NoorPrimary")
            StatPill(icon: "text.line.first.and.arrowtriangle.forward", label: "Ayah", value: "\(lastVerse)", color: "NoorGold")
            StatPill(icon: "arrow.down.circle.fill", label: "Cached", value: OfflineCacheService.shared.cacheSizeString(), color: "NoorAccent")
        }
    }
}

struct StatPill: View {
    let icon: String; let label: String; let value: String; let color: String
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.caption).foregroundStyle(Color(color))
            Text(value).font(.caption2.weight(.bold)).lineLimit(1)
            Text(label).font(.system(size: 8)).foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }
}
