import SwiftUI

// MARK: - Reusable Sheet Dismiss Button (Apple-standard xmark.circle.fill)
struct SheetCloseButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close")
    }
}

/// Convenience ViewModifier that injects the close button into .topBarTrailing
struct SheetDismissModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                SheetCloseButton { dismiss() }
            }
        }
    }
}

extension View {
    func sheetDismissButton() -> some View {
        modifier(SheetDismissModifier())
    }
}

struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    @Environment(\.colorScheme) var cs
    @Environment(\.localization) var l10n
    @Namespace private var tabNS

    private let tabs: [AppTab] = [.home, .quran, .salah, .library, .more]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                TabItem(tab: tab, isSelected: selectedTab == tab, ns: tabNS, label: l10n.t(tab.labelKey)) {
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
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.alehaGreen.opacity(0.13))
                            .frame(width: 44, height: 30)
                            .matchedGeometryEffect(id: "tabPill", in: ns)
                    }
                    Image(systemName: isSelected ? tab.iconFilled : tab.icon)
                        .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Color.alehaGreen : Color.secondary.opacity(0.45))
                        .scaleEffect(isSelected ? 1.05 : 1.0)
                        .symbolEffect(.bounce, value: isSelected)
                }
                .frame(height: 30)

                Text(label)
                    .font(.system(size: 9, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? Color.alehaGreen : Color.secondary.opacity(0.45))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                // Dot indicator under active tab
                Circle()
                    .fill(isSelected ? Color.alehaGreen : Color.clear)
                    .frame(width: 4, height: 4)
                    .matchedGeometryEffect(id: "tabDot", in: ns)
                    .animation(.spring(response: 0.32, dampingFraction: 0.72), value: isSelected)
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
