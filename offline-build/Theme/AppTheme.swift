import SwiftUI

// MARK: - Color Palette
extension Color {
    // Primary emerald green — spiritual, Islamic heritage
    static let noorPrimary = Color("NoorPrimary")
    static let noorSecondary = Color("NoorSecondary")
    static let noorAccent = Color("NoorAccent")
    static let noorGold = Color("NoorGold")
    static let noorSurface = Color("NoorSurface")
    static let noorCardBg = Color("NoorCardBg")

    // Fallback programmatic colors
    static let noorPrimaryFallback = Color(red: 0.10, green: 0.55, blue: 0.42)
    static let noorSecondaryFallback = Color(red: 0.08, green: 0.36, blue: 0.30)
    static let noorGoldFallback = Color(red: 0.85, green: 0.68, blue: 0.32)
}

// MARK: - App Theme
struct AppTheme {
    static let cornerRadius: CGFloat = 16
    static let smallRadius: CGFloat = 10
    static let cardPadding: CGFloat = 16
    static let screenPadding: CGFloat = 20
}

// MARK: - Card Modifier
struct NoorCardStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.cardPadding)
            .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06), radius: 8, y: 4)
    }
}

extension View {
    func noorCard() -> some View {
        modifier(NoorCardStyle())
    }
}
