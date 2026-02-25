import SwiftUI

struct StreakCard: View {
    let streak: ReadingStreak

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
                .foregroundStyle(Color("NoorGold"))
            Text("\(streak.currentDays)")
                .font(.title2.weight(.bold))
            Text("days")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 64, height: 80)
        .background(Color("NoorGold").opacity(0.12))
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
                .foregroundStyle(streak.todayRead ? Color("NoorPrimary") : .orange)
        }
    }

    private var weekDots: some View {
        VStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { day in
                Circle()
                    .fill(day < 5 ? Color("NoorPrimary") : Color(.systemGray4))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
