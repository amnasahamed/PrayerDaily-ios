import SwiftUI

struct TodayPrayerView: View {
    @EnvironmentObject var store: SalahStore
    @State private var showShareProgress = false

    private var todayLog: PrayerDayLog { store.todayLog }
    private var progress: Double { Double(todayLog.completedCount) / 5.0 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppTheme.sectionSpacing) {
                heroCard
                weeklyConsistencyBanner
                prayerListSection
                weekOverviewCard
                shareProgressButton
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, 4)
            .padding(.bottom, 30)
        }
    }

    // MARK: - Hero
    private var heroCard: some View {
        HStack(spacing: 20) {
            progressRing
            VStack(alignment: .leading, spacing: 6) {
                Text("\(todayLog.completedCount) of 5 Prayers")
                    .font(.headline)
                statusLabel
                Text(todayProgress)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .noorCard()
    }

    private var todayProgress: String {
        let remaining = 5 - todayLog.completedCount
        if remaining == 0 { return "All prayers done today — Alhamdulillah" }
        return "\(remaining) prayer\(remaining > 1 ? "s" : "") remaining"
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.alehaActiveGreen.opacity(0.15), lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.alehaActiveGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.7, dampingFraction: 0.75), value: progress)
                .pulseGlow(Color.alehaActiveGreen, active: progress > 0 && progress < 1)
            VStack(spacing: 1) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.alehaActiveGreen)
                    .contentTransition(.numericText())
                Text("Today")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 90, height: 90)
    }

    private var shareProgressButton: some View {
        Button { showShareProgress = true } label: {
            HStack(spacing: 10) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.alehaActiveGreen)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Share My Progress")
                        .font(.subheadline.weight(.semibold))
                    Text("Beautiful card with today's stats")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .noorCard()
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showShareProgress) {
            ShareProgressSheet(store: store)
        }
    }

    private var statusLabel: some View {
        Group {
            if todayLog.completedCount == 5 {
                Label("ماشاء الله!", systemImage: "star.fill")
                    .foregroundStyle(Color.alehaAmber)
            } else {
                let nextPrayer = Prayer.allCases.first { todayLog.status(for: $0) == .none }
                if let next = nextPrayer {
                    Label("Next: \(next.rawValue)", systemImage: next.icon)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .font(.subheadline)
    }

    // MARK: - Weekly Consistency Banner
    private var weeklyConsistencyBanner: some View {
        let pct = store.weeklyConsistency
        let color: Color = pct >= 80 ? Color.alehaGreen : (pct >= 50 ? Color.alehaAmber : .red.opacity(0.7))
        return HStack(spacing: 14) {
            Image(systemName: "trophy.fill")
                .font(.title2)
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 3) {
                Text("Weekly Consistency")
                    .font(.subheadline.weight(.semibold))
                Text(consistencyMessage(pct))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(pct)%")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())
        }
        .noorCard()
    }

    private func consistencyMessage(_ pct: Int) -> String {
        switch pct {
        case 90...100: return "Exceptional — keep it up!"
        case 75..<90:  return "Great consistency this week"
        case 50..<75:  return "Good effort — aim for more"
        default:       return "Let's build the habit together"
        }
    }

    // MARK: - Prayer List
    private var prayerListSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Log Your Prayers")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("Swipe to log")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            ForEach(Prayer.allCases) { prayer in
                SwipeToPrayRow(prayer: prayer, status: todayLog.status(for: prayer)) { newStatus in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        store.setStatus(newStatus, prayer: prayer, date: Date())
                    }
                }
            }
        }
        .noorCard()
    }

    // MARK: - Week Overview
    private var weekOverviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This Week")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Label("\(store.currentStreak) day streak", systemImage: "flame.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.alehaAmber)
            }
            weekBars
        }
        .noorCard()
    }

    private var weekBars: some View {
        let completion = store.weekCompletion
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        return HStack(spacing: 8) {
            ForEach(0..<7, id: \.self) { idx in
                VStack(spacing: 6) {
                    barView(completion[idx])
                    Text(days[idx])
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func barView(_ value: Double) -> some View {
        let barColor: Color = value >= 1.0 ? Color.alehaGreen : (value > 0 ? Color.alehaAmber : Color(.systemGray5))
        return VStack {
            Spacer()
            RoundedRectangle(cornerRadius: 4)
                .fill(barColor)
                .frame(width: 26, height: max(8, CGFloat(value) * 48))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: value)
        }
        .frame(height: 52)
    }
}

// MARK: - Swipe-to-Log Row
struct SwipeToPrayRow: View {
    let prayer: Prayer
    let status: PrayerStatus
    let onStatusChange: (PrayerStatus) -> Void
    @State private var dragOffset: CGFloat = 0
    @State private var didJustChange = false

    private let swipeThreshold: CGFloat = 60

    var body: some View {
        ZStack {
            // Swipe hint background
            HStack {
                swipeHintView
                Spacer()
            }
            // Row content
            HStack(spacing: 12) {
                prayerIcon
                prayerLabel
                Spacer()
                statusMenu
            }
            .padding(.vertical, 4)
            .background(Color("NoorSurface"))
            .offset(x: dragOffset)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { v in
                        if v.translation.width > 0 {
                            dragOffset = min(v.translation.width, swipeThreshold * 1.5)
                        }
                    }
                    .onEnded { v in
                        if v.translation.width > swipeThreshold {
                            triggerSwipeLog()
                        }
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            dragOffset = 0
                        }
                    }
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var swipeHintView: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
            Text("Prayed")
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .frame(height: 44)
        .background(Color.alehaGreen)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .opacity(dragOffset > 10 ? Double(dragOffset / swipeThreshold) : 0)
    }

    private func triggerSwipeLog() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        didJustChange = true
        onStatusChange(.prayed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { didJustChange = false }
    }

    private var prayerIcon: some View {
        Image(systemName: prayer.icon)
            .font(.title3)
            .foregroundStyle(status == .none ? .secondary : status.color)
            .frame(width: 32)
            .scaleEffect(didJustChange ? 1.2 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: didJustChange)
    }

    private var prayerLabel: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(prayer.rawValue).font(.body.weight(.medium))
            Text(status.rawValue).font(.caption).foregroundStyle(status.color)
        }
    }

    private var statusMenu: some View {
        Menu {
            ForEach(PrayerStatus.allCases.filter { $0 != .none }, id: \.self) { s in
                Button {
                    onStatusChange(s)
                } label: { Label(s.rawValue, systemImage: s.icon) }
            }
            if status != .none {
                Button(role: .destructive) { onStatusChange(.none) } label: {
                    Label("Clear", systemImage: "trash")
                }
            }
        } label: {
            Image(systemName: status.icon)
                .font(.title2)
                .foregroundStyle(status == .none ? Color(.systemGray3) : status.color)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
        }
    }
}

// MARK: - Legacy Row (Calendar reuse)
struct PrayerLogRow: View {
    let prayer: Prayer
    let status: PrayerStatus
    let onStatusChange: (PrayerStatus) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: prayer.icon)
                .font(.title3)
                .foregroundStyle(status == .none ? .secondary : status.color)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(prayer.rawValue).font(.body.weight(.medium))
                Text(status.rawValue).font(.caption).foregroundStyle(status.color)
            }
            Spacer()
            Menu {
                ForEach(PrayerStatus.allCases.filter { $0 != .none }, id: \.self) { s in
                    Button { onStatusChange(s) } label: {
                        Label(s.rawValue, systemImage: s.icon)
                    }
                }
                if status != .none {
                    Button(role: .destructive) { onStatusChange(.none) } label: {
                        Label("Clear", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: status.icon)
                    .font(.title2)
                    .foregroundStyle(status == .none ? Color(.systemGray3) : status.color)
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
            }
        }
        .padding(.vertical, 3)
    }
}
