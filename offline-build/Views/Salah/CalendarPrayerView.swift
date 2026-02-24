import SwiftUI

struct CalendarPrayerView: View {
    @EnvironmentObject var store: SalahStore
    @State private var displayedMonth = Date()

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                monthNav
                calendarGrid
                selectedDayDetail
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.bottom, 30)
        }
    }

    // MARK: - Month Navigation
    private var monthNav: some View {
        HStack {
            Button { shiftMonth(-1) } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
            }
            Spacer()
            Text(monthTitle)
                .font(.headline)
            Spacer()
            Button { shiftMonth(1) } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
            }
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 8)
        .padding(.top, 8)
    }

    private var monthTitle: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: displayedMonth)
    }

    private func shiftMonth(_ value: Int) {
        withAnimation {
            if let d = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
                displayedMonth = d
            }
        }
    }

    // MARK: - Calendar Grid
    private var calendarGrid: some View {
        VStack(spacing: 4) {
            weekdayHeader
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysInMonth(), id: \.self) { item in
                    calendarCell(item)
                }
            }
        }
        .noorCard()
    }

    private var weekdayHeader: some View {
        HStack {
            ForEach(weekdayLabels, id: \.self) { d in
                Text(d)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func calendarCell(_ item: CalendarDay) -> some View {
        let isSelected = calendar.isDate(item.date, inSameDayAs: store.selectedDate)
        let isToday = calendar.isDateInToday(item.date)
        let dayLog = store.log(for: item.date)
        let ratio = CGFloat(dayLog.completedCount) / 5.0

        return Button {
            withAnimation(.spring(response: 0.3)) { store.selectedDate = item.date }
        } label: {
            VStack(spacing: 2) {
                Text(item.isPlaceholder ? "" : "\(item.day)")
                    .font(.caption.weight(isToday ? .bold : .regular))
                    .foregroundStyle(foregroundForCell(item: item, isSelected: isSelected, isToday: isToday))
                    .frame(width: 32, height: 32)
                    .background(cellBackground(isSelected: isSelected, isToday: isToday))
                    .clipShape(Circle())

                if !item.isPlaceholder {
                    prayerDots(ratio)
                }
            }
            .frame(height: 48)
        }
        .buttonStyle(.plain)
        .disabled(item.isPlaceholder)
    }

    private func foregroundForCell(item: CalendarDay, isSelected: Bool, isToday: Bool) -> Color {
        if item.isPlaceholder { return .clear }
        if isSelected { return .white }
        if isToday { return Color("NoorPrimary") }
        return .primary
    }

    private func cellBackground(isSelected: Bool, isToday: Bool) -> some ShapeStyle {
        if isSelected { return AnyShapeStyle(Color("NoorPrimary")) }
        if isToday { return AnyShapeStyle(Color("NoorPrimary").opacity(0.12)) }
        return AnyShapeStyle(Color.clear)
    }

    private func prayerDots(_ ratio: CGFloat) -> some View {
        let dotColor: Color = ratio >= 1.0 ? Color("NoorPrimary") : (ratio > 0 ? Color("NoorGold") : Color(.systemGray5))
        return Circle()
            .fill(dotColor)
            .frame(width: 5, height: 5)
    }

    // MARK: - Selected Day Detail
    private var selectedDayDetail: some View {
        let dayLog = store.log(for: store.selectedDate)
        return VStack(alignment: .leading, spacing: 12) {
            Text(selectedDayTitle)
                .font(.subheadline.weight(.semibold))
            ForEach(Prayer.allCases) { prayer in
                PrayerLogRow(prayer: prayer, status: dayLog.status(for: prayer)) { newStatus in
                    store.setStatus(newStatus, prayer: prayer, date: store.selectedDate)
                }
            }
        }
        .noorCard()
    }

    private var selectedDayTitle: String {
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: store.selectedDate)
    }

    // MARK: - Helpers
    private func daysInMonth() -> [CalendarDay] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }
        let startWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        var items: [CalendarDay] = []
        for _ in 0..<startWeekday {
            items.append(CalendarDay(day: 0, date: Date(), isPlaceholder: true))
        }
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                items.append(CalendarDay(day: day, date: date, isPlaceholder: false))
            }
        }
        return items
    }
}

struct CalendarDay: Hashable {
    let day: Int
    let date: Date
    let isPlaceholder: Bool
}
