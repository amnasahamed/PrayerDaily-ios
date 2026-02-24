import SwiftUI

struct HomeView: View {
    @State private var todayPrayers = SampleData.todayPrayers()
    @State private var appeared = false
    @State private var heroScale: CGFloat = 0.96

    var body: some View {
        NavigationStack {
            ZStack {
                CalmingBackground()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
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
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .principal) { navLogo } }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.1)) {
                    appeared = true
                    heroScale = 1.0
                }
            }
        }
    }

    // MARK: - Nav Logo
    private var navLogo: some View {
        HStack(spacing: 6) {
            AlehaLogoMark(size: 22)
            Text("aleha")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.alehaGreen)
        }
    }

    // MARK: - Hero
    private var heroSection: some View {
        HeroCard(appeared: appeared)
            .scaleEffect(heroScale)
            .opacity(appeared ? 1 : 0)
    }

    // MARK: - Prayer Tracker
    private var prayerTrackerSection: some View {
        PrayerTrackerCard(prayers: $todayPrayers)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15), value: appeared)
    }

    // MARK: - Prayer Times
    private var prayerTimesSection: some View {
        PrayerTimesCard()
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.22), value: appeared)
    }

    // MARK: - Daily Reflection
    private var dailyReflection: some View {
        DailyReflectionCard(
            arabic: SampleData.dailyAyah.arabic,
            translation: SampleData.dailyAyah.translation,
            reference: SampleData.dailyAyah.reference,
            tafsir: SampleData.dailyAyah.tafsir
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.28), value: appeared)
    }

    // MARK: - Streak & Progress
    private var streakAndProgress: some View {
        HStack(spacing: 14) {
            CompactStreakView()
            ReadingProgressCard()
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.34), value: appeared)
    }

    // MARK: - Quick Access
    private var quickAccessGrid: some View {
        QuickAccessSection()
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: appeared)
    }

    // MARK: - Hadith
    private var hadithSection: some View {
        HadithCard(hadith: SampleData.hadiths[0])
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.46), value: appeared)
    }
}

// MARK: - Hero Card
struct HeroCard: View {
    let appeared: Bool
    @Environment(\.colorScheme) var cs
    @State private var pulseScale: CGFloat = 1.0
    @State private var textOpacity = 0.0

    private var greetingText: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "Good Morning" }
        if h < 17 { return "Good Afternoon" }
        return "Good Evening"
    }
    private var greetingEmoji: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return "☀️" }
        if h < 17 { return "🌤" }
        return "🌙"
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            heroBackground
            heroContent
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.alehaGreen.opacity(0.25), radius: 24, y: 10)
        .onAppear {
            withAnimation(.easeIn(duration: 0.5).delay(0.4)) { textOpacity = 1 }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.08
            }
        }
    }

    private var heroBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.alehaDeepTeal,
                    Color.alehaDarkGreen,
                    Color(red: 0.10, green: 0.38, blue: 0.22)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            IslamicPatternOverlay(opacity: 0.04)
            orbOverlay
        }
        .frame(height: 200)
    }

    private var orbOverlay: some View {
        ZStack {
            Circle()
                .fill(Color.alehaGreen.opacity(0.25))
                .frame(width: 220, height: 220)
                .blur(radius: 60)
                .offset(x: 100, y: -40)
                .scaleEffect(pulseScale)
            Circle()
                .fill(Color.alehaAmber.opacity(0.12))
                .frame(width: 140, height: 140)
                .blur(radius: 40)
                .offset(x: 140, y: 50)
        }
    }

    private var heroContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(greetingText) \(greetingEmoji)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.75))
                    Text("السلام عليكم")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                }
                Spacer()
                crescentOrb
            }
            hijriDateLabel
        }
        .padding(22)
        .opacity(textOpacity)
    }

    @ViewBuilder
    private var hijriDateLabel: some View {
        let today = Date()
        let formatter = DateFormatter()
        let _ = { formatter.dateStyle = .full }()
        Text(formatter.string(from: today))
            .font(.system(size: 11, weight: .regular))
            .foregroundStyle(.white.opacity(0.45))
    }

    private var crescentOrb: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 64, height: 64)
            CrescentShape()
                .fill(Color.alehaAmber.opacity(0.90))
                .frame(width: 32, height: 32)
        }
        .scaleEffect(pulseScale * 0.97)
    }
}

// MARK: - Compact Streak View
struct CompactStreakView: View {
    @Environment(\.colorScheme) var cs
    @State private var animValue: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(Color.alehaAmber)
                    .font(.subheadline)
                Text("Streak")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text("14")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Color.alehaAmber)
                .contentTransition(.numericText())
            Text("days")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(cs == .dark ? Color.white.opacity(0.07) : Color.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous).stroke(cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.6), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.05), radius: 14, y: 5)
    }
}

// MARK: - Crescent Shape (shared)
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
                .frame(width: size * 1.4, height: size * 1.4)
            CrescentShape()
                .fill(Color.alehaGreen)
                .frame(width: size, height: size)
        }
    }
}
