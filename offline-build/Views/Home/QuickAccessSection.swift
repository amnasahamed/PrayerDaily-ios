import SwiftUI

struct QuickAccessSection: View {
    private let items: [(icon: String, title: String, color: Color)] = [
        ("book.fill",           "Quran",     Color.alehaGreen),
        ("hands.sparkles.fill", "Duas",      Color.alehaAmber),
        ("rosette",             "Dhikr",     Color(red: 0.55, green: 0.30, blue: 0.85)),
        ("text.book.closed.fill","Hadith",   Color.alehaDarkGreen),
        ("graduationcap.fill",  "Kids",      Color(red: 0.95, green: 0.55, blue: 0.20)),
        ("cross.case.fill",     "Emergency", Color(red: 0.85, green: 0.28, blue: 0.28))
    ]
    @State private var pressedIndex: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(items.indices, id: \.self) { i in
                    QuickTile(
                        icon:  items[i].icon,
                        title: items[i].title,
                        color: items[i].color,
                        index: i,
                        pressedIndex: $pressedIndex
                    )
                }
            }
        }
    }

    private var sectionLabel: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.alehaGreen)
                .frame(width: 4, height: 18)
            Text("Quick Access")
                .font(.headline.weight(.semibold))
        }
    }
}

struct QuickTile: View {
    let icon: String
    let title: String
    let color: Color
    let index: Int
    @Binding var pressedIndex: Int?
    @Environment(\.colorScheme) var cs

    private var isPressed: Bool { pressedIndex == index }

    var body: some View {
        Button {
            let gen = UIImpactFeedbackGenerator(style: .light)
            gen.impactOccurred()
            pressedIndex = index
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if pressedIndex == index { pressedIndex = nil }
            }
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.13))
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(color)
                }
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.smallRadius, style: .continuous)
                    .fill(cs == .dark ? Color.white.opacity(0.07) : Color.white.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.smallRadius, style: .continuous)
                            .stroke(cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.6), lineWidth: 0.5)
                    )
            )
            .shadow(color: color.opacity(isPressed ? 0.25 : 0.0), radius: 14, y: 4)
            .scaleEffect(isPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
    }
}
