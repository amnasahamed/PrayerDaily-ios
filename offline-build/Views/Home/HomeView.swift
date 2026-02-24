import SwiftUI

struct HomeView: View {
    @State private var todayPrayers = SampleData.todayPrayers()
    @State private var showGreeting = false

    var body: some View {
        NavigationStack {
            ZStack {
                CalmingBackground()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 22) {
                        heroSection
                        prayerTimesSection
                        dailyReflection
                        readingProgressSection
                        prayerTracker
                        quickAccessGrid
                        hadithOfDay
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.bottom, 40)
                    .padding(.top, 4)
                }
            }
            .navigationTitle("Aleha")
            .modifier(AlehaNavStyle())
            .onAppear { withAnimation(.easeOut(duration: 0.6)) { showGreeting = true } }
        }
    }

    // MARK: - Hero
    private var heroSection: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                greetingColumn
                Spacer()
                crescentMark
            }
        }
        .opacity(showGreeting ? 1 : 0)
        .offset(y: showGreeting ? 0 : 10)
    }

    private var greetingColumn: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greetingText)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            Text("السلام عليكم")
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundStyle(Color.alehaGreen.opacity(0.75))
        }
    }

    private var greetingText: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Good Morning ☀️" }
        if h < 17 { return "Good Afternoon 🌤" }
        return "Good Evening 🌙"
    }

    private var crescentMark: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(colors: [Color.alehaAmber.opacity(0.2), Color.alehaAmber.opacity(0.02)],
                                   center: .center, startRadius: 2, endRadius: 30)
                )
                .frame(width: 60, height: 60)
            CrescentShape()
                .fill(Color.alehaAmber.opacity(0.8))
                .frame(width: 28, height: 28)
        }
    }

    private var prayerTimesSection: some View { PrayerTimesCard() }

    private var dailyReflection: some View {
        DailyReflectionCard(
            arabic: SampleData.dailyAyah.arabic,
            translation: SampleData.dailyAyah.translation,
            reference: SampleData.dailyAyah.reference,
            tafsir: SampleData.dailyAyah.tafsir
        )
    }

    private var readingProgressSection: some View { ReadingProgressCard() }
    private var prayerTracker: some View { PrayerTrackerCard(prayers: $todayPrayers) }
    private var quickAccessGrid: some View { QuickAccessSection() }
    private var hadithOfDay: some View { HadithCard(hadith: SampleData.hadiths[0]) }
}

// MARK: - Crescent Shape
struct CrescentShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        path.addArc(center: center, radius: r, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        let offset = r * 0.35
        let innerCenter = CGPoint(x: center.x + offset, y: center.y - offset * 0.3)
        path.addArc(center: innerCenter, radius: r * 0.75, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
        return path
    }
}
