import SwiftUI

struct HomeView: View {
    @StateObject private var prayerService = PrayerTimesService.shared
    @EnvironmentObject var salahStore: SalahStore
    @Environment(\.localization) var l10n
    @State private var todayPrayers = SampleData.todayPrayers()
    @State private var appeared = false

    private var greetingTitle: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Good Morning" }
        if h < 17 { return "Good Afternoon" }
        if h < 20 { return "Good Evening" }
        return "Good Night"
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 20) {
                    headerSection
                    verseSection
                    prayerSection
                    quickToolsSection
                    guidesSection
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("PrayerDaily")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            prayerService.requestLocation()
            loadTodayFromStore()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Greeting
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Text("السلام عليكم")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.alehaGreen)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Next prayer card
            if let next = prayerService.nextPrayer {
                nextPrayerBanner(next)
            }

            // Streak card
            streakBanner
        }
        .padding(.top, 8)
    }

    private func nextPrayerBanner(_ next: PrayerTime) -> some View {
        HStack(spacing: 12) {
            Image(systemName: next.prayer.icon)
                .font(.title2)
                .foregroundStyle(Color.alehaGreen)
                .frame(width: 50, height: 50)
                .background(Color.alehaGreen.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Next Prayer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(next.prayer.rawValue)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(next.timeString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(next.time.timeIntervalSinceNow.formattedPrayerCountdown)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.alehaGreen)
                Text("remaining")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.alehaGreen.opacity(0.2), lineWidth: 1)
        )
    }

    private var streakBanner: some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.title3)
                    .foregroundStyle(Color.alehaAmber)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(salahStore.currentStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Text("Day Streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()
                .frame(height: 40)

            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundStyle(Color.alehaGreen)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(weekTotal)/35")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Text("This Week")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if qadaTotal > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "moon.fill")
                        .font(.title3)
                        .foregroundStyle(Color.alehaSaffron)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(qadaTotal)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Text("Qada")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Verse Section
    private var verseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Verse of the Day", systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(Color.alehaAmber)

            let verse = DailyVerseService.shared.todaysVerse
            return VerseShareCard(
                arabic: verse.arabic,
                translation: verse.translation,
                reference: verse.reference,
                tafsir: verse.tafsir
            )
        }
    }

    // MARK: - Prayer Section
    private var prayerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Today's Prayers", systemImage: "moon.stars.fill")
                .font(.headline)
                .foregroundStyle(Color.alehaGreen)

            PrayerTimelineCard(service: prayerService, prayers: $todayPrayers)
                .environmentObject(salahStore)
        }
    }

    // MARK: - Quick Tools Section
    private var quickToolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Quick Tools", systemImage: "bolt.fill")
                .font(.headline)
                .foregroundStyle(Color.alehaGreen)

            QuickToolsRow(service: prayerService)
        }
    }

    // MARK: - Guides Section
    private var guidesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Islamic Guides", systemImage: "book.closed.fill")
                .font(.headline)
                .foregroundStyle(Color.alehaGreen)

            IslamicGuidesSection()
        }
    }

    // MARK: - Helpers
    private func loadTodayFromStore() {
        let today = Date()
        let dayLog = salahStore.log(for: today)
        todayPrayers = Prayer.allCases.map { prayer in
            let completed = dayLog.status(for: prayer) == .prayed || dayLog.status(for: prayer) == .late
            return SalahLogEntry(prayer: prayer, completed: completed, date: today)
        }
    }

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

// MARK: - TimeInterval Extension
extension TimeInterval {
    var formattedPrayerCountdown: String {
        let totalMinutes = Int(self / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}
