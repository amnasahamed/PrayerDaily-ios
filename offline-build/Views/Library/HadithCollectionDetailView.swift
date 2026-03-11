import SwiftUI

struct HadithCollectionDetailView: View {
    let collection: HadithCollection
    @State private var expandedChapter: Int? = nil

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                headerCard
                chaptersContent
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(Color("NoorSurface").ignoresSafeArea())
        .navigationTitle(collection.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Header
    private var headerCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(collection.color).opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: collection.icon)
                    .font(.title)
                    .foregroundStyle(Color(collection.color))
            }
            Text(collection.arabicName)
                .font(.title3)
                .foregroundStyle(Color(collection.color))
            Text(collection.name)
                .font(.title2.weight(.bold))
            Text(collection.author)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(collection.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            statsRow
        }
        .frame(maxWidth: .infinity)
        .noorCard()
    }

    private var statsRow: some View {
        HStack(spacing: 24) {
            StatBubble(value: "\(collection.totalHadith)", label: "Hadith")
            StatBubble(value: "\(collection.chapters.count)", label: "Chapters")
        }
        .padding(.top, 4)
    }

    // MARK: - Chapters
    private var chaptersContent: some View {
        VStack(spacing: 12) {
            ForEach(collection.chapters) { chapter in
                ChapterSection(chapter: chapter, isExpanded: expandedChapter == chapter.id) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        expandedChapter = expandedChapter == chapter.id ? nil : chapter.id
                    }
                }
            }
        }
    }
}

// MARK: - Stat Bubble
struct StatBubble: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.headline.weight(.bold)).foregroundStyle(Color("NoorPrimary"))
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }
}

// MARK: - Chapter Section
struct ChapterSection: View {
    let chapter: HadithChapter
    let isExpanded: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) var cs

    var body: some View {
        VStack(spacing: 0) {
            chapterHeader
            if isExpanded {
                Divider().padding(.horizontal, 14)
                VStack(spacing: 0) {
                    ForEach(chapter.hadiths) { hadith in
                        HadithRowView(hadith: hadith)
                        if hadith.id != chapter.hadiths.last?.id {
                            Divider().padding(.leading, 50)
                        }
                    }
                }
            }
        }
        .background(cs == .dark ? Color(.systemGray6) : .white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .shadow(color: .black.opacity(cs == .dark ? 0.3 : 0.05), radius: 6, y: 3)
    }

    private var chapterHeader: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(chapter.arabicTitle)
                        .font(.caption)
                        .foregroundStyle(Color("NoorPrimary"))
                    Text(chapter.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("\(chapter.hadiths.count) hadith")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Hadith Row
struct HadithRowView: View {
    let hadith: HadithEntry
    @State private var showFull = false
    @AppStorage("bookmarkedHadiths") private var bookmarkedHadiths: String = ""

    private var isBookmarked: Bool {
        bookmarkedHadiths.components(separatedBy: ",").contains(hadith.reference)
    }

    private func toggleBookmark() {
        var ids = bookmarkedHadiths.isEmpty ? [] : bookmarkedHadiths.components(separatedBy: ",")
        if isBookmarked {
            ids.removeAll { $0 == hadith.reference }
        } else {
            ids.append(hadith.reference)
        }
        bookmarkedHadiths = ids.joined(separator: ",")
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func shareHadith() {
        let text = "\(hadith.arabic)\n\n\(hadith.english)\n\n— \(hadith.reference)"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            hadithNumber
            arabicText
            englishText
            metaRow
        }
        .padding(14)
        .onTapGesture { withAnimation { showFull.toggle() } }
    }

    private var hadithNumber: some View {
        HStack(spacing: 8) {
            Text("#\(hadith.number)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color("NoorPrimary"))
                .clipShape(Capsule())
            Text(hadith.narrator)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            GradeBadge(grade: hadith.grade)
        }
    }

    private var arabicText: some View {
        Text(hadith.arabic)
            .font(.system(size: 18, design: .serif))
            .foregroundStyle(Color("NoorPrimary"))
            .lineLimit(showFull ? nil : 2)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .multilineTextAlignment(.trailing)
    }

    private var englishText: some View {
        Text(hadith.english)
            .font(.subheadline)
            .foregroundStyle(.primary)
            .lineLimit(showFull ? nil : 3)
    }

    private var metaRow: some View {
        HStack {
            Text(hadith.reference)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: toggleBookmark) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.caption)
                    .foregroundStyle(Color("NoorGold"))
            }
            Button(action: shareHadith) {
                Image(systemName: "square.and.arrow.up")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Grade Badge
struct GradeBadge: View {
    let grade: String
    private var color: Color {
        switch grade {
        case "Sahih": return .green
        case "Hasan": return .orange
        default: return .gray
        }
    }

    var body: some View {
        Text(grade)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}
