import SwiftUI

struct HomeView: View {
    @State private var todayPrayers = SampleData.todayPrayers()
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                CalmingBackground()
                mainScroll
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .principal) { navLogo } }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.05)) {
                    appeared = true
                }
            }
        }
    }

    private var mainScroll: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                heroSection
                prayerTimesSection
                prayerTrackerSection
                qiblaAndDhikrRow
                dailyReflection
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
    }

    private var navLogo: some View {
        HStack(spacing: 6) {
            AlehaLogoMark(size: 20)
            Text("aleha")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Color.alehaGreen)
        }
    }

    private var heroSection: some View {
        HeroCard(appeared: appeared)
            .staggerAppear(appeared, index: 0)
    }

    private var prayerTimesSection: some View {
        PrayerTimesCard()
            .staggerAppear(appeared, index: 1)
    }

    private var prayerTrackerSection: some View {
        PrayerTrackerCard(prayers: $todayPrayers)
            .staggerAppear(appeared, index: 2)
    }

    private var qiblaAndDhikrRow: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: QiblaCompassView()) {
                CompactQiblaCard()
            }
            .buttonStyle(SpringPressStyle())
            NavigationLink(destination: HomeDhikrDestination()) {
                CompactDhikrCard()
            }
            .buttonStyle(SpringPressStyle())
        }
        .staggerAppear(appeared, index: 3)
    }

    private var dailyReflection: some View {
        DailyReflectionCard(
            arabic: SampleData.dailyAyah.arabic,
            translation: SampleData.dailyAyah.translation,
            reference: SampleData.dailyAyah.reference,
            tafsir: SampleData.dailyAyah.tafsir
        )
        .staggerAppear(appeared, index: 4)
    }
}

// MARK: - Dhikr Destination Wrapper
struct HomeDhikrDestination: View {
    @StateObject private var store = SalahStore()
    var body: some View {
        DhikrCounterView()
            .environmentObject(store)
    }
}
