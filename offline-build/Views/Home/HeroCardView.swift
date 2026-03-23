import SwiftUI

// MARK: - Hero Card with Mosque Silhouette
struct HeroCard: View {
    let appeared: Bool
    @Environment(\.colorScheme) var cs
    @Environment(\.localization) var l10n
    @State private var pulseScale: CGFloat = 1.0
    @State private var textOpacity = 0.0
    @State private var parallaxOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            heroBackground
            heroContent
        }
        .frame(height: 210)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.alehaGreen.opacity(cs == .dark ? 0.3 : 0.18), radius: 20, y: 8)
        .onAppear {
            withAnimation(.easeIn(duration: 0.5).delay(0.3)) { textOpacity = 1 }
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
        }
    }

    private var heroBackground: some View {
        ZStack {
            skyGradient
            starsLayer
            IslamicPatternOverlay(opacity: 0.025)
            mosqueLayer
            greenOrb
            amberOrb
        }
    }

    private var skyGradient: some View {
        LinearGradient(
            colors: [
                cs == .dark ? Color(red: 0.05, green: 0.12, blue: 0.22) : Color(red: 0.12, green: 0.25, blue: 0.45),
                cs == .dark ? Color(red: 0.06, green: 0.22, blue: 0.16) : Color(red: 0.08, green: 0.35, blue: 0.28),
                cs == .dark ? Color(red: 0.10, green: 0.34, blue: 0.22) : Color(red: 0.10, green: 0.45, blue: 0.32),
                cs == .dark ? Color(red: 0.14, green: 0.44, blue: 0.28) : Color(red: 0.14, green: 0.55, blue: 0.38)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Stars
    private var starsLayer: some View {
        Canvas { context, size in
            let starPositions: [(CGFloat, CGFloat, CGFloat)] = [
                (0.15, 0.12, 1.5), (0.32, 0.08, 2.0), (0.55, 0.15, 1.2),
                (0.72, 0.06, 1.8), (0.88, 0.18, 1.4), (0.25, 0.25, 1.0),
                (0.65, 0.28, 1.6), (0.45, 0.05, 1.3), (0.82, 0.30, 1.1),
                (0.08, 0.20, 1.7), (0.50, 0.22, 0.9), (0.38, 0.18, 1.4)
            ]
            for (x, y, r) in starPositions {
                let point = CGPoint(x: size.width * x, y: size.height * y)
                let rect = CGRect(x: point.x - r, y: point.y - r, width: r * 2, height: r * 2)
                context.fill(Path(ellipseIn: rect), with: .color(cs == .dark ? .white.opacity(0.6) : .white.opacity(0.3)))
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Mosque Silhouette
    private var mosqueLayer: some View {
        GeometryReader { geo in
            MosqueSilhouette()
                .fill(
                    LinearGradient(
                        colors: [
                            cs == .dark ? Color(red: 0.04, green: 0.14, blue: 0.08).opacity(0.9) : Color(red: 0.08, green: 0.25, blue: 0.15).opacity(0.85),
                            cs == .dark ? Color(red: 0.03, green: 0.10, blue: 0.06) : Color(red: 0.05, green: 0.18, blue: 0.10)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: geo.size.width, height: geo.size.height * 0.48)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }

    private var greenOrb: some View {
        Circle()
            .fill(Color.alehaGreen.opacity(0.18))
            .frame(width: 160, height: 160)
            .blur(radius: 50)
            .offset(x: 100, y: -20)
            .scaleEffect(pulseScale)
    }

    private var amberOrb: some View {
        Circle()
            .fill(Color.alehaAmber.opacity(0.12))
            .frame(width: 80, height: 80)
            .blur(radius: 30)
            .offset(x: -60, y: -60)
    }

    // MARK: - Content
    private var heroContent: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                Text(greetingText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
                Text("السلام عليكم")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                Text(todayDateString)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.40))
            }
            Spacer()
            crescentMoon
        }
        .padding(20)
        .opacity(textOpacity)
    }

    private var crescentMoon: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 46, height: 46)
            CrescentShape()
                .fill(Color.alehaAmber.opacity(0.85))
                .frame(width: 22, height: 22)
        }
        .scaleEffect(pulseScale * 0.98)
    }

    private var greetingText: String {
        let h = Calendar.current.component(.hour, from: Date())
        if h < 12 { return l10n.t(.homeGreetingMorning) }
        if h < 17 { return l10n.t(.homeGreetingAfternoon) }
        return l10n.t(.homeGreetingEvening)
    }

    private static let fullDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .full
        return f
    }()

    private var todayDateString: String {
        Self.fullDateFormatter.string(from: Date())
    }
}

// MARK: - Mosque Silhouette Shape
struct MosqueSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let baseY = h

        path.move(to: CGPoint(x: 0, y: baseY))

        // Left wall
        path.addLine(to: CGPoint(x: 0, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.05, y: h * 0.50))

        // Left minaret
        path.addLine(to: CGPoint(x: w * 0.08, y: h * 0.48))
        path.addLine(to: CGPoint(x: w * 0.09, y: h * 0.12))
        // Minaret top crescent ball
        path.addLine(to: CGPoint(x: w * 0.095, y: h * 0.06))
        path.addLine(to: CGPoint(x: w * 0.10, y: h * 0.04))
        path.addLine(to: CGPoint(x: w * 0.105, y: h * 0.06))
        path.addLine(to: CGPoint(x: w * 0.11, y: h * 0.12))
        path.addLine(to: CGPoint(x: w * 0.12, y: h * 0.48))
        path.addLine(to: CGPoint(x: w * 0.15, y: h * 0.50))

        // Left section rising to dome
        path.addLine(to: CGPoint(x: w * 0.22, y: h * 0.45))
        path.addLine(to: CGPoint(x: w * 0.28, y: h * 0.38))

        // Small left dome
        addDome(to: &path, centerX: w * 0.32, topY: h * 0.28, width: w * 0.10, startY: h * 0.38)

        // Rise to center dome
        path.addLine(to: CGPoint(x: w * 0.40, y: h * 0.30))

        // Main center dome (large)
        addDome(to: &path, centerX: w * 0.50, topY: h * 0.08, width: w * 0.20, startY: h * 0.30)

        // Right side (mirror)
        path.addLine(to: CGPoint(x: w * 0.60, y: h * 0.30))

        // Small right dome
        addDome(to: &path, centerX: w * 0.68, topY: h * 0.28, width: w * 0.10, startY: h * 0.38)

        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.38))
        path.addLine(to: CGPoint(x: w * 0.78, y: h * 0.45))
        path.addLine(to: CGPoint(x: w * 0.85, y: h * 0.50))

        // Right minaret
        path.addLine(to: CGPoint(x: w * 0.88, y: h * 0.48))
        path.addLine(to: CGPoint(x: w * 0.89, y: h * 0.12))
        path.addLine(to: CGPoint(x: w * 0.895, y: h * 0.06))
        path.addLine(to: CGPoint(x: w * 0.90, y: h * 0.04))
        path.addLine(to: CGPoint(x: w * 0.905, y: h * 0.06))
        path.addLine(to: CGPoint(x: w * 0.91, y: h * 0.12))
        path.addLine(to: CGPoint(x: w * 0.92, y: h * 0.48))
        path.addLine(to: CGPoint(x: w * 0.95, y: h * 0.50))

        // Right wall
        path.addLine(to: CGPoint(x: w, y: h * 0.55))
        path.addLine(to: CGPoint(x: w, y: baseY))

        path.closeSubpath()
        return path
    }

    private func addDome(to path: inout Path, centerX: CGFloat, topY: CGFloat, width: CGFloat, startY: CGFloat) {
        let leftX = centerX - width / 2
        let rightX = centerX + width / 2
        let cp1 = CGPoint(x: leftX + width * 0.1, y: topY)
        let cp2 = CGPoint(x: rightX - width * 0.1, y: topY)
        path.addCurve(
            to: CGPoint(x: rightX, y: startY),
            control1: cp1,
            control2: cp2
        )
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

// MARK: - Compact Streak View
struct CompactStreakView: View {
    @Environment(\.colorScheme) var cs
    @EnvironmentObject var salahStore: SalahStore

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
                Text("\(salahStore.currentStreak)")
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
        let completion = salahStore.weekCompletion
        return HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { day in
                Circle()
                    .fill(day < completion.count && completion[day] > 0 ? Color.alehaAmber : Color(.systemGray4))
                    .frame(width: 6, height: 6)
            }
        }
    }
}
