import SwiftUI
import Foundation

// MARK: - Aleha Brand Palette
extension Color {
    static let alehaGreen      = Color(red: 0.176, green: 0.710, blue: 0.400)
    static let alehaAmber      = Color(red: 0.961, green: 0.651, blue: 0.133)
    static let alehaSaffron    = Color(red: 0.96, green: 0.62, blue: 0.04)
    static let alehaDarkGreen  = Color(red: 0.063, green: 0.239, blue: 0.137)
    static let alehaLightGreen = Color(red: 0.40, green: 0.72, blue: 0.45)
    static let alehaCream      = Color(red: 0.984, green: 0.976, blue: 0.961)
    static let alehaSage       = Color(red: 0.882, green: 0.957, blue: 0.902)
    static let alehaDeepTeal   = Color(red: 0.051, green: 0.188, blue: 0.137)

    // Semantic aliases
    static let noorPrimary  = Color("NoorPrimary")
    static let noorSecondary = Color("NoorSecondary")
    static let noorAccent   = Color("NoorAccent")
    static let noorGold     = Color("NoorGold")
    static let noorSurface  = Color("NoorSurface")
    static let noorCardBg   = Color("NoorCardBg")
}

// MARK: - Theme Constants
struct AppTheme {
    static let cornerRadius: CGFloat   = 22
    static let smallRadius: CGFloat    = 14
    static let cardPadding: CGFloat    = 15      // tightened from 18
    static let screenPadding: CGFloat  = 16      // tightened from 18
    static let sectionSpacing: CGFloat = 12      // tightened vertical rhythm
}

// MARK: - Stronger Active Green (for CTAs & active states)
extension Color {
    static let alehaActiveGreen = Color(red: 0.10, green: 0.62, blue: 0.30)  // richer/deeper
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
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.06), radius: 14, y: 5)
    }
    private var cardFill: some ShapeStyle {
        colorScheme == .dark
            ? AnyShapeStyle(Color.white.opacity(0.08))
            : AnyShapeStyle(Color.white.opacity(0.92))
    }
    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.12) : Color.alehaGreen.opacity(0.08)
    }
}

// MARK: - Primary CTA Button Style
struct PrimaryCTAStyle: ButtonStyle {
    var color: Color = Color.alehaActiveGreen
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(color.opacity(configuration.isPressed ? 0.8 : 1.0))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: color.opacity(0.3), radius: configuration.isPressed ? 2 : 8, y: configuration.isPressed ? 1 : 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Checkmark Burst Animation
struct CheckmarkBurst: View {
    @Binding var show: Bool
    var color: Color = Color.alehaActiveGreen

    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.18))
                .frame(width: 60, height: 60)
                .scaleEffect(show ? 1.6 : 0.3)
                .opacity(show ? 0 : 0)
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(color)
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .onChange(of: show) { _, newVal in
            if newVal {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    scale = 1.2; opacity = 1
                }
                withAnimation(.spring(response: 0.2).delay(0.15)) { scale = 1.0 }
                withAnimation(.easeOut(duration: 0.3).delay(0.5)) { opacity = 0; scale = 0.8 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { show = false }
            }
        }
    }
}

// MARK: - Pulse Glow Effect
struct PulseGlow: ViewModifier {
    var color: Color = Color.alehaActiveGreen
    var active: Bool = true
    @State private var pulse = false

    func body(content: Content) -> some View {
        content
            .shadow(color: active ? color.opacity(pulse ? 0.55 : 0.15) : .clear, radius: pulse ? 12 : 4)
            .onAppear {
                guard active else { return }
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}

extension View {
    func pulseGlow(_ color: Color = Color.alehaActiveGreen, active: Bool = true) -> some View {
        modifier(PulseGlow(color: color, active: active))
    }
}

extension View {
    func noorCard() -> some View  { modifier(AlehaCardStyle()) }
    func alehaCard() -> some View { modifier(AlehaCardStyle()) }
}

// MARK: - Spring Press Button Style
struct SpringPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: configuration.isPressed)
    }
}

// MARK: - Bounce Press Button Style
struct BouncePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

// MARK: - Calming Layered Background
struct CalmingBackground: View {
    @Environment(\.colorScheme) var cs
    var body: some View {
        ZStack {
            baseGradient
            topOrb
            bottomOrb
        }
        .ignoresSafeArea()
    }

    private var baseGradient: some View {
        LinearGradient(
            colors: cs == .dark
                ? [Color(red: 0.04, green: 0.06, blue: 0.05),
                   Color(red: 0.05, green: 0.08, blue: 0.06)]
                : [Color(red: 0.96, green: 0.98, blue: 0.96),
                   Color(red: 0.95, green: 0.97, blue: 0.94)],
            startPoint: .top, endPoint: .bottom
        )
    }
    private var topOrb: some View {
        Circle()
            .fill(Color.alehaGreen.opacity(cs == .dark ? 0.06 : 0.07))
            .frame(width: 400, height: 400)
            .blur(radius: 120)
            .offset(x: -80, y: -240)
    }
    private var bottomOrb: some View {
        Circle()
            .fill(Color.alehaAmber.opacity(cs == .dark ? 0.03 : 0.04))
            .frame(width: 300, height: 300)
            .blur(radius: 90)
            .offset(x: 120, y: 300)
    }
}

// MARK: - Inline Toolbar Style
struct AlehaNavStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
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
            let pt = CGPoint(x: center.x + r * Foundation.cos(angle),
                             y: center.y + r * Foundation.sin(angle))
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Shimmer Modifier
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1
    let active: Bool

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if active {
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.3), .clear],
                            startPoint: UnitPoint(x: phase, y: 0.5),
                            endPoint:   UnitPoint(x: phase + 0.5, y: 0.5)
                        )
                        .onAppear {
                            withAnimation(.linear(duration: 1.3).repeatForever(autoreverses: false)) {
                                phase = 1.5
                            }
                        }
                    }
                }
            )
            .clipped()
    }
}

extension View {
    func shimmer(_ active: Bool = true) -> some View { modifier(ShimmerModifier(active: active)) }
}

// MARK: - Stagger Animation Helper
struct StaggeredAppear: ViewModifier {
    let appeared: Bool
    let index: Int
    let baseDelay: Double

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.82)
                .delay(baseDelay + Double(index) * 0.06),
                value: appeared
            )
    }
}

extension View {
    func staggerAppear(_ appeared: Bool, index: Int, baseDelay: Double = 0.1) -> some View {
        modifier(StaggeredAppear(appeared: appeared, index: index, baseDelay: baseDelay))
    }
}
