import SwiftUI

// MARK: - More
struct MorePlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                CalmingBackground()
                ScrollView {
                    VStack(spacing: 14) {
                        NavigationLink(destination: EmergencyGuidesView()) {
                            MoreMenuRow(icon: "cross.case.fill", title: "Emergency Guides", subtitle: "Janazah, Ruqyah, Nikah & Travel Duas", color: Color.alehaAmber)
                        }
                        .buttonStyle(.plain)
                        MoreMenuRow(icon: "person.crop.circle.fill", title: "Profile", subtitle: "Your settings & preferences", color: Color.alehaGreen)
                        MoreMenuRow(icon: "moon.stars.fill", title: "Night Mode", subtitle: "Dark theme for late reading", color: Color.alehaDarkGreen)
                        MoreMenuRow(icon: "arrow.down.circle.fill", title: "Offline Cache", subtitle: "\(OfflineCacheService.shared.cachedSurahCount()) surahs cached (\(OfflineCacheService.shared.cacheSizeString()))", color: Color.alehaAmber)
                    }
                    .padding(AppTheme.screenPadding)
                }
            }
            .navigationTitle("More")
            .modifier(AlehaNavStyle())
        }
    }
}

struct MoreMenuRow: View {
    let icon: String; let title: String; let subtitle: String; let color: Color
    @Environment(\.colorScheme) var cs
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 46, height: 46)
                Image(systemName: icon)
                    .font(.title3).foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(cs == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(cs == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.5), lineWidth: 0.5)
        )
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
