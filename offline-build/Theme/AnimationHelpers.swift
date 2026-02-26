import SwiftUI

// MARK: - Fluid Page Transition
struct SlideUpTransition: ViewModifier {
    let appeared: Bool
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 24)
            .blur(radius: appeared ? 0 : 2)
            .animation(
                .spring(response: 0.52, dampingFraction: 0.82).delay(delay),
                value: appeared
            )
    }
}

struct FadeScaleTransition: ViewModifier {
    let appeared: Bool
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.94)
            .animation(
                .spring(response: 0.45, dampingFraction: 0.78).delay(delay),
                value: appeared
            )
    }
}

extension View {
    func slideUp(_ appeared: Bool, delay: Double = 0) -> some View {
        modifier(SlideUpTransition(appeared: appeared, delay: delay))
    }
    func fadeScale(_ appeared: Bool, delay: Double = 0) -> some View {
        modifier(FadeScaleTransition(appeared: appeared, delay: delay))
    }
}

// MARK: - Animated Counter
struct AnimatedNumber: View {
    let value: Int
    let font: Font
    let color: Color

    var body: some View {
        Text("\(value)")
            .font(font)
            .foregroundStyle(color)
            .contentTransition(.numericText(countsDown: false))
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: value)
    }
}

// MARK: - Ripple Button Style
struct RippleButtonStyle: ButtonStyle {
    var color: Color = Color.alehaGreen
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .brightness(configuration.isPressed ? -0.03 : 0)
            .animation(.spring(response: 0.22, dampingFraction: 0.60), value: configuration.isPressed)
    }
}

// MARK: - Section Appear Helper
struct SectionAppear: ViewModifier {
    @State private var appeared = false
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.55, dampingFraction: 0.83).delay(delay), value: appeared)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    appeared = true
                }
            }
    }
}

extension View {
    func sectionAppear(delay: Double = 0) -> some View {
        modifier(SectionAppear(delay: delay))
    }
}

// MARK: - Confetti Burst
struct ConfettiBurst: View {
    @Binding var trigger: Bool
    private let colors: [Color] = [.alehaGreen, .alehaAmber, .alehaSaffron, .blue.opacity(0.7), .pink.opacity(0.7)]
    @State private var particles: [ConfettiParticle] = []

    struct ConfettiParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var color: Color
        var rotation: Double
        var scale: CGFloat
        var opacity: Double
        var velocityX: CGFloat
        var velocityY: CGFloat
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { p in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(p.color)
                        .frame(width: 8, height: 8)
                        .scaleEffect(p.scale)
                        .rotationEffect(.degrees(p.rotation))
                        .opacity(p.opacity)
                        .position(x: p.x, y: p.y)
                }
            }
            .onChange(of: trigger) { _, val in
                guard val else { return }
                let cx = geo.size.width / 2
                particles = (0..<42).map { _ in
                    ConfettiParticle(
                        x: cx + CGFloat.random(in: -40...40),
                        y: geo.size.height * 0.4,
                        color: colors.randomElement()!,
                        rotation: Double.random(in: 0...360),
                        scale: CGFloat.random(in: 0.6...1.4),
                        opacity: 1,
                        velocityX: CGFloat.random(in: -140...140),
                        velocityY: CGFloat.random(in: -260 ... -80)
                    )
                }
                withAnimation(.easeOut(duration: 1.1)) {
                    for i in particles.indices {
                        particles[i].x += particles[i].velocityX
                        particles[i].y += particles[i].velocityY + 180
                        particles[i].opacity = 0
                        particles[i].rotation += Double.random(in: 180...540)
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    particles = []
                    trigger = false
                }
            }
        }
        .allowsHitTesting(false)
    }
}


