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
                prayerTrackerSection
                prayerTimesSection
                dailyReflection
                streakAndProgress
                quickAccessGrid
                hadithSection
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

    private var prayerTrackerSection: some View {
        PrayerTrackerCard(prayers: $todayPrayers)
            .staggerAppear(appeared, index: 1)
    }

    private var prayerTimesSection: some View {
        PrayerTimesCard()
            .staggerAppear(appeared, index: 2)
    }

    private var dailyReflection: some View {
        DailyReflectionCard(
            arabic: SampleData.dailyAyah.arabic,
            translation: SampleData.dailyAyah.translation,
            reference: SampleData.dailyAyah.reference,
            tafsir: SampleData.dailyAyah.tafsir
        )
        .staggerAppear(appeared, index: 3)
    }

    private var streakAndProgress: some View {
        HStack(spacing: 12) {
            CompactStreakView()
            ReadingProgressCard()
        }
        .staggerAppear(appeared, index: 4)
    }

    private var quickAccessGrid: some View {
        QuickAccessSection()
            .staggerAppear(appeared, index: 5)
    }

    private var hadithSection: some View {
        HadithCard(hadith: SampleData.hadiths[0])
            .staggerAppear(appeared, index: 6)
    }
}

// MARK: - Hero Card
struct HeroCard: View {
    let appeared: Bool
    @Environment(\.colorScheme) var cs
    @State private var pulseScale: CGFloat = 1.0
    @State private var textOpacity = 0.0

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            heroBackground
            heroContent
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.alehaGreen.opacity(cs == .dark ? 0.3 : 0.18), radius: 20, y: 8)
        .onAppear {
            withAnimation(.easeIn(duration: 0.5).delay(0.3)) { textOpacity = 1 }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.06
            }
        }
    }

    private var heroBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.28, blue: 0.16),
                    Color(red: 0.10, green: 0.36, blue: 0.22),
                    Color(red: 0.14, green: 0.44, blue: 0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            IslamicPatternOverlay(opacity: 0.035)
            greenOrb
            amberOrb
        }
        .frame(height: 180)
    }

    private var greenOrb: some View {
        Circle()
            .fill(Color.alehaGreen.opacity(0.20))
            .frame(width: 180, height: 180)
            .blur(radius: 50)
            .offset(x: 110, y: -30)
            .scaleEffect(pulseScale)
    }

    private var amberOrb: some View {
        Circle()
            .fill(Color.alehaAmber.opacity(0.10))
            .frame(width: 120, height: 120)
            .blur(radius: 35)
            .offset(x: 130, y: 50)
    }

    private var heroContent: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greetingText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
                Text("السلام عليكم")
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                Text(todayDateString)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
            }
            Spacer()
            crescentOrb
        }
        .padding(20)
        .opacity(textOpacity)
    }

    private var crescentOrb: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 52, height: 52)
            CrescentShape()
                .fill(Color.alehaAmber.opacity(0.85))
                .frame(width: 26, height: 26)
        }
        .scaleEffect(pulseScale * 0.98)
    }

    private var greetingText: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Good Morning ☀️" }
        if h < 17 { return "Good Afternoon 🌤" }
        return "Good Evening 🌙"
    }

    private var todayDateString: String {
        let f = DateFormatter()
        f.dateStyle = .full
        return f.string(from: Date())
    }
}

// MARK: - Compact Streak View
struct CompactStreakView: View {
    @Environment(\.colorScheme) var cs
    @State private var countAnim: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(Color.alehaAmber)
                    .font(.system(size: 13))
                Text("Streak")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("14")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.alehaAmber)
                    .contentTransition(.numericText())
                Text("days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .offset(y: -2)
            }
            weekDots
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(cs == .dark ? Color.white.opacity(0.07) : Color.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
            .stroke(cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.6), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
    }

    private var weekDots: some View {
        HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { day in
                Circle()
                    .fill(day < 5 ? Color.alehaAmber : Color(.systemGray4))
                    .frame(width: 6, height: 6)
            }
        }
    }
}

// MARK: - Crescent Shape
struct CrescentShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        path.addArc(center: center, radius: r, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        let innerCenter = CGPoint(x: center.x + r * 0.35, y: center.y - r * 0.1)
        path.addArc(center: innerCenter, radius: r * 0.75, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
        return path
    }
}

// MARK: - Aleha Logo Mark
struct AlehaLogoMark: View {
    let size: CGFloat
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.alehaGreen.opacity(0.15))
                .frame(width: size * 1.3, height: size * 1.3)
            CrescentShape()
                .fill(Color.alehaGreen)
                .frame(width: size, height: size)
        }
    }
}
