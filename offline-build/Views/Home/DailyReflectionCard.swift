import SwiftUI

struct DailyReflectionCard: View {
    let arabic: String
    let translation: String
    let reference: String
    let tafsir: String

    @State private var showTafsir = false
    @State private var arabicOpacity = 0.0
    @State private var shimmerActive = false

    var body: some View {
        VStack(spacing: 0) {
            cardHeader
            Divider().background(.white.opacity(0.15)).padding(.horizontal)
            cardBody
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .shadow(color: Color.alehaGreen.opacity(0.25), radius: 20, y: 8)
        .onAppear {
            withAnimation(.easeIn(duration: 0.8).delay(0.3)) { arabicOpacity = 1 }
        }
    }

    private var cardHeader: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.alehaAmber)
                Text("Verse of the Day")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.alehaAmber)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.white.opacity(0.12))
            .clipShape(Capsule())
            Spacer()
            Text(dayLabel)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.45))
        }
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .padding(.bottom, 14)
    }

    private var dayLabel: String {
        let f = DateFormatter(); f.dateFormat = "EEEE"
        return f.string(from: Date())
    }

    private var cardBody: some View {
        VStack(spacing: 16) {
            Text(arabic)
                .font(.system(size: 28, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .opacity(arabicOpacity)
                .animation(.easeIn(duration: 0.8), value: arabicOpacity)

            Text(translation)
                .font(.callout)
                .foregroundStyle(.white.opacity(0.88))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Text(reference)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.50))

            if showTafsir {
                VStack(alignment: .leading, spacing: 8) {
                    Divider().background(.white.opacity(0.15))
                    Text(tafsir)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.78))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            Button {
                let gen = UIImpactFeedbackGenerator(style: .light)
                gen.impactOccurred()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    showTafsir.toggle()
                }
            } label: {
                Label(showTafsir ? "Hide Tafsir" : "Read Tafsir",
                      systemImage: showTafsir ? "chevron.up" : "book.pages")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.90))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.14))
                    .clipShape(Capsule())
            }
            .buttonStyle(SpringPressStyle())
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 18)
    }

    private var cardBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.alehaDeepTeal,
                    Color(red: 0.08, green: 0.30, blue: 0.18),
                    Color(red: 0.12, green: 0.42, blue: 0.24)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            IslamicPatternOverlay(opacity: 0.05)
            // Subtle glow orb
            Circle()
                .fill(Color.alehaAmber.opacity(0.07))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: 80, y: -40)
        }
    }
}
