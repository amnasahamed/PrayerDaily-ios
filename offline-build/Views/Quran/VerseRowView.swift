import SwiftUI

struct VerseRowView: View {
    let verse: Verse
    let showTranslation: Bool
    let audioState: AudioPlayState
    let onPlay: () -> Void
    let onBookmark: () -> Void
    let isBookmarked: Bool
    var onTafsir: (() -> Void)? = nil

    @Environment(\.colorScheme) var colorScheme

    private var isCurrentlyPlaying: Bool {
        switch audioState {
        case .playing(let s, let v): return s == verse.surahId && v == verse.number
        case .paused(let s, let v): return s == verse.surahId && v == verse.number
        default: return false
        }
    }

    private var isPaused: Bool {
        if case .paused(let s, let v) = audioState {
            return s == verse.surahId && v == verse.number
        }
        return false
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 14) {
            verseHeader
            arabicText
            if showTranslation { translationText }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(verseBackground)
    }

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
            .foregroundStyle(Color.alehaGreen)
            .frame(width: 28, height: 28)
            .background(Color.alehaGreen.opacity(0.10))
            .clipShape(Circle())
    }

    private var actionButtons: some View {
        HStack(spacing: 14) {
            Button(action: onPlay) {
                Image(systemName: playIcon)
                    .font(.subheadline)
                    .foregroundStyle(isCurrentlyPlaying ? Color.alehaAmber : Color.alehaGreen)
            }
            if let onTafsir = onTafsir {
                Button(action: onTafsir) {
                    Image(systemName: "text.magnifyingglass")
                        .font(.subheadline)
                        .foregroundStyle(Color.noorAccent)
                }
            }
            Button(action: onBookmark) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.subheadline)
                    .foregroundStyle(isBookmarked ? Color.alehaAmber : .secondary)
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

    private var arabicText: some View {
        Text(verse.arabic)
            .font(.system(size: 28))
            .lineSpacing(16)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .foregroundStyle(isCurrentlyPlaying ? Color.alehaGreen : .primary)
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
                Color.alehaGreen.opacity(0.06)
            } else {
                colorScheme == .dark ? Color(.systemGray6) : Color.white
            }
        }
    }
}
