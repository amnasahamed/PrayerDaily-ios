import SwiftUI

struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    @Environment(\.colorScheme) var cs
    @Namespace private var tabNS

    private let tabs: [AppTab] = [.home, .quran, .salah, .library, .more]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                TabItem(tab: tab, isSelected: selectedTab == tab, ns: tabNS) {
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(tabBackground)
        .shadow(color: .black.opacity(cs == .dark ? 0.5 : 0.12), radius: 20, y: 5)
        .padding(.horizontal, 20)
        .padding(.bottom, 18)
    }

    private var tabBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(cs == .dark ? Color(white: 0.11).opacity(0.96) : Color.white.opacity(0.94))
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(cs == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05), lineWidth: 0.5)
            )
    }
}

private struct TabItem: View {
    let tab: AppTab
    let isSelected: Bool
    var ns: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(Color.alehaGreen.opacity(0.14))
                            .frame(width: 40, height: 26)
                            .matchedGeometryEffect(id: "tabPill", in: ns)
                    }
                    Image(systemName: isSelected ? tab.iconFilled : tab.icon)
                        .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Color.alehaGreen : Color.secondary.opacity(0.6))
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                        .symbolEffect(.bounce, value: isSelected)
                }
                .frame(height: 28)

                Text(tab.rawValue)
                    .font(.system(size: 9, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? Color.alehaGreen : Color.secondary.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(BouncePressStyle())
    }
}

extension AppTab {
    var iconFilled: String {
        switch self {
        case .home:    return "moon.stars.fill"
        case .quran:   return "book.fill"
        case .salah:   return "clock.fill"
        case .library: return "books.vertical.fill"
        case .more:    return "ellipsis.circle.fill"
        }
    }
}
