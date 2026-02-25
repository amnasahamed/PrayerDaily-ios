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
