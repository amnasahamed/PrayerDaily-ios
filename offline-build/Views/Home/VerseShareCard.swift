import SwiftUI

// MARK: - Shareable Verse of the Day Card
struct VerseShareCard: View {
    let arabic: String
    let translation: String
    let reference: String
    let tafsir: String

    @State private var showTafsir = false
    @State private var saved = false
    @State private var arabicOpacity = 0.0
    @Environment(\.colorScheme) var cs

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().background(.white.opacity(0.12)).padding(.horizontal, 2)
            body_
            actionRow
        }
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .shadow(color: Color.alehaGreen.opacity(0.22), radius: 18, y: 8)
        .onAppear {
            withAnimation(.easeIn(duration: 0.7).delay(0.2)) { arabicOpacity = 1 }
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Label("Verse of the Day", systemImage: "sparkles")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.alehaAmber)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.white.opacity(0.12))
                .clipShape(Capsule())
            Spacer()
            Text(dayLabel)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.40))
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 12)
    }

    // MARK: - Body
    private var body_: some View {
        VStack(spacing: 12) {
            Text(arabic)
                .font(.system(size: 26, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .opacity(arabicOpacity)

            Text(translation)
                .font(.callout)
                .foregroundStyle(.white.opacity(0.88))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text(reference)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.45))

            if showTafsir {
                VStack(alignment: .leading, spacing: 6) {
                    Divider().background(.white.opacity(0.15))
                    Text(tafsir)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.78))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Action Row
    private var actionRow: some View {
        VStack(spacing: 10) {
            pageIndicator
            HStack(spacing: 8) {
                saveButton
                shareButton
                tafsirButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 18)
        .padding(.top, 4)
    }

    private var pageIndicator: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i == 0 ? Color.alehaAmber : Color.white.opacity(0.30))
                    .frame(width: i == 0 ? 18 : 6, height: 5)
            }
        }
    }

    private var saveButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.55)) { saved.toggle() }
        } label: {
            Label(saved ? "Saved" : "Save", systemImage: saved ? "bookmark.fill" : "bookmark")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(saved ? Color.alehaAmber : .white.opacity(0.85))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.white.opacity(saved ? 0.20 : 0.12))
                .clipShape(Capsule())
        }
        .buttonStyle(SpringPressStyle())
    }

    private var shareButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            shareVerse()
        } label: {
            Label("Share", systemImage: "square.and.arrow.up")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.white.opacity(0.12))
                .clipShape(Capsule())
        }
        .buttonStyle(SpringPressStyle())
    }

    private var tafsirButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { showTafsir.toggle() }
        } label: {
            Label(showTafsir ? "Less" : "Tafsir", systemImage: showTafsir ? "chevron.up" : "book.pages")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.white.opacity(0.12))
                .clipShape(Capsule())
        }
        .buttonStyle(SpringPressStyle())
    }

    // MARK: - Helpers
    private var dayLabel: String {
        let f = DateFormatter(); f.dateFormat = "EEEE"; return f.string(from: Date())
    }

    private func shareVerse() {
        let text = "\"\(translation)\"\n— \(reference)\n\nVia Aleha"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }

    // MARK: - Background
    private var cardBg: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.alehaDeepTeal,
                    Color(red: 0.07, green: 0.26, blue: 0.16),
                    Color(red: 0.11, green: 0.38, blue: 0.22)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            IslamicPatternOverlay(opacity: 0.045)
            Circle()
                .fill(Color.alehaAmber.opacity(0.06))
                .frame(width: 200, height: 200)
                .blur(radius: 55)
                .offset(x: 90, y: -30)
        }
    }
}
