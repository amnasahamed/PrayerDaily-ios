import SwiftUI

struct TodayPrayerView: View {
    @EnvironmentObject var store: SalahStore

    private var todayLog: PrayerDayLog { store.todayLog }
    private var progress: Double { Double(todayLog.completedCount) / 5.0 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                heroCard
                prayerListSection
                weekOverviewCard
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.bottom, 30)
        }
    }

    // MARK: - Hero
    private var heroCard: some View {
        VStack(spacing: 14) {
            progressRing
            Text("\(todayLog.completedCount) of 5 Prayers")
                .font(.headline)
            statusLabel
        }
        .frame(maxWidth: .infinity)
        .noorCard()
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.alehaGreen, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.7, dampingFraction: 0.8), value: progress)
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.alehaGreen)
                    .contentTransition(.numericText())
                Text("Complete")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 110, height: 110)
    }

    private var statusLabel: some View {
        Group {
            if todayLog.completedCount == 5 {
                Label("All prayers completed! ماشاء الله", systemImage: "star.fill")
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

    // MARK: - Prayer List
    private var prayerListSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Log Your Prayers")
                .font(.subheadline.weight(.semibold))
            ForEach(Prayer.allCases) { prayer in
                PrayerLogRow(prayer: prayer, status: todayLog.status(for: prayer)) { newStatus in
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
                Text("🔥 \(store.currentStreak) day streak")
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

// MARK: - Prayer Log Row
struct PrayerLogRow: View {
    let prayer: Prayer
    let status: PrayerStatus
    let onStatusChange: (PrayerStatus) -> Void
    @State private var didJustChange = false

    var body: some View {
        HStack(spacing: 12) {
            prayerIcon
            prayerLabel
            Spacer()
            statusButton
        }
        .padding(.vertical, 3)
    }

    private var prayerIcon: some View {
        Image(systemName: prayer.icon)
            .font(.title3)
            .foregroundStyle(status == .none ? .secondary : status.color)
            .frame(width: 32)
            .scaleEffect(didJustChange ? 1.15 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: didJustChange)
    }

    private var prayerLabel: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(prayer.rawValue).font(.body.weight(.medium))
            Text(status.rawValue).font(.caption).foregroundStyle(status.color)
        }
    }

    private var statusButton: some View {
        Menu {
            ForEach(PrayerStatus.allCases.filter { $0 != .none }, id: \.self) { s in
                Button {
                    didJustChange = true
                    onStatusChange(s)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { didJustChange = false }
                } label: {
                    Label(s.rawValue, systemImage: s.icon)
                }
            }
            if status != .none {
                Button(role: .destructive) {
                    onStatusChange(.none)
                } label: {
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
