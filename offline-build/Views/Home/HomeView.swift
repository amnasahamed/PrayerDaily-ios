import SwiftUI

struct HomeView: View {
    @State private var todayPrayers = SampleData.todayPrayers()
    @State private var streak = SampleData.streak

    var body: some View {
        NavigationStack {
            ZStack {
                CalmingBackground()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        greetingHeader
                        prayerTimesSection
                        dailyReflectionCard
                        readingProgressSection
                        prayerTrackerSection
                        quickAccessGrid
                        hadithOfDayCard
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.bottom, 30)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Aleha")
            .modifier(AlehaNavStyle())
        }
    }

    private var greetingHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.title3.weight(.semibold))
                Text("Peace be upon you ✨")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            brandMark
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 17 { return "Good Afternoon" }
        return "Good Evening"
    }

    private var brandMark: some View {
        ZStack {
            Circle().fill(Color("NoorGold").opacity(0.15)).frame(width: 46, height: 46)
            Image(systemName: "moon.stars.fill").font(.title3).foregroundStyle(Color("NoorGold"))
        }
    }

    private var prayerTimesSection: some View { PrayerTimesCard() }
    private var dailyReflectionCard: some View {
        DailyReflectionCard(
            arabic: SampleData.dailyAyah.arabic,
            translation: SampleData.dailyAyah.translation,
            reference: SampleData.dailyAyah.reference,
            tafsir: SampleData.dailyAyah.tafsir
        )
    }
    private var readingProgressSection: some View { ReadingProgressCard() }
    private var prayerTrackerSection: some View { PrayerTrackerCard(prayers: $todayPrayers) }
    private var quickAccessGrid: some View { QuickAccessSection() }
    private var hadithOfDayCard: some View { HadithCard(hadith: SampleData.hadiths[0]) }
}
