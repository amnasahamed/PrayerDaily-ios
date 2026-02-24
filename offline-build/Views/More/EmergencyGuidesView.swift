import SwiftUI

// MARK: - Guide List
struct EmergencyGuidesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(EmergencyGuideData.allGuides) { guide in
                    NavigationLink(destination: GuideDetailView(guide: guide)) {
                        GuideCard(guide: guide)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppTheme.screenPadding)
        }
        .background(Color("NoorSurface").ignoresSafeArea())
        .navigationTitle("Emergency Guides")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GuideCard: View {
    let guide: EmergencyGuide
    @Environment(\.colorScheme) var cs
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: guide.icon)
                .font(.title2)
                .foregroundStyle(Color(guide.color))
                .frame(width: 50, height: 50)
                .background(Color(guide.color).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 3) {
                Text(guide.title).font(.headline)
                Text(guide.subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(cs == .dark ? Color(.systemGray6) : .white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .shadow(color: .black.opacity(cs == .dark ? 0.3 : 0.05), radius: 6, y: 3)
    }
}

// MARK: - Guide Detail
struct GuideDetailView: View {
    let guide: EmergencyGuide
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerBanner
                ForEach(guide.sections) { section in
                    SectionBlock(section: section, color: guide.color)
                }
            }
            .padding(AppTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(Color("NoorSurface").ignoresSafeArea())
        .navigationTitle(guide.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: guide.icon).font(.largeTitle).foregroundStyle(Color(guide.color))
                Text(guide.title).font(.title2.weight(.bold))
                Text(guide.subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(20)
        .background(Color(guide.color).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}

struct SectionBlock: View {
    let section: GuideSection
    let color: String
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(section.heading)
                .font(.headline)
                .foregroundStyle(Color(color))
            ForEach(section.steps) { step in
                StepRow(step: step, color: color)
            }
        }
    }
}

struct StepRow: View {
    let step: GuideStep
    let color: String
    @Environment(\.colorScheme) var cs
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 10) {
                Text("\(step.number)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(Color(color))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(step.title).font(.subheadline.weight(.semibold))
                    Text(step.detail).font(.caption).foregroundStyle(.secondary).lineSpacing(3)
                }
            }
            if let arabic = step.arabic {
                Text(arabic)
                    .font(.system(size: 20))
                    .foregroundStyle(Color(color))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(12)
                    .background(Color(color).opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(14)
        .background(cs == .dark ? Color(.systemGray6) : .white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
