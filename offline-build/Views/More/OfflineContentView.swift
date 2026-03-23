import SwiftUI

struct OfflineContentView: View {
    @EnvironmentObject var localization: LocalizationManager
    @State private var cachedIds: Set<Int> = []
    @State private var downloadingId: Int? = nil
    @State private var removingId: Int? = nil
    @State private var cacheSize: String = "0 B"
    @State private var showClearConfirm = false

    private let cache = OfflineCacheService.shared
    private let featured: [(Int, String, String)] = [
        (1,   "Al-Fatihah", "The Opening"),
        (2,   "Al-Baqarah", "The Cow"),
        (36,  "Ya-Sin",     "Ya Sin"),
        (55,  "Ar-Rahman",  "The Most Gracious"),
        (67,  "Al-Mulk",   "The Sovereignty"),
        (112, "Al-Ikhlas", "Sincerity"),
        (113, "Al-Falaq",  "The Daybreak"),
        (114, "An-Nas",    "Mankind")
    ]

    var body: some View {
        ZStack {
            CalmingBackground().ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    storageCard
                    surahList
                    offlineNote
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle(localization.t(.offlineTitle))
        .navigationBarTitleDisplayMode(.large)
        .modifier(AlehaNavStyle())
        .onAppear { refreshState() }
        .confirmationDialog(localization.t(.offlineClearConfirmTitle), isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button(localization.t(.offlineClearAll), role: .destructive) {
                cache.clearCache()
                refreshState()
            }
            Button(localization.t(.commonCancel), role: .cancel) {}
        }
    }

    private func refreshState() {
        cachedIds = Set(featured.map(\.0).filter { cache.isSurahCached($0) })
        cacheSize = cache.cacheSizeString()
    }

    // MARK: - Storage Card
    private var storageCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(localization.t(.offlineStorageUsed)).font(.headline.weight(.bold))
                Spacer()
                Text(cacheSize)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.alehaGreen)
            }
            let ratio = featured.isEmpty ? 0.0 : Double(cachedIds.count) / Double(featured.count)
            ProgressView(value: ratio)
                .tint(Color.alehaGreen)
                .scaleEffect(x: 1, y: 1.6, anchor: .center)
            HStack {
                Text("\(cachedIds.count) of \(featured.count) " + localization.t(.offlineSurahsSaved))
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                if !cachedIds.isEmpty {
                    Button(localization.t(.offlineClearAll)) { showClearConfirm = true }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                }
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

    private var offlineNote: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill").foregroundStyle(Color.alehaAmber)
            Text(localization.t(.offlineSavedInfo))
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color.alehaAmber.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
                actionButton(for: num)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            if showDivider { Divider().padding(.leading, 66) }
        }
    }

    @ViewBuilder
    private func actionButton(for num: Int) -> some View {
        if downloadingId == num || removingId == num {
            ProgressView().scaleEffect(0.8).frame(width: 68)
        } else if cachedIds.contains(num) {
            Button {
                removingId = num
                DispatchQueue.global(qos: .background).async {
                    let f = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                        .appendingPathComponent("QuranCache/surah_\(num).json")
                    try? FileManager.default.removeItem(at: f)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        removingId = nil
                        refreshState()
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.alehaGreen)
                    Text(localization.t(.offlineSaved)).font(.caption.weight(.medium)).foregroundStyle(Color.alehaGreen)
                }
            }
            .buttonStyle(.plain)
        } else {
            Button {
                downloadingId = num
                Task {
                    // Attempt to fetch & cache from QuranAPIService
                    if let verses = try? await QuranAPIService.shared.fetchVerses(surahId: num) {
                        OfflineCacheService.shared.cacheVerses(verses, surahId: num)
                    }
                    await MainActor.run {
                        downloadingId = nil
                        refreshState()
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.circle").foregroundStyle(Color.alehaAmber)
                    Text(localization.t(.offlineDownload)).font(.caption.weight(.medium)).foregroundStyle(Color.alehaAmber)
                }
            }
            .buttonStyle(.plain)
        }
    }
}
