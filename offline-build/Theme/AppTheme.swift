import SwiftUI

// MARK: - Aleha Brand Colors
extension Color {
    static let noorPrimary = Color("NoorPrimary")
    static let noorSecondary = Color("NoorSecondary")
    static let noorAccent = Color("NoorAccent")
    static let noorGold = Color("NoorGold")
    static let noorSurface = Color("NoorSurface")
    static let noorCardBg = Color("NoorCardBg")
    static let alehaGreen = Color(red: 0.18, green: 0.53, blue: 0.25)
    static let alehaAmber = Color(red: 0.92, green: 0.62, blue: 0.20)
}

// MARK: - Theme Constants
struct AppTheme {
    static let cornerRadius: CGFloat = 22
    static let smallRadius: CGFloat = 14
    static let cardPadding: CGFloat = 18
    static let screenPadding: CGFloat = 20
}

// MARK: - Glass Card Modifier
struct AlehaCardStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.cardPadding)
            .background(cardFill)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.25 : 0.06), radius: 12, y: 4)
    }
    private var cardFill: some View {
        RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
            .fill(colorScheme == .dark
                  ? Color.white.opacity(0.06)
                  : Color.white.opacity(0.85))
            .background(.ultraThinMaterial)
    }
}

extension View {
    func noorCard() -> some View { modifier(AlehaCardStyle()) }
    func alehaCard() -> some View { modifier(AlehaCardStyle()) }
}

// MARK: - Calming Background
struct CalmingBackground: View {
    @Environment(\.colorScheme) var cs
    var body: some View {
        ZStack {
            baseGradient
            topOrb
            midOrb
            bottomOrb
        }
        .ignoresSafeArea()
    }

    private var baseGradient: some View {
        LinearGradient(
            colors: cs == .dark
                ? [Color(red: 0.04, green: 0.05, blue: 0.07),
                   Color(red: 0.05, green: 0.08, blue: 0.10)]
                : [Color(red: 0.96, green: 0.97, blue: 0.95),
                   Color(red: 0.93, green: 0.96, blue: 0.94),
                   Color(red: 0.95, green: 0.95, blue: 0.97)],
            startPoint: .top, endPoint: .bottom
        )
    }

    private var topOrb: some View {
        Circle()
            .fill(Color.alehaGreen.opacity(cs == .dark ? 0.05 : 0.07))
            .frame(width: 500, height: 500)
            .blur(radius: 120)
            .offset(x: -120, y: -260)
    }

    private var midOrb: some View {
        Circle()
            .fill(Color.alehaAmber.opacity(cs == .dark ? 0.03 : 0.05))
            .frame(width: 300, height: 300)
            .blur(radius: 80)
            .offset(x: 140, y: 50)
    }

    private var bottomOrb: some View {
        Circle()
            .fill(Color.alehaGreen.opacity(cs == .dark ? 0.03 : 0.04))
            .frame(width: 400, height: 400)
            .blur(radius: 100)
            .offset(x: -60, y: 400)
    }
}

// MARK: - Inline Toolbar Style
struct AlehaNavStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Geometric Islamic Pattern
struct IslamicPatternOverlay: View {
    let opacity: Double
    var body: some View {
        GeometryReader { geo in
            let size: CGFloat = 40
            let cols = Int(geo.size.width / size) + 1
            let rows = Int(geo.size.height / size) + 1
            Canvas { context, canvasSize in
                for row in 0..<rows {
                    for col in 0..<cols {
                        let x = CGFloat(col) * size + (row.isMultiple(of: 2) ? size / 2 : 0)
                        let y = CGFloat(row) * size
                        let path = starPath(center: CGPoint(x: x, y: y), radius: 6)
                        context.stroke(path, with: .color(.white.opacity(opacity)), lineWidth: 0.5)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func starPath(center: CGPoint, radius: CGFloat) -> Path {
        var path = Path()
        for i in 0..<8 {
            let angle = Double(i) * .pi / 4
            let r: CGFloat = i.isMultiple(of: 2) ? radius : radius * 0.4
            let pt = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }
}
