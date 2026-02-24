import SwiftUI

// MARK: - Color Palette (Aleha brand: green + gold crescent)
extension Color {
    static let noorPrimary = Color("NoorPrimary")
    static let noorSecondary = Color("NoorSecondary")
    static let noorAccent = Color("NoorAccent")
    static let noorGold = Color("NoorGold")
    static let noorSurface = Color("NoorSurface")
    static let noorCardBg = Color("NoorCardBg")
}

// MARK: - App Theme
struct AppTheme {
    static let cornerRadius: CGFloat = 20
    static let smallRadius: CGFloat = 14
    static let cardPadding: CGFloat = 18
    static let screenPadding: CGFloat = 20
}

// MARK: - Glass Card
struct AlehaCardStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.cardPadding)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.3), lineWidth: 0.5)
            )
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
            bgGradient
            topOrb
            bottomOrb
        }
        .ignoresSafeArea()
    }

    private var bgGradient: some View {
        LinearGradient(
            colors: cs == .dark
                ? [Color(red: 0.04, green: 0.06, blue: 0.08), Color(red: 0.06, green: 0.10, blue: 0.12)]
                : [Color(red: 0.95, green: 0.97, blue: 0.94), Color(red: 0.92, green: 0.96, blue: 0.93)],
            startPoint: .top, endPoint: .bottom
        )
    }

    private var topOrb: some View {
        Circle()
            .fill(Color("NoorPrimary").opacity(cs == .dark ? 0.06 : 0.08))
            .frame(width: 400, height: 400)
            .blur(radius: 100)
            .offset(x: -80, y: -200)
    }

    private var bottomOrb: some View {
        Circle()
            .fill(Color("NoorGold").opacity(cs == .dark ? 0.04 : 0.06))
            .frame(width: 350, height: 350)
            .blur(radius: 90)
            .offset(x: 100, y: 300)
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
