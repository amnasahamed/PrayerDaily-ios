import SwiftUI

struct OfflineContentView: View {
    @State private var downloadedSurahs: Set<Int> = [1, 2, 36, 55, 67, 112, 113, 114]
    @State private var downloadingId: Int? = nil

    private let featured: [(Int, String, String)] = [
        (1, "Al-Fatihah", "The Opening"),
        (2, "Al-Baqarah", "The Cow"),
        (36, "Ya-Sin", "Ya Sin"),
        (55, "Ar-Rahman", "The Most Gracious"),
        (67, "Al-Mulk", "The Sovereignty"),
        (112, "Al-Ikhlas", "Sincerity"),
        (113, "Al-Falaq", "The Daybreak"),
        (114, "An-Nas", "Mankind")
    ]

    var body: some View {
        ZStack {
            CalmingBackground().ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    storageCard
                    surahList
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle("Offline Content")
        .navigationBarTitleDisplayMode(.large)
        .modifier(AlehaNavStyle())
    }

    // MARK: - Storage
    private var storageCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Storage Used").font(.headline.weight(.bold))
                Spacer()
                Text(OfflineCacheService.shared.cacheSizeString())
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.alehaGreen)
            }
            let ratio = Double(downloadedSurahs.count) / Double(featured.count)
            ProgressView(value: ratio)
                .tint(Color.alehaGreen)
                .scaleEffect(x: 1, y: 1.6, anchor: .center)
            HStack {
                Text("\(downloadedSurahs.count) of \(featured.count) surahs saved")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Clear All") {
                    downloadedSurahs.removeAll()
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.red)
            }
        }
        .noorCard()
    }

    // MARK: - Surah list
    private var surahList: some View {
        VStack(spacing: 0) {
            ForEach(Array(featured.enumerated()), id: \.element.0) { idx, item in
                let (num, name, meaning) = item
                surahRow(num: num, name: name, meaning: meaning, showDivider: idx < featured.count - 1)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
    }

    private func surahRow(num: Int, name: String, meaning: String, showDivider: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.alehaGreen.opacity(0.1)).frame(width: 36, height: 36)
                    Text("\(num)").font(.caption.weight(.bold)).foregroundStyle(Color.alehaGreen)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(name).font(.subheadline.weight(.medium))
                    Text(meaning).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                downloadButton(for: num)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            if showDivider { Divider().padding(.leading, 66) }
        }
    }

    @ViewBuilder
    private func downloadButton(for num: Int) -> some View {
        if downloadedSurahs.contains(num) {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.alehaGreen)
                Text("Saved").font(.caption.weight(.medium)).foregroundStyle(Color.alehaGreen)
            }
        } else if downloadingId == num {
            ProgressView().scaleEffect(0.8)
                .frame(width: 60)
        } else {
            Button {
                downloadingId = num
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    downloadedSurahs.insert(num)
                    downloadingId = nil
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.circle").foregroundStyle(Color.alehaAmber)
                    Text("Save").font(.caption.weight(.medium)).foregroundStyle(Color.alehaAmber)
                }
            }
            .buttonStyle(.plain)
        }
    }
}
