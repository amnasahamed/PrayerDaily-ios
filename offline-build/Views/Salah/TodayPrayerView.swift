import SwiftUI

struct TodayPrayerView: View {
    @EnvironmentObject var store: SalahStore

    private var todayLog: PrayerDayLog { store.todayLog }
    private var progress: Double { Double(todayLog.completedCount) / 5.0 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
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
                .stroke(Color(.systemGray5), lineWidth: 10)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color("NoorPrimary"), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.5), value: progress)
            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.title.weight(.bold))
                    .foregroundStyle(Color("NoorPrimary"))
                Text("Complete")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 120, height: 120)
    }

    private var statusLabel: some View {
        Group {
            if todayLog.completedCount == 5 {
                Label("All prayers completed! ماشاء الله", systemImage: "star.fill")
                    .foregroundStyle(Color("NoorGold"))
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Log Your Prayers")
                .font(.subheadline.weight(.semibold))
            ForEach(Prayer.allCases) { prayer in
                PrayerLogRow(prayer: prayer, status: todayLog.status(for: prayer)) { newStatus in
                    store.setStatus(newStatus, prayer: prayer, date: Date())
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
                    .foregroundStyle(Color("NoorGold"))
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
        let barColor: Color = value >= 1.0 ? Color("NoorPrimary") : (value > 0 ? Color("NoorGold") : Color(.systemGray5))
        return VStack {
            Spacer()
            RoundedRectangle(cornerRadius: 3)
                .fill(barColor)
                .frame(width: 28, height: max(8, CGFloat(value) * 50))
        }
        .frame(height: 55)
    }
}

// MARK: - Prayer Log Row
struct PrayerLogRow: View {
    let prayer: Prayer
    let status: PrayerStatus
    let onStatusChange: (PrayerStatus) -> Void

    @State private var showPicker = false

    var body: some View {
        HStack(spacing: 14) {
            prayerIcon
            prayerLabel
            Spacer()
            statusButton
        }
        .padding(.vertical, 4)
    }

    private var prayerIcon: some View {
        Image(systemName: prayer.icon)
            .font(.title3)
            .foregroundStyle(status == .none ? .secondary : status.color)
            .frame(width: 36)
    }

    private var prayerLabel: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(prayer.rawValue)
                .font(.body.weight(.medium))
            Text(status.rawValue)
                .font(.caption)
                .foregroundStyle(status.color)
        }
    }

    private var statusButton: some View {
        Menu {
            ForEach(PrayerStatus.allCases.filter { $0 != .none }, id: \.self) { s in
                Button {
                    withAnimation { onStatusChange(s) }
                } label: {
                    Label(s.rawValue, systemImage: s.icon)
                }
            }
            if status != .none {
                Button(role: .destructive) {
                    withAnimation { onStatusChange(.none) }
                } label: {
                    Label("Clear", systemImage: "trash")
                }
            }
        } label: {
            Image(systemName: status.icon)
                .font(.title2)
                .foregroundStyle(status == .none ? Color(.systemGray3) : status.color)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
    }
}
