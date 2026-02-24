import SwiftUI

struct QuickAccessSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Access")
                .font(.subheadline.weight(.semibold))
            LazyVGrid(columns: gridColumns, spacing: 12) {
                QuickTile(icon: "book.fill", title: "Quran", color: Color("NoorPrimary"))
                QuickTile(icon: "hands.sparkles.fill", title: "Duas", color: Color("NoorAccent"))
                QuickTile(icon: "rosette", title: "Dhikr", color: Color("NoorGold"))
                QuickTile(icon: "text.book.closed.fill", title: "Hadith", color: Color("NoorSecondary"))
                QuickTile(icon: "graduationcap.fill", title: "Kids", color: .orange)
                QuickTile(icon: "cross.case.fill", title: "Emergency", color: .red)
            }
        }
    }

    private var gridColumns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    }
}

struct QuickTile: View {
    let icon: String
    let title: String
    let color: Color
    @Environment(\.colorScheme) var scheme

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(title)
                .font(.caption.weight(.medium))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(scheme == .dark ? Color(.systemGray6) : .white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallRadius))
        .shadow(color: .black.opacity(scheme == .dark ? 0.3 : 0.05), radius: 4, y: 2)
    }
}
