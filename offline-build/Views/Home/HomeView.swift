import SwiftUI

struct HomeView: View {
    @State private var todayPrayers = SampleData.todayPrayers()
    @State private var streak = SampleData.streak

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    dailyReflectionCard
                    prayerTrackerSection
                    streakSection
                    quickAccessGrid
                    hadithOfDayCard
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.bottom, 30)
            }
            .background(Color("NoorSurface").ignoresSafeArea())
            .navigationTitle("Noor")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("NoorPrimary"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Daily Reflection
    private var dailyReflectionCard: some View {
        DailyReflectionCard(
            arabic: SampleData.dailyAyah.arabic,
            translation: SampleData.dailyAyah.translation,
            reference: SampleData.dailyAyah.reference,
            tafsir: SampleData.dailyAyah.tafsir
        )
    }

    // MARK: - Prayer Tracker
    private var prayerTrackerSection: some View {
        PrayerTrackerCard(prayers: $todayPrayers)
    }

    // MARK: - Streak
    private var streakSection: some View {
        StreakCard(streak: streak)
    }

    // MARK: - Quick Access
    private var quickAccessGrid: some View {
        QuickAccessSection()
    }

    // MARK: - Hadith
    private var hadithOfDayCard: some View {
        HadithCard(hadith: SampleData.hadiths[0])
    }
}
