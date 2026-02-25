import SwiftUI

// MARK: - Ayah Share Card Generator
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

// MARK: - Verse Row
struct VerseRowView: View {
    let verse: Verse
    let showTranslation: Bool
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
        VStack(alignment: .trailing, spacing: 14) {
            verseHeader
            arabicText
            if showTranslation { translationText }
            Divider().opacity(0.4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(verseBackground)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
    }

    // MARK: - Header
    private var verseHeader: some View {
        HStack {
            verseNumberBadge
            Spacer()
            actionButtons
        }
    }

    private var verseNumberBadge: some View {
        Text("\(verse.number)")
            .font(.caption2.weight(.bold))
            .foregroundStyle(Color("NoorPrimary"))
            .frame(width: 28, height: 28)
            .background(Color("NoorPrimary").opacity(0.10))
            .clipShape(Circle())
    }

    private var actionButtons: some View {
        HStack(spacing: 14) {
            Button(action: onPlay) {
                Image(systemName: playIcon)
                    .font(.subheadline)
                    .foregroundStyle(isCurrentlyPlaying ? Color("NoorGold") : Color("NoorPrimary"))
            }
            if let onTafsir = onTafsir {
                Button(action: onTafsir) {
                    Image(systemName: "text.magnifyingglass")
                        .font(.subheadline)
                        .foregroundStyle(Color("NoorAccent"))
                }
            }
            Button(action: shareAyah) {
                Image(systemName: "square.and.arrow.up")
                    .font(.subheadline)
                    .foregroundStyle(Color("NoorSecondary"))
            }
            Button(action: onBookmark) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.subheadline)
                    .foregroundStyle(isBookmarked ? Color("NoorGold") : .secondary)
                    .scaleEffect(isBookmarked ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isBookmarked)
            }
        }
    }

    private var playIcon: String {
        if isCurrentlyPlaying && !isPaused { return "pause.circle.fill" }
        if isPaused { return "play.circle.fill" }
        return "play.circle"
    }

    // MARK: - Content
    private var arabicText: some View {
        Text(verse.arabic)
            .font(.system(size: 28))
            .lineSpacing(16)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .foregroundStyle(isCurrentlyPlaying ? Color("NoorPrimary") : .primary)
    }

    private var translationText: some View {
        Text(verse.translation)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .lineSpacing(5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var verseBackground: some View {
        Group {
            if isCurrentlyPlaying {
                Color("NoorPrimary").opacity(0.06)
            } else {
                (colorScheme == .dark ? Color(.systemGray6) : Color.white)
            }
        }
    }

    // MARK: - Share
    private func shareAyah() {
        let name = surahName.isEmpty ? "Surah \(verse.surahId)" : surahName
        let text = "\(verse.arabic)\n\n\(verse.translation)\n\n— \(name), Ayah \(verse.number) | Noor App"
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
