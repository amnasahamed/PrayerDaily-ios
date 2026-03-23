import SwiftUI

struct QuickAccessSection: View {
    private struct TileItem {
        let icon: String
        let titleKey: LocalizedKey
        let color: Color
        let tab: AppTab?
    }

    private let items: [TileItem] = [
        TileItem(icon: "book.fill",            titleKey: .quranTitle,     color: Color.alehaGreen,                              tab: .quran),
        TileItem(icon: "hands.sparkles.fill",  titleKey: .libraryDuas,    color: Color.alehaAmber,                              tab: .library),
        TileItem(icon: "rosette",              titleKey: .dhikrTitle,     color: Color(red: 0.55, green: 0.30, blue: 0.85),     tab: .salah),
        TileItem(icon: "text.book.closed.fill",titleKey: .hadithTitle,    color: Color.alehaDarkGreen,                          tab: .library),
        TileItem(icon: "graduationcap.fill",   titleKey: .homeKids,       color: Color(red: 0.95, green: 0.55, blue: 0.20),     tab: nil),
        TileItem(icon: "cross.case.fill",      titleKey: .emergencyTitle, color: Color(red: 0.85, green: 0.28, blue: 0.28),     tab: .library),
    ]
    @State private var pressedIndex: Int? = nil
    @State private var showKidsComing = false
    @EnvironmentObject var localization: LocalizationManager

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
                        title: localization.t(items[i].titleKey),
                        color: items[i].color,
                        index: i,
                        pressedIndex: $pressedIndex,
                        onTap: {
                            if let tab = items[i].tab {
                                NotificationCenter.default.post(name: .didTapQuickAccess, object: tab)
                            } else {
                                showKidsComing = true
                            }
                        }
                    )
                }
            }
        }
        .sheet(isPresented: $showKidsComing) {
            VStack(spacing: 20) {
                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color(red: 0.95, green: 0.55, blue: 0.20))
                Text(localization.t(.homeKidsSection))
                    .font(.title2.weight(.bold))
                Text(localization.t(.homeComingSoon))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(localization.t(.homeKidsDescription))
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .padding(40)
            .presentationDetents([.medium])
        }
    }

    private var sectionLabel: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.alehaGreen)
                .frame(width: 4, height: 18)
            Text(localization.t(.homeQuickAccess))
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
    var onTap: (() -> Void)? = nil
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
            onTap?()
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
