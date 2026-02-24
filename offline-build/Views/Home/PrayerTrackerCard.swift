import SwiftUI

struct PrayerTrackerCard: View {
    @Binding var prayers: [SalahLogEntry]
    @State private var lastTapped: String? = nil

    private var completedCount: Int { prayers.filter(\.completed).count }
    private var progress: Double { Double(completedCount) / 5.0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
            ZStack {
                Capsule()
                    .fill(Color.alehaGreen.opacity(0.12))
                    .frame(width: 44, height: 24)
                Text("\(completedCount)/5")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.alehaGreen)
            }
        }
    }

    private var prayerRow: some View {
        HStack(spacing: 8) {
            ForEach(prayers.indices, id: \.self) { idx in
                PrayerBubble(
                    entry: prayers[idx],
                    isLastTapped: lastTapped == prayers[idx].prayer.rawValue
                ) {
                    let gen = UIImpactFeedbackGenerator(style: .medium)
                    gen.impactOccurred()
                    lastTapped = prayers[idx].prayer.rawValue
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                        prayers[idx].completed.toggle()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
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
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(entry.completed
                              ? Color.alehaGreen
                              : Color(.systemGray5).opacity(0.8))
                        .frame(width: 46, height: 46)
                        .shadow(color: entry.completed ? Color.alehaGreen.opacity(0.35) : .clear,
                                radius: 8, y: 3)
                    if entry.completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: entry.prayer.icon)
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }
                }
                .scaleEffect(isLastTapped ? 1.25 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isLastTapped)

                Text(entry.prayer.rawValue)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(entry.completed ? Color.alehaGreen : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
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
                    .fill(Color(.systemGray5).opacity(0.6))
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
        .frame(height: 6)
    }
}
