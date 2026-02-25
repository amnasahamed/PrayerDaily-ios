import SwiftUI

// MARK: - Library Dhikr View (wraps DhikrCounterView with its own store)
struct LibraryDhikrView: View {
    @StateObject private var store = SalahStore()

    var body: some View {
        ZStack {
            CalmingBackground()
            DhikrCounterView()
                .environmentObject(store)
        }
        .navigationTitle("Dhikr Counter")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(AlehaNavStyle())
    }
}

// MARK: - Library Hijri Calendar View
struct LibraryHijriView: View {
    @StateObject private var prayerService = PrayerTimesService.shared
    @State private var selectedDate = Date()
    @Environment(\.colorScheme) var cs

    var body: some View {
        ZStack {
            CalmingBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    hijriTodayCard
                    converterCard
                    monthInfoCard
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.top, 8)
                .padding(.bottom, 60)
            }
        }
        .navigationTitle("Hijri Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(AlehaNavStyle())
        .onAppear { prayerService.requestLocation() }
    }

    // MARK: - Today Card
    private var hijriTodayCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.alehaDarkGreen.opacity(0.12))
                    .frame(width: 72, height: 72)
                Text("🌙")
                    .font(.system(size: 36))
            }
            VStack(spacing: 6) {
                Text("Today's Hijri Date")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(prayerService.hijriDate.isEmpty ? "Loading…" : prayerService.hijriDate)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.alehaDarkGreen)
                    .multilineTextAlignment(.center)
                Text(gregorianToday)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .noorCard()
    }

    // MARK: - Converter Card
    private var converterCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2).fill(Color.alehaDarkGreen).frame(width: 4, height: 18)
                Text("Date Converter")
                    .font(.headline.weight(.bold))
                Spacer()
            }

            DatePicker("Select Gregorian Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Color.alehaDarkGreen)

            VStack(spacing: 8) {
                HStack {
                    Text("Gregorian").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Text(formatDate(selectedDate)).font(.subheadline.weight(.semibold))
                }
                Divider()
                HStack {
                    Text("Hijri").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Text(hijriForDate(selectedDate))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.alehaDarkGreen)
                }
            }
            .noorCard()
        }
        .noorCard()
    }

    // MARK: - Month Info
    private var monthInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2).fill(Color.alehaDarkGreen).frame(width: 4, height: 18)
                Text("Islamic Months")
                    .font(.headline.weight(.bold))
                Spacer()
            }
            ForEach(islamicMonths, id: \.0) { month in
                HStack {
                    Text(month.0)
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    if !month.1.isEmpty {
                        Text(month.1)
                            .font(.caption)
                            .foregroundStyle(Color.alehaDarkGreen)
                    }
                }
                .padding(.vertical, 3)
                if month.0 != islamicMonths.last?.0 {
                    Divider()
                }
            }
        }
        .noorCard()
    }

    // MARK: - Helpers
    private var gregorianToday: String {
        let f = DateFormatter(); f.dateStyle = .full
        return f.string(from: Date())
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter(); f.dateStyle = .long
        return f.string(from: date)
    }

    private func hijriForDate(_ date: Date) -> String {
        let cal = Calendar(identifier: .islamicUmmAlQura)
        let components = cal.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year, let month = components.month, let day = components.day else {
            return "—"
        }
        let monthNames = ["Muharram", "Safar", "Rabi al-Awwal", "Rabi al-Thani",
                          "Jumada al-Awwal", "Jumada al-Thani", "Rajab", "Sha'ban",
                          "Ramadan", "Shawwal", "Dhu al-Qi'dah", "Dhu al-Hijjah"]
        let monthName = month >= 1 && month <= 12 ? monthNames[month - 1] : "\(month)"
        return "\(day) \(monthName) \(year) AH"
    }

    private let islamicMonths: [(String, String)] = [
        ("1. Muharram", "Sacred month"),
        ("2. Safar", ""),
        ("3. Rabi al-Awwal", "Birth of the Prophet ﷺ"),
        ("4. Rabi al-Thani", ""),
        ("5. Jumada al-Awwal", ""),
        ("6. Jumada al-Thani", ""),
        ("7. Rajab", "Sacred month"),
        ("8. Sha'ban", "Night of Bara'ah"),
        ("9. Ramadan", "Month of fasting 🌙"),
        ("10. Shawwal", "Eid al-Fitr"),
        ("11. Dhu al-Qi'dah", "Sacred month"),
        ("12. Dhu al-Hijjah", "Hajj & Eid al-Adha")
    ]
}

// MARK: - Library Prayer Tracker View (wraps full Salah dashboard)
struct LibraryPrayerTrackerView: View {
    @StateObject private var store = SalahStore()

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
                .padding(.top, 8)
                .padding(.bottom, 60)
            }
        }
        .navigationTitle("Prayer Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .modifier(AlehaNavStyle())
    }

    private var headerCard: some View {
        HStack(spacing: 0) {
            statCell("\(store.currentStreak)🔥", label: "Streak")
            Divider().frame(height: 44)
            statCell("\(store.weeklyConsistency)%", label: "This Week")
            Divider().frame(height: 44)
            statCell("\(store.todayLog.completedCount)/5", label: "Today")
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
            Text("This Week")
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
            Text("Today's Log")
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
                                Label("Clear", systemImage: "trash")
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
