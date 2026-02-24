import SwiftUI

// MARK: - Library
struct LibraryPlaceholderView: View {
    var body: some View {
        NavigationStack {
            PlaceholderContent(
                icon: "books.vertical.fill",
                title: "Islamic Knowledge Vault",
                subtitle: "Your pocket Islamic library. Hadith collections, Seerah, Prophet stories, duas, and more.",
                features: ["40 Hadith collection", "Sahih Hadith selections", "Seerah timeline", "Stories of 25 Prophets", "Dua by situation", "Islamic quotes database"]
            )
            .navigationTitle("Library")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("NoorPrimary"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - More
struct MorePlaceholderView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    NavigationLink(destination: EmergencyGuidesView()) {
                        MoreMenuRow(icon: "cross.case.fill", title: "Emergency Guides", subtitle: "Janazah, Ruqyah, Nikah & Travel Duas", color: "NoorAccent")
                    }
                    .buttonStyle(.plain)

                    MoreMenuRow(icon: "person.crop.circle.fill", title: "Profile", subtitle: "Your settings & preferences", color: "NoorPrimary")
                    MoreMenuRow(icon: "moon.stars.fill", title: "Night Mode", subtitle: "Dark theme for late reading", color: "NoorSecondary")
                    MoreMenuRow(icon: "arrow.down.circle.fill", title: "Offline Cache", subtitle: "\(OfflineCacheService.shared.cachedSurahCount()) surahs cached (\(OfflineCacheService.shared.cacheSizeString()))", color: "NoorGold")
                }
                .padding(AppTheme.screenPadding)
            }
            .background(Color("NoorSurface").ignoresSafeArea())
            .navigationTitle("More")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("NoorPrimary"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct MoreMenuRow: View {
    let icon: String; let title: String; let subtitle: String; let color: String
    @Environment(\.colorScheme) var cs
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3).foregroundStyle(Color(color))
                .frame(width: 44, height: 44)
                .background(Color(color).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(cs == .dark ? Color(.systemGray6) : .white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .shadow(color: .black.opacity(cs == .dark ? 0.3 : 0.05), radius: 6, y: 3)
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
        .background(Color("NoorSurface").ignoresSafeArea())
    }
    private var iconHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 50)).foregroundStyle(Color("NoorPrimary"))
                .padding(24).background(Color("NoorPrimary").opacity(0.1)).clipShape(Circle())
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
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color("NoorPrimary"))
                    Text(f).font(.subheadline)
                }
            }
        }.frame(maxWidth: .infinity, alignment: .leading).noorCard()
    }
    private var comingSoonBadge: some View {
        Text("Coming Soon").font(.caption.weight(.semibold)).foregroundStyle(Color("NoorGold"))
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(Color("NoorGold").opacity(0.12)).clipShape(Capsule())
    }
}
