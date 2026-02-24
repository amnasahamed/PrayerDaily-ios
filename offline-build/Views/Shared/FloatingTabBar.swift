import SwiftUI

struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    @Environment(\.colorScheme) var cs

    private let tabs: [AppTab] = [.home, .quran, .salah, .library, .more]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                TabItem(tab: tab, isSelected: selectedTab == tab) {
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(cs == .dark ? Color(white: 0.12).opacity(0.95) : Color.white.opacity(0.92))
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(cs == .dark ? Color.white.opacity(0.10) : Color.black.opacity(0.06), lineWidth: 0.5)
                )
        )
        .shadow(color: .black.opacity(cs == .dark ? 0.45 : 0.12), radius: 24, y: 6)
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
}

private struct TabItem: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(Color.alehaGreen.opacity(0.15))
                            .frame(width: 44, height: 28)
                            .transition(.scale.combined(with: .opacity))
                    }
                    Image(systemName: isSelected ? tab.iconFilled : tab.icon)
                        .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Color.alehaGreen : Color.secondary)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .symbolEffect(.bounce, value: isSelected)
                }
                Text(tab.rawValue)
                    .font(.system(size: 9, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? Color.alehaGreen : Color.secondary)
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
