import SwiftUI

struct TodayPrayerView: View {
    @EnvironmentObject var store: SalahStore
    @EnvironmentObject var localization: LocalizationManager
    @Environment(\.localization) var l10n
    @State private var showShareProgress = false
    @State private var confettiBurst = false
    @State private var appeared = false
    @State private var previousCount = 0

    private var isMl: Bool { l10n.currentLanguage == .malayalam }
    private var todayLog: PrayerDayLog { store.todayLog }
    private var progress: Double { Double(todayLog.completedCount) / 5.0 }

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppTheme.sectionSpacing) {
                    heroCard.slideUp(appeared, delay: 0.05)
                    weeklyConsistencyBanner.slideUp(appeared, delay: 0.12)
                    prayerListSection.slideUp(appeared, delay: 0.18)
                    weekOverviewCard.slideUp(appeared, delay: 0.24)
                    shareProgressButton.slideUp(appeared, delay: 0.30)
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.top, 12)
                .padding(.bottom, 120)
            }
            ConfettiBurst(trigger: $confettiBurst)
        }
        .onAppear {
            previousCount = todayLog.completedCount
            withAnimation { appeared = true }
        }
        .onChange(of: todayLog.completedCount) { _, newVal in
            if newVal == 5 && previousCount < 5 {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { confettiBurst = true }
            }
            previousCount = newVal
        }
    }

    // MARK: - Hero
    private var heroCard: some View {
        HStack(spacing: 20) {
            progressRing
            VStack(alignment: .leading, spacing: 6) {
                Text(isMl ? "\(todayLog.completedCount) / 5 നമസ്കാരം" : "\(todayLog.completedCount) \(localization.t(.todayOf5Prayers))")
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
        if isMl {
            if remaining == 0 { return "ഇന്നത്തെ എല്ലാ നമസ്കാരവും — അൽഹംദുലില്ലാഹ്" }
            return "\(remaining) നമസ്കാരം ബാക്കി"
        }
        if remaining == 0 { return localization.t(.todayAllPrayersDone) }
        return "\(remaining) \(localization.t(.todayPrayersRemaining))"
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
                Text(localization.t(.todayLabel))
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
                    Text(localization.t(.todayShareProgress))
                        .font(.subheadline.weight(.semibold))
                    Text(localization.t(.todayShareStatsDesc))
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
                .environmentObject(localization)
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
                    Label("\(localization.t(.headerNextPrayer)): \(next.localizedName(isMalayalam: isMl))", systemImage: next.icon)
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
                Text(localization.t(.salahWeeklyConsistency))
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
        if isMl {
            switch pct {
            case 90...100: return "അസാധ്യം — തുടർന്നും!"
            case 75..<90:  return "ഈ ആഴ്ച നല്ല കൃത്യത"
            case 50..<75:  return "നല്ല ശ്രമം — കൂടുതൽ ലക്ഷ്യം"
            default:       return "ഒരുമിച്ച് ശീലം ഉണ്ടാക്കാം"
            }
        }
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
                Text(localization.t(.salahLogPrayer))
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(localization.t(.todaySwipeToLog))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            ForEach(Prayer.allCases) { prayer in
                SwipeToPrayRow(prayer: prayer, status: todayLog.status(for: prayer), isMalayalam: isMl) { newStatus in
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
                Text(localization.t(.salahThisWeek))
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Label("\(store.currentStreak) \(localization.t(.salahDayStreak))", systemImage: "flame.fill")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.alehaAmber)
            }
            weekBars
        }
        .noorCard()
    }

    private var weekBars: some View {
        let completion = store.weekCompletion
        let days = isMl ? ["തി", "ചൊ", "ബു", "വ്യ", "വെ", "ശ", "ഞ"] : ["M", "T", "W", "T", "F", "S", "S"]
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
    @EnvironmentObject var localization: LocalizationManager
    let prayer: Prayer
    let status: PrayerStatus
    var isMalayalam: Bool = false
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
            Text(localization.t(.salahPrayed))
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
            Text(prayer.localizedName(isMalayalam: isMalayalam)).font(.body.weight(.medium))
            Text(status.localizedName(isMalayalam: isMalayalam)).font(.caption).foregroundStyle(status.color)
        }
    }

    private var statusMenu: some View {
        Menu {
            ForEach(PrayerStatus.allCases.filter { $0 != .none }, id: \.self) { s in
                Button {
                    onStatusChange(s)
                } label: { Label(s.localizedName(isMalayalam: isMalayalam), systemImage: s.icon) }
            }
            if status != .none {
                Button(role: .destructive) { onStatusChange(.none) } label: {
                    Label(localization.t(.salahClear), systemImage: "trash")
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
    @EnvironmentObject var localization: LocalizationManager
    let prayer: Prayer
    let status: PrayerStatus
    var isMalayalam: Bool = false
    let onStatusChange: (PrayerStatus) -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: prayer.icon)
                .font(.title3)
                .foregroundStyle(status == .none ? .secondary : status.color)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(prayer.localizedName(isMalayalam: isMalayalam)).font(.body.weight(.medium))
                Text(status.localizedName(isMalayalam: isMalayalam)).font(.caption).foregroundStyle(status.color)
            }
            Spacer()
            Menu {
                ForEach(PrayerStatus.allCases.filter { $0 != .none }, id: \.self) { s in
                    Button { onStatusChange(s) } label: {
                        Label(s.localizedName(isMalayalam: isMalayalam), systemImage: s.icon)
                    }
                }
                if status != .none {
                    Button(role: .destructive) { onStatusChange(.none) } label: {
                        Label(localization.t(.salahClear), systemImage: "trash")
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
