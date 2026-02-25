import SwiftUI

struct PrayerTrackerCard: View {
    @Binding var prayers: [SalahLogEntry]
    @State private var lastTapped: String? = nil
    @State private var confettiPrayer: String? = nil

    private var completedCount: Int { prayers.filter(\.completed).count }
    private var progress: Double { Double(completedCount) / 5.0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerRow
            prayerRow
            AnimatedProgressBar(progress: progress, color: Color.alehaGreen)
        }
        .noorCard()
    }

    private var headerRow: some View {
        HStack {
            Label("Today's Salah", systemImage: "clock.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            Spacer()
            countBadge
        }
    }

    private var countBadge: some View {
        HStack(spacing: 3) {
            Text("\(completedCount)")
                .contentTransition(.numericText())
            Text("/5")
        }
        .font(.caption.weight(.bold))
        .foregroundStyle(Color.alehaGreen)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.alehaGreen.opacity(0.10))
        .clipShape(Capsule())
    }

    private var prayerRow: some View {
        HStack(spacing: 6) {
            ForEach(prayers.indices, id: \.self) { idx in
                PrayerBubble(
                    entry: prayers[idx],
                    isLastTapped: lastTapped == prayers[idx].prayer.rawValue,
                    showConfetti: confettiPrayer == prayers[idx].prayer.rawValue
                ) {
                    let gen = UIImpactFeedbackGenerator(style: .medium)
                    gen.impactOccurred()
                    let wasCompleted = prayers[idx].completed
                    lastTapped = prayers[idx].prayer.rawValue
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                        prayers[idx].completed.toggle()
                    }
                    if !wasCompleted {
                        confettiPrayer = prayers[idx].prayer.rawValue
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            confettiPrayer = nil
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        lastTapped = nil
                    }
                }
            }
        }
    }
}

// MARK: - Prayer Bubble
private struct PrayerBubble: View {
    let entry: SalahLogEntry
    let isLastTapped: Bool
    let showConfetti: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 5) {
                ZStack {
                    bubbleCircle
                    bubbleIcon
                    if showConfetti { confettiOverlay }
                }
                .scaleEffect(isLastTapped ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isLastTapped)

                Text(entry.prayer.rawValue)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(entry.completed ? Color.alehaGreen : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var bubbleCircle: some View {
        Circle()
            .fill(entry.completed ? Color.alehaGreen : Color(.systemGray5).opacity(0.8))
            .frame(width: 44, height: 44)
            .shadow(color: entry.completed ? Color.alehaGreen.opacity(0.3) : .clear, radius: 6, y: 2)
    }

    @ViewBuilder
    private var bubbleIcon: some View {
        if entry.completed {
            Image(systemName: "checkmark")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .transition(.scale.combined(with: .opacity))
        } else {
            Image(systemName: entry.prayer.icon)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }
    }

    private var confettiOverlay: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(i.isMultiple(of: 2) ? Color.alehaGreen : Color.alehaAmber)
                    .frame(width: 4, height: 4)
                    .offset(confettiOffset(i))
                    .opacity(showConfetti ? 0 : 1)
                    .animation(
                        .easeOut(duration: 0.6).delay(Double(i) * 0.04),
                        value: showConfetti
                    )
            }
        }
    }

    private func confettiOffset(_ i: Int) -> CGSize {
        let angle = Double(i) * (360.0 / 6.0) * .pi / 180.0
        let dist: CGFloat = showConfetti ? 28 : 0
        return CGSize(width: dist * Foundation.cos(angle), height: dist * Foundation.sin(angle))
    }
}

// MARK: - Animated Progress Bar
struct AnimatedProgressBar: View {
    let progress: Double
    let color: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5).opacity(0.5))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress)
                    .animation(.spring(response: 0.5, dampingFraction: 0.75), value: progress)
            }
        }
        .frame(height: 5)
    }
}
