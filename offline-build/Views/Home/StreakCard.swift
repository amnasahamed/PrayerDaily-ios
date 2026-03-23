import SwiftUI

struct StreakCard: View {
    let streak: ReadingStreak
    @EnvironmentObject var salahStore: SalahStore

    var body: some View {
        HStack(spacing: 16) {
            streakBadge
            statsColumn
            Spacer()
            weekDots
        }
        .noorCard()
    }

    private var streakBadge: some View {
        VStack(spacing: 2) {
            Image(systemName: "flame.fill")
                .font(.title)
                .foregroundStyle(Color.alehaAmber)
            Text("\(streak.currentDays)")
                .font(.title2.weight(.bold))
            Text("days")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 64, height: 80)
        .background(Color.alehaAmber.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallRadius))
    }

    private var statsColumn: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Reading Streak")
                .font(.subheadline.weight(.semibold))
            Text("Best: \(streak.bestDays) days")
                .font(.caption)
                .foregroundStyle(.secondary)
            let todayLabel = streak.todayRead ? "\(streak.pagesReadToday) pages today" : "Read today to continue!"
            Text(todayLabel)
                .font(.caption)
                .foregroundStyle(streak.todayRead ? Color.alehaGreen : .orange)
        }
    }

    private var weekDots: some View {
        let completion = salahStore.weekCompletion
        return VStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { day in
                Circle()
                    .fill(day < completion.count && completion[day] > 0 ? Color.alehaGreen : Color(.systemGray4))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
