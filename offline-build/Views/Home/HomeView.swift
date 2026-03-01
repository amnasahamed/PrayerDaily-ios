import SwiftUI

struct HomeView: View {
    @StateObject private var prayerService = PrayerTimesService.shared
    @EnvironmentObject var salahStore: SalahStore
    @Environment(\.localization) var l10n
    @State private var todayPrayers = SampleData.todayPrayers()
    @State private var appeared = false

    var body: some View {
        ZStack {
            CalmingBackground()
            mainScroll
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .principal) { navLogo } }
        .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            prayerService.requestLocation()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.05)) {
                appeared = true
            }
        }
    }

    // MARK: - Main Scroll
    private var mainScroll: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppTheme.sectionSpacing) {
                headerSection
                sectionLabel("moon.stars.fill", l10n.t(.homeSalah))
                prayerBlock
                sectionLabel("bolt.fill", l10n.t(.homeQuickTools))
                quickTools
                sectionLabel("book.closed.fill", "Islamic Guides")
                guidesSection
                sectionLabel("text.quote", l10n.t(.homeVerseOfDay))
                verseCard
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, 4)
            .padding(.bottom, 120)
        }
    }

    // MARK: - Nav Logo
    private var navLogo: some View {
        HStack(spacing: 6) {
            AlehaLogoMark(size: 20)
            Text("aleha")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.alehaGreen)
        }
    }

    // MARK: - Section Label
    private func sectionLabel(_ icon: String, _ title: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.alehaGreen)
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .kerning(1.1)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 10)
    }

    // MARK: - Sections
    private var headerSection: some View {
        SmartHeaderView(service: prayerService)
            .staggerAppear(appeared, index: 0)
    }

    private var prayerBlock: some View {
        PrayerTimelineCard(service: prayerService, prayers: $todayPrayers)
            .environmentObject(salahStore)
            .staggerAppear(appeared, index: 1)
    }

    private var quickTools: some View {
        QuickToolsRow(service: prayerService)
            .staggerAppear(appeared, index: 2)
    }

    private var guidesSection: some View {
        IslamicGuidesSection()
            .staggerAppear(appeared, index: 3)
    }

    private var verseCard: some View {
        let verse = DailyVerseService.shared.todaysVerse
        return VerseShareCard(
            arabic: verse.arabic,
            translation: verse.translation,
            reference: verse.reference,
            tafsir: verse.tafsir
        )
        .staggerAppear(appeared, index: 4)
    }
}
