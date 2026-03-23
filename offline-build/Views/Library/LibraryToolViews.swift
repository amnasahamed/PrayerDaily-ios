import SwiftUI

// MARK: - Library Dhikr View (wraps DhikrCounterView with its own store)
struct LibraryDhikrView: View {
    @StateObject private var store = SalahStore()
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        ZStack {
            CalmingBackground()
            DhikrCounterView()
                .environmentObject(store)
        }
        .navigationTitle(localization.t(.dhikrTitle))
        .navigationBarTitleDisplayMode(.inline)
        .modifier(AlehaNavStyle())
    }
}

// MARK: - Library Hijri Calendar View
struct LibraryHijriView: View {
    @StateObject private var prayerService = PrayerTimesService.shared
    @State private var displayedMonthOffset: Int = 0
    @Environment(\.colorScheme) var cs
    @EnvironmentObject var localization: LocalizationManager

    private let hijriCal = Calendar(identifier: .islamicUmmAlQura)
    private let gregCal = Calendar.current

    private var displayedGregorianMonth: Date {
        gregCal.date(byAdding: .month, value: displayedMonthOffset, to: Date()) ?? Date()
    }

    var body: some View {
        ZStack {
            CalmingBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    todayBanner
                    monthNavigator
                    calendarGrid
                    islamicEventsCard
                    islamicMonthsCard
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle(localization.t(.libraryIslamicCalendar))
        .navigationBarTitleDisplayMode(.inline)
        .sheetDismissButton()
        .modifier(AlehaNavStyle())
        .onAppear { prayerService.requestLocation() }
    }

    // MARK: - Today Banner
    private var todayBanner: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(Color.alehaDarkGreen.opacity(0.12)).frame(width: 52, height: 52)
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color.alehaDarkGreen)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(prayerService.hijriDate.isEmpty ? "Loading…" : prayerService.hijriDate)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.alehaDarkGreen)
                Text(gregorianToday)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(currentHijriMonthName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.alehaDarkGreen)
                Text("AH \(currentHijriYear)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(
                    colors: [Color.alehaDarkGreen.opacity(cs == .dark ? 0.2 : 0.08), Color.alehaDarkGreen.opacity(0.03)],
                    startPoint: .leading, endPoint: .trailing
                ))
        )
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.alehaDarkGreen.opacity(0.15), lineWidth: 1))
    }

    // MARK: - Month Navigator
    private var monthNavigator: some View {
        HStack {
            Button { withAnimation(.spring(response: 0.3)) { displayedMonthOffset -= 1 } } label: {
                Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.alehaDarkGreen)
                    .frame(width: 36, height: 36)
                    .background(Color.alehaDarkGreen.opacity(0.1))
                    .clipShape(Circle())
            }
            Spacer()
            VStack(spacing: 2) {
                Text(monthYearString(displayedGregorianMonth))
                    .font(.headline.weight(.bold))
                Text(hijriMonthYearString(displayedGregorianMonth))
                    .font(.caption)
                    .foregroundStyle(Color.alehaDarkGreen)
            }
            Spacer()
            Button { withAnimation(.spring(response: 0.3)) { displayedMonthOffset += 1 } } label: {
                Image(systemName: "chevron.right").font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.alehaDarkGreen)
                    .frame(width: 36, height: 36)
                    .background(Color.alehaDarkGreen.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Calendar Grid
    private var calendarGrid: some View {
        VStack(spacing: 12) {
            // Day headers
            HStack(spacing: 0) {
                ForEach(["Su","Mo","Tu","We","Th","Fr","Sa"], id: \.self) { d in
                    Text(d)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(d == "Fr" ? Color.alehaDarkGreen : .secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            // Day cells
            let days = daysInMonth(displayedGregorianMonth)
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        dayCellView(date)
                    } else {
                        Color.clear.frame(height: 48)
                    }
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(cs == .dark ? Color(.systemGray6) : Color.white))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    private func dayCellView(_ date: Date) -> some View {
        let isToday = gregCal.isDateInToday(date)
        let hijriDay = hijriCal.component(.day, from: date)
        let gregDay = gregCal.component(.day, from: date)
        let event = islamicEventForDate(date)
        return VStack(spacing: 2) {
            ZStack {
                if isToday {
                    Circle()
                        .fill(Color.alehaDarkGreen)
                        .frame(width: 32, height: 32)
                } else if event != nil {
                    Circle()
                        .fill(Color.alehaAmber.opacity(0.2))
                        .frame(width: 32, height: 32)
                }
                VStack(spacing: 0) {
                    Text("\(gregDay)")
                        .font(.system(size: 13, weight: isToday ? .bold : .regular))
                        .foregroundStyle(isToday ? .white : .primary)
                    Text("\(hijriDay)")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(isToday ? .white.opacity(0.8) : Color.alehaDarkGreen.opacity(0.7))
                }
            }
            .frame(height: 38)
            if event != nil {
                Circle().fill(Color.alehaAmber).frame(width: 4, height: 4)
            } else {
                Color.clear.frame(height: 4)
            }
        }
    }

    // MARK: - Events Card
    private var islamicEventsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2).fill(Color.alehaAmber).frame(width: 4, height: 18)
                Text(localization.t(.hijriUpcomingEvents))
                    .font(.headline.weight(.bold))
                Spacer()
            }
            ForEach(upcomingEvents, id: \.0) { event in
                HStack(spacing: 12) {
                    Text(event.2).font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.0).font(.subheadline.weight(.semibold))
                        Text(event.1).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
                if event.0 != upcomingEvents.last?.0 { Divider() }
            }
        }
        .noorCard()
    }

    // MARK: - Islamic Months Reference
    private var islamicMonthsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2).fill(Color.alehaDarkGreen).frame(width: 4, height: 18)
                Text(localization.t(.hijriIslamicMonths)).font(.headline.weight(.bold))
                Spacer()
            }
            ForEach(islamicMonths, id: \.0) { month in
                HStack {
                    Text(month.0).font(.subheadline.weight(.medium))
                    Spacer()
                    if !month.1.isEmpty {
                        Text(month.1).font(.caption).foregroundStyle(Color.alehaDarkGreen)
                    }
                }
                .padding(.vertical, 3)
                if month.0 != islamicMonths.last?.0 { Divider() }
            }
        }
        .noorCard()
    }

    // MARK: - Helpers
    private var gregorianToday: String {
        let f = DateFormatter(); f.dateStyle = .full; return f.string(from: Date())
    }

    private var currentHijriMonthName: String {
        let m = hijriCal.component(.month, from: Date())
        return hijriMonthNames[safe: m - 1] ?? "—"
    }

    private var currentHijriYear: Int {
        hijriCal.component(.year, from: Date())
    }

    private func monthYearString(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"; return f.string(from: date)
    }

    private func hijriMonthYearString(_ date: Date) -> String {
        let m = hijriCal.component(.month, from: date)
        let y = hijriCal.component(.year, from: date)
        let name = hijriMonthNames[safe: m - 1] ?? "—"
        return "\(name) \(y) AH"
    }

    private func daysInMonth(_ date: Date) -> [Date?] {
        guard let range = gregCal.range(of: .day, in: .month, for: date),
              let first = gregCal.date(from: gregCal.dateComponents([.year, .month], from: date))
        else { return [] }
        let weekday = (gregCal.component(.weekday, from: first) - 1 + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: weekday)
        for d in range {
            days.append(gregCal.date(byAdding: .day, value: d - 1, to: first))
        }
        return days
    }

    private func islamicEventForDate(_ date: Date) -> String? {
        let hijriMonth = hijriCal.component(.month, from: date)
        let hijriDay = hijriCal.component(.day, from: date)
        let key = "\(hijriMonth)-\(hijriDay)"
        return islamicEventMap[key]
    }

    private let islamicEventMap: [String: String] = [
        "1-1": "Islamic New Year", "1-10": "Ashura",
        "3-12": "Mawlid al-Nabi ﷺ", "7-27": "Isra & Mi'raj",
        "8-15": "Night of Bara'ah", "9-1": "Ramadan Begins",
        "9-27": "Laylat al-Qadr", "10-1": "Eid al-Fitr",
        "12-8": "Hajj begins", "12-9": "Day of Arafah", "12-10": "Eid al-Adha"
    ]

    private let upcomingEvents: [(String, String, String)] = [
        ("Laylat al-Qadr", "27 Ramadan", "🌙"),
        ("Eid al-Fitr", "1 Shawwal", "🌙"),
        ("Day of Arafah", "9 Dhu al-Hijjah", "🕋"),
        ("Eid al-Adha", "10 Dhu al-Hijjah", "🐏")
    ]

    private let hijriMonthNames = ["Muharram","Safar","Rabi al-Awwal","Rabi al-Thani",
                                    "Jumada al-Awwal","Jumada al-Thani","Rajab","Sha'ban",
                                    "Ramadan","Shawwal","Dhu al-Qi'dah","Dhu al-Hijjah"]

    private let islamicMonths: [(String, String)] = [
        ("1. Muharram", "Sacred month"),
        ("2. Safar", ""),
        ("3. Rabi al-Awwal", "Birth of the Prophet ﷺ"),
        ("4. Rabi al-Thani", ""),
        ("5. Jumada al-Awwal", ""),
        ("6. Jumada al-Thani", ""),
        ("7. Rajab", "Sacred month"),
        ("8. Sha'ban", "Night of Bara'ah"),
        ("9. Ramadan", "Month of fasting"),
        ("10. Shawwal", "Eid al-Fitr"),
        ("11. Dhu al-Qi'dah", "Sacred month"),
        ("12. Dhu al-Hijjah", "Hajj & Eid al-Adha")
    ]
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Library Prayer Tracker View (wraps full Salah dashboard)
struct LibraryPrayerTrackerView: View {
    @StateObject private var store = SalahStore()
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        ZStack {
            CalmingBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerCard
                    weekOverview
                    todayPrayers
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle(localization.t(.trackerPrayerTracker))
        .navigationBarTitleDisplayMode(.inline)
        .modifier(AlehaNavStyle())
    }

    private var headerCard: some View {
        HStack(spacing: 0) {
            statCell("\(store.currentStreak)", label: localization.t(.salahStreak))
            Divider().frame(height: 44)
            statCell("\(store.weeklyConsistency)%", label: localization.t(.salahThisWeek))
            Divider().frame(height: 44)
            statCell("\(store.todayLog.completedCount)/5", label: localization.t(.salahToday))
        }
        .noorCard()
    }

    private func statCell(_ value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.alehaGreen)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var weekOverview: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.t(.salahThisWeek))
                .font(.headline.weight(.bold))
            HStack(spacing: 8) {
                ForEach(0..<7) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: -(6 - offset), to: Date()) ?? Date()
                    let count = store.log(for: date).completedCount
                    let isToday = offset == 6
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(barColor(count))
                            .frame(height: max(8, CGFloat(count) / 5.0 * 48))
                        Text(dayLabel(offset)).font(.caption2).foregroundStyle(isToday ? Color.alehaGreen : .secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .bottom)
                }
            }
            .frame(height: 68, alignment: .bottom)
        }
        .noorCard()
    }

    private var todayPrayers: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.t(.trackerTodaysLog))
                .font(.headline.weight(.bold))
            ForEach(Prayer.allCases) { prayer in
                HStack(spacing: 12) {
                    Image(systemName: prayer.icon)
                        .font(.title3)
                        .foregroundStyle(store.todayLog.status(for: prayer).color)
                        .frame(width: 32)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(prayer.rawValue).font(.body.weight(.medium))
                        Text(store.todayLog.status(for: prayer).rawValue)
                            .font(.caption)
                            .foregroundStyle(store.todayLog.status(for: prayer).color)
                    }
                    Spacer()
                    Menu {
                        ForEach(PrayerStatus.allCases.filter { $0 != .none }, id: \.self) { s in
                            Button {
                                withAnimation { store.setStatus(s, prayer: prayer, date: Date()) }
                            } label: {
                                Label(s.rawValue, systemImage: s.icon)
                            }
                        }
                        if store.todayLog.status(for: prayer) != .none {
                            Button(role: .destructive) {
                                store.setStatus(.none, prayer: prayer, date: Date())
                            } label: {
                                Label(localization.t(.trackerClear), systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: store.todayLog.status(for: prayer).icon)
                            .font(.title2)
                            .foregroundStyle(store.todayLog.status(for: prayer) == .none
                                             ? Color(.systemGray3)
                                             : store.todayLog.status(for: prayer).color)
                            .frame(width: 40, height: 40)
                            .contentShape(Rectangle())
                    }
                }
                .padding(.vertical, 3)
                if prayer != Prayer.allCases.last {
                    Divider().padding(.leading, 44)
                }
            }
        }
        .noorCard()
    }

    private func dayLabel(_ offset: Int) -> String {
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: Date()) - 2 // Monday = 0
        let idx = ((weekday - (6 - offset)) + 7) % 7
        return days[idx % 7]
    }

    private func barColor(_ count: Int) -> Color {
        switch count {
        case 5:     return Color.alehaGreen
        case 3..<5: return Color.alehaAmber
        case 1..<3: return .orange
        default:    return Color(.systemGray5)
        }
    }
}
