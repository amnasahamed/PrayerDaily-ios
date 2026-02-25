import SwiftUI

// MorePlaceholderView and MoreMenuRow moved to Views/More/MoreView.swift
typealias MorePlaceholderView = MoreView

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
