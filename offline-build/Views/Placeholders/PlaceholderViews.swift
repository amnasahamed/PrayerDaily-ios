import SwiftUI

// MARK: - More Screen (Grouped List Style)
struct MorePlaceholderView: View {
    @Environment(\.colorScheme) var cs
    var body: some View {
        NavigationStack {
            ZStack {
                CalmingBackground()
                ScrollView {
                    VStack(spacing: 2) {
                        groupedSection
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("More")
            .modifier(AlehaNavStyle())
        }
    }

    private var groupedSection: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: EmergencyGuidesView()) {
                MoreMenuRow(icon: "cross.case.fill", title: "Emergency Guides", subtitle: "Janazah, Ruqyah, Nikah & Travel", color: Color.alehaAmber, showDivider: true)
            }
            .buttonStyle(.plain)

            MoreMenuRow(icon: "person.crop.circle.fill", title: "Profile", subtitle: "Your settings & preferences", color: Color.alehaGreen, showDivider: true)
            MoreMenuRow(icon: "moon.stars.fill", title: "Appearance", subtitle: "Theme & display options", color: Color.alehaDarkGreen, showDivider: true)

            let cacheCount = OfflineCacheService.shared.cachedSurahCount()
            let cacheSize = OfflineCacheService.shared.cacheSizeString()
            MoreMenuRow(icon: "arrow.down.circle.fill", title: "Offline Content", subtitle: "\(cacheCount) surahs saved (\(cacheSize))", color: Color.alehaAmber, showDivider: true)

            MoreMenuRow(icon: "info.circle.fill", title: "About Aleha", subtitle: "Version 1.0", color: Color.alehaGreen, showDivider: false)
        }
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(cs == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.85))
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.6), lineWidth: 0.5)
        )
    }
}

struct MoreMenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var showDivider: Bool = false
    @Environment(\.colorScheme) var cs

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(color.opacity(0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.weight(.medium))
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)

            if showDivider {
                Divider().padding(.leading, 68)
            }
        }
    }
}

// MARK: - Shared Placeholder
struct PlaceholderContent: View {
    let icon: String; let title: String; let subtitle: String; let features: [String]
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                iconHeader; descriptionSection; featureList; comingSoonBadge
            }
            .padding(AppTheme.screenPadding)
        }
        .background(CalmingBackground())
    }
    private var iconHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 50)).foregroundStyle(Color.alehaGreen)
                .padding(24).background(Color.alehaGreen.opacity(0.1)).clipShape(Circle())
            Text(title).font(.title2.weight(.bold))
        }.padding(.top, 20)
    }
    private var descriptionSection: some View {
        Text(subtitle).font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal)
    }
    private var featureList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Planned Features").font(.subheadline.weight(.semibold))
            ForEach(features, id: \.self) { f in
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.alehaGreen)
                    Text(f).font(.subheadline)
                }
            }
        }.frame(maxWidth: .infinity, alignment: .leading).noorCard()
    }
    private var comingSoonBadge: some View {
        Text("Coming Soon").font(.caption.weight(.semibold)).foregroundStyle(Color.alehaAmber)
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(Color.alehaAmber.opacity(0.12)).clipShape(Capsule())
    }
}
