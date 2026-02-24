import SwiftUI

struct DailyReflectionCard: View {
    let arabic: String
    let translation: String
    let reference: String
    let tafsir: String
    @State private var showTafsir = false

    var body: some View {
        VStack(spacing: 16) {
            headerRow
            arabicText
            translationText
            referenceLabel
            tafsirSection
        }
        .padding(22)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .shadow(color: Color.alehaGreen.opacity(0.15), radius: 16, y: 6)
    }

    private var headerRow: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundStyle(Color.alehaAmber)
            Text("Daily Reflection")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.alehaAmber)
            Spacer()
            Text(dayString)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    private var dayString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE"
        return f.string(from: Date())
    }

    private var arabicText: some View {
        Text(arabic)
            .font(.system(size: 30, design: .serif))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.vertical, 6)
    }

    private var translationText: some View {
        Text(translation)
            .font(.callout)
            .foregroundStyle(.white.opacity(0.92))
            .multilineTextAlignment(.center)
            .lineSpacing(3)
    }

    private var referenceLabel: some View {
        Text(reference)
            .font(.caption.weight(.medium))
            .foregroundStyle(.white.opacity(0.5))
    }

    @ViewBuilder
    private var tafsirSection: some View {
        if showTafsir {
            Text(tafsir)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
                .lineSpacing(3)
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
        Button {
            withAnimation(.easeInOut(duration: 0.3)) { showTafsir.toggle() }
        } label: {
            Label(showTafsir ? "Hide Tafsir" : "Read Tafsir",
                  systemImage: showTafsir ? "chevron.up" : "book.pages")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(.white.opacity(0.12))
                .clipShape(Capsule())
        }
    }

    private var cardBg: some View {
        ZStack {
            LinearGradient(
                colors: [Color.alehaGreen, Color(red: 0.10, green: 0.38, blue: 0.22)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            IslamicPatternOverlay(opacity: 0.06)
        }
    }
}
