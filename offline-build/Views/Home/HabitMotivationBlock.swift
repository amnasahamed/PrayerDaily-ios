import SwiftUI

// MARK: - Habit & Motivation Block
struct HabitMotivationBlock: View {
    @EnvironmentObject var salahStore: SalahStore
    @Environment(\.colorScheme) var cs
    @State private var animateFlame = false

    private var streak: Int { salahStore.currentStreak }
    private var weekTotal: Int {
        let logs = salahStore.logs.values
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
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.alehaAmber)
                .scaleEffect(animateFlame ? 1.15 : 1.0)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animateFlame)
                .onAppear { animateFlame = true }
            Text("\(streak)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.alehaAmber)
                .contentTransition(.numericText())
            Text("Day Streak")
                .font(.system(size: 10, weight: .medium))
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
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(Color.alehaGreen)
            Text("\(weekTotal)/35")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.alehaGreen)
                .contentTransition(.numericText())
            Text("This Week")
                .font(.system(size: 10, weight: .medium))
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
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(accent)
            Text("\(qadaTotal)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(accent)
                .contentTransition(.numericText())
            Text("Qada Left")
                .font(.system(size: 10, weight: .medium))
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
        // Simple tint blend for card backgrounds
        self.opacity(1 - ratio)
    }
}
