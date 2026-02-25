import SwiftUI

struct CompactDhikrCard: View {
    @State private var count: Int = 0
    @State private var tapScale: CGFloat = 1.0
    @Environment(\.colorScheme) var cs

    private let target = 33
    private var progress: Double { min(Double(count) / Double(target), 1.0) }

    var body: some View {
        VStack(spacing: 10) {
            cardHeader
            counterRing
            arabicLabel
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(cardBorder)
        .shadow(color: .black.opacity(0.05), radius: 14, y: 5)
    }

    private var cardHeader: some View {
        HStack(spacing: 5) {
            Image(systemName: "hands.sparkles.fill")
                .foregroundStyle(Color.alehaAmber)
                .font(.system(size: 12))
            Text("Dhikr")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var counterRing: some View {
        ZStack {
            Circle()
                .stroke(Color.alehaAmber.opacity(0.12), lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.alehaAmber, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.3), value: count)
            VStack(spacing: 1) {
                Text("\(count)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.alehaAmber)
                    .contentTransition(.numericText())
                Text("/\(target)")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 72, height: 72)
        .scaleEffect(tapScale)
        .onTapGesture {
            let gen = UIImpactFeedbackGenerator(style: .light)
            gen.impactOccurred()
            withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                count += 1
                tapScale = 1.12
            }
            withAnimation(.spring(response: 0.2).delay(0.1)) {
                tapScale = 1.0
            }
        }
    }

    private var arabicLabel: some View {
        Text("سبحان الله")
            .font(.system(size: 13, design: .serif))
            .foregroundStyle(.primary.opacity(0.7))
    }

    private var cardBg: some ShapeStyle {
        cs == .dark
            ? AnyShapeStyle(Color.white.opacity(0.07))
            : AnyShapeStyle(Color.white.opacity(0.88))
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
            .stroke(cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.6), lineWidth: 0.5)
    }
}
