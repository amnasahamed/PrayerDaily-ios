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

// MARK: - Floating Tab Bar

struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    @Environment(\.colorScheme) var cs
    @Environment(\.localization) var l10n
    @Namespace private var tabNS

    private let tabs: [AppTab] = [.home, .quran, .salah, .library, .more]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                TabItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    ns: tabNS,
                    label: l10n.t(tab.labelKey)
                ) {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .modifier(TabBarGlassModifier(cs: cs))
        // Block all touches on the visible bar surface — prevents bleed-through
        // in the padding areas between tab buttons and the bar edges.
        .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.horizontal, 20)
        .padding(.bottom, 18)
    }
}

// MARK: - Glass / Legacy background modifier

private struct TabBarGlassModifier: ViewModifier {
    let cs: ColorScheme

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            // Native Liquid Glass — adapts to content behind the bar
            content
                .glassEffect(in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        } else {
            // Material fallback for iOS 17–25
            content
                .background(legacyBackground)
                .shadow(color: .black.opacity(cs == .dark ? 0.45 : 0.10), radius: 20, y: 5)
        }
    }

    @ViewBuilder
    private var legacyBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(cs == .dark ? Color(white: 0.11).opacity(0.96) : Color.white.opacity(0.94))
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(
                        cs == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05),
                        lineWidth: 0.5
                    )
            )
    }
}

// MARK: - Tab Item

private struct TabItem: View {
    let tab: AppTab
    let isSelected: Bool
    var ns: Namespace.ID
    let label: String
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: isSelected ? tab.iconFilled : tab.icon)
                    .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(
                        isSelected ? Color.alehaGreen : Color.secondary.opacity(0.45)
                    )
                    .scaleEffect(isSelected ? 1.05 : 1.0)
                    .modifier(TabBounceModifier(isSelected: isSelected, reduceMotion: reduceMotion))
                    .frame(height: 30)

                Text(label)
                    .font(.system(size: 9, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? Color.alehaGreen : Color.secondary.opacity(0.45))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Circle()
                    .fill(isSelected ? Color.alehaGreen : Color.clear)
                    .frame(width: 4, height: 4)
                    .animation(.spring(response: 0.32, dampingFraction: 0.72), value: isSelected)
            }
            .frame(maxWidth: .infinity)
            .background {
                if isSelected {
                    pillBackground
                        .padding(.horizontal, 4)
                        .matchedGeometryEffect(id: "tabPill", in: ns)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(BouncePressStyle())
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    // Active pill: Liquid Glass (iOS 26+) or tinted fill (iOS 17–25)
    @ViewBuilder
    private var pillBackground: some View {
        if #available(iOS 26.0, *) {
            Color.clear
                .glassEffect(in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .tint(Color.alehaGreen)
        } else {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.alehaGreen.opacity(0.13))
        }
    }
}

// MARK: - Bounce effect gated behind reduce-motion

private struct TabBounceModifier: ViewModifier {
    let isSelected: Bool
    let reduceMotion: Bool
    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.symbolEffect(.bounce, value: isSelected)
        }
    }
}

// MARK: - AppTab icon extensions

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
