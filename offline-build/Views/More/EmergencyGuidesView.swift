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
    @State private var isMalayalam = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerBanner
                ForEach(guide.sections) { section in
                    SectionBlock(section: section, color: guide.color, isMalayalam: isMalayalam)
                }
            }
            .padding(AppTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(Color("NoorSurface").ignoresSafeArea())
        .navigationTitle(isMalayalam ? guide.titleMl : guide.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                BilingualToggle(isMalayalam: $isMalayalam)
            }
        }
    }

    private var headerBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: guide.icon).font(.largeTitle).foregroundStyle(Color(guide.color))
                Text(isMalayalam ? guide.titleMl : guide.title)
                    .font(.title2.weight(.bold))
                    .animation(.none, value: isMalayalam)
                Text(isMalayalam ? guide.subtitleMl : guide.subtitle)
                    .font(.subheadline).foregroundStyle(.secondary)
                    .animation(.none, value: isMalayalam)
            }
            Spacer()
        }
        .padding(20)
        .background(Color(guide.color).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .animation(.easeInOut(duration: 0.2), value: isMalayalam)
    }
}

// MARK: - Bilingual Toggle
struct BilingualToggle: View {
    @Binding var isMalayalam: Bool

    var body: some View {
        HStack(spacing: 0) {
            langButton(label: "EN", active: !isMalayalam) { isMalayalam = false }
            langButton(label: "മ", active: isMalayalam) { isMalayalam = true }
        }
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private func langButton(label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { action() } }) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(active ? .white : .secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(active ? Color.accentColor : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
    }
}

struct SectionBlock: View {
    let section: GuideSection
    let color: String
    let isMalayalam: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(isMalayalam ? section.headingMl : section.heading)
                .font(.headline)
                .foregroundStyle(Color(color))
            ForEach(section.steps) { step in
                StepRow(step: step, color: color, isMalayalam: isMalayalam)
            }
        }
    }
}

struct StepRow: View {
    let step: GuideStep
    let color: String
    let isMalayalam: Bool
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
                    Text(isMalayalam ? step.titleMl : step.title)
                        .font(.subheadline.weight(.semibold))
                    Text(isMalayalam ? step.detailMl : step.detail)
                        .font(.caption).foregroundStyle(.secondary).lineSpacing(3)
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
        .animation(.easeInOut(duration: 0.2), value: isMalayalam)
    }
}
