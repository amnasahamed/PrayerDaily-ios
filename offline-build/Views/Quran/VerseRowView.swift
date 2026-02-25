import SwiftUI

// MARK: - Verse Row
struct VerseRowView: View {
    let verse: Verse
    let showTranslation: Bool
    var showArabic: Bool = true
    var isFocusMode: Bool = false
    let audioState: AudioPlayState
    let onPlay: () -> Void
    let onBookmark: () -> Void
    let isBookmarked: Bool
    var onTafsir: (() -> Void)? = nil
    var surahName: String = ""

    @Environment(\.colorScheme) var colorScheme
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []

    private var isCurrentlyPlaying: Bool {
        switch audioState {
        case .playing(let s, let v): return s == verse.surahId && v == verse.number
        case .paused(let s, let v): return s == verse.surahId && v == verse.number
        default: return false
        }
    }

    private var isPaused: Bool {
        if case .paused(let s, let v) = audioState { return s == verse.surahId && v == verse.number }
        return false
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            cardContent
            actionBar
            Divider().opacity(isFocusMode ? 0.15 : 0.35)
        }
        .background(cardBackground)
        .sheet(isPresented: $showShareSheet) { ShareSheet(items: shareItems) }
    }

    // MARK: - Card Content
    private var cardContent: some View {
        VStack(alignment: .trailing, spacing: 10) {
            numberBadge
            if showArabic { arabicBlock }
            if showTranslation { translationBlock }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 6)
    }

    private var numberBadge: some View {
        HStack {
            Text("\(verse.number)")
                .font(.caption2.weight(.bold))
                .foregroundStyle(isFocusMode ? Color("NoorGold") : Color("NoorPrimary"))
                .frame(width: 28, height: 28)
                .background((isFocusMode ? Color("NoorGold") : Color("NoorPrimary")).opacity(0.12))
                .clipShape(Circle())
            Spacer()
        }
    }

    private var arabicBlock: some View {
        Text(verse.arabic)
            .font(.system(size: isFocusMode ? 32 : 28))
            .lineSpacing(isFocusMode ? 20 : 14)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .foregroundStyle(isFocusMode ? .white : (isCurrentlyPlaying ? Color("NoorPrimary") : .primary))
    }

    private var translationBlock: some View {
        Text(verse.translation)
            .font(.subheadline)
            .foregroundStyle(isFocusMode ? .white.opacity(0.75) : Color.primary.opacity(0.75))
            .lineSpacing(5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Action Bar
    private var actionBar: some View {
        HStack(spacing: 0) {
            actionButton(icon: playIcon, tint: isCurrentlyPlaying ? Color("NoorGold") : iconTint, action: onPlay)
            if let tafsir = onTafsir {
                actionButton(icon: "doc.text.magnifyingglass", tint: Color("NoorAccent"), action: tafsir)
            }
            actionButton(icon: "square.and.arrow.up", tint: iconTint, action: shareAyah)
            actionButton(
                icon: isBookmarked ? "bookmark.fill" : "bookmark",
                tint: isBookmarked ? Color("NoorGold") : iconTint,
                action: onBookmark
            )
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 6)
    }

    private var iconTint: Color {
        isFocusMode ? .white.opacity(0.55) : Color("NoorPrimary").opacity(0.7)
    }

    private func actionButton(icon: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 38, height: 32)
        }
        .buttonStyle(.plain)
    }

    private var playIcon: String {
        if isCurrentlyPlaying && !isPaused { return "pause.circle.fill" }
        if isPaused { return "play.circle.fill" }
        return "play.circle"
    }

    // MARK: - Background
    @ViewBuilder
    private var cardBackground: some View {
        if isFocusMode {
            Color.black
        } else if isCurrentlyPlaying {
            Color("NoorPrimary").opacity(0.06)
        } else {
            colorScheme == .dark ? Color(.systemGray6) : Color.white
        }
    }

    // MARK: - Share
    private func shareAyah() {
        let name = surahName.isEmpty ? "Surah \(verse.surahId)" : surahName
        let text = "\(verse.arabic)\n\n\(verse.translation)\n\n— \(name) \(verse.surahId):\(verse.number) | Noor App"
        shareItems = [text]
        showShareSheet = true
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}

// MARK: - Ayah Share Card
struct AyahShareCard: View {
    let verse: Verse
    let surahName: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.28, blue: 0.2), Color(red: 0.1, green: 0.45, blue: 0.3)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            VStack(spacing: 20) {
                Spacer()
                Text(verse.arabic)
                    .font(.system(size: 26))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .lineSpacing(10)

                Rectangle().fill(.white.opacity(0.25)).frame(height: 1).padding(.horizontal, 40)

                Text(verse.translation)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .lineSpacing(5)

                Spacer()

                HStack {
                    Text("Noor • \(surahName) \(verse.surahId):\(verse.number)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Image(systemName: "moon.stars.fill")
                        .foregroundStyle(Color(red: 0.95, green: 0.8, blue: 0.3))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 320, height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
