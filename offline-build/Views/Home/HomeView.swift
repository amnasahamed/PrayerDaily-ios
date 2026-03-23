import SwiftUI

struct HomeView: View {
    @StateObject private var prayerService = PrayerTimesService.shared
    @EnvironmentObject var salahStore: SalahStore
    @Environment(\.localization) var l10n

    @State private var todayPrayers = SampleData.todayPrayers()

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 28) {
                    prayerSection
                    verseSection
                    quickToolsSection
                    guidesSection
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.bottom, 100)
            }
            .background(CalmingBackground())
            .navigationTitle("PrayerDaily")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showQibla) { NavigationStack { QiblaCompassView() } }
            .sheet(isPresented: $showDhikr) { DhikrSheetWrapper() }
            .sheet(isPresented: $showHijri) { NavigationStack { LibraryHijriView() } }
            .sheet(isPresented: $showDuas) { DuasCategorySheet() }
            .sheet(isPresented: $showQuran) { QuranQuickSheet() }
        }
        .onAppear {
            prayerService.requestLocation()
            loadTodayFromStore()
        }
    }

    // MARK: - Verse Section
    private var verseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "sparkles", title: "Verse of the Day", color: .alehaAmber)

            let verse = DailyVerseService.shared.todaysVerse
            VerseShareCard(
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
            sectionHeader(icon: "moon.stars.fill", title: "Today's Prayers", color: .alehaGreen)

            PrayerTimelineCard(service: prayerService, prayers: $todayPrayers)
                .environmentObject(salahStore)
        }
    }

    // MARK: - Quick Tools Section
    private var quickToolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "bolt.fill", title: "Quick Tools", color: .secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(makeQuickTools()) { tool in
                        QuickToolPill(tool: tool) {
                            handleToolTap(tool)
                        }
                    }
                }
            }
        }
    }

    private struct QuickToolPill: View {
        let tool: QuickToolItem
        let action: () -> Void
        @State private var pressed = false

        var body: some View {
            Button(action: {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                action()
            }) {
                HStack(spacing: 7) {
                    Image(systemName: tool.icon)
                        .font(.system(size: 13, weight: .semibold))
                    Text(tool.label)
                        .font(.subheadline.weight(.medium))
                }
                .foregroundStyle(tool.accent)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(tool.accent.opacity(0.12))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .scaleEffect(pressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.62), value: pressed)
        }
    }

    private struct QuickToolItem: Identifiable {
        let id: String
        let icon: String
        let label: String
        let accent: Color
        let destination: QuickToolDestination
    }

    private enum QuickToolDestination {
        case qibla, dhikr, hijri, duas, quran
    }

    private func makeQuickTools() -> [QuickToolItem] {
        [
            QuickToolItem(id: "qibla", icon: "location.north.fill", label: "Qibla",
                          accent: .alehaGreen, destination: .qibla),
            QuickToolItem(id: "hijri", icon: "moon.stars.fill", label: "Hijri",
                          accent: .alehaAmber, destination: .hijri),
            QuickToolItem(id: "dhikr", icon: "hand.raised.fill", label: "Dhikr",
                          accent: .alehaSaffron, destination: .dhikr),
            QuickToolItem(id: "quran", icon: "book.fill", label: "Quran",
                          accent: .alehaGreen, destination: .quran),
            QuickToolItem(id: "duas", icon: "hands.sparkles.fill", label: "Duas",
                          accent: Color(red: 0.82, green: 0.38, blue: 0.20), destination: .duas),
        ]
    }

    @State private var showQibla = false
    @State private var showDhikr = false
    @State private var showHijri = false
    @State private var showDuas  = false
    @State private var showQuran = false

    private func handleToolTap(_ tool: QuickToolItem) {
        switch tool.destination {
        case .qibla:  showQibla = true
        case .dhikr:  showDhikr = true
        case .hijri:  showHijri = true
        case .duas:   showDuas  = true
        case .quran:  showQuran = true
        }
    }

    // MARK: - Guides Section
    private var guidesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "book.closed.fill", title: "Islamic Guides", color: .secondary)

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

    // MARK: - Section Header Helper
    private func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    // MARK: - Quick Tool Sheet Wrappers
    private struct DhikrSheetWrapper: View {
        @StateObject private var store = SalahStore()
        var body: some View {
            NavigationStack {
                DhikrCounterView()
                    .environmentObject(store)
                    .navigationTitle("Dhikr")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.hidden, for: .navigationBar)
            }
        }
    }

    private struct QuranQuickSheet: View {
        private let featured = QuranData.allSurahs
        var body: some View {
            NavigationStack {
                List(featured) { surah in
                    NavigationLink(destination: SurahReaderView(surah: surah)) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color.alehaGreen.opacity(0.12))
                                    .frame(width: 36, height: 36)
                                Text("\(surah.id)")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.alehaGreen)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(surah.nameTransliteration)
                                    .font(.subheadline.weight(.semibold))
                                Text("\(surah.verses) verses · \(surah.type)")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(surah.nameArabic)
                                .font(.system(size: 17, design: .serif))
                                .foregroundStyle(Color.alehaGreen)
                        }
                    }
                }
                .navigationTitle("Quran")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
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
