import SwiftUI

struct QuickAccessSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick Access")
                .font(.headline.weight(.semibold))
            LazyVGrid(columns: gridColumns, spacing: 14) {
                QuickTile(icon: "book.fill", title: "Quran", color: Color.alehaGreen)
                QuickTile(icon: "hands.sparkles.fill", title: "Duas", color: Color.alehaAmber)
                QuickTile(icon: "rosette", title: "Dhikr", color: Color.noorGold)
                QuickTile(icon: "text.book.closed.fill", title: "Hadith", color: Color.alehaDarkGreen)
                QuickTile(icon: "graduationcap.fill", title: "Kids", color: .orange)
                QuickTile(icon: "cross.case.fill", title: "Emergency", color: Color(red: 0.85, green: 0.30, blue: 0.30))
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
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
        .background(scheme == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.smallRadius, style: .continuous)
                .stroke(scheme == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.5), lineWidth: 0.5)
        )
    }
}
