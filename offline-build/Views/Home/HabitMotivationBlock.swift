import SwiftUI

// MARK: - Habit & Motivation Block
struct HabitMotivationBlock: View {
    @EnvironmentObject var salahStore: SalahStore
    @Environment(\.colorScheme) var cs
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var animateFlame = false

    private var streak: Int { salahStore.currentStreak }
    private var weekTotal: Int {
        let cal = Calendar.current
        let today = Date()
        return (0..<7).compactMap { offset in
            cal.date(byAdding: .day, value: -offset, to: today)
        }.reduce(0) { sum, date in
            sum + salahStore.log(for: date).completedCount
        }
    }
    private var qadaTotal: Int { salahStore.qadaEntries.reduce(0) { $0 + $1.count } }

    var body: some View {
        HStack(spacing: 10) {
            streakCard
            weekCard
            qadaCard
        }
    }

    private var streakCard: some View {
        VStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(Color.alehaAmber)
                .scaleEffect(reduceMotion ? 1.0 : (animateFlame ? 1.15 : 1.0))
                .animation(reduceMotion ? .none : .easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animateFlame)
                .onAppear { if !reduceMotion { animateFlame = true } }
            Text("\(streak)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.alehaAmber)
                .contentTransition(.numericText())
            Text("Day Streak")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(cardBg(Color.alehaAmber))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(cardBorder)
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }

    private var weekCard: some View {
        VStack(spacing: 6) {
            Image(systemName: "calendar")
                .font(.title2)
                .foregroundStyle(Color.alehaGreen)
            Text("\(weekTotal)/35")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.alehaGreen)
                .contentTransition(.numericText())
            Text("This Week")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(cardBg(Color.alehaGreen))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(cardBorder)
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }

    private var qadaCard: some View {
        let accent: Color = qadaTotal == 0 ? Color.alehaGreen : Color.alehaSaffron
        return VStack(spacing: 6) {
            Image(systemName: "moon.fill")
                .font(.title2)
                .foregroundStyle(accent)
            Text("\(qadaTotal)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(accent)
                .contentTransition(.numericText())
            Text("Qada Left")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(cardBg(accent))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(cardBorder)
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }

    private func cardBg(_ accent: Color) -> some ShapeStyle {
        cs == .dark
            ? AnyShapeStyle(Color.white.opacity(0.07))
            : AnyShapeStyle(accent.opacity(0.05).blended(with: Color.white, ratio: 0.85))
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.7), lineWidth: 0.5)
    }
}

// MARK: - Color blend helper
extension Color {
    func blended(with other: Color, ratio: Double) -> Color {
        // Blend based on ratio: ratio=0 returns self, ratio=1 returns other
        let clampedRatio = max(0, min(1, ratio))
        let uiSelf = UIColor(self)
        let uiOther = UIColor(other)

        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        uiSelf.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiOther.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return Color(
            red: Double(r1) * (1 - clampedRatio) + Double(r2) * clampedRatio,
            green: Double(g1) * (1 - clampedRatio) + Double(g2) * clampedRatio,
            blue: Double(b1) * (1 - clampedRatio) + Double(b2) * clampedRatio
        )
    }
}
