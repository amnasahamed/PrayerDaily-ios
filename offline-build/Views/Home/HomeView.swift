import SwiftUI

struct HomeView: View {
    @State private var todayPrayers = SampleData.todayPrayers()
    @State private var streak = SampleData.streak

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    prayerTimesSection
                    dailyReflectionCard
                    readingProgressSection
                    prayerTrackerSection
                    streakSection
                    quickAccessGrid
                    hadithOfDayCard
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.bottom, 30)
            }
            .background(Color("NoorSurface").ignoresSafeArea())
            .navigationTitle("Aleha")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("NoorPrimary"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var prayerTimesSection: some View {
        PrayerTimesCard()
    }

    private var dailyReflectionCard: some View {
        DailyReflectionCard(
            arabic: SampleData.dailyAyah.arabic,
            translation: SampleData.dailyAyah.translation,
            reference: SampleData.dailyAyah.reference,
            tafsir: SampleData.dailyAyah.tafsir
        )
    }

    private var readingProgressSection: some View {
        ReadingProgressCard()
    }

    private var prayerTrackerSection: some View {
        PrayerTrackerCard(prayers: $todayPrayers)
    }

    private var streakSection: some View {
        StreakCard(streak: streak)
    }

    private var quickAccessGrid: some View {
        QuickAccessSection()
    }

    private var hadithOfDayCard: some View {
        HadithCard(hadith: SampleData.hadiths[0])
    }
}
