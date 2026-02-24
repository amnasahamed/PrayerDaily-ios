import SwiftUI
import Foundation

// MARK: - Aleha Brand Palette
extension Color {
    // Primary brand colors from logo
    static let alehaGreen = Color(red: 0.18, green: 0.55, blue: 0.30)
    static let alehaAmber = Color(red: 0.92, green: 0.65, blue: 0.22)
    static let alehaDarkGreen = Color(red: 0.10, green: 0.38, blue: 0.22)
    static let alehaLightGreen = Color(red: 0.40, green: 0.72, blue: 0.45)
    static let alehaCream = Color(red: 0.98, green: 0.97, blue: 0.94)
    static let alehaSage = Color(red: 0.88, green: 0.92, blue: 0.87)

    // Semantic aliases
    static let noorPrimary = Color("NoorPrimary")
    static let noorSecondary = Color("NoorSecondary")
    static let noorAccent = Color("NoorAccent")
    static let noorGold = Color("NoorGold")
    static let noorSurface = Color("NoorSurface")
    static let noorCardBg = Color("NoorCardBg")
}

// MARK: - Theme Constants
struct AppTheme {
    static let cornerRadius: CGFloat = 24
    static let smallRadius: CGFloat = 16
    static let cardPadding: CGFloat = 18
    static let screenPadding: CGFloat = 20
}

// MARK: - Frosted Glass Card
struct AlehaCardStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.cardPadding)
            .background(cardFill)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.04), radius: 16, y: 6)
    }
    private var cardFill: some ShapeStyle {
        colorScheme == .dark
            ? AnyShapeStyle(Color.white.opacity(0.06))
            : AnyShapeStyle(Color.white.opacity(0.75))
    }
    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.6)
    }
}

extension View {
    func noorCard() -> some View { modifier(AlehaCardStyle()) }
    func alehaCard() -> some View { modifier(AlehaCardStyle()) }
}

// MARK: - Calming Background with Soft Orbs
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
                ? [Color(red: 0.06, green: 0.07, blue: 0.08),
                   Color(red: 0.07, green: 0.09, blue: 0.10)]
                : [Color(red: 0.97, green: 0.97, blue: 0.95),
                   Color(red: 0.94, green: 0.96, blue: 0.93),
                   Color(red: 0.96, green: 0.96, blue: 0.97)],
            startPoint: .top, endPoint: .bottom
        )
    }

    private var topOrb: some View {
        Circle()
            .fill(Color.alehaGreen.opacity(cs == .dark ? 0.04 : 0.06))
            .frame(width: 500, height: 500)
            .blur(radius: 140)
            .offset(x: -100, y: -280)
    }

    private var midOrb: some View {
        Circle()
            .fill(Color.alehaAmber.opacity(cs == .dark ? 0.025 : 0.04))
            .frame(width: 350, height: 350)
            .blur(radius: 100)
            .offset(x: 150, y: 80)
    }

    private var bottomOrb: some View {
        Circle()
            .fill(Color.alehaGreen.opacity(cs == .dark ? 0.025 : 0.035))
            .frame(width: 420, height: 420)
            .blur(radius: 110)
            .offset(x: -40, y: 420)
    }
}

// MARK: - Section Background (for tabs needing it)
struct SectionBackground: View {
    @Environment(\.colorScheme) var cs
    var body: some View {
        CalmingBackground()
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
            Canvas { context, _ in
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
            let cosA = Foundation.cos(angle)
            let sinA = Foundation.sin(angle)
            let pt = CGPoint(x: center.x + r * cosA, y: center.y + r * sinA)
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }
}
