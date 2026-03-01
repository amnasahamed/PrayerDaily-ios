import SwiftUI

// MARK: - Prayer Timeline Card
// Unified salah + habits card with horizontal timeline

struct PrayerTimelineCard: View {
    @ObservedObject var service: PrayerTimesService
    @Binding var prayers: [SalahLogEntry]
    @EnvironmentObject var salahStore: SalahStore
    @Environment(\.colorScheme) var cs

    @State private var pulse = false
    @State private var confettiFor: String? = nil
    @State private var tappedIdx: Int? = nil

    private var completedCount: Int { prayers.filter(\.completed).count }

    var body: some View {
        VStack(spacing: 0) {
            timelineSection
            divider
            habitFooter
        }
        .alehaCard()
    }

    // MARK: - Timeline Section
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            subHeader
            timeline
        }
        .padding(.bottom, 14)
    }

    // MARK: - Sub-header (italic serif feel)
    private var subHeader: some View {
        HStack {
            Text(nextPrayerLabel)
                .font(.system(size: 13, weight: .medium))
                .italic()
                .foregroundStyle(.secondary)
            Spacer()
            Text("Today")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.alehaGreen)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Color.alehaGreen.opacity(0.12))
                .clipShape(Capsule())
        }
    }

    private var nextPrayerLabel: String {
        guard let next = service.nextPrayer else { return "All prayers done today" }
        let mins = Int(next.time.timeIntervalSinceNow / 60)
        if mins < 60 {
            return "\(mins) minutes until \(next.prayer.rawValue)"
        } else {
            let hrs = mins / 60
            let rem = mins % 60
            if rem == 0 {
                return "\(hrs)h until \(next.prayer.rawValue)"
            }
            return "\(hrs)h \(rem)m until \(next.prayer.rawValue)"
        }
    }

    // MARK: - Horizontal Timeline
    private var timeline: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                trackLine(width: geo.size.width)
                    .offset(y: 32)
                HStack(spacing: 0) {
                    ForEach(prayers.indices, id: \.self) { idx in
                        prayerNode(idx: idx, total: prayers.count)
                    }
                }
            }
        }
        .frame(height: 100)
    }

    private func trackLine(width: CGFloat) -> some View {
        let completedFrac = Double(completedCount) / 5.0
        return ZStack(alignment: .leading) {
            Capsule()
                .fill(Color(.systemGray5).opacity(0.6))
                .frame(height: 3)
            Capsule()
                .fill(LinearGradient(
                    colors: [Color.alehaActiveGreen, Color.alehaGreen.opacity(0.6)],
                    startPoint: .leading, endPoint: .trailing))
                .frame(width: width * completedFrac, height: 3)
                .animation(.spring(response: 0.55, dampingFraction: 0.78), value: completedCount)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Single Prayer Node
    private func prayerNode(idx: Int, total: Int) -> some View {
        let entry = prayers[idx]
        let isNext = isNextPrayer(entry.prayer)
        let isPast = isPastPrayer(entry.prayer)
        let scale: CGFloat = isNext ? 1.22 : 1.0
        let prayerTime = service.prayerTimes.first(where: { $0.prayer == entry.prayer })?.timeString ?? ""

        return Button {
            handleTap(idx: idx)
        } label: {
            VStack(spacing: 5) {
                // Prayer time label
                Text(prayerTime)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(isNext ? Color.alehaGreen : .secondary.opacity(0.7))
                    .frame(height: 12)

                // Node circle
                ZStack {
                    nodeCircle(entry: entry, isNext: isNext, isPast: isPast)
                    nodeIcon(entry: entry, isNext: isNext, isPast: isPast)

                    if isNext {
                        pulseRing
                    }
                    if confettiFor == entry.prayer.rawValue {
                        confettiOverlay
                    }
                }
                .frame(width: nodeSize(isNext: isNext), height: nodeSize(isNext: isNext))
                .scaleEffect(tappedIdx == idx ? 1.35 : scale)
                .animation(.spring(response: 0.28, dampingFraction: 0.5), value: tappedIdx)

                // Prayer name
                Text(entry.prayer.rawValue)
                    .font(.system(size: 10, weight: isNext ? .bold : .medium))
                    .foregroundStyle(entry.completed ? Color.alehaActiveGreen : (isNext ? Color.alehaGreen : .secondary))
                    .frame(height: 14)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .onAppear { if isNext { pulse = true } }
    }

    private func nodeSize(isNext: Bool) -> CGFloat { isNext ? 40 : 34 }

    @ViewBuilder
    private func nodeCircle(entry: SalahLogEntry, isNext: Bool, isPast: Bool) -> some View {
        if entry.completed {
            Circle()
                .fill(Color.alehaActiveGreen)
                .shadow(color: Color.alehaActiveGreen.opacity(0.35), radius: 6, y: 2)
        } else if isNext {
            Circle()
                .fill(Color.alehaGreen.opacity(0.15))
                .overlay(Circle().strokeBorder(Color.alehaGreen, lineWidth: 2.0))
        } else if isPast {
            Circle()
                .fill(Color(.systemGray4).opacity(0.55))
        } else {
            Circle()
                .fill(Color(.systemGray6).opacity(0.8))
                .overlay(
                    Circle().strokeBorder(
                        style: StrokeStyle(lineWidth: 1.5, dash: [3, 2.5]))
                    .foregroundStyle(Color(.systemGray3))
                )
        }
    }

    @ViewBuilder
    private func nodeIcon(entry: SalahLogEntry, isNext: Bool, isPast: Bool) -> some View {
        if entry.completed {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .transition(.scale.combined(with: .opacity))
        } else if isNext {
            Image(systemName: "clock.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.alehaGreen)
        } else if isPast {
            Image(systemName: "minus")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color(.systemGray3))
        } else {
            Image(systemName: entry.prayer.icon)
                .font(.system(size: 11))
                .foregroundStyle(Color(.systemGray3))
        }
    }

    private var pulseRing: some View {
        Circle()
            .strokeBorder(Color.alehaGreen.opacity(pulse ? 0.0 : 0.45), lineWidth: 3)
            .scaleEffect(pulse ? 1.7 : 1.0)
            .animation(.easeOut(duration: 1.4).repeatForever(autoreverses: false), value: pulse)
    }

    private var confettiOverlay: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                Circle()
                    .fill(i.isMultiple(of: 2) ? Color.alehaGreen : Color.alehaAmber)
                    .frame(width: 4, height: 4)
                    .offset(confettiOffset(i))
                    .opacity(confettiFor != nil ? 0.0 : 1.0)
                    .animation(.easeOut(duration: 0.6).delay(Double(i) * 0.05), value: confettiFor)
            }
        }
    }

    private func confettiOffset(_ i: Int) -> CGSize {
        let angle = Double(i) * (360.0 / 6.0) * .pi / 180.0
        let dist: CGFloat = 26
        return CGSize(width: dist * Foundation.cos(angle), height: dist * Foundation.sin(angle))
    }

    // MARK: - Tap
    private func handleTap(idx: Int) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let wasCompleted = prayers[idx].completed
        tappedIdx = idx
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            prayers[idx].completed.toggle()
        }
        if !wasCompleted {
            confettiFor = prayers[idx].prayer.rawValue
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { confettiFor = nil }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation { tappedIdx = nil }
        }
    }

    // MARK: - State Logic
    private func isNextPrayer(_ prayer: Prayer) -> Bool {
        service.nextPrayer?.prayer == prayer
    }

    private func isPastPrayer(_ prayer: Prayer) -> Bool {
        guard let pt = service.prayerTimes.first(where: { $0.prayer == prayer }) else {
            return prayerHourThreshold(prayer) < Calendar.current.component(.hour, from: Date())
        }
        return pt.isPast && !prayers.first(where: { $0.prayer == prayer })!.completed
    }

    private func prayerHourThreshold(_ prayer: Prayer) -> Int {
        switch prayer {
        case .fajr: return 6
        case .dhuhr: return 13
        case .asr: return 17
        case .maghrib: return 20
        case .isha: return 24
        }
    }

    // MARK: - Divider
    private var divider: some View {
        Rectangle()
            .fill(Color(.separator).opacity(0.35))
            .frame(height: 0.5)
            .padding(.horizontal, -AppTheme.cardPadding)
    }

    // MARK: - Habit Footer Strip
    private var habitFooter: some View {
        HStack(spacing: 0) {
            habitStat(
                icon: "flame.fill",
                value: "\(salahStore.currentStreak)",
                label: "streak",
                color: Color.alehaAmber
            )
            footerDivider
            habitStat(
                icon: "calendar",
                value: "\(weekTotal)/35",
                label: "this week",
                color: Color.alehaGreen
            )
            footerDivider
            habitStat(
                icon: "moon.fill",
                value: "\(qadaTotal)",
                label: "qada left",
                color: qadaTotal == 0 ? Color.alehaGreen : Color.alehaSaffron
            )
        }
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    private func habitStat(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(color)
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                    .contentTransition(.numericText())
            }
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var footerDivider: some View {
        Rectangle()
            .fill(Color(.separator).opacity(0.35))
            .frame(width: 0.5, height: 32)
    }

    // MARK: - Computed stats
    private var weekTotal: Int {
        let cal = Calendar.current
        let today = Date()
        return (0..<7).compactMap { offset in
            cal.date(byAdding: .day, value: -offset, to: today)
        }.reduce(0) { sum, date in sum + salahStore.log(for: date).completedCount }
    }

    private var qadaTotal: Int {
        salahStore.qadaEntries.reduce(0) { $0 + $1.count }
    }
}
