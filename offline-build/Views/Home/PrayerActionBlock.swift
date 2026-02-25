import SwiftUI

// MARK: - Unified Prayer Action Block (merges times + tracker)
struct PrayerActionBlock: View {
    @ObservedObject var service: PrayerTimesService
    @Binding var prayers: [SalahLogEntry]
    @Environment(\.colorScheme) var cs

    private var completedCount: Int { prayers.filter(\.completed).count }
    private var progress: Double { Double(completedCount) / 5.0 }
    private var nextPrayerName: String { service.nextPrayer?.prayer.rawValue ?? "—" }
    private var nextPrayerTime: String { service.nextPrayer?.timeString ?? "" }

    var body: some View {
        VStack(spacing: 16) {
            headerRow
            ringAndList
            AnimatedProgressBar(progress: progress, color: Color.alehaGreen)
        }
        .alehaCard()
    }

    // MARK: - Header
    private var headerRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today's Salah")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
                Text("Next: \(nextPrayerName) \(nextPrayerTime)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            countPill
        }
    }

    private var countPill: some View {
        HStack(spacing: 3) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 11))
                .foregroundStyle(Color.alehaGreen)
            Text("\(completedCount) / 5")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.alehaGreen)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.alehaGreen.opacity(0.10))
        .clipShape(Capsule())
    }

    // MARK: - Ring + Prayer List Side by Side
    private var ringAndList: some View {
        HStack(alignment: .center, spacing: 20) {
            progressRing
            prayerList
        }
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.alehaActiveGreen.opacity(0.15), lineWidth: 9)
                .frame(width: 88, height: 88)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [Color.alehaActiveGreen, Color.alehaGreen.opacity(0.6)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 9, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 88, height: 88)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                .pulseGlow(Color.alehaActiveGreen, active: progress > 0 && progress < 1)
            VStack(spacing: 0) {
                Text("\(completedCount)")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.alehaActiveGreen)
                    .contentTransition(.numericText())
                Text("of 5")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var prayerList: some View {
        VStack(spacing: 8) {
            ForEach(prayers.indices, id: \.self) { idx in
                PrayerRowItem(
                    entry: $prayers[idx],
                    prayerTime: service.prayerTimes.first(where: { $0.prayer == prayers[idx].prayer })?.timeString ?? ""
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Prayer Row with Swipe Actions
struct PrayerRowItem: View {
    @Binding var entry: SalahLogEntry
    let prayerTime: String
    @State private var bounceScale: CGFloat = 1.0
    @State private var offset: CGFloat = 0

    var body: some View {
        HStack(spacing: 10) {
            checkButton
            Text(entry.prayer.rawValue)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
            Spacer()
            Text(prayerTime)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .offset(x: offset)
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    handleSwipe(translation: value.translation.width)
                }
        )
    }

    private var checkButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.25, dampingFraction: 0.45)) {
                bounceScale = 1.35
                entry.completed.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.55)) { bounceScale = 1.0 }
            }
        } label: {
            ZStack {
                Circle()
                    .fill(entry.completed ? Color.alehaActiveGreen : Color(.systemGray5).opacity(0.6))
                    .frame(width: 30, height: 30)
                    .shadow(color: entry.completed ? Color.alehaActiveGreen.opacity(0.45) : .clear, radius: 7)
                if entry.completed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .scaleEffect(bounceScale)
        }
        .buttonStyle(.plain)
    }

    private func handleSwipe(translation: CGFloat) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if translation > 40 {
                // Swipe right = mark prayed
                entry.completed = true
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } else if translation < -40 {
                // Swipe left = mark missed
                entry.completed = false
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
            offset = 0
        }
    }
}
