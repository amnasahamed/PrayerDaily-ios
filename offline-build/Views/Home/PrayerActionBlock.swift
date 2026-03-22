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
        }
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
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.alehaActiveGreen)
                    .contentTransition(.numericText())
                Text("of 5")
                    .font(.caption2)
                    .fontWeight(.medium)
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
                if entry.completed {
                    Circle()
                        .fill(Color.alehaActiveGreen)
                        .frame(width: 30, height: 30)
                        .shadow(color: Color.alehaActiveGreen.opacity(0.45), radius: 7)
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(.white)
                        .transition(.scale.combined(with: .opacity))
                } else if isPast {
                    // Missed – solid gray circle (no checkmark)
                    Circle()
                        .fill(Color(.systemGray4).opacity(0.7))
                        .frame(width: 30, height: 30)
                } else {
                    // Upcoming – dashed outline with clock icon
                    Circle()
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                        .foregroundStyle(Color.alehaGreen.opacity(0.55))
                        .frame(width: 30, height: 30)
                    Image(systemName: "clock")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.alehaGreen.opacity(0.70))
                }
            }
            .scaleEffect(bounceScale)
        }
        .buttonStyle(.plain)
    }

    // Determines if a prayer's scheduled time has passed
    private var isPast: Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        let thresholds: [Prayer: Int] = [.fajr: 6, .dhuhr: 13, .asr: 17, .maghrib: 20, .isha: 24]
        return hour >= (thresholds[entry.prayer] ?? 24)
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
