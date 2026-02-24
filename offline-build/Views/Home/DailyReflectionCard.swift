import SwiftUI

struct DailyReflectionCard: View {
    let arabic: String
    let translation: String
    let reference: String
    let tafsir: String
    @State private var showTafsir = false

    var body: some View {
        VStack(spacing: 14) {
            headerRow
            arabicText
            translationText
            referenceLabel
            tafsirToggle
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }

    private var headerRow: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundStyle(Color("NoorGold"))
            Text("Daily Reflection")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("NoorGold"))
            Spacer()
            Text("Today")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private var arabicText: some View {
        Text(arabic)
            .font(.system(size: 28, design: .serif))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.vertical, 8)
    }

    private var translationText: some View {
        Text(translation)
            .font(.body)
            .foregroundStyle(.white.opacity(0.9))
            .multilineTextAlignment(.center)
    }

    private var referenceLabel: some View {
        Text(reference)
            .font(.caption)
            .foregroundStyle(.white.opacity(0.6))
    }

    @ViewBuilder
    private var tafsirToggle: some View {
        if showTafsir {
            Text(tafsir)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
                .padding(.top, 6)
                .transition(.opacity.combined(with: .move(edge: .top)))
        }
        Button {
            withAnimation(.easeInOut(duration: 0.3)) { showTafsir.toggle() }
        } label: {
            Label(showTafsir ? "Hide Tafsir" : "Read Tafsir",
                  systemImage: showTafsir ? "chevron.up" : "book.pages")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(.white.opacity(0.15))
                .clipShape(Capsule())
        }
    }

    private var cardBackground: some View {
        LinearGradient(
            colors: [Color("NoorPrimary"), Color("NoorSecondary")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
